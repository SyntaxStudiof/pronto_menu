import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'quiz_game_widget.dart' show QuizGameWidget;
import 'quiz_questions_data.dart';

class QuizGameModel extends FlutterFlowModel<QuizGameWidget> {
  /// Stato tab: 0 = Al mio Tavolo (locale), 1 = Sfida tra Tavoli (online)
  int selectedTabIndex = 0;

  /// Tavolo locale salvato o digitato
  String? myTableNumber;

  // --- STATO PARTITA LOCALE ---
  List<QuizQuestion> localQuestions = [];
  int currentLocalQuestionIndex = 0;
  int? selectedAnswerIndex;
  bool isAnswerRevealed = false;
  int localScore = 0;
  int correctAnswersCount = 0;
  bool isLocalGameFinished = false;
  int timerSecondsRemaining = 15;

  // --- STATO ONLINE ---
  String? currentMatchId;
  int? onlineSelectedAnswerIndex;
  bool onlineAnswerSubmitted = false;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
