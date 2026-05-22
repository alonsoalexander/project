import 'package:flutter/material.dart';

// ─── Color Palette ────────────────────────────────────────────────────────────
// Directly maps CSS custom properties from src/styles/theme.css

class AppColors {
  AppColors._();

  // --primary: #2D5A27  (forest green)
  static const Color primary = Color(0xFF2D5A27);
  // --primary-foreground: #F9F9F7
  static const Color primaryForeground = Color(0xFFF9F9F7);
  // --secondary: #D97706  (amber)
  static const Color secondary = Color(0xFFD97706);
  // --accent: #E8F5E6  (light green tint)
  static const Color accent = Color(0xFFE8F5E6);
  // --background: #F9F9F7  (off-white)
  static const Color background = Color(0xFFF9F9F7);
  // --foreground: #2D2D2D
  static const Color foreground = Color(0xFF2D2D2D);
  // --muted: #EEEEE8
  static const Color muted = Color(0xFFEEEEE8);
  // --muted-foreground: #6B6B65
  static const Color mutedForeground = Color(0xFF6B6B65);
  // --border: rgba(45,45,45,0.1)
  static const Color border = Color(0x1A2D2D2D);
  // --destructive: #d4183d
  static const Color destructive = Color(0xFFD4183D);
  // Input background: #ffffff
  static const Color inputBackground = Color(0xFFFFFFFF);
  // Om du inte har dessa definierade:
  static const primaryDark = Color(0xFF0057B8);   // mörkare version av primary

  static const surfaceDark  = Color(0xFFB0B0B0);   // mörkare version av surface

  static const textPrimary  = Color.fromARGB(255, 0, 0, 0);
  // Convenience shades used for cards / surfaces
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF0F0EA);
}

// ─── Typography ───────────────────────────────────────────────────────────────
// Maps base layer font rules from theme.css

class AppTextStyles {
  AppTextStyles._();

  static TextTheme buildTextTheme() {
    // Uses the platform system font (SF Pro on macOS/iOS, Roboto on Android).
    // React project used the same approach via Tailwind's system font stack.
    return const TextTheme(
      // h1 → displayLarge  (~text-2xl, 28px, weight 600)
      displayLarge: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: AppColors.foreground,
        height: 1.2,
      ),
      // h2 → displayMedium (~text-xl, 24px, weight 600)
      displayMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: AppColors.foreground,
        height: 1.3,
      ),
      // h3 → displaySmall (~text-lg, 20px, weight 600)
      displaySmall: TextStyle(
        fontSize: 40,
        fontWeight: FontWeight.w600,
        color: AppColors.foreground,
        height: 1.3,
      ),
      // h4 → headlineMedium (16px, weight 600)
      headlineMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.foreground,
      ),
      // body / p → bodyLarge (16px, weight 500)
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.foreground,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.foreground,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.mutedForeground,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.foreground,
      ),
    );
  }
}

// ─── Border Radius ─────────────────────────────────────────────────────────────
// Maps --radius: 0.625rem (10px) and derived values from theme.css

class AppRadius {
  AppRadius._();

  static const double sm = 6.0;   // calc(--radius - 4px)
  static const double md = 8.0;   // calc(--radius - 2px)
  static const double lg = 10.0;  // --radius
  static const double xl = 14.0;  // calc(--radius + 4px)

  static BorderRadius get small => BorderRadius.circular(sm);
  static BorderRadius get medium => BorderRadius.circular(md);
  static BorderRadius get large => BorderRadius.circular(lg);
  static BorderRadius get extraLarge => BorderRadius.circular(xl);
}

// ─── Spacing ───────────────────────────────────────────────────────────────────
// Mirrors Tailwind's 4px base unit scale

class AppSpacing {
  AppSpacing._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  static const double xxxl = 48.0;
}

// ─── ThemeData ─────────────────────────────────────────────────────────────────

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final textTheme = AppTextStyles.buildTextTheme();

    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.primary,
        onPrimary: AppColors.primaryForeground,
        secondary: AppColors.secondary,
        onSecondary: AppColors.primaryForeground,
        error: AppColors.destructive,
        onError: AppColors.primaryForeground,
        surface: AppColors.surface,
        onSurface: AppColors.foreground,
        surfaceContainerHighest: AppColors.muted,
        outline: AppColors.border,
      ),
      scaffoldBackgroundColor: AppColors.background,
      textTheme: textTheme,

      // ── AppBar (maps to Root.tsx sticky header) ──
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.foreground,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: AppColors.border,
        titleTextStyle: textTheme.headlineMedium,
        iconTheme: const IconThemeData(color: AppColors.foreground),
      ),

      // ── ElevatedButton (maps to Button variant="default") ──
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.primaryForeground,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.medium,
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),

      // ── OutlinedButton (maps to Button variant="outline") ──
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.foreground,
          side: const BorderSide(color: AppColors.border),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.medium,
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),

      // ── TextButton (maps to Button variant="ghost" / "link") ──
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.foreground,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),

      // ── InputDecoration (maps to <Input> shadcn component) ──
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inputBackground,
        border: OutlineInputBorder(
          borderRadius: AppRadius.medium,
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.medium,
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.medium,
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.medium,
          borderSide: const BorderSide(color: AppColors.destructive),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: AppColors.mutedForeground,
        ),
      ),

      // ── Card (maps to <Card> shadcn component) ──
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.large,
          side: const BorderSide(color: AppColors.border),
        ),
        margin: EdgeInsets.zero,
      ),

      // ── Divider ──
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 0,
      ),

      // ── Chip / Badge ──
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.muted,
        labelStyle: textTheme.bodySmall,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.extraLarge,
        ),
        side: BorderSide.none,
      ),
    );
  }
}
