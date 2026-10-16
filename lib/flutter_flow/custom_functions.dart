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
    risultato.add('(N.$quantita) $piatto');
  });

  return risultato;
}

List<String>? raggruppaPiattiDaStringa(String? testoPiattiCompleto) {
  if (testoPiattiCompleto == null || testoPiattiCompleto.isEmpty) {
    return [];
  }

  // Dividiamo il testo rispettando eventuali modifiche racchiuse tra parentesi
  // (es. "Margherita (+ Prosciutto, Funghi), Marinara")
  List<String> listaPiattiGrezza = [];
  int parenthesisDepth = 0;
  StringBuffer current = StringBuffer();

  for (int i = 0; i < testoPiattiCompleto.length; i++) {
    final char = testoPiattiCompleto[i];
    if (char == '(' || char == '[') {
      parenthesisDepth++;
      current.write(char);
    } else if (char == ')' || char == ']') {
      if (parenthesisDepth > 0) parenthesisDepth--;
      current.write(char);
    } else if (char == ',' && parenthesisDepth == 0) {
      listaPiattiGrezza.add(current.toString().trim());
      current.clear();
      if (i + 1 < testoPiattiCompleto.length && testoPiattiCompleto[i + 1] == ' ') {
        i++;
      }
    } else {
      current.write(char);
    }
  }
  if (current.isNotEmpty && current.toString().trim().isNotEmpty) {
    listaPiattiGrezza.add(current.toString().trim());
  }

  Map<String, int> conteggio = {};

  for (String piatto in listaPiattiGrezza) {
    String piattoPulito = piatto.trim();
    if (piattoPulito.isNotEmpty) {
      conteggio[piattoPulito] = (conteggio[piattoPulito] ?? 0) + 1;
    }
  }

  List<String> risultato = [];
  conteggio.forEach((piatto, quantita) {
    risultato.add('(N.$quantita) $piatto');
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
