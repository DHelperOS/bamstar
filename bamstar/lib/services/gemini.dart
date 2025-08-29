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
        gem.Part.text("이 사업자등록증명서에서 다음 정보를 정확히 추출해주세요:\n- 발급번호\n- 사업자등록번호\n- 상호(법인명)\n- 성명(대표자)\n- 주민(법인)등록번호\n- 사업장소재지\n- 개업일\n- 사업자등록일\n- 업태\n- 종목\n- 공동사업자\n\n모든 텍스트를 정확히 추출해주세요."),
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
다음 텍스트에서 사업자등록증명서 정보를 추출해서 JSON 형식으로 반환해주세요.

텍스트:
$extractedText

JSON 형식으로만 응답해주세요 (없는 항목은 빈 문자열로):
{
  "businessNumber": "552-10-45-3728-552",
  "representativeName": "윤미나",
  "openingDate": "20250804",
  "businessName": "밤컴퍼니(Bam Company)",
  "corporateNumber": "951219-*******",
  "mainBusinessType": "정보통신업",
  "subBusinessType": "포털 및 기타 인터넷 정보 매개 서비스업",
  "businessAddress": "경기도 수원시 권선구 경수대로384번길 60, 502호(권선동, SONOHEIM)"
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
사업자등록번호, 성명(대표자), 개업일 3개 항목만 비교합니다.
각 항목이 완전히 일치하면 33.33점씩 부여합니다.

국세청 API에서 받은 정보:
$apiData

사업자등록증명서에서 추출한 정보:
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
