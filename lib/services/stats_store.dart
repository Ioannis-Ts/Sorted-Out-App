import 'package:cloud_firestore/cloud_firestore.dart';

class StatsStore {
  static Stream<num> tonsStream(int year) {
    return FirebaseFirestore.instance
        .collection('Stats')
        .doc(year.toString())
        .snapshots()
        .map((doc) {
          final data = doc.data();
          if (data == null) return 0;
          final v = data['tons'];
          if (v is num) return v;
          return 0;
        });
  }
}
