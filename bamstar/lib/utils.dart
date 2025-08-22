// Text utilities including Korean profanity filtering wrappers.
//
// This module exposes small, dependency-light helpers around
// `korean_profanity_filter` so UI/business code can stay clean.
//
// Contract:
// - isProfaneKo(text): bool — fast profanity detection.
// - extractProfanitiesKo(text): List<String> — list the detected tokens.
// - cleanProfanitiesKo(text): String — remove profanities from text.
// - censorProfanitiesKo(text, {String replacement = '※'}): String — replace
//   profanities with a replacement token (default '※').
// - addProfanityPatternsKo(pattern): void — extend regex patterns at runtime.
//
// Notes:
// - The underlying filter uses regex-based detection suitable for Korean.
// - Functions are platform-agnostic and work on web/mobile/desktop.
// - Keep this file UI-free; only pure utils.

import 'package:korean_profanity_filter/korean_profanity_filter.dart';

/// Returns true if the given [text] contains Korean profanity.
bool isProfaneKo(String text) {
  // String extensions are provided by the package.
  return text.containsBadWords;
}

/// Extracts detected profanity tokens. Empty list if none.
List<String> extractProfanitiesKo(String text) {
  return text.getListOfBadWords;
}

/// Removes detected profanities from [text].
String cleanProfanitiesKo(String text) {
  return text.cleanBadWords;
}

/// Replaces profanities in [text] with [replacement] (default '※').
String censorProfanitiesKo(String text, {String replacement = '※'}) {
  return text.replaceBadWords(replacement);
}

/// Adds custom profanity regex pattern(s) at runtime.
/// Accepts a single combined regex string (e.g., '패턴1|패턴2').
void addProfanityPatternsKo(String pattern) {
  if (pattern.trim().isEmpty) return;
  ProfanityFilter.addPattern(pattern);
}
