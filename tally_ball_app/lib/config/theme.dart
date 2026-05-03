import 'package:flutter/material.dart';

class TallyThemeExtension extends ThemeExtension<TallyThemeExtension> {
  final Color precisionBlue;
  final Color persistentRed;
  final Color optimisticYellow;

  // Tints (75%, 50%, 25%)
  final Color precisionBlue75;
  final Color precisionBlue50;
  final Color precisionBlue25;
  final Color persistentRed75;
  final Color persistentRed50;
  final Color persistentRed25;
  final Color optimisticYellow75;
  final Color optimisticYellow50;
  final Color optimisticYellow25;
  
  final Color bgPrimary;
  final Color bgSecondary;
  final Color bgCard;
  final Color bgCardLight;
  final Color bgSurface;
  
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  
  final Color border;
  final Color borderBlue;
  final Color borderYellow;
  
  final Color success;
  final Color warning;
  final Color error;
  
  final Color blueGlow;
  final Color redGlow;
  final Color yellowGlow;

  const TallyThemeExtension({
    required this.precisionBlue,
    required this.persistentRed,
    required this.optimisticYellow,
    required this.precisionBlue75,
    required this.precisionBlue50,
    required this.precisionBlue25,
    required this.persistentRed75,
    required this.persistentRed50,
    required this.persistentRed25,
    required this.optimisticYellow75,
    required this.optimisticYellow50,
    required this.optimisticYellow25,
    required this.bgPrimary,
    required this.bgSecondary,
    required this.bgCard,
    required this.bgCardLight,
    required this.bgSurface,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.border,
    required this.borderBlue,
    required this.borderYellow,
    required this.success,
    required this.warning,
    required this.error,
    required this.blueGlow,
    required this.redGlow,
    required this.yellowGlow,
  });

  @override
  ThemeExtension<TallyThemeExtension> copyWith({
    Color? precisionBlue,
    Color? persistentRed,
    Color? optimisticYellow,
    Color? precisionBlue75,
    Color? precisionBlue50,
    Color? precisionBlue25,
    Color? persistentRed75,
    Color? persistentRed50,
    Color? persistentRed25,
    Color? optimisticYellow75,
    Color? optimisticYellow50,
    Color? optimisticYellow25,
    Color? bgPrimary,
    Color? bgSecondary,
    Color? bgCard,
    Color? bgCardLight,
    Color? bgSurface,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? border,
    Color? borderBlue,
    Color? borderYellow,
    Color? success,
    Color? warning,
    Color? error,
    Color? blueGlow,
    Color? redGlow,
    Color? yellowGlow,
  }) {
    return TallyThemeExtension(
      precisionBlue: precisionBlue ?? this.precisionBlue,
      persistentRed: persistentRed ?? this.persistentRed,
      optimisticYellow: optimisticYellow ?? this.optimisticYellow,
      precisionBlue75: precisionBlue75 ?? this.precisionBlue75,
      precisionBlue50: precisionBlue50 ?? this.precisionBlue50,
      precisionBlue25: precisionBlue25 ?? this.precisionBlue25,
      persistentRed75: persistentRed75 ?? this.persistentRed75,
      persistentRed50: persistentRed50 ?? this.persistentRed50,
      persistentRed25: persistentRed25 ?? this.persistentRed25,
      optimisticYellow75: optimisticYellow75 ?? this.optimisticYellow75,
      optimisticYellow50: optimisticYellow50 ?? this.optimisticYellow50,
      optimisticYellow25: optimisticYellow25 ?? this.optimisticYellow25,
      bgPrimary: bgPrimary ?? this.bgPrimary,
      bgSecondary: bgSecondary ?? this.bgSecondary,
      bgCard: bgCard ?? this.bgCard,
      bgCardLight: bgCardLight ?? this.bgCardLight,
      bgSurface: bgSurface ?? this.bgSurface,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      border: border ?? this.border,
      borderBlue: borderBlue ?? this.borderBlue,
      borderYellow: borderYellow ?? this.borderYellow,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      error: error ?? this.error,
      blueGlow: blueGlow ?? this.blueGlow,
      redGlow: redGlow ?? this.redGlow,
      yellowGlow: yellowGlow ?? this.yellowGlow,
    );
  }

