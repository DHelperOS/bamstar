// Gemini moderation helper using flutter_gemini.
// - Provides a singleton GeminiService with a text profanity/toxicity check.
// - Reads API key from env: GEMINI_API_KEY (via flutter_dotenv).

import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gemini/flutter_gemini.dart' as gem;
import 'package:logging/logging.dart';

class GeminiService {
  GeminiService._internal();
  static final GeminiService instance = GeminiService._internal();

  gem.Gemini? _client;

  /// Initialize lazily with API key from .env (GEMINI_API_KEY).
  void _ensureInit() {
    if (_client != null) return;
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      // Not configured; skip creating client.
      return;
    }
    _client = gem.Gemini.instance;
    gem.Gemini.init(apiKey: apiKey);
  }

  /// Extract text from business registration image
  Future<String> extractTextFromBusinessRegistration(List<int> imageBytes) async {
    _ensureInit();
    final client = _client;
    if (client == null) {
      throw Exception('Gemini API not initialized');
    }

    try {
      final uint8List = Uint8List.fromList(imageBytes);
      final res = await client.prompt(parts: [
        gem.Part.text("이 사업자 등록증에서 모든 텍스트를 추출해주세요. 사업자등록번호, 대표자명, 개업일자, 상호명, 법인등록번호, 업태, 종목, 사업장소재지 등 모든 정보를 텍스트로 추출해주세요."),
        gem.Part.bytes(uint8List),
      ]);
      
      // Extract text from response using dynamic access
      String extractedText = '';
      try {
        final dynamic any = res;
        final candidates = (any as dynamic).candidates;
        if (candidates is List && candidates.isNotEmpty) {
          final first = candidates.first;
          final content = (first as dynamic)?.content;
          final parts = (content as dynamic)?.parts;
          if (parts is List && parts.isNotEmpty) {
            final t = (parts.first as dynamic)?.text;
            if (t is String) extractedText = t;
          }
        }
      } catch (_) {
        // Fallback to direct access if structure is different
        extractedText = res?.output ?? '';
      }
      
      return extractedText;
    } catch (e) {
      Logger('GeminiService').severe('Failed to extract text from image: $e');
      rethrow;
    }
  }
  
  /// Extract structured business data from text
  Future<Map<String, String>> extractBusinessDataFromText(String extractedText) async {
    _ensureInit();
    final client = _client;
    if (client == null) {
      throw Exception('Gemini API not initialized');
    }

    final prompt = '''
다음 텍스트에서 사업자 정보를 추출해서 JSON 형식으로 반환해주세요.
추출할 항목: businessNumber, representativeName, openingDate, businessName, corporateNumber, mainBusinessType, subBusinessType, businessAddress

텍스트:
$extractedText

JSON 형식으로만 응답해주세요:
{
  "businessNumber": "123-45-67890",
  "representativeName": "홍길동",
  "openingDate": "20240101",
  "businessName": "회사명",
  "corporateNumber": "법인번호",
  "mainBusinessType": "업태",
  "subBusinessType": "종목",
  "businessAddress": "주소"
}
    ''';

    try {
      final res = await client.prompt(parts: [gem.Part.text(prompt)]);
      
      String resultText = '';
      try {
        final dynamic any = res;
        final candidates = (any as dynamic).candidates;
        if (candidates is List && candidates.isNotEmpty) {
          final first = candidates.first;
          final content = (first as dynamic)?.content;
          final parts = (content as dynamic)?.parts;
          if (parts is List && parts.isNotEmpty) {
            final t = (parts.first as dynamic)?.text;
            if (t is String) resultText = t;
          }
        }
      } catch (_) {
        resultText = res?.output ?? '{}';
      }
      
      // Parse JSON response
      try {
        // Extract JSON from response (sometimes wrapped in markdown code blocks)
        final jsonMatch = RegExp(r'\{[^}]*\}').firstMatch(resultText);
        final jsonStr = jsonMatch?.group(0) ?? resultText;
        
        final Map<String, dynamic> parsed = Map<String, dynamic>.from(
          (jsonStr.contains('{') && jsonStr.contains('}')) 
            ? Map<String, dynamic>.from({
                'businessNumber': '',
                'representativeName': '',
                'openingDate': '',
                'businessName': '',
                'corporateNumber': '',
                'mainBusinessType': '',
                'subBusinessType': '',
                'businessAddress': '',
              })
            : {}
        );
        
        // Try to parse the actual JSON
        try {
          final actualData = Map<String, dynamic>.from(
            RegExp(r'"(\w+)"\s*:\s*"([^"]*)"')
                .allMatches(resultText)
                .fold<Map<String, String>>({}, (map, match) {
              map[match.group(1)!] = match.group(2)!;
              return map;
            })
          );
          
          if (actualData.isNotEmpty) {
            parsed.addAll(actualData);
          }
        } catch (_) {}
        
        return Map<String, String>.from(
          parsed.map((key, value) => MapEntry(key, value?.toString() ?? ''))
        );
      } catch (_) {
        // Return empty map if parsing fails
        return {
          'businessNumber': '',
          'representativeName': '',
          'openingDate': '',
          'businessName': '',
          'corporateNumber': '',
          'mainBusinessType': '',
          'subBusinessType': '',
          'businessAddress': '',
        };
      }
    } catch (e) {
      Logger('GeminiService').severe('Failed to extract business data: $e');
      return {};
    }
  }

  /// Compare business registration data and calculate match percentage
  Future<double> compareBusinessData({
    required String apiData,
    required String extractedText,
  }) async {
    _ensureInit();
    final client = _client;
    if (client == null) {
      throw Exception('Gemini API not initialized');
    }

    final prompt = '''
다음 두 개의 사업자 정보를 비교해서 일치율을 계산해주세요.
사업자등록번호, 대표자명, 개업일자 3개 항목만 비교합니다.
각 항목이 완전히 일치하면 33.33점씩 부여합니다.

API에서 받은 정보:
$apiData

이미지에서 추출한 정보:
$extractedText

세 항목의 일치율을 0-100 사이의 숫자로만 응답해주세요.
- 3개 모두 일치: 100
- 2개 일치: 67
- 1개 일치: 33
- 모두 불일치: 0

숫자만 응답: 
    ''';

    try {
      final res = await client.prompt(parts: [gem.Part.text(prompt)]);
      
      // Extract text from response
      String resultText = '0';
      try {
        final dynamic any = res;
        final candidates = (any as dynamic).candidates;
        if (candidates is List && candidates.isNotEmpty) {
          final first = candidates.first;
          final content = (first as dynamic)?.content;
          final parts = (content as dynamic)?.parts;
          if (parts is List && parts.isNotEmpty) {
            final t = (parts.first as dynamic)?.text;
            if (t is String) resultText = t;
          }
        }
      } catch (_) {
        // Fallback
        resultText = res?.output ?? '0';
      }
      
      final percentage = double.tryParse(resultText.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
      return percentage.clamp(0.0, 100.0);
    } catch (e) {
      Logger('GeminiService').severe('Failed to compare business data: $e');
      return 0.0;
    }
  }

  /// Returns true if the text should be considered profane/toxic.
  Future<bool> isTextProfane(String text) async {
    _ensureInit();
    final client = _client;
    if (client == null) {
      // If not configured, default allow.
      return false;
    }

    final prompt =
        'You are a strict Korean content moderator. Analyze the following text and respond with ONLY "true" or "false". '
        'Return "true" if the text contains profanity, hate speech, harassment, sexual explicit expressions, or severe toxicity in Korean; '
        'otherwise return "false". Text: "$text"';

    try {
      // Use dynamic to support API shape differences across versions.
      final res = await client.prompt(parts: [gem.Part.text(prompt)]);
      String raw = '';
      try {
        // Parse candidates -> content -> parts[0].text
        final dynamic any = res;
        final candidates = (any as dynamic).candidates;
        if (candidates is List && candidates.isNotEmpty) {
          final first = candidates.first;
          final content = (first as dynamic)?.content;
          final parts = (content as dynamic)?.parts;
          if (parts is List && parts.isNotEmpty) {
            final t = (parts.first as dynamic)?.text;
            if (t is String) raw = t;
          }
        }
      } catch (_) {
        // ignore
      }

      raw = raw.trim().toLowerCase();
      if (kDebugMode) {
        final log = Logger('GeminiService');
        log.fine('[Gemini moderation] input=${text.length} chars, result=$raw');
      }
      if (raw == 'true') return true;
      if (raw == 'false') return false;
      return false;
    } catch (_) {
      // Network/API error: fail-open
      return false;
    }
  }
}
