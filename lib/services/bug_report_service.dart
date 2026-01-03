import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BugReportService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static Future<void> submit({
    required String message,
    required String source,
    String? route,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    await _db.collection('bug_reports').add({
      'message': message,
      'source': source, // 'shake' ή 'shortcut'
      'route': route,
      'userId': uid,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