  @override
  ThemeExtension<TallyThemeExtension> lerp(ThemeExtension<TallyThemeExtension>? other, double t) {
    if (other is! TallyThemeExtension) return this;
    return TallyThemeExtension(
      precisionBlue: Color.lerp(precisionBlue, other.precisionBlue, t)!,
      persistentRed: Color.lerp(persistentRed, other.persistentRed, t)!,
      optimisticYellow: Color.lerp(optimisticYellow, other.optimisticYellow, t)!,
      precisionBlue75: Color.lerp(precisionBlue75, other.precisionBlue75, t)!,
      precisionBlue50: Color.lerp(precisionBlue50, other.precisionBlue50, t)!,
      precisionBlue25: Color.lerp(precisionBlue25, other.precisionBlue25, t)!,
      persistentRed75: Color.lerp(persistentRed75, other.persistentRed75, t)!,
      persistentRed50: Color.lerp(persistentRed50, other.persistentRed50, t)!,
      persistentRed25: Color.lerp(persistentRed25, other.persistentRed25, t)!,
      optimisticYellow75: Color.lerp(optimisticYellow75, other.optimisticYellow75, t)!,
      optimisticYellow50: Color.lerp(optimisticYellow50, other.optimisticYellow50, t)!,
      optimisticYellow25: Color.lerp(optimisticYellow25, other.optimisticYellow25, t)!,
      bgPrimary: Color.lerp(bgPrimary, other.bgPrimary, t)!,
      bgSecondary: Color.lerp(bgSecondary, other.bgSecondary, t)!,
      bgCard: Color.lerp(bgCard, other.bgCard, t)!,
      bgCardLight: Color.lerp(bgCardLight, other.bgCardLight, t)!,
      bgSurface: Color.lerp(bgSurface, other.bgSurface, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      border: Color.lerp(border, other.border, t)!,
      borderBlue: Color.lerp(borderBlue, other.borderBlue, t)!,
      borderYellow: Color.lerp(borderYellow, other.borderYellow, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      error: Color.lerp(error, other.error, t)!,
      blueGlow: Color.lerp(blueGlow, other.blueGlow, t)!,
      redGlow: Color.lerp(redGlow, other.redGlow, t)!,
      yellowGlow: Color.lerp(yellowGlow, other.yellowGlow, t)!,
    );
  }
}

extension ThemeColorsExt on BuildContext {
  TallyThemeExtension get colors => Theme.of(this).extension<TallyThemeExtension>()!;
}

// Keep TallyColors for backward compatibility initially, 
// but we will gradually replace it with context.colors
class TallyColors {
  TallyColors._();
  static const Color precisionBlue = Color(0xFF0072BA);
  static const Color persistentRed = Color(0xFFC32525);
  static const Color optimisticYellow = Color(0xFFFFD800);
  static const Color bgPrimary = Color(0xFF0A0E14);
  static const Color bgSecondary = Color(0xFF0F1923);
  static const Color bgCard = Color(0xFF141E2B);
  static const Color bgCardLight = Color(0xFF1A2636);
  static const Color bgSurface = Color(0xFF1C2836);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8B949E);
  static const Color textTertiary = Color(0xFF5A6570);
  static const Color border = Color(0xFF2A3545);
  static const Color borderBlue = Color(0xFF0072BA);
  static const Color borderYellow = Color(0xFFFFD800);
  static const Color success = Color(0xFF2ECC71);
  static const Color warning = Color(0xFFE67E22);
  static const Color error = Color(0xFFE74C3C);
}

class TallyTextStyles {
  TallyTextStyles._();

  static TextStyle heading1(BuildContext context) => TextStyle(
    fontFamily: 'AcierBat',
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: context.colors.textPrimary,
    letterSpacing: 2,
  );

  static TextStyle heading2(BuildContext context) => TextStyle(
    fontFamily: 'AcierBat',
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: context.colors.textPrimary,
    letterSpacing: 1.5,
  );

  static TextStyle heading3(BuildContext context) => TextStyle(
    fontFamily: 'AcierBat',
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: context.colors.textPrimary,
    letterSpacing: 1,
  );

  static TextStyle scoreDisplay(BuildContext context) => TextStyle(
    fontFamily: 'AcierBat',
    fontSize: 72,
    fontWeight: FontWeight.w700,
    color: context.colors.textPrimary,
    height: 1.0,
  );

