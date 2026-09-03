import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class CancellationRequestsRecord extends FirestoreRecord {
  CancellationRequestsRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "email" field.
  String? _email;
  String get email => _email ?? '';
  bool hasEmail() => _email != null;

  // "requested_at" field.
  DateTime? _requestedAt;
  DateTime? get requestedAt => _requestedAt;
  bool hasRequestedAt() => _requestedAt != null;

  // "status" field.
  String? _status;
  String get status => _status ?? '';
  bool hasStatus() => _status != null;

  // "motivo" field.
  String? _motivo;
  String get motivo => _motivo ?? '';
  bool hasMotivo() => _motivo != null;

  // "nota" field.
  String? _nota;
  String get nota => _nota ?? '';
  bool hasNota() => _nota != null;

  void _initializeFields() {
    _email = snapshotData['email'] as String?;
    _requestedAt = snapshotData['requested_at'] as DateTime?;
    _status = snapshotData['status'] as String?;
    _motivo = snapshotData['motivo'] as String?;
    _nota = snapshotData['nota'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('cancellation_requests');

  static Stream<CancellationRequestsRecord> getDocument(
          DocumentReference ref) =>
      ref.snapshots().map((s) => CancellationRequestsRecord.fromSnapshot(s));

  static Future<CancellationRequestsRecord> getDocumentOnce(
          DocumentReference ref) =>
      ref.get().then((s) => CancellationRequestsRecord.fromSnapshot(s));

  static CancellationRequestsRecord fromSnapshot(DocumentSnapshot snapshot) =>
      CancellationRequestsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static CancellationRequestsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      CancellationRequestsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'CancellationRequestsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is CancellationRequestsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createCancellationRequestsRecordData({
  String? email,
  DateTime? requestedAt,
  String? status,
  String? motivo,
  String? nota,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'email': email,
      'requested_at': requestedAt,
      'status': status,
      'motivo': motivo,
      'nota': nota,
    }.withoutNulls,
  );

  return firestoreData;
}

class CancellationRequestsRecordDocumentEquality
    implements Equality<CancellationRequestsRecord> {
  const CancellationRequestsRecordDocumentEquality();

  @override
  bool equals(CancellationRequestsRecord? e1, CancellationRequestsRecord? e2) {
    return e1?.email == e2?.email &&
        e1?.requestedAt == e2?.requestedAt &&
        e1?.status == e2?.status &&
        e1?.motivo == e2?.motivo &&
        e1?.nota == e2?.nota;
  }

  @override
  int hash(CancellationRequestsRecord? e) => const ListEquality()
      .hash([e?.email, e?.requestedAt, e?.status, e?.motivo, e?.nota]);

  @override
  bool isValidKey(Object? o) => o is CancellationRequestsRecord;
}
