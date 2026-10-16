import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class JukeboxRequestsRecord extends FirestoreRecord {
  JukeboxRequestsRecord._(
    super.reference,
    super.data,
  ) {
    _initializeFields();
  }

  // "ristoranteRef" field.
  DocumentReference? _ristoranteRef;
  DocumentReference? get ristoranteRef => _ristoranteRef;
  bool hasRistoranteRef() => _ristoranteRef != null;

  // "trackId" field.
  String? _trackId;
  String get trackId => _trackId ?? '';
  bool hasTrackId() => _trackId != null;

  // "trackTitle" field.
  String? _trackTitle;
  String get trackTitle => _trackTitle ?? '';
  bool hasTrackTitle() => _trackTitle != null;

  // "artistName" field.
  String? _artistName;
  String get artistName => _artistName ?? '';
  bool hasArtistName() => _artistName != null;

  // "albumArtUrl" field.
  String? _albumArtUrl;
  String get albumArtUrl => _albumArtUrl ?? '';
  bool hasAlbumArtUrl() => _albumArtUrl != null;

  // "durationMs" field.
  int? _durationMs;
  int get durationMs => _durationMs ?? 0;
  bool hasDurationMs() => _durationMs != null;

  // "requestedAt" field.
  DateTime? _requestedAt;
  DateTime? get requestedAt => _requestedAt;
  bool hasRequestedAt() => _requestedAt != null;

  // "status" field.
  String? _status;
  String get status => _status ?? 'in_coda';
  bool hasStatus() => _status != null;

  // "tavolo" field.
  int? _tavolo;
  int get tavolo => _tavolo ?? 0;
  bool hasTavolo() => _tavolo != null;

  void _initializeFields() {
    _ristoranteRef = snapshotData['ristoranteRef'] as DocumentReference?;
    _trackId = snapshotData['trackId'] as String?;
    _trackTitle = snapshotData['trackTitle'] as String?;
    _artistName = snapshotData['artistName'] as String?;
    _albumArtUrl = snapshotData['albumArtUrl'] as String?;
    _durationMs = castToType<int>(snapshotData['durationMs']);
    _requestedAt = snapshotData['requestedAt'] as DateTime?;
    _status = snapshotData['status'] as String?;
    _tavolo = castToType<int>(snapshotData['tavolo']);
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('jukebox_requests');

  static Stream<JukeboxRequestsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => JukeboxRequestsRecord.fromSnapshot(s));

  static Future<JukeboxRequestsRecord> getDocumentOnce(
          DocumentReference ref) =>
      ref.get().then((s) => JukeboxRequestsRecord.fromSnapshot(s));

  static JukeboxRequestsRecord fromSnapshot(DocumentSnapshot snapshot) =>
      JukeboxRequestsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static JukeboxRequestsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      JukeboxRequestsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'JukeboxRequestsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is JukeboxRequestsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createJukeboxRequestsRecordData({
  DocumentReference? ristoranteRef,
  String? trackId,
  String? trackTitle,
  String? artistName,
  String? albumArtUrl,
  int? durationMs,
  DateTime? requestedAt,
  String? status,
  int? tavolo,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'ristoranteRef': ristoranteRef,
      'trackId': trackId,
      'trackTitle': trackTitle,
      'artistName': artistName,
      'albumArtUrl': albumArtUrl,
      'durationMs': durationMs,
      'requestedAt': requestedAt,
      'status': status,
      'tavolo': tavolo,
    }.withoutNulls,
  );

  return firestoreData;
}

class JukeboxRequestsRecordDocumentEquality
    implements Equality<JukeboxRequestsRecord> {
  const JukeboxRequestsRecordDocumentEquality();

  @override
  bool equals(JukeboxRequestsRecord? e1, JukeboxRequestsRecord? e2) {
    return e1?.ristoranteRef == e2?.ristoranteRef &&
        e1?.trackId == e2?.trackId &&
        e1?.trackTitle == e2?.trackTitle &&
        e1?.artistName == e2?.artistName &&
        e1?.albumArtUrl == e2?.albumArtUrl &&
        e1?.durationMs == e2?.durationMs &&
        e1?.requestedAt == e2?.requestedAt &&
        e1?.status == e2?.status &&
        e1?.tavolo == e2?.tavolo;
  }

  @override
  int hash(JukeboxRequestsRecord? e) => const ListEquality().hash([
        e?.ristoranteRef,
        e?.trackId,
        e?.trackTitle,
        e?.artistName,
        e?.albumArtUrl,
        e?.durationMs,
        e?.requestedAt,
        e?.status,
        e?.tavolo,
      ]);

  @override
  bool isValidKey(Object? o) => o is JukeboxRequestsRecord;
}
