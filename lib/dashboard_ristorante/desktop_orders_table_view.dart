import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/custom_functions.dart' as functions;

/// Vista Tabella Ordini a tutto schermo per Desktop / PC
class DesktopOrdersTableView extends StatefulWidget {
  const DesktopOrdersTableView({
    super.key,
    this.ristoranteRef,
    this.initialStatusFilter,
  });

  final DocumentReference? ristoranteRef;
  final String? initialStatusFilter; // 'all', 'in_attesa', 'in_preparazione', 'Completato'

  @override
  State<DesktopOrdersTableView> createState() => _DesktopOrdersTableViewState();
}

class _DesktopOrdersTableViewState extends State<DesktopOrdersTableView> {
  // Global cache across instances so data is instantly rendered on tab switches
  static final Map<String, List<OrdersRecord>> _globalOrdersCache = {};

  String _selectedFilter = 'all'; // 'all', 'in_attesa', 'in_preparazione', 'Completato'
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _sortAscending = false;
  int _sortColumnIndex = 1; // 1 = data/orario

  late Stream<List<OrdersRecord>> _ordersStream;
  List<OrdersRecord>? _cachedOrders;

  String get _cacheKey =>
      '${widget.ristoranteRef?.id ?? 'default'}_${widget.initialStatusFilter ?? 'all'}';

  @override
  void initState() {
    super.initState();
    if (widget.initialStatusFilter != null) {
      _selectedFilter = widget.initialStatusFilter!;
    }
    _cachedOrders = _globalOrdersCache[_cacheKey];
    _initOrdersStream();
  }

  void _initOrdersStream() {
    _ordersStream = queryOrdersRecord(
      queryBuilder: (orders) {
        if (widget.initialStatusFilter == 'Completato') {
          return orders.where('stato_ordine', isEqualTo: 'Completato');
        } else if (widget.initialStatusFilter != null && widget.initialStatusFilter != 'all') {
          return orders.where('stato_ordine', isEqualTo: widget.initialStatusFilter);
        }
        return orders.orderBy('data_creazione', descending: true);
      },
      limit: 100,
    );
  }

  @override
  void didUpdateWidget(covariant DesktopOrdersTableView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.ristoranteRef != widget.ristoranteRef ||
        oldWidget.initialStatusFilter != widget.initialStatusFilter) {
      if (widget.initialStatusFilter != null) {
        _selectedFilter = widget.initialStatusFilter!;
      }
      _cachedOrders = _globalOrdersCache[_cacheKey];
      _initOrdersStream();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final docRef = widget.ristoranteRef;

    return StreamBuilder<List<OrdersRecord>>(
      stream: _ordersStream,
      initialData: _cachedOrders,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          _cachedOrders = snapshot.data;
          _globalOrdersCache[_cacheKey] = snapshot.data!;
        }
        if (snapshot.hasError && !snapshot.hasData) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline_rounded, size: 48.0, color: colorScheme.error),
                  const SizedBox(height: 16.0),
                  Text(
                    'Errore nel caricamento degli ordini',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    '${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13.0, color: colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          );
        }

        if (!snapshot.hasData) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SpinKitPulse(
                  color: colorScheme.primary,
                  size: 50.0,
                ),
                const SizedBox(height: 16.0),
                Text(
                  'Connessione a Firebase in corso...',
                  style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        }

        // Tutti gli ordini del ristorante
        List<OrdersRecord> allOrders = snapshot.data!;
        if (docRef != null) {
          allOrders = allOrders
              .where((o) => o.ristoranteRef == null || o.ristoranteRef == docRef)
              .toList();
        }

        // Calcolo KPI riepilogativi
        final inAttesaCount = allOrders.where((o) => o.statoOrdine.toLowerCase() == 'in_attesa').length;
        final inPrepCount = allOrders.where((o) => o.statoOrdine.toLowerCase() == 'in_preparazione').length;
        final completatiCount = allOrders.where((o) => o.statoOrdine.toLowerCase() == 'completato').length;
        final totaleIncasso = allOrders
            .where((o) => o.statoOrdine.toLowerCase() == 'completato')
            .fold<double>(0.0, (acc, o) => acc + o.totale);

