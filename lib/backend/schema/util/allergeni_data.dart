import 'package:flutter/material.dart';
import '../piatti_record.dart';

class InfoFiltroMagico {
  final String id;
  final String label;
  final String emoji;
  final String descrizione;
  final Color badgeColor;

  const InfoFiltroMagico({
    required this.id,
    required this.label,
    required this.emoji,
    required this.descrizione,
    required this.badgeColor,
  });
}

class InfoAllergene {
  final String id;
  final String label;
  final String emoji;
  final String note;

  const InfoAllergene({
    required this.id,
    required this.label,
    required this.emoji,
    required this.note,
  });
}

class AllergeniData {
  static const List<InfoFiltroMagico> filtriMagici = [
    InfoFiltroMagico(
      id: 'senza_glutine',
      label: 'Senza Glutine',
      emoji: '🌾',
      descrizione: 'Privo di glutine o adatto a celiaci',
      badgeColor: Color(0xFF2E7D32),
    ),
    InfoFiltroMagico(
      id: 'senza_lattosio',
      label: 'Senza Lattosio',
      emoji: '🥛',
      descrizione: 'Privo di lattosio e latte vaccino',
      badgeColor: Color(0xFF0277BD),
    ),
    InfoFiltroMagico(
      id: 'vegetariano',
      label: 'Vegetariano',
      emoji: '🥗',
      descrizione: 'Senza carne o pesce, con possibili derivati',
      badgeColor: Color(0xFF388E3C),
    ),
    InfoFiltroMagico(
      id: 'vegano',
      label: 'Vegano',
      emoji: '🌱',
      descrizione: '100% vegetale, nessun ingrediente o derivato animale',
      badgeColor: Color(0xFF1B5E20),
    ),
  ];

  static const List<InfoAllergene> allergeniObbligatori = [
    InfoAllergene(
      id: 'glutine',
      label: 'Glutine',
      emoji: '🌾',
      note: 'Grano, segale, orzo, avena, farro, kamut',
    ),
    InfoAllergene(
      id: 'crostacei',
      label: 'Crostacei',
      emoji: '🦐',
      note: 'Gamberi, scampi, aragoste, granchi',
    ),
    InfoAllergene(
      id: 'uova',
      label: 'Uova',
      emoji: '🥚',
      note: 'Uova e prodotti derivati',
    ),
    InfoAllergene(
      id: 'pesce',
      label: 'Pesce',
      emoji: '🐟',
      note: 'Pesce e prodotti derivati',
    ),
    InfoAllergene(
      id: 'arachidi',
      label: 'Arachidi',
      emoji: '🥜',
      note: 'Arachidi e derivati',
    ),
    InfoAllergene(
      id: 'soia',
      label: 'Soia',
      emoji: '🌱',
      note: 'Soia e derivati',
    ),
    InfoAllergene(
      id: 'latte',
      label: 'Latte e Lattosio',
      emoji: '🥛',
      note: 'Latte, formaggi, burro e derivati',
    ),
    InfoAllergene(
      id: 'frutta_guscio',
      label: 'Frutta a guscio',
      emoji: '🌰',
      note: 'Mandorle, nocciole, noci, anacardi, pistacchi',
    ),
    InfoAllergene(
      id: 'sedano',
      label: 'Sedano',
      emoji: '🥬',
      note: 'Sedano e derivati',
    ),
    InfoAllergene(
      id: 'senape',
      label: 'Senape',
      emoji: '🟡',
      note: 'Senape e derivati',
    ),
    InfoAllergene(
      id: 'sesamo',
      label: 'Sesamo',
      emoji: '🥯',
      note: 'Semi di sesamo e derivati',
    ),
    InfoAllergene(
      id: 'solfiti',
      label: 'Anidride solforosa e solfiti',
      emoji: '🍷',
      note: 'In concentrazioni superiori a 10 mg/kg o 10 mg/l',
    ),
    InfoAllergene(
      id: 'lupini',
      label: 'Lupini',
      emoji: '🌿',
      note: 'Lupini e derivati',
    ),
    InfoAllergene(
      id: 'molluschi',
      label: 'Molluschi',
      emoji: '🐙',
      note: 'Cozze, vongole, polpi, calamari, seppie',
    ),
  ];

  static InfoFiltroMagico? getFiltroMagicoById(String id) {
    final cleanId = id.trim().toLowerCase().replaceAll(' ', '_');
    for (final item in filtriMagici) {
      if (item.id == cleanId ||
          item.label.toLowerCase() == cleanId ||
          cleanId.contains(item.id)) {
        return item;
      }
    }
    return null;
  }

  static InfoAllergene? getAllergeneById(String id) {
    final cleanId = id.trim().toLowerCase().replaceAll(' ', '_');
    for (final item in allergeniObbligatori) {
      if (item.id == cleanId ||
          item.label.toLowerCase() == cleanId ||
          cleanId.contains(item.id)) {
        return item;
      }
    }
    return null;
  }

  static bool dishHasFiltro(PiattiRecord dish, String filtroId) {
    final targetId = filtroId.trim().toLowerCase().replaceAll(' ', '_');
    for (final tag in dish.intolleranze) {
      final cleanTag = tag.trim().toLowerCase().replaceAll(' ', '_');
      if (cleanTag == targetId || cleanTag.contains(targetId) || targetId.contains(cleanTag)) {
        return true;
      }
    }
    return false;
  }

  static bool dishHasAllergene(PiattiRecord dish, String allergeneId) {
    final targetId = allergeneId.trim().toLowerCase().replaceAll(' ', '_');
    for (final all in dish.allergeni) {
      final cleanAll = all.trim().toLowerCase().replaceAll(' ', '_');
      if (cleanAll == targetId || cleanAll.contains(targetId) || targetId.contains(cleanAll)) {
        return true;
      }
    }
    return false;
  }

  static bool dishMatchesFilters({
    required PiattiRecord dish,
    required Set<String> filtriMagici,
    required Set<String> allergeniEsclusi,
  }) {
    for (final filtro in filtriMagici) {
      if (!dishHasFiltro(dish, filtro)) {
        return false;
      }
    }
    for (final all in allergeniEsclusi) {
      if (dishHasAllergene(dish, all)) {
        return false;
      }
    }
    return true;
  }
}
