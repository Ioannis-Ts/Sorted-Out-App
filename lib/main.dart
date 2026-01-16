import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'pages/map_page.dart';
import 'pages/ai_assistant_page.dart';

import 'pages/bug_report_sheet.dart';
import 'services/shake_detector_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyBbW_8xzDqwzOBd5_MYMUVUxk5qYG8ag9E',
      authDomain: 'sortedout-3aa9a.firebaseapp.com',
      projectId: 'sortedout-3aa9a',
      storageBucket: 'sortedout-3aa9a.firebasestorage.app',
      messagingSenderId: '649193972348',
      appId: '1:649193972348:web:e54f00200768cb1ccd1ff9',
      measurementId: 'G-8CQKNSWCDR',
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final GlobalKey<NavigatorState> _navKey = GlobalKey<NavigatorState>();

  late final ShakeDetectorService _shake;
  bool _sheetOpen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    HardwareKeyboard.instance.addHandler(_handleKey);

    _shake = ShakeDetectorService(
      onShake: () => _openBugSheet(source: 'shake'),
    );
    if (!kIsWeb) {
      _shake.start();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    HardwareKeyboard.instance.removeHandler(_handleKey);
    _shake.stop();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (kIsWeb) return;

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _shake.stop();
    } else if (state == AppLifecycleState.resumed) {
      _shake.start();
    }
  }

  bool _handleKey(KeyEvent event) {
    if (event is! KeyDownEvent) return false;

    final isF2 = event.logicalKey == LogicalKeyboardKey.f2;

    final pressed = HardwareKeyboard.instance.logicalKeysPressed;
    final ctrl =
        pressed.contains(LogicalKeyboardKey.controlLeft) ||
        pressed.contains(LogicalKeyboardKey.controlRight);
    final alt =
        pressed.contains(LogicalKeyboardKey.altLeft) ||
        pressed.contains(LogicalKeyboardKey.altRight);
    final isCombo = event.logicalKey == LogicalKeyboardKey.keyB && ctrl && alt;

    if (isF2 || isCombo) {
      _openBugSheet(source: 'shortcut');
      return true;
    }

    return false;
  }

  Future<void> _openBugSheet({required String source}) async {
    if (_sheetOpen) return;

    final ctx = _navKey.currentContext;
    if (ctx == null) return;

    _sheetOpen = true;
    try {
      await showModalBottomSheet(
        context: ctx,
        useRootNavigator: true,
        isScrollControlled: true,
        builder: (_) => BugReportSheet(source: source),
      );
    } finally {
      _sheetOpen = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget homeGate() {
      return StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snap) {
          final user = snap.data;
          if (user == null) return const LoginPage();
          return HomePage(userId: user.uid);
        },
      );
    }

    return MaterialApp(
      navigatorKey: _navKey,
      debugShowCheckedModeBanner: false,
      initialRoute: '/home',
      routes: {
        '/login': (_) => const LoginPage(),
        '/home': (_) => homeGate(),
        '/ai': (_) => const AiAssistantPage(),
        '/map': (_) => MapPage(),
      },
    );
  }
}