        // Filtro per stato
        List<OrdersRecord> filteredOrders = allOrders;
        if (_selectedFilter != 'all') {
          filteredOrders = filteredOrders.where((o) {
            return o.statoOrdine.toLowerCase() == _selectedFilter.toLowerCase();
          }).toList();
        }

        // Filtro per ricerca (tavolo o piatti)
        if (_searchQuery.trim().isNotEmpty) {
          final query = _searchQuery.trim().toLowerCase();
          filteredOrders = filteredOrders.where((o) {
            final matchTavolo = 'tavolo ${o.tavolo}'.toLowerCase().contains(query) ||
                o.tavolo.toString().contains(query);
            final matchPiatti = o.listaPiatti.toLowerCase().contains(query);
            return matchTavolo || matchPiatti;
          }).toList();
        }

        // Ordinamento
        filteredOrders.sort((a, b) {
          int result = 0;
          if (_sortColumnIndex == 0) {
            result = a.tavolo.compareTo(b.tavolo);
          } else if (_sortColumnIndex == 1) {
            final dateA = a.dataCreazione ?? DateTime.fromMillisecondsSinceEpoch(0);
            final dateB = b.dataCreazione ?? DateTime.fromMillisecondsSinceEpoch(0);
            result = dateA.compareTo(dateB);
          } else if (_sortColumnIndex == 3) {
            result = a.totale.compareTo(b.totale);
          }
          return _sortAscending ? result : -result;
        });

