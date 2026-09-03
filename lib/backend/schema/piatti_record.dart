import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class PiattiRecord extends FirestoreRecord {
  PiattiRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "Nome" field.
  String? _nome;
  String get nome => _nome ?? '';
  bool hasNome() => _nome != null;

  // "Prezzo" field.
  double? _prezzo;
  double get prezzo => _prezzo ?? 0.0;
  bool hasPrezzo() => _prezzo != null;

  // "Categoria" field.
  String? _categoria;
  String get categoria => _categoria ?? '';
  bool hasCategoria() => _categoria != null;

  // "proprietario" field.
  DocumentReference? _proprietario;
  DocumentReference? get proprietario => _proprietario;
  bool hasProprietario() => _proprietario != null;

  // "ingredienti" field.
  String? _ingredienti;
  String get ingredienti => _ingredienti ?? '';
  bool hasIngredienti() => _ingredienti != null;

  // "descrizione" field.
  String? _descrizione;
  String get descrizione => _descrizione ?? '';
  bool hasDescrizione() => _descrizione != null;

  // "foto" field.
  String? _foto;
  String get foto => _foto ?? '';
  bool hasFoto() => _foto != null;

  // "isCestinato" field.
  bool? _isCestinato;
  bool get isCestinato => _isCestinato ?? false;
  bool hasIsCestinato() => _isCestinato != null;

  // "dataCestinamento" field.
  DateTime? _dataCestinamento;
  DateTime? get dataCestinamento => _dataCestinamento;
  bool hasDataCestinamento() => _dataCestinamento != null;

  // "sottocategoria_ref" field.
  DocumentReference? _sottocategoriaRef;
  DocumentReference? get sottocategoriaRef => _sottocategoriaRef;
  bool hasSottocategoriaRef() => _sottocategoriaRef != null;

  void _initializeFields() {
    _nome = snapshotData['Nome'] as String?;
    _prezzo = castToType<double>(snapshotData['Prezzo']);
    _categoria = snapshotData['Categoria'] as String?;
    _proprietario = snapshotData['proprietario'] as DocumentReference?;
    _ingredienti = snapshotData['ingredienti'] as String?;
    _descrizione = snapshotData['descrizione'] as String?;
    _foto = snapshotData['foto'] as String?;
    _isCestinato = snapshotData['isCestinato'] as bool?;
    _dataCestinamento = snapshotData['dataCestinamento'] as DateTime?;
    _sottocategoriaRef =
        snapshotData['sottocategoria_ref'] as DocumentReference?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('Piatti');

  static Stream<PiattiRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => PiattiRecord.fromSnapshot(s));

  static Future<PiattiRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => PiattiRecord.fromSnapshot(s));

  static PiattiRecord fromSnapshot(DocumentSnapshot snapshot) => PiattiRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static PiattiRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      PiattiRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'PiattiRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is PiattiRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createPiattiRecordData({
  String? nome,
  double? prezzo,
  String? categoria,
  DocumentReference? proprietario,
  String? ingredienti,
  String? descrizione,
  String? foto,
  bool? isCestinato,
  DateTime? dataCestinamento,
  DocumentReference? sottocategoriaRef,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'Nome': nome,
      'Prezzo': prezzo,
      'Categoria': categoria,
      'proprietario': proprietario,
      'ingredienti': ingredienti,
      'descrizione': descrizione,
      'foto': foto,
      'isCestinato': isCestinato,
      'dataCestinamento': dataCestinamento,
      'sottocategoria_ref': sottocategoriaRef,
    }.withoutNulls,
  );

  return firestoreData;
}

class PiattiRecordDocumentEquality implements Equality<PiattiRecord> {
  const PiattiRecordDocumentEquality();

  @override
  bool equals(PiattiRecord? e1, PiattiRecord? e2) {
    return e1?.nome == e2?.nome &&
        e1?.prezzo == e2?.prezzo &&
        e1?.categoria == e2?.categoria &&
        e1?.proprietario == e2?.proprietario &&
        e1?.ingredienti == e2?.ingredienti &&
        e1?.descrizione == e2?.descrizione &&
        e1?.foto == e2?.foto &&
        e1?.isCestinato == e2?.isCestinato &&
        e1?.dataCestinamento == e2?.dataCestinamento &&
        e1?.sottocategoriaRef == e2?.sottocategoriaRef;
  }

  @override
  int hash(PiattiRecord? e) => const ListEquality().hash([
        e?.nome,
        e?.prezzo,
        e?.categoria,
        e?.proprietario,
        e?.ingredienti,
        e?.descrizione,
        e?.foto,
        e?.isCestinato,
        e?.dataCestinamento,
        e?.sottocategoriaRef
      ]);

  @override
  bool isValidKey(Object? o) => o is PiattiRecord;
}
