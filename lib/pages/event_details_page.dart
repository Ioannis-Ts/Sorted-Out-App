import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_variables.dart';
import '../models/event_model.dart';
import '../pages/create_event_page.dart';

class EventDetailsPage extends StatefulWidget {
  final EventModel event;
  final String currentUserId;

  const EventDetailsPage({
    super.key,
    required this.event,
    required this.currentUserId,
  });

  @override
  State<EventDetailsPage> createState() => _EventDetailsPageState();
}

class _EventDetailsPageState extends State<EventDetailsPage> {
  late EventModel _event;

  bool get isCreator => _event.creatorId == widget.currentUserId;

  @override
  void initState() {
    super.initState();
    _event = widget.event;
  }

  Future<void> _reloadEvent() async {
    final doc = await FirebaseFirestore.instance
        .collection('Events')
        .doc(_event.id)
        .get();

    if (!doc.exists) return;

    setState(() {
      _event = EventModel.fromDoc(doc);
    });
  }

  String _formatDateTime(DateTime d) {
    final day = d.day.toString().padLeft(2, '0');
    final month = d.month.toString().padLeft(2, '0');
    final year = d.year.toString().substring(2);
    final hour = d.hour.toString().padLeft(2, '0');
    final minute = d.minute.toString().padLeft(2, '0');
    return '$day/$month/$year - $hour:$minute';
  }

  Widget _buildHeader(BuildContext context) {
    final dateStr = _formatDateTime(_event.date);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Row(
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
                    _event.title,
                    style: AppTexts.generalTitle.copyWith(fontSize: 22),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_event.location} - $dateStr',
                    style: AppTexts.generalBody.copyWith(
                      fontStyle: FontStyle.italic,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            isCreator
                ? IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () async {
                      final updated = await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => CreateEventPage(
                            userId: widget.currentUserId,
                            eventId: _event.id,
                          ),
                        ),
                      );

                      if (updated == true) {
                        await _reloadEvent();
                      }
                    },
                  )
                : const SizedBox(width: 48),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const double staticHeaderHeight = 100.0;

    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(AppImages.background),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Scrollable Content
          Positioned.fill(
            top: staticHeaderHeight,
            bottom: 0,
            child: SingleChildScrollView(
              child: Padding(
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
                        _event.description,
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
                      child: _buildPicturesGrid(),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),

          // Header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildHeader(context),
          ),
        ],
      ),
    );
  }

  Widget _buildPicturesGrid() {
    final images = _event.imageUrls.take(4).toList();

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
