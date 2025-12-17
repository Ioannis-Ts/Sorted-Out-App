import 'package:flutter/material.dart';
import '../../theme/app_variables.dart';
import '../../widgets/events_button.dart';

class TestPage extends StatelessWidget {
  const TestPage({super.key});

  @override
  Widget build(BuildContext context) {
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

          SafeArea(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children:  [
                  EventsPillButton(
                    onTap: () => debugPrint('Go to events'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
