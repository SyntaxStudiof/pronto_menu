import 'dart:async';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class QuizMatchesRecord extends FirestoreRecord {
  QuizMatchesRecord._(
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

  // "question_ids" field (list of integers).
  List<int>? _questionIds;
  List<int> get questionIds => _questionIds ?? const [];
  bool hasQuestionIds() => _questionIds != null;

  // "current_question_index" field (0..4).
  int? _currentQuestionIndex;
  int get currentQuestionIndex => _currentQuestionIndex ?? 0;
  bool hasCurrentQuestionIndex() => _currentQuestionIndex != null;

  // "risposta_sfidante" field (-1 se non ancora risposto, 0..3 se risposto).
  int? _rispostaSfidante;
  int get rispostaSfidante => _rispostaSfidante ?? -1;
  bool hasRispostaSfidante() => _rispostaSfidante != null;

  // "risposta_avversario" field (-1 se non ancora risposto, 0..3 se risposto).
  int? _rispostaAvversario;
  int get rispostaAvversario => _rispostaAvversario ?? -1;
  bool hasRispostaAvversario() => _rispostaAvversario != null;

  // "stato" field: in_attesa, in_corso, completata, abbandonata
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
    _questionIds = getDataList(snapshotData['question_ids'])?.map((e) => castToType<int>(e) ?? 0).toList();
    _currentQuestionIndex = castToType<int>(snapshotData['current_question_index']);
    _rispostaSfidante = castToType<int>(snapshotData['risposta_sfidante']);
    _rispostaAvversario = castToType<int>(snapshotData['risposta_avversario']);
    _stato = snapshotData['stato'] as String?;
    _punteggioSfidante = castToType<int>(snapshotData['punteggio_sfidante']);
    _punteggioAvversario = castToType<int>(snapshotData['punteggio_avversario']);
    _messaggioChat = snapshotData['messaggio_chat'] as String?;
    _messaggioMittente = snapshotData['messaggio_mittente'] as String?;
    _createdAt = snapshotData['created_at'] as DateTime?;
    _updatedAt = snapshotData['updated_at'] as DateTime?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('quiz_matches');

  static Stream<QuizMatchesRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => QuizMatchesRecord.fromSnapshot(s));

  static Future<QuizMatchesRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => QuizMatchesRecord.fromSnapshot(s));

  static QuizMatchesRecord fromSnapshot(DocumentSnapshot snapshot) =>
      QuizMatchesRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static QuizMatchesRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      QuizMatchesRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'QuizMatchesRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is QuizMatchesRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createQuizMatchesRecordData({
  DocumentReference? ristoranteRef,
  String? tavoloSfidante,
  String? tavoloAvversario,
  List<int>? questionIds,
  int? currentQuestionIndex,
  int? rispostaSfidante,
  int? rispostaAvversario,
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
      'question_ids': questionIds,
      'current_question_index': currentQuestionIndex,
      'risposta_sfidante': rispostaSfidante,
      'risposta_avversario': rispostaAvversario,
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
