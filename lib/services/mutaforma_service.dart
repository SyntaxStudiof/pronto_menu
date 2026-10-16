import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

class FasciaMutaforma {
  final String id;
  String nome;
  String orarioInizio; // Formato "HH:mm" (24h)
  String orarioFine; // Formato "HH:mm" (24h)
  List<int> giorni; // 1 = Lunedì ... 7 = Domenica (DateTime.weekday)
  List<String> categoriaIds; // ID delle categorie visibili

  String get oraInizio => orarioInizio;
  String get oraFine => orarioFine;
  List<int> get giorniAttivi => giorni;

  FasciaMutaforma({
    required this.id,
    required this.nome,
    required this.orarioInizio,
    required this.orarioFine,
    List<int>? giorni,
    List<String>? categoriaIds,
  })  : giorni = giorni ?? [1, 2, 3, 4, 5, 6, 7],
        categoriaIds = categoriaIds ?? [];

  Map<String, dynamic> toMap() => {
        'id': id,
        'nome': nome,
        'orario_inizio': orarioInizio,
        'orario_fine': orarioFine,
        'giorni': giorni,
        'categoria_ids': categoriaIds,
      };

  factory FasciaMutaforma.fromMap(Map<String, dynamic> map) {
    return FasciaMutaforma(
      id: map['id']?.toString() ?? '',
      nome: map['nome']?.toString() ?? '',
      orarioInizio: map['orario_inizio']?.toString() ?? '12:00',
      orarioFine: map['orario_fine']?.toString() ?? '15:00',
      giorni: (map['giorni'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          [1, 2, 3, 4, 5, 6, 7],
      categoriaIds: (map['categoria_ids'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  /// Verifica se questa fascia oraria è attiva nel momento indicato (default: adesso).
  bool isAttivaOra([DateTime? now]) {
    final dt = now ?? DateTime.now();
    if (!giorni.contains(dt.weekday)) {
      return false;
    }

    final currentMin = dt.hour * 60 + dt.minute;
    final startMin = _parseMinutes(orarioInizio);
    final endMin = _parseMinutes(orarioFine);

    if (startMin == null || endMin == null) {
      return false;
    }

    if (startMin <= endMin) {
      // Fascia nello stesso giorno (es. 12:00 -> 15:00)
      return currentMin >= startMin && currentMin < endMin;
    } else {
      // Fascia che supera la mezzanotte (es. 22:00 -> 03:00)
      return currentMin >= startMin || currentMin < endMin;
    }
  }

  /// Minuti dall'inizio del giorno (0..1439)
  static int? _parseMinutes(String timeStr) {
    final parts = timeStr.split(':');
    if (parts.length < 2) return null;
    final h = int.tryParse(parts[0]) ?? 0;
    final m = int.tryParse(parts[1]) ?? 0;
    return h * 60 + m;
  }

  /// Stringa riassuntiva dei giorni attivi
  String getGiorniLabel() => MutaformaService.formatGiorni(giorni);
}

class MutaformaService {
  /// Formatta una lista di numeri giorno (1..7) in etichetta leggibile
  static String formatGiorni(List<int> giorni) {
    if (giorni.length == 7) return 'Tutti i giorni';
    if (giorni.length == 5 &&
        giorni.contains(1) &&
        giorni.contains(2) &&
        giorni.contains(3) &&
        giorni.contains(4) &&
        giorni.contains(5)) {
      return 'Lun - Ven';
    }
    if (giorni.length == 2 && giorni.contains(6) && giorni.contains(7)) {
      return 'Fine settimana (Sab - Dom)';
    }

    const dayNames = {
      1: 'Lun',
      2: 'Mar',
      3: 'Mer',
      4: 'Gio',
      5: 'Ven',
      6: 'Sab',
      7: 'Dom',
    };
    final sorted = [...giorni]..sort();
    return sorted.map((d) => dayNames[d] ?? '').where((s) => s.isNotEmpty).join(', ');
  }

  /// Decodifica la lista di fasce orarie da stringa JSON
  static List<FasciaMutaforma> decodeFasce(String? rawJson) {
    if (rawJson == null || rawJson.trim().isEmpty) {
      return [];
    }
    try {
      final decoded = jsonDecode(rawJson);
      if (decoded is List) {
        return decoded
            .map((e) => FasciaMutaforma.fromMap(Map<String, dynamic>.from(e as Map)))
            .toList();
      }
    } catch (_) {}
    return [];
  }

  /// Codifica la lista di fasce orarie in stringa JSON
  static String encodeFasce(List<FasciaMutaforma> fasce) {
    return jsonEncode(fasce.map((f) => f.toMap()).toList());
  }

  /// Salva le fasce orarie nel documento del ristorante
  static Future<void> salvaFasce({
    required DocumentReference userRef,
    required List<FasciaMutaforma> fasce,
  }) async {
    await userRef.update({
      'fasce_mutaforma': encodeFasce(fasce),
    });
  }

  /// Attiva o disattiva il Menù Mutaforma per il ristorante
  static Future<void> toggleMutaforma({
    required DocumentReference userRef,
    required bool attivo,
  }) async {
    await userRef.update({
      'menu_mutaforma_attivo': attivo,
    });
  }

  /// Restituisce la fascia attualmente attiva (se presente)
  static FasciaMutaforma? getFasciaAttiva(List<FasciaMutaforma> fasce, [DateTime? now]) {
    final dt = now ?? DateTime.now();
    for (final f in fasce) {
      if (f.isAttivaOra(dt)) {
        return f;
      }
    }
    return null;
  }

  /// Restituisce la prossima fascia oraria che aprirà (se nessuna è attiva ora)
  static FasciaMutaforma? getProssimaFascia(List<FasciaMutaforma> fasce, [DateTime? now]) {
    if (fasce.isEmpty) return null;
    final dt = now ?? DateTime.now();
    final currentMin = dt.hour * 60 + dt.minute;

    FasciaMutaforma? candidate;
    int minDiff = 999999;

    for (final f in fasce) {
      if (!f.giorni.contains(dt.weekday)) continue;
      final startMin = FasciaMutaforma._parseMinutes(f.orarioInizio);
      if (startMin == null) continue;

      int diff = startMin - currentMin;
      if (diff <= 0) {
        diff += 1440; // Prossimo giorno
      }
      if (diff < minDiff) {
        minDiff = diff;
        candidate = f;
      }
    }

    return candidate ?? fasce.firstOrNull;
  }
}
