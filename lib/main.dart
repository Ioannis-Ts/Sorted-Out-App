import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
// import 'pages/test_page.dart'; // ή EventsPage, ανάλογα τι θέλεις ως αρχική
import 'pages/home_page.dart';
// import 'pages/map_page.dart';
import 'pages/ai_assistant_page.dart';
import 'pages/login_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyBbW_8xzDqwzOBd5_MYMUVUxk5qYG8ag9E',
      authDomain: 'sortedout-3aa9a.firebaseapp.com',
      projectId: 'sortedout-3aa9a',
      storageBucket: 'sortedout-3aa9a.firebasestorage.app',
      messagingSenderId: '649193972348',
      appId: '1:649193972348:web:e54f00200768cb1ccd1ff9',
      measurementId: 'G-8CQKNSWCDR', // optional, αλλά το βάζουμε
    ),
  );

  runApp(const MyApp());
}

//ΠΕΙΡΑΞΤΕ ΑΠΟ ΕΔΩ ΚΑΙ ΚΑΤΩ----------------------------------------------------------------

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const String testUserId = 'test_user';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // start page
      initialRoute: '/login',

      // named routes
      routes: {
        '/ai': (_) => const AiAssistantPage(),
        '/home': (_) => const LoginPage(),
        '/login': (context) => const LoginPage(),
        '/home': (context) => const HomePage(userId: 'test_user'),
        // '/home': (_) => const HomePage(userId: testUserId),
        // '/map': (_) => const MapPage(userId: testUserId),
      },
    );
  }
}
