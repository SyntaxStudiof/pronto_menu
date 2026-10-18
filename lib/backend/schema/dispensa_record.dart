import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class DispensaRecord extends FirestoreRecord {
  DispensaRecord._(
    super.reference,
    super.data,
  ) {
    _initializeFields();
  }

  // "nome" field.
  String? _nome;
  String get nome => _nome ?? '';
  bool hasNome() => _nome != null;

  // "quantita" field.
  double? _quantita;
  double get quantita => _quantita ?? 0.0;
  bool hasQuantita() => _quantita != null;

  // "unita_misura" field (kg, g, l, ml, pz, etc.)
  String? _unitaMisura;
  String get unitaMisura => _unitaMisura ?? 'pz';
  bool hasUnitaMisura() => _unitaMisura != null;

  // "soglia_minima" field (quantità sotto la quale segnalare "in esaurimento")
  double? _sogliaMinima;
  double get sogliaMinima => _sogliaMinima ?? 0.0;
  bool hasSogliaMinima() => _sogliaMinima != null;

  // "esaurito" field (true se l'ingrediente è finito)
  bool? _esaurito;
  bool get esaurito => _esaurito ?? false;
  bool hasEsaurito() => _esaurito != null;

  // "sta_per_finire" field (true se in esaurimento)
  bool? _staPerFinire;
  bool get staPerFinire => _staPerFinire ?? false;
  bool hasStaPerFinire() => _staPerFinire != null;

  // "proprietario" field (DocumentReference al ristorante)
  DocumentReference? _proprietario;
  DocumentReference? get proprietario => _proprietario;
  bool hasProprietario() => _proprietario != null;

  // "data_aggiornamento" field
  DateTime? _dataAggiornamento;
  DateTime? get dataAggiornamento => _dataAggiornamento;
  bool hasDataAggiornamento() => _dataAggiornamento != null;

  // "note" field
  String? _note;
  String get note => _note ?? '';
  bool hasNote() => _note != null;

  // "prezzo" field (costo extra per aggiunta cliente)
  double? _prezzo;
  double get prezzo => _prezzo ?? 0.0;
  bool hasPrezzo() => _prezzo != null;

  // "disponibile_come_aggiunta" field (true se ordinabile dal cliente come extra)
  bool? _disponibileComeAggiunta;
  bool get disponibileComeAggiunta => _disponibileComeAggiunta ?? false;
  bool hasDisponibileComeAggiunta() => _disponibileComeAggiunta != null;

  // "tutte_le_categorie" field (true se l'aggiunta vale per tutte le categorie del menu)
  bool? _tutteLeCategorie;
  bool get tutteLeCategorie => _tutteLeCategorie ?? true;
  bool hasTutteLeCategorie() => _tutteLeCategorie != null;

  // "categorie_compatibili" field (lista ID/nomi categorie in cui l'ingrediente è aggiungibile)
  List<String>? _categorieCompatibili;
  List<String> get categorieCompatibili => _categorieCompatibili ?? const [];
  bool hasCategorieCompatibili() => _categorieCompatibili != null;

  void _initializeFields() {
    _nome = snapshotData['nome'] as String?;
    _quantita = castToType<double>(snapshotData['quantita']);
    _unitaMisura = snapshotData['unita_misura'] as String?;
    _sogliaMinima = castToType<double>(snapshotData['soglia_minima']);
    _esaurito = snapshotData['esaurito'] as bool?;
    _staPerFinire = snapshotData['sta_per_finire'] as bool?;
    _proprietario = snapshotData['proprietario'] as DocumentReference?;
    _dataAggiornamento = snapshotData['data_aggiornamento'] as DateTime?;
    _note = snapshotData['note'] as String?;
    _prezzo = castToType<double>(snapshotData['prezzo']);
    _disponibileComeAggiunta =
        snapshotData['disponibile_come_aggiunta'] as bool?;
    _tutteLeCategorie = snapshotData['tutte_le_categorie'] as bool?;
    _categorieCompatibili = getDataList(snapshotData['categorie_compatibili']);
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('dispensa');

  static Stream<DispensaRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => DispensaRecord.fromSnapshot(s));

  static Future<DispensaRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => DispensaRecord.fromSnapshot(s));

  static DispensaRecord fromSnapshot(DocumentSnapshot snapshot) =>
      DispensaRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static DispensaRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      DispensaRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'DispensaRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is DispensaRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createDispensaRecordData({
  String? nome,
  double? quantita,
  String? unitaMisura,
  double? sogliaMinima,
  bool? esaurito,
  bool? staPerFinire,
  DocumentReference? proprietario,
  DateTime? dataAggiornamento,
  String? note,
  double? prezzo,
  bool? disponibileComeAggiunta,
  bool? tutteLeCategorie,
  List<String>? categorieCompatibili,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'nome': nome,
      'quantita': quantita,
      'unita_misura': unitaMisura,
      'soglia_minima': sogliaMinima,
      'esaurito': esaurito,
      'sta_per_finire': staPerFinire,
      'proprietario': proprietario,
      'data_aggiornamento': dataAggiornamento,
      'note': note,
      'prezzo': prezzo,
      'disponibile_come_aggiunta': disponibileComeAggiunta,
      'tutte_le_categorie': tutteLeCategorie,
      'categorie_compatibili': categorieCompatibili,
    }.withoutNulls,
  );

  return firestoreData;
}

class DispensaRecordDocumentEquality implements Equality<DispensaRecord> {
  const DispensaRecordDocumentEquality();

  @override
  bool equals(DispensaRecord? e1, DispensaRecord? e2) {
    const listEquality = ListEquality();
    return e1?.nome == e2?.nome &&
        e1?.quantita == e2?.quantita &&
        e1?.unitaMisura == e2?.unitaMisura &&
        e1?.sogliaMinima == e2?.sogliaMinima &&
        e1?.esaurito == e2?.esaurito &&
        e1?.staPerFinire == e2?.staPerFinire &&
        e1?.proprietario == e2?.proprietario &&
        e1?.dataAggiornamento == e2?.dataAggiornamento &&
        e1?.note == e2?.note &&
        e1?.prezzo == e2?.prezzo &&
        e1?.disponibileComeAggiunta == e2?.disponibileComeAggiunta &&
        e1?.tutteLeCategorie == e2?.tutteLeCategorie &&
        listEquality.equals(e1?.categorieCompatibili, e2?.categorieCompatibili);
  }

  @override
  int hash(DispensaRecord? e) => const ListEquality().hash([
        e?.nome,
        e?.quantita,
        e?.unitaMisura,
        e?.sogliaMinima,
        e?.esaurito,
        e?.staPerFinire,
        e?.proprietario,
        e?.dataAggiornamento,
        e?.note,
        e?.prezzo,
        e?.disponibileComeAggiunta,
        e?.tutteLeCategorie,
        e?.categorieCompatibili,
      ]);

  @override
  bool isValidKey(Object? o) => o is DispensaRecord;
}
