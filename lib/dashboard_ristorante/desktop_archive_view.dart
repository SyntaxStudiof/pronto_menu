import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/custom_functions.dart' as functions;
import '/custom_code/actions/csv_downloader.dart';

enum ArchivePeriodFilter {
  today,
  thisWeek,
  thisMonth,
  thisYear,
  customRange,
  all,
}

enum ArchiveSortBy {
  dateDesc,
  dateAsc,
  tableAsc,
  tableDesc,
  totalDesc,
  totalAsc,
}

/// Vista Archivio Ordini (4ª Fase) per Desktop
class DesktopArchiveView extends StatefulWidget {
  const DesktopArchiveView({
    super.key,
    this.ristoranteRef,
  });

  final DocumentReference? ristoranteRef;

  @override
  State<DesktopArchiveView> createState() => _DesktopArchiveViewState();
}

class _DesktopArchiveViewState extends State<DesktopArchiveView> {
  ArchivePeriodFilter _selectedPeriod = ArchivePeriodFilter.thisMonth;
  DateTimeRange? _customDateRange;
  ArchiveSortBy _sortBy = ArchiveSortBy.dateDesc;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final Set<String> _selectedOrderIds = {};

  late Stream<List<OrdersRecord>> _archiveStream;

  @override
  void initState() {
    super.initState();
    _initArchiveStream();
  }

  void _initArchiveStream() {
    _archiveStream = queryOrdersRecord(
      queryBuilder: (orders) {
        return orders.where('stato_ordine', isEqualTo: 'archiviato');
      },
      limit: 500,
    );
  }