        return Container(
          color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ═════════════════════════════════════════════════════════════
              // 1. CARDS KPI STATISTICHE RAPIDE
              // ═════════════════════════════════════════════════════════════
              Padding(
                padding: const EdgeInsets.fromLTRB(28.0, 24.0, 28.0, 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildKpiCard(
                        title: 'In Attesa',
                        value: '$inAttesaCount',
                        icon: Icons.hourglass_top_rounded,
                        color: const Color(0xFFF59E0B),
                        bgColor: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                        isDark: isDark,
                        isSelected: _selectedFilter == 'in_attesa',
                        onTap: () => setState(() => _selectedFilter = _selectedFilter == 'in_attesa' ? 'all' : 'in_attesa'),
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: _buildKpiCard(
                        title: 'In Preparazione',
                        value: '$inPrepCount',
                        icon: Icons.soup_kitchen_rounded,
                        color: const Color(0xFF3B82F6),
                        bgColor: const Color(0xFF3B82F6).withValues(alpha: 0.12),
                        isDark: isDark,
                        isSelected: _selectedFilter == 'in_preparazione',
                        onTap: () => setState(() => _selectedFilter = _selectedFilter == 'in_preparazione' ? 'all' : 'in_preparazione'),
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: _buildKpiCard(
                        title: 'Completati',
                        value: '$completatiCount',
                        icon: Icons.check_circle_rounded,
                        color: const Color(0xFF10B981),
                        bgColor: const Color(0xFF10B981).withValues(alpha: 0.12),
                        isDark: isDark,
                        isSelected: _selectedFilter == 'Completato',
                        onTap: () => setState(() => _selectedFilter = _selectedFilter == 'Completato' ? 'all' : 'Completato'),
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: _buildKpiCard(
                        title: 'Incasso Completati',
                        value: '${totaleIncasso.toStringAsFixed(2)} €',
                        icon: Icons.payments_rounded,
                        color: const Color(0xFF8B5CF6),
                        bgColor: const Color(0xFF8B5CF6).withValues(alpha: 0.12),
                        isDark: isDark,
                        isSelected: false,
                        onTap: null,
                      ),
                    ),
                  ],
                ),
              ),

              // ═════════════════════════════════════════════════════════════
              // 2. BARRA STRUMENTI: FILTRI, RICERCA E AZIONI BATCH
              // ═════════════════════════════════════════════════════════════
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28.0),
                child: Row(
                  children: [
                    // Campo Ricerca
                    Expanded(
                      flex: 2,
                      child: SizedBox(
                        height: 42.0,
                        child: TextField(
                          controller: _searchController,
                          onChanged: (val) => setState(() => _searchQuery = val),
                          style: TextStyle(
                            fontSize: 13.5,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                          decoration: InputDecoration(
                            hintText: 'Cerca per tavolo o nome piatto...',
                            hintStyle: TextStyle(
                              fontSize: 13.0,
                              color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                            ),
                            prefixIcon: Icon(
                              Icons.search_rounded,
                              size: 19.0,
                              color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                            ),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear_rounded, size: 16.0),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() => _searchQuery = '');
                                    },
                                  )
                                : null,
                            filled: true,
                            fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                            contentPadding: EdgeInsets.zero,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(
                                color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(
                                color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14.0),

                    // Filtri Chip Rapidi
                    _buildFilterChip('Tutti (${allOrders.length})', 'all', isDark, colorScheme),
                    const SizedBox(width: 8.0),
                    _buildFilterChip('In Attesa ($inAttesaCount)', 'in_attesa', isDark, colorScheme),
                    const SizedBox(width: 8.0),
                    _buildFilterChip('In Prep. ($inPrepCount)', 'in_preparazione', isDark, colorScheme),
                    const SizedBox(width: 8.0),
                    _buildFilterChip('Completati ($completatiCount)', 'Completato', isDark, colorScheme),

                    const Spacer(),

                    // Bottone "Completa tutti in attesa"
                    if (inAttesaCount > 0)
                      ElevatedButton.icon(
                        onPressed: () => _confermaCompletaTutti(context, allOrders),
                        icon: const Icon(Icons.done_all_rounded, size: 17.0),
                        label: Text(
                          'Completa tutti in attesa ($inAttesaCount)',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.0),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                          elevation: 0,
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 16.0),

              // ═════════════════════════════════════════════════════════════
              // 3. TABELLA ORDINI A TUTTO SCHERMO
              // ═════════════════════════════════════════════════════════════
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(28.0, 0.0, 28.0, 24.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      borderRadius: BorderRadius.circular(16.0),
                      border: Border.all(
                        color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                        width: 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                          blurRadius: 10.0,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: filteredOrders.isEmpty
                        ? _buildEmptyState(isDark, colorScheme)
                        : _buildOrdersTable(filteredOrders, isDark, colorScheme),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // WIDGET TABELLA DATI
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildOrdersTable(
    List<OrdersRecord> orders,
    bool isDark,
    ColorScheme colorScheme,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scrollbar(
          thumbVisibility: true,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: constraints.maxWidth),
                child: DataTable(
                  sortColumnIndex: _sortColumnIndex,
                  sortAscending: _sortAscending,
                  headingRowHeight: 52.0,
                  dataRowMaxHeight: 88.0,
                  dataRowMinHeight: 70.0,
                  horizontalMargin: 24.0,
                  columnSpacing: 28.0,
                  headingRowColor: WidgetStateProperty.all(
                    isDark ? const Color(0xFF0F172A).withValues(alpha: 0.6) : const Color(0xFFF8FAFC),
                  ),
                  dividerThickness: 1.0,
                  border: TableBorder(
                    horizontalInside: BorderSide(
                      color: isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFF1F5F9),
                      width: 1.0,
                    ),
                  ),
                  columns: [
                    DataColumn(
                      label: const Text(
                        'TAVOLO',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11.5, letterSpacing: 0.6),
                      ),
                      onSort: (index, ascending) {
                        setState(() {
                          _sortColumnIndex = index;
                          _sortAscending = ascending;
                        });
                      },
                    ),
                    DataColumn(
                      label: const Text(
                        'ORARIO & DATA',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11.5, letterSpacing: 0.6),
                      ),
                      onSort: (index, ascending) {
                        setState(() {
                          _sortColumnIndex = index;
                          _sortAscending = ascending;
                        });
                      },
                    ),
                    const DataColumn(
                      label: Text(
                        'PIATTI ORDINATI',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11.5, letterSpacing: 0.6),
                      ),
                    ),
                    DataColumn(
                      label: const Text(
                        'TOTALE',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11.5, letterSpacing: 0.6),
                      ),
                      numeric: true,
                      onSort: (index, ascending) {
                        setState(() {
                          _sortColumnIndex = index;
                          _sortAscending = ascending;
                        });
                      },
                    ),
                    const DataColumn(
                      label: Text(
                        'STATO COMANDA',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11.5, letterSpacing: 0.6),
                      ),
                    ),
                    const DataColumn(
                      label: Text(
                        'AZIONI RAPIDE',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11.5, letterSpacing: 0.6),
                      ),
                    ),
                  ],
                  rows: orders.map((order) {
                    final piatti = functions.raggruppaPiattiDaStringa(order.listaPiatti) ?? [];
                    final stato = order.statoOrdine.toLowerCase();
                    final dataStr = order.dataCreazione != null
                        ? dateTimeFormat('d/M/y HH:mm', order.dataCreazione)
                        : '--:--';
                    final tempoFa = order.dataCreazione != null
                        ? _calcolaTempoFa(order.dataCreazione!)
                        : '';

                    return DataRow(
                      cells: [
                        // 1. Tavolo
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10.0),
                              border: Border.all(
                                color: colorScheme.primary.withValues(alpha: 0.25),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.table_restaurant_rounded, size: 16.0, color: colorScheme.primary),
                                const SizedBox(width: 6.0),
                                Text(
                                  'Tavolo ${order.tavolo}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13.5,
                                    color: colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // 2. Data & Orario
                        DataCell(
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                dataStr,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13.0,
                                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                                ),
                              ),
                              if (tempoFa.isNotEmpty)
                                Text(
                                  tempoFa,
                                  style: TextStyle(
                                    fontSize: 11.0,
                                    fontWeight: FontWeight.w500,
                                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                  ),
                                ),
                            ],
                          ),
                        ),

                        // 3. Piatti Ordinati (Tag pill)
                        DataCell(
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 380.0),
                            child: piatti.isEmpty
                                ? Text(
                                    order.listaPiatti.isNotEmpty ? order.listaPiatti : 'Nessun piatto specificato',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                                    ),
                                  )
                                : Wrap(
                                    spacing: 6.0,
                                    runSpacing: 4.0,
                                    children: <Widget>[
                                      ...piatti.take(3).map((p) {
                                        return Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.5),
                                          decoration: BoxDecoration(
                                            color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                                            borderRadius: BorderRadius.circular(6.0),
                                          ),
                                          child: Text(
                                            p,
                                            style: TextStyle(
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.w600,
                                              color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF334155),
                                            ),
                                          ),
                                        );
                                      }),
                                      if (piatti.length > 3)
                                        InkWell(
                                          onTap: () => _mostraDettaglioOrdine(context, order, piatti),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 3.5),
                                            decoration: BoxDecoration(
                                              color: colorScheme.primary.withValues(alpha: 0.15),
                                              borderRadius: BorderRadius.circular(6.0),
                                            ),
                                            child: Text(
                                              '+${piatti.length - 3} altri',
                                              style: TextStyle(
                                                fontSize: 11.0,
                                                fontWeight: FontWeight.bold,
                                                color: colorScheme.primary,
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                          ),
                        ),

