import 'package:flutter/material.dart';
import 'theme/app_variables.dart';
import 'widgets/event_thumbnail.dart';
import 'widgets/main_nav_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'models/event_model.dart';
import 'event_details_page.dart';


class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // BACKGROUND
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(AppImages.background),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // CONTENT
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                0,
                24,
                0,
                140, // χώρος για + και nav bar
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
                                    builder: (_) => EventDetailsPage(event: e),
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

          // ΚΟΥΜΠΙ "+"
          Positioned(
            bottom: 72, // ακριβώς πάνω από το nav bar
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () {
                  // TODO: create-event
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

          // MAIN NAV BAR
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: MainNavBar(
              currentIndex: null,
              onTabSelected: (_) {
                // TODO: navigation αργότερα
              },
            ),
          ),
        ],
      ),
    );
  }
}
