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
  const AdminTicketsWidget({super.key});

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
                  color: theme.colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.support_agent_rounded,
                  color: theme.colorScheme.primary,
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
                      color: theme.colorScheme.primary,
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

              return SingleChildScrollView(
                controller: _model.columnController,
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 800.0),
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // --- 1. KPI COUNTER CARDS ---
                        Row(
                          children: [
                            Expanded(
                              child: _buildKpiCard(
                                context: context,
                                theme: theme,
                                label: 'In attesa',
                                count: apertiCount,
                                icon: Icons.pending_actions_rounded,
                                accentColor: const Color(0xFFF59E0B),
                                isSelected: _model.filtroStato == 'Aperto',
                                onTap: () {
                                  safeSetState(() {
                                    _model.filtroStato =
                                        _model.filtroStato == 'Aperto' ? 'Tutti' : 'Aperto';
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 10.0),
                            Expanded(
                              child: _buildKpiCard(
                                context: context,
                                theme: theme,
                                label: 'Risolti',
                                count: risoltiCount,
                                icon: Icons.task_alt_rounded,
                                accentColor: const Color(0xFF10B981),
                                isSelected: _model.filtroStato == 'Risolto',
                                onTap: () {
                                  safeSetState(() {
                                    _model.filtroStato =
                                        _model.filtroStato == 'Risolto' ? 'Tutti' : 'Risolto';
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 10.0),
                            Expanded(
                              child: _buildKpiCard(
                                context: context,
                                theme: theme,
                                label: 'Totali',
                                count: totaleCount,
                                icon: Icons.receipt_long_rounded,
                                accentColor: theme.colorScheme.primary,
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

                        const SizedBox(height: 16.0),

                        // --- 2. BARRA DI RICERCA ---
                        Container(
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            borderRadius: BorderRadius.circular(16.0),
                            border: Border.all(
                              color: theme.dividerColor.withValues(alpha: 0.12),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.02),
                                blurRadius: 10.0,
                                offset: const Offset(0.0, 3.0),
                              ),
                            ],
                          ),
                          child: TextFormField(
                            controller: _model.cercaTextController,
                            focusNode: _model.cercaFocusNode,
                            onChanged: (_) => safeSetState(() {}),
                            decoration: InputDecoration(
                              hintText: 'Cerca per oggetto, contenuto o risposta...',
                              hintStyle: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.hintColor.withValues(alpha: 0.7),
                                fontSize: 13.5,
                              ),
                              prefixIcon: Icon(
                                Icons.search_rounded,
                                color: theme.colorScheme.primary,
                                size: 22.0,
                              ),
                              suffixIcon: (_model.cercaTextController?.text.isNotEmpty ?? false)
                                  ? IconButton(
                                      icon: Icon(
                                        Icons.close_rounded,
                                        size: 18.0,
                                        color: theme.hintColor,
                                      ),
                                      onPressed: () {
                                        _model.cercaTextController?.clear();
                                        safeSetState(() {});
                                      },
                                    )
                                  : null,
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 14.0,
                              ),
                            ),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontSize: 14.0,
                            ),
                          ),
                        ),

                        const SizedBox(height: 14.0),

                        // --- 3. PILLOLE DI FILTRO STATO ---
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildFilterChip(
                                context: context,
                                theme: theme,
                                label: 'Tutti i ticket',
                                count: totaleCount,
                                isSelected: _model.filtroStato == 'Tutti',
                                onTap: () => safeSetState(() => _model.filtroStato = 'Tutti'),
                              ),
                              const SizedBox(width: 8.0),
                              _buildFilterChip(
                                context: context,
                                theme: theme,
                                label: 'In attesa',
                                count: apertiCount,
                                activeColor: const Color(0xFFF59E0B),
                                isSelected: _model.filtroStato == 'Aperto',
                                onTap: () => safeSetState(() => _model.filtroStato = 'Aperto'),
                              ),
                              const SizedBox(width: 8.0),
                              _buildFilterChip(
                                context: context,
                                theme: theme,
                                label: 'Risolti',
                                count: risoltiCount,
                                activeColor: const Color(0xFF10B981),
                                isSelected: _model.filtroStato == 'Risolto',
                                onTap: () => safeSetState(() => _model.filtroStato = 'Risolto'),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 18.0),

                        // --- 4. LISTA O STATO VUOTO ---
                        if (allTickets.isEmpty)
                          _buildZeroTicketsEmptyState(theme)
                        else if (filteredList.isEmpty)
                          _buildNoFilterMatchEmptyState(theme)
                        else
                          ListView.separated(
                            padding: const EdgeInsets.only(bottom: 24.0),
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
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildKpiCard({
    required BuildContext context,
    required ThemeData theme,
    required String label,
    required int count,
    required IconData icon,
    required Color accentColor,
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
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 14.0),
          decoration: BoxDecoration(
            color: isSelected
                ? accentColor.withValues(alpha: 0.1)
                : theme.cardColor,
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(
              color: isSelected
                  ? accentColor
                  : theme.dividerColor.withValues(alpha: 0.12),
              width: isSelected ? 1.6 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? accentColor.withValues(alpha: 0.12)
                    : Colors.black.withValues(alpha: 0.02),
                blurRadius: 10.0,
                offset: const Offset(0.0, 3.0),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 32.0,
                    height: 32.0,
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      icon,
                      size: 18.0,
                      color: accentColor,
                    ),
                  ),
                  Text(
                    count.toString(),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 20.0,
                      color: isSelected ? accentColor : theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10.0),
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  fontSize: 12.0,
                  color: isSelected ? accentColor : theme.hintColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required BuildContext context,
    required ThemeData theme,
    required String label,
    required int count,
    Color? activeColor,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final effectiveColor = activeColor ?? theme.colorScheme.primary;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(24.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24.0),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: isSelected
                ? effectiveColor.withValues(alpha: 0.14)
                : theme.cardColor,
            borderRadius: BorderRadius.circular(24.0),
            border: Border.all(
              color: isSelected
                  ? effectiveColor
                  : theme.dividerColor.withValues(alpha: 0.14),
              width: isSelected ? 1.4 : 1.0,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 12.5,
                  color: isSelected ? effectiveColor : theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 6.0),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                decoration: BoxDecoration(
                  color: isSelected
                      ? effectiveColor
                      : theme.dividerColor.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    color: isSelected ? Colors.white : theme.hintColor,
                    fontSize: 11.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildZeroTicketsEmptyState(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 36.0),
      child: Container(
        padding: const EdgeInsets.all(28.0),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(24.0),
          border: Border.all(
            color: theme.dividerColor.withValues(alpha: 0.15),
          ),
          boxShadow: [
            BoxShadow(
              blurRadius: 20.0,
              color: Colors.black.withValues(alpha: 0.04),
              offset: const Offset(0.0, 6.0),
            ),
          ],
        ),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 80.0,
                  height: 80.0,
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                ),
                const Icon(
                  Icons.task_alt_rounded,
                  color: Color(0xFF10B981),
                  size: 40.0,
                ),
              ],
            ),
            const SizedBox(height: 18.0),
            Text(
              'Zero ticket da gestire',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 18.0,
              ),
            ),
            const SizedBox(height: 6.0),
            Text(
              'Tutti i ristoratori sono felici! Non ci sono richieste di supporto in sospeso.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.hintColor,
                fontSize: 13.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoFilterMatchEmptyState(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 36.0),
      child: Container(
        padding: const EdgeInsets.all(28.0),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(24.0),
          border: Border.all(
            color: theme.dividerColor.withValues(alpha: 0.15),
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 48.0,
              color: theme.hintColor.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 14.0),
            Text(
              'Nessun ticket trovato',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 17.0,
              ),
            ),
            const SizedBox(height: 6.0),
            Text(
              'Prova a modificare il filtro o la ricerca per visualizzare altri risultati.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.hintColor,
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
