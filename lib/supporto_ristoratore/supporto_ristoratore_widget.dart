import '/auth/firebase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'supporto_ristoratore_model.dart';
export 'supporto_ristoratore_model.dart';

class SupportoRistoratoreWidget extends StatefulWidget {
  const SupportoRistoratoreWidget({
    super.key,
    this.ristoranteRef,
    this.embedded = false,
  });

  final DocumentReference? ristoranteRef;
  final bool embedded;

  static String routeName = 'SupportoRistoratore';
  static String routePath = '/supportoRistoratore';

  @override
  State<SupportoRistoratoreWidget> createState() =>
      _SupportoRistoratoreWidgetState();
}

class _SupportoRistoratoreWidgetState extends State<SupportoRistoratoreWidget> {
  late SupportoRistoratoreModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  bool _hasAutoSwitchedTab = false;
  int? _expandedFaqIndex;

  final List<Map<String, String>> _categorieSupporto = [
    {'icon': '🍽️', 'nome': 'Menù & Piatti'},
    {'icon': '📋', 'nome': 'Comande & Tavoli'},
    {'icon': '🎵', 'nome': 'Jukebox'},
    {'icon': '💳', 'nome': 'Abbonamento'},
    {'icon': '⚙️', 'nome': 'Altro'},
  ];

