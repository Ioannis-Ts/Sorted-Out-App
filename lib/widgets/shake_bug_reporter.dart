import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../pages/bug_report_sheet.dart';
import '../services/shake_detector_service.dart';

class ShakeBugReporter extends StatefulWidget {
  const ShakeBugReporter({
    super.key,
    required this.child,
    required this.navigatorKey,
    this.enabledShortcut = true,
    this.enabledShake = true,
  });

  final Widget child;
  final GlobalKey<NavigatorState> navigatorKey;
  final bool enabledShortcut;
  final bool enabledShake;

  @override
  State<ShakeBugReporter> createState() => _ShakeBugReporterState();
}

class _ShakeBugReporterState extends State<ShakeBugReporter>
    with WidgetsBindingObserver {
  late final ShakeDetectorService _shake;
  bool _sheetOpen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // ✅ Global keyboard handler (δεν εξαρτάται από Focus)
    if (widget.enabledShortcut) {
      HardwareKeyboard.instance.addHandler(_handleKey);
    }

    _shake = ShakeDetectorService(
      onShake: () => _openBugSheet(source: 'shake'),
    );

    // ✅ Shake: βγάλ’ το στο web (δεν έχει νόημα)
    if (widget.enabledShake && !kIsWeb) {
      _shake.start();
    }
  }

  @override
  void didUpdateWidget(covariant ShakeBugReporter oldWidget) {
    super.didUpdateWidget(oldWidget);

    // keyboard
    if (oldWidget.enabledShortcut != widget.enabledShortcut) {
      if (widget.enabledShortcut) {
        HardwareKeyboard.instance.addHandler(_handleKey);
      } else {
        HardwareKeyboard.instance.removeHandler(_handleKey);
      }
    }

    // shake
    if (oldWidget.enabledShake != widget.enabledShake) {
      if (widget.enabledShake && !kIsWeb) {
        _shake.start();
      } else {
        _shake.stop();
      }
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
    if (!widget.enabledShake || kIsWeb) return;

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _shake.stop();
    } else if (state == AppLifecycleState.resumed) {
      _shake.start();
    }
  }

  bool _handleKey(KeyEvent event) {
    if (!widget.enabledShortcut) return false;
    if (event is! KeyDownEvent) return false;

    // ✅ Σίγουρο fallback (δουλεύει πάντα): F2
    final isF2 = event.logicalKey == LogicalKeyboardKey.f2;

    // ✅ Combo: Ctrl + Alt + B (μερικές φορές Alt=AltGr σε ελληνικό layout)
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
      return true; // consume
    }

    return false;
  }

  Future<void> _openBugSheet({required String source}) async {
    if (_sheetOpen) return;

    final ctx = widget.navigatorKey.currentContext;
    if (ctx == null) return;

    _sheetOpen = true;
    try {
      await showModalBottomSheet(
        context: ctx,
        isScrollControlled: true,
        builder: (_) => BugReportSheet(source: source),
      );
    } finally {
      _sheetOpen = false;
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
