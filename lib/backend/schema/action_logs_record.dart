import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class ActionLogsRecord extends FirestoreRecord {
  ActionLogsRecord._(
    super.reference,
    super.data,
  ) {
    _initializeFields();
  }

  // "ristorante_ref" field.
  DocumentReference? _ristoranteRef;
  DocumentReference? get ristoranteRef => _ristoranteRef;
  bool hasRistoranteRef() => _ristoranteRef != null;

  // "ristorante_nome" field.
  String? _ristoranteNome;
  String get ristoranteNome => _ristoranteNome ?? '';
  bool hasRistoranteNome() => _ristoranteNome != null;

  // "utente_ref" field.
  DocumentReference? _utenteRef;
  DocumentReference? get utenteRef => _utenteRef;
  bool hasUtenteRef() => _utenteRef != null;

  // "utente_nome" field.
  String? _utenteNome;
  String get utenteNome => _utenteNome ?? '';
  bool hasUtenteNome() => _utenteNome != null;

  // "utente_email" field.
  String? _utenteEmail;
  String get utenteEmail => _utenteEmail ?? '';
  bool hasUtenteEmail() => _utenteEmail != null;

  // "azione" field.
  String? _azione;
  String get azione => _azione ?? '';
  bool hasAzione() => _azione != null;

  // "dettagli" field.
  String? _dettagli;
  String get dettagli => _dettagli ?? '';
  bool hasDettagli() => _dettagli != null;

  // "tipo_azione" field (delete, update, create, restore).
  String? _tipoAzione;
  String get tipoAzione => _tipoAzione ?? '';
  bool hasTipoAzione() => _tipoAzione != null;

  // "tipo_entita" field (categoria, piatto, cestino, dispensa, impostazioni).
  String? _tipoEntita;
  String get tipoEntita => _tipoEntita ?? '';
  bool hasTipoEntita() => _tipoEntita != null;

  // "data_ora" field.
  DateTime? _dataOra;
  DateTime? get dataOra => _dataOra;
  bool hasDataOra() => _dataOra != null;

  void _initializeFields() {
    _ristoranteRef = snapshotData['ristorante_ref'] as DocumentReference?;
    _ristoranteNome = snapshotData['ristorante_nome'] as String?;
    _utenteRef = snapshotData['utente_ref'] as DocumentReference?;
    _utenteNome = snapshotData['utente_nome'] as String?;
    _utenteEmail = snapshotData['utente_email'] as String?;
    _azione = snapshotData['azione'] as String?;
    _dettagli = snapshotData['dettagli'] as String?;
    _tipoAzione = snapshotData['tipo_azione'] as String?;
    _tipoEntita = snapshotData['tipo_entita'] as String?;
    _dataOra = snapshotData['data_ora'] as DateTime?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('ActionLogs');

  static Stream<ActionLogsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => ActionLogsRecord.fromSnapshot(s));

  static Future<ActionLogsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => ActionLogsRecord.fromSnapshot(s));

  static ActionLogsRecord fromSnapshot(DocumentSnapshot snapshot) =>
      ActionLogsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static ActionLogsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      ActionLogsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'ActionLogsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is ActionLogsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createActionLogsRecordData({
  DocumentReference? ristoranteRef,
  String? ristoranteNome,
  DocumentReference? utenteRef,
  String? utenteNome,
  String? utenteEmail,
  String? azione,
  String? dettagli,
  String? tipoAzione,
  String? tipoEntita,
  DateTime? dataOra,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'ristorante_ref': ristoranteRef,
      'ristorante_nome': ristoranteNome,
      'utente_ref': utenteRef,
      'utente_nome': utenteNome,
      'utente_email': utenteEmail,
      'azione': azione,
      'dettagli': dettagli,
      'tipo_azione': tipoAzione,
      'tipo_entita': tipoEntita,
      'data_ora': dataOra,
    }.withoutNulls,
  );

  return firestoreData;
}

class ActionLogsRecordDocumentEquality implements Equality<ActionLogsRecord> {
  const ActionLogsRecordDocumentEquality();

  @override
  bool equals(ActionLogsRecord? e1, ActionLogsRecord? e2) {
    return e1?.ristoranteRef == e2?.ristoranteRef &&
        e1?.ristoranteNome == e2?.ristoranteNome &&
        e1?.utenteRef == e2?.utenteRef &&
        e1?.utenteNome == e2?.utenteNome &&
        e1?.utenteEmail == e2?.utenteEmail &&
        e1?.azione == e2?.azione &&
        e1?.dettagli == e2?.dettagli &&
        e1?.tipoAzione == e2?.tipoAzione &&
        e1?.tipoEntita == e2?.tipoEntita &&
        e1?.dataOra == e2?.dataOra;
  }

  @override
  int hash(ActionLogsRecord? e) => const ListEquality().hash([
        e?.ristoranteRef,
        e?.ristoranteNome,
        e?.utenteRef,
        e?.utenteNome,
        e?.utenteEmail,
        e?.azione,
        e?.dettagli,
        e?.tipoAzione,
        e?.tipoEntita,
        e?.dataOra
      ]);

  @override
  bool isValidKey(Object? o) => o is ActionLogsRecord;
}
