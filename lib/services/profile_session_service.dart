import 'package:cloud_firestore/cloud_firestore.dart';
//import 'profile_points_store.dart';

class ProfileSessionService {
  static final _db = FirebaseFirestore.instance;

  static Future<void> handleLogin(String userId) async {
    print('🔥 handleLogin CALLED for userId = $userId');

    final ref = _db.collection('Profiles').doc(userId);

    await _db.runTransaction((tx) async {
      print('📥 Transaction started');

      final snap = await tx.get(ref);
      final data = snap.data();

      print('📄 Profile document exists: ${snap.exists}');
      print('📄 Profile data: $data');

      final now = DateTime.now();
      print('🕒 NOW = $now');

      DateTime? lastLogin;

      if (data != null && data['lastlogin'] is Timestamp) {
        lastLogin = (data['lastlogin'] as Timestamp).toDate();
        print('🕒 lastLogin from Firestore = $lastLogin');
      } else {
        print('⚠️ lastlogin missing or not Timestamp');
      }

      final bool isNewMonth = lastLogin == null ||
          lastLogin.year != now.year ||
          lastLogin.month != now.month;

      print('📆 isNewMonth = $isNewMonth');

      if (isNewMonth) {
        print('🔁 RESETTING totalpoints to 0');
        tx.set(
          ref,
          {'totalpoints': 0},
          SetOptions(merge: true),
        );
      }

      print('📝 Updating lastlogin');
      tx.set(
        ref,
        {'lastlogin': Timestamp.fromDate(now)},
        SetOptions(merge: true),
      );
    });

    print('✅ handleLogin FINISHED');
  }
}
