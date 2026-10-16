import 'dart:async';

import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'quiz_game_model.dart';
import 'quiz_questions_data.dart';
export 'quiz_game_model.dart';

class QuizGameWidget extends StatefulWidget {
  const QuizGameWidget({
    super.key,
    required this.ristoranteRef,
    this.tavoloPreimpostato,
  });

  final DocumentReference? ristoranteRef;
  final String? tavoloPreimpostato;

  static String routeName = 'QuizGame';
  static String routePath = '/quizGame';

  @override
  State<QuizGameWidget> createState() => _QuizGameWidgetState();
}

class _QuizGameWidgetState extends State<QuizGameWidget> {
  late QuizGameModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  Timer? _localTimer;
  Timer? _chatDismissTimer;
  String _liveReactionMessage = '';

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => QuizGameModel());

    final defaultTable = widget.tavoloPreimpostato?.trim() ?? '';
    _model.myTableNumber = defaultTable.isNotEmpty
        ? defaultTable
        : (FFAppState().numeroTavolo.isNotEmpty
            ? FFAppState().numeroTavolo
            : 'Tavolo 1');

    _initLocalGame();

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _localTimer?.cancel();
    _chatDismissTimer?.cancel();
    _model.dispose();
    super.dispose();
  }

  // --- LOGICA GIOCO LOCALE ---
  void _initLocalGame() {
    _localTimer?.cancel();
    _model.localQuestions = QuizDataService.getRandomQuestions(count: 5);
    _model.currentLocalQuestionIndex = 0;
    _model.selectedAnswerIndex = null;
    _model.isAnswerRevealed = false;
    _model.localScore = 0;
    _model.correctAnswersCount = 0;
    _model.isLocalGameFinished = false;
    _startLocalQuestionTimer();
  }

  void _startLocalQuestionTimer() {
    _localTimer?.cancel();
    _model.timerSecondsRemaining = 15;
    _model.selectedAnswerIndex = null;
    _model.isAnswerRevealed = false;

    _localTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_model.timerSecondsRemaining > 1) {
        safeSetState(() {
          _model.timerSecondsRemaining--;
        });
      } else {
        _localTimer?.cancel();
        _onTimeExpiredLocal();
      }
    });
  }

  void _onTimeExpiredLocal() {
    if (_model.isAnswerRevealed) return;
    HapticFeedback.mediumImpact();
    safeSetState(() {
      _model.timerSecondsRemaining = 0;
      _model.isAnswerRevealed = true;
    });
  }

  void _selectLocalAnswer(int index) {
    if (_model.isAnswerRevealed) return;
    _localTimer?.cancel();

    final currentQ = _model.localQuestions[_model.currentLocalQuestionIndex];
    final isCorrect = index == currentQ.correctIndex;

    HapticFeedback.lightImpact();

    safeSetState(() {
      _model.selectedAnswerIndex = index;
      _model.isAnswerRevealed = true;

      if (isCorrect) {
        _model.correctAnswersCount++;
        // 100 punti base + bonus secondi rimasti (fino a +50)
        final speedBonus = _model.timerSecondsRemaining * 3;
        _model.localScore += (100 + speedBonus);
      }
    });
  }

  void _nextLocalQuestion() {
    if (_model.currentLocalQuestionIndex < _model.localQuestions.length - 1) {
      safeSetState(() {
        _model.currentLocalQuestionIndex++;
      });
      _startLocalQuestionTimer();
    } else {
      _localTimer?.cancel();
      safeSetState(() {
        _model.isLocalGameFinished = true;
      });
    }
  }

  String _getFoodTitle(int correct) {
    if (correct >= 5) return 'Maestro Gourmet Supremo 👑';
    if (correct >= 4) return 'Critico Gastronomico DOC 🍷';
    if (correct >= 3) return 'Buongustaio Esperto 🍕';
    if (correct >= 2) return 'Assaggiatore Curioso 🍽️';
    return 'Apprendista ai Fornelli 🍳';
  }

  // --- LOGICA ONLINE MULTIPLAYER ---
  Future<void> _creaNuovaSfidaOnline() async {
    final mioTavolo = _model.myTableNumber?.trim() ?? 'Tavolo';
    final questions = QuizDataService.getRandomQuestions(count: 5);
    final questionIds = questions.map((q) => q.id).toList();

    final matchRef = await QuizMatchesRecord.collection.add(
      createQuizMatchesRecordData(
        ristoranteRef: widget.ristoranteRef,
        tavoloSfidante: mioTavolo,
        tavoloAvversario: '',
        questionIds: questionIds,
        currentQuestionIndex: 0,
        rispostaSfidante: -1,
        rispostaAvversario: -1,
        stato: 'in_attesa',
        punteggioSfidante: 0,
        punteggioAvversario: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );

    safeSetState(() {
      _model.currentMatchId = matchRef.id;
      _model.onlineSelectedAnswerIndex = null;
      _model.onlineAnswerSubmitted = false;
    });
  }

  Future<void> _accettaSfidaOnline(QuizMatchesRecord match) async {
    final mioTavolo = _model.myTableNumber?.trim() ?? 'Tavolo';

    await match.reference.update(
      createQuizMatchesRecordData(
        tavoloAvversario: mioTavolo,
        stato: 'in_corso',
        updatedAt: DateTime.now(),
      ),
    );

    safeSetState(() {
      _model.currentMatchId = match.reference.id;
      _model.onlineSelectedAnswerIndex = null;
      _model.onlineAnswerSubmitted = false;
    });
  }

  Future<void> _inviaRispostaOnline(QuizMatchesRecord match, int answerIndex) async {
    final mioTavolo = _model.myTableNumber ?? '';
    final isSfidante = match.tavoloSfidante == mioTavolo;

    HapticFeedback.lightImpact();

    safeSetState(() {
      _model.onlineSelectedAnswerIndex = answerIndex;
      _model.onlineAnswerSubmitted = true;
    });

    final currentQId = match.questionIds.length > match.currentQuestionIndex
        ? match.questionIds[match.currentQuestionIndex]
        : 1;
    final currentQ = QuizDataService.allQuestions.firstWhere(
      (q) => q.id == currentQId,
      orElse: () => QuizDataService.allQuestions.first,
    );
    final isCorrect = answerIndex == currentQ.correctIndex;
    final pointsEarned = isCorrect ? 100 : 0;

    final updates = <String, dynamic>{
      'updated_at': DateTime.now(),
    };

    if (isSfidante) {
      updates['risposta_sfidante'] = answerIndex;
      updates['punteggio_sfidante'] = match.punteggioSfidante + pointsEarned;
    } else {
      updates['risposta_avversario'] = answerIndex;
      updates['punteggio_avversario'] = match.punteggioAvversario + pointsEarned;
    }

    await match.reference.update(updates);
  }

  Future<void> _avanzaProssimoRoundOnline(QuizMatchesRecord match) async {
    final isUltimaDomanda = match.currentQuestionIndex >= match.questionIds.length - 1;

    final updates = <String, dynamic>{
      'risposta_sfidante': -1,
      'risposta_avversario': -1,
      'updated_at': DateTime.now(),
    };

    if (isUltimaDomanda) {
      updates['stato'] = 'completata';
    } else {
      updates['current_question_index'] = match.currentQuestionIndex + 1;
    }

    await match.reference.update(updates);

    safeSetState(() {
      _model.onlineSelectedAnswerIndex = null;
      _model.onlineAnswerSubmitted = false;
    });
  }

  Future<void> _inviaReazioneOnline(String emoji, String testo) async {
    if (_model.currentMatchId == null) return;
    final matchRef = QuizMatchesRecord.collection.doc(_model.currentMatchId!);
    final mioTavolo = _model.myTableNumber?.trim() ?? 'Tavolo';

    await matchRef.update({
      'messaggio_chat': '$emoji $testo',
      'messaggio_mittente': mioTavolo,
      'updated_at': DateTime.now(),
    });
  }

  Future<void> _abbandonaMatchOnline(QuizMatchesRecord match) async {
    final confermato = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Abbandonare la sfida?'),
        content: const Text('Sei sicuro di voler uscire da questa partita di quiz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Resta in gioco'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Abbandona', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confermato == true) {
      await match.reference.update({
        'stato': 'abbandonata',
        'updated_at': DateTime.now(),
      });
      safeSetState(() {
        _model.currentMatchId = null;
        _model.onlineSelectedAnswerIndex = null;
        _model.onlineAnswerSubmitted = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor ?? theme.cardColor,
        elevation: 0.0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: FlutterFlowIconButton(
          borderColor: Colors.transparent,
          borderRadius: 24.0,
          borderWidth: 1.0,
          buttonSize: 40.0,
          icon: Icon(
            Icons.arrow_back_rounded,
            color: theme.colorScheme.onSurface,
            size: 24.0,
          ),
          onPressed: () async {
            context.safePop();
          },
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36.0,
              height: 36.0,
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10.0),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.lightbulb_rounded,
                color: Color(0xFFF59E0B),
                size: 20.0,
              ),
            ),
            const SizedBox(width: 10.0),
            Text(
              'Quiz al Tavolo',
              style: theme.appBarTheme.titleTextStyle ??
                  theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 19.0,
                    letterSpacing: -0.4,
                    color: theme.colorScheme.onSurface,
                  ),
            ),
          ],
        ),
        actions: const [
          SizedBox(width: 48.0),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8.0),
            // Selettore Tab Moderno
            _buildTabSelector(theme, colorScheme),
            const SizedBox(height: 8.0),
            // Contenuto in base al Tab
            Expanded(
              child: _model.selectedTabIndex == 0
                  ? _buildLocalQuizView(theme, colorScheme)
                  : _buildOnlineQuizView(theme, colorScheme),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabSelector(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20.0),
      padding: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () {
                HapticFeedback.selectionClick();
                safeSetState(() => _model.selectedTabIndex = 0);
              },
              borderRadius: BorderRadius.circular(12.0),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 9.0),
                decoration: BoxDecoration(
                  color: _model.selectedTabIndex == 0
                      ? const Color(0xFFF59E0B)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.table_restaurant_rounded,
                      size: 18.0,
                      color: _model.selectedTabIndex == 0
                          ? Colors.white
                          : theme.hintColor,
                    ),
                    const SizedBox(width: 8.0),
                    Text(
                      'Al mio Tavolo',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13.5,
                        color: _model.selectedTabIndex == 0
                          ? Colors.white
                          : theme.hintColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () {
                HapticFeedback.selectionClick();
                safeSetState(() => _model.selectedTabIndex = 1);
              },
              borderRadius: BorderRadius.circular(12.0),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 9.0),
                decoration: BoxDecoration(
                  color: _model.selectedTabIndex == 1
                      ? const Color(0xFFF59E0B)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.sensors_rounded,
                      size: 18.0,
                      color: _model.selectedTabIndex == 1
                          ? Colors.white
                          : theme.hintColor,
                    ),
                    const SizedBox(width: 8.0),
                    Text(
                      'Sfida tra Tavoli',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13.5,
                        color: _model.selectedTabIndex == 1
                          ? Colors.white
                          : theme.hintColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // SCHERMATA: AL MIO TAVOLO (LOCALE)
  // ==========================================
  Widget _buildLocalQuizView(ThemeData theme, ColorScheme colorScheme) {
    if (_model.isLocalGameFinished) {
      return _buildLocalResultScreen(theme, colorScheme);
    }

    if (_model.localQuestions.isEmpty) {
      return const Center(
        child: SpinKitPulse(color: Color(0xFFF59E0B), size: 40.0),
      );
    }

    final currentQ = _model.localQuestions[_model.currentLocalQuestionIndex];
    final progress = (_model.currentLocalQuestionIndex + 1) / _model.localQuestions.length;
    final timerPercent = _model.timerSecondsRemaining / 15.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Barra di progresso del Quiz
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Domanda ${_model.currentLocalQuestionIndex + 1} di ${_model.localQuestions.length}',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.hintColor,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.stars_rounded, color: Color(0xFFF59E0B), size: 16.0),
                    const SizedBox(width: 4.0),
                    Text(
                      '${_model.localScore} pt',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFF59E0B),
                        fontSize: 13.0,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          ClipRRect(
            borderRadius: BorderRadius.circular(6.0),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6.0,
              backgroundColor: theme.dividerColor.withValues(alpha: 0.15),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFF59E0B)),
            ),
          ),
          const SizedBox(height: 18.0),

          // Timer Conto alla Rovescia
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(
                color: theme.dividerColor.withValues(alpha: 0.12),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.timer_rounded,
                  color: _model.timerSecondsRemaining <= 4 ? Colors.red : const Color(0xFFF59E0B),
                  size: 20.0,
                ),
                const SizedBox(width: 10.0),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6.0),
                    child: LinearProgressIndicator(
                      value: timerPercent,
                      minHeight: 8.0,
                      backgroundColor: theme.dividerColor.withValues(alpha: 0.12),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _model.timerSecondsRemaining <= 4 ? Colors.red : const Color(0xFFF59E0B),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12.0),
                Text(
                  '${_model.timerSecondsRemaining}s',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15.0,
                    color: _model.timerSecondsRemaining <= 4 ? Colors.red : theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16.0),

          // Scheda della Domanda
          Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(20.0),
              border: Border.all(
                color: theme.dividerColor.withValues(alpha: 0.12),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10.0,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Text(
                    currentQ.category,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12.0,
                      color: Color(0xFFD97706),
                    ),
                  ),
                ),
                const SizedBox(height: 12.0),
                Text(
                  currentQ.question,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 17.5,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16.0),

          // 4 Opzioni di Risposta
          ...List.generate(currentQ.options.length, (optIdx) {
            final optionText = currentQ.options[optIdx];
            final isChosen = _model.selectedAnswerIndex == optIdx;
            final isCorrect = optIdx == currentQ.correctIndex;

            Color borderColor = theme.dividerColor.withValues(alpha: 0.15);
            Color bgColor = theme.cardColor;
            Color textColor = theme.colorScheme.onSurface;
            IconData? trailingIcon;
            Color? trailingIconColor;

            if (_model.isAnswerRevealed) {
              if (isCorrect) {
                borderColor = const Color(0xFF10B981);
                bgColor = const Color(0xFF10B981).withValues(alpha: 0.12);
                textColor = const Color(0xFF047857);
                trailingIcon = Icons.check_circle_rounded;
                trailingIconColor = const Color(0xFF10B981);
              } else if (isChosen && !isCorrect) {
                borderColor = Colors.red;
                bgColor = Colors.red.withValues(alpha: 0.10);
                textColor = Colors.red.shade800;
                trailingIcon = Icons.cancel_rounded;
                trailingIconColor = Colors.red;
              }
            }

            final letters = ['A', 'B', 'C', 'D'];

            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: InkWell(
                onTap: _model.isAnswerRevealed
                    ? null
                    : () => _selectLocalAnswer(optIdx),
                borderRadius: BorderRadius.circular(16.0),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(16.0),
                    border: Border.all(color: borderColor, width: isChosen || (_model.isAnswerRevealed && isCorrect) ? 2.0 : 1.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 6.0,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 32.0,
                        height: 32.0,
                        decoration: BoxDecoration(
                          color: isChosen
                              ? const Color(0xFFF59E0B)
                              : theme.dividerColor.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          letters[optIdx],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14.0,
                            color: isChosen ? Colors.white : theme.hintColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14.0),
                      Expanded(
                        child: Text(
                          optionText,
                          style: TextStyle(
                            fontSize: 15.0,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                      ),
                      if (trailingIcon != null) ...[
                        const SizedBox(width: 8.0),
                        Icon(trailingIcon, color: trailingIconColor, size: 22.0),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }),

          // Box Curiosità "Lo sapevi che? 💡" (Compare dopo la risposta)
          if (_model.isAnswerRevealed) ...[
            const SizedBox(height: 8.0),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16.0),
                border: Border.all(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.25),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('💡', style: TextStyle(fontSize: 20.0)),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Lo sapevi che?',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13.0,
                            color: Color(0xFFD97706),
                          ),
                        ),
                        const SizedBox(height: 3.0),
                        Text(
                          currentQ.funFact,
                          style: TextStyle(
                            fontSize: 13.5,
                            color: theme.colorScheme.onSurface,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18.0),

            // Pulsante Prossima Domanda / Vedi Risultati
            SizedBox(
              height: 48.0,
              child: ElevatedButton(
                onPressed: _nextLocalQuestion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF59E0B),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  elevation: 2.0,
                ),
                child: Text(
                  _model.currentLocalQuestionIndex < _model.localQuestions.length - 1
                      ? 'Prossima Domanda ➔'
                      : 'Vedi Risultati Finali 🏆',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
                ),
              ),
            ),
            const SizedBox(height: 24.0),
          ],
        ],
      ),
    );
  }

  Widget _buildLocalResultScreen(ThemeData theme, ColorScheme colorScheme) {
    final title = _getFoodTitle(_model.correctAnswersCount);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 10.0),
          Container(
            width: 90.0,
            height: 90.0,
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Text('🏆', style: TextStyle(fontSize: 48.0)),
          ),
          const SizedBox(height: 16.0),
          Text(
            'Quiz Completato!',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6.0),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 6.0),
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14.5,
                color: Color(0xFFD97706),
              ),
            ),
          ),
          const SizedBox(height: 24.0),

          // Punteggi Box
          Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(20.0),
              border: Border.all(
                color: theme.dividerColor.withValues(alpha: 0.12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      '${_model.localScore}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 26.0,
                        color: Color(0xFFF59E0B),
                      ),
                    ),
                    const SizedBox(height: 2.0),
                    Text(
                      'Punti Totali',
                      style: theme.textTheme.labelMedium?.copyWith(color: theme.hintColor),
                    ),
                  ],
                ),
                Container(
                  width: 1.0,
                  height: 40.0,
                  color: theme.dividerColor.withValues(alpha: 0.20),
                ),
                Column(
                  children: [
                    Text(
                      '${_model.correctAnswersCount}/5',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 26.0,
                        color: Color(0xFF10B981),
                      ),
                    ),
                    const SizedBox(height: 2.0),
                    Text(
                      'Esatte',
                      style: theme.textTheme.labelMedium?.copyWith(color: theme.hintColor),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 28.0),

          // Pulsante Gioca di Nuovo
          SizedBox(
            width: double.infinity,
            height: 50.0,
            child: ElevatedButton.icon(
              onPressed: () {
                HapticFeedback.lightImpact();
                safeSetState(() {
                  _initLocalGame();
                });
              },
              icon: const Icon(Icons.replay_rounded, color: Colors.white),
              label: const Text(
                'Gioca un\'Altra Partita',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF59E0B),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                elevation: 2.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // SCHERMATA: SFIDA TRA TAVOLI (ONLINE)
  // ==========================================
  Widget _buildOnlineQuizView(ThemeData theme, ColorScheme colorScheme) {
    if (_model.currentMatchId != null) {
      return StreamBuilder<QuizMatchesRecord>(
        stream: QuizMatchesRecord.getDocument(
          QuizMatchesRecord.collection.doc(_model.currentMatchId!),
        ),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: SpinKitPulse(color: Color(0xFFF59E0B), size: 40.0),
            );
          }
          final match = snapshot.data!;
          return _buildActiveOnlineQuizMatch(theme, colorScheme, match);
        },
      );
    }

    return _buildOnlineLobby(theme, colorScheme);
  }

  Widget _buildOnlineLobby(ThemeData theme, ColorScheme colorScheme) {
    final mioTavolo = _model.myTableNumber ?? 'Tavolo 1';

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Identificativo del tavolo
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(
                color: theme.dividerColor.withValues(alpha: 0.12),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 36.0,
                  height: 36.0,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.table_bar_rounded,
                    color: Color(0xFFF59E0B),
                    size: 20.0,
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Il tuo Tavolo:',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.hintColor,
                        ),
                      ),
                      Text(
                        mioTavolo,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => _modificaNumeroTavolo(theme),
                  child: const Text('Modifica'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18.0),

          // Bottone per lanciare una nuova sfida
          SizedBox(
            height: 48.0,
            child: ElevatedButton.icon(
              onPressed: _creaNuovaSfidaOnline,
              icon: const Icon(Icons.bolt_rounded, color: Colors.white),
              label: const Text(
                'Lancia una Nuova Sfida ai Tavoli',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.0, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF59E0B),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                elevation: 2.0,
              ),
            ),
          ),
          const SizedBox(height: 24.0),

          // Lista sfide in attesa dagli altri tavoli
          Text(
            'Tavoli in attesa di giocare:',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12.0),

          StreamBuilder<List<QuizMatchesRecord>>(
            stream: queryQuizMatchesRecord(
              queryBuilder: (q) => q
                  .where('ristorante_ref', isEqualTo: widget.ristoranteRef)
                  .where('stato', isEqualTo: 'in_attesa')
                  .orderBy('created_at', descending: true),
            ),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: SpinKitPulse(color: Color(0xFFF59E0B), size: 36.0),
                  ),
                );
              }

              final matches = snapshot.data!;
              final sfideAltri = matches.where((m) => m.tavoloSfidante != mioTavolo).toList();
              final mieSfideInAttesa = matches.where((m) => m.tavoloSfidante == mioTavolo).toList();

              return Column(
                children: [
                  if (mieSfideInAttesa.isNotEmpty) ...[
                    Container(
                      margin: const EdgeInsets.only(bottom: 14.0),
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(16.0),
                        border: Border.all(
                          color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
                        ),
                      ),
                      child: Row(
                        children: [
                          const SpinKitPulse(color: Color(0xFFF59E0B), size: 28.0),
                          const SizedBox(width: 14.0),
                          const Expanded(
                            child: Text(
                              'In attesa che un altro tavolo accetti il tuo quiz...',
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded, color: Colors.red),
                            onPressed: () async {
                              await mieSfideInAttesa.first.reference.delete();
                            },
                          ),
                        ],
                      ),
                    ),
                  ],

                  if (sfideAltri.isEmpty) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(32.0),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(20.0),
                        border: Border.all(
                          color: theme.dividerColor.withValues(alpha: 0.12),
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.quiz_outlined, size: 44.0, color: theme.hintColor),
                          const SizedBox(height: 12.0),
                          Text(
                            'Nessun tavolo in attesa al momento',
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: theme.hintColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6.0),
                          Text(
                            'Clicca sul pulsante sopra per creare una sfida e coinvolgere gli altri tavoli!',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: sfideAltri.length,
                      itemBuilder: (context, idx) {
                        final match = sfideAltri[idx];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10.0),
                          padding: const EdgeInsets.all(14.0),
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            borderRadius: BorderRadius.circular(16.0),
                            border: Border.all(
                              color: theme.dividerColor.withValues(alpha: 0.12),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40.0,
                                height: 40.0,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                alignment: Alignment.center,
                                child: const Text('🧠', style: TextStyle(fontSize: 20.0)),
                              ),
                              const SizedBox(width: 12.0),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      match.tavoloSfidante,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15.0,
                                      ),
                                    ),
                                    Text(
                                      'Sfida a 5 domande',
                                      style: theme.textTheme.labelSmall?.copyWith(color: theme.hintColor),
                                    ),
                                  ],
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () => _accettaSfidaOnline(match),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFF59E0B),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                ),
                                child: const Text('Gioca', style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActiveOnlineQuizMatch(ThemeData theme, ColorScheme colorScheme, QuizMatchesRecord match) {
    final mioTavolo = _model.myTableNumber ?? 'Tavolo 1';
    final isSfidante = match.tavoloSfidante == mioTavolo;
    final tavoloAvversarioNome = isSfidante ? match.tavoloAvversario : match.tavoloSfidante;

    // Se l'avversario ha inviato una reazione in chat
    if (match.hasMessaggioChat() && match.messaggioMittente != mioTavolo) {
      if (_liveReactionMessage != match.messaggioChat) {
        _liveReactionMessage = match.messaggioChat;
        _chatDismissTimer?.cancel();
        _chatDismissTimer = Timer(const Duration(seconds: 4), () {
          if (mounted) safeSetState(() => _liveReactionMessage = '');
        });
      }
    }

    if (match.stato == 'in_attesa') {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SpinKitPulse(color: Color(0xFFF59E0B), size: 50.0),
              const SizedBox(height: 20.0),
              const Text(
                'Sfida Creata!',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
              ),
              const SizedBox(height: 8.0),
              Text(
                'In attesa che un altro tavolo accetti di giocare...',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
              ),
              const SizedBox(height: 24.0),
              OutlinedButton.icon(
                onPressed: () => _abbandonaMatchOnline(match),
                icon: const Icon(Icons.close_rounded, color: Colors.red),
                label: const Text('Annulla Sfida', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ),
      );
    }

    if (match.stato == 'abbandonata') {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cancel_rounded, size: 54.0, color: Colors.red),
              const SizedBox(height: 16.0),
              const Text(
                'Partita Terminata',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
              ),
              const SizedBox(height: 8.0),
              Text(
                'L\'altro tavolo ha abbandonato la sfida.',
                style: TextStyle(color: theme.hintColor),
              ),
              const SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: () {
                  safeSetState(() => _model.currentMatchId = null);
                },
                child: const Text('Torna alla Lobby'),
              ),
            ],
          ),
        ),
      );
    }

    if (match.stato == 'completata') {
      final mioPunti = isSfidante ? match.punteggioSfidante : match.punteggioAvversario;
      final avvPunti = isSfidante ? match.punteggioAvversario : match.punteggioSfidante;

      final hoVinto = mioPunti > avvPunti;
      final pareggio = mioPunti == avvPunti;

      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(hoVinto ? '🏆' : (pareggio ? '🤝' : '🥈'), style: const TextStyle(fontSize: 60.0)),
              const SizedBox(height: 16.0),
              Text(
                hoVinto ? 'Complimenti, Hai Vinto!' : (pareggio ? 'È un Pareggio!' : 'Ha vinto $tavoloAvversarioNome!'),
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20.0),
              Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(20.0),
                  border: Border.all(color: theme.dividerColor.withValues(alpha: 0.12)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text('$mioPunti', style: const TextStyle(fontSize: 26.0, fontWeight: FontWeight.bold, color: Color(0xFFF59E0B))),
                        Text('Tu ($mioTavolo)', style: TextStyle(color: theme.hintColor)),
                      ],
                    ),
                    const Text('VS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0)),
                    Column(
                      children: [
                        Text('$avvPunti', style: const TextStyle(fontSize: 26.0, fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
                        Text(tavoloAvversarioNome, style: TextStyle(color: theme.hintColor)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: () {
                  safeSetState(() => _model.currentMatchId = null);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF59E0B),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
                ),
                child: const Text('Torna alla Sala Giochi', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      );
    }

    // PARTITA ONLINE IN CORSO
    final qId = match.questionIds.length > match.currentQuestionIndex
        ? match.questionIds[match.currentQuestionIndex]
        : 1;
    final currentQ = QuizDataService.allQuestions.firstWhere(
      (q) => q.id == qId,
      orElse: () => QuizDataService.allQuestions.first,
    );

    final miaRisposta = isSfidante ? match.rispostaSfidante : match.rispostaAvversario;
    final avvRisposta = isSfidante ? match.rispostaAvversario : match.rispostaSfidante;
    final hoRisposto = miaRisposta != -1;
    final avvHaRisposto = avvRisposta != -1;
    final entrambiHannoRisposto = hoRisposto && avvHaRisposto;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Banner Sfida & Punteggi Live
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(color: theme.dividerColor.withValues(alpha: 0.12)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$mioTavolo (Tu)', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.0)),
                    Text(
                      '${isSfidante ? match.punteggioSfidante : match.punteggioAvversario} pt',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0, color: Color(0xFFF59E0B)),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Text(
                    'Round ${match.currentQuestionIndex + 1}/5',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5, color: Color(0xFFD97706)),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(tavoloAvversarioNome, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.0)),
                    Text(
                      '${isSfidante ? match.punteggioAvversario : match.punteggioSfidante} pt',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0, color: Color(0xFF10B981)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12.0),

          // Reazione a fumetto live se presente
          if (_liveReactionMessage.isNotEmpty) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 12.0),
              padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: Colors.amber.shade100,
                borderRadius: BorderRadius.circular(16.0),
                border: Border.all(color: Colors.amber.shade300),
              ),
              child: Row(
                children: [
                  const Icon(Icons.chat_bubble_rounded, size: 16.0, color: Colors.amber),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: Text(
                      '$tavoloAvversarioNome: $_liveReactionMessage',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.0, color: Colors.black87),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Scheda Domanda
          Container(
            padding: const EdgeInsets.all(18.0),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(20.0),
              border: Border.all(color: theme.dividerColor.withValues(alpha: 0.12)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      currentQ.category,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.0, color: Color(0xFFD97706)),
                    ),
                    if (avvHaRisposto)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: const Text('Avversario pronto! ⚡', style: TextStyle(fontSize: 11.0, fontWeight: FontWeight.bold, color: Color(0xFF047857))),
                      ),
                  ],
                ),
                const SizedBox(height: 10.0),
                Text(
                  currentQ.question,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 17.0,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14.0),

          // Opzioni
          ...List.generate(currentQ.options.length, (optIdx) {
            final optionText = currentQ.options[optIdx];
            final isChosen = miaRisposta == optIdx;
            final isCorrect = optIdx == currentQ.correctIndex;

            Color borderColor = theme.dividerColor.withValues(alpha: 0.15);
            Color bgColor = theme.cardColor;

            if (entrambiHannoRisposto) {
              if (isCorrect) {
                borderColor = const Color(0xFF10B981);
                bgColor = const Color(0xFF10B981).withValues(alpha: 0.12);
              } else if (isChosen && !isCorrect) {
                borderColor = Colors.red;
                bgColor = Colors.red.withValues(alpha: 0.10);
              }
            } else if (isChosen) {
              borderColor = const Color(0xFFF59E0B);
              bgColor = const Color(0xFFF59E0B).withValues(alpha: 0.12);
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: InkWell(
                onTap: hoRisposto ? null : () => _inviaRispostaOnline(match, optIdx),
                borderRadius: BorderRadius.circular(16.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 13.0),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(16.0),
                    border: Border.all(color: borderColor, width: isChosen ? 2.0 : 1.0),
                  ),
                  child: Row(
                    children: [
                      Text(
                        ['A', 'B', 'C', 'D'][optIdx],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isChosen ? const Color(0xFFF59E0B) : theme.hintColor,
                        ),
                      ),
                      const SizedBox(width: 12.0),
                      Expanded(
                        child: Text(
                          optionText,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14.5),
                        ),
                      ),
                      if (isChosen && !entrambiHannoRisposto)
                        const Icon(Icons.check_circle_outline_rounded, color: Color(0xFFF59E0B), size: 20.0),
                    ],
                  ),
                ),
              ),
            );
          }),

          // Se entrambi hanno risposto: Tasto Prossimo Round
          if (entrambiHannoRisposto) ...[
            const SizedBox(height: 12.0),
            ElevatedButton(
              onPressed: () => _avanzaProssimoRoundOnline(match),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF59E0B),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
              ),
              child: Text(
                match.currentQuestionIndex < match.questionIds.length - 1
                    ? 'Prossimo Round ➔'
                    : 'Classifica Finale 🏆',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ] else if (hoRisposto) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SpinKitPulse(color: Color(0xFFF59E0B), size: 18.0),
                  const SizedBox(width: 8.0),
                  Text('In attesa che $tavoloAvversarioNome risponda...', style: TextStyle(color: theme.hintColor, fontSize: 13.0)),
                ],
              ),
            ),
          ],

          const SizedBox(height: 16.0),

          // Barra Reazioni Rapide Emojis
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(color: theme.dividerColor.withValues(alpha: 0.12)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildReactionButton('🔥', 'Troppo forte!'),
                _buildReactionButton('💡', 'Che genio!'),
                _buildReactionButton('🍕', 'Offro io!'),
                _buildReactionButton('👏', 'Bella risposta!'),
                _buildReactionButton('😎', 'Troppo facile!'),
              ],
            ),
          ),
          const SizedBox(height: 16.0),

          // Abbandona
          Center(
            child: TextButton.icon(
              onPressed: () => _abbandonaMatchOnline(match),
              icon: const Icon(Icons.exit_to_app_rounded, color: Colors.red, size: 18.0),
              label: const Text('Abbandona partita', style: TextStyle(color: Colors.red, fontSize: 13.0)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReactionButton(String emoji, String text) {
    return InkWell(
      onTap: () => _inviaReazioneOnline(emoji, text),
      borderRadius: BorderRadius.circular(12.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
        child: Text(emoji, style: const TextStyle(fontSize: 22.0)),
      ),
    );
  }

  void _modificaNumeroTavolo(ThemeData theme) {
    final textController = TextEditingController(text: _model.myTableNumber);
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Modifica il tuo Tavolo'),
          content: TextField(
            controller: textController,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Es. Tavolo 5',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Annulla'),
            ),
            ElevatedButton(
              onPressed: () {
                final txt = textController.text.trim();
                if (txt.isNotEmpty) {
                  safeSetState(() {
                    _model.myTableNumber = txt;
                  });
                  FFAppState().numeroTavolo = txt;
                }
                Navigator.pop(ctx);
              },
              child: const Text('Salva'),
            ),
          ],
        );
      },
    );
  }
}
