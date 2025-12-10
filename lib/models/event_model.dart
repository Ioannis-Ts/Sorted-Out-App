import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel {
  final String id;
  final String title;
  final String location;
  final DateTime date;
  final String description;
  final List<String> imageUrls;

  EventModel({
    required this.id,
    required this.title,
    required this.location,
    required this.date,
    required this.description,
    required this.imageUrls,
  });

  factory EventModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return EventModel(
      id: doc.id,
      title: data['title'] as String,
      location: data['location'] as String,
      date: (data['date'] as Timestamp).toDate(),
      description: data['description'] as String? ?? '',
      imageUrls:
          (data['imageUrls'] as List<dynamic>? ?? []).cast<String>(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'location': location,
      'date': Timestamp.fromDate(date),
      'description': description,
      'imageUrls': imageUrls,
    };
  }
}
