import 'package:flutter/material.dart';

class AppImages{

static const String background = 'assets/images/background.png';

}

class AppColors {
  AppColors._(); 

  // ======== MAIN BRAND COLORS (από Figma) ========

  static const Color main = Color(0xFF8B99FF);
  static const Color grey = Color(0xFF777070);
  static const Color grey2 = Color.fromARGB(255, 82, 76, 76);
  static const Color lightGrey = Color(0xFFEAEAEA);
  static const Color outline = Color(0xFFA69E9E);
  static const Color anotherGrey = Color(0xFF535252);
  static const Color ourYellow = Color(0xFFFFFAE2);

  // ======== ΒΟΗΘΗΤΙΚΑ (μπορούμε να τα προσαρμόσουμε αργότερα) ========

  static const Color textMain = anotherGrey;      // αντί για μαύρο κείμενο
  static const Color textMuted = grey;  // πιο ήσυχο κείμενο
}

class AppTexts {
  AppTexts._(); // private constructor

  /// Γενικός τίτλος
  static const TextStyle generalTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.textMain,
    fontFamily: 'IstokWeb',
  );

  /// Γενικό κείμενο
  static const TextStyle generalBody = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
    fontFamily: 'IstokWeb',
  );
}


class AppPoints {
  AppPoints._();

  static const int plastic     = 2;
  static const int paper       = 1;
  static const int glass       = 4;
  static const int metal       = 4;
  static const int batteries   = 5;
  static const int electronics = 6;
  static const int food        = 2;
}
