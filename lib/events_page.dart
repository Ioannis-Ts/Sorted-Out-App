import 'package:flutter/material.dart';
import 'theme/app_variables.dart';
import 'widgets/event_thumbnail.dart';
import 'widgets/main_nav_bar.dart';

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
                image: AssetImage('assets/images/background.png'),
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
                    child: ListView(
                      children: [
                        EventThumbnail(
                          title: 'Awareness Day',
                          location: 'Ntafou Park, NY',
                          date: DateTime(2026, 2, 12),
                        ),
                        EventThumbnail(
                          title: 'Awareness Day',
                          location: 'Ntafou Park, NY',
                          date: DateTime(2026, 2, 12),
                        ),
                        EventThumbnail(
                          title: 'Awareness Day',
                          location: 'Ntafou Park, NY',
                          date: DateTime(2026, 2, 12),
                        ),
                        EventThumbnail(
                          title: 'Awareness Day',
                          location: 'Ntafou Park, NY',
                          date: DateTime(2026, 2, 12),
                        ),
                        EventThumbnail(
                          title: 'Awareness Day',
                          location: 'Ntafou Park, NY',
                          date: DateTime(2026, 2, 12),
                        ),
                        EventThumbnail(
                          title: 'Awareness Day',
                          location: 'Ntafou Park, NY',
                          date: DateTime(2026, 2, 12),
                        ),
                        EventThumbnail(
                          title: 'Awareness Day',
                          location: 'Ntafou Park, NY',
                          date: DateTime(2026, 2, 12),
                        ),
                      ],
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
