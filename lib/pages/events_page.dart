import 'package:flutter/material.dart';
import '../theme/app_variables.dart';
import '../widgets/event_thumbnail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event_model.dart';
import 'event_details_page.dart';
import 'create_event_page.dart';

class EventsPage extends StatefulWidget {
  final String userId;
  const EventsPage({super.key, required this.userId});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. BACKGROUND
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(AppImages.background),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // 2. CONTENT
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                0,
                24,
                0,
                110, // ✅ Reduced padding: More space for the list, just enough to clear the button
              ),
              child: Column(
                children: [
                  Center(
                    child: Text(
                      'Events',
                      style: AppTexts.generalTitle.copyWith(fontSize: 24),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // ✅ Expanded now takes up all the extra space left by removing the nav bar
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('Events')
                          .orderBy('date')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        if (snapshot.hasError) {
                          return const Center(child: Text('Error loading events'));
                        }

                        final docs = snapshot.data?.docs ?? [];

                        if (docs.isEmpty) {
                          return const Center(child: Text('No events yet'));
                        }

                        final events = docs.map((d) => EventModel.fromDoc(d)).toList();

                        return ListView.builder(
                          // Adding top padding to list prevents first item from sticking to title
                          padding: const EdgeInsets.only(top: 8), 
                          itemCount: events.length,
                          itemBuilder: (context, index) {
                            final e = events[index];
                            return EventThumbnail(
                              title: e.title,
                              location: e.location,
                              date: e.date,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => EventDetailsPage(event: e, currentUserId: widget.userId,),
                                  ),
                                );
                              },
                              imageUrl: e.imageUrls.isNotEmpty ? e.imageUrls.first : null,
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. BACK ARROW (Top Left)
          Positioned(
            top: 0,
            left: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, size: 28),
                  color: AppColors.textMain,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ),
          ),

          // 4. "+" BUTTON (Moved Down)
          Positioned(
            bottom: 32, // ✅ Moved closer to bottom since Nav Bar is gone
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => CreateEventPage(userId: widget.userId),
                    ),
                  );
                },
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.ourYellow,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.add,
                    size: 32,
                    color: AppColors.textMain,
                  ),
                ),
              ),
            ),
          ),
          
          // REMOVED: MainNavBar Positioned widget
        ],
      ),
    );
  }
}