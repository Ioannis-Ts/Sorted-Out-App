import 'package:flutter/material.dart';
import '../theme/app_variables.dart';
import '../content/about_content.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 🔹 Background
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(AppImages.background),
                fit: BoxFit.cover,
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // 🔹 Top bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'About',
                        style: AppTexts.generalTitle.copyWith(fontSize: 22),
                      ),
                    ],
                  ),
                ),

                // 🔹 Fixed Yellow Box with Scrolling Text
                Expanded(
                  child: Padding(
                    // Outer margin (space around the yellow box)
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                    child: Container(
                      width: double.infinity,
                      // ✅ 1. The Container is now the parent (Fixed Frame)
                      decoration: BoxDecoration(
                        color: AppColors.ourYellow,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      // ✅ 2. The ScrollView is INSIDE the Container
                      child: ClipRRect(
                        // Clips the scrolling content to the rounded corners
                        borderRadius: BorderRadius.circular(24), 
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 24,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: AboutContent.sections.map((section) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 24),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      section['title'] ?? '',
                                      style: AppTexts.generalTitle.copyWith(
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      section['body'] ?? '',
                                      style: AppTexts.generalBody.copyWith(
                                        fontSize: 13,
                                        height: 1.45,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}