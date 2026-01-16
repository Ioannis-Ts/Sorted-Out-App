import 'dart:async';
import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:vibration/vibration.dart'; // 1. Import the package

class ShakeDetectorService {
  ShakeDetectorService({
    this.onShake,
    this.thresholdG = 2.7,
    this.cooldown = const Duration(seconds: 3),
  });

  final void Function()? onShake;
  final double thresholdG;
  final Duration cooldown;

  StreamSubscription<AccelerometerEvent>? _sub;
  DateTime? _lastShake;

  double _lastMag = 0.0;

  void start() {
    // 2. Mark the listener as 'async' to allow Vibration calls
    _sub ??= accelerometerEvents.listen((e) async {
      final mag = sqrt(e.x * e.x + e.y * e.y + e.z * e.z) / 9.81;

      final delta = (mag - _lastMag).abs();
      _lastMag = mag;

      final now = DateTime.now();
      final inCooldown =
          _lastShake != null && now.difference(_lastShake!) < cooldown;

      // Συνθήκη shake
      if (!inCooldown && (mag > thresholdG || delta > 1.3)) {
        _lastShake = now;

        // 3. Trigger Vibration
        // Check if device has a motor first to avoid errors
        if (await Vibration.hasVibrator()) {
          // Vibrate for 500 milliseconds (half a second)
          Vibration.vibrate(duration: 500);
        }

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