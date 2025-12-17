import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePointsStore {
  static final _db = FirebaseFirestore.instance;

  static DocumentReference<Map<String, dynamic>> _doc(String userId) {
    return _db.collection('Profiles').doc(userId);
  }

  /// Live stream of totalpoints (defaults to 0 if missing)
  static Stream<int> pointsStream(String userId) {
    return _doc(userId).snapshots().map((snap) {
      final data = snap.data();
      final value = data?['totalpoints'];
      if (value is int) return value;
      if (value is num) return value.toInt();
      return 0;
    });
  }

  /// Set totalpoints (creates the document if it doesn't exist)
  static Future<void> setPoints(String userId, int points) async {
    await _doc(userId).set({'totalpoints': points}, SetOptions(merge: true));
  }

  /// Add delta to totalpoints safely (transaction)
  static Future<void> addPoints(String userId, int delta) async {
    final ref = _doc(userId);

    await _db.runTransaction((tx) async {
      final snap = await tx.get(ref);
      final current = (snap.data()?['totalpoints'] as num?)?.toInt() ?? 0;
      tx.set(ref, {'totalpoints': current + delta}, SetOptions(merge: true));
    });
  }
}
