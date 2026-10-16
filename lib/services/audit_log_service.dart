import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import 'package:flutter/foundation.dart';

class AuditLogService {
  /// Registra un'azione critica effettuata nell'app per la cronologia di audit dell'amministratore
  static Future<void> logAction({
    required String azione,
    required String dettagli,
    required String tipoAzione, // 'delete', 'update', 'create', 'restore'
    required String tipoEntita, // 'categoria', 'piatto', 'cestino', 'dispensa', 'menu', 'impostazioni'
    DocumentReference? ristoranteRef,
    String? ristoranteNome,
  }) async {
    try {
      final effectiveRistoranteRef = ristoranteRef ?? currentUserReference;

      String nomeLocale = ristoranteNome ?? '';
      if (nomeLocale.isEmpty && currentUserDocument != null) {
        if (currentUserDocument!.displayName.isNotEmpty) {
          nomeLocale = currentUserDocument!.displayName;
        } else if (currentUserDocument!.nome.isNotEmpty) {
          nomeLocale = '${currentUserDocument!.nome} ${currentUserDocument!.cognome}'.trim();
        }
      }
      if (nomeLocale.isEmpty) {
        nomeLocale = 'Ristorante';
      }

      final utenteNome = currentUserDisplayName.isNotEmpty
          ? currentUserDisplayName
          : (currentUserEmail.isNotEmpty ? currentUserEmail.split('@').first : 'Utente');

      await ActionLogsRecord.collection.add(createActionLogsRecordData(
        ristoranteRef: effectiveRistoranteRef,
        ristoranteNome: nomeLocale,
        utenteRef: currentUserReference,
        utenteNome: utenteNome,
        utenteEmail: currentUserEmail,
        azione: azione,
        dettagli: dettagli,
        tipoAzione: tipoAzione,
        tipoEntita: tipoEntita,
        dataOra: DateTime.now(),
      ));
    } catch (e) {
      // Ignora silenziosamente errori per non bloccare l'esperienza utente
      debugPrint('Errore durante la registrazione dell\'audit log: $e');
    }
  }
}
