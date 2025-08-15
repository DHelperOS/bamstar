import 'package:flutter/material.dart';
import 'scenes/onboarding_page.dart';

// --- 라이트 모드 색상 정의 ---
const Color lightBackgroundColor = Color(0xFFF6F6FA); // 배경: 부드러운 라벤더 화이트
const Color lightSurfaceColor = Color(0xFFFFFFFF); // 카드 배경: 깨끗한 흰색
const Color lightPrimaryColor = Color(0xFFC4A8FF); // 주조색: 부드러운 라벤더
const Color lightPrimaryVariantColor = Color(0xFF9479EA); // 강조색: 더 진한 보라
const Color lightTextColorPrimary = Color(0xFF2D3057); // 기본 텍스트: 짙은 남색
const Color lightTextColorSecondary = Color(0xFF9B9CB5); // 보조 텍스트: 연한 회색

// --- 다크 모드 색상 정의 ---
const Color darkBackgroundColor = Color(0xFF1C1B29); // 배경: 짙은 인디고
const Color darkSurfaceColor = Color(0xFF2A2A3D); // 카드 배경: 한 톤 밝은 보라
const Color darkPrimaryColor = Color(0xFFA77DFF); // 주조색: 밝은 라벤더 (네온 느낌)
const Color darkPrimaryVariantColor = Color(0xFFC4A8FF); // 강조색: 더 밝은 라벤더
const Color darkTextColorPrimary = Color(0xFFE0E0E0); // 기본 텍스트: 오프 화이트
const Color darkTextColorSecondary = Color(0xFF9B9CB5); // 보조 텍스트: (라이트 모드와 동일하게 유지 가능)

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final lightScheme = ColorScheme(
      brightness: Brightness.light,
      primary: lightPrimaryColor,
      onPrimary: lightTextColorPrimary,
      secondary: lightPrimaryVariantColor,
      onSecondary: lightTextColorPrimary,
  error: Colors.red.shade700,
  onError: Colors.white,
      surface: lightSurfaceColor,
      onSurface: lightTextColorPrimary,
    );

    final darkScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: darkPrimaryColor,
      onPrimary: darkTextColorPrimary,
      secondary: darkPrimaryVariantColor,
      onSecondary: darkTextColorPrimary,
  error: Colors.red.shade400,
  onError: Colors.black,
      surface: darkSurfaceColor,
      onSurface: darkTextColorPrimary,
    );

    return MaterialApp(
      title: 'Flutter Demo',
      themeMode: ThemeMode.system,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: lightScheme,
  scaffoldBackgroundColor: lightBackgroundColor,
        cardColor: lightScheme.surface,
        cardTheme: const CardThemeData(
          color: lightSurfaceColor,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: lightBackgroundColor,
          foregroundColor: lightTextColorPrimary,
          elevation: 0,
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: lightScheme.primary,
          foregroundColor: lightScheme.onPrimary,
        ),
        textTheme: ThemeData.light().textTheme.apply(
              bodyColor: lightTextColorPrimary,
              displayColor: lightTextColorPrimary,
            ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: lightSurfaceColor,
          selectedItemColor: lightPrimaryVariantColor,
          unselectedItemColor: lightTextColorSecondary,
        ),
        dialogTheme: const DialogThemeData(
          backgroundColor: lightSurfaceColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: lightSurfaceColor,
          disabledColor: lightSurfaceColor,
          selectedColor: lightPrimaryVariantColor.withAlpha(51),
          secondarySelectedColor: lightPrimaryColor.withAlpha(51),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          labelStyle: const TextStyle(color: lightTextColorPrimary),
          secondaryLabelStyle: const TextStyle(color: lightTextColorPrimary),
          brightness: Brightness.light,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: lightPrimaryVariantColor,
            foregroundColor: lightTextColorPrimary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: lightPrimaryColor),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: lightPrimaryColor,
            side: BorderSide(color: lightPrimaryColor.withAlpha(31)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: darkScheme,
  scaffoldBackgroundColor: darkBackgroundColor,
        cardColor: darkScheme.surface,
        cardTheme: const CardThemeData(
          color: darkSurfaceColor,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: darkBackgroundColor,
          foregroundColor: darkTextColorPrimary,
          elevation: 0,
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: darkScheme.primary,
          foregroundColor: darkScheme.onPrimary,
        ),
        textTheme: ThemeData.dark().textTheme.apply(
              bodyColor: darkTextColorPrimary,
              displayColor: darkTextColorPrimary,
            ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: darkSurfaceColor,
          selectedItemColor: darkPrimaryVariantColor,
          unselectedItemColor: darkTextColorSecondary,
        ),
        dialogTheme: const DialogThemeData(
          backgroundColor: darkSurfaceColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: darkSurfaceColor,
          disabledColor: darkSurfaceColor,
          selectedColor: darkPrimaryVariantColor.withAlpha(51),
          secondarySelectedColor: darkPrimaryColor.withAlpha(51),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          labelStyle: const TextStyle(color: darkTextColorPrimary),
          secondaryLabelStyle: const TextStyle(color: darkTextColorPrimary),
          brightness: Brightness.dark,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: darkPrimaryVariantColor,
            foregroundColor: darkTextColorPrimary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: darkPrimaryColor),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: darkPrimaryColor,
            side: BorderSide(color: darkPrimaryColor.withAlpha(31)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
  home: const OnboardingPage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Use appBarTheme backgroundColor for predictable theming
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
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
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
