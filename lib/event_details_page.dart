import 'package:flutter/material.dart';
import 'theme/app_variables.dart';
import 'models/event_model.dart';
import 'widgets/main_nav_bar.dart';

class EventDetailsPage extends StatelessWidget {
  final EventModel event;

  const EventDetailsPage({super.key, required this.event});

  String _formatDateTime(DateTime d) {
    final day = d.day.toString().padLeft(2, '0');
    final month = d.month.toString().padLeft(2, '0');
    final year = d.year.toString().substring(2);
    final hour = d.hour.toString().padLeft(2, '0');
    final minute = d.minute.toString().padLeft(2, '0');
    return '$day/$month/$year - $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = _formatDateTime(event.date);

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(AppImages.background),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // 🔹 περιεχόμενο
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 67),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // header με back + τίτλο
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                event.title,
                                style: AppTexts.generalTitle.copyWith(
                                  fontSize: 22,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${event.location} - $dateStr',
                                style: AppTexts.generalBody.copyWith(
                                  fontStyle: FontStyle.italic,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),

                    const SizedBox(height: 16),

                    Center(
                      child: Text(
                        'Description',
                        style: AppTexts.generalTitle.copyWith(fontSize: 16),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // description box
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.ourYellow,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Text(
                        event.description,
                        style: AppTexts.generalBody.copyWith(fontSize: 14),
                      ),
                    ),

                    const SizedBox(height: 24),

                    Center(
                      child: Text(
                        'Pictures',
                        style: AppTexts.generalTitle.copyWith(fontSize: 16),
                      ),
                    ),

                    const SizedBox(height: 8),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.ourYellow,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: _buildPicturesGrid(context),
                    ),
                  ],
                ),
              )
            ),
          ),

          // 🔹 bottom nav bar (όλα inactive)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: MainNavBar(
              currentIndex: null,
              onTabSelected: (_) {
                // TODO: navigation αν θες
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPicturesGrid(BuildContext context) {
  final images = event.imageUrls.take(4).toList(); // μέχρι 4

  if (images.isEmpty) {
    // Αν δεν έχει εικόνες, δεν εμφανίζουμε τίποτα
    return const SizedBox.shrink();
  }

  return GridView.builder(
    shrinkWrap: true, // Βεβαιωνόμαστε ότι το GridView δεν θα καταλάβει όλο το διαθέσιμο χώρο
    physics: const NeverScrollableScrollPhysics(), // Απενεργοποιούμε το scroll του GridView, γιατί υπάρχει ήδη το scrollable της σελίδας
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2, // Δύο εικόνες ανά γραμμή
      crossAxisSpacing: 12, // Απόσταση ανάμεσα στις εικόνες
      mainAxisSpacing: 12,  // Απόσταση ανάμεσα στις γραμμές
      childAspectRatio: 1,  // Κάνουμε τις εικόνες τετράγωνες
    ),
    itemCount: images.length,
    itemBuilder: (context, index) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          images[index],
          fit: BoxFit.cover,  // Εικόνα που θα γεμίσει το πλαίσιο χωρίς να χάσει την αναλογία της
        ),
      );
    },
  );
}
}

