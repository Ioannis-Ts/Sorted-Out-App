import 'package:flutter/material.dart';
import '../theme/app_variables.dart';
import '../models/event_model.dart';

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

  // WIDGET: The static Header
  Widget _buildHeader(BuildContext context) {
    final dateStr = _formatDateTime(event.date);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Row(
          children: [
            // Back Button
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
            const SizedBox(width: 8),
            // Title and Location/Date centered
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
            // Spacer to balance the back button
            const SizedBox(width: 48), 
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Adjust this height if your header content is taller/shorter
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

          // 2. Scrollable Content
          Positioned.fill(
            top: staticHeaderHeight, 
            bottom: 0, // ✅ Changed from 67 to 0 to use the full screen height
            child: SingleChildScrollView(
              child: Padding(
                // Added some bottom padding so content doesn't touch the very edge of the screen
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
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
          
          // 3. Static Header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildHeader(context),
          ),
          
          // REMOVED: Positioned(bottom: 0...) for MainNavBar
        ],
      ),
    );
  }
  
  // Pictures Grid Logic
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