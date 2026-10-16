import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme_provider.dart';

// ──────────────────────────────────────────────────────────────────────────────
// AppCustomTheme — ThemeExtension con parametri grafici per i 4 preset ristorazione
// ──────────────────────────────────────────────────────────────────────────────

class AppCustomTheme extends ThemeExtension<AppCustomTheme> {
  /// Icona simbolo del preset (es. wine bar per Premium, birra per Pub, ecc.).
  final IconData defaultIcon;

  /// Velocità delle animazioni adatta al mood del locale.
  final Duration animationSpeed;

  /// Stile tipografico del titolo, specifico per ogni tema.
  final TextStyle customTitleStyle;

  /// Colore accent secondario decorativo.
  final Color accentColor;

  /// Raggio dei bordi caratteristico dello stile.
  final double borderRadius;

  /// Tag testuale leggibile mostrato nella UI.
  final String styleTag;

  /// Font family del titolo principale (nomi dei piatti e prezzi).
  final String fontFamily;

  /// Font family del corpo del testo (descrizioni e ingredienti).
  final String bodyFontFamily;

  const AppCustomTheme({
    required this.defaultIcon,
    required this.animationSpeed,
    required this.customTitleStyle,
    required this.accentColor,
    required this.borderRadius,
    required this.styleTag,
    required this.fontFamily,
    required this.bodyFontFamily,
  });

  @override
  AppCustomTheme copyWith({
    IconData? defaultIcon,
    Duration? animationSpeed,
    TextStyle? customTitleStyle,
    Color? accentColor,
    double? borderRadius,
    String? styleTag,
    String? fontFamily,
    String? bodyFontFamily,
  }) {
    return AppCustomTheme(
      defaultIcon: defaultIcon ?? this.defaultIcon,
      animationSpeed: animationSpeed ?? this.animationSpeed,
      customTitleStyle: customTitleStyle ?? this.customTitleStyle,
      accentColor: accentColor ?? this.accentColor,
      borderRadius: borderRadius ?? this.borderRadius,
      styleTag: styleTag ?? this.styleTag,
      fontFamily: fontFamily ?? this.fontFamily,
      bodyFontFamily: bodyFontFamily ?? this.bodyFontFamily,
    );
  }

