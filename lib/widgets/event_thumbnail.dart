import 'package:flutter/material.dart';
import '../theme/app_variables.dart';

class EventThumbnail extends StatelessWidget {
  final String title;
  final String location;
  final DateTime date;
  final String? imageUrl;      // ΝΕΟ
  final VoidCallback? onTap;

  const EventThumbnail({
    super.key,
    required this.title,
    required this.location,
    required this.date,
    this.imageUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final formattedDate = '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.ourYellow, // εξωτερικό κρεμ φόντο
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppColors.outline, // πολύ λεπτό γκρι περίγραμμα
            width: 1,                 // αν το θες *πολύ* λεπτό, άστο 1
          ),
        ),

        child: Container(
          margin: const EdgeInsets.all(8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white, // εσωτερικό λευκό
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // τίτλος + τοποθεσία (αριστερά)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTexts.generalTitle,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      location,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTexts.generalBody,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // ημερομηνία + “thumbnail” (δεξιά)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    formattedDate,
                    style: AppTexts.generalBody.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMain,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.textMain,
                        width: 2,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: (imageUrl != null && imageUrl!.isNotEmpty)
                          ? Image.network(
                              imageUrl!,
                              fit: BoxFit.cover,
                            )
                          : const Icon(
                              Icons.image,
                              size: 24,
                              color: Colors.black87,
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
