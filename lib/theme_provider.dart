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

/// Layout styles for dish cards in the menu.
enum DishCardLayout {
  classico,
  fotoGrande,
  griglia,
  minimale,
}

extension DishCardLayoutExtension on DishCardLayout {
  String get name => switch (this) {
        DishCardLayout.classico => 'classico',
        DishCardLayout.fotoGrande => 'foto_grande',
        DishCardLayout.griglia => 'griglia',
        DishCardLayout.minimale => 'minimale',
      };

  String get displayName => switch (this) {
        DishCardLayout.classico => 'Classico Orizzontale',
        DishCardLayout.fotoGrande => 'Foto in Evidenza',
        DishCardLayout.griglia => 'Griglia Compatta (2 Col.)',
        DishCardLayout.minimale => 'Lista Minimale',
      };

  String get description => switch (this) {
        DishCardLayout.classico =>
          'Foto a sinistra e dettagli a destra. Il layout più amato e versatile.',
        DishCardLayout.fotoGrande =>
          'Immagine grande in alto. Esalta al massimo l\'estetica dei piatti gourmet e burger.',
        DishCardLayout.griglia =>
          'Due colonne compatte con foto sopra. Ideale per consultare molti piatti a colpo d\'occhio.',
        DishCardLayout.minimale =>
          'Senza foto invasive, massima eleganza tipografica. Ideale per pizzerie ed enoteche.',
      };

  IconData get icon => switch (this) {
        DishCardLayout.classico => Icons.view_stream_rounded,
        DishCardLayout.fotoGrande => Icons.photo_size_select_actual_rounded,
        DishCardLayout.griglia => Icons.grid_view_rounded,
        DishCardLayout.minimale => Icons.view_headline_rounded,
      };

  static DishCardLayout fromString(String? val) {
    return switch (val) {
      'foto_grande' || 'fotoGrande' => DishCardLayout.fotoGrande,
      'griglia' => DishCardLayout.griglia,
      'minimale' => DishCardLayout.minimale,
      _ => DishCardLayout.classico,
    };
  }
}

/// Supported background textures and patterns for the restaurant menu.
enum BackgroundTexture {
  nessuna,
  pergamena,
  legno,
  ardesia,
  tessuto,
  geometrico,
}

extension BackgroundTextureExtension on BackgroundTexture {
  String get name => switch (this) {
        BackgroundTexture.nessuna => 'nessuna',
        BackgroundTexture.pergamena => 'pergamena',
        BackgroundTexture.legno => 'legno',
        BackgroundTexture.ardesia => 'ardesia',
        BackgroundTexture.tessuto => 'tessuto',
        BackgroundTexture.geometrico => 'geometrico',
      };

  String get displayName => switch (this) {
        BackgroundTexture.nessuna => 'Nessuna (Tinta unita)',
        BackgroundTexture.pergamena => 'Carta Pergamena',
        BackgroundTexture.legno => 'Legno Bistrot',
        BackgroundTexture.ardesia => 'Ardesia Minerale',
        BackgroundTexture.tessuto => 'Lino & Tovagliato',
        BackgroundTexture.geometrico => 'Texture Geometrica',
      };

  String get description => switch (this) {
        BackgroundTexture.nessuna => 'Sfondo moderno, pulito e minimale a tinta unita.',
        BackgroundTexture.pergamena => 'Tonalità calda avorio con grana carta da forno artigianale.',
        BackgroundTexture.legno => 'Essenza calda rustica tipo tavolo bistrot o bancone pub.',
        BackgroundTexture.ardesia => 'Pietra scura zen ad alto contrasto per sushi e carne.',
        BackgroundTexture.tessuto => 'Trama delicata di lino naturale per ristoranti eleganti.',
        BackgroundTexture.geometrico => 'Pattern contemporaneo sottile e raffinato.',
      };

  IconData get icon => switch (this) {
        BackgroundTexture.nessuna => Icons.circle_outlined,
        BackgroundTexture.pergamena => Icons.description_outlined,
        BackgroundTexture.legno => Icons.deck_rounded,
        BackgroundTexture.ardesia => Icons.layers_rounded,
        BackgroundTexture.tessuto => Icons.texture_rounded,
        BackgroundTexture.geometrico => Icons.grain_rounded,
      };

  static BackgroundTexture fromString(String? val) {
    return switch (val) {
      'pergamena' => BackgroundTexture.pergamena,
      'legno' => BackgroundTexture.legno,
      'ardesia' => BackgroundTexture.ardesia,
      'tessuto' => BackgroundTexture.tessuto,
      'geometrico' => BackgroundTexture.geometrico,
      _ => BackgroundTexture.nessuna,
    };
  }
}