  @override
  AppCustomTheme lerp(ThemeExtension<AppCustomTheme>? other, double t) {
    if (other is! AppCustomTheme) return this;
    return AppCustomTheme(
      defaultIcon: t < 0.5 ? defaultIcon : other.defaultIcon,
      animationSpeed: Duration(
        microseconds: (animationSpeed.inMicroseconds +
                (other.animationSpeed.inMicroseconds -
                        animationSpeed.inMicroseconds) *
                    t)
            .round(),
      ),
      customTitleStyle:
          TextStyle.lerp(customTitleStyle, other.customTitleStyle, t) ??
              customTitleStyle,
      accentColor: Color.lerp(accentColor, other.accentColor, t) ?? accentColor,
      borderRadius: borderRadius + (other.borderRadius - borderRadius) * t,
      styleTag: t < 0.5 ? styleTag : other.styleTag,
      fontFamily: t < 0.5 ? fontFamily : other.fontFamily,
      bodyFontFamily: t < 0.5 ? bodyFontFamily : other.bodyFontFamily,
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Helper extensions
// ──────────────────────────────────────────────────────────────────────────────

extension AppCustomThemeGetter on ThemeData {
  AppCustomTheme? get appCustomTheme => extension<AppCustomTheme>();
}

extension AppCustomThemeContext on BuildContext {
  AppCustomTheme? get appCustomTheme =>
      Theme.of(this).extension<AppCustomTheme>();
}

// ──────────────────────────────────────────────────────────────────────────────
// AppThemes — Generatore centralizzato con supporto Font Titoli e Body dinamici
// ──────────────────────────────────────────────────────────────────────────────

class AppThemes {
  /// Genera il ThemeData per il preset e i font richiesti rispettando rigorosamente
  /// il parametro [brightness] (light/dark) e calcolando il contrasto dinamico.
  static ThemeData buildTheme({
    required AppDesignStyle designStyle,
    Color? primaryColor,
    Brightness brightness = Brightness.light,
    String? titleFont,
    String? bodyFont,
  }) {
    final effectiveColor = primaryColor ?? designStyle.defaultPrimaryColor;
    final effectiveTitleFont = titleFont ?? designStyle.defaultTitleFont;
    final effectiveBodyFont = bodyFont ?? designStyle.defaultBodyFont;

    switch (designStyle) {
      case AppDesignStyle.premium:
        return _buildPresetTheme(
          seedColor: effectiveColor,
          brightness: brightness,
          titleFont: effectiveTitleFont,
          bodyFont: effectiveBodyFont,
          borderRadius: 6.0,
          elevation: 1.0,
          defaultIcon: Icons.wine_bar_rounded,
          animationSpeed: const Duration(milliseconds: 450),
          styleTag: 'FINE DINING',
        );
      case AppDesignStyle.pub:
        return _buildPresetTheme(
          seedColor: effectiveColor,
          brightness: brightness,
          titleFont: effectiveTitleFont,
          bodyFont: effectiveBodyFont,
          borderRadius: 22.0,
          elevation: 3.0,
          defaultIcon: Icons.sports_bar_rounded,
          animationSpeed: const Duration(milliseconds: 280),
          styleTag: 'CRAFT PUB',
        );
      case AppDesignStyle.minimal:
        return _buildPresetTheme(
          seedColor: effectiveColor,
          brightness: brightness,
          titleFont: effectiveTitleFont,
          bodyFont: effectiveBodyFont,
          borderRadius: 0.0,
          elevation: 0.0,
          defaultIcon: Icons.ramen_dining_rounded,
          animationSpeed: const Duration(milliseconds: 150),
          styleTag: 'ZEN GOURMET',
        );
      case AppDesignStyle.tradizionale:
        return _buildPresetTheme(
          seedColor: effectiveColor,
          brightness: brightness,
          titleFont: effectiveTitleFont,
          bodyFont: effectiveBodyFont,
          borderRadius: 12.0,
          elevation: 2.0,
          defaultIcon: Icons.local_pizza_rounded,
          animationSpeed: const Duration(milliseconds: 320),
          styleTag: 'TRATTORIA',
        );
    }
  }

  static ThemeData _buildPresetTheme({
    required Color seedColor,
    required Brightness brightness,
    required String titleFont,
    required String bodyFont,
    required double borderRadius,
    required double elevation,
    required IconData defaultIcon,
    required Duration animationSpeed,
    required String styleTag,
  }) {
    // 1. ColorScheme dinamico basato sul seed e la luminosità
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: brightness,
    ).copyWith(
      primary: seedColor,
    );

    // 2. Base text theme allineato alla luminosità
    final baseTextTheme = brightness == Brightness.dark
        ? ThemeData.dark().textTheme
        : ThemeData.light().textTheme;

    // 3. Tipografia dinamica differenziata per Titoli (piatti e prezzi) e Body (descrizioni)
    final titleTextTheme = GoogleFonts.getTextTheme(titleFont, baseTextTheme);
    final bodyTextTheme = GoogleFonts.getTextTheme(bodyFont, baseTextTheme);

    final textTheme = baseTextTheme.copyWith(
      displayLarge:
          titleTextTheme.displayLarge?.copyWith(color: colorScheme.onSurface),
      displayMedium:
          titleTextTheme.displayMedium?.copyWith(color: colorScheme.onSurface),
      displaySmall:
          titleTextTheme.displaySmall?.copyWith(color: colorScheme.onSurface),
      headlineLarge: titleTextTheme.headlineLarge?.copyWith(
          color: colorScheme.onSurface, fontWeight: FontWeight.w700),
      headlineMedium: titleTextTheme.headlineMedium?.copyWith(
          color: colorScheme.onSurface, fontWeight: FontWeight.w700),
      headlineSmall: titleTextTheme.headlineSmall?.copyWith(
          color: colorScheme.onSurface, fontWeight: FontWeight.w600),
      titleLarge: titleTextTheme.titleLarge?.copyWith(
          color: colorScheme.onSurface, fontWeight: FontWeight.w700),
      titleMedium: titleTextTheme.titleMedium?.copyWith(
          color: colorScheme.onSurface, fontWeight: FontWeight.w600),
      titleSmall: titleTextTheme.titleSmall?.copyWith(
          color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.w500),
      bodyLarge: bodyTextTheme.bodyLarge
          ?.copyWith(color: colorScheme.onSurface, height: 1.5),
      bodyMedium: bodyTextTheme.bodyMedium
          ?.copyWith(color: colorScheme.onSurfaceVariant, height: 1.45),
      bodySmall: bodyTextTheme.bodySmall
          ?.copyWith(color: colorScheme.onSurfaceVariant),
      labelLarge: titleTextTheme.labelLarge?.copyWith(
          color: colorScheme.primary, fontWeight: FontWeight.w700),
      labelMedium: bodyTextTheme.labelMedium
          ?.copyWith(color: colorScheme.onSurfaceVariant),
      labelSmall: bodyTextTheme.labelSmall
          ?.copyWith(color: colorScheme.onSurfaceVariant),
    );

    // 4. Estensione custom per il tema
    final customTheme = AppCustomTheme(
      defaultIcon: defaultIcon,
      animationSpeed: animationSpeed,
      customTitleStyle: GoogleFonts.getFont(
        titleFont,
        textStyle: TextStyle(
          fontSize: 20.0,
          fontWeight: FontWeight.w700,
          color: colorScheme.onSurface,
        ),
      ),
      accentColor: colorScheme.primary,
      borderRadius: borderRadius,
      styleTag: styleTag,
      fontFamily: titleFont,
      bodyFontFamily: bodyFont,
    );

    final isFlat = elevation == 0.0;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surfaceContainerLowest,
      canvasColor: colorScheme.surfaceContainerLowest,
      cardColor: colorScheme.surface,
      dividerColor: colorScheme.outlineVariant.withValues(alpha: 0.5),
      textTheme: textTheme,
      extensions: [customTheme],
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: colorScheme.onSurface,
        ),
        iconTheme: IconThemeData(
          color: colorScheme.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surface,
        elevation: elevation,
        shadowColor: isFlat
            ? Colors.transparent
            : colorScheme.shadow.withValues(
                alpha: brightness == Brightness.dark ? 0.35 : 0.08,
              ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          side: BorderSide.none,
        ),
        margin: EdgeInsets.zero,
      ),
      listTileTheme: ListTileThemeData(
        textColor: colorScheme.onSurface,
        iconColor: colorScheme.onSurfaceVariant,
        tileColor: colorScheme.surface,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: elevation,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          textStyle: TextStyle(
            fontFamily: GoogleFonts.getFont(titleFont).fontFamily,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
