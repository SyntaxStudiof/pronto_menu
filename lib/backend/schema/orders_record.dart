import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class OrdersRecord extends FirestoreRecord {
  OrdersRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "tavolo" field.
  int? _tavolo;
  int get tavolo => _tavolo ?? 0;
  bool hasTavolo() => _tavolo != null;

  // "totale" field.
  double? _totale;
  double get totale => _totale ?? 0.0;
  bool hasTotale() => _totale != null;

  // "data_creazione" field.
  DateTime? _dataCreazione;
  DateTime? get dataCreazione => _dataCreazione;
  bool hasDataCreazione() => _dataCreazione != null;

  // "lista_piatti" field.
  String? _listaPiatti;
  String get listaPiatti => _listaPiatti ?? '';
  bool hasListaPiatti() => _listaPiatti != null;

  // "stato_ordine" field.
  String? _statoOrdine;
  String get statoOrdine => _statoOrdine ?? '';
  bool hasStatoOrdine() => _statoOrdine != null;

  // "lista_piatti_ref" field.
  List<DocumentReference>? _listaPiattiRef;
  List<DocumentReference> get listaPiattiRef => _listaPiattiRef ?? const [];
  bool hasListaPiattiRef() => _listaPiattiRef != null;

  // "visto" field.
  bool? _visto;
  bool get visto => _visto ?? false;
  bool hasVisto() => _visto != null;

  // "ristoranteRef" field.
  DocumentReference? _ristoranteRef;
  DocumentReference? get ristoranteRef => _ristoranteRef;
  bool hasRistoranteRef() => _ristoranteRef != null;

  void _initializeFields() {
    _tavolo = castToType<int>(snapshotData['tavolo']);
    _totale = castToType<double>(snapshotData['totale']);
    _dataCreazione = snapshotData['data_creazione'] as DateTime?;
    _listaPiatti = snapshotData['lista_piatti'] as String?;
    _statoOrdine = snapshotData['stato_ordine'] as String?;
    _listaPiattiRef = getDataList(snapshotData['lista_piatti_ref']);
    _visto = snapshotData['visto'] as bool?;
    _ristoranteRef = snapshotData['ristoranteRef'] as DocumentReference?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('orders');

  static Stream<OrdersRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => OrdersRecord.fromSnapshot(s));

  static Future<OrdersRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => OrdersRecord.fromSnapshot(s));

  static OrdersRecord fromSnapshot(DocumentSnapshot snapshot) => OrdersRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static OrdersRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      OrdersRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'OrdersRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is OrdersRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createOrdersRecordData({
  int? tavolo,
  double? totale,
  DateTime? dataCreazione,
  String? listaPiatti,
  String? statoOrdine,
  bool? visto,
  DocumentReference? ristoranteRef,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'tavolo': tavolo,
      'totale': totale,
      'data_creazione': dataCreazione,
      'lista_piatti': listaPiatti,
      'stato_ordine': statoOrdine,
      'visto': visto,
      'ristoranteRef': ristoranteRef,
    }.withoutNulls,
  );

  return firestoreData;
}

class OrdersRecordDocumentEquality implements Equality<OrdersRecord> {
  const OrdersRecordDocumentEquality();

  @override
  bool equals(OrdersRecord? e1, OrdersRecord? e2) {
    const listEquality = ListEquality();
    return e1?.tavolo == e2?.tavolo &&
        e1?.totale == e2?.totale &&
        e1?.dataCreazione == e2?.dataCreazione &&
        e1?.listaPiatti == e2?.listaPiatti &&
        e1?.statoOrdine == e2?.statoOrdine &&
        listEquality.equals(e1?.listaPiattiRef, e2?.listaPiattiRef) &&
        e1?.visto == e2?.visto &&
        e1?.ristoranteRef == e2?.ristoranteRef;
  }

  @override
  int hash(OrdersRecord? e) => const ListEquality().hash([
        e?.tavolo,
        e?.totale,
        e?.dataCreazione,
        e?.listaPiatti,
        e?.statoOrdine,
        e?.listaPiattiRef,
        e?.visto,
        e?.ristoranteRef
      ]);

  @override
  bool isValidKey(Object? o) => o is OrdersRecord;
}