  final List<Map<String, String>> _faqItems = [
    {
      'q': 'Come stampo o scarico i QR Code per i tavoli?',
      'a':
          'Accedi a Impostazioni > QR Code Menù. Da lì puoi scaricare il PDF pronto per la stampa con il QR Code di ciascun tavolo o il QR Code generale.',
    },
    {
      'q': 'Come posso aggiungere varianti ed extra a pagamento ai piatti?',
      'a':
          'Accedi alla sezione Menù, modifica o crea un piatto e apri la gestione Varianti/Extra, oppure abilita gli ingredienti della Dispensa come aggiunte ordinate.',
    },
    {
      'q': 'Come funzionano le notifiche delle nuove comande?',
      'a':
          'Assicurati di tenere aperta la dashboard "Ordini" con l\'audio attivo del dispositivo: un segnale sonoro e visivo ti avviserà all\'istante per ogni nuovo ordine.',
    },
    {
      'q': 'Come posso modificare i dati fiscali o il piano di abbonamento?',
      'a':
          'Dalla sezione Impostazioni > Gestisci abbonamento puoi gestire il metodo di pagamento, visualizzare le fatture e passare al piano superiore.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SupportoRistoratoreModel());

    _model.titoloTicketTextController ??= TextEditingController();
    _model.titoloTicketFocusNode ??= FocusNode();

    _model.descrizioneTicketTextController ??= TextEditingController();
    _model.descrizioneTicketFocusNode ??= FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _inviaTicket(ThemeData theme) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final titoloBase = _model.titoloTicketTextController!.text.trim();
    final descrizione = _model.descrizioneTicketTextController!.text.trim();
    final categoria = _model.categoriaSelezionata;

    final String titoloCompleto =
        categoria != null ? '[$categoria] $titoloBase' : titoloBase;

    safeSetState(() => _model.isSubmitting = true);

    try {
      await TicketsRecord.collection.doc().set(createTicketsRecordData(
            titolo: titoloCompleto,
            descrizione: descrizione,
            ristoratoreRef: currentUserReference,
            dataCreazione: getCurrentTimestamp,
            stato: 'Aperto',
          ));

      try {
        await InviaNotificaWhatsAppCall.call(
          messaggioTicket:
              '🚨 Nuovo Ticket su ProntoMenu!\nLocale: ${currentUserDisplayName.isNotEmpty ? currentUserDisplayName : currentUserEmail}\nProblema: $titoloCompleto',
        );
      } catch (_) {}

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded,
                  color: Colors.white, size: 20.0),
              const SizedBox(width: 10.0),
              Expanded(
                child: Text(
                  'Ticket inviato con successo! Ti risponderemo al più presto.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          duration: const Duration(seconds: 4),
        ),
      );

      safeSetState(() {
        _model.titoloTicketTextController?.clear();
        _model.descrizioneTicketTextController?.clear();
        _model.categoriaSelezionata = null;
        _model.isSubmitting = false;
        _model.selectedTabIndex = 1; // Passa alla vista ticket
      });
    } catch (e) {
      if (!mounted) return;
      safeSetState(() => _model.isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Errore durante l\'invio: $e'),
          backgroundColor: theme.colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    // Palette uniforme con il design system della Dashboard
    final bgCanvas = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSecondary =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: bgCanvas,
        appBar: widget.embedded
            ? null
            : AppBar(
                backgroundColor: bgCanvas,
                elevation: 0.0,
                scrolledUnderElevation: 0.0,
                centerTitle: true,
                automaticallyImplyLeading: false,
                leading: FlutterFlowIconButton(
                  borderColor: Colors.transparent,
                  borderRadius: 24.0,
                  borderWidth: 1.0,
                  buttonSize: 40.0,
                  icon: Icon(
                    Icons.arrow_back_rounded,
                    color: colorScheme.onSurface,
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
                        color: colorScheme.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.support_agent_rounded,
                        color: colorScheme.primary,
                        size: 20.0,
                      ),
                    ),
                    const SizedBox(width: 10.0),
                    Text(
                      'Supporto Clienti',
                      style: theme.appBarTheme.titleTextStyle ??
                          theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 19.0,
                            letterSpacing: -0.4,
                            color: colorScheme.onSurface,
                          ),
                    ),
                  ],
                ),
                actions: const [
                  SizedBox(width: 48.0),
                ],
              ),
        body: SafeArea(
          top: true,
          child: StreamBuilder<List<TicketsRecord>>(
            stream: queryTicketsRecord(
              queryBuilder: (ticketsRecord) => ticketsRecord
                  .where('ristoratore_ref', isEqualTo: currentUserReference)
                  .orderBy('data_creazione', descending: true),
            ),
            builder: (context, snapshot) {
              final allTickets = snapshot.data ?? [];
              final unreadTickets = allTickets.where((t) =>
                  t.rispostaAdmin.trim().isNotEmpty && !t.rispostaLetta).toList();
              final hasUnreadReply = unreadTickets.isNotEmpty;

              if (hasUnreadReply && !_hasAutoSwitchedTab) {
                _hasAutoSwitchedTab = true;
                _model.selectedTabIndex = 1;
              }

              // Se l'utente è sulla schermata dei ticket e ci sono risposte non lette, segnale come lette
              if (_model.selectedTabIndex == 1 && hasUnreadReply) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  for (final t in unreadTickets) {
                    t.reference.update({'risposta_letta': true});
                  }
                });
              }

              final int apertiCount =
                  allTickets.where((t) => t.stato == 'Aperto').length;
              final int risoltiCount =
                  allTickets.where((t) => t.stato == 'Risolto').length;

              return Align(
                alignment: Alignment.topCenter,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final bool isDesktop =
                        widget.embedded || constraints.maxWidth >= 920;

                    return ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: isDesktop ? 1240.0 : 680.0,
                      ),
                      child: SingleChildScrollView(
                        controller: _model.scrollController,
                        padding: EdgeInsets.symmetric(
                          horizontal: isDesktop ? 28.0 : 18.0,
                          vertical: 20.0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // ── Header Titolo & Selettore Tab ───────────────────────────
                            _buildHeaderSection(
                              theme: theme,
                              colorScheme: colorScheme,
                              isDark: isDark,
                              isDesktop: isDesktop,
                              textPrimary: textPrimary,
                              textSecondary: textSecondary,
                              ticketCount: allTickets.length,
                              hasUnreadReply: hasUnreadReply,
                            ),
                            const SizedBox(height: 24.0),

                            // ── Vista Desktop a 2 Colonne o Mobile a Colonna Singola ───
                            if (isDesktop)
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Colonna Sinistra Principale (~63%): Form o Lista Ticket
                                  Expanded(
                                    flex: 63,
                                    child: _model.selectedTabIndex == 0
                                        ? _buildNuovaRichiestaTab(
                                            theme,
                                            colorScheme,
                                            isDark,
                                          )
                                        : _buildIMieiTicketTab(
                                            theme,
                                            colorScheme,
                                            isDark,
                                            allTickets: allTickets,
                                            isLoading: !snapshot.hasData,
                                          ),
                                  ),
                                  const SizedBox(width: 24.0),
                                  // Colonna Destra (~37%): Statistiche, Assistenza Diretta & FAQ
                                  Expanded(
                                    flex: 37,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        _buildTicketStatsCard(
                                          theme,
                                          isDark,
                                          apertiCount: apertiCount,
                                          risoltiCount: risoltiCount,
                                          totalCount: allTickets.length,
                                          hasUnread: hasUnreadReply,
                                        ),
                                        const SizedBox(height: 20.0),
                                        _buildAssistenzaDirettaCard(
                                            theme, colorScheme, isDark),
                                        const SizedBox(height: 20.0),
                                        _buildFaqCard(
                                            theme, colorScheme, isDark),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            else ...[
                              // Layout Mobile
                              if (_model.selectedTabIndex == 0)
                                _buildNuovaRichiestaTab(
                                    theme, colorScheme, isDark)
                              else
                                _buildIMieiTicketTab(
                                  theme,
                                  colorScheme,
                                  isDark,
                                  allTickets: allTickets,
                                  isLoading: !snapshot.hasData,
                                ),
                              const SizedBox(height: 24.0),
                              _buildTicketStatsCard(
                                theme,
                                isDark,
                                apertiCount: apertiCount,
                                risoltiCount: risoltiCount,
                                totalCount: allTickets.length,
                                hasUnread: hasUnreadReply,
                              ),
                              const SizedBox(height: 20.0),
                              _buildAssistenzaDirettaCard(
                                  theme, colorScheme, isDark),
                              const SizedBox(height: 20.0),
                              _buildFaqCard(theme, colorScheme, isDark),
                            ],

                            const SizedBox(height: 40.0),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // HEADER CON TITOLO & TAB SELECTOR
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildHeaderSection({
    required ThemeData theme,
    required ColorScheme colorScheme,
    required bool isDark,
    required bool isDesktop,
    required Color textPrimary,
    required Color textSecondary,
    required int ticketCount,
    required bool hasUnreadReply,
  }) {
    final titleBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Centro Assistenza & Supporto',
          style: TextStyle(
            fontSize: isDesktop ? 22.0 : 19.0,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            color: textPrimary,
          ),
        ),
        const SizedBox(height: 4.0),
        Text(
          'Invia una richiesta al nostro team o consulta lo stato delle segnalazioni.',
          style: TextStyle(
            fontSize: 13.5,
            color: textSecondary,
            height: 1.35,
          ),
        ),
      ],
    );

    final tabSelector = _buildSegmentedTabSelector(
      theme,
      colorScheme,
      isDark,
      ticketCount: ticketCount,
      hasUnreadReply: hasUnreadReply,
    );

    if (isDesktop) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(child: titleBlock),
          const SizedBox(width: 20.0),
          SizedBox(width: 360.0, child: tabSelector),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          titleBlock,
          const SizedBox(height: 16.0),
          tabSelector,
        ],
      );
    }
  }

  Widget _buildSegmentedTabSelector(
    ThemeData theme,
    ColorScheme colorScheme,
    bool isDark, {
    required int ticketCount,
    required bool hasUnreadReply,
  }) {
    final tabBg = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1);

    return Container(
      padding: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        color: tabBg,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(
          color: borderColor,
          width: 1.0,
        ),
      ),
      child: Row(
        children: [
          // Tab 0: Nuova Richiesta
          Expanded(
            child: InkWell(
              onTap: () => safeSetState(() => _model.selectedTabIndex = 0),
              borderRadius: BorderRadius.circular(10.0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding:
                    const EdgeInsets.symmetric(vertical: 9.0, horizontal: 8.0),
                decoration: BoxDecoration(
                  color: _model.selectedTabIndex == 0
                      ? colorScheme.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10.0),
                  boxShadow: _model.selectedTabIndex == 0
                      ? [
                          BoxShadow(
                            color: colorScheme.primary.withValues(alpha: 0.3),
                            blurRadius: 6.0,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_circle_outline_rounded,
                      size: 16.0,
                      color: _model.selectedTabIndex == 0
                          ? Colors.white
                          : (isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF64748B)),
                    ),
                    const SizedBox(width: 6.0),
                    Flexible(
                      child: Text(
                        'Nuova Richiesta',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13.0,
                          fontWeight: FontWeight.bold,
                          color: _model.selectedTabIndex == 0
                              ? Colors.white
                              : (isDark
                                  ? const Color(0xFFCBD5E1)
                                  : const Color(0xFF334155)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 4.0),
          // Tab 1: I Miei Ticket
          Expanded(
            child: InkWell(
              onTap: () => safeSetState(() => _model.selectedTabIndex = 1),
              borderRadius: BorderRadius.circular(10.0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding:
                    const EdgeInsets.symmetric(vertical: 9.0, horizontal: 8.0),
                decoration: BoxDecoration(
                  color: _model.selectedTabIndex == 1
                      ? colorScheme.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10.0),
                  boxShadow: _model.selectedTabIndex == 1
                      ? [
                          BoxShadow(
                            color: colorScheme.primary.withValues(alpha: 0.3),
                            blurRadius: 6.0,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.inbox_rounded,
                      size: 16.0,
                      color: _model.selectedTabIndex == 1
                          ? Colors.white
                          : (isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF64748B)),
                    ),
                    const SizedBox(width: 6.0),
                    Flexible(
                      child: Text(
                        ticketCount > 0
                            ? 'I Miei Ticket ($ticketCount)'
                            : 'I Miei Ticket',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13.0,
                          fontWeight: FontWeight.bold,
                          color: _model.selectedTabIndex == 1
                              ? Colors.white
                              : (isDark
                                  ? const Color(0xFFCBD5E1)
                                  : const Color(0xFF334155)),
                        ),
                      ),
                    ),
                    if (hasUnreadReply) ...[
                      const SizedBox(width: 5.0),
                      Container(
                        width: 8.0,
                        height: 8.0,
                        decoration: const BoxDecoration(
                          color: Color(0xFFEF4444),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TAB 0: NUOVA RICHIESTA DI SUPPORTO
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildNuovaRichiestaTab(
    ThemeData theme,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor =
        isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final inputBg =
        isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSecondary =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Banner Hero Informativo
          Container(
            padding: const EdgeInsets.all(18.0),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(color: borderColor, width: 1.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.03),
                  blurRadius: 10.0,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 48.0,
                  height: 48.0,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14.0),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.headset_mic_rounded,
                    color: colorScheme.primary,
                    size: 26.0,
                  ),
                ),
                const SizedBox(width: 14.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Come possiamo aiutarti?',
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                                color: textPrimary,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8.0, vertical: 3.5),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981)
                                  .withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8.0),
                              border: Border.all(
                                color: const Color(0xFF10B981)
                                    .withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6.0,
                                  height: 6.0,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF10B981),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 5.0),
                                const Text(
                                  'Supporto Attivo',
                                  style: TextStyle(
                                    fontSize: 11.0,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF10B981),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        'Descrivi il tuo dubbio o la configurazione che desideri: riceverai assistenza qualificata in brevissimo tempo.',
                        style: TextStyle(
                          fontSize: 13.0,
                          color: textSecondary,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18.0),

          // Selettore Argomento / Categoria
          Container(
            padding: const EdgeInsets.all(18.0),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(color: borderColor, width: 1.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.03),
                  blurRadius: 10.0,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.category_rounded,
                      size: 16.0,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 8.0),
                    Text(
                      'Seleziona l\'argomento',
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12.0),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: _categorieSupporto.map((cat) {
                    final bool isSelected =
                        _model.categoriaSelezionata == cat['nome'];
                    return InkWell(
                      onTap: () {
                        safeSetState(() {
                          _model.categoriaSelezionata =
                              isSelected ? null : cat['nome'];
                        });
                      },
                      borderRadius: BorderRadius.circular(10.0),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12.0, vertical: 7.5),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? colorScheme.primary.withValues(alpha: 0.15)
                              : (isDark
                                  ? const Color(0xFF0F172A)
                                  : const Color(0xFFF1F5F9)),
                          borderRadius: BorderRadius.circular(10.0),
                          border: Border.all(
                            color: isSelected
                                ? colorScheme.primary
                                : borderColor,
                            width: isSelected ? 1.5 : 1.0,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(cat['icon']!,
                                style: const TextStyle(fontSize: 13.0)),
                            const SizedBox(width: 6.0),
                            Text(
                              cat['nome']!,
                              style: TextStyle(
                                fontSize: 13.0,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                                color: isSelected
                                    ? colorScheme.primary
                                    : textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18.0),

          // Modulo Ticket (Oggetto, Messaggio & Invio)
          Container(
            padding: const EdgeInsets.all(22.0),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(color: borderColor, width: 1.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.03),
                  blurRadius: 10.0,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Campo Oggetto
                Text(
                  'Oggetto della richiesta',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 8.0),
                TextFormField(
                  controller: _model.titoloTicketTextController,
                  focusNode: _model.titoloTicketFocusNode,
                  autofocus: false,
                  enabled: !_model.isSubmitting,
                  decoration: InputDecoration(
                    hintText:
                        'Es: Problema con la stampa, modifica orari o prezzi...',
                    hintStyle: TextStyle(
                      color: textSecondary.withValues(alpha: 0.7),
                      fontSize: 13.5,
                    ),
                    prefixIcon: Icon(
                      Icons.title_rounded,
                      color: colorScheme.primary,
                      size: 20.0,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 14.0,
                    ),
                    filled: true,
                    fillColor: inputBg,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(
                        color: colorScheme.primary,
                        width: 1.5,
                      ),
                    ),
                  ),
                  style: TextStyle(
                    fontSize: 14.0,
                    color: textPrimary,
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Inserisci l\'oggetto del problema';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18.0),

                // Campo Descrizione
                Text(
                  'Descrizione dettagliata',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 8.0),
                TextFormField(
                  controller: _model.descrizioneTicketTextController,
                  focusNode: _model.descrizioneTicketFocusNode,
                  autofocus: false,
                  enabled: !_model.isSubmitting,
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText:
                        'Spiega nel dettaglio cosa accade o cosa vorresti configurare. Più dettagli fornisci, più rapida sarà la soluzione...',
                    hintStyle: TextStyle(
                      color: textSecondary.withValues(alpha: 0.7),
                      fontSize: 13.5,
                    ),
                    contentPadding: const EdgeInsets.all(16.0),
                    filled: true,
                    fillColor: inputBg,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(
                        color: colorScheme.primary,
                        width: 1.5,
                      ),
                    ),
                  ),
                  style: TextStyle(
                    fontSize: 14.0,
                    color: textPrimary,
                    height: 1.4,
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Inserisci una descrizione per aiutarci ad assisterti';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 22.0),

                // Pulsante Invia Richiesta
                FFButtonWidget(
                  onPressed: _model.isSubmitting
                      ? null
                      : () => _inviaTicket(theme),
                  text: _model.isSubmitting
                      ? 'Invio in corso...'
                      : 'Invia Richiesta di Aiuto',
                  icon: _model.isSubmitting
                      ? null
                      : const Icon(
                          Icons.send_rounded,
                          size: 18.0,
                          color: Colors.white,
                        ),
                  options: FFButtonOptions(
                    height: 48.0,
                    color: colorScheme.primary,
                    textStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 15.0,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.2,
                    ),
                    elevation: 1.0,
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TAB 1: I MIEI TICKET & STORICO
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildIMieiTicketTab(
    ThemeData theme,
    ColorScheme colorScheme,
    bool isDark, {
    required List<TicketsRecord> allTickets,
    required bool isLoading,
  }) {
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor =
        isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSecondary =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    if (isLoading) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 60.0),
          child: SpinKitPulse(
            color: colorScheme.primary,
            size: 44.0,
          ),
        ),
      );
    }

    // Filtra in base a _model.filtroStato
    final List<TicketsRecord> ticketsFiltrati = allTickets.where((t) {
      if (_model.filtroStato == 'Aperto') return t.stato == 'Aperto';
      if (_model.filtroStato == 'Risolto') return t.stato == 'Risolto';
      return true;
    }).toList();

    final int apertiCount =
        allTickets.where((t) => t.stato == 'Aperto').length;
    final int risoltiCount =
        allTickets.where((t) => t.stato == 'Risolto').length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Barra dei Filtri Rapidi
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFiltroPill(
                isDark: isDark,
                colorScheme: colorScheme,
                label: 'Tutti (${allTickets.length})',
                isSelected: _model.filtroStato == 'Tutti',
                onTap: () => safeSetState(() => _model.filtroStato = 'Tutti'),
              ),
              const SizedBox(width: 8.0),
              _buildFiltroPill(
                isDark: isDark,
                colorScheme: colorScheme,
                label: 'In Attesa ($apertiCount)',
                isSelected: _model.filtroStato == 'Aperto',
                accentColor: const Color(0xFFF59E0B),
                onTap: () => safeSetState(() => _model.filtroStato = 'Aperto'),
              ),
              const SizedBox(width: 8.0),
              _buildFiltroPill(
                isDark: isDark,
                colorScheme: colorScheme,
                label: 'Risolti ($risoltiCount)',
                isSelected: _model.filtroStato == 'Risolto',
                accentColor: const Color(0xFF10B981),
                onTap: () => safeSetState(() => _model.filtroStato = 'Risolto'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16.0),

        if (ticketsFiltrati.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 24.0, vertical: 48.0),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(color: borderColor, width: 1.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56.0,
                  height: 56.0,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.10),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.mark_email_read_outlined,
                    size: 28.0,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 14.0),
                Text(
                  _model.filtroStato == 'Aperto'
                      ? 'Nessun ticket in attesa!'
                      : 'Nessuna segnalazione trovata',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 6.0),
                Text(
                  _model.filtroStato == 'Aperto'
                      ? 'Tutte le tue richieste sono state prese in carico e risolte dal team.'
                      : 'Se riscontri qualsiasi difficoltà o hai una domanda, apri una nuova richiesta!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.0,
                    color: textSecondary,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 16.0),
                ElevatedButton.icon(
                  onPressed: () =>
                      safeSetState(() => _model.selectedTabIndex = 0),
                  icon: const Icon(Icons.add_rounded, size: 16.0),
                  label: const Text('Crea Nuova Richiesta'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 10.0),
                  ),
                ),
              ],
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: ticketsFiltrati.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12.0),
            itemBuilder: (context, index) {
              final ticket = ticketsFiltrati[index];
              return _buildClienteTicketCard(
                theme,
                colorScheme,
                isDark,
                ticket,
              );
            },
          ),
      ],
    );
  }

  Widget _buildFiltroPill({
    required bool isDark,
    required ColorScheme colorScheme,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    Color? accentColor,
  }) {
    final activeColor = accentColor ?? colorScheme.primary;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor =
        isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 7.0),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withValues(alpha: 0.15)
              : cardBg,
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(
            color: isSelected ? activeColor : borderColor,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected
                ? activeColor
                : (isDark
                    ? const Color(0xFFCBD5E1)
                    : const Color(0xFF475569)),
          ),
        ),
      ),
    );
  }

  Widget _buildClienteTicketCard(
    ThemeData theme,
    ColorScheme colorScheme,
    bool isDark,
    TicketsRecord ticket,
  ) {
    final bool isAperto = ticket.stato == 'Aperto';
    final bool isUnread =
        !ticket.rispostaLetta && ticket.rispostaAdmin.trim().isNotEmpty;
    final dataStr = ticket.dataCreazione != null
        ? dateTimeFormat('d MMM y, HH:mm', ticket.dataCreazione)
        : '';

    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor = isUnread
        ? const Color(0xFFEF4444)
        : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0));
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSecondary =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: borderColor,
          width: isUnread ? 1.6 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isUnread
                ? const Color(0xFFEF4444).withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: isDark ? 0.25 : 0.03),
            blurRadius: 10.0,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner di Notifica Risposta Admin (se non letta)
          if (isUnread) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 12.0),
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(
                  color: const Color(0xFFEF4444).withValues(alpha: 0.3),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.mark_chat_unread_rounded,
                    size: 15.0,
                    color: Color(0xFFEF4444),
                  ),
                  SizedBox(width: 6.0),
                  Flexible(
                    child: Text(
                      'NUOVA RISPOSTA RICEVUTA DAL SUPPORTO!',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Color(0xFFEF4444),
                        fontWeight: FontWeight.bold,
                        fontSize: 11.0,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Header: Data e Badge Stato
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 14.0,
                      color: textSecondary,
                    ),
                    const SizedBox(width: 4.0),
                    Flexible(
                      child: Text(
                        dataStr,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: textSecondary,
                          fontSize: 12.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8.0),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: (isAperto
                          ? const Color(0xFFF59E0B)
                          : const Color(0xFF10B981))
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(
                    color: (isAperto
                            ? const Color(0xFFF59E0B)
                            : const Color(0xFF10B981))
                        .withValues(alpha: 0.3),
                    width: 1.0,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6.5,
                      height: 6.5,
                      decoration: BoxDecoration(
                        color: isAperto
                            ? const Color(0xFFF59E0B)
                            : const Color(0xFF10B981),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5.0),
                    Text(
                      isAperto ? 'IN ATTESA' : 'RISOLTO',
                      style: TextStyle(
                        fontSize: 11.0,
                        fontWeight: FontWeight.bold,
                        color: isAperto
                            ? const Color(0xFFF59E0B)
                            : const Color(0xFF10B981),
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10.0),

          // Titolo del Ticket
          Text(
            ticket.titolo,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 8.0),

          // Descrizione del Ticket
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF0F172A)
                  : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10.0),
              border: Border.all(
                color: isDark
                    ? const Color(0xFF334155).withValues(alpha: 0.5)
                    : const Color(0xFFE2E8F0),
              ),
            ),
            child: Text(
              ticket.descrizione,
              style: TextStyle(
                color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                fontSize: 13.5,
                height: 1.4,
              ),
            ),
          ),

          // Risposta dell'Admin (se presente)
          if (!isAperto && ticket.rispostaAdmin.isNotEmpty) ...[
            const SizedBox(height: 14.0),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14.0),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(
                  color: const Color(0xFF10B981).withValues(alpha: 0.25),
                  width: 1.0,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981),
                          borderRadius: BorderRadius.circular(6.0),
                        ),
                        child: const Icon(
                          Icons.support_agent_rounded,
                          size: 14.0,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Text(
                        'Risposta dell\'Assistenza ProntoMenu',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? const Color(0xFF34D399)
                              : const Color(0xFF047857),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    ticket.rispostaAdmin,
                    style: TextStyle(
                      color: isDark
                          ? const Color(0xFFD1FAE5)
                          : const Color(0xFF064E3B),
                      fontSize: 13.5,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // WIDGET SIDEBAR: STATISTICHE TICKET
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildTicketStatsCard(
    ThemeData theme,
    bool isDark, {
    required int apertiCount,
    required int risoltiCount,
    required int totalCount,
    required bool hasUnread,
  }) {
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor =
        isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSecondary =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Container(
      padding: const EdgeInsets.all(18.0),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: borderColor, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.03),
            blurRadius: 10.0,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 34.0,
                height: 34.0,
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(9.0),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.assessment_rounded,
                  color: Color(0xFF3B82F6),
                  size: 18.0,
                ),
              ),
              const SizedBox(width: 10.0),
              Expanded(
                child: Text(
                  'Riepilogo Richieste',
                  style: TextStyle(
                    fontSize: 15.0,
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                  ),
                ),
              ),
              if (hasUnread)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 7.0, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                  child: const Text(
                    'Nuova Risposta',
                    style: TextStyle(
                      color: Color(0xFFEF4444),
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16.0),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 12.0, horizontal: 10.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '$apertiCount',
                        style: const TextStyle(
                          fontSize: 22.0,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFF59E0B),
                        ),
                      ),
                      const SizedBox(height: 2.0),
                      Text(
                        'In Attesa',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10.0),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 12.0, horizontal: 10.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(
                      color: const Color(0xFF10B981).withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '$risoltiCount',
                        style: const TextStyle(
                          fontSize: 22.0,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF10B981),
                        ),
                      ),
                      const SizedBox(height: 2.0),
                      Text(
                        'Risolti',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10.0),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 12.0, horizontal: 10.0),
                  decoration: BoxDecoration(
                    color: (isDark
                            ? const Color(0xFF0F172A)
                            : const Color(0xFFF1F5F9))
                        .withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '$totalCount',
                        style: TextStyle(
                          fontSize: 22.0,
                          fontWeight: FontWeight.w800,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2.0),
                      Text(
                        'Totali',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (totalCount > 0 && _model.selectedTabIndex == 0) ...[
            const SizedBox(height: 14.0),
            OutlinedButton.icon(
              onPressed: () => safeSetState(() => _model.selectedTabIndex = 1),
              icon: const Icon(Icons.history_rounded, size: 16.0),
              label: const Text('Vedi storico richieste'),
              style: OutlinedButton.styleFrom(
                foregroundColor: textPrimary,
                side: BorderSide(color: borderColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                padding: const EdgeInsets.symmetric(vertical: 9.0),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // WIDGET SIDEBAR: ASSISTENZA DIRETTA & ORARI
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildAssistenzaDirettaCard(
    ThemeData theme,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor =
        isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSecondary =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Container(
      padding: const EdgeInsets.all(18.0),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: borderColor, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.03),
            blurRadius: 10.0,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 34.0,
                height: 34.0,
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(9.0),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.support_agent_rounded,
                  color: Color(0xFF10B981),
                  size: 18.0,
                ),
              ),
              const SizedBox(width: 10.0),
              Expanded(
                child: Text(
                  'Orari & Canali di Supporto',
                  style: TextStyle(
                    fontSize: 15.0,
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14.0),
          _buildInfoRow(
            icon: Icons.schedule_rounded,
            iconColor: const Color(0xFF3B82F6),
            label: 'Orario di risposta',
            value: 'Lun - Dom: 09:00 - 23:00',
            textPrimary: textPrimary,
            textSecondary: textSecondary,
          ),
          const SizedBox(height: 10.0),
          _buildInfoRow(
            icon: Icons.speed_rounded,
            iconColor: const Color(0xFF10B981),
            label: 'Tempo medio di riscontro',
            value: '< 2 ore lavorative',
            textPrimary: textPrimary,
            textSecondary: textSecondary,
          ),
          const SizedBox(height: 10.0),
          _buildInfoRow(
            icon: Icons.verified_user_rounded,
            iconColor: const Color(0xFF8B5CF6),
            label: 'Priorità emergenze',
            value: 'Assistenza rapida durante il servizio',
            textPrimary: textPrimary,
            textSecondary: textSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16.0, color: iconColor),
        const SizedBox(width: 8.0),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.5,
                  color: textSecondary,
                ),
              ),
              const SizedBox(height: 1.0),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13.0,
                  fontWeight: FontWeight.w600,
                  color: textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // WIDGET SIDEBAR: DOMANDE FREQUENTI (FAQ)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildFaqCard(
    ThemeData theme,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor =
        isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSecondary =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Container(
      padding: const EdgeInsets.all(18.0),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: borderColor, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.03),
            blurRadius: 10.0,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 34.0,
                height: 34.0,
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(9.0),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.help_center_rounded,
                  color: Color(0xFFF59E0B),
                  size: 18.0,
                ),
              ),
              const SizedBox(width: 10.0),
              Expanded(
                child: Text(
                  'Domande Frequenti (FAQ)',
                  style: TextStyle(
                    fontSize: 15.0,
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12.0),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _faqItems.length,
            separatorBuilder: (_, __) => Divider(
              color: borderColor,
              height: 16.0,
              thickness: 1.0,
            ),
            itemBuilder: (context, index) {
              final item = _faqItems[index];
              final isExpanded = _expandedFaqIndex == index;

              return InkWell(
                onTap: () {
                  safeSetState(() {
                    _expandedFaqIndex = isExpanded ? null : index;
                  });
                },
                borderRadius: BorderRadius.circular(8.0),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              item['q']!,
                              style: TextStyle(
                                fontSize: 13.0,
                                fontWeight: FontWeight.w600,
                                color: isExpanded
                                    ? colorScheme.primary
                                    : textPrimary,
                                height: 1.3,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8.0),
                          Icon(
                            isExpanded
                                ? Icons.keyboard_arrow_up_rounded
                                : Icons.keyboard_arrow_down_rounded,
                            size: 18.0,
                            color: textSecondary,
                          ),
                        ],
                      ),
                      if (isExpanded) ...[
                        const SizedBox(height: 6.0),
                        Text(
                          item['a']!,
                          style: TextStyle(
                            fontSize: 12.5,
                            color: textSecondary,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
