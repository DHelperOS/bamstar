// Gemini moderation helper using flutter_gemini.
// - Provides a singleton GeminiService with a text profanity/toxicity check.
// - Reads API key from env: GEMINI_API_KEY (via flutter_dotenv).

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gemini/flutter_gemini.dart' as gem;

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
      final dynamic res = await client.prompt(parts: [gem.Part.text(prompt)]);
      String raw = '';
      try {
        // Newer API often exposes `outputText` on the response object.
        final ot = (res as dynamic)?.outputText;
        if (ot is String) raw = ot;
      } catch (_) {
        // ignore
      }
      if (raw.isEmpty) {
        try {
          // Fallback: candidates -> content -> parts[0].text
          final candidates = (res as dynamic)?.candidates;
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
      }

      raw = raw.trim().toLowerCase();
      if (kDebugMode) {
        // ignore: avoid_print
        print('[Gemini moderation] input=${text.length} chars, result=$raw');
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
