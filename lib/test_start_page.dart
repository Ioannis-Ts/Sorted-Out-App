import 'package:flutter/material.dart';
import 'events_page.dart';

class TestStartPage extends StatelessWidget {
  const TestStartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Navigation'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const EventsPage(),
              ),
            );
          },
          child: const Text('Go to Events'),
        ),
      ),
    );
  }
}
