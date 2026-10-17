import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import '/services/audit_log_service.dart';

class CestinoService {
  /// Controlla ed elimina definitivamente da Firebase Firestore e Firebase Storage
  /// tutti i piatti nel cestino che hanno superato i 7 giorni.
  static Future<int> pulisciPiattiScaduti({DocumentReference? ristoranteRef}) async {
    try {
      final now = DateTime.now();
      Query query = FirebaseFirestore.instance
          .collection('Piatti')
          .where('isCestinato', isEqualTo: true);

      if (ristoranteRef != null) {
        query = query.where('proprietario', isEqualTo: ristoranteRef);
      }

      final snapshot = await query.get();
      int eliminatiCount = 0;

      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>?;
        if (data == null) continue;

        DateTime? deadline;
        if (data['dataCestinamento'] is Timestamp) {
          deadline = (data['dataCestinamento'] as Timestamp).toDate();
        } else if (data['dataCestinamento'] is DateTime) {
          deadline = data['dataCestinamento'] as DateTime;
        }

        // Se non ha dataCestinamento, impostiamo la scadenza a 7 giorni da adesso per sicurezza
        if (deadline == null) {
          final nuovaScadenza = now.add(const Duration(days: 7));
          await doc.reference.update({
            'dataCestinamento': nuovaScadenza,
          });
          continue;
        }

        // Verifica se la data di scadenza (7 giorni dal cestinamento) è stata superata
        bool isScaduto = now.isAfter(deadline);

        if (isScaduto) {
          final nomePiatto = (data['Nome'] as String? ?? data['nome'] as String? ?? 'Piatto').trim();
          final foto = (data['Foto'] as String? ?? data['foto'] as String? ?? '').trim();

          // 1. Elimina la foto dallo storage di Firebase
          if (foto.isNotEmpty) {
            try {
              await FirebaseStorage.instance.refFromURL(foto).delete();
            } catch (e) {
              debugPrint('Nota: foto $foto già eliminata o non trovata in Storage: $e');
            }
          }

          // 2. Elimina il documento definitivo da Firestore
          await doc.reference.delete();
          eliminatiCount++;

          // 3. Registra l'azione automatica nell'audit log
          try {
            await AuditLogService.logAction(
              ristoranteRef: ristoranteRef,
              azione: "Eliminazione automatica piatto scaduto dal cestino",
              dettagli: "Il piatto '$nomePiatto' è rimasto nel cestino per oltre 7 giorni ed è stato eliminato definitivamente da Firebase.",
              tipoAzione: 'eliminazione_automatica',
              tipoEntita: 'piatto',
            );
          } catch (_) {}
        }
      }

      if (eliminatiCount > 0) {
        debugPrint('CestinoService: eliminati definitivamente $eliminatiCount piatti scaduti da Firebase.');
      }
      return eliminatiCount;
    } catch (e) {
      debugPrint('Errore durante la pulizia automatica dei piatti cestinati: $e');
      return 0;
    }
  }

  /// Calcola quanti giorni rimangono prima dell'eliminazione automatica definitiva.
  static int calcolaGiorniRimanenti(DateTime? dataCestinamento) {
    if (dataCestinamento == null) return 7;
    final now = DateTime.now();
    final difference = dataCestinamento.difference(now);
    if (difference.isNegative) return 0;
    
    // Se rimangono ore ma meno di 24, considera 1 giorno
    final giorni = difference.inDays;
    final oreResidue = difference.inHours % 24;
    return giorni + (oreResidue > 0 ? 1 : 0);
  }
}
