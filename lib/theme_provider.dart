import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Supported restaurant design presets for the application.
enum AppDesignStyle {
  premium,
  pub,
  minimal,
  tradizionale,
}

extension AppDesignStyleExtension on AppDesignStyle {
  String get displayName => switch (this) {
        AppDesignStyle.premium => 'Premium',
        AppDesignStyle.pub => 'Pub',
        AppDesignStyle.minimal => 'Minimal',
        AppDesignStyle.tradizionale => 'Tradizionale',
      };

  String get targetAudience => switch (this) {
        AppDesignStyle.premium => 'Ristoranti di lusso e fine dining',
        AppDesignStyle.pub => 'Pub, birrerie e burger house',
        AppDesignStyle.minimal => 'Sushi bar e cucina gourmet',
        AppDesignStyle.tradizionale => 'Pizzerie e trattorie tipiche',
      };

  String get description => switch (this) {
        AppDesignStyle.premium =>
          'Oro e toni scuri, bordi netti ed eleganti, font serif raffinato e ombre sottili.',
        AppDesignStyle.pub =>
          'Colori caldi ambrati, bordi molto arrotondati, icone spesse e atmosfera accogliente.',
        AppDesignStyle.minimal =>
          'Essenziale e zen, tanto respiro, accenti desaturati, angoli retti e font geometrico.',
        AppDesignStyle.tradizionale =>
          'Rosso mattone classico, forme familiari e accoglienti, tipografia classica altamente leggibile.',
      };

  Color get defaultPrimaryColor => switch (this) {
        AppDesignStyle.premium => const Color(0xFFC5A059),
        AppDesignStyle.pub => const Color(0xFFD97706),
        AppDesignStyle.minimal => const Color(0xFF334155),
        AppDesignStyle.tradizionale => const Color(0xFFB71C1C),
      };

  IconData get defaultIcon => switch (this) {
        AppDesignStyle.premium => Icons.wine_bar_rounded,
        AppDesignStyle.pub => Icons.sports_bar_rounded,
        AppDesignStyle.minimal => Icons.ramen_dining_rounded,
        AppDesignStyle.tradizionale => Icons.local_pizza_rounded,
      };

  String get defaultTitleFont => switch (this) {
        AppDesignStyle.premium => 'Playfair Display',
        AppDesignStyle.pub => 'Rubik',
        AppDesignStyle.minimal => 'Space Grotesk',
        AppDesignStyle.tradizionale => 'Lora',
      };

  String get defaultBodyFont => switch (this) {
        AppDesignStyle.premium => 'Plus Jakarta Sans',
        AppDesignStyle.pub => 'Nunito',
        AppDesignStyle.minimal => 'Inter',
        AppDesignStyle.tradizionale => 'Lora',
      };
}

/// Provider to manage application design preset, typography (title & body fonts),
/// and theme mode (light/dark), with automatic persistence via [SharedPreferences].
class ThemeProvider extends ChangeNotifier {
  static const String _keyDesignStyle = 'app_design_style';
  static const String _keyThemeMode = 'app_theme_mode';
  static const String _keyTitleFont = 'app_title_font';
  static const String _keyBodyFont = 'app_body_font';
  static const String _kFFThemeModeKey = '__theme_mode__';

  AppDesignStyle _designStyle = AppDesignStyle.premium;
  Color _primaryColor = AppDesignStyle.premium.defaultPrimaryColor;
  ThemeMode _themeMode = ThemeMode.light;
  String _titleFont = AppDesignStyle.premium.defaultTitleFont;
  String _bodyFont = AppDesignStyle.premium.defaultBodyFont;
  bool _isLoaded = false;

  AppDesignStyle get designStyle => _designStyle;
  Color get primaryColor => _primaryColor;
  ThemeMode get themeMode => _themeMode;
  String get titleFont => _titleFont;
  String get bodyFont => _bodyFont;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  bool get isLoaded => _isLoaded;