                        // 4. Totale
                        DataCell(
                          Text(
                            '${order.totale.toStringAsFixed(2)} €',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 15.0,
                              letterSpacing: -0.3,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                            ),
                          ),
                        ),

                        // 5. Stato Comanda
                        DataCell(
                          _buildStatusBadge(stato),
                        ),

                        // 6. Azioni Rapide
                        DataCell(
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Pulsante Avanzamento Stato
                              if (stato == 'in_attesa')
                                ElevatedButton.icon(
                                  onPressed: () {
                                    order.reference.update(createOrdersRecordData(
                                      statoOrdine: 'in_preparazione',
                                    ));
                                  },
                                  icon: const Icon(Icons.soup_kitchen_rounded, size: 14.0),
                                  label: const Text('Inizia Prep.', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF3B82F6),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                                    elevation: 0,
                                  ),
                                ),
                              if (stato == 'in_preparazione' || stato == 'in_attesa') ...[
                                const SizedBox(width: 6.0),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    order.reference.update(createOrdersRecordData(
                                      statoOrdine: 'Completato',
                                      visto: true,
                                    ));
                                  },
                                  icon: const Icon(Icons.check_rounded, size: 14.0),
                                  label: const Text('Completa', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF10B981),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                                    elevation: 0,
                                  ),
                                ),
                              ],
                              if (stato == 'completato')
                                OutlinedButton.icon(
                                  onPressed: () {
                                    order.reference.update(createOrdersRecordData(
                                      statoOrdine: 'in_attesa',
                                    ));
                                  },
                                  icon: const Icon(Icons.restart_alt_rounded, size: 14.0),
                                  label: const Text('Riapri', style: TextStyle(fontSize: 11.5)),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                                  ),
                                ),

                              const SizedBox(width: 6.0),

                              // Menu contestuale
                              PopupMenuButton<String>(
                                icon: Icon(
                                  Icons.more_vert_rounded,
                                  size: 18.0,
                                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                ),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                                onSelected: (val) async {
                                  if (val == 'dettaglio') {
                                    _mostraDettaglioOrdine(context, order, piatti);
                                  } else if (val == 'elimina') {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: const Text('Elimina Ordine'),
                                        content: Text('Vuoi davvero eliminare l\'ordine del Tavolo ${order.tavolo}?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(ctx, false),
                                            child: const Text('Annulla'),
                                          ),
                                          ElevatedButton(
                                            onPressed: () => Navigator.pop(ctx, true),
                                            style: ElevatedButton.styleFrom(backgroundColor: colorScheme.error),
                                            child: const Text('Elimina'),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (confirm == true) {
                                      await order.reference.delete();
                                    }
                                  }
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'dettaglio',
                                    child: Row(
                                      children: [
                                        Icon(Icons.info_outline_rounded, size: 16.0),
                                        SizedBox(width: 8.0),
                                        Text('Dettagli comanda'),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 'elimina',
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete_outline_rounded, size: 16.0, color: colorScheme.error),
                                        const SizedBox(width: 8.0),
                                        Text('Elimina ordine', style: TextStyle(color: colorScheme.error)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // HELPERS UI
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildKpiCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color bgColor,
    required bool isDark,
    required bool isSelected,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 16.0),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(14.0),
          border: Border.all(
            color: isSelected
                ? color
                : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected ? color.withValues(alpha: 0.15) : Colors.black.withValues(alpha: 0.02),
              blurRadius: 8.0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44.0,
              height: 44.0,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Icon(icon, color: color, size: 22.0),
            ),
            const SizedBox(width: 14.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w600,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 2.0),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    String value,
    bool isDark,
    ColorScheme colorScheme,
  ) {
    final isSelected = _selectedFilter == value;
    return InkWell(
      onTap: () => setState(() => _selectedFilter = value),
      borderRadius: BorderRadius.circular(20.0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 9.0),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary
              : (isDark ? const Color(0xFF1E293B) : Colors.white),
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected
                ? Colors.white
                : (isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569)),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String stato) {
    Color color;
    Color bgColor;
    String label;
    IconData icon;

    if (stato == 'in_attesa') {
      color = const Color(0xFFD97706);
      bgColor = const Color(0xFFF59E0B).withValues(alpha: 0.15);
      label = 'In Attesa';
      icon = Icons.hourglass_top_rounded;
    } else if (stato == 'in_preparazione') {
      color = const Color(0xFF2563EB);
      bgColor = const Color(0xFF3B82F6).withValues(alpha: 0.15);
      label = 'In Preparazione';
      icon = Icons.soup_kitchen_rounded;
    } else if (stato == 'completato') {
      color = const Color(0xFF059669);
      bgColor = const Color(0xFF10B981).withValues(alpha: 0.15);
      label = 'Completato';
      icon = Icons.check_circle_rounded;
    } else {
      color = const Color(0xFF64748B);
      bgColor = const Color(0xFF64748B).withValues(alpha: 0.15);
      label = stato;
      icon = Icons.info_outline_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.0, color: color),
          const SizedBox(width: 5.0),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.0,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark, ColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76.0,
              height: 76.0,
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.receipt_long_rounded,
                size: 38.0,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 18.0),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Nessun ordine trovato per "$_searchQuery"'
                  : 'Nessun ordine trovato in questa sezione',
              style: TextStyle(
                fontSize: 17.0,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Prova a cercare un numero di tavolo diverso o cancella il filtro di ricerca.'
                  : 'Gli ordini inviati dai clienti al tavolo appariranno qui automaticamente in tempo reale.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.5,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _calcolaTempoFa(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Proprio ora';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min fa';
    if (diff.inHours < 24) return '${diff.inHours} h fa';
    return '${diff.inDays} gg fa';
  }

  Future<void> _confermaCompletaTutti(
    BuildContext context,
    List<OrdersRecord> allOrders,
  ) async {
    final inAttesaOrders = allOrders
        .where((o) => o.statoOrdine.toLowerCase() == 'in_attesa')
        .toList();

    if (inAttesaOrders.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Completa tutti gli ordini in attesa'),
        content: Text(
          'Sei sicuro di voler segnare come completate tutte le ${inAttesaOrders.length} comande in attesa?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annulla'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
            child: const Text('Completa tutti'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      for (final o in inAttesaOrders) {
        await o.reference.update(createOrdersRecordData(
          statoOrdine: 'Completato',
          visto: true,
        ));
      }
    }
  }

  void _mostraDettaglioOrdine(
    BuildContext context,
    OrdersRecord order,
    List<String> piatti,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        child: Container(
          width: 520.0,
          padding: const EdgeInsets.all(28.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Text(
                          'Tavolo ${order.tavolo}',
                          style: TextStyle(
                            fontSize: 15.0,
                            fontWeight: FontWeight.w800,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10.0),
                      _buildStatusBadge(order.statoOrdine.toLowerCase()),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              Text(
                'Dettaglio Comanda',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              if (order.dataCreazione != null) ...[
                const SizedBox(height: 4.0),
                Text(
                  'Orario ordine: ${dateTimeFormat('d/M/y HH:mm', order.dataCreazione)}',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                ),
              ],
              const SizedBox(height: 20.0),
              const Divider(height: 1.0),
              const SizedBox(height: 16.0),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 280.0),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: piatti.isNotEmpty ? piatti.length : 1,
                  separatorBuilder: (_, __) => const SizedBox(height: 8.0),
                  itemBuilder: (context, idx) {
                    if (piatti.isEmpty) {
                      return Text(
                        order.listaPiatti.isNotEmpty ? order.listaPiatti : 'Nessun piatto specificato',
                        style: const TextStyle(fontSize: 14.0),
                      );
                    }
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF334155).withValues(alpha: 0.5) : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(
                          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.restaurant_rounded, size: 16.0, color: theme.colorScheme.primary),
                          const SizedBox(width: 10.0),
                          Expanded(
                            child: Text(
                              piatti[idx],
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : const Color(0xFF0F172A),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20.0),
              const Divider(height: 1.0),
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Totale Conto:',
                    style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${order.totale.toStringAsFixed(2)} €',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.w900,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Chiudi'),
                  ),
                  const SizedBox(width: 8.0),
                  if (order.statoOrdine.toLowerCase() != 'completato')
                    ElevatedButton.icon(
                      onPressed: () {
                        order.reference.update(createOrdersRecordData(
                          statoOrdine: 'Completato',
                          visto: true,
                        ));
                        Navigator.pop(ctx);
                      },
                      icon: const Icon(Icons.check_rounded, size: 16.0),
                      label: const Text('Segna come Completato'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
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
}
