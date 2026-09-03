import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class SottocategorieRecord extends FirestoreRecord {
  SottocategorieRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "nome" field.
  String? _nome;
  String get nome => _nome ?? '';
  bool hasNome() => _nome != null;

  // "categoria_padre_ref" field.
  DocumentReference? _categoriaPadreRef;
  DocumentReference? get categoriaPadreRef => _categoriaPadreRef;
  bool hasCategoriaPadreRef() => _categoriaPadreRef != null;

  // "proprietario" field.
  DocumentReference? _proprietario;
  DocumentReference? get proprietario => _proprietario;
  bool hasProprietario() => _proprietario != null;

  void _initializeFields() {
    _nome = snapshotData['nome'] as String?;
    _categoriaPadreRef =
        snapshotData['categoria_padre_ref'] as DocumentReference?;
    _proprietario = snapshotData['proprietario'] as DocumentReference?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('Sottocategorie');

  static Stream<SottocategorieRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => SottocategorieRecord.fromSnapshot(s));

  static Future<SottocategorieRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => SottocategorieRecord.fromSnapshot(s));

  static SottocategorieRecord fromSnapshot(DocumentSnapshot snapshot) =>
      SottocategorieRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static SottocategorieRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      SottocategorieRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'SottocategorieRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is SottocategorieRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createSottocategorieRecordData({
  String? nome,
  DocumentReference? categoriaPadreRef,
  DocumentReference? proprietario,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'nome': nome,
      'categoria_padre_ref': categoriaPadreRef,
      'proprietario': proprietario,
    }.withoutNulls,
  );

  return firestoreData;
}

class SottocategorieRecordDocumentEquality
    implements Equality<SottocategorieRecord> {
  const SottocategorieRecordDocumentEquality();

  @override
  bool equals(SottocategorieRecord? e1, SottocategorieRecord? e2) {
    return e1?.nome == e2?.nome &&
        e1?.categoriaPadreRef == e2?.categoriaPadreRef &&
        e1?.proprietario == e2?.proprietario;
  }

  @override
  int hash(SottocategorieRecord? e) => const ListEquality()
      .hash([e?.nome, e?.categoriaPadreRef, e?.proprietario]);

  @override
  bool isValidKey(Object? o) => o is SottocategorieRecord;
}
