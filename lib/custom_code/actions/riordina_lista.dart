// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

Future<List<CategoriesRecord>> riordinaLista(
  List<CategoriesRecord>? lista,
  int oldIndex,
  int newIndex,
) async {
  // Se la lista è vuota, restituisce una lista vuota
  if (lista == null || lista.isEmpty) {
    return [];
  }

  // Aggiustamento necessario in Flutter per lo spostamento verso il basso
  if (oldIndex < newIndex) {
    newIndex -= 1;
  }

  // Rimuove l'elemento dalla vecchia posizione
  final item = lista.removeAt(oldIndex);

  // Lo inserisce nella nuova posizione
  lista.insert(newIndex, item);

  // Restituisce la lista con il nuovo ordine
  return lista;
}
