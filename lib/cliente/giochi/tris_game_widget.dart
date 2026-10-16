import 'dart:async';
import 'dart:math';

import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

import 'tris_game_model.dart';
export 'tris_game_model.dart';

class TrisGameWidget extends StatefulWidget {
  const TrisGameWidget({
    super.key,
    required this.ristoranteRef,
    this.tavoloPreimpostato,
  });

  final DocumentReference? ristoranteRef;
  final String? tavoloPreimpostato;

  static String routeName = 'TrisGame';
  static String routePath = '/trisGame';

  @override
  State<TrisGameWidget> createState() => _TrisGameWidgetState();
}

class _TrisGameWidgetState extends State<TrisGameWidget>
    with SingleTickerProviderStateMixin {
  late TrisGameModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  // Costanti linee vincenti
  static const List<List<int>> _winningLines = [
    [0, 1, 2], [3, 4, 5], [6, 7, 8], // Righe
    [0, 3, 6], [1, 4, 7], [2, 5, 8], // Colonne
    [0, 4, 8], [2, 4, 6],             // Diagonali
  ];

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => TrisGameModel());
    _model.tabController = TabController(length: 2, vsync: this);
    _model.tabController.addListener(() {
      if (_model.tabController.indexIsChanging) {
        safeSetState(() {
          _model.currentTabIndex = _model.tabController.index;
        });
      }
    });

    final defaultTable = widget.tavoloPreimpostato?.trim() ?? '';
    _model.myTableNumber = defaultTable.isNotEmpty
        ? defaultTable
        : (FFAppState().numeroTavolo.isNotEmpty
            ? FFAppState().numeroTavolo
            : 'Tavolo 1');

    _model.tableInputController =
        TextEditingController(text: _model.myTableNumber);
    _model.tableInputFocusNode = FocusNode();

    _resetLocalGame(keepScore: false);
  }

  @override
  void dispose() {
    _model.tabController.dispose();
    _model.dispose();
    super.dispose();
  }

  // ----------------------------------------------------
  // LOGICA LOCALE (Passa e Gioca / vs Bot)
  // ----------------------------------------------------
  void _resetLocalGame({bool keepScore = true}) {
    safeSetState(() {
      _model.localBoard = List.filled(9, '');
      _model.localTurn = 'X';
      _model.localWinner = null;
      _model.winningLine = null;
      if (!keepScore) {
        _model.scoreX = 0;
        _model.scoreO = 0;
        _model.draws = 0;
      }
    });
  }

  void _onLocalCellTap(int index) {
    if (_model.localBoard[index].isNotEmpty || _model.localWinner != null) {
      return;
    }

    HapticFeedback.lightImpact();

    safeSetState(() {
      _model.localBoard[index] = _model.localTurn;
    });

    final winnerInfo = _checkWinner(_model.localBoard);
    if (winnerInfo != null) {
      safeSetState(() {
        _model.localWinner = winnerInfo['winner'];
        _model.winningLine = (winnerInfo['line'] as List<int>);
        if (_model.localWinner == 'X') {
          _model.scoreX++;
        } else if (_model.localWinner == 'O') {
          _model.scoreO++;
        } else {
          _model.draws++;
        }
      });
      return;
    }

    // Passa turno
    final nextTurn = _model.localTurn == 'X' ? 'O' : 'X';
    safeSetState(() {
      _model.localTurn = nextTurn;
    });

    // Se è vs Bot e tocca a O
    if (_model.vsBot && nextTurn == 'O') {
      Timer(const Duration(milliseconds: 350), _makeBotMove);
    }
  }

  void _makeBotMove() {
    if (!mounted || _model.localWinner != null) return;

    // 1. Cerca mossa vincente per O
    for (int i = 0; i < 9; i++) {
      if (_model.localBoard[i].isEmpty) {
        final temp = List<String>.from(_model.localBoard);
        temp[i] = 'O';
        final w = _checkWinner(temp);
        if (w != null && w['winner'] == 'O') {
          _onLocalCellTap(i);
          return;
        }
      }
    }

    // 2. Blocca eventuale tris di X
    for (int i = 0; i < 9; i++) {
      if (_model.localBoard[i].isEmpty) {
        final temp = List<String>.from(_model.localBoard);
        temp[i] = 'X';
        final w = _checkWinner(temp);
        if (w != null && w['winner'] == 'X') {
          _onLocalCellTap(i);
          return;
        }
      }
    }

    // 3. Prendi il centro se libero
    if (_model.localBoard[4].isEmpty) {
      _onLocalCellTap(4);
      return;
    }

    // 4. Prendi un angolo o cella vuota a caso
    final emptyIndices = <int>[];
    for (int i = 0; i < 9; i++) {
      if (_model.localBoard[i].isEmpty) emptyIndices.add(i);
    }

    if (emptyIndices.isNotEmpty) {
      final randIndex = emptyIndices[Random().nextInt(emptyIndices.length)];
      _onLocalCellTap(randIndex);
    }
  }

  Map<String, dynamic>? _checkWinner(List<String> b) {
    for (final line in _winningLines) {
      final a = b[line[0]];
      final c = b[line[1]];
      final d = b[line[2]];
      if (a.isNotEmpty && a == c && a == d) {
        return {'winner': a, 'line': line};
      }
    }
    if (!b.contains('')) {
      return {'winner': 'draw', 'line': <int>[]};
    }
    return null;
  }

  // ----------------------------------------------------
  // LOGICA ONLINE MULTIPLAYER (Sfida tra Tavoli)
  // ----------------------------------------------------
  Future<void> _creaNuovaSfida() async {
    final mioTavolo = _model.myTableNumber?.trim() ?? 'Tavolo';
    final ref = await TrisMatchesRecord.collection.add(
      createTrisMatchesRecordData(
        ristoranteRef: widget.ristoranteRef,
        tavoloSfidante: mioTavolo,
        tavoloAvversario: '',
        sfidanteSimbolo: 'X',
        avversarioSimbolo: 'O',
        board: List.filled(9, ''),
        turno: 'X',
        stato: 'in_attesa',
        punteggioSfidante: 0,
        punteggioAvversario: 0,
        messaggioChat: '',
        messaggioMittente: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );

    safeSetState(() {
      _model.currentMatchId = ref.id;
    });
  }

  Future<void> _accettaSfida(TrisMatchesRecord match) async {
    final mioTavolo = _model.myTableNumber?.trim() ?? 'Tavolo';
    await match.reference.update(createTrisMatchesRecordData(
      tavoloAvversario: mioTavolo,
      stato: 'in_corso',
      updatedAt: DateTime.now(),
    ));

    safeSetState(() {
      _model.currentMatchId = match.reference.id;
    });
  }

  Future<void> _faiMossaOnline(
    TrisMatchesRecord match,
    int index,
    String mySymbol,
  ) async {
    if (match.stato != 'in_corso') return;
    if (match.turno != mySymbol) return;
    if (match.board[index].isNotEmpty) return;

    HapticFeedback.lightImpact();

    final newBoard = List<String>.from(match.board);
    newBoard[index] = mySymbol;

    final winnerInfo = _checkWinner(newBoard);
    String nuovoStato = 'in_corso';
    int newScoreSfidante = match.punteggioSfidante;
    int newScoreAvversario = match.punteggioAvversario;

    if (winnerInfo != null) {
      final winner = winnerInfo['winner'];
      if (winner == 'X') {
        nuovoStato = 'vittoria_x';
        newScoreSfidante++;
      } else if (winner == 'O') {
        nuovoStato = 'vittoria_o';
        newScoreAvversario++;
      } else {
        nuovoStato = 'pareggio';
      }
    }

    final prossimoTurno = mySymbol == 'X' ? 'O' : 'X';

    await match.reference.update(createTrisMatchesRecordData(
      board: newBoard,
      turno: prossimoTurno,
      stato: nuovoStato,
      punteggioSfidante: newScoreSfidante,
      punteggioAvversario: newScoreAvversario,
      updatedAt: DateTime.now(),
    ));
  }

  Future<void> _inviaReazioneOnline(
    TrisMatchesRecord match,
    String testo,
  ) async {
    HapticFeedback.selectionClick();
    final mioTavolo = _model.myTableNumber?.trim() ?? 'Tavolo';
    await match.reference.update(createTrisMatchesRecordData(
      messaggioChat: testo,
      messaggioMittente: mioTavolo,
      updatedAt: DateTime.now(),
    ));
  }

  Future<void> _rivincitaOnline(TrisMatchesRecord match) async {
    await match.reference.update(createTrisMatchesRecordData(
      board: List.filled(9, ''),
      turno: 'X',
      stato: 'in_corso',
      messaggioChat: '🔄 Partita riavviata! Buona fortuna!',
      messaggioMittente: _model.myTableNumber ?? 'Tavolo',
      updatedAt: DateTime.now(),
    ));
  }

  Future<void> _annullaOEsciOnline(TrisMatchesRecord match) async {
    if (match.stato == 'in_attesa') {
      await match.reference.delete();
    }
    safeSetState(() {
      _model.currentMatchId = null;
    });
  }

  // ----------------------------------------------------
  // BUILD PRINCIPALE
  // ----------------------------------------------------
  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          elevation: 0.0,
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
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.sports_esports_rounded,
                  color: Color(0xFF8B5CF6),
                  size: 20.0,
                ),
              ),
              const SizedBox(width: 10.0),
              Text(
                'Tris al Tavolo',
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
          centerTitle: true,
        ),
        body: SafeArea(
          top: true,
          child: Column(
            children: [
              // Tab Selector (Sfida al Tavolo vs Sfida tra Tavoli)
              Container(
                margin: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 12.0),
                padding: const EdgeInsets.all(4.0),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(
                    color: theme.dividerColor.withValues(alpha: 0.15),
                  ),
                ),
                child: TabBar(
                  controller: _model.tabController,
                  indicator: BoxDecoration(
                    color: const Color(0xFF8B5CF6),
                    borderRadius: BorderRadius.circular(12.0),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
                        blurRadius: 8.0,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor:
                      colorScheme.onSurface.withValues(alpha: 0.65),
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13.5,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13.5,
                  ),
                  tabs: const [
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.touch_app_rounded, size: 18.0),
                          SizedBox(width: 6.0),
                          Text('Al mio Tavolo'),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.sensors_rounded, size: 18.0),
                          SizedBox(width: 6.0),
                          Text('Sfida altri Tavoli'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Contenuto Tabs
              Expanded(
                child: TabBarView(
                  controller: _model.tabController,
                  children: [
                    _buildLocalGameView(theme, colorScheme),
                    _buildOnlineGameView(theme, colorScheme),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ----------------------------------------------------
  // VISTA 1: LOCALE (PASSA E GIOCA / VS BOT)
  // ----------------------------------------------------
  Widget _buildLocalGameView(ThemeData theme, ColorScheme colorScheme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 480.0),
          child: Column(
            children: [
              // Toggle modalità Passa e Gioca / vs Bot
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12.0, vertical: 6.0),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(14.0),
                  border: Border.all(
                    color: theme.dividerColor.withValues(alpha: 0.12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _model.vsBot
                              ? Icons.smart_toy_rounded
                              : Icons.groups_rounded,
                          size: 20.0,
                          color: const Color(0xFF8B5CF6),
                        ),
                        const SizedBox(width: 8.0),
                        Text(
                          _model.vsBot
                              ? 'Contro il Computer'
                              : '2 Giocatori (Passa & Gioca)',
                          style: TextStyle(
                            fontSize: 13.0,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    Switch.adaptive(
                      value: _model.vsBot,
                      activeThumbColor: const Color(0xFF8B5CF6),
                      onChanged: (val) {
                        safeSetState(() {
                          _model.vsBot = val;
                          _resetLocalGame(keepScore: false);
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14.0),

              // Tabellone Punteggi
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 12.0),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(18.0),
                  border: Border.all(
                    color: theme.dividerColor.withValues(alpha: 0.12),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10.0,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildPlayerScoreCard(
                      label: 'Giocatore ❌',
                      score: _model.scoreX,
                      color: const Color(0xFF06B6D4),
                      isActive: _model.localWinner == null &&
                          _model.localTurn == 'X',
                    ),
                    Column(
                      children: [
                        Text(
                          'PAREGGI',
                          style: TextStyle(
                            fontSize: 10.0,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.6,
                            color: theme.hintColor,
                          ),
                        ),
                        const SizedBox(height: 2.0),
                        Text(
                          '${_model.draws}',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    _buildPlayerScoreCard(
                      label: _model.vsBot ? 'Bot ⭕' : 'Giocatore ⭕',
                      score: _model.scoreO,
                      color: const Color(0xFFF43F5E),
                      isActive: _model.localWinner == null &&
                          _model.localTurn == 'O',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),

              // Banner Stato Turno / Vittoria
              _buildLocalStatusBar(theme),
              const SizedBox(height: 18.0),

              // Griglia 3x3 Tris
              _buildBoardGrid(
                board: _model.localBoard,
                winningLine: _model.winningLine,
                onTap: _onLocalCellTap,
                enabled: _model.localWinner == null &&
                    (!_model.vsBot || _model.localTurn == 'X'),
              ),
              const SizedBox(height: 24.0),

              // Bottoni Nuova Partita / Reset
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.0),
                        ),
                        side: BorderSide(
                          color: theme.dividerColor.withValues(alpha: 0.4),
                        ),
                      ),
                      onPressed: () => _resetLocalGame(keepScore: false),
                      icon: const Icon(Icons.refresh_rounded, size: 18.0),
                      label: const Text(
                        'Azzera Punti',
                        style: TextStyle(fontSize: 13.0),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B5CF6),
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.0),
                        ),
                        elevation: 0.0,
                      ),
                      onPressed: () => _resetLocalGame(keepScore: true),
                      icon: const Icon(Icons.play_arrow_rounded,
                          color: Colors.white, size: 20.0),
                      label: const Text(
                        'Nuova Partita',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerScoreCard({
    required String label,
    required int score,
    required Color color,
    required bool isActive,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: isActive ? color.withValues(alpha: 0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: isActive ? color : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12.0,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2.0),
          Text(
            '$score',
            style: TextStyle(
              fontSize: 22.0,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocalStatusBar(ThemeData theme) {
    String text;
    Color bg;
    Color fg;

    if (_model.localWinner == 'X') {
      text = '🎉 Ha vinto il Giocatore ❌!';
      bg = const Color(0xFF06B6D4).withValues(alpha: 0.15);
      fg = const Color(0xFF0891B2);
    } else if (_model.localWinner == 'O') {
      text = _model.vsBot ? '🤖 Ha vinto il Computer ⭕!' : '🎉 Ha vinto il Giocatore ⭕!';
      bg = const Color(0xFFF43F5E).withValues(alpha: 0.15);
      fg = const Color(0xFFE11D48);
    } else if (_model.localWinner == 'draw') {
      text = '🤝 Pareggio! Nessun vincitore!';
      bg = Colors.amber.withValues(alpha: 0.15);
      fg = Colors.amber.shade900;
    } else {
      final isX = _model.localTurn == 'X';
      text = isX
          ? 'Tocca a ❌'
          : (_model.vsBot ? 'Il Bot sta pensando... 🤔' : 'Tocca a ⭕');
      bg = (isX ? const Color(0xFF06B6D4) : const Color(0xFFF43F5E))
          .withValues(alpha: 0.10);
      fg = isX ? const Color(0xFF0891B2) : const Color(0xFFE11D48);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14.0),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 14.5,
          fontWeight: FontWeight.bold,
          color: fg,
        ),
      ),
    );
  }

  // ----------------------------------------------------
  // VISTA 2: SFIDA TRA TAVOLI (ONLINE MULTIPLAYER)
  // ----------------------------------------------------
  Widget _buildOnlineGameView(ThemeData theme, ColorScheme colorScheme) {
    if (_model.currentMatchId != null) {
      return StreamBuilder<TrisMatchesRecord>(
        stream: TrisMatchesRecord.getDocument(
          FirebaseFirestore.instance
              .collection('tris_matches')
              .doc(_model.currentMatchId!),
        ),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: SpinKitPulse(
                color: Color(0xFF8B5CF6),
                size: 40.0,
              ),
            );
          }

          final match = snapshot.data!;
          return _buildActiveOnlineMatch(theme, colorScheme, match);
        },
      );
    }

    // Lobby di attesa / selezione sfida
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 480.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Identificativo del mio tavolo
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(18.0),
                  border: Border.all(
                    color: theme.dividerColor.withValues(alpha: 0.15),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44.0,
                      height: 44.0,
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B5CF6).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.table_restaurant_rounded,
                        color: Color(0xFF8B5CF6),
                        size: 22.0,
                      ),
                    ),
                    const SizedBox(width: 14.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Il tuo Tavolo:',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: theme.hintColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2.0),
                          Text(
                            _model.myTableNumber ?? 'Non impostato',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF8B5CF6),
                      ),
                      onPressed: () => _modificaNumeroTavolo(theme),
                      icon: const Icon(Icons.edit_rounded, size: 16.0),
                      label: const Text('Cambia'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),

              // Bottone Lancia Sfida
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18.0),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF8B5CF6).withValues(alpha: 0.35),
                      blurRadius: 14.0,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18.0),
                    onTap: _creaNuovaSfida,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_circle_outline_rounded,
                              color: Colors.white, size: 22.0),
                          SizedBox(width: 10.0),
                          Text(
                            'Lancia una Nuova Sfida al Locale',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24.0),

              // Lista sfide aperte in attesa
              Text(
                'SFIDE APERTE NEL RISTORANTE',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.6,
                  color: theme.hintColor,
                ),
              ),
              const SizedBox(height: 10.0),

              StreamBuilder<List<TrisMatchesRecord>>(
                stream: queryTrisMatchesRecord(
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
                        child: SpinKitPulse(
                          color: Color(0xFF8B5CF6),
                          size: 36.0,
                        ),
                      ),
                    );
                  }

                  final matches = snapshot.data!;
                  // Filtra escludendo sfide create da me stesso
                  final mioTavolo = _model.myTableNumber ?? '';
                  final sfideAltri = matches
                      .where((m) => m.tavoloSfidante != mioTavolo)
                      .toList();
                  final mieSfideInAttesa = matches
                      .where((m) => m.tavoloSfidante == mioTavolo)
                      .toList();

                  return Column(
                    children: [
                      // Se ho una mia sfida in attesa
                      if (mieSfideInAttesa.isNotEmpty) ...[
                        Container(
                          margin: const EdgeInsets.only(bottom: 14.0),
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: const Color(0xFF8B5CF6)
                                .withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(16.0),
                            border: Border.all(
                              color: const Color(0xFF8B5CF6)
                                  .withValues(alpha: 0.35),
                            ),
                          ),
                          child: Row(
                            children: [
                              const SpinKitPulse(
                                color: Color(0xFF8B5CF6),
                                size: 28.0,
                              ),
                              const SizedBox(width: 14.0),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'La tua sfida è aperta!',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14.0,
                                        color: Color(0xFF7C3AED),
                                      ),
                                    ),
                                    SizedBox(height: 2.0),
                                    Text(
                                      'In attesa che un altro tavolo accetti...',
                                      style: TextStyle(fontSize: 12.0),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close_rounded,
                                    color: Colors.red, size: 20.0),
                                onPressed: () =>
                                    _annullaOEsciOnline(mieSfideInAttesa.first),
                              ),
                            ],
                          ),
                        ),
                      ],

                      if (sfideAltri.isEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 32.0),
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            borderRadius: BorderRadius.circular(16.0),
                            border: Border.all(
                              color: theme.dividerColor.withValues(alpha: 0.12),
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.sports_esports_outlined,
                                size: 44.0,
                                color: theme.hintColor.withValues(alpha: 0.6),
                              ),
                              const SizedBox(height: 10.0),
                              Text(
                                'Nessun tavolo in attesa al momento',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4.0),
                              Text(
                                'Tocca il pulsante sopra per lanciare la prima sfida del locale!',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: theme.hintColor,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        ...sfideAltri.map((match) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10.0),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 12.0),
                            decoration: BoxDecoration(
                              color: theme.cardColor,
                              borderRadius: BorderRadius.circular(16.0),
                              border: Border.all(
                                color:
                                    theme.dividerColor.withValues(alpha: 0.12),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.02),
                                  blurRadius: 8.0,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 40.0,
                                  height: 40.0,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF06B6D4)
                                        .withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  alignment: Alignment.center,
                                  child: const Text(
                                    'VS',
                                    style: TextStyle(
                                      color: Color(0xFF0891B2),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13.0,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12.0),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        match.tavoloSfidante,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14.5,
                                        ),
                                      ),
                                      const SizedBox(height: 2.0),
                                      Text(
                                        'Cerca sfidante per Tris',
                                        style: TextStyle(
                                          fontSize: 11.5,
                                          color: theme.hintColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF8B5CF6),
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(10.0),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14.0, vertical: 8.0),
                                    elevation: 0.0,
                                  ),
                                  onPressed: () => _accettaSfida(match),
                                  child: const Text(
                                    'Accetta',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ----------------------------------------------------
  // VISTA 3: PARTITA ATTIVA TRA DUE TAVOLI
  // ----------------------------------------------------
  Widget _buildActiveOnlineMatch(
    ThemeData theme,
    ColorScheme colorScheme,
    TrisMatchesRecord match,
  ) {
    final mioTavolo = _model.myTableNumber ?? '';
    final isSfidante = match.tavoloSfidante == mioTavolo;
    final mySymbol = isSfidante ? match.sfidanteSimbolo : match.avversarioSimbolo;
    final opponentTable =
        isSfidante ? match.tavoloAvversario : match.tavoloSfidante;
    final isMyTurn = match.turno == mySymbol && match.stato == 'in_corso';

    // Rileva linea vincente per evidenziare
    final winnerCheck = _checkWinner(match.board);
    final List<int>? winningLine =
        winnerCheck != null ? (winnerCheck['line'] as List<int>) : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 480.0),
          child: Column(
            children: [
              // Header Partita (Tavolo A vs Tavolo B + Punteggi)
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 12.0),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(18.0),
                  border: Border.all(
                    color: theme.dividerColor.withValues(alpha: 0.12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildOnlinePlayerCard(
                      label: '$mioTavolo (Tu: $mySymbol)',
                      score: isSfidante
                          ? match.punteggioSfidante
                          : match.punteggioAvversario,
                      color: mySymbol == 'X'
                          ? const Color(0xFF06B6D4)
                          : const Color(0xFFF43F5E),
                      isActive: isMyTurn,
                    ),
                    const Text(
                      'VS',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.0,
                        color: Colors.grey,
                      ),
                    ),
                    _buildOnlinePlayerCard(
                      label: '$opponentTable (${mySymbol == 'X' ? 'O' : 'X'})',
                      score: isSfidante
                          ? match.punteggioAvversario
                          : match.punteggioSfidante,
                      color: mySymbol == 'X'
                          ? const Color(0xFFF43F5E)
                          : const Color(0xFF06B6D4),
                      isActive: !isMyTurn && match.stato == 'in_corso',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12.0),

              // Banner dinamico del turno / risultato
              _buildOnlineStatusBar(match, isMyTurn, mySymbol, opponentTable),
              const SizedBox(height: 12.0),

              // Chat / Reazione rapida dell'avversario
              if (match.messaggioChat.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(bottom: 12.0),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14.0, vertical: 8.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5CF6).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(
                      color: const Color(0xFF8B5CF6).withValues(alpha: 0.25),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.chat_bubble_outline_rounded,
                          size: 16.0, color: Color(0xFF8B5CF6)),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: Text(
                          '${match.messaggioMittente}: "${match.messaggioChat}"',
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Griglia 3x3 sincronizzata
              _buildBoardGrid(
                board: match.board,
                winningLine: winningLine,
                onTap: (idx) => _faiMossaOnline(match, idx, mySymbol),
                enabled: isMyTurn,
              ),
              const SizedBox(height: 16.0),

              // Reazioni rapide cliccabili
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildReactionPill('👏 Bravo!', match),
                    _buildReactionPill('😅 Per poco!', match),
                    _buildReactionPill('☕ Chi perde offre!', match),
                    _buildReactionPill('👀 Attento!', match),
                    _buildReactionPill('🔄 Rivincita?', match),
                  ],
                ),
              ),
              const SizedBox(height: 20.0),

              // Bottoni di fine partita o abbandono
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.0),
                        ),
                        side: BorderSide(
                          color: theme.dividerColor.withValues(alpha: 0.35),
                        ),
                      ),
                      onPressed: () => _annullaOEsciOnline(match),
                      child: const Text('Esci dalla Sfida'),
                    ),
                  ),
                  if (match.stato != 'in_corso' && match.stato != 'in_attesa') ...[
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8B5CF6),
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.0),
                          ),
                          elevation: 0.0,
                        ),
                        onPressed: () => _rivincitaOnline(match),
                        icon: const Icon(Icons.replay_rounded,
                            color: Colors.white, size: 18.0),
                        label: const Text(
                          'Rivincita',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOnlinePlayerCard({
    required String label,
    required int score,
    required Color color,
    required bool isActive,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: isActive ? color.withValues(alpha: 0.12) : Colors.transparent,
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(
          color: isActive ? color : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2.0),
          Text(
            '$score',
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOnlineStatusBar(
    TrisMatchesRecord match,
    bool isMyTurn,
    String mySymbol,
    String opponentTable,
  ) {
    String text;
    Color bg;
    Color fg;

    if (match.stato == 'in_attesa') {
      text = 'In attesa che l\'avversario si connetta...';
      bg = Colors.amber.withValues(alpha: 0.15);
      fg = Colors.amber.shade900;
    } else if (match.stato == 'vittoria_x') {
      final iWon = mySymbol == 'X';
      text = iWon ? '🎉 Congratulazioni! Hai vinto tu!' : '👏 Ha vinto $opponentTable!';
      bg = (iWon ? const Color(0xFF10B981) : const Color(0xFFEF4444))
          .withValues(alpha: 0.15);
      fg = iWon ? const Color(0xFF059669) : const Color(0xFFDC2626);
    } else if (match.stato == 'vittoria_o') {
      final iWon = mySymbol == 'O';
      text = iWon ? '🎉 Congratulazioni! Hai vinto tu!' : '👏 Ha vinto $opponentTable!';
      bg = (iWon ? const Color(0xFF10B981) : const Color(0xFFEF4444))
          .withValues(alpha: 0.15);
      fg = iWon ? const Color(0xFF059669) : const Color(0xFFDC2626);
    } else if (match.stato == 'pareggio') {
      text = '🤝 Pareggio tra i due tavoli!';
      bg = Colors.amber.withValues(alpha: 0.15);
      fg = Colors.amber.shade900;
    } else {
      if (isMyTurn) {
        text = '🟢 Tocca a te! Fai la tua mossa';
        bg = const Color(0xFF10B981).withValues(alpha: 0.15);
        fg = const Color(0xFF059669);
      } else {
        text = '⏳ In attesa della mossa di $opponentTable...';
        bg = Colors.grey.withValues(alpha: 0.12);
        fg = Colors.grey.shade700;
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14.0),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 13.5,
          fontWeight: FontWeight.bold,
          color: fg,
        ),
      ),
    );
  }

  Widget _buildReactionPill(String text, TrisMatchesRecord match) {
    return Container(
      margin: const EdgeInsets.only(right: 8.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14.0),
          onTap: () => _inviaReazioneOnline(match, text),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(14.0),
              border: Border.all(
                color: Theme.of(context).dividerColor.withValues(alpha: 0.15),
              ),
            ),
            child: Text(
              text,
              style: const TextStyle(fontSize: 12.0, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }

  // ----------------------------------------------------
  // GRIGLIA 3x3 CONDIVISA (BELLA & RESPONSIVE)
  // ----------------------------------------------------
  Widget _buildBoardGrid({
    required List<String> board,
    required List<int>? winningLine,
    required ValueChanged<int> onTap,
    required bool enabled,
  }) {
    return Container(
      width: 320.0,
      height: 320.0,
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24.0),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.15),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 18.0,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 9,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 10.0,
          mainAxisSpacing: 10.0,
        ),
        itemBuilder: (context, index) {
          final val = index < board.length ? board[index] : '';
          final isWinningCell = winningLine?.contains(index) ?? false;

          Color cellColor;
          Color borderColor;
          if (isWinningCell) {
            cellColor = const Color(0xFFF59E0B).withValues(alpha: 0.20);
            borderColor = const Color(0xFFF59E0B);
          } else {
            cellColor =
                Theme.of(context).dividerColor.withValues(alpha: 0.04);
            borderColor =
                Theme.of(context).dividerColor.withValues(alpha: 0.12);
          }

          return Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16.0),
              onTap: enabled && val.isEmpty ? () => onTap(index) : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: cellColor,
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(color: borderColor, width: isWinningCell ? 2.5 : 1.2),
                ),
                alignment: Alignment.center,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  transitionBuilder: (child, anim) => ScaleTransition(
                    scale: anim,
                    child: child,
                  ),
                  child: val == 'X'
                      ? const Text(
                          '✕',
                          key: ValueKey('X'),
                          style: TextStyle(
                            fontSize: 48.0,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF06B6D4),
                            height: 1.0,
                          ),
                        )
                      : (val == 'O'
                          ? const Text(
                              '○',
                              key: ValueKey('O'),
                              style: TextStyle(
                                fontSize: 52.0,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFF43F5E),
                                height: 1.0,
                              ),
                            )
                          : const SizedBox.shrink()),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _modificaNumeroTavolo(ThemeData theme) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          title: const Text('Modifica il tuo Tavolo'),
          content: TextField(
            controller: _model.tableInputController,
            focusNode: _model.tableInputFocusNode,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Es. Tavolo 5',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Annulla'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B5CF6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              onPressed: () {
                final txt = _model.tableInputController?.text.trim() ?? '';
                if (txt.isNotEmpty) {
                  safeSetState(() {
                    _model.myTableNumber = txt;
                    FFAppState().numeroTavolo = txt;
                  });
                }
                Navigator.pop(ctx);
              },
              child: const Text('Salva', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
