// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

Future svuotaCestinoMassivo(DocumentReference? utenteLoggato) async {
  QuerySnapshot querySnapshot = await FirebaseFirestore.instance
      .collection('Piatti')
      .where('proprietario', isEqualTo: utenteLoggato)
      .where('isCestinato', isEqualTo: true)
      .get();

  for (DocumentSnapshot doc in querySnapshot.docs) {
    try {
      final data = doc.data() as Map<String, dynamic>?;
      final foto = (data?['Foto'] as String? ?? data?['foto'] as String? ?? '').trim();
      if (foto.isNotEmpty) {
        await FirebaseStorage.instance.refFromURL(foto).delete();
      }
    } catch (_) {}
    await doc.reference.delete();
  }
}
