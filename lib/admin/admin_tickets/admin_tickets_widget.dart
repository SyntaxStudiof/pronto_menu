import '/admin/card_ticket_admin/card_ticket_admin_widget.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'admin_tickets_model.dart';
export 'admin_tickets_model.dart';

/// Pagina da cui l'admin visualizza, filtra e risponde ai ticket di supporto
class AdminTicketsWidget extends StatefulWidget {
  const AdminTicketsWidget({
    super.key,
    this.embedded = false,
  });

  final bool embedded;

  static String routeName = 'AdminTickets';
  static String routePath = '/adminTickets';

  @override
  State<AdminTicketsWidget> createState() => _AdminTicketsWidgetState();
}

class _AdminTicketsWidgetState extends State<AdminTicketsWidget> {
  late AdminTicketsModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AdminTicketsModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgCanvas = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final cardBorder = isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0);
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final innerInputBg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9);
    const purpleAccent = Color(0xFF7C3AED);

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
                automaticallyImplyLeading: false,
                elevation: 0.0,
                leading: FlutterFlowIconButton(
                  borderColor: Colors.transparent,
                  borderRadius: 24.0,
                  borderWidth: 1.0,
                  buttonSize: 40.0,
                  icon: Icon(
                    Icons.arrow_back_rounded,
                    color: textPrimary,
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
                        color: purpleAccent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.support_agent_rounded,
                        color: purpleAccent,
                        size: 20.0,
                      ),
                    ),
                    const SizedBox(width: 10.0),
                    Text(
                      'Supporto clienti',
                      style: theme.appBarTheme.titleTextStyle ??
                          theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 19.0,
                            letterSpacing: -0.4,
                            color: textPrimary,
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
          child: StreamBuilder<List<TicketsRecord>>(
            stream: queryTicketsRecord(
              queryBuilder: (ticketsRecord) =>
                  ticketsRecord.orderBy('data_creazione', descending: true),
            ),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: SizedBox(
                    width: 48.0,
                    height: 48.0,
                    child: SpinKitPulse(
                      color: purpleAccent,
                      size: 48.0,
                    ),
                  ),
                );
              }

              final allTickets = snapshot.data!;
              final totaleCount = allTickets.length;
              final apertiCount = allTickets.where((t) {
                final s = t.stato.trim().toLowerCase();
                return s == 'aperto' || s.isEmpty;
              }).length;
              final risoltiCount = allTickets.where((t) {
                return t.stato.trim().toLowerCase() == 'risolto';
              }).length;

              // Filtra per stato
              var filteredList = allTickets.where((t) {
                final s = t.stato.trim().toLowerCase();
                final isAperto = (s == 'aperto' || s.isEmpty);
                if (_model.filtroStato == 'Aperto') return isAperto;
                if (_model.filtroStato == 'Risolto') return s == 'risolto';
                return true;
              }).toList();

              // Filtra per ricerca
              final query = _model.cercaTextController?.text.trim().toLowerCase() ?? '';
              if (query.isNotEmpty) {
                filteredList = filteredList.where((t) {
                  final titolo = t.titolo.toLowerCase();
                  final desc = t.descrizione.toLowerCase();
                  final risp = t.rispostaAdmin.toLowerCase();
                  return titolo.contains(query) ||
                      desc.contains(query) ||
                      risp.contains(query);
                }).toList();
              }

              return Container(
                color: bgCanvas,
                child: SingleChildScrollView(
                  controller: _model.columnController,
                  padding: widget.embedded
                      ? const EdgeInsets.fromLTRB(28.0, 24.0, 28.0, 40.0)
                      : const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 32.0),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1400.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // ── 1. KPI COUNTER CARDS ────────────────────────────
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final isWide = constraints.maxWidth >= 840;
                              return isWide
                                  ? Row(
                                      children: [
                                        Expanded(
                                          child: _buildTicketKpiCard(
                                            title: 'In attesa',
                                            value: '$apertiCount',
                                            subtitle: apertiCount > 0
                                                ? 'Richieste da gestire'
                                                : 'Nessun ticket in attesa',
                                            icon: Icons.pending_actions_rounded,
                                            accentColor: apertiCount > 0
                                                ? const Color(0xFFF59E0B)
                                                : const Color(0xFF10B981),
                                            cardBg: cardBg,
                                            cardBorder: cardBorder,
                                            textPrimary: textPrimary,
                                            textSecondary: textSecondary,
                                            isDark: isDark,
                                            isSelected: _model.filtroStato == 'Aperto',
                                            onTap: () {
                                              safeSetState(() {
                                                _model.filtroStato =
                                                    _model.filtroStato == 'Aperto' ? 'Tutti' : 'Aperto';
                                              });
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: 16.0),
                                        Expanded(
                                          child: _buildTicketKpiCard(
                                            title: 'Risolti',
                                            value: '$risoltiCount',
                                            subtitle: 'Ticket completati',
                                            icon: Icons.task_alt_rounded,
                                            accentColor: const Color(0xFF10B981),
                                            cardBg: cardBg,
                                            cardBorder: cardBorder,
                                            textPrimary: textPrimary,
                                            textSecondary: textSecondary,
                                            isDark: isDark,
                                            isSelected: _model.filtroStato == 'Risolto',
                                            onTap: () {
                                              safeSetState(() {
                                                _model.filtroStato =
                                                    _model.filtroStato == 'Risolto' ? 'Tutti' : 'Risolto';
                                              });
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: 16.0),
                                        Expanded(
                                          child: _buildTicketKpiCard(
                                            title: 'Totali',
                                            value: '$totaleCount',
                                            subtitle: 'Tutti i ticket registrati',
                                            icon: Icons.receipt_long_rounded,
                                            accentColor: purpleAccent,
                                            cardBg: cardBg,
                                            cardBorder: cardBorder,
                                            textPrimary: textPrimary,
                                            textSecondary: textSecondary,
                                            isDark: isDark,
                                            isSelected: _model.filtroStato == 'Tutti',
                                            onTap: () {
                                              safeSetState(() {
                                                _model.filtroStato = 'Tutti';
                                              });
                                            },
                                          ),
                                        ),
                                      ],
                                    )
                                  : Column(
                                      children: [
                                        _buildTicketKpiCard(
                                          title: 'In attesa',
                                          value: '$apertiCount',
                                          subtitle: apertiCount > 0
                                              ? 'Richieste da gestire'
                                              : 'Nessun ticket in attesa',
                                          icon: Icons.pending_actions_rounded,
                                          accentColor: apertiCount > 0
                                              ? const Color(0xFFF59E0B)
                                              : const Color(0xFF10B981),
                                          cardBg: cardBg,
                                          cardBorder: cardBorder,
                                          textPrimary: textPrimary,
                                          textSecondary: textSecondary,
                                          isDark: isDark,
                                          isSelected: _model.filtroStato == 'Aperto',
                                          onTap: () {
                                            safeSetState(() {
                                              _model.filtroStato =
                                                  _model.filtroStato == 'Aperto' ? 'Tutti' : 'Aperto';
                                            });
                                          },
                                        ),
                                        const SizedBox(height: 12.0),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: _buildTicketKpiCard(
                                                title: 'Risolti',
                                                value: '$risoltiCount',
                                                subtitle: 'Completati',
                                                icon: Icons.task_alt_rounded,
                                                accentColor: const Color(0xFF10B981),
                                                cardBg: cardBg,
                                                cardBorder: cardBorder,
                                                textPrimary: textPrimary,
                                                textSecondary: textSecondary,
                                                isDark: isDark,
                                                isSelected: _model.filtroStato == 'Risolto',
                                                onTap: () {
                                                  safeSetState(() {
                                                    _model.filtroStato =
                                                        _model.filtroStato == 'Risolto' ? 'Tutti' : 'Risolto';
                                                  });
                                                },
                                              ),
                                            ),
                                            const SizedBox(width: 12.0),
                                            Expanded(
                                              child: _buildTicketKpiCard(
                                                title: 'Totali',
                                                value: '$totaleCount',
                                                subtitle: 'Tutti i ticket',
                                                icon: Icons.receipt_long_rounded,
                                                accentColor: purpleAccent,
                                                cardBg: cardBg,
                                                cardBorder: cardBorder,
                                                textPrimary: textPrimary,
                                                textSecondary: textSecondary,
                                                isDark: isDark,
                                                isSelected: _model.filtroStato == 'Tutti',
                                                onTap: () {
                                                  safeSetState(() {
                                                    _model.filtroStato = 'Tutti';
                                                  });
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    );
                            },
                          ),

                          const SizedBox(height: 18.0),

                          // ── 2. BARRA DI RICERCA & FILTRI DESKTOP ────────────
                          Container(
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: cardBg,
                              borderRadius: BorderRadius.circular(16.0),
                              border: Border.all(color: cardBorder),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                                  blurRadius: 10.0,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Casella di ricerca
                                Container(
                                  height: 46.0,
                                  decoration: BoxDecoration(
                                    color: innerInputBg,
                                    borderRadius: BorderRadius.circular(10.0),
                                    border: Border.all(color: cardBorder),
                                  ),
                                  child: Row(
                                    children: [
                                      const SizedBox(width: 14.0),
                                      const Icon(
                                        Icons.search_rounded,
                                        color: Color(0xFF7C3AED),
                                        size: 20.0,
                                      ),
                                      const SizedBox(width: 10.0),
                                      Expanded(
                                        child: TextField(
                                          controller: _model.cercaTextController,
                                          focusNode: _model.cercaFocusNode,
                                          onChanged: (_) => safeSetState(() {}),
                                          style: TextStyle(
                                            fontSize: 13.5,
                                            color: textPrimary,
                                          ),
                                          decoration: InputDecoration(
                                            isDense: true,
                                            hintText: 'Cerca per oggetto, contenuto o risposta...',
                                            hintStyle: TextStyle(
                                              fontSize: 13.5,
                                              color: textSecondary,
                                            ),
                                            border: InputBorder.none,
                                          ),
                                        ),
                                      ),
                                      if (_model.cercaTextController?.text.isNotEmpty ?? false)
                                        IconButton(
                                          icon: Icon(
                                            Icons.close_rounded,
                                            size: 18.0,
                                            color: textSecondary,
                                          ),
                                          onPressed: () {
                                            _model.cercaTextController?.clear();
                                            safeSetState(() {});
                                          },
                                        ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 14.0),

                                // Pillole di filtro stato
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: [
                                      _buildFilterPill(
                                        label: 'Tutti i ticket ($totaleCount)',
                                        isSelected: _model.filtroStato == 'Tutti',
                                        activeColor: purpleAccent,
                                        cardBg: innerInputBg,
                                        cardBorder: cardBorder,
                                        textPrimary: textPrimary,
                                        textSecondary: textSecondary,
                                        onTap: () => safeSetState(() => _model.filtroStato = 'Tutti'),
                                      ),
                                      const SizedBox(width: 8.0),
                                      _buildFilterPill(
                                        label: 'In attesa ($apertiCount)',
                                        isSelected: _model.filtroStato == 'Aperto',
                                        activeColor: const Color(0xFFF59E0B),
                                        cardBg: innerInputBg,
                                        cardBorder: cardBorder,
                                        textPrimary: textPrimary,
                                        textSecondary: textSecondary,
                                        onTap: () => safeSetState(() => _model.filtroStato = 'Aperto'),
                                      ),
                                      const SizedBox(width: 8.0),
                                      _buildFilterPill(
                                        label: 'Risolti ($risoltiCount)',
                                        isSelected: _model.filtroStato == 'Risolto',
                                        activeColor: const Color(0xFF10B981),
                                        cardBg: innerInputBg,
                                        cardBorder: cardBorder,
                                        textPrimary: textPrimary,
                                        textSecondary: textSecondary,
                                        onTap: () => safeSetState(() => _model.filtroStato = 'Risolto'),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20.0),

                          // ── 3. LISTA O STATO VUOTO ──────────────────────────
                          if (allTickets.isEmpty)
                            _buildZeroTicketsEmptyState(
                              cardBg: cardBg,
                              cardBorder: cardBorder,
                              textPrimary: textPrimary,
                              textSecondary: textSecondary,
                            )
                          else if (filteredList.isEmpty)
                            _buildNoFilterMatchEmptyState(
                              cardBg: cardBg,
                              cardBorder: cardBorder,
                              textPrimary: textPrimary,
                              textSecondary: textSecondary,
                            )
                          else
                            ListView.separated(
                              padding: const EdgeInsets.only(bottom: 28.0),
                              primary: false,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: filteredList.length,
                              separatorBuilder: (context, index) => const SizedBox(height: 14.0),
                              itemBuilder: (context, index) {
                                final ticket = filteredList[index];
                                return CardTicketAdminWidget(
                                  key: ValueKey('ticket_admin_${ticket.reference.id}'),
                                  parameter1: ticket.titolo,
                                  parameter2: ticket.descrizione,
                                  parameter3: ticket.stato,
                                  parameter4: ticket.ristoratoreRef,
                                  parameter5: ticket.reference,
                                  ticketCorrente: ticket,
                                );
                              },
                            ),
                        ],
                      ),
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

  // ─── KPI CARD UNIFORME CON IL DESIGN SYSTEM ──────────────────────────────
  Widget _buildTicketKpiCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    required Color cardBg,
    required Color cardBorder,
    required Color textPrimary,
    required Color textSecondary,
    required bool isDark,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.0),
        child: Container(
          padding: const EdgeInsets.all(18.0),
          decoration: BoxDecoration(
            color: isSelected
                ? accentColor.withValues(alpha: isDark ? 0.15 : 0.08)
                : cardBg,
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(
              color: isSelected ? accentColor : cardBorder,
              width: isSelected ? 1.6 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? accentColor.withValues(alpha: 0.15)
                    : Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                blurRadius: 8.0,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? accentColor : textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 22.0,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        color: isSelected ? accentColor : textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: accentColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 44.0,
                height: 44.0,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                alignment: Alignment.center,
                child: Icon(
                  icon,
                  size: 22.0,
                  color: accentColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── PILLOLA DI FILTRO UNIFORME ──────────────────────────────────────────
  Widget _buildFilterPill({
    required String label,
    required bool isSelected,
    required Color activeColor,
    required Color cardBg,
    required Color cardBorder,
    required Color textPrimary,
    required Color textSecondary,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20.0),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 7.5),
          decoration: BoxDecoration(
            color: isSelected
                ? activeColor.withValues(alpha: 0.16)
                : cardBg,
            borderRadius: BorderRadius.circular(20.0),
            border: Border.all(
              color: isSelected ? activeColor : cardBorder,
              width: isSelected ? 1.4 : 1.0,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? activeColor : textPrimary,
            ),
          ),
        ),
      ),
    );
  }

  // ─── STATI VUOTI UNIFORMI ────────────────────────────────────────────────
  Widget _buildZeroTicketsEmptyState({
    required Color cardBg,
    required Color cardBorder,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30.0),
      child: Container(
        padding: const EdgeInsets.all(32.0),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(color: cardBorder),
        ),
        child: Column(
          children: [
            Container(
              width: 72.0,
              height: 72.0,
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.task_alt_rounded,
                color: Color(0xFF10B981),
                size: 38.0,
              ),
            ),
            const SizedBox(height: 18.0),
            Text(
              'Zero ticket da gestire',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18.0,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 6.0),
            Text(
              'Tutti i ristoratori sono felici! Non ci sono richieste di supporto in sospeso.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textSecondary,
                fontSize: 13.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoFilterMatchEmptyState({
    required Color cardBg,
    required Color cardBorder,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30.0),
      child: Container(
        padding: const EdgeInsets.all(32.0),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(color: cardBorder),
        ),
        child: Column(
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 48.0,
              color: textSecondary.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 14.0),
            Text(
              'Nessun ticket trovato',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17.0,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 6.0),
            Text(
              'Prova a modificare il filtro o la ricerca per visualizzare altri risultati.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textSecondary,
                fontSize: 13.5,
              ),
            ),
            const SizedBox(height: 16.0),
            OutlinedButton.icon(
              onPressed: () {
                _model.cercaTextController?.clear();
                safeSetState(() {
                  _model.filtroStato = 'Tutti';
                });
              },
              icon: const Icon(Icons.refresh_rounded, size: 16.0),
              label: const Text('Reimposta filtri'),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

