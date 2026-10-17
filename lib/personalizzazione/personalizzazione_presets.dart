import 'package:flutter/material.dart';
import '../theme_provider.dart';

/// Preset fotografici ad alta risoluzione per la copertina del ristorante
class BannerPresetOption {
  final String id;
  final String title;
  final String subtitle;
  final String imageUrl;
  final IconData icon;

  const BannerPresetOption({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.icon,
  });
}

class PersonalizzazionePresets {
  static const List<BannerPresetOption> banners = [
    BannerPresetOption(
      id: 'preset_forno',
      title: 'Forno & Pizzeria',
      subtitle: 'Forno a legna, lievitati e pizza fumante',
      imageUrl: 'https://images.unsplash.com/photo-1513104890138-7c749659a591?auto=format&fit=crop&w=1200&q=80',
      icon: Icons.local_pizza_rounded,
    ),
    BannerPresetOption(
      id: 'preset_eleganza',
      title: 'Fine Dining & Cantina',
      subtitle: 'Atmosfera esclusiva, calici e posate eleganti',
      imageUrl: 'https://images.unsplash.com/photo-1550966871-3ed3cdb5ed0c?auto=format&fit=crop&w=1200&q=80',
      icon: Icons.wine_bar_rounded,
    ),
    BannerPresetOption(
      id: 'preset_bistrot',
      title: 'Bistrot & Cocktail Bar',
      subtitle: 'Luci calde soffuse, bancone e relax',
      imageUrl: 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=1200&q=80',
      icon: Icons.nightlife_rounded,
    ),
    BannerPresetOption(
      id: 'preset_botanical',
      title: 'Green, Bio & Cucina Fresca',
      subtitle: 'Ingredienti naturali, poké e verdure di stagione',
      imageUrl: 'https://images.unsplash.com/photo-1540420773420-3366772f4999?auto=format&fit=crop&w=1200&q=80',
      icon: Icons.eco_rounded,
    ),
    BannerPresetOption(
      id: 'preset_steakhouse',
      title: 'Braceria & Burger House',
      subtitle: 'Griglia a vista, carni selezionate e burger',
      imageUrl: 'https://images.unsplash.com/photo-1544025162-d76694265947?auto=format&fit=crop&w=1200&q=80',
      icon: Icons.outdoor_grill_rounded,
    ),
    BannerPresetOption(
      id: 'preset_sushi',
      title: 'Sushi & Minimal Zen',
      subtitle: 'Ardesia scura, sushi d\'autore e armonia',
      imageUrl: 'https://images.unsplash.com/photo-1579871494447-9811cf80d66c?auto=format&fit=crop&w=1200&q=80',
      icon: Icons.set_meal_rounded,
    ),
  ];

  /// Risolve l'URL effettivo a partire da un ID preset o da un URL personalizzato
  static String resolveBannerUrl(String? idOrUrl) {
    if (idOrUrl == null || idOrUrl.trim().isEmpty) return '';
    final clean = idOrUrl.trim();
    for (final b in banners) {
      if (b.id == clean) return b.imageUrl;
    }
    if (clean.startsWith('http://') || clean.startsWith('https://')) {
      return clean;
    }
    return '';
  }

  /// Restituisce la decorazione grafica per la texture di sfondo selezionata
  static BoxDecoration getTextureDecoration({
    required BackgroundTexture texture,
    required bool isDark,
    required ThemeData theme,
  }) {
    switch (texture) {
      case BackgroundTexture.pergamena:
        return BoxDecoration(
          color: isDark ? const Color(0xFF1E1A16) : const Color(0xFFFAF6EE),
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF1E1A16), const Color(0xFF27221C), const Color(0xFF1A1713)]
                : [const Color(0xFFFAF6EE), const Color(0xFFF3EDE0), const Color(0xFFF9F5EC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        );

      case BackgroundTexture.legno:
        return BoxDecoration(
          color: isDark ? const Color(0xFF1B1612) : const Color(0xFFF7F2EB),
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF1C1712), const Color(0xFF241D17), const Color(0xFF18130E)]
                : [const Color(0xFFF7F2EB), const Color(0xFFECE4D8), const Color(0xFFF5EFE7)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        );

      case BackgroundTexture.ardesia:
        return BoxDecoration(
          color: isDark ? const Color(0xFF12161A) : const Color(0xFFF1F3F5),
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF14191E), const Color(0xFF1D242B), const Color(0xFF0F1316)]
                : [const Color(0xFFF1F3F5), const Color(0xFFE5E9EC), const Color(0xFFF4F6F8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        );

      case BackgroundTexture.tessuto:
        return BoxDecoration(
          color: isDark ? const Color(0xFF18181A) : const Color(0xFFF8F8F6),
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF19191B), const Color(0xFF212124), const Color(0xFF161617)]
                : [const Color(0xFFF8F8F6), const Color(0xFFEDEDEA), const Color(0xFFFBFBFA)],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        );

      case BackgroundTexture.geometrico:
        return BoxDecoration(
          color: isDark ? const Color(0xFF15181E) : const Color(0xFFF4F6F9),
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF171B22), const Color(0xFF1D222A), const Color(0xFF13161C)]
                : [const Color(0xFFF4F6F9), const Color(0xFFE9EDF2), const Color(0xFFF7F9FC)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        );

      case BackgroundTexture.nessuna:
        return BoxDecoration(
          color: theme.scaffoldBackgroundColor,
        );
    }
  }
}
