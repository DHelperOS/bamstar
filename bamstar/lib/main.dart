// State management policy: this project uses
//  - flutter_riverpod: ^2.6.1
//  - flutter_bloc: ^9.1.1
// All new stateful logic should follow these versions and patterns.
// See dev/state_management_guidelines.md for examples and conventions.
import 'package:flutter/material.dart';
import 'scenes/onboarding_page.dart';
import 'scenes/login_page.dart';
import 'scenes/roles_select.dart';
import 'scenes/place_home_page.dart';
import 'scenes/community/community_home_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import 'auth/supabase_env.dart';
import 'package:kakao_flutter_sdk_common/kakao_flutter_sdk_common.dart'
    as kakao_common;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logging/logging.dart';
import 'utils/global_toast.dart';
import 'services/analytics.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Setup simple logging
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((rec) {
    // Include time, level, logger name and stacktrace when present
    final st = rec.stackTrace == null ? '' : '\n${rec.stackTrace}';
    // Log via dart:developer or stdout using Logger formatting
    // Use debugPrint to avoid linter avoid_print warning in production.
    // ignore: avoid_print
    print(
      '${rec.time.toIso8601String()} [${rec.level.name}] ${rec.loggerName}: ${rec.message}$st',
    );
  });
  final log = Logger('main');
  bool supabaseInitOk = true;
  // Load environment
  await dotenv.load(fileName: '.env');
  // Initialize Kakao SDK if key provided (Android/iOS)
  try {
    if (kakaoNativeAppKey.isNotEmpty) {
      kakao_common.KakaoSdk.init(nativeAppKey: kakaoNativeAppKey);
      log.info('Kakao SDK initialized');
    }
  } catch (e, st) {
    log.severe('Failed to initialize Kakao SDK: $e', e, st);
  }

  // Initialize Supabase once, read from .env and log errors clearly.
  try {
    if ((supabaseUrl).isNotEmpty && (supabaseAnonKey).isNotEmpty) {
      await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
      log.info('Supabase initialized (url: $supabaseUrl)');
      supabaseInitOk = true;
    } else {
      log.warning(
        'Supabase URL or ANON key missing in .env — SUPABASE_URL: ${supabaseUrl.isNotEmpty}, SUPABASE_ANON_KEY: ${supabaseAnonKey.isNotEmpty}',
      );
      supabaseInitOk = false;
    }
  } catch (e, st) {
    // Specific helpful message for the common "before calling supabase.instance" error
    log.severe('Error initializing Supabase: $e', e, st);
    supabaseInitOk = false;
  }
  // Initialize Firebase Analytics (best-effort)
  try {
    await AnalyticsService.ensureInitialized();
  } catch (_) {}
  // If Supabase failed to initialize, pass that state into the app so we can
  // show a helpful full-screen error UI.
  // Initialize router (reads SharedPreferences) before starting the app so
  // initial route honors whether onboarding was seen.
  await initRouter();
  runApp(ProviderScope(child: MyApp(supabaseInitOk: supabaseInitOk)));
}

late final GoRouter _router;

Future<void> initRouter() async {
  final prefs = await SharedPreferences.getInstance();
  final seen = prefs.getBool('seen_onboarding') ?? false;
  // If onboarding seen and Supabase session exists, start at home instead of login
  String initial;
  try {
    final session = Supabase.instance.client.auth.currentSession;
    if (!seen) {
      initial = '/';
    } else if (session != null) {
      initial = '/home';
    } else {
      initial = '/login';
    }
  } catch (_) {
    // Fallback if Supabase is not initialized for any reason
    initial = seen ? '/login' : '/';
  }
  _router = GoRouter(
    navigatorKey: appNavigatorKey,
    initialLocation: initial,
    routes: [
      GoRoute(path: '/', builder: (context, state) => const OnboardingScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(
        path: '/roles',
        builder: (context, state) => const RoleSelectPage(),
      ),
      GoRoute(path: '/home', builder: (context, state) => const MainScreen()),
      GoRoute(
        path: '/community',
        builder: (context, state) => const CommunityHomePage(),
      ),
    ],
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.supabaseInitOk = true});

  final bool supabaseInitOk;

  @override
  Widget build(BuildContext context) {
    if (!supabaseInitOk) {
      return MaterialApp(
        title: 'BamStar - Error',
        theme: AppTheme.lightTheme,
        home: Scaffold(
          appBar: AppBar(title: const Text('초기화 오류')),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.error_outline, size: 64, color: Colors.red),
                  SizedBox(height: 16),
                  Text(
                    '앱 초기화에 실패했습니다. 환경 변수(SUPABASE_URL, SUPABASE_ANON_KEY)를 확인하세요.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return MaterialApp.router(
      title: 'BamStar',
      themeMode: ThemeMode.system,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      routerConfig: _router,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