  static TextStyle scoreMedium(BuildContext context) => TextStyle(
    fontFamily: 'AcierBat',
    fontSize: 48,
    fontWeight: FontWeight.w700,
    color: context.colors.textPrimary,
    height: 1.0,
  );

  static TextStyle scriptAccent(BuildContext context) => TextStyle(
    fontFamily: 'Amithen',
    fontSize: 16,
    color: context.colors.optimisticYellow,
    fontStyle: FontStyle.italic,
  );

  static TextStyle bodyLarge(BuildContext context) => TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: context.colors.textPrimary,
  );

  static TextStyle bodyMedium(BuildContext context) => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: context.colors.textSecondary,
  );

  static TextStyle bodySmall(BuildContext context) => TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: context.colors.textTertiary,
  );

  static TextStyle label(BuildContext context) => TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: context.colors.precisionBlue,
    letterSpacing: 2,
  );

  static TextStyle labelYellow(BuildContext context) => TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: context.colors.optimisticYellow,
    letterSpacing: 2,
  );

  static TextStyle button(BuildContext context) => TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: context.colors.textPrimary,
    letterSpacing: 1.5,
  );
  
  // Legacy statics for backward compatibility during transition
  static const TextStyle heading1Legacy = TextStyle(
    fontFamily: 'AcierBat', fontSize: 32, fontWeight: FontWeight.w700, color: Color(0xFFFFFFFF), letterSpacing: 2,
  );
  static const TextStyle heading2Legacy = TextStyle(
    fontFamily: 'AcierBat', fontSize: 24, fontWeight: FontWeight.w700, color: Color(0xFFFFFFFF), letterSpacing: 1.5,
  );
  static const TextStyle heading3Legacy = TextStyle(
    fontFamily: 'AcierBat', fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFFFFFFFF), letterSpacing: 1,
  );
  static const TextStyle bodyLargeLegacy = TextStyle(
    fontSize: 16, fontWeight: FontWeight.w400, color: Color(0xFFFFFFFF),
  );
  static const TextStyle bodyMediumLegacy = TextStyle(
    fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xFF8B949E),
  );
  static const TextStyle bodySmallLegacy = TextStyle(
    fontSize: 12, fontWeight: FontWeight.w400, color: Color(0xFF5A6570),
  );
  static const TextStyle labelLegacy = TextStyle(
    fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF0072BA), letterSpacing: 2,
  );
  static const TextStyle scoreDisplayLegacy = TextStyle(
    fontFamily: 'AcierBat', fontSize: 72, fontWeight: FontWeight.w700, color: Color(0xFFFFFFFF), height: 1.0,
  );
  static const TextStyle scoreMediumLegacy = TextStyle(
    fontFamily: 'AcierBat', fontSize: 48, fontWeight: FontWeight.w700, color: Color(0xFFFFFFFF), height: 1.0,
  );
  static const TextStyle scriptAccentLegacy = TextStyle(
    fontFamily: 'Amithen', fontSize: 16, color: Color(0xFFFFD800), fontStyle: FontStyle.italic,
  );
  static const TextStyle buttonLegacy = TextStyle(
    fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFFFFFFFF), letterSpacing: 1.5,
  );
}

class TallyTheme {
  TallyTheme._();

