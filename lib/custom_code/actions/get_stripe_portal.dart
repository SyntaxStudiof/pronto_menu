// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:cloud_functions/cloud_functions.dart';
import 'package:url_launcher/url_launcher.dart'; // Pacchetto per aprire il browser nativo

Future<String?> getStripePortal(
  BuildContext context,
  String returnUrl,
) async {
  try {
    // 1. Chiamiamo la Cloud Function
    final result = await FirebaseFunctions.instanceFor(region: 'europe-west3')
        .httpsCallable('ext-firestore-stripe-payments-createPortalLink')
        .call({
      'returnUrl': returnUrl,
    });

    final String? portalUrl = result.data['url'] as String?;

    // 2. Se Stripe ci dà il link, lo apriamo DIRETTAMENTE nel browser esterno
    if (portalUrl != null && portalUrl.isNotEmpty) {
      final Uri url = Uri.parse(portalUrl);

      // Forziamo l'apertura nel browser esterno (Safari/Chrome) per evitare blocchi
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw 'URL del portale vuoto o non valido.';
    }

    return portalUrl;
  } catch (e) {
    // Se qualcosa fallisce, spunta la striscia rossa sul telefono
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Errore Stripe Portal: $e'),
        backgroundColor: Colors.red,
      ),
    );
    return null;
  }
}
