// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:cloud_firestore/cloud_firestore.dart';

Future salvaOrdineCategorie(List<DocumentReference>? listaRef) async {
  // Se la lista è vuota, ci fermiamo subito per evitare errori
  if (listaRef == null || listaRef.isEmpty) {
    return;
  }

  // Creiamo il pacco unico (batch) per Firebase
  final batch = FirebaseFirestore.instance.batch();

  // Passiamo in rassegna la lista partendo dal primo (che ha indice 0)
  for (int i = 0; i < listaRef.length; i++) {
    // Aggiorniamo il campo ordine_categoria con la sua posizione + 1
    batch.update(listaRef[i], {'ordine_categoria': i + 1});
  }

  // Inviamo tutto a Firebase in un millisecondo!
  await batch.commit();
}
