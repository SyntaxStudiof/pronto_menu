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

  final List<Map<String, String>> _categorieSupporto = [
    {'icon': '🍽️', 'nome': 'Menù & Piatti'},
    {'icon': '📋', 'nome': 'Comande & Tavoli'},
    {'icon': '🎵', 'nome': 'Jukebox'},
    {'icon': '💳', 'nome': 'Abbonamento'},
    {'icon': '⚙️', 'nome': 'Altro'},
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

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: widget.embedded
            ? null
            : AppBar(
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
                  Icons.help_outline_rounded,
                  color: colorScheme.primary,
                  size: 20.0,
                ),
              ),
              const SizedBox(width: 10.0),
              Text(
                'Supporto',
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

              return SingleChildScrollView(
                controller: _model.scrollController,
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 20.0),
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 680.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Segmented Tabs Header
                        _buildSegmentedTabSelector(
                          theme,
                          colorScheme,
                          ticketCount: allTickets.length,
                          hasUnreadReply: hasUnreadReply,
                        ),
                        const SizedBox(height: 20.0),

                        // TAB 0: NUOVA RICHIESTA
                        if (_model.selectedTabIndex == 0)
                          _buildNuovaRichiestaTab(theme, colorScheme),

                        // TAB 1: I MIEI TICKET
                        if (_model.selectedTabIndex == 1)
                          _buildIMieiTicketTab(
                            theme,
                            colorScheme,
                            allTickets: allTickets,
                            isLoading: !snapshot.hasData,
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSegmentedTabSelector(
    ThemeData theme,
    ColorScheme colorScheme, {
    required int ticketCount,
    required bool hasUnreadReply,
  }) {
    return Container(
      padding: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.12),
          width: 1.0,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => safeSetState(() => _model.selectedTabIndex = 0),
              borderRadius: BorderRadius.circular(12.0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 11.0, horizontal: 4.0),
                decoration: BoxDecoration(
                  color: _model.selectedTabIndex == 0
                      ? colorScheme.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: _model.selectedTabIndex == 0
                      ? [
                          BoxShadow(
                            color: colorScheme.primary.withValues(alpha: 0.25),
                            blurRadius: 8.0,
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
                          ? colorScheme.onPrimary
                          : theme.hintColor,
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
                              ? colorScheme.onPrimary
                              : colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 4.0),
          Expanded(
            child: InkWell(
              onTap: () => safeSetState(() => _model.selectedTabIndex = 1),
              borderRadius: BorderRadius.circular(12.0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 11.0, horizontal: 4.0),
                decoration: BoxDecoration(
                  color: _model.selectedTabIndex == 1
                      ? colorScheme.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: _model.selectedTabIndex == 1
                      ? [
                          BoxShadow(
                            color: colorScheme.primary.withValues(alpha: 0.25),
                            blurRadius: 8.0,
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
                          ? colorScheme.onPrimary
                          : theme.hintColor,
                    ),
                    const SizedBox(width: 6.0),
                    Flexible(
                      child: Text(
                        ticketCount > 0 ? 'I Miei Ticket ($ticketCount)' : 'I Miei Ticket',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13.0,
                          fontWeight: FontWeight.bold,
                          color: _model.selectedTabIndex == 1
                              ? colorScheme.onPrimary
                              : colorScheme.onSurface,
                        ),
                      ),
                    ),
                    if (hasUnreadReply) ...[
                      const SizedBox(width: 4.0),
                      Container(
                        width: 16.0,
                        height: 16.0,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFEF4444).withValues(alpha: 0.4),
                              blurRadius: 4.0,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          '!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10.0,
                            fontWeight: FontWeight.w900,
                            height: 1.0,
                          ),
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

  Widget _buildNuovaRichiestaTab(ThemeData theme, ColorScheme colorScheme) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Hero Welcome Card
          Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(20.0),
              border: Border.all(
                color: theme.dividerColor.withValues(alpha: 0.12),
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 14.0,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 52.0,
                  height: 52.0,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.support_agent_rounded,
                    color: colorScheme.primary,
                    size: 30.0,
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Come possiamo aiutarti?',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 17.0,
                        ),
                      ),
                      const SizedBox(height: 3.0),
                      Text(
                        'Compila il modulo per ricevere assistenza dedicata dal nostro team.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.hintColor,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Row(
                        children: [
                          Icon(
                            Icons.bolt_rounded,
                            color: Colors.orange.shade700,
                            size: 15.0,
                          ),
                          const SizedBox(width: 4.0),
                          Expanded(
                            child: Text(
                              'Risposta media garantita entro poche ore',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: Colors.orange.shade800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20.0),

          // Selettore Argomento / Categoria
          Text(
            'Seleziona l\'argomento',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10.0),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _categorieSupporto.map((cat) {
                final bool isSelected =
                    _model.categoriaSelezionata == cat['nome'];
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text('${cat['icon']} ${cat['nome']}'),
                    selected: isSelected,
                    onSelected: (selected) {
                      safeSetState(() {
                        _model.categoriaSelezionata =
                            selected ? cat['nome'] : null;
                      });
                    },
                    selectedColor:
                        colorScheme.primary.withValues(alpha: 0.15),
                    backgroundColor: theme.cardColor,
                    labelStyle: TextStyle(
                      fontSize: 12.5,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.onSurface,
                    ),
                    side: BorderSide(
                      color: isSelected
                          ? colorScheme.primary
                          : theme.dividerColor.withValues(alpha: 0.18),
                      width: isSelected ? 1.4 : 1.0,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20.0),

          // Card del Modulo
          Container(
            padding: const EdgeInsets.all(22.0),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(20.0),
              border: Border.all(
                color: theme.dividerColor.withValues(alpha: 0.12),
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 14.0,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Campo Oggetto
                Text(
                  'Oggetto della richiesta',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8.0),
                TextFormField(
                  controller: _model.titoloTicketTextController,
                  focusNode: _model.titoloTicketFocusNode,
                  autofocus: false,
                  enabled: !_model.isSubmitting,
                  decoration: InputDecoration(
                    hintText: 'Es: Problema con la stampa, modifica prezzi...',
                    hintStyle: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.hintColor,
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
                    fillColor: theme.scaffoldBackgroundColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14.0),
                      borderSide: BorderSide(
                        color: theme.dividerColor.withValues(alpha: 0.15),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14.0),
                      borderSide: BorderSide(
                        color: theme.dividerColor.withValues(alpha: 0.15),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14.0),
                      borderSide: BorderSide(
                        color: colorScheme.primary,
                        width: 1.5,
                      ),
                    ),
                  ),
                  style: theme.textTheme.bodyMedium,
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
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
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
                        'Spiega nel dettaglio cosa accade o cosa vorresti configurare...',
                    hintStyle: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.hintColor,
                    ),
                    contentPadding: const EdgeInsets.all(16.0),
                    filled: true,
                    fillColor: theme.scaffoldBackgroundColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14.0),
                      borderSide: BorderSide(
                        color: theme.dividerColor.withValues(alpha: 0.15),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14.0),
                      borderSide: BorderSide(
                        color: theme.dividerColor.withValues(alpha: 0.15),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14.0),
                      borderSide: BorderSide(
                        color: colorScheme.primary,
                        width: 1.5,
                      ),
                    ),
                  ),
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Inserisci una descrizione per aiutarci ad assisterti';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24.0),

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
                    height: 50.0,
                    color: colorScheme.primary,
                    textStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 15.5,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                    elevation: 2.0,
                    borderRadius: BorderRadius.circular(14.0),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32.0),
        ],
      ),
    );
  }

  Widget _buildIMieiTicketTab(
    ThemeData theme,
    ColorScheme colorScheme, {
    required List<TicketsRecord> allTickets,
    required bool isLoading,
  }) {
    if (isLoading) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40.0),
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
        // Filtri Rapidi
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFiltroPill(
                theme,
                label: 'Tutti (${allTickets.length})',
                isSelected: _model.filtroStato == 'Tutti',
                onTap: () => safeSetState(() => _model.filtroStato = 'Tutti'),
              ),
              const SizedBox(width: 8.0),
              _buildFiltroPill(
                theme,
                label: 'In Attesa ($apertiCount)',
                isSelected: _model.filtroStato == 'Aperto',
                color: Colors.orange.shade700,
                onTap: () => safeSetState(() => _model.filtroStato = 'Aperto'),
              ),
              const SizedBox(width: 8.0),
              _buildFiltroPill(
                theme,
                label: 'Risolti ($risoltiCount)',
                isSelected: _model.filtroStato == 'Risolto',
                color: const Color(0xFF10B981),
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
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(20.0),
              border: Border.all(
                color: theme.dividerColor.withValues(alpha: 0.12),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 60.0,
                  height: 60.0,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.10),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.mark_email_read_outlined,
                    size: 30.0,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 14.0),
                Text(
                  _model.filtroStato == 'Aperto'
                      ? 'Nessun ticket in attesa!'
                      : 'Nessun ticket presente',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6.0),
                Text(
                  _model.filtroStato == 'Aperto'
                      ? 'Tutte le tue segnalazioni sono state gestite e risolte.'
                      : 'Se riscontri qualsiasi difficoltà o hai una richiesta, apri un ticket!',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.hintColor,
                  ),
                ),
                if (_model.filtroStato != 'Tutti') ...[
                  const SizedBox(height: 14.0),
                  TextButton.icon(
                    onPressed: () =>
                        safeSetState(() => _model.filtroStato = 'Tutti'),
                    icon: const Icon(Icons.clear_all_rounded, size: 16.0),
                    label: const Text('Mostra tutti i ticket'),
                  ),
                ],
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
              return _buildClienteTicketCard(theme, colorScheme, ticket);
            },
          ),
        const SizedBox(height: 32.0),
      ],
    );
  }

  Widget _buildFiltroPill(
    ThemeData theme, {
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    Color? color,
  }) {
    final activeColor = color ?? theme.colorScheme.primary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 7.0),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withValues(alpha: 0.15)
              : theme.cardColor,
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(
            color: isSelected
                ? activeColor
                : theme.dividerColor.withValues(alpha: 0.15),
            width: isSelected ? 1.4 : 1.0,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.0,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected
                ? activeColor
                : theme.textTheme.bodyMedium?.color,
          ),
        ),
      ),
    );
  }

  Widget _buildClienteTicketCard(
      ThemeData theme, ColorScheme colorScheme, TicketsRecord ticket) {
    final bool isAperto = ticket.stato == 'Aperto';
    final bool isUnread =
        !ticket.rispostaLetta && ticket.rispostaAdmin.trim().isNotEmpty;
    final dataStr = ticket.dataCreazione != null
        ? dateTimeFormat('d MMM y, HH:mm', ticket.dataCreazione)
        : '';

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18.0),
        border: Border.all(
          color: isUnread
              ? const Color(0xFFEF4444)
              : isAperto
                  ? Colors.orange.withValues(alpha: 0.35)
                  : theme.dividerColor.withValues(alpha: 0.12),
          width: isUnread ? 1.6 : (isAperto ? 1.2 : 1.0),
        ),
        boxShadow: [
          BoxShadow(
            color: isUnread
                ? const Color(0xFFEF4444).withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.03),
            blurRadius: 10.0,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                      'NUOVA RISPOSTA RICEVUTA DALL\'ADMIN!',
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
                      color: theme.hintColor,
                    ),
                    const SizedBox(width: 4.0),
                    Flexible(
                      child: Text(
                        dataStr,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.hintColor,
                          fontSize: 11.5,
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
                  color: (isAperto ? Colors.orange : const Color(0xFF10B981))
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(
                    color: (isAperto ? Colors.orange : const Color(0xFF10B981))
                        .withValues(alpha: 0.28),
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
                            ? Colors.orange.shade700
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
                            ? Colors.orange.shade800
                            : const Color(0xFF047857),
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12.0),

          // Titolo del Ticket
          Text(
            ticket.titolo,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 16.5,
            ),
          ),
          const SizedBox(height: 8.0),

          // Descrizione del Ticket
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Text(
              ticket.descrizione,
              style: theme.textTheme.bodyMedium?.copyWith(
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
                borderRadius: BorderRadius.circular(14.0),
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
                      Expanded(
                        child: Text(
                          'Risposta dell\'Assistenza ProntoMenu',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: theme.brightness == Brightness.dark
                                ? const Color(0xFF34D399)
                                : const Color(0xFF047857),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    ticket.rispostaAdmin,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.brightness == Brightness.dark
                          ? const Color(0xFFD1FAE5)
                          : const Color(0xFF064E3B),
                      fontSize: 14.0,
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
}
