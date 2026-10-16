import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// ThemeGlobal defines the global aesthetics and theme configuration
/// based on the 'ProntoMenu' Light design system.
class ThemeGlobal {
  // ProntoMenu Light Palette (from settings -> temi)
  static const Color primary = Color(0xFF2C5E4F); // Deep Forest Green
  static const Color secondary = Color(0xFFD8CAB7); // Warm Cream / Beige
  static const Color tertiary = Color(0xFFA6343C); // Crimson Wine Red
  static const Color alternate = Color(0xFF333333); // Dark Charcoal
  static const Color primaryBackground = Color(0xFFFFFAF5); // Warm Ivory
  static const Color secondaryBackground = Color(0xFFF1E8DC); // Warm Sand / Card Surface
  static const Color primaryText = Color(0xFF413F3E); // Dark Espresso Text
  static const Color secondaryText = Color(0xFFA59D96); // Warm Muted Gray
  static const Color accent1 = Color(0x322C5E4F); // 20% Primary
  static const Color accent2 = Color(0xFFE0E0E0); // Light Border Gray
  static const Color accent3 = Color(0x34D8CAB7); // 20% Secondary
  static const Color accent4 = Color(0xFF310055); // Deep Plum
  static const Color success = Color(0xFF0B9F74); // Emerald Green
  static const Color error = Color(0xFFF8464C); // Soft Red
  static const Color warning = Color(0xFFFFA926); // Amber Orange
  static const Color info = Color(0xFF4F85E0); // Soft Blue

  // Subtle separator color matching the warm cream palette
  static const Color separatorColor = Color(0xFFE5DCD0);

  /// Builds the global application ThemeData based on the ProntoMenu Light palette.
  static ThemeData buildTheme({Brightness brightness = Brightness.light}) {
    final textTheme = GoogleFonts.outfitTextTheme(
      ThemeData.light().textTheme,
    ).apply(
      bodyColor: primaryText,
      displayColor: primaryText,
    );

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: primaryBackground,
      canvasColor: secondaryBackground,
      cardColor: secondaryBackground,
      dividerColor: separatorColor,
      splashFactory: InkSparkle.splashFactory,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: primary,
        onPrimary: Colors.white,
        secondary: secondary,
        onSecondary: primaryText,
        tertiary: tertiary,
        onTertiary: Colors.white,
        error: error,
        onError: Colors.white,
        surface: secondaryBackground,
        onSurface: primaryText,
        surfaceContainerHighest: Colors.white,
        outline: secondary,
        outlineVariant: separatorColor,
      ),
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      appBarTheme: AppBarTheme(
        elevation: 0.0,
        scrolledUnderElevation: 0.0,
        backgroundColor: primaryBackground.withValues(alpha: 0.95),
        foregroundColor: primaryText,
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.outfit(
          color: primaryText,
          fontSize: 17.0,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.4,
        ),
        iconTheme: const IconThemeData(
          color: primaryText,
          size: 22.0,
        ),
      ),
      cardTheme: CardThemeData(
        color: secondaryBackground,
        elevation: 0.0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
          side: BorderSide(
            color: separatorColor.withValues(alpha: 0.8),
            width: 0.8,
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: primaryBackground,
        elevation: 10.0,
        shadowColor: Colors.black.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        titleTextStyle: GoogleFonts.outfit(
          color: primaryText,
          fontSize: 18.0,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
        ),
        contentTextStyle: GoogleFonts.openSans(
          color: secondaryText,
          fontSize: 14.0,
          height: 1.4,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0.0,
          backgroundColor: primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(88.0, 44.0),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          textStyle: GoogleFonts.outfit(
            fontSize: 15.0,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          elevation: 0.0,
          foregroundColor: primary,
          side: const BorderSide(color: primary, width: 1.0),
          minimumSize: const Size(88.0, 44.0),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          textStyle: GoogleFonts.outfit(
            fontSize: 15.0,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          textStyle: GoogleFonts.outfit(
            fontSize: 15.0,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(
            color: separatorColor,
            width: 0.8,
          ),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12.0)),
          borderSide: BorderSide(
            color: separatorColor,
            width: 0.8,
          ),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12.0)),
          borderSide: BorderSide(
            color: primary,
            width: 1.6,
          ),
        ),
        hintStyle: GoogleFonts.openSans(
          color: secondaryText,
          fontSize: 14.5,
        ),
        labelStyle: GoogleFonts.outfit(
          color: secondaryText,
          fontSize: 14.5,
          fontWeight: FontWeight.w500,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: separatorColor,
        thickness: 0.8,
        space: 1.0,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: primaryBackground,
        elevation: 16.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
        ),
      ),
      scrollbarTheme: ScrollbarThemeData(
        interactive: true,
        thickness: WidgetStateProperty.all(3.0),
        radius: const Radius.circular(8.0),
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.dragged)) {
            return primary.withValues(alpha: 0.8);
          }
          if (states.contains(WidgetState.hovered)) {
            return primary.withValues(alpha: 0.6);
          }
          return primary.withValues(alpha: 0.35);
        }),
      ),
    );
  }
}
