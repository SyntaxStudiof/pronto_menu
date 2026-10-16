import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class TicketsRecord extends FirestoreRecord {
  TicketsRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "titolo" field.
  String? _titolo;
  String get titolo => _titolo ?? '';
  bool hasTitolo() => _titolo != null;

  // "descrizione" field.
  String? _descrizione;
  String get descrizione => _descrizione ?? '';
  bool hasDescrizione() => _descrizione != null;

  // "ristoratore_ref" field.
  DocumentReference? _ristoratoreRef;
  DocumentReference? get ristoratoreRef => _ristoratoreRef;
  bool hasRistoratoreRef() => _ristoratoreRef != null;

  // "data_creazione" field.
  DateTime? _dataCreazione;
  DateTime? get dataCreazione => _dataCreazione;
  bool hasDataCreazione() => _dataCreazione != null;

  // "stato" field.
  String? _stato;
  String get stato => _stato ?? '';
  bool hasStato() => _stato != null;

  // "risposta_admin" field.
  String? _rispostaAdmin;
  String get rispostaAdmin => _rispostaAdmin ?? '';
  bool hasRispostaAdmin() => _rispostaAdmin != null;

  // "risposta_letta" field.
  bool? _rispostaLetta;
  bool get rispostaLetta => _rispostaLetta ?? false;
  bool hasRispostaLetta() => _rispostaLetta != null;

  void _initializeFields() {
    _titolo = snapshotData['titolo'] as String?;
    _descrizione = snapshotData['descrizione'] as String?;
    _ristoratoreRef = snapshotData['ristoratore_ref'] as DocumentReference?;
    _dataCreazione = snapshotData['data_creazione'] as DateTime?;
    _stato = snapshotData['stato'] as String?;
    _rispostaAdmin = snapshotData['risposta_admin'] as String?;
    _rispostaLetta = snapshotData['risposta_letta'] as bool?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('Tickets');

  static Stream<TicketsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => TicketsRecord.fromSnapshot(s));

  static Future<TicketsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => TicketsRecord.fromSnapshot(s));

  static TicketsRecord fromSnapshot(DocumentSnapshot snapshot) =>
      TicketsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static TicketsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      TicketsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'TicketsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is TicketsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createTicketsRecordData({
  String? titolo,
  String? descrizione,
  DocumentReference? ristoratoreRef,
  DateTime? dataCreazione,
  String? stato,
  String? rispostaAdmin,
  bool? rispostaLetta,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'titolo': titolo,
      'descrizione': descrizione,
      'ristoratore_ref': ristoratoreRef,
      'data_creazione': dataCreazione,
      'stato': stato,
      'risposta_admin': rispostaAdmin,
      'risposta_letta': rispostaLetta,
    }.withoutNulls,
  );

  return firestoreData;
}

class TicketsRecordDocumentEquality implements Equality<TicketsRecord> {
  const TicketsRecordDocumentEquality();

  @override
  bool equals(TicketsRecord? e1, TicketsRecord? e2) {
    return e1?.titolo == e2?.titolo &&
        e1?.descrizione == e2?.descrizione &&
        e1?.ristoratoreRef == e2?.ristoratoreRef &&
        e1?.dataCreazione == e2?.dataCreazione &&
        e1?.stato == e2?.stato &&
        e1?.rispostaAdmin == e2?.rispostaAdmin &&
        e1?.rispostaLetta == e2?.rispostaLetta;
  }

  @override
  int hash(TicketsRecord? e) => const ListEquality().hash([
        e?.titolo,
        e?.descrizione,
        e?.ristoratoreRef,
        e?.dataCreazione,
        e?.stato,
        e?.rispostaAdmin,
        e?.rispostaLetta
      ]);

  @override
  bool isValidKey(Object? o) => o is TicketsRecord;
}
