import 'dart:ui';

import 'package:flutter/cupertino.dart';


class AppColors {
  // Primary Brand Colors
  static const Color primaryDark = Color(0xFF050040);      // #050040
  static const Color primaryAccent = Color(0xFFD39841);    // #D39841
  static const Color primaryLight = Color(0xFFA9D4E7);     // #A9D4E7
  static const Color pureBlack = Color(0xFF000000);        // #000000

  // Secondary Colors
  static const Color secondaryDark = Color(0xFF2A2A72);
  static const Color secondaryLight = Color(0xFFFDF6EF);

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);

  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = pureBlack; // Using your pure black
  static const Color grey = Color(0xFF9E9E9E);
  static const Color lightGrey = Color(0xFFE0E0E0);
  static const Color darkGrey = Color(0xFF424242);

  // Background Colors
  static const Color scaffoldBackground = Color(0xFFFFFFFF);
  static const Color cardBackground = Color(0xFFF5F5F5);

  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);

  // Button Colors
  static const Color buttonPrimary = primaryDark;      // #050040
  static const Color buttonSecondary = primaryAccent;  // #D39841
  static const Color buttonLight = primaryLight;       // #A9D4E7
  static const Color buttonDisabled = Color(0xFFE0E0E0);

  // Border Colors
  static const Color borderPrimary = primaryDark;      // #050040
  static const Color borderAccent = primaryAccent;     // #D39841
  static const Color borderLight = Color(0xFFE0E0E0);

  // Icon Colors
  static const Color iconPrimary = primaryDark;        // #050040
  static const Color iconAccent = primaryAccent;       // #D39841
  static const Color iconLight = primaryLight;         // #A9D4E7

  // Shadow Colors
  static const Color shadowLight = Color(0x1A000000);  // 10% opacity black
  static const Color shadowDark = Color(0x33000000);   // 20% opacity black

  // Gradient Colors
  static const Gradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryDark, Color(0xFF2A2A72)], // #050040 to darker blue
  );

  static const Gradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryAccent, Color(0xFFFFB74D)], // #D39841 to lighter orange
  );

  static const Gradient lightGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryLight, Color(0xFFC8E6F5)], // #A9D4E7 to lighter blue
  );

  // Card Colors
  static const Color cardDark = primaryDark;           // #050040
  static const Color cardAccent = primaryAccent;       // #D39841
  static const Color cardLight = primaryLight;         // #A9D4E7

  // Text Specific Colors
  static const Color textDark = primaryDark;           // #050040
  static const Color textAccent = primaryAccent;       // #D39841
  static const Color textLightBlue = primaryLight;     // #A9D4E7
}