  static const _darkColors = TallyThemeExtension(
    precisionBlue: Color(0xFF0072BA),
    persistentRed: Color(0xFFC32525),
    optimisticYellow: Color(0xFFFFD800),
    precisionBlue75: Color(0xFF4095CC),
    precisionBlue50: Color(0xFF7FB8DC),
    precisionBlue25: Color(0xFFBFDCEE),
    persistentRed75: Color(0xFFD25B5B),
    persistentRed50: Color(0xFFE19292),
    persistentRed25: Color(0xFFF0C9C9),
    optimisticYellow75: Color(0xFFFFE240),
    optimisticYellow50: Color(0xFFFFEC7F),
    optimisticYellow25: Color(0xFFFFF5BF),
    bgPrimary: Color(0xFF0A0E14),
    bgSecondary: Color(0xFF0F1923),
    bgCard: Color(0xFF141E2B),
    bgCardLight: Color(0xFF1A2636),
    bgSurface: Color(0xFF1C2836),
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xFF8B949E),
    textTertiary: Color(0xFF5A6570),
    border: Color(0xFF2A3545),
    borderBlue: Color(0xFF0072BA),
    borderYellow: Color(0xFFFFD800),
    success: Color(0xFF0072BA),
    warning: Color(0xFFFFD800),
    error: Color(0xFFC32525),
    blueGlow: Color(0x400072BA),
    redGlow: Color(0x40C32525),
    yellowGlow: Color(0x40FFD800),
  );

  static const _lightColors = TallyThemeExtension(
    precisionBlue: Color(0xFF0072BA),
    persistentRed: Color(0xFFC32525),
    optimisticYellow: Color(0xFFFFD800),
    precisionBlue75: Color(0xFF4095CC),
    precisionBlue50: Color(0xFF7FB8DC),
    precisionBlue25: Color(0xFFBFDCEE),
    persistentRed75: Color(0xFFD25B5B),
    persistentRed50: Color(0xFFE19292),
    persistentRed25: Color(0xFFF0C9C9),
    optimisticYellow75: Color(0xFFFFE240),
    optimisticYellow50: Color(0xFFFFEC7F),
    optimisticYellow25: Color(0xFFFFF5BF),
    bgPrimary: Color(0xFFF8FAFC),
    bgSecondary: Color(0xFFF3F4F6),
    bgCard: Color(0xFFFFFFFF),
    bgCardLight: Color(0xFFF9FAFB),
    bgSurface: Color(0xFFFFFFFF),
    textPrimary: Color(0xFF0A0E14),
    textSecondary: Color(0xFF4B5563),
    textTertiary: Color(0xFF9CA3AF),
    border: Color(0xFFE5E7EB),
    borderBlue: Color(0xFF0072BA),
    borderYellow: Color(0xFFFFD800),
    success: Color(0xFF0072BA),
    warning: Color(0xFFFFD800),
    error: Color(0xFFC32525),
    blueGlow: Color(0x330072BA),
    redGlow: Color(0x33C32525),
    yellowGlow: Color(0x33FFD800),
  );

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: _darkColors.bgPrimary,
      primaryColor: _darkColors.precisionBlue,
      extensions: const <ThemeExtension<dynamic>>[
        _darkColors,
      ],
      colorScheme: ColorScheme.dark(
        primary: _darkColors.precisionBlue,
        secondary: _darkColors.optimisticYellow,
        error: _darkColors.persistentRed,
        surface: _darkColors.bgCard,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: _darkColors.bgPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'AcierBat',
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: _darkColors.textPrimary,
          letterSpacing: 2,
        ),
        iconTheme: IconThemeData(color: _darkColors.textPrimary),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: _darkColors.bgPrimary,
        selectedItemColor: _darkColors.precisionBlue,
        unselectedItemColor: _darkColors.textTertiary,
        type: BottomNavigationBarType.fixed,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _darkColors.bgCard,
        hintStyle: TextStyle(color: _darkColors.textTertiary, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _darkColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _darkColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _darkColors.precisionBlue, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _darkColors.precisionBlue,
          foregroundColor: _darkColors.textPrimary,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: _lightColors.bgPrimary,
      primaryColor: _lightColors.precisionBlue,
      extensions: const <ThemeExtension<dynamic>>[
        _lightColors,
      ],
      colorScheme: ColorScheme.light(
        primary: _lightColors.precisionBlue,
        secondary: _lightColors.optimisticYellow,
        error: _lightColors.persistentRed,
        surface: _lightColors.bgCard,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: _lightColors.bgPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'AcierBat',
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: _lightColors.textPrimary,
          letterSpacing: 2,
        ),
        iconTheme: IconThemeData(color: _lightColors.textPrimary),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: _lightColors.bgPrimary,
        selectedItemColor: _lightColors.precisionBlue,
        unselectedItemColor: _lightColors.textTertiary,
        type: BottomNavigationBarType.fixed,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _lightColors.bgCard,
        hintStyle: TextStyle(color: _lightColors.textTertiary, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _lightColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _lightColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _lightColors.precisionBlue, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _lightColors.precisionBlue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
      ),
    );
  }
}