/// Stili di visualizzazione dei badge (prezzo, allergeni, tags) nel menù cliente
enum BadgeStyle {
  pillola,
  modernoSoft,
  minimalOutline,
  boldTag,
}

extension BadgeStyleExtension on BadgeStyle {
  String get value => switch (this) {
        BadgeStyle.pillola => 'pillola',
        BadgeStyle.modernoSoft => 'moderno_soft',
        BadgeStyle.minimalOutline => 'minimal_outline',
        BadgeStyle.boldTag => 'bold_tag',
      };

  String get displayName => switch (this) {
        BadgeStyle.pillola => 'Capsula / Pillola',
        BadgeStyle.modernoSoft => 'Moderno Soft',
        BadgeStyle.minimalOutline => 'Minimal Outline',
        BadgeStyle.boldTag => 'Bold Tag Solido',
      };

  String get description => switch (this) {
        BadgeStyle.pillola => 'Bordi arrotondati classici, morbidi e universali.',
        BadgeStyle.modernoSoft => 'Angoli smussati (r6) con sfondo tenue e bordo sottile, raffinato.',
        BadgeStyle.minimalOutline => 'Solo contorno fine a contrasto senza riempimento, sobrio.',
        BadgeStyle.boldTag => 'Sfondo pieno ad alto contrasto con angoli decisi e icona.',
      };

  IconData get icon => switch (this) {
        BadgeStyle.pillola => Icons.label_rounded,
        BadgeStyle.modernoSoft => Icons.crop_square_rounded,
        BadgeStyle.minimalOutline => Icons.check_box_outline_blank_rounded,
        BadgeStyle.boldTag => Icons.local_offer_rounded,
      };

  static BadgeStyle fromString(String? val) {
    return switch (val) {
      'moderno_soft' => BadgeStyle.modernoSoft,
      'minimal_outline' => BadgeStyle.minimalOutline,
      'bold_tag' => BadgeStyle.boldTag,
      _ => BadgeStyle.pillola,
    };
  }
}

/// Provider to manage application design preset, typography (title & body fonts),
/// and theme mode (light/dark), with automatic persistence via [SharedPreferences].
class ThemeProvider extends ChangeNotifier {
  static const String _keyDesignStyle = 'app_design_style';
  static const String _keyThemeMode = 'app_theme_mode';
  static const String _keyTitleFont = 'app_title_font';
  static const String _keyBodyFont = 'app_body_font';
  static const String _keyPrimaryColor = 'app_primary_color';
  static const String _keyDishCardLayout = 'app_dish_card_layout';
  static const String _keyCoverBanner = 'app_cover_banner';
  static const String _keyBackgroundTexture = 'app_background_texture';
  static const String _keyBadgeStyle = 'app_badge_style';
  static const String _kFFThemeModeKey = '__theme_mode__';

  AppDesignStyle _designStyle = AppDesignStyle.premium;
  Color _primaryColor = AppDesignStyle.premium.defaultPrimaryColor;
  ThemeMode _themeMode = ThemeMode.light;
  String _titleFont = AppDesignStyle.premium.defaultTitleFont;
  String _bodyFont = AppDesignStyle.premium.defaultBodyFont;
  DishCardLayout _dishCardLayout = DishCardLayout.classico;
  String _coverBanner = '';
  BackgroundTexture _backgroundTexture = BackgroundTexture.nessuna;
  BadgeStyle _badgeStyle = BadgeStyle.pillola;
  bool _isLoaded = false;

  AppDesignStyle get designStyle => _designStyle;
  Color get primaryColor => _primaryColor;
  String get primaryColorHex =>
      '#${_primaryColor.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
  ThemeMode get themeMode => _themeMode;
  String get titleFont => _titleFont;
  String get bodyFont => _bodyFont;
  DishCardLayout get dishCardLayout => _dishCardLayout;
  String get coverBanner => _coverBanner;
  BackgroundTexture get backgroundTexture => _backgroundTexture;
  BadgeStyle get badgeStyle => _badgeStyle;
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

    final savedPrimaryColorHex = prefs.getString(_keyPrimaryColor);
    if (savedPrimaryColorHex != null && savedPrimaryColorHex.isNotEmpty) {
      try {
        final clean = savedPrimaryColorHex.replaceAll('#', '');
        if (clean.length == 6) {
          _primaryColor = Color(int.parse('FF$clean', radix: 16));
        } else if (clean.length == 8) {
          _primaryColor = Color(int.parse(clean, radix: 16));
        }
      } catch (_) {
        _primaryColor = _designStyle.defaultPrimaryColor;
      }
    } else {
      _primaryColor = _designStyle.defaultPrimaryColor;
    }

    // Load fonts
    final savedTitleFont = prefs.getString(_keyTitleFont);
    _titleFont = savedTitleFont ?? _designStyle.defaultTitleFont;