  @override
  void didUpdateWidget(covariant DesktopArchiveView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.ristoranteRef != widget.ristoranteRef) {
      _initArchiveStream();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _isOrderInSelectedPeriod(OrdersRecord order) {
    if (_selectedPeriod == ArchivePeriodFilter.all) return true;
    final date = order.dataCreazione;
    if (date == null) return false;

    final now = DateTime.now();

    switch (_selectedPeriod) {
      case ArchivePeriodFilter.today:
        return date.year == now.year &&
            date.month == now.month &&
            date.day == now.day;

      case ArchivePeriodFilter.thisWeek:
        // Ultimi 7 giorni fino ad oggi compreso
        final startOfWeek = DateTime(now.year, now.month, now.day)
            .subtract(const Duration(days: 6));
        final endOfToday = DateTime(now.year, now.month, now.day, 23, 59, 59);
        return date.isAfter(startOfWeek.subtract(const Duration(seconds: 1))) &&
            date.isBefore(endOfToday.add(const Duration(seconds: 1)));

      case ArchivePeriodFilter.thisMonth:
        return date.year == now.year && date.month == now.month;

      case ArchivePeriodFilter.thisYear:
        return date.year == now.year;

      case ArchivePeriodFilter.customRange:
        if (_customDateRange == null) return true;
        final start = DateTime(
          _customDateRange!.start.year,
          _customDateRange!.start.month,
          _customDateRange!.start.day,
          0,
          0,
          0,
        );
        final end = DateTime(
          _customDateRange!.end.year,
          _customDateRange!.end.month,
          _customDateRange!.end.day,
          23,
          59,
          59,
        );
        return date.isAfter(start.subtract(const Duration(seconds: 1))) &&
            date.isBefore(end.add(const Duration(seconds: 1)));

      case ArchivePeriodFilter.all:
        return true;
    }
  }

  String _getPeriodLabel() {
    switch (_selectedPeriod) {
      case ArchivePeriodFilter.today:
        return 'Oggi';
      case ArchivePeriodFilter.thisWeek:
        return 'Questa Settimana';
      case ArchivePeriodFilter.thisMonth:
        return 'Questo Mese';
      case ArchivePeriodFilter.thisYear:
        return 'Quest\'Anno';
      case ArchivePeriodFilter.customRange:
        if (_customDateRange != null) {
          final fromStr = dateTimeFormat('d/M/y', _customDateRange!.start);
          final toStr = dateTimeFormat('d/M/y', _customDateRange!.end);
          return '$fromStr - $toStr';
        }
        return 'Data Specifica';
      case ArchivePeriodFilter.all:
        return 'Tutto lo Storico';
    }
  }

  void _exportCsv(List<OrdersRecord> orders) {
    if (orders.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nessuna comanda da esportare per il periodo selezionato.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final buffer = StringBuffer();
    // Intestazione CSV
    buffer.writeln('ID Ordine;Data Creazione;Orario;Tavolo;Piatti Ordinati;Totale (€);Stato');

    for (final order in orders) {
      final dateStr = order.dataCreazione != null
          ? dateTimeFormat('d/M/y', order.dataCreazione)
          : '';
      final timeStr = order.dataCreazione != null
          ? dateTimeFormat('HH:mm', order.dataCreazione)
          : '';
      final tableStr = 'Tavolo ${order.tavolo}';
      // Sostituisce i punti e virgola o newline per non rompere le colonne CSV
      final dishes = order.listaPiatti
          .replaceAll(';', ' - ')
          .replaceAll('\n', ' ')
          .replaceAll('\r', '')
          .trim();
      final totalStr = order.totale.toStringAsFixed(2).replaceAll('.', ',');
      final statusStr = order.statoOrdine;

      buffer.writeln(
        '"${order.reference.id}";"$dateStr";"$timeStr";"$tableStr";"$dishes";"$totalStr";"$statusStr"',
      );
    }

    final dateTag = dateTimeFormat('yyyyMMdd_HHmm', DateTime.now());
    final filename = 'report_ordini_${_selectedPeriod.name}_$dateTag.csv';

    downloadCsvFile(buffer.toString(), filename);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.download_done_rounded, color: Colors.white),
            const SizedBox(width: 10.0),
            Expanded(
              child: Text(
                'Report CSV generato con successo: $filename (${orders.length} comande)',
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _pickCustomDateRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: DateTime(now.year + 2),
      initialDateRange: _customDateRange ??
          DateTimeRange(
            start: DateTime(now.year, now.month, 1),
            end: now,
          ),
      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF6366F1),
              brightness: isDark ? Brightness.dark : Brightness.light,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _customDateRange = picked;
        _selectedPeriod = ArchivePeriodFilter.customRange;
      });
    }
  }

  Future<void> _eliminaSingolo(OrdersRecord order) async {
    final theme = Theme.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: theme.colorScheme.error.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.delete_outline_rounded, color: theme.colorScheme.error, size: 22.0),
            ),
            const SizedBox(width: 12.0),
            const Text('Elimina comanda?', style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          'Vuoi eliminare definitivamente la comanda del Tavolo ${order.tavolo} dall\'archivio?\n\nQuesta azione non può essere annullata.',
          style: const TextStyle(fontSize: 13.5, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annulla'),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.delete_forever_rounded, size: 16.0),
            label: const Text('Elimina'),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: Colors.white,
              elevation: 0.0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await order.reference.delete();
      setState(() {
        _selectedOrderIds.remove(order.reference.id);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Comanda Tavolo ${order.tavolo} eliminata con successo.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _eliminaSelezionati(List<OrdersRecord> allOrders) async {
    final toDelete = allOrders
        .where((o) => _selectedOrderIds.contains(o.reference.id))
        .toList();

    if (toDelete.isEmpty) return;

    final theme = Theme.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: theme.colorScheme.error.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.delete_sweep_rounded, color: theme.colorScheme.error, size: 24.0),
            ),
            const SizedBox(width: 12.0),
            Text('Elimina ${toDelete.length} comande?', style: const TextStyle(fontSize: 17.0, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          'Sei sicuro di voler eliminare definitivamente ${toDelete.length} comande selezionate dall\'archivio?\n\nQuesta azione cancellerà i record e non potrà essere annullata.',
          style: const TextStyle(fontSize: 13.5, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annulla'),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.delete_forever_rounded, size: 16.0),
            label: Text('Elimina (${toDelete.length})'),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: Colors.white,
              elevation: 0.0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
          ),
        ],
      ),
    );

    if (confirm == true) {
      for (final order in toDelete) {
        await order.reference.delete();
      }
      setState(() {
        _selectedOrderIds.clear();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${toDelete.length} comande eliminate definitivamente dall\'archivio.'),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final docRef = widget.ristoranteRef;

    return StreamBuilder<List<OrdersRecord>>(
      stream: _archiveStream,
      builder: (context, snapshot) {
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
                    'Errore nel caricamento dell\'archivio ordini',
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
                  size: 48.0,
                ),
                const SizedBox(height: 16.0),
                Text(
                  'Caricamento archivio ordini...',
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

        List<OrdersRecord> allArchived = snapshot.data!;
        if (docRef != null) {
          allArchived = allArchived
              .where((o) => o.ristoranteRef == null || o.ristoranteRef == docRef)
              .toList();
        }

        // Filtro per periodo
        List<OrdersRecord> periodOrders =
            allArchived.where(_isOrderInSelectedPeriod).toList();

        // Calcolo KPI del periodo selezionato
        final int comandeCount = periodOrders.length;
        final double totaleIncasso = periodOrders.fold(
          0.0,
          (acc, o) => acc + o.totale,
        );
        final double scontrinoMedio =
            comandeCount > 0 ? (totaleIncasso / comandeCount) : 0.0;
        final int tavoliDistinti =
            periodOrders.map((o) => o.tavolo).toSet().length;

        // Filtro ricerca
        List<OrdersRecord> filteredOrders = periodOrders;
        if (_searchQuery.trim().isNotEmpty) {
          final q = _searchQuery.trim().toLowerCase();
          filteredOrders = filteredOrders.where((o) {
            final matchTavolo = 'tavolo ${o.tavolo}'.toLowerCase().contains(q) ||
                o.tavolo.toString().contains(q);
            final matchPiatti = o.listaPiatti.toLowerCase().contains(q);
            return matchTavolo || matchPiatti;
          }).toList();
        }

        // Ordinamento personalizzato
        filteredOrders.sort((a, b) {
          switch (_sortBy) {
            case ArchiveSortBy.dateDesc:
              final dA = a.dataCreazione ?? DateTime(1970);
              final dB = b.dataCreazione ?? DateTime(1970);
              return dB.compareTo(dA);
            case ArchiveSortBy.dateAsc:
              final dA = a.dataCreazione ?? DateTime(1970);
              final dB = b.dataCreazione ?? DateTime(1970);
              return dA.compareTo(dB);
            case ArchiveSortBy.tableAsc:
              return a.tavolo.compareTo(b.tavolo);
            case ArchiveSortBy.tableDesc:
              return b.tavolo.compareTo(a.tavolo);
            case ArchiveSortBy.totalDesc:
              return b.totale.compareTo(a.totale);
            case ArchiveSortBy.totalAsc:
              return a.totale.compareTo(b.totale);
          }
        });

        return Container(
          color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ═════════════════════════════════════════════════════════════
              // 1. CARDS KPI STATISTICHE DEL PERIODO
              // ═════════════════════════════════════════════════════════════
              Padding(
                padding: const EdgeInsets.fromLTRB(28.0, 24.0, 28.0, 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildKpiCard(
                        title: 'Incasso ${_getPeriodLabel()}',
                        value: '${totaleIncasso.toStringAsFixed(2)} €',
                        icon: Icons.payments_rounded,
                        color: const Color(0xFF10B981),
                        bgColor: const Color(0xFF10B981).withValues(alpha: 0.12),
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: _buildKpiCard(
                        title: 'Comande Archiviate',
                        value: '$comandeCount',
                        icon: Icons.inventory_2_rounded,
                        color: const Color(0xFF6366F1),
                        bgColor: const Color(0xFF6366F1).withValues(alpha: 0.12),
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: _buildKpiCard(
                        title: 'Scontrino Medio',
                        value: '${scontrinoMedio.toStringAsFixed(2)} €',
                        icon: Icons.analytics_rounded,
                        color: const Color(0xFFF59E0B),
                        bgColor: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: _buildKpiCard(
                        title: 'Tavoli Serviti',
                        value: '$tavoliDistinti',
                        icon: Icons.table_restaurant_rounded,
                        color: const Color(0xFF0EA5E9),
                        bgColor: const Color(0xFF0EA5E9).withValues(alpha: 0.12),
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),
              ),

              // ═════════════════════════════════════════════════════════════
              // 2. BARRA STRUMENTI: FILTRI PERIODO, ORDINAMENTO, DOWNLOAD
              // ═════════════════════════════════════════════════════════════
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28.0),
                child: Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(14.0),
                    border: Border.all(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Chip Periodo
                      _buildPeriodChip('Oggi', ArchivePeriodFilter.today, isDark),
                      const SizedBox(width: 6.0),
                      _buildPeriodChip('Questa Settimana', ArchivePeriodFilter.thisWeek, isDark),
                      const SizedBox(width: 6.0),
                      _buildPeriodChip('Questo Mese', ArchivePeriodFilter.thisMonth, isDark),
                      const SizedBox(width: 6.0),
                      _buildPeriodChip('Quest\'Anno', ArchivePeriodFilter.thisYear, isDark),
                      const SizedBox(width: 6.0),
                      _buildPeriodChip('Tutti', ArchivePeriodFilter.all, isDark),
                      const SizedBox(width: 6.0),

                      // Tasto Data Specifica / Range
                      OutlinedButton.icon(
                        onPressed: _pickCustomDateRange,
                        icon: const Icon(Icons.date_range_rounded, size: 16.0),
                        label: Text(
                          _selectedPeriod == ArchivePeriodFilter.customRange && _customDateRange != null
                              ? '${dateTimeFormat('d/M', _customDateRange!.start)} - ${dateTimeFormat('d/M/yy', _customDateRange!.end)}'
                              : 'Data Specifica',
                          style: const TextStyle(fontSize: 12.0, fontWeight: FontWeight.w600),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _selectedPeriod == ArchivePeriodFilter.customRange
                              ? Colors.white
                              : (isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569)),
                          backgroundColor: _selectedPeriod == ArchivePeriodFilter.customRange
                              ? const Color(0xFF6366F1)
                              : Colors.transparent,
                          side: BorderSide(
                            color: _selectedPeriod == ArchivePeriodFilter.customRange
                                ? const Color(0xFF6366F1)
                                : (isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1)),
                          ),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                        ),
                      ),

                      const Spacer(),

                      // Dropdown Ordinamento
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        height: 38.0,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(10.0),
                          border: Border.all(
                            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<ArchiveSortBy>(
                            value: _sortBy,
                            icon: const Icon(Icons.arrow_drop_down_rounded),
                            dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                            ),
                            onChanged: (val) {
                              if (val != null) setState(() => _sortBy = val);
                            },
                            items: const [
                              DropdownMenuItem(
                                value: ArchiveSortBy.dateDesc,
                                child: Text('Più recenti prima'),
                              ),
                              DropdownMenuItem(
                                value: ArchiveSortBy.dateAsc,
                                child: Text('Meno recenti prima'),
                              ),
                              DropdownMenuItem(
                                value: ArchiveSortBy.totalDesc,
                                child: Text('Totale: più alto'),
                              ),
                              DropdownMenuItem(
                                value: ArchiveSortBy.totalAsc,
                                child: Text('Totale: più basso'),
                              ),
                              DropdownMenuItem(
                                value: ArchiveSortBy.tableAsc,
                                child: Text('Tavolo: crescente'),
                              ),
                              DropdownMenuItem(
                                value: ArchiveSortBy.tableDesc,
                                child: Text('Tavolo: decrescente'),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(width: 10.0),

                      // Bottone Download CSV
                      ElevatedButton.icon(
                        onPressed: () => _exportCsv(filteredOrders),
                        icon: const Icon(Icons.file_download_outlined, size: 18.0),
                        label: Text(
                          'Scarica CSV (${filteredOrders.length})',
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
              ),

              const SizedBox(height: 12.0),

              // Campo di ricerca rapida
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28.0),
                child: SizedBox(
                  height: 40.0,
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) => setState(() => _searchQuery = val),
                    style: TextStyle(
                      fontSize: 13.5,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                    decoration: InputDecoration(
                      hintText: 'Cerca comanda per numero di tavolo o nome del piatto...',
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

              const SizedBox(height: 14.0),

              // Banner Selezione Multipla
              if (_selectedOrderIds.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(28.0, 0.0, 28.0, 14.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(
                        color: const Color(0xFF6366F1).withValues(alpha: 0.4),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6366F1).withValues(alpha: 0.08),
                          blurRadius: 8.0,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6.0),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6366F1).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: const Icon(Icons.check_box_rounded, color: Color(0xFF6366F1), size: 18.0),
                        ),
                        const SizedBox(width: 10.0),
                        Text(
                          '${_selectedOrderIds.length} ${_selectedOrderIds.length == 1 ? 'comanda selezionata' : 'comande selezionate'}',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(width: 14.0),
                        TextButton(
                          onPressed: () => setState(() => _selectedOrderIds.clear()),
                          style: TextButton.styleFrom(
                            foregroundColor: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                            textStyle: const TextStyle(fontSize: 12.5),
                          ),
                          child: const Text('Deseleziona'),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _selectedOrderIds.addAll(filteredOrders.map((o) => o.reference.id));
                            });
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF6366F1),
                            textStyle: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                          ),
                          child: Text('Seleziona tutti filtrati (${filteredOrders.length})'),
                        ),
                        const Spacer(),
                        // Scarica CSV comande selezionate
                        OutlinedButton.icon(
                          onPressed: () {
                            final selected = filteredOrders
                                .where((o) => _selectedOrderIds.contains(o.reference.id))
                                .toList();
                            _exportCsv(selected);
                          },
                          icon: const Icon(Icons.download_rounded, size: 16.0),
                          label: const Text('Scarica CSV selezionati', style: TextStyle(fontSize: 12.0)),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                          ),
                        ),
                        const SizedBox(width: 10.0),
                        // Elimina comande selezionate
                        ElevatedButton.icon(
                          onPressed: () => _eliminaSelezionati(filteredOrders),
                          icon: const Icon(Icons.delete_forever_rounded, size: 16.0),
                          label: Text(
                            'Elimina selezionati (${_selectedOrderIds.length})',
                            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.error,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                            elevation: 0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // ═════════════════════════════════════════════════════════════
              // 3. TABELLA ORDINI ARCHIVIATI
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
                        ? _buildEmptyArchiveState(isDark, colorScheme)
                        : _buildArchiveTable(filteredOrders, isDark, colorScheme),
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
  // HELPERS UI
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildPeriodChip(
    String label,
    ArchivePeriodFilter filter,
    bool isDark,
  ) {
    final isSelected = _selectedPeriod == filter;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() => _selectedPeriod = filter);
        }
      },
      labelStyle: TextStyle(
        fontSize: 12.0,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        color: isSelected
            ? Colors.white
            : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
      ),
      selectedColor: const Color(0xFF6366F1),
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
      side: BorderSide(
        color: isSelected
            ? const Color(0xFF6366F1)
            : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color bgColor,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 16.0),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          width: 1.0,
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
    );
  }

  Widget _buildArchiveTable(
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
                  showCheckboxColumn: true,
                  headingRowHeight: 52.0,
                  dataRowMaxHeight: 88.0,
                  dataRowMinHeight: 70.0,
                  horizontalMargin: 24.0,
                  columnSpacing: 28.0,
                  headingRowColor: WidgetStateProperty.all(
                    isDark
                        ? const Color(0xFF0F172A).withValues(alpha: 0.6)
                        : const Color(0xFFF8FAFC),
                  ),
                  dividerThickness: 1.0,
                  border: TableBorder(
                    horizontalInside: BorderSide(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.06)
                          : const Color(0xFFF1F5F9),
                      width: 1.0,
                    ),
                  ),
                  columns: const [
                    DataColumn(
                      label: Text(
                        'TAVOLO',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11.5, letterSpacing: 0.6),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'DATA & ORA ORDINE',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11.5, letterSpacing: 0.6),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'PIATTI ORDINATI',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11.5, letterSpacing: 0.6),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'TOTALE',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11.5, letterSpacing: 0.6),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'STATO',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11.5, letterSpacing: 0.6),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'AZIONI',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11.5, letterSpacing: 0.6),
                      ),
                    ),
                  ],
                  rows: orders.map((order) {
                    final piatti = functions.raggruppaPiattiDaStringa(order.listaPiatti) ?? [];
                    final isSelected = _selectedOrderIds.contains(order.reference.id);

                    return DataRow(
                      selected: isSelected,
                      onSelectChanged: (selected) {
                        setState(() {
                          if (selected == true) {
                            _selectedOrderIds.add(order.reference.id);
                          } else {
                            _selectedOrderIds.remove(order.reference.id);
                          }
                        });
                      },
                      cells: [
                        // 1. Tavolo
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 7.0),
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10.0),
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
                                    fontSize: 14.0,
                                    color: colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // 2. Data & Ora
                        DataCell(
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                order.dataCreazione != null
                                    ? dateTimeFormat('d MMMM y', order.dataCreazione, locale: 'it')
                                    : '--/--/----',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13.5,
                                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(height: 3.0),
                              Text(
                                order.dataCreazione != null
                                    ? 'Orario: ${dateTimeFormat('HH:mm', order.dataCreazione)}'
                                    : '',
                                style: TextStyle(
                                  fontSize: 12.0,
                                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // 3. Piatti Ordinati
                        DataCell(
                          SizedBox(
                            width: 320.0,
                            child: piatti.isEmpty
                                ? Text('Nessun piatto specificato',
                                    style: TextStyle(fontStyle: FontStyle.italic, color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)))
                                : Wrap(
                                    spacing: 6.0,
                                    runSpacing: 4.0,
                                    children: [
                                      ...piatti.take(3).map((p) => Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
                                            decoration: BoxDecoration(
                                              color: isDark
                                                  ? Colors.white.withValues(alpha: 0.06)
                                                  : const Color(0xFFF1F5F9),
                                              borderRadius: BorderRadius.circular(6.0),
                                              border: Border.all(
                                                color: isDark
                                                    ? Colors.white.withValues(alpha: 0.08)
                                                    : const Color(0xFFE2E8F0),
                                              ),
                                            ),
                                            child: Text(
                                              p,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 11.5,
                                                fontWeight: FontWeight.w500,
                                                color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF334155),
                                              ),
                                            ),
                                          )),
                                      if (piatti.length > 3)
                                        InkWell(
                                          onTap: () => _mostraDettaglioOrdine(context, order, piatti),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 7.0, vertical: 3.0),
                                            decoration: BoxDecoration(
                                              color: colorScheme.primary.withValues(alpha: 0.12),
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

                        // 5. Stato
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6366F1).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8.0),
                              border: Border.all(
                                color: const Color(0xFF6366F1).withValues(alpha: 0.3),
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.inventory_2_rounded, size: 14.0, color: Color(0xFF6366F1)),
                                SizedBox(width: 5.0),
                                Text(
                                  'Archiviato',
                                  style: TextStyle(
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF6366F1),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // 6. Azioni
                        DataCell(
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              OutlinedButton.icon(
                                onPressed: () => _mostraDettaglioOrdine(context, order, piatti),
                                icon: const Icon(Icons.info_outline_rounded, size: 14.0),
                                label: const Text('Dettaglio', style: TextStyle(fontSize: 11.5)),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                                ),
                              ),
                              const SizedBox(width: 6.0),
                              IconButton(
                                icon: Icon(Icons.delete_outline_rounded, color: colorScheme.error, size: 18.0),
                                tooltip: 'Elimina comanda',
                                style: IconButton.styleFrom(
                                  backgroundColor: colorScheme.error.withValues(alpha: 0.1),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                                  padding: const EdgeInsets.all(7.0),
                                ),
                                onPressed: () => _eliminaSingolo(order),
                              ),
                              const SizedBox(width: 6.0),
                              PopupMenuButton<String>(
                                icon: Icon(
                                  Icons.more_vert_rounded,
                                  size: 18.0,
                                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                ),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                                onSelected: (val) async {
                                  if (val == 'riapri') {
                                    await order.reference.update(createOrdersRecordData(
                                      statoOrdine: 'Completato',
                                      visto: true,
                                    ));
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Comanda Tavolo ${order.tavolo} ripristinata in Completati.'),
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                    }
                                  } else if (val == 'in_attesa') {
                                    await order.reference.update(createOrdersRecordData(
                                      statoOrdine: 'in_attesa',
                                      visto: false,
                                    ));
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Comanda Tavolo ${order.tavolo} rimessa In Attesa.'),
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                    }
                                  } else if (val == 'elimina') {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: const Text('Elimina definitivamente'),
                                        content: Text(
                                          'Vuoi eliminare definitivamente questo ordine del Tavolo ${order.tavolo} dall\'archivio?\n\nQuesta operazione non può essere annullata.',
                                        ),
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
                                    value: 'riapri',
                                    child: Row(
                                      children: [
                                        Icon(Icons.unarchive_outlined, size: 16.0),
                                        SizedBox(width: 8.0),
                                        Text('Ripristina in Completati'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'in_attesa',
                                    child: Row(
                                      children: [
                                        Icon(Icons.replay_rounded, size: 16.0),
                                        SizedBox(width: 8.0),
                                        Text('Rimetti In Attesa'),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 'elimina',
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete_outline_rounded, size: 16.0, color: colorScheme.error),
                                        const SizedBox(width: 8.0),
                                        Text('Elimina definitivamente', style: TextStyle(color: colorScheme.error)),
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

  Widget _buildEmptyArchiveState(bool isDark, ColorScheme colorScheme) {
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
                color: const Color(0xFF6366F1).withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.inventory_2_outlined,
                size: 38.0,
                color: Color(0xFF6366F1),
              ),
            ),
            const SizedBox(height: 18.0),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Nessun ordine trovato per "$_searchQuery"'
                  : 'Nessuna comanda archiviata per ${_getPeriodLabel()}',
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
                  : 'Quando le comande vengono completate e archiviate (dalla cucina o dallo smartphone),\nverranno conservate qui per le statistiche e l\'esportazione CSV.',
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
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6366F1).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: const Text(
                          'Archiviato',
                          style: TextStyle(
                            fontSize: 12.0,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF6366F1),
                          ),
                        ),
                      ),
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
                'Dettaglio Comanda Archiviata',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              if (order.dataCreazione != null) ...[
                const SizedBox(height: 4.0),
                Text(
                  'Orario ordine: ${dateTimeFormat('d MMMM y, HH:mm', order.dataCreazione, locale: 'it')}',
                  style: TextStyle(
                    fontSize: 13.0,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                ),
              ],
              const SizedBox(height: 16.0),
              const Divider(height: 1.0),
              const SizedBox(height: 16.0),
              Text(
                'PIATTI RICHIESTI (${piatti.length})',
                style: TextStyle(
                  fontSize: 12.0,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 10.0),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: piatti.length,
                  separatorBuilder: (_, __) => const Divider(height: 12.0),
                  itemBuilder: (context, i) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 4.0),
                          width: 6.0,
                          height: 6.0,
                          decoration: const BoxDecoration(
                            color: Color(0xFF6366F1),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10.0),
                        Expanded(
                          child: Text(
                            piatti[i],
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w500,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 16.0),
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
                      fontSize: 22.0,
                      fontWeight: FontWeight.w900,
                      color: theme.colorScheme.primary,
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
