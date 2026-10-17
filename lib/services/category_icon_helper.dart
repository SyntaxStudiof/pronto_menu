import 'package:flutter/material.dart';

/// Helper centralizzato per associare a ciascuna categoria del menù
/// un'icona tematica intelligente, coerente tra Menu Cliente e Home Ristoratore.
class CategoryIconHelper {
  static IconData getCategoryIcon(String categoryName) {
    final lower = categoryName.toLowerCase().trim();

    // 1. Pizze e lievitati affini
    if (lower.contains('pizz')) {
      return Icons.local_pizza_rounded;
    }

    // 2. Burger & Sandwich
    if (lower.contains('burg') ||
        lower.contains('panin') ||
        lower.contains('sandwich') ||
        lower.contains('toast') ||
        lower.contains('hot dog') ||
        lower.contains('club')) {
      return Icons.lunch_dining_rounded;
    }

    // 3. Primi Piatti, Paste, Risotti, Zuppe
    if (lower.contains('prim') ||
        lower.contains('past') ||
        lower.contains('risott') ||
        lower.contains('noodl') ||
        lower.contains('gnocch') ||
        lower.contains('lasagn') ||
        lower.contains('spaghett') ||
        lower.contains('ravioli') ||
        lower.contains('tortell') ||
        lower.contains('zupp') ||
        lower.contains('minestr')) {
      return Icons.ramen_dining_rounded;
    }

    // 4. Secondi di Carne
    if (lower.contains('second') ||
        lower.contains('carn') ||
        lower.contains('steak') ||
        lower.contains('tagliat') ||
        lower.contains('grigliat') ||
        lower.contains('arrosto') ||
        lower.contains('filett') ||
        lower.contains('costat') ||
        lower.contains('pollo') ||
        lower.contains('kebab') ||
        lower.contains('bbq') ||
        lower.contains('barbecue')) {
      return Icons.kebab_dining_rounded;
    }

    // 5. Sushi, Poké & Cucina Asiatica
    if (lower.contains('sush') ||
        lower.contains('pok') ||
        lower.contains('sashim') ||
        lower.contains('giappon') ||
        lower.contains('asian') ||
        lower.contains('oriental')) {
      return Icons.rice_bowl_rounded;
    }

    // 6. Pesce & Frutti di Mare
    if (lower.contains('pesc') ||
        lower.contains('fish') ||
        lower.contains('mare') ||
        lower.contains('seafood') ||
        lower.contains('crostac') ||
        lower.contains('gamber') ||
        lower.contains('polp') ||
        lower.contains('calamar') ||
        lower.contains('frittur') ||
        lower.contains('branzin') ||
        lower.contains('orat')) {
      return Icons.set_meal_rounded;
    }

    // 7. Antipasti, Tapas & Sfizi
    if (lower.contains('antipas') ||
        lower.contains('starter') ||
        lower.contains('appetiz') ||
        lower.contains('tapas') ||
        lower.contains('sfiz') ||
        lower.contains('cicchett') ||
        lower.contains('bruschett') ||
        lower.contains('finger')) {
      return Icons.tapas_rounded;
    }

    // 8. Fritti & Snack
    if (lower.contains('fritt') ||
        lower.contains('chip') ||
        lower.contains('patatin') ||
        lower.contains('fries') ||
        lower.contains('nugget')) {
      return Icons.fastfood_rounded;
    }

    // 9. Contorni, Insalate & Verdure
    if (lower.contains('contorn') ||
        lower.contains('insalat') ||
        lower.contains('salad') ||
        lower.contains('verdur') ||
        lower.contains('vegetar') ||
        lower.contains('ortagg') ||
        lower.contains('vegan')) {
      return Icons.eco_rounded;
    }

    // 10. Forno, Focacce & Piadine
    if (lower.contains('focacc') ||
        lower.contains('piadin') ||
        lower.contains('forno') ||
        lower.contains('panetter') ||
        lower.contains('calzon') ||
        lower.contains('schiacciat')) {
      return Icons.bakery_dining_rounded;
    }

    // 11. Dolci & Dessert
    if (lower.contains('dolc') ||
        lower.contains('dessert') ||
        lower.contains('tort') ||
        lower.contains('cake') ||
        lower.contains('pasticc') ||
        lower.contains('tiramis') ||
        lower.contains('cheesecake') ||
        lower.contains('muffin') ||
        lower.contains('cannol')) {
      return Icons.cake_rounded;
    }

    // 12. Gelato & Sorbetto
    if (lower.contains('gelat') ||
        lower.contains('ice cream') ||
        lower.contains('sorbett') ||
        lower.contains('granit')) {
      return Icons.icecream_rounded;
    }

    // 13. Frutta
    if (lower.contains('frutt') ||
        lower.contains('fruit') ||
        lower.contains('macedon')) {
      return Icons.apple_rounded;
    }

    // 14. Cocktail & Aperitivi
    if (lower.contains('cocktail') ||
        lower.contains('aperit') ||
        lower.contains('spritz') ||
        lower.contains('pestat') ||
        lower.contains('mojito') ||
        lower.contains('gin') ||
        lower.contains('long drink')) {
      return Icons.local_bar_rounded;
    }

    // 15. Vini & Bollicine
    if (lower.contains('vin') ||
        lower.contains('wine') ||
        lower.contains('champagne') ||
        lower.contains('prosecco') ||
        lower.contains('bollicin') ||
        lower.contains('spumant') ||
        lower.contains('cantina')) {
      return Icons.wine_bar_rounded;
    }

    // 16. Birre
    if (lower.contains('birr') ||
        lower.contains('beer') ||
        lower.contains('ale') ||
        lower.contains('ipa') ||
        lower.contains('lager') ||
        lower.contains('spina')) {
      return Icons.sports_bar_rounded;
    }

    // 17. Caffetteria & Colazione
    if (lower.contains('caff') ||
        lower.contains('coffee') ||
        lower.contains('colazion') ||
        lower.contains('breakfast') ||
        lower.contains('espresso') ||
        lower.contains('cappuccin') ||
        lower.contains('croissant') ||
        lower.contains('brioche') ||
        lower.contains('cornett')) {
      return Icons.coffee_rounded;
    }

    // 18. Digestivi, Liquori, Amari & Spirits
    if (lower.contains('liquor') ||
        lower.contains('amar') ||
        lower.contains('grapp') ||
        lower.contains('distillat') ||
        lower.contains('spirit') ||
        lower.contains('digestiv') ||
        lower.contains('rum') ||
        lower.contains('vodka') ||
        lower.contains('whisky') ||
        lower.contains('whiskey')) {
      return Icons.liquor_rounded;
    }

    // 19. Bevande analcoliche generiche
    if (lower.contains('bevand') ||
        lower.contains('drink') ||
        lower.contains('bibit') ||
        lower.contains('soft drink') ||
        lower.contains('acqu') ||
        lower.contains('water') ||
        lower.contains('succ') ||
        lower.contains('cola') ||
        lower.contains('aranciat') ||
        lower.contains('the') ||
        lower.contains('tè') ||
        lower.contains('tea')) {
      return Icons.local_cafe_rounded;
    }

    // 20. Default generico ristorazione
    return Icons.restaurant_rounded;
  }
}
