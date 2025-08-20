// Global text utilities including Korean profanity filtering wrappers.
//
// Contract:
// - isProfaneKo(text): bool — fast profanity detection (korean_profanity_filter)
// - extractProfanitiesKo(text): List<String>
// - cleanProfanitiesKo(text): String
// - censorProfanitiesKo(text, {String replacement = '※'}): String
// - addProfanityPatternsKo(pattern): void — extend regex patterns at runtime
// - isProfaneKoWithGemini(text): Future<bool> — two-phase check (local + Gemini)

import 'package:korean_profanity_filter/korean_profanity_filter.dart';
import 'package:bamstar/services/gemini.dart';

/// Returns true if the given [text] contains Korean profanity using local regex.
bool isProfaneKo(String text) => text.containsBadWords;

/// Extracts detected profanity tokens. Empty list if none.
List<String> extractProfanitiesKo(String text) => text.getListOfBadWords;

/// Removes detected profanities from [text].
String cleanProfanitiesKo(String text) => text.cleanBadWords;

/// Replaces profanities in [text] with [replacement] (default '※').
String censorProfanitiesKo(String text, {String replacement = '※'}) =>
    text.replaceBadWords(replacement);

/// Adds custom profanity regex pattern(s) at runtime.
void addProfanityPatternsKo(String pattern) {
  if (pattern.trim().isEmpty) return;
  ProfanityFilter.addPattern(pattern);
}

/// Two-phase profanity check:
/// 1) Local regex (fast). If detected -> true
/// 2) If local is clean -> ask Gemini moderation for Korean profanity/toxicity
///    Returns true if Gemini flags the text as offensive.
Future<bool> isProfaneKoWithGemini(String text) async {
  if (isProfaneKo(text)) return true;
  // Falls back to remote moderation only if local passes.
  return GeminiService.instance.isTextProfane(text);
}
