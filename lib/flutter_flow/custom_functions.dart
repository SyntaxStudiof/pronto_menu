import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'lat_lng.dart';
import 'place.dart';
import 'uploaded_file.dart';
import '/backend/backend.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/auth/firebase_auth/auth_util.dart';

double? sottraiPrezzo(
  double? totale,
  double? prezzoPiatto,
) {
  // Usiamo ?? 0 per dire: "se il valore è nullo, usa zero"
  return (totale ?? 0.0) - (prezzoPiatto ?? 0.0);
}

List<String>? raggruppaPiatti(List<String>? listaPiattiOriginale) {
  if (listaPiattiOriginale == null || listaPiattiOriginale.isEmpty) {
    return [];
  }

  Map<String, int> conteggio = {};

  for (String piatto in listaPiattiOriginale) {
    conteggio[piatto] = (conteggio[piatto] ?? 0) + 1;
  }

  List<String> risultato = [];
  conteggio.forEach((piatto, quantita) {
    risultato.add('$quantita $piatto');
  });

  return risultato;
}

List<String>? raggruppaPiattiDaStringa(String? testoPiattiCompleto) {
  if (testoPiattiCompleto == null || testoPiattiCompleto.isEmpty) {
    return [];
  }

  // Dividiamo il testo lungo usando la virgola e lo spazio come separatore
  // (es. "Margherita, Salumi" diventa ["Margherita", "Salumi"])
  List<String> listaPiattiGrezza = testoPiattiCompleto.split(', ');

  Map<String, int> conteggio = {};

  for (String piatto in listaPiattiGrezza) {
    // Rimuoviamo eventuali spazi extra e puliamo il testo
    String piattoPulito = piatto.trim();
    if (piattoPulito.isNotEmpty) {
      conteggio[piattoPulito] = (conteggio[piattoPulito] ?? 0) + 1;
    }
  }

  // Creiamo la lista finale raggruppata (es. "2 Margherita")
  List<String> risultato = [];
  conteggio.forEach((piatto, quantita) {
    risultato.add('$quantita $piatto');
  });

  return risultato;
}

String? unisciNomiCarrello(List<String>? listaNomi) {
  if (listaNomi == null || listaNomi.isEmpty) {
    return '';
  }
  // Unisce tutti i nomi della lista mettendoci in mezzo una virgola e uno spazio
  return listaNomi.join(', ');
}

double? formattaPrezzo(String? inputPrezzo) {
  if (inputPrezzo == null || inputPrezzo.trim().isEmpty) {
    return 0.0;
  }
  return double.tryParse(inputPrezzo.replaceAll(',', '.')) ?? 0.0;
}

DateTime aggiungiSetteGiorni(DateTime dataDiOggi) {
  return dataDiOggi.add(Duration(days: 7));
}

List<UsersRecord> cercaRistoranti(
  List<UsersRecord> listaCompleta,
  String? testoRicerca,
) {
  if (testoRicerca == null || testoRicerca.isEmpty) {
    return listaCompleta;
  }

  final testo = testoRicerca.toLowerCase();

  return listaCompleta.where((utente) {
    final email = utente.email?.toLowerCase() ?? '';
    final nome = utente.displayName?.toLowerCase() ?? '';

    return email.contains(testo) || nome.contains(testo);
  }).toList();
}

bool? isPremiumAttivo(
  bool? isPremium,
  DateTime? expiryDate,
) {
  if (isPremium == null || !isPremium) return false;
  if (expiryDate == null) return true;
  return expiryDate.isAfter(DateTime.now());
}
