import 'package:flutter/material.dart';
import '../app_variables.dart'; // προσαρμόσέ το αν το αρχείο λέγεται αλλιώς

class EventThumbnail extends StatelessWidget {
  final String title;
  final String location;
  final String date;
  final VoidCallback? onTap;

  const EventThumbnail({
    super.key,
    required this.title,
    required this.location,
    required this.date,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.ouryellow,          // εξωτερικό κρεμ φόντο
          borderRadius: BorderRadius.circular(18),
        ),
        child: Container(
          margin: const EdgeInsets.all(4),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,               // εσωτερικό λευκό
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // τίτλος + περιγραφή (αριστερά)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textMain,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      location,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textMain.withOpacity(0.7),
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // ημερομηνία + εικονίδιο (δεξιά)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    date,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
                    child: const Icon(
                      Icons.image,
                      size: 24,
                      color: Colors.black87,
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
