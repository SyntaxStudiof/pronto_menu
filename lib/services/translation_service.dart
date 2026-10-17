import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '/backend/backend.dart';

class MenuLanguage {
  final String code;
  final String label;
  final String flag;

  const MenuLanguage({
    required this.code,
    required this.label,
    required this.flag,
  });
}

class TranslationService {
  static const String _kPrefLangKey = 'prontomenu_client_lang';

  /// Lingue supportate per il menu cliente
  static const List<MenuLanguage> supportedLanguages = [
    MenuLanguage(code: 'it', label: 'Italiano', flag: '🇮🇹'),
    MenuLanguage(code: 'en', label: 'English', flag: '🇬🇧'),
    MenuLanguage(code: 'fr', label: 'Français', flag: '🇫🇷'),
    MenuLanguage(code: 'de', label: 'Deutsch', flag: '🇩🇪'),
    MenuLanguage(code: 'es', label: 'Español', flag: '🇪🇸'),
  ];

  /// Cache in memoria per traduzioni dinamiche
  static final Map<String, String> _memoryCache = {};

  /// Notifier per aggiornamenti reattivi dei testi quando arriva una traduzione dinamica
  static final ValueNotifier<int> translationNotifier = ValueNotifier<int>(0);

  /// Recupera la lingua salvata per il cliente (default 'it')
  static Future<String> getSavedLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_kPrefLangKey) ?? 'it';
    } catch (_) {
      return 'it';
    }
  }

  /// Salva la preferenza di lingua del cliente
  static Future<void> saveLanguage(String langCode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kPrefLangKey, langCode);
      translationNotifier.value++;
    } catch (_) {}
  }

  /// Traduce una stringa di testo nella lingua desiderata (sl=it)
  static Future<String> translateText(
    String text, {
    required String targetLang,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || targetLang == 'it') {
      return text;
    }

    final cacheKey = '$targetLang::$trimmed';
    if (_memoryCache.containsKey(cacheKey)) {
      return _memoryCache[cacheKey]!;
    }

    try {
      final url = Uri.parse(
        'https://translate.googleapis.com/translate_a/single?client=gtx&sl=it&tl=$targetLang&dt=t&q=${Uri.encodeComponent(trimmed)}',
      );

      final res = await http.get(url).timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data is List && data.isNotEmpty && data[0] is List) {
          final translated = (data[0] as List)
              .map((chunk) => chunk[0]?.toString() ?? '')
              .join();
          if (translated.isNotEmpty) {
            _memoryCache[cacheKey] = translated;
            translationNotifier.value++;
            return translated;
          }
        }
      }
    } catch (e) {
      debugPrint('Errore traduzione ($targetLang): $e');
    }

    return text;
  }

  /// Genera le traduzioni per un piatto da salvare su Firestore (esclude categoricamente il Nome!)
  static Future<Map<String, dynamic>> generateDishTranslations({
    required String descrizione,
    required String ingredienti,
  }) async {
    final Map<String, dynamic> translations = {};
    const targetLangs = ['en', 'fr', 'de', 'es'];

    for (final lang in targetLangs) {
      final descFuture = descrizione.isNotEmpty
          ? translateText(descrizione, targetLang: lang)
          : Future.value('');
      final ingrFuture = ingredienti.isNotEmpty
          ? translateText(ingredienti, targetLang: lang)
          : Future.value('');

      final results = await Future.wait([descFuture, ingrFuture]);
      translations[lang] = {
        'descrizione': results[0],
        'ingredienti': results[1],
      };
    }

    return translations;
  }

  /// Restituisce la descrizione del piatto tradotta
  static String getDishDescription(PiattiRecord piatto, String lang) {
    if (lang == 'it' || piatto.descrizione.isEmpty) {
      return piatto.descrizione;
    }

    final dishTranslations = piatto.traduzioni;
    if (dishTranslations.isNotEmpty &&
        dishTranslations[lang] is Map &&
        dishTranslations[lang]['descrizione'] != null &&
        (dishTranslations[lang]['descrizione'] as String).isNotEmpty) {
      return dishTranslations[lang]['descrizione'] as String;
    }

    final cacheKey = '$lang::${piatto.descrizione.trim()}';
    if (_memoryCache.containsKey(cacheKey)) {
      return _memoryCache[cacheKey]!;
    }

    // Se non presente, avvia traduzione in background per le prossime letture
    translateText(piatto.descrizione, targetLang: lang);
    return piatto.descrizione;
  }

  /// Restituisce gli ingredienti del piatto tradotti
  static String getDishIngredients(PiattiRecord piatto, String lang) {
    if (lang == 'it' || piatto.ingredienti.isEmpty) {
      return piatto.ingredienti;
    }

    final dishTranslations = piatto.traduzioni;
    if (dishTranslations.isNotEmpty &&
        dishTranslations[lang] is Map &&
        dishTranslations[lang]['ingredienti'] != null &&
        (dishTranslations[lang]['ingredienti'] as String).isNotEmpty) {
      return dishTranslations[lang]['ingredienti'] as String;
    }

    final cacheKey = '$lang::${piatto.ingredienti.trim()}';
    if (_memoryCache.containsKey(cacheKey)) {
      return _memoryCache[cacheKey]!;
    }

    // Se non presente, avvia traduzione in background per le prossime letture
    translateText(piatto.ingredienti, targetLang: lang);
    return piatto.ingredienti;
  }

  /// Traduzione rapida delle categorie di menu più comuni
  static final Map<String, Map<String, String>> _categoryDictionary = {
    'antipasti': {
      'en': 'Appetizers',
      'fr': 'Entrées',
      'de': 'Vorspeisen',
      'es': 'Entrantes',
    },
    'primi': {
      'en': 'First Courses',
      'fr': 'Premiers Plats',
      'de': 'Erste Gänge',
      'es': 'Primeros Platos',
    },
    'primi piatti': {
      'en': 'First Courses',
      'fr': 'Premiers Plats',
      'de': 'Erste Gänge',
      'es': 'Primeros Platos',
    },
    'secondi': {
      'en': 'Main Courses',
      'fr': 'Plats Principaux',
      'de': 'Hauptgerichte',
      'es': 'Segundos Platos',
    },
    'secondi piatti': {
      'en': 'Main Courses',
      'fr': 'Plats Principaux',
      'de': 'Hauptgerichte',
      'es': 'Segundos Platos',
    },
    'contorni': {
      'en': 'Side Dishes',
      'fr': 'Accompagnements',
      'de': 'Beilagen',
      'es': 'Guarniciones',
    },
    'pizze': {
      'en': 'Pizzas',
      'fr': 'Pizzas',
      'de': 'Pizzen',
      'es': 'Pizzas',
    },
    'pizza': {
      'en': 'Pizza',
      'fr': 'Pizza',
      'de': 'Pizza',
      'es': 'Pizza',
    },
    'dolci': {
      'en': 'Desserts',
      'fr': 'Desserts',
      'de': 'Desserts',
      'es': 'Postres',
    },
    'dessert': {
      'en': 'Desserts',
      'fr': 'Desserts',
      'de': 'Desserts',
      'es': 'Postres',
    },
    'bevande': {
      'en': 'Drinks',
      'fr': 'Boissons',
      'de': 'Getränke',
      'es': 'Bebidas',
    },
    'bibite': {
      'en': 'Beverages',
      'fr': 'Boissons',
      'de': 'Erfrischungsgetränke',
      'es': 'Refrescos',
    },
    'birre': {
      'en': 'Beers',
      'fr': 'Bières',
      'de': 'Biere',
      'es': 'Cervezas',
    },
    'vini': {
      'en': 'Wines',
      'fr': 'Vins',
      'de': 'Weine',
      'es': 'Vinos',
    },
    'caffetteria': {
      'en': 'Coffee & Tea',
      'fr': 'Cafétéria',
      'de': 'Kaffee & Tee',
      'es': 'Cafetería',
    },
    'specialità': {
      'en': 'Specials',
      'fr': 'Spécialités',
      'de': 'Spezialitäten',
      'es': 'Especialidades',
    },
  };

  /// Restituisce la categoria tradotta
  static String getCategoryName(String category, String lang) {
    if (lang == 'it' || category.trim().isEmpty) return category;

    final lower = category.trim().toLowerCase();
    if (_categoryDictionary.containsKey(lower) &&
        _categoryDictionary[lower]![lang] != null) {
      return _categoryDictionary[lower]![lang]!;
    }

    final cacheKey = '$lang::$lower';
    if (_memoryCache.containsKey(cacheKey)) {
      return _memoryCache[cacheKey]!;
    }

    translateText(category, targetLang: lang);
    return category;
  }

  /// Dizionario testi UI del menu cliente
  static final Map<String, Map<String, String>> _uiDictionary = {
    'cerca_piatto': {
      'it': 'Cerca nel menu...',
      'en': 'Search in menu...',
      'fr': 'Rechercher dans le menu...',
      'de': 'Im Menü suchen...',
      'es': 'Buscar en el menú...',
    },
    'filtri_magici': {
      'it': 'Filtri Magici',
      'en': 'Smart Filters',
      'fr': 'Filtres Intelligents',
      'de': 'Smarte Filter',
      'es': 'Filtros Inteligentes',
    },
    'tutti_i_piatti': {
      'it': 'Tutti',
      'en': 'All',
      'fr': 'Tous',
      'de': 'Alle',
      'es': 'Todos',
    },
    'aggiungi': {
      'it': 'Aggiungi',
      'en': 'Add',
      'fr': 'Ajouter',
      'de': 'Hinzufügen',
      'es': 'Añadir',
    },
    'ingredienti': {
      'it': 'Ingredienti',
      'en': 'Ingredients',
      'fr': 'Ingrédients',
      'de': 'Zutaten',
      'es': 'Ingredientes',
    },
    'allergeni': {
      'it': 'Allergeni',
      'en': 'Allergens',
      'fr': 'Allergènes',
      'de': 'Allergene',
      'es': 'Alérgenos',
    },
    'nessun_piatto': {
      'it': 'Nessun piatto trovato',
      'en': 'No dishes found',
      'fr': 'Aucun plat trouvé',
      'de': 'Keine Gerichte gefunden',
      'es': 'No se encontraron platos',
    },
    'lingua': {
      'it': 'Lingua',
      'en': 'Language',
      'fr': 'Langue',
      'de': 'Sprache',
      'es': 'Idioma',
    },
    'seleziona_lingua': {
      'it': 'Seleziona Lingua',
      'en': 'Select Language',
      'fr': 'Sélectionner la langue',
      'de': 'Sprache auswählen',
      'es': 'Seleccionar idioma',
    },
    'lingua_menu': {
      'it': 'Lingua del Menu',
      'en': 'Menu Language',
      'fr': 'Langue du Menu',
      'de': 'Menüsprache',
      'es': 'Idioma del Menú',
    },
    'filtri': {
      'it': 'Filtri',
      'en': 'Filters',
      'fr': 'Filtres',
      'de': 'Filter',
      'es': 'Filtros',
    },
    'azzera_filtri': {
      'it': 'Azzera filtri',
      'en': 'Reset filters',
      'fr': 'Réinitialiser',
      'de': 'Filter zurücksetzen',
      'es': 'Restablecer',
    },
    'nessun_piatto_filtri': {
      'it': 'Nessun piatto trovato con i filtri selezionati.',
      'en': 'No dishes found with selected filters.',
      'fr': 'Aucun plat trouvé avec les filtres sélectionnés.',
      'de': 'Keine Gerichte mit den ausgewählten Filtern gefunden.',
      'es': 'No se encontraron platos con los filtros seleccionados.',
    },
    'modifica_filtri_hint': {
      'it': 'Prova a modificare i filtri o gli allergeni esclusi per vedere più piatti.',
      'en': 'Try adjusting your filters or excluded allergens to see more dishes.',
      'fr': 'Essayez de modifier les filtres pour voir plus de plats.',
      'de': 'Versuchen Sie, die Filter anzupassen, um mehr Gerichte zu sehen.',
      'es': 'Intenta ajustar los filtros para ver más platos.',
    },
    // Jukebox
    'jukebox_locale': {
      'it': 'Jukebox del Locale',
      'en': 'Venue Jukebox',
      'fr': 'Jukebox du Lieu',
      'de': 'Lokal-Jukebox',
      'es': 'Jukebox del Local',
    },
    'musica_diffusione': {
      'it': 'Musica dal vivo in diffusione',
      'en': 'Live background music',
      'fr': 'Musique d\'ambiance en direct',
      'de': 'Live-Hintergrundmusik',
      'es': 'Música en vivo',
    },
    'in_onda_coda': {
      'it': 'In Onda & Coda',
      'en': 'On Air & Queue',
      'fr': 'En Cours & File',
      'de': 'Läuft & Warteschlange',
      'es': 'En Reproducción y Cola',
    },
    'scegli_brano': {
      'it': 'Scegli un Brano',
      'en': 'Pick a Song',
      'fr': 'Choisir un Titre',
      'de': 'Song auswählen',
      'es': 'Elegir Canción',
    },
    'in_riproduzione': {
      'it': 'In riproduzione:',
      'en': 'Now playing:',
      'fr': 'En cours de lecture :',
      'de': 'Aktuelle Wiedergabe:',
      'es': 'En reproducción:',
    },
    'nessun_brano_in_riproduzione': {
      'it': 'Nessun brano in riproduzione',
      'en': 'No song currently playing',
      'fr': 'Aucun titre en cours de lecture',
      'de': 'Derzeit wird kein Song abgespielt',
      'es': 'Ninguna canción en reproducción',
    },
    'coda_richieste': {
      'it': 'Coda Richieste Clienti',
      'en': 'Customer Request Queue',
      'fr': 'File des Demandes Clients',
      'de': 'Warteschlange der Gästewünsche',
      'es': 'Cola de Solicitudes',
    },
    'nessun_brano_coda': {
      'it': 'Nessun brano in coda',
      'en': 'No songs in queue',
      'fr': 'Aucun titre dans la file',
      'de': 'Keine Songs in der Warteschlange',
      'es': 'Ninguna canción en cola',
    },
    'sii_il_primo': {
      'it': 'Sii il primo a richiedere una canzone!',
      'en': 'Be the first to request a song!',
      'fr': 'Soyez le premier à demander une chanson !',
      'de': 'Seien Sie der Erste, der einen Song wünscht!',
      'es': '¡Sé el primero en pedir una canción!',
    },
    'cerca_brano_artista': {
      'it': 'Cerca brano o artista...',
      'en': 'Search song or artist...',
      'fr': 'Rechercher titre ou artiste...',
      'de': 'Song oder Künstler suchen...',
      'es': 'Buscar canción o artista...',
    },
    'richiedi': {
      'it': 'Richiedi',
      'en': 'Request',
      'fr': 'Demander',
      'de': 'Wünschen',
      'es': 'Pedir',
    },
    'in_coda': {
      'it': 'In Coda',
      'en': 'In Queue',
      'fr': 'En File',
      'de': 'In Warteschlange',
      'es': 'En Cola',
    },
    'conferma_richiesta': {
      'it': 'Conferma Richiesta',
      'en': 'Confirm Request',
      'fr': 'Confirmer la Demande',
      'de': 'Anfrage bestätigen',
      'es': 'Confirmar Solicitud',
    },
    'annulla': {
      'it': 'Annulla',
      'en': 'Cancel',
      'fr': 'Annuler',
      'de': 'Abbrechen',
      'es': 'Cancelar',
    },
    'vuoi_richiedere': {
      'it': 'Vuoi richiedere questo brano?',
      'en': 'Do you want to request this song?',
      'fr': 'Voulez-vous demander ce titre ?',
      'de': 'Möchten Sie diesen Song anfordern?',
      'es': '¿Quieres solicitar esta canción?',
    },
    'richiesta_inviata': {
      'it': 'Richiesta inviata con successo!',
      'en': 'Request sent successfully!',
      'fr': 'Demande envoyée avec succès !',
      'de': 'Anfrage erfolgreich gesendet!',
      'es': '¡Solicitud enviada con éxito!',
    },
    'puoi_richiedere_tra': {
      'it': 'Puoi richiedere un altro brano tra',
      'en': 'You can request another song in',
      'fr': 'Vous pouvez demander un autre titre dans',
      'de': 'Nächste Anfrage möglich in',
      'es': 'Puedes pedir otra canción en',
    },
    'jukebox_non_attivo': {
      'it': 'Il Jukebox non è attualmente attivo',
      'en': 'The Jukebox is currently not active',
      'fr': 'Le Jukebox n\'est pas actif actuellement',
      'de': 'Die Jukebox ist derzeit nicht aktiv',
      'es': 'El Jukebox no está activo actualmente',
    },
    'nessun_brano_trovato': {
      'it': 'Nessun brano trovato',
      'en': 'No songs found',
      'fr': 'Aucun titre trouvé',
      'de': 'Keine Songs gefunden',
      'es': 'No se encontraron canciones',
    },
    'riprova': {
      'it': 'Riprova',
      'en': 'Retry',
      'fr': 'Réessayer',
      'de': 'Wiederholen',
      'es': 'Reintentar',
    },
    'in_onda_ora': {
      'it': 'IN ONDA ORA',
      'en': 'ON AIR NOW',
      'fr': 'EN DIRECT',
      'de': 'JETZT AUF SENDUNG',
      'es': 'EN EL AIRE AHORA',
    },
    'musica_in_pausa': {
      'it': 'MUSICA IN PAUSA',
      'en': 'MUSIC PAUSED',
      'fr': 'MUSIQUE EN PAUSE',
      'de': 'MUSIK PAUSIERT',
      'es': 'MÚSICA EN PAUSA',
    },
    'giradischi_pronto': {
      'it': 'Giradischi pronto',
      'en': 'Turntable ready',
      'fr': 'Tourne-disque prêt',
      'de': 'Plattenspieler bereit',
      'es': 'Tocadiscos listo',
    },
    'in_attesa_locale': {
      'it': 'In attesa di riproduzione dal locale',
      'en': 'Waiting for music from venue',
      'fr': 'En attente de diffusion par le lieu',
      'de': 'Warten auf Musik vom Lokal',
      'es': 'Esperando reproducción del local',
    },
    'in_pausa': {
      'it': 'In pausa',
      'en': 'Paused',
      'fr': 'En pause',
      'de': 'Pausiert',
      'es': 'En pausa',
    },
    'canzoni_in_coda_tavoli': {
      'it': 'Canzoni in Coda dai Tavoli',
      'en': 'Songs in Queue from Tables',
      'fr': 'Titres en file d\'attente',
      'de': 'Warteschlangen-Titel der Tische',
      'es': 'Canciones en cola de las mesas',
    },
    'ordine_richiesta': {
      'it': 'Verranno riprodotte in ordine di richiesta',
      'en': 'Will be played in order of request',
      'fr': 'Diffusés dans l\'ordre des demandes',
      'de': 'Werden nach Reihenfolge der Anfragen abgespielt',
      'es': 'Se reproducirán en orden de solicitud',
    },
    'nessuna_canzone_coda': {
      'it': 'Nessuna canzone in coda al momento',
      'en': 'No songs currently in queue',
      'fr': 'Aucun titre dans la file pour le moment',
      'de': 'Derzeit keine Songs in der Warteschlange',
      'es': 'No hay canciones en cola en este momento',
    },
    'prossima_in_riproduzione': {
      'it': 'PROSSIMA IN RIPRODUZIONE',
      'en': 'UP NEXT',
      'fr': 'À SUIVRE',
      'de': 'ALS NÄCHSTES',
      'es': 'A CONTINUACIÓN',
    },
    'sfoglia_playlist_richiedi': {
      'it': 'Sfoglia la Playlist e Richiedi un Brano',
      'en': 'Browse Playlist & Request a Song',
      'fr': 'Parcourir la playlist et demander un titre',
      'de': 'Playlist durchsuchen & Song wünschen',
      'es': 'Explorar playlist y pedir canción',
    },
    'prossima_richiesta_tra': {
      'it': 'Prossima richiesta disponibile tra:',
      'en': 'Next request available in:',
      'fr': 'Prochaine demande disponible dans :',
      'de': 'Nächste Anfrage möglich in:',
      'es': 'Próxima solicitud disponible en:',
    },
    'puoi_richiedere_ora': {
      'it': 'Puoi richiedere 1 brano adesso!',
      'en': 'You can request 1 song now!',
      'fr': 'Vous pouvez demander 1 titre maintenant !',
      'de': 'Du kannst jetzt 1 Song anfordern!',
      'es': '¡Puedes pedir 1 canción ahora!',
    },
    'regola_antispam': {
      'it': 'Regola anti-spam: 1 richiesta ogni 30 minuti a persona.',
      'en': 'Anti-spam rule: 1 request every 30 minutes per guest.',
      'fr': 'Règle anti-spam : 1 demande toutes les 30 min par personne.',
      'de': 'Anti-Spam-Regel: 1 Anfrage alle 30 Minuten pro Gast.',
      'es': 'Regla anti-spam: 1 solicitud cada 30 min por persona.',
    },
    'cerca_per_titolo_artista': {
      'it': 'Cerca per titolo o artista...',
      'en': 'Search by title or artist...',
      'fr': 'Rechercher par titre ou artiste...',
      'de': 'Nach Titel oder Künstler suchen...',
      'es': 'Buscar por título o artista...',
    },
    'caricamento_playlist': {
      'it': 'Caricamento playlist...',
      'en': 'Loading playlist...',
      'fr': 'Chargement de la playlist...',
      'de': 'Lade Playlist...',
      'es': 'Cargando playlist...',
    },
    'prova_altro_titolo': {
      'it': 'Prova a cercare con un altro nome o titolo',
      'en': 'Try searching with another name or title',
      'fr': 'Essayez de chercher avec un autre titre ou artiste',
      'de': 'Versuchen Sie es mit einem anderen Namen oder Titel',
      'es': 'Intenta buscar con otro nombre o título',
    },
    'gia_in_coda': {
      'it': 'è già in coda! Scegli un\'altra canzone.',
      'en': 'is already in queue! Pick another song.',
      'fr': 'est déjà dans la file ! Choisissez un autre titre.',
      'de': 'ist bereits in der Warteschlange! Wählen Sie einen anderen Song.',
      'es': 'ya está en cola. Elige otra canción.',
    },
    'attendi_ancora': {
      'it': 'Attendi ancora',
      'en': 'Please wait',
      'fr': 'Veuillez patienter encore',
      'de': 'Bitte warten Sie noch',
      'es': 'Espera todavía',
    },
    'prima_di_richiedere': {
      'it': 'prima di richiedere un altro brano.',
      'en': 'before requesting another song.',
      'fr': 'avant de demander un autre titre.',
      'de': 'bevor Sie einen weiteren Song wünschen.',
      'es': 'antes de pedir otra canción.',
    },
    'richiedi_canzone_titolo': {
      'it': 'Richiedi Canzone',
      'en': 'Request Song',
      'fr': 'Demander une Chanson',
      'de': 'Song Wünschen',
      'es': 'Solicitar Canción',
    },
    'vuoi_mettere_in_coda': {
      'it': 'Vuoi mettere in coda:',
      'en': 'Do you want to queue:',
      'fr': 'Voulez-vous ajouter à la file :',
      'de': 'Möchten Sie in die Warteschlange einreihen:',
      'es': '¿Quieres añadir a la cola:',
    },
    'potrai_richiedere_tra_30': {
      'it': 'Potrai richiedere un altro brano tra 30 minuti.',
      'en': 'You will be able to request another song in 30 minutes.',
      'fr': 'Vous pourrez demander un autre titre dans 30 minutes.',
      'de': 'Sie können in 30 Minuten einen weiteren Song anfordern.',
      'es': 'Podrás solicitar otra canción en 30 minutos.',
    },
    'richiesta_inviata_successo': {
      'it': 'Richiesta inviata! In coda.',
      'en': 'Request sent! In queue.',
      'fr': 'Demande envoyée ! En file d\'attente.',
      'de': 'Anfrage gesendet! In Warteschlange.',
      'es': '¡Solicitud enviada! En cola.',
    },
    'errore_invio_richiesta': {
      'it': 'Errore durante l\'invio della richiesta:',
      'en': 'Error sending request:',
      'fr': 'Erreur lors de l\'envoi de la demande :',
      'de': 'Fehler beim Senden der Anfrage:',
      'es': 'Error al enviar la solicitud:',
    },
    'impossibile_caricare_playlist': {
      'it': 'Impossibile caricare i brani della playlist.',
      'en': 'Unable to load playlist tracks.',
      'fr': 'Impossible de charger les titres de la playlist.',
      'de': 'Playlist-Titel konnten nicht geladen werden.',
      'es': 'No se pudieron cargar las canciones de la lista.',
    },
    'scegli_categoria_in_alto': {
      'it': 'Scegli una categoria in alto',
      'en': 'Choose a category above',
      'fr': 'Choisissez une catégorie ci-dessus',
      'de': 'Kategorie oben auswählen',
      'es': 'Elige una categoría arriba',
    },
    'benvenuto_da': {
      'it': 'BENVENUTO DA',
      'en': 'WELCOME TO',
      'fr': 'BIENVENUE CHEZ',
      'de': 'WILLKOMMEN BEI',
      'es': 'BIENVENIDO A',
    },
    // Allergeni & Filtri
    'escludi_allergeni': {
      'it': 'Escludi Allergeni',
      'en': 'Exclude Allergens',
      'fr': 'Exclure les Allergènes',
      'de': 'Allergene ausschließen',
      'es': 'Excluir Alérgenos',
    },
    'nascondi_piatti_allergeni': {
      'it': 'Nascondi i piatti che contengono gli allergeni selezionati',
      'en': 'Hide dishes containing selected allergens',
      'fr': 'Masquer les plats contenant les allergènes sélectionnés',
      'de': 'Gerichte mit ausgewählten Allergenen ausblenden',
      'es': 'Ocultar platos con los alérgenos seleccionados',
    },
    'azzera': {
      'it': 'Azzera',
      'en': 'Reset',
      'fr': 'Effacer',
      'de': 'Zurücksetzen',
      'es': 'Restablecer',
    },
    'applica_filtri': {
      'it': 'Applica Filtri',
      'en': 'Apply Filters',
      'fr': 'Appliquer les Filtres',
      'de': 'Filter anwenden',
      'es': 'Aplicar Filtros',
    },
    'allergeni_presenti_menu': {
      'it': 'Allergeni presenti nei piatti di questo menu',
      'en': 'Allergens present in dishes on this menu',
      'fr': 'Allergènes présents dans ce menu',
      'de': 'In diesem Menü vorkommende Allergene',
      'es': 'Alérgenos presentes en este menú',
    },
    'allergeni_alimentari': {
      'it': 'Allergeni alimentari',
      'en': 'Food allergens',
      'fr': 'Allergènes alimentaires',
      'de': 'Lebensmittelallergene',
      'es': 'Alérgenos alimentarios',
    },
    'esclusi': {
      'it': 'esclusi',
      'en': 'excluded',
      'fr': 'exclus',
      'de': 'ausgeschlossen',
      'es': 'excluidos',
    },
    'allergeni_badge': {
      'it': 'allergeni',
      'en': 'allergens',
      'fr': 'allergènes',
      'de': 'Allergene',
      'es': 'alérgenos',
    },
    'nessun_allergene_dichiarato': {
      'it': 'Nessun allergene dichiarato',
      'en': 'No allergens declared',
      'fr': 'Aucun allergène déclaré',
      'de': 'Keine Allergene deklariert',
      'es': 'Sin alérgenos declarados',
    },
    'nota_ingredienti_esauriti': {
      'it': 'Nota: gli ingredienti sbarrati non sono al momento disponibili.',
      'en': 'Note: strikethrough ingredients are currently unavailable.',
      'fr': 'Note : les ingrédients barrés ne sont pas disponibles actuellement.',
      'de': 'Hinweis: Durchgestrichene Zutaten sind derzeit nicht verfügbar.',
      'es': 'Nota: los ingredientes tachados no están disponibles en este momento.',
    },
    'menu': {
      'it': 'Menu',
      'en': 'Menu',
      'fr': 'Menu',
      'de': 'Menü',
      'es': 'Menú',
    },
    'piatto_assente': {
      'it': 'Piatto assente',
      'en': 'Dish unavailable',
      'fr': 'Plat indisponible',
      'de': 'Gericht nicht verfügbar',
      'es': 'Plato no disponible',
    },
    'ingredienti_assenti': {
      'it': 'Ingredienti assenti',
      'en': 'No ingredients listed',
      'fr': 'Aucun ingrédient indiqué',
      'de': 'Keine Zutaten angegeben',
      'es': 'Sin ingredientes indicados',
    },
    'descrizione_assente': {
      'it': 'Descrizione assente',
      'en': 'No description available',
      'fr': 'Aucune description disponible',
      'de': 'Keine Beschreibung verfügbar',
      'es': 'Sin descripción disponible',
    },
    // Personalizzazione Piatto
    'personalizza_piatto': {
      'it': 'Personalizza piatto',
      'en': 'Customize dish',
      'fr': 'Personnaliser le plat',
      'de': 'Gericht anpassen',
      'es': 'Personalizar plato',
    },
    'modifica_ingredienti': {
      'it': 'Modifica ingredienti',
      'en': 'Modify ingredients',
      'fr': 'Modifier les ingrédients',
      'de': 'Zutaten anpassen',
      'es': 'Modificar ingredientes',
    },
    'ingredienti_base': {
      'it': 'Ingredienti base (tocca per rimuovere):',
      'en': 'Base ingredients (tap to remove):',
      'fr': 'Ingrédients de base (touchez pour retirer) :',
      'de': 'Grundzutaten (zum Entfernen tippen):',
      'es': 'Ingredientes base (toca para quitar):',
    },
    'aggiungi_dalla_dispensa': {
      'it': 'Aggiungi dalla dispensa:',
      'en': 'Add from pantry:',
      'fr': 'Ajouter depuis la réserve :',
      'de': 'Aus der Vorratskammer hinzufügen:',
      'es': 'Añadir de la despensa:',
    },
    'nessun_ingrediente_dispensa': {
      'it': 'Nessun ingrediente aggiuntivo disponibile in dispensa',
      'en': 'No extra ingredients available in pantry',
      'fr': 'Aucun ingrédient supplémentaire disponible dans la réserve',
      'de': 'Keine zusätzlichen Zutaten in der Vorratskammer verfügbar',
      'es': 'No hay ingredientes adicionales disponibles en la despensa',
    },
    'cerca_ingrediente': {
      'it': 'Cerca ingrediente...',
      'en': 'Search ingredient...',
      'fr': 'Rechercher un ingrédient...',
      'de': 'Zutat suchen...',
      'es': 'Buscar ingrediente...',
    },
    'ingrediente_manuale_titolo': {
      'it': 'Aggiunta a mano libera:',
      'en': 'Custom addition:',
      'fr': 'Ajout manuel :',
      'de': 'Manuelle Zugabe:',
      'es': 'Añadido manual:',
    },
    'ingrediente_manuale_hint': {
      'it': 'Scrivi un ingrediente o modifica...',
      'en': 'Type an ingredient or note...',
      'fr': 'Écrivez un ingrédient ou une note...',
      'de': 'Zutat oder Notiz eingeben...',
      'es': 'Escribe un ingrediente o nota...',
    },
    'riepilogo_modifiche': {
      'it': 'Riepilogo modifiche:',
      'en': 'Customization summary:',
      'fr': 'Résumé des modifications :',
      'de': 'Zusammenfassung der Änderungen:',
      'es': 'Resumen de modificaciones:',
    },
    'nessuna_modifica': {
      'it': 'Nessuna modifica (piatto standard)',
      'en': 'No modifications (standard dish)',
      'fr': 'Aucune modification (plat standard)',
      'de': 'Keine Änderungen (Standardgericht)',
      'es': 'Sin modificaciones (plato estándar)',
    },
    'aggiungi_al_carrello': {
      'it': 'Aggiungi al carrello',
      'en': 'Add to cart',
      'fr': 'Ajouter au panier',
      'de': 'In den Warenkorb',
      'es': 'Añadir al carrito',
    },
    'piatto_personalizzato_aggiunto': {
      'it': 'Piatto personalizzato aggiunto al carrello!',
      'en': 'Customized dish added to cart!',
      'fr': 'Plat personnalisé ajouté au panier !',
      'de': 'Angepasstes Gericht in den Warenkorb gelegt!',
      'es': '¡Plato personalizado añadido al carrito!',
    },
    'solo_dispensa_avviso': {
      'it': 'Le modifiche sono limitate agli ingredienti disponibili in dispensa.',
      'en': 'Modifications are limited to ingredients available in the pantry.',
      'fr': 'Les modifications sont limitées aux ingrédients disponibles dans la réserve.',
      'de': 'Änderungen sind auf in der Vorratskammer verfügbare Zutaten beschränkt.',
      'es': 'Las modificaciones están limitadas a los ingredientes disponibles en la despensa.',
    },
    // Carrello & Ordini
    'riepilogo_ordini': {
      'it': 'Riepilogo Ordine',
      'en': 'Order Summary',
      'fr': 'Récapitulatif de Commande',
      'de': 'Bestellübersicht',
      'es': 'Resumen del Pedido',
    },
    'carrello_vuoto': {
      'it': 'Il tuo carrello è vuoto',
      'en': 'Your cart is empty',
      'fr': 'Votre panier est vide',
      'de': 'Ihr Warenkorb ist leer',
      'es': 'Tu carrito está vacío',
    },
    'carrello_vuoto_desc': {
      'it': 'Non hai ancora aggiunto alcun piatto. Sfoglia il menu e scegli le tue specialità preferite!',
      'en': 'You haven\'t added any dishes yet. Browse the menu and pick your favorite specialties!',
      'fr': 'Vous n\'avez pas encore ajouté de plat. Parcourez le menu et choisissez vos spécialités préférées !',
      'de': 'Sie haben noch keine Gerichte hinzugefügt. Durchsuchen Sie die Speisekarte und wählen Sie Ihre Favoriten!',
      'es': 'Aún no has añadido ningún plato. ¡Explora el menú y elige tus especialidades favoritas!',
    },
    'torna_al_menu': {
      'it': 'Torna al Menu',
      'en': 'Back to Menu',
      'fr': 'Retour au Menu',
      'de': 'Zurück zum Menü',
      'es': 'Volver al Menú',
    },
    'svuota_carrello': {
      'it': 'Svuota carrello',
      'en': 'Clear cart',
      'fr': 'Vider le panier',
      'de': 'Warenkorb leeren',
      'es': 'Vaciar carrito',
    },
    'svuota_carrello_conferma': {
      'it': 'Vuoi davvero svuotare il carrello? Tutti i piatti selezionati verranno rimossi.',
      'en': 'Do you really want to clear your cart? All selected dishes will be removed.',
      'fr': 'Voulez-vous vraiment vider votre panier ? Tous les plats sélectionnés seront supprimés.',
      'de': 'Möchten Sie Ihren Warenkorb wirklich leeren? Alle ausgewählten Gerichte werden entfernt.',
      'es': '¿Seguro que quieres vaciar el carrito? Se eliminarán todos los platos seleccionados.',
    },
    'svuota': {
      'it': 'Svuota',
      'en': 'Clear',
      'fr': 'Vider',
      'de': 'Leeren',
      'es': 'Vaciar',
    },
    'piatti_selezionati': {
      'it': 'Piatti selezionati',
      'en': 'Selected dishes',
      'fr': 'Plats sélectionnés',
      'de': 'Ausgewählte Gerichte',
      'es': 'Platos seleccionados',
    },
    'totale_ordine': {
      'it': 'Totale ordine',
      'en': 'Order total',
      'fr': 'Total de la commande',
      'de': 'Bestellsumme',
      'es': 'Total del pedido',
    },
    'totale': {
      'it': 'Totale:',
      'en': 'Total:',
      'fr': 'Total :',
      'de': 'Gesamt:',
      'es': 'Total:',
    },
    'invia_ordine': {
      'it': 'Invia ordine',
      'en': 'Send order',
      'fr': 'Envoyer la commande',
      'de': 'Bestellung senden',
      'es': 'Enviar pedido',
    },
    'sessione_scaduta': {
      'it': 'Sessione scaduta. Per favore, inquadra nuovamente il QR Code del tavolo per tornare al menu',
      'en': 'Session expired. Please scan the table QR Code again to return to the menu',
      'fr': 'Session expirée. Veuillez scanner à nouveau le QR Code pour revenir au menu',
      'de': 'Sitzung abgelaufen. Bitte scannen Sie den QR-Code erneut, um zum Menü zurückzukehren',
      'es': 'Sesión caducada. Escanea de nuevo el código QR de la mesa para volver al menú',
    },
    'inserisci_tavolo': {
      'it': 'Inserisci numero tavolo',
      'en': 'Enter table number',
      'fr': 'Entrez le numéro de table',
      'de': 'Tischnummer eingeben',
      'es': 'Introduce el número de mesa',
    },
    'conferma_ordine': {
      'it': 'Conferma Ordine',
      'en': 'Confirm Order',
      'fr': 'Confirmer la Commande',
      'de': 'Bestellung bestätigen',
      'es': 'Confirmar Pedido',
    },
    'ordine_inviato': {
      'it': 'Ordine inviato con successo! Lo stiamo preparando per te.',
      'en': 'Order sent successfully! We are preparing it for you.',
      'fr': 'Commande envoyée avec succès ! Nous la préparons pour vous.',
      'de': 'Bestellung erfolgreich gesendet! Wir bereiten sie für Sie zu.',
      'es': '¡Pedido enviado con éxito! Lo estamos preparando para ti.',
    },
    'panoramica': {
      'it': 'Panoramica',
      'en': 'Overview',
      'fr': 'Aperçu',
      'de': 'Übersicht',
      'es': 'Resumen',
    },
    'tutte': {
      'it': 'Tutte',
      'en': 'All',
      'fr': 'Toutes',
      'de': 'Alle',
      'es': 'Todas',
    },
  };

  /// Restituisce una stringa di interfaccia nella lingua corrente
  static String getUi(String key, String lang) {
    if (_uiDictionary.containsKey(key) && _uiDictionary[key]![lang] != null) {
      return _uiDictionary[key]![lang]!;
    }
    return _uiDictionary[key]?['it'] ?? key;
  }

  /// Dizionario dei filtri magici (intolleranze)
  static final Map<String, Map<String, String>> _magicFiltersDictionary = {
    'senza_glutine': {
      'it': 'Senza Glutine',
      'en': 'Gluten Free',
      'fr': 'Sans Gluten',
      'de': 'Glutenfrei',
      'es': 'Sin Gluten',
    },
    'senza_lattosio': {
      'it': 'Senza Lattosio',
      'en': 'Lactose Free',
      'fr': 'Sans Lactose',
      'de': 'Laktosefrei',
      'es': 'Sin Lactosa',
    },
    'vegetariano': {
      'it': 'Vegetariano',
      'en': 'Vegetarian',
      'fr': 'Végétarien',
      'de': 'Vegetarisch',
      'es': 'Vegetariano',
    },
    'vegano': {
      'it': 'Vegano',
      'en': 'Vegan',
      'fr': 'Végétalien',
      'de': 'Vegan',
      'es': 'Vegano',
    },
  };

  /// Restituisce la label tradotta di un filtro magico
  static String getFiltroLabel(String id, String lang) {
    final clean = id.trim().toLowerCase().replaceAll(' ', '_');
    if (_magicFiltersDictionary.containsKey(clean) &&
        _magicFiltersDictionary[clean]![lang] != null) {
      return _magicFiltersDictionary[clean]![lang]!;
    }
    return id;
  }

  /// Dizionario degli allergeni obbligatori per legge
  static final Map<String, Map<String, String>> _allergeniDictionary = {
    'glutine': {
      'it': 'Glutine',
      'en': 'Gluten',
      'fr': 'Gluten',
      'de': 'Gluten',
      'es': 'Gluten',
    },
    'crostacei': {
      'it': 'Crostacei',
      'en': 'Crustaceans',
      'fr': 'Crustacés',
      'de': 'Krebstiere',
      'es': 'Crustáceos',
    },
    'uova': {
      'it': 'Uova',
      'en': 'Eggs',
      'fr': 'Œufs',
      'de': 'Eier',
      'es': 'Huevos',
    },
    'pesce': {
      'it': 'Pesce',
      'en': 'Fish',
      'fr': 'Poisson',
      'de': 'Fisch',
      'es': 'Pescado',
    },
    'arachidi': {
      'it': 'Arachidi',
      'en': 'Peanuts',
      'fr': 'Arachides',
      'de': 'Erdnüsse',
      'es': 'Cacahuetes',
    },
    'soia': {
      'it': 'Soia',
      'en': 'Soybeans',
      'fr': 'Soja',
      'de': 'Soja',
      'es': 'Soja',
    },
    'latte': {
      'it': 'Latte e Lattosio',
      'en': 'Milk & Lactose',
      'fr': 'Lait et Lactose',
      'de': 'Milch & Laktose',
      'es': 'Leche y Lactosa',
    },
    'frutta_guscio': {
      'it': 'Frutta a guscio',
      'en': 'Tree Nuts',
      'fr': 'Fruits à coque',
      'de': 'Schalenfrüchte',
      'es': 'Frutos de cáscara',
    },
    'sedano': {
      'it': 'Sedano',
      'en': 'Celery',
      'fr': 'Céleri',
      'de': 'Sellerie',
      'es': 'Apio',
    },
    'senape': {
      'it': 'Senape',
      'en': 'Mustard',
      'fr': 'Moutarde',
      'de': 'Senf',
      'es': 'Mostaza',
    },
    'sesamo': {
      'it': 'Sesamo',
      'en': 'Sesame seeds',
      'fr': 'Graines de sésame',
      'de': 'Sesamsamen',
      'es': 'Granos de sésamo',
    },
    'solfiti': {
      'it': 'Anidride solforosa e solfiti',
      'en': 'Sulphur dioxide & sulphites',
      'fr': 'Anhydride sulfureux et sulfites',
      'de': 'Schwefeldioxid und Sulfite',
      'es': 'Dióxido de azufre y sulfitos',
    },
    'lupini': {
      'it': 'Lupini',
      'en': 'Lupin',
      'fr': 'Lupin',
      'de': 'Lupinen',
      'es': 'Altramuces',
    },
    'molluschi': {
      'it': 'Molluschi',
      'en': 'Molluscs',
      'fr': 'Mollusques',
      'de': 'Weichtiere',
      'es': 'Moluscos',
    },
  };

  /// Restituisce il nome dell'allergene tradotto
  static String getAllergeneLabel(String id, String lang) {
    final clean = id.trim().toLowerCase().replaceAll(' ', '_');
    if (_allergeniDictionary.containsKey(clean) &&
        _allergeniDictionary[clean]![lang] != null) {
      return _allergeniDictionary[clean]![lang]!;
    }
    return id;
  }
}
