import 'dart:async';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class TrisMatchesRecord extends FirestoreRecord {
  TrisMatchesRecord._(
    super.reference,
    super.data,
  ) {
    _initializeFields();
  }

  // "ristorante_ref" field.
  DocumentReference? _ristoranteRef;
  DocumentReference? get ristoranteRef => _ristoranteRef;
  bool hasRistoranteRef() => _ristoranteRef != null;

  // "tavolo_sfidante" field.
  String? _tavoloSfidante;
  String get tavoloSfidante => _tavoloSfidante ?? '';
  bool hasTavoloSfidante() => _tavoloSfidante != null;

  // "tavolo_avversario" field.
  String? _tavoloAvversario;
  String get tavoloAvversario => _tavoloAvversario ?? '';
  bool hasTavoloAvversario() => _tavoloAvversario != null;

  // "sfidante_simbolo" field.
  String? _sfidanteSimbolo;
  String get sfidanteSimbolo => _sfidanteSimbolo ?? 'X';
  bool hasSfidanteSimbolo() => _sfidanteSimbolo != null;

  // "avversario_simbolo" field.
  String? _avversarioSimbolo;
  String get avversarioSimbolo => _avversarioSimbolo ?? 'O';
  bool hasAvversarioSimbolo() => _avversarioSimbolo != null;

  // "board" field (list of 9 strings).
  List<String>? _board;
  List<String> get board => _board ?? const ['', '', '', '', '', '', '', '', ''];
  bool hasBoard() => _board != null;

  // "turno" field ("X" or "O").
  String? _turno;
  String get turno => _turno ?? 'X';
  bool hasTurno() => _turno != null;

  // "stato" field: in_attesa, in_corso, vittoria_x, vittoria_o, pareggio, annullata
  String? _stato;
  String get stato => _stato ?? 'in_attesa';
  bool hasStato() => _stato != null;

  // "punteggio_sfidante" field.
  int? _punteggioSfidante;
  int get punteggioSfidante => _punteggioSfidante ?? 0;
  bool hasPunteggioSfidante() => _punteggioSfidante != null;

  // "punteggio_avversario" field.
  int? _punteggioAvversario;
  int get punteggioAvversario => _punteggioAvversario ?? 0;
  bool hasPunteggioAvversario() => _punteggioAvversario != null;

  // "messaggio_chat" field.
  String? _messaggioChat;
  String get messaggioChat => _messaggioChat ?? '';
  bool hasMessaggioChat() => _messaggioChat != null;

  // "messaggio_mittente" field.
  String? _messaggioMittente;
  String get messaggioMittente => _messaggioMittente ?? '';
  bool hasMessaggioMittente() => _messaggioMittente != null;

  // "created_at" field.
  DateTime? _createdAt;
  DateTime? get createdAt => _createdAt;
  bool hasCreatedAt() => _createdAt != null;

  // "updated_at" field.
  DateTime? _updatedAt;
  DateTime? get updatedAt => _updatedAt;
  bool hasUpdatedAt() => _updatedAt != null;

  void _initializeFields() {
    _ristoranteRef = snapshotData['ristorante_ref'] as DocumentReference?;
    _tavoloSfidante = snapshotData['tavolo_sfidante'] as String?;
    _tavoloAvversario = snapshotData['tavolo_avversario'] as String?;
    _sfidanteSimbolo = snapshotData['sfidante_simbolo'] as String?;
    _avversarioSimbolo = snapshotData['avversario_simbolo'] as String?;
    _board = getDataList(snapshotData['board']);
    _turno = snapshotData['turno'] as String?;
    _stato = snapshotData['stato'] as String?;
    _punteggioSfidante = castToType<int>(snapshotData['punteggio_sfidante']);
    _punteggioAvversario = castToType<int>(snapshotData['punteggio_avversario']);
    _messaggioChat = snapshotData['messaggio_chat'] as String?;
    _messaggioMittente = snapshotData['messaggio_mittente'] as String?;
    _createdAt = snapshotData['created_at'] as DateTime?;
    _updatedAt = snapshotData['updated_at'] as DateTime?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('tris_matches');

  static Stream<TrisMatchesRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => TrisMatchesRecord.fromSnapshot(s));

  static Future<TrisMatchesRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => TrisMatchesRecord.fromSnapshot(s));

  static TrisMatchesRecord fromSnapshot(DocumentSnapshot snapshot) =>
      TrisMatchesRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static TrisMatchesRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      TrisMatchesRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'TrisMatchesRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is TrisMatchesRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createTrisMatchesRecordData({
  DocumentReference? ristoranteRef,
  String? tavoloSfidante,
  String? tavoloAvversario,
  String? sfidanteSimbolo,
  String? avversarioSimbolo,
  List<String>? board,
  String? turno,
  String? stato,
  int? punteggioSfidante,
  int? punteggioAvversario,
  String? messaggioChat,
  String? messaggioMittente,
  DateTime? createdAt,
  DateTime? updatedAt,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'ristorante_ref': ristoranteRef,
      'tavolo_sfidante': tavoloSfidante,
      'tavolo_avversario': tavoloAvversario,
      'sfidante_simbolo': sfidanteSimbolo,
      'avversario_simbolo': avversarioSimbolo,
      'board': board,
      'turno': turno,
      'stato': stato,
      'punteggio_sfidante': punteggioSfidante,
      'punteggio_avversario': punteggioAvversario,
      'messaggio_chat': messaggioChat,
      'messaggio_mittente': messaggioMittente,
      'created_at': createdAt,
      'updated_at': updatedAt,
    }.withoutNulls,
  );

  return firestoreData;
}
