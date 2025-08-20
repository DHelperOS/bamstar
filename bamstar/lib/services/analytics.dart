import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:logging/logging.dart';

/// Thin analytics wrapper used across the app.
/// Call `AnalyticsService.ensureInitialized()` early in `main()`.
class AnalyticsService {
  static final Logger _log = Logger('AnalyticsService');
  static FirebaseAnalytics? _analytics;

  static Future<void> ensureInitialized() async {
    try {
      await Firebase.initializeApp();
      _analytics = FirebaseAnalytics.instance;
      _log.info('Firebase initialized for analytics');
    } catch (e, st) {
      _log.warning('Firebase.initializeApp failed: $e', e, st);
    }
  }

  static Future<void> logEvent(String name, {Map<String, Object?>? params}) async {
    try {
      _log.fine('logEvent: $name params=$params');
    // Firebase API expects Map<String, Object>? (non-nullable values).
  final filtered = params?.map<String, Object>((k, v) => MapEntry(k, v as Object));
    await _analytics?.logEvent(name: name, parameters: filtered);
    } catch (e, st) {
      _log.warning('Failed to log event $name: $e', e, st);
    }
  }

  static Future<void> setUserId(String? uid) async {
    try {
      await _analytics?.setUserId(id: uid);
    } catch (e, st) {
      _log.warning('Failed to set user id for analytics: $e', e, st);
    }
  }

  /// Helper used in debug to enable verbose logging locally.
  static void enableDebugLogging() {
    _log.info('Analytics debug logging enabled');
    FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
  }
}
