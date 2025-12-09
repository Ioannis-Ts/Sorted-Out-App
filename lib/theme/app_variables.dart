import 'package:flutter/material.dart';

class AppImages{

static const String background = 'assets/images/background.png';

}

class AppColors {
  AppColors._(); 

  // ======== MAIN BRAND COLORS (από Figma) ========

  // Our Main Color
  static const Color main = Color(0xFF8B99FF);

  // Our Grey Color
  static const Color grey = Color(0xFF777070);

  // Our Grey Color 2 (ίδιο hex, ειλικρινά δεν ξέρω γιατί θα το δούμε στην πορεία)
  static const Color grey2 = Color(0xFF777070);

  // Our Light Grey Color
  static const Color lightGrey = Color(0xFFEAEAEA);

  // Outline Color
  static const Color outline = Color(0xFFA69E9E);

  // Another Grey Color
  static const Color anotherGrey = Color(0xFF535252);

  // Our Yellow Color
  static const Color ourYellow = Color(0xFFFFFAE2);

  // ======== ΒΟΗΘΗΤΙΚΑ (μπορούμε να τα προσαρμόσουμε αργότερα) ========

  static const Color textMain = anotherGrey;      //στα events και γενικά αντί για μαύρο κείμενο
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
