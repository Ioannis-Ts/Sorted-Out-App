import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // <--- 1. ΠΡΟΣΘΗΚΗ FIRESTORE
import '../theme/app_variables.dart';
import 'recycle_points_page.dart';
import '../widgets/main_nav_bar.dart';
import '../widgets/tree_progress_button.dart';
import '../widgets/points_cloud.dart';
import '../widgets/events_button.dart';
import '../widgets/qr_button.dart';
import '../services/stats_store.dart';
import '../widgets/tons_collected_bar.dart';
import 'events_page.dart';
import 'qr_scan_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ΣΗΜΕΙΩΣΗ: Αφαίρεσα το import του 'profile_name_button.dart'
// γιατί θα το φτιάξουμε εδώ τοπικά για να διαβάζει από το 'Profiles'.

class HomePage extends StatelessWidget {
  final String userId;
  final int pointsGoal;
  final int yearA;
  final int yearB;

  const HomePage({
    super.key,
    required this.userId,
    this.pointsGoal = 250,
    this.yearA = 2024,
    this.yearB = 2025,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // --- DYNAMIC SIZES ---
    final double treeSize = screenHeight * 0.27;
    final double cloudWidth = screenWidth * 0.80;
    final double cloudHeight = screenHeight * 0.055;
    final double qrSize = screenHeight * 0.09;
    final double navBarHeight = 90.0;

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

          // Content Layer
          SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 10, 16, navBarHeight + 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                  // --- 2. PROFILE SECTION ΜΕ LOGOUT ---
                  StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('Profiles')
                        .doc(userId)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Text("Loading...");
                      }
                      
                      var data = snapshot.data!.data() as Map<String, dynamic>?;
                      String userName = data?['name'] ?? 'User'; 

                      // Τυλίγουμε το Container με GestureDetector για να ακούει τα κλικ
                      return GestureDetector(
                        onTap: () {
                          // Εμφάνιση παραθύρου επιβεβαίωσης
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Αποσύνδεση'),
                              content: const Text('Είστε σίγουροι ότι θέλετε να αποσυνδεθείτε;'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context), // Ακύρωση
                                  child: const Text('Όχι'),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    // 1. Κλείνουμε το παράθυρο διαλόγου
                                    Navigator.pop(context);
                                    
                                    // 2. Αποσύνδεση από το Firebase
                                    await FirebaseAuth.instance.signOut();

                                    // 3. Επιστροφή στο Login και καθαρισμός ιστορικού
                                    if (context.mounted) {
                                      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                                    }
                                  },
                                  child: const Text('Ναι, Έξοδος', style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9), // (Αντικατέστησε το withOpacity αν σου βγάζει warning)
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              )
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.logout, color: Colors.redAccent, size: 20), // Άλλαξα το εικονίδιο σε logout για να είναι προφανές (ή άσε το person)
                              const SizedBox(width: 8),
                              Text(
                                userName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  const Spacer(flex: 1),

                  // --- STATS TITLE ---
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 25,
                        vertical: 0,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.outline,
                          width: 1.5,
                        ),
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Tons Collected',
                        style: AppTexts.generalBody.copyWith(
                          fontWeight: FontWeight.w700,
                          height: 1.0,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 5),

                  // --- STATS BARS ---
                  StreamBuilder<num>(
                    stream: StatsStore.tonsStream(yearA),
                    builder: (context, snapA) {
                      final tonsA = snapA.data ?? 0;
                      return StreamBuilder<num>(
                        stream: StatsStore.tonsStream(yearB),
                        builder: (context, snapB) {
                          final tonsB = snapB.data ?? 0;
                          final maxTons = (tonsA > tonsB) ? tonsA : tonsB;
                          return Column(
                            children: [
                              TonsCollectedBar(
                                year: yearA,
                                tons: tonsA,
                                maxTons: maxTons,
                              ),
                              const SizedBox(height: 8),
                              TonsCollectedBar(
                                year: yearB,
                                tons: tonsB,
                                maxTons: maxTons,
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),

                  const Spacer(flex: 2),

                  // --- TREE ---
                  Align(
                    alignment: Alignment.center,
                    child: TreeProgressButton(
                      userId: userId,
                      goal: pointsGoal,
                      size: treeSize,
                      ringWidth: treeSize * 0.05,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => RecyclePointsPage(userId: userId),
                          ),
                        );
                      },
                    ),
                  ),

                  const Spacer(flex: 2),

                  // --- CLOUD ---
                  // ΠΡΟΣΟΧΗ: Αν το PointsCloud διαβάζει εσωτερικά από τη βάση,
                  // ίσως χρειαστεί αλλαγή στο αρχείο 'points_cloud.dart' αν δείχνει 0.
                  Align(
                    alignment: Alignment.center,
                    child: PointsCloud(
                      userId: userId,
                      goal: pointsGoal,
                      minWidth: cloudWidth,
                      height: cloudHeight,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // --- BUTTONS ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      EventsPillButton(
                        height: 52,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const EventsPage(),
                            ),
                          );
                        },
                      ),
                      QrButton(
                        size: qrSize,
                        onTap: () async {
                          final result = await Navigator.of(context)
                              .push<String>(
                                MaterialPageRoute(
                                  builder: (_) => const QrScanPage(),
                                ),
                              );

                          if (result != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Scanned: $result')),
                            );
                          }
                        },
                      ),
                    ],
                  ),

                  const Spacer(flex: 3),
                ],
              ),
            ),
          ),

          // Bottom Nav Bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: MainNavBar(currentIndex: 1, currentUserId: userId),
          ),
        ],
      ),
    );
  }
}