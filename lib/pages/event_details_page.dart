import 'package:flutter/material.dart';
import '../theme/app_variables.dart';
import '../models/event_model.dart';
import '../widgets/main_nav_bar.dart';

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

  // WIDGET: Το στατικό Header (παραμένει το ίδιο)
  Widget _buildHeader(BuildContext context) {
    final dateStr = _formatDateTime(event.date);

    // Το SafeArea διασφαλίζει ότι το header δεν κρύβεται πίσω από την εγκοπή (notch)
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Row(
          children: [
            // Κουμπί Πίσω (Είναι ήδη μέσα στο header)
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
            const SizedBox(width: 8),
            // Τίτλος και Ημερομηνία/Τοποθεσία στο κέντρο
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
            // Κενό για να ισοσταθμίσει το IconButton αριστερά
            const SizedBox(width: 48), 
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 💡 Αλλάξτε αυτό το ύψος αν το header σας είναι ψηλότερο ή κοντύτερο.
    const double staticHeaderHeight = 100.0; 

    return Scaffold(
      body: Stack(
        children: [
          // 1. Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(AppImages.background),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // 2. Scrollable Περιεχόμενο (ξεκινάει κάτω από το Header)
          Positioned.fill(
            top: staticHeaderHeight, 
            bottom: 67, // Το ύψος της bottom nav bar
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                    const SizedBox(height: 24), 
                  ],
                ),
              ),
            ),
          ),
          
          // 3. Στατικό Header (Η ΔΙΟΡΘΩΣΗ ΕΙΝΑΙ ΕΔΩ)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildHeader(context),
          ),
          
          // 4. Bottom nav bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: MainNavBar(
              currentIndex: null,
            ),
          ),
        ],
      ),
    );
  }
  
  // Κώδικας _buildPicturesGrid...
  Widget _buildPicturesGrid(BuildContext context) {
    final images = event.imageUrls.take(4).toList(); 

    if (images.isEmpty) {
      return const SizedBox.shrink();
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(), 
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemCount: images.length,
      itemBuilder: (context, index) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            images[index],
            fit: BoxFit.cover,
          ),
        );
      },
    );
  }
}