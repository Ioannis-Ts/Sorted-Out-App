import 'dart:async';
import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';

class ShakeDetectorService {
  ShakeDetectorService({
    this.onShake,
    this.thresholdG = 2.7, // 2.2–3.0 συνήθως καλό range
    this.cooldown = const Duration(seconds: 3),
  });

  final void Function()? onShake;
  final double thresholdG;
  final Duration cooldown;

  StreamSubscription<AccelerometerEvent>? _sub;
  DateTime? _lastShake;

  // Για λίγο πιο “smooth” detection
  double _lastMag = 0.0;

  void start() {
    _sub ??= accelerometerEvents.listen((e) {
      // magnitude σε "g" περίπου (9.81 m/s^2 = 1g)
      final mag = sqrt(e.x * e.x + e.y * e.y + e.z * e.z) / 9.81;

      // “jerk” = απότομη αλλαγή magnitude
      final delta = (mag - _lastMag).abs();
      _lastMag = mag;

      final now = DateTime.now();
      final inCooldown =
          _lastShake != null && now.difference(_lastShake!) < cooldown;

      // Συνθήκη shake
      if (!inCooldown && (mag > thresholdG || delta > 1.3)) {
        _lastShake = now;
        onShake?.call();
      }
    });
  }

  void stop() async {
    await _sub?.cancel();
    _sub = null;
  }

  bool get isRunning => _sub != null;
}