    final savedBodyFont = prefs.getString(_keyBodyFont);
    _bodyFont = savedBodyFont ?? _designStyle.defaultBodyFont;

    final savedLayout = prefs.getString(_keyDishCardLayout);
    _dishCardLayout = DishCardLayoutExtension.fromString(savedLayout);

    final savedBanner = prefs.getString(_keyCoverBanner);
    _coverBanner = savedBanner ?? '';

    final savedTexture = prefs.getString(_keyBackgroundTexture);
    _backgroundTexture = BackgroundTextureExtension.fromString(savedTexture);

    final savedBadge = prefs.getString(_keyBadgeStyle);
    _badgeStyle = BadgeStyleExtension.fromString(savedBadge);

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
    final hex = '#${_primaryColor.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
    await prefs.setString(_keyPrimaryColor, hex);
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

  /// Updates the primary accent color and persists it.
  Future<void> setPrimaryColor(Color color) async {
    _primaryColor = color;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final hex = '#${color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
    await prefs.setString(_keyPrimaryColor, hex);
  }

  /// Sets the dish card layout style ('classico', 'foto_grande', 'griglia', 'minimale').
  Future<void> setDishCardLayout(DishCardLayout layout) async {
    if (_dishCardLayout == layout) return;
    _dishCardLayout = layout;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyDishCardLayout, layout.name);
  }

  /// Sets the restaurant cover banner (preset ID or image URL).
  Future<void> setCoverBanner(String bannerUrl) async {
    if (_coverBanner == bannerUrl) return;
    _coverBanner = bannerUrl;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyCoverBanner, bannerUrl);
  }

  /// Sets the background texture/pattern for the menu.
  Future<void> setBackgroundTexture(BackgroundTexture texture) async {
    if (_backgroundTexture == texture) return;
    _backgroundTexture = texture;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyBackgroundTexture, texture.name);
  }

  /// Sets the badge style for prices, allergens, and tags ('pillola', 'moderno_soft', 'minimal_outline', 'bold_tag').
  Future<void> setBadgeStyle(BadgeStyle style) async {
    if (_badgeStyle == style) return;
    _badgeStyle = style;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyBadgeStyle, style.value);
  }

  /// Syncs all customization properties from a restaurant profile (e.g. from Firestore).
  Future<void> syncFromRestaurant({
    String? temaScelto,
    String? colorePrimarioHex,
    String? fontTitoli,
    String? fontTesti,
    String? layoutPiatti,
    String? bannerCopertina,
    String? textureSfondo,
    String? stileBadge,
  }) async {
    if (temaScelto != null && temaScelto.isNotEmpty) {
      for (final style in AppDesignStyle.values) {
        if (style.name == temaScelto) {
          _designStyle = style;
          break;
        }
      }
    }
    if (colorePrimarioHex != null && colorePrimarioHex.isNotEmpty) {
      try {
        final clean = colorePrimarioHex.replaceAll('#', '');
        if (clean.length == 6) {
          _primaryColor = Color(int.parse('FF$clean', radix: 16));
        } else if (clean.length == 8) {
          _primaryColor = Color(int.parse(clean, radix: 16));
        }
      } catch (_) {}
    } else {
      _primaryColor = _designStyle.defaultPrimaryColor;
    }
    if (fontTitoli != null && fontTitoli.isNotEmpty) {
      _titleFont = fontTitoli;
    } else {
      _titleFont = _designStyle.defaultTitleFont;
    }
    if (fontTesti != null && fontTesti.isNotEmpty) {
      _bodyFont = fontTesti;
    } else {
      _bodyFont = _designStyle.defaultBodyFont;
    }
    if (layoutPiatti != null && layoutPiatti.isNotEmpty) {
      _dishCardLayout = DishCardLayoutExtension.fromString(layoutPiatti);
    }
    if (bannerCopertina != null) {
      _coverBanner = bannerCopertina;
    }
    if (textureSfondo != null && textureSfondo.isNotEmpty) {
      _backgroundTexture = BackgroundTextureExtension.fromString(textureSfondo);
    }
    if (stileBadge != null && stileBadge.isNotEmpty) {
      _badgeStyle = BadgeStyleExtension.fromString(stileBadge);
    }
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyDesignStyle, _designStyle.name);
      final hex = '#${_primaryColor.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
      await prefs.setString(_keyPrimaryColor, hex);
      await prefs.setString(_keyTitleFont, _titleFont);
      await prefs.setString(_keyBodyFont, _bodyFont);
      await prefs.setString(_keyDishCardLayout, _dishCardLayout.name);
      await prefs.setString(_keyCoverBanner, _coverBanner);
      await prefs.setString(_keyBackgroundTexture, _backgroundTexture.name);
      await prefs.setString(_keyBadgeStyle, _badgeStyle.value);
    } catch (_) {}
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
