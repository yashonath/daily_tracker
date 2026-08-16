import 'package:flutter/material.dart';

@immutable
class AppTheme {

  // Colors
  static const Color blue = Color(0xFF2563EB);
  static const Color blueLight = Color(0xFFEFF6FF);
  static const Color green = Color(0xFF16A34A);
  static const Color greenLight = Color(0xFFF0FDF4);
  static const Color red = Color(0xFFDC2626);
  static const Color redLight = Color(0xFFFEF2F2);
  static const Color amber = Color(0xFFD97706);
  static const Color amberLight = Color(0xFFFFFBEB);
  static const Color teal = Color(0xFF1D9E75);
  static const Color tealLight = Color(0xFFF0FBF6);

  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFFAFAF9),
      colorScheme: ColorScheme.fromSeed(
        seedColor: blue,
        brightness: Brightness.light,
        surface: Colors.white,
      ),
      fontFamily: 'SF Pro Display',
      cardTheme: const CardThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),


      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFFAFAF9),
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          color: Color(0xFF111110),
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        iconTheme: IconThemeData(color: Color(0xFF111110)),
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: Color(0xFF111110),


        unselectedLabelColor: Color(0xFFB0AFA8),
        indicatorColor: Color(0xFF111110),
        labelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        unselectedLabelStyle: TextStyle(fontSize: 12),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF4F4F2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: const BorderSide(color: Color(0x22000000)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: const BorderSide(color: Color(0x22000000)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: const BorderSide(color: blue, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      extensions: const [AppColors.light],
    );
  }

  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF111110),
      colorScheme: ColorScheme.fromSeed(
        seedColor: blue,
        brightness: Brightness.dark,
        surface: const Color(0xFF1A1A19),
      ),
      fontFamily: 'SF Pro Display',
      cardTheme: const CardThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),


      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF111110),
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          color: Color(0xFFEEEDE8),
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        iconTheme: IconThemeData(color: Color(0xFFEEEDE8)),
      ),
      tabBarTheme: const TabBarThemeData(

        labelColor: Color(0xFFEEEDE8),
        unselectedLabelColor: Color(0xFF4A4A46),
        indicatorColor: Color(0xFFEEEDE8),
        labelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        unselectedLabelStyle: TextStyle(fontSize: 12),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF232321),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: const BorderSide(color: Color(0x22FFFFFF)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: const BorderSide(color: Color(0x22FFFFFF)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: const BorderSide(color: blue, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      extensions: const [AppColors.dark],
    );
  }
}

@immutable
class AppColors extends ThemeExtension<AppColors> {
  final Color surface2;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color border;
  final Color border2;

  const AppColors({
    required this.surface2,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.border,
    required this.border2,
  });

  static const light = AppColors(
    surface2: Color(0xFFF4F4F2),
    textPrimary: Color(0xFF111110),
    textSecondary: Color(0xFF78776E),
    textTertiary: Color(0xFFB0AFA8),
    border: Color(0x12000000),
    border2: Color(0x22000000),
  );

  static const dark = AppColors(
    surface2: Color(0xFF232321),
    textPrimary: Color(0xFFEEEDE8),
    textSecondary: Color(0xFF78776E),
    textTertiary: Color(0xFF4A4A46),
    border: Color(0x12FFFFFF),
    border2: Color(0x22FFFFFF),
  );

  @override
  AppColors copyWith({Color? surface2, Color? textPrimary, Color? textSecondary, Color? textTertiary, Color? border, Color? border2}) {
    return AppColors(
      surface2: surface2 ?? this.surface2,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      border: border ?? this.border,
      border2: border2 ?? this.border2,
    );
  }

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      surface2: Color.lerp(surface2, other.surface2, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      border: Color.lerp(border, other.border, t)!,
      border2: Color.lerp(border2, other.border2, t)!,
    );
  }
}