  ThemeProvider({
    AppDesignStyle initialDesignStyle = AppDesignStyle.premium,
    ThemeMode initialThemeMode = ThemeMode.light,
  })  : _designStyle = initialDesignStyle,
        _primaryColor = initialDesignStyle.defaultPrimaryColor,
        _themeMode = initialThemeMode,
        _titleFont = initialDesignStyle.defaultTitleFont,
        _bodyFont = initialDesignStyle.defaultBodyFont {
    loadFromPreferences();
  }

  /// Loads persisted settings from [SharedPreferences].
  Future<void> loadFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    final savedStyleName = prefs.getString(_keyDesignStyle);
    if (savedStyleName != null) {
      for (final style in AppDesignStyle.values) {
        if (style.name == savedStyleName) {
          _designStyle = style;
          break;
        }
      }
    }

    _primaryColor = _designStyle.defaultPrimaryColor;

    // Load fonts
    final savedTitleFont = prefs.getString(_keyTitleFont);
    _titleFont = savedTitleFont ?? _designStyle.defaultTitleFont;

    final savedBodyFont = prefs.getString(_keyBodyFont);
    _bodyFont = savedBodyFont ?? _designStyle.defaultBodyFont;

    // Load ThemeMode
    final savedMode = prefs.getString(_keyThemeMode);
    if (savedMode != null) {
      if (savedMode == ThemeMode.dark.name) {
        _themeMode = ThemeMode.dark;
      } else if (savedMode == ThemeMode.light.name) {
        _themeMode = ThemeMode.light;
      } else {
        _themeMode = ThemeMode.system;
      }
    } else {
      final legacyDark = prefs.getBool(_kFFThemeModeKey);
      if (legacyDark != null) {
        _themeMode = legacyDark ? ThemeMode.dark : ThemeMode.light;
      } else {
        _themeMode = ThemeMode.light;
      }
    }

    _isLoaded = true;
    notifyListeners();
  }

  /// Updates the design preset: simultaneously updates style, primaryColor, and default fonts.
  Future<void> setDesignStyle(AppDesignStyle style) async {
    _designStyle = style;
    _primaryColor = style.defaultPrimaryColor;
    _titleFont = style.defaultTitleFont;
    _bodyFont = style.defaultBodyFont;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyDesignStyle, style.name);
    await prefs.setString(_keyTitleFont, _titleFont);
    await prefs.setString(_keyBodyFont, _bodyFont);
  }

  /// Setter alias for [setDesignStyle].
  set designStyle(AppDesignStyle style) {
    setDesignStyle(style);
  }

  /// Sets custom title font (used for dish names, prices, titles, CTA buttons).
  Future<void> setTitleFont(String font) async {
    if (_titleFont == font) return;
    _titleFont = font;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyTitleFont, font);
  }

  /// Sets custom body font (used for dish descriptions, ingredients, details).
  Future<void> setBodyFont(String font) async {
    if (_bodyFont == font) return;
    _bodyFont = font;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyBodyFont, font);
  }

  /// Resets title and body fonts to the current preset's defaults.
  Future<void> resetFontsToPreset() async {
    _titleFont = _designStyle.defaultTitleFont;
    _bodyFont = _designStyle.defaultBodyFont;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyTitleFont, _titleFont);
    await prefs.setString(_keyBodyFont, _bodyFont);
  }

  /// Legacy helper for color changes: preserves preset integrity.
  Future<void> setPrimaryColor(Color color) async {
    _primaryColor = color;
    notifyListeners();
  }

  /// Updates the theme mode (light, dark, system) and persists the preference.
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyThemeMode, mode.name);
    if (mode == ThemeMode.system) {
      await prefs.remove(_kFFThemeModeKey);
    } else {
      await prefs.setBool(_kFFThemeModeKey, mode == ThemeMode.dark);
    }
  }

  /// Toggles between light and dark mode.
  Future<void> toggleThemeMode() async {
    final newMode =
        _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await setThemeMode(newMode);
  }
}
