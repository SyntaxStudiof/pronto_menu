import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'admin_cronologia_azioni_model.dart';
export 'admin_cronologia_azioni_model.dart';

class AdminCronologiaAzioniWidget extends StatefulWidget {
  const AdminCronologiaAzioniWidget({
    super.key,
    this.embedded = false,
  });

  final bool embedded;

  static String routeName = 'AdminCronologiaAzioni';
  static String routePath = '/adminCronologiaAzioni';

  @override
  State<AdminCronologiaAzioniWidget> createState() =>
      _AdminCronologiaAzioniWidgetState();
}

class _AdminCronologiaAzioniWidgetState
    extends State<AdminCronologiaAzioniWidget> {
  late AdminCronologiaAzioniModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AdminCronologiaAzioniModel());
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  String _formatFriendlyTimestamp(DateTime? dt) {
    if (dt == null) return 'Data sconosciuta';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final logDate = DateTime(dt.year, dt.month, dt.day);

    final timeStr = DateFormat('HH:mm').format(dt);

    if (logDate == today) {
      return 'Oggi alle $timeStr';
    } else if (logDate == yesterday) {
      return 'Ieri alle $timeStr';
    } else {
      return DateFormat('d MMM y, HH:mm', 'it_IT').format(dt);
    }
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
                        Icons.manage_history_rounded,
                        color: purpleAccent,
                        size: 20.0,
                      ),
                    ),
                    const SizedBox(width: 10.0),
                    Text(
                      'Cronologia Azioni',
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
          child: StreamBuilder<List<ActionLogsRecord>>(
            stream: queryActionLogsRecord(
              queryBuilder: (actionLogs) =>
                  actionLogs.orderBy('data_ora', descending: true),
            ),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          size: 48.0,
                          color: theme.colorScheme.error,
                        ),
                        const SizedBox(height: 12.0),
                        Text(
                          'Errore nel caricamento dei log',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6.0),
                        Text(
                          '${snapshot.error}',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                );
              }

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

              final allLogs = snapshot.data!;

              // Conteggi per statistiche
              final totalCount = allLogs.length;
              final deleteCount = allLogs.where((l) {
                final t = l.tipoAzione.toLowerCase();
                return t == 'delete' || t == 'eliminazione';
              }).length;
              final updateCount = allLogs.where((l) {
                final t = l.tipoAzione.toLowerCase();
                return t == 'update' || t == 'modifica';
              }).length;
              final createCount = allLogs.where((l) {
                final t = l.tipoAzione.toLowerCase();
                return t == 'create' || t == 'creazione';
              }).length;
              final restoreCount = allLogs.where((l) {
                final t = l.tipoAzione.toLowerCase();
                return t == 'restore' || t == 'ripristino';
              }).length;

              // Estrai nomi univoci dei ristoranti presenti nei log
              final Map<String, String> ristorantiMap = {};
              for (final l in allLogs) {
                if (l.ristoranteNome.isNotEmpty) {
                  ristorantiMap[l.ristoranteNome] = l.ristoranteNome;
                }
              }
              final listaRistoranti = ['Tutti', ...ristorantiMap.keys];

              // Applica filtro tipo
              var filteredList = allLogs.where((l) {
                if (_model.filtroTipo != 'Tutti') {
                  final logTipo = l.tipoAzione.toLowerCase();
                  final fTipo = _model.filtroTipo.toLowerCase();
                  bool matches = false;
                  if (fTipo == 'delete' || fTipo == 'eliminazione') {
                    matches = logTipo == 'delete' || logTipo == 'eliminazione';
                  } else if (fTipo == 'update' || fTipo == 'modifica') {
                    matches = logTipo == 'update' || logTipo == 'modifica';
                  } else if (fTipo == 'create' || fTipo == 'creazione') {
                    matches = logTipo == 'create' || logTipo == 'creazione';
                  } else if (fTipo == 'restore' || fTipo == 'ripristino') {
                    matches = logTipo == 'restore' || logTipo == 'ripristino';
                  } else {
                    matches = logTipo == fTipo;
                  }
                  if (!matches) return false;
                }
                if (_model.filtroRistorante != 'Tutti' &&
                    l.ristoranteNome != _model.filtroRistorante) {
                  return false;
                }
                return true;
              }).toList();

              // Applica filtro ricerca libera
              final query =
                  _model.searchController?.text.trim().toLowerCase() ?? '';
              if (query.isNotEmpty) {
                filteredList = filteredList.where((l) {
                  return l.ristoranteNome.toLowerCase().contains(query) ||
                      l.utenteNome.toLowerCase().contains(query) ||
                      l.utenteEmail.toLowerCase().contains(query) ||
                      l.azione.toLowerCase().contains(query) ||
                      l.dettagli.toLowerCase().contains(query);
                }).toList();
              }

              return Container(
                color: bgCanvas,
                child: SingleChildScrollView(
                  controller: _model.scrollController,
                  padding: widget.embedded
                      ? const EdgeInsets.fromLTRB(28.0, 24.0, 28.0, 40.0)
                      : const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 32.0),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1400.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // ── 1. BANNER AUDIT LOG TUTELA ─────────────────────
                          Container(
                            padding: const EdgeInsets.all(18.0),
                            decoration: BoxDecoration(
                              color: cardBg,
                              borderRadius: BorderRadius.circular(16.0),
                              border: Border.all(color: cardBorder),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                                  blurRadius: 10.0,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 44.0,
                                  height: 44.0,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2563EB).withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  alignment: Alignment.center,
                                  child: const Icon(
                                    Icons.shield_rounded,
                                    color: Color(0xFF3B82F6),
                                    size: 24.0,
                                  ),
                                ),
                                const SizedBox(width: 14.0),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Registro di Sicurezza & Tutela App',
                                        style: TextStyle(
                                          color: textPrimary,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15.0,
                                        ),
                                      ),
                                      const SizedBox(height: 3.0),
                                      Text(
                                        'Ogni eliminazione di categoria, piatto o modifica importante viene registrata in tempo reale con orario e utente esatto.',
                                        style: TextStyle(
                                          color: textSecondary,
                                          fontSize: 12.5,
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

                          // ── 2. KPI COUNTERS ────────────────────────────────
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final isWide = constraints.maxWidth >= 960;
                              return isWide
                                  ? Row(
                                      children: [
                                        Expanded(
                                          child: _buildAuditKpiCard(
                                            title: 'Eliminazioni',
                                            value: '$deleteCount',
                                            subtitle: _model.filtroTipo == 'delete'
                                                ? '● Filtro attivo'
                                                : 'Filtra eliminazioni',
                                            icon: Icons.delete_outline_rounded,
                                            accentColor: const Color(0xFFEF4444),
                                            cardBg: cardBg,
                                            cardBorder: cardBorder,
                                            textPrimary: textPrimary,
                                            textSecondary: textSecondary,
                                            isDark: isDark,
                                            isSelected: _model.filtroTipo == 'delete',
                                            onTap: () => safeSetState(() {
                                              _model.filtroTipo = _model.filtroTipo == 'delete'
                                                  ? 'Tutti'
                                                  : 'delete';
                                            }),
                                          ),
                                        ),
                                        const SizedBox(width: 16.0),
                                        Expanded(
                                          child: _buildAuditKpiCard(
                                            title: 'Modifiche',
                                            value: '$updateCount',
                                            subtitle: _model.filtroTipo == 'update'
                                                ? '● Filtro attivo'
                                                : 'Variazioni menù',
                                            icon: Icons.edit_note_rounded,
                                            accentColor: const Color(0xFFF59E0B),
                                            cardBg: cardBg,
                                            cardBorder: cardBorder,
                                            textPrimary: textPrimary,
                                            textSecondary: textSecondary,
                                            isDark: isDark,
                                            isSelected: _model.filtroTipo == 'update',
                                            onTap: () => safeSetState(() {
                                              _model.filtroTipo = _model.filtroTipo == 'update'
                                                  ? 'Tutti'
                                                  : 'update';
                                            }),
                                          ),
                                        ),
                                        const SizedBox(width: 16.0),
                                        Expanded(
                                          child: _buildAuditKpiCard(
                                            title: 'Creazioni',
                                            value: '$createCount',
                                            subtitle: _model.filtroTipo == 'create'
                                                ? '● Filtro attivo'
                                                : 'Nuovi elementi',
                                            icon: Icons.add_circle_outline_rounded,
                                            accentColor: const Color(0xFF10B981),
                                            cardBg: cardBg,
                                            cardBorder: cardBorder,
                                            textPrimary: textPrimary,
                                            textSecondary: textSecondary,
                                            isDark: isDark,
                                            isSelected: _model.filtroTipo == 'create',
                                            onTap: () => safeSetState(() {
                                              _model.filtroTipo = _model.filtroTipo == 'create'
                                                  ? 'Tutti'
                                                  : 'create';
                                            }),
                                          ),
                                        ),
                                        const SizedBox(width: 16.0),
                                        Expanded(
                                          child: _buildAuditKpiCard(
                                            title: 'Totale Eventi',
                                            value: '$totalCount',
                                            subtitle: _model.filtroTipo == 'Tutti'
                                                ? '● Mostra tutti'
                                                : 'Tutti i log di sistema',
                                            icon: Icons.format_list_bulleted_rounded,
                                            accentColor: purpleAccent,
                                            cardBg: cardBg,
                                            cardBorder: cardBorder,
                                            textPrimary: textPrimary,
                                            textSecondary: textSecondary,
                                            isDark: isDark,
                                            isSelected: _model.filtroTipo == 'Tutti',
                                            onTap: () => safeSetState(() {
                                              _model.filtroTipo = 'Tutti';
                                            }),
                                          ),
                                        ),
                                      ],
                                    )
                                  : Wrap(
                                      spacing: 12.0,
                                      runSpacing: 12.0,
                                      children: [
                                        SizedBox(
                                          width: (constraints.maxWidth - 12.0) / 2,
                                          child: _buildAuditKpiCard(
                                            title: 'Eliminazioni',
                                            value: '$deleteCount',
                                            subtitle: 'Filtra eliminazioni',
                                            icon: Icons.delete_outline_rounded,
                                            accentColor: const Color(0xFFEF4444),
                                            cardBg: cardBg,
                                            cardBorder: cardBorder,
                                            textPrimary: textPrimary,
                                            textSecondary: textSecondary,
                                            isDark: isDark,
                                            isSelected: _model.filtroTipo == 'delete',
                                            onTap: () => safeSetState(() {
                                              _model.filtroTipo = _model.filtroTipo == 'delete'
                                                  ? 'Tutti'
                                                  : 'delete';
                                            }),
                                          ),
                                        ),
                                        SizedBox(
                                          width: (constraints.maxWidth - 12.0) / 2,
                                          child: _buildAuditKpiCard(
                                            title: 'Modifiche',
                                            value: '$updateCount',
                                            subtitle: 'Variazioni menù',
                                            icon: Icons.edit_note_rounded,
                                            accentColor: const Color(0xFFF59E0B),
                                            cardBg: cardBg,
                                            cardBorder: cardBorder,
                                            textPrimary: textPrimary,
                                            textSecondary: textSecondary,
                                            isDark: isDark,
                                            isSelected: _model.filtroTipo == 'update',
                                            onTap: () => safeSetState(() {
                                              _model.filtroTipo = _model.filtroTipo == 'update'
                                                  ? 'Tutti'
                                                  : 'update';
                                            }),
                                          ),
                                        ),
                                        SizedBox(
                                          width: (constraints.maxWidth - 12.0) / 2,
                                          child: _buildAuditKpiCard(
                                            title: 'Creazioni',
                                            value: '$createCount',
                                            subtitle: 'Nuovi piatti & cat.',
                                            icon: Icons.add_circle_outline_rounded,
                                            accentColor: const Color(0xFF10B981),
                                            cardBg: cardBg,
                                            cardBorder: cardBorder,
                                            textPrimary: textPrimary,
                                            textSecondary: textSecondary,
                                            isDark: isDark,
                                            isSelected: _model.filtroTipo == 'create',
                                            onTap: () => safeSetState(() {
                                              _model.filtroTipo = _model.filtroTipo == 'create'
                                                  ? 'Tutti'
                                                  : 'create';
                                            }),
                                          ),
                                        ),
                                        SizedBox(
                                          width: (constraints.maxWidth - 12.0) / 2,
                                          child: _buildAuditKpiCard(
                                            title: 'Totale Eventi',
                                            value: '$totalCount',
                                            subtitle: 'Tutti i log',
                                            icon: Icons.format_list_bulleted_rounded,
                                            accentColor: purpleAccent,
                                            cardBg: cardBg,
                                            cardBorder: cardBorder,
                                            textPrimary: textPrimary,
                                            textSecondary: textSecondary,
                                            isDark: isDark,
                                            isSelected: _model.filtroTipo == 'Tutti',
                                            onTap: () => safeSetState(() {
                                              _model.filtroTipo = 'Tutti';
                                            }),
                                          ),
                                        ),
                                      ],
                                    );
                            },
                          ),

                          const SizedBox(height: 18.0),

                          // ── 3. BARRA DI RICERCA & FILTRI DESKTOP ────────────
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
                                          controller: _model.searchController,
                                          focusNode: _model.searchFocusNode,
                                          onChanged: (_) => safeSetState(() {}),
                                          style: TextStyle(
                                            fontSize: 13.5,
                                            color: textPrimary,
                                          ),
                                          decoration: InputDecoration(
                                            isDense: true,
                                            hintText: 'Cerca per ristorante, utente, elemento o azione...',
                                            hintStyle: TextStyle(
                                              fontSize: 13.5,
                                              color: textSecondary,
                                            ),
                                            border: InputBorder.none,
                                          ),
                                        ),
                                      ),
                                      if (_model.searchController?.text.isNotEmpty ?? false)
                                        IconButton(
                                          icon: Icon(
                                            Icons.close_rounded,
                                            size: 18.0,
                                            color: textSecondary,
                                          ),
                                          onPressed: () {
                                            _model.searchController?.clear();
                                            safeSetState(() {});
                                          },
                                        ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 14.0),

                                // Filtri rapidi azione
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: [
                                      _buildFilterPill(
                                        label: 'Tutti ($totalCount)',
                                        isSelected: _model.filtroTipo == 'Tutti',
                                        activeColor: purpleAccent,
                                        cardBg: innerInputBg,
                                        cardBorder: cardBorder,
                                        textPrimary: textPrimary,
                                        textSecondary: textSecondary,
                                        onTap: () => safeSetState(() => _model.filtroTipo = 'Tutti'),
                                      ),
                                      const SizedBox(width: 8.0),
                                      _buildFilterPill(
                                        label: '🗑️ Eliminazioni ($deleteCount)',
                                        isSelected: _model.filtroTipo == 'delete',
                                        activeColor: const Color(0xFFEF4444),
                                        cardBg: innerInputBg,
                                        cardBorder: cardBorder,
                                        textPrimary: textPrimary,
                                        textSecondary: textSecondary,
                                        onTap: () => safeSetState(() => _model.filtroTipo = 'delete'),
                                      ),
                                      const SizedBox(width: 8.0),
                                      _buildFilterPill(
                                        label: '✏️ Modifiche ($updateCount)',
                                        isSelected: _model.filtroTipo == 'update',
                                        activeColor: const Color(0xFFF59E0B),
                                        cardBg: innerInputBg,
                                        cardBorder: cardBorder,
                                        textPrimary: textPrimary,
                                        textSecondary: textSecondary,
                                        onTap: () => safeSetState(() => _model.filtroTipo = 'update'),
                                      ),
                                      const SizedBox(width: 8.0),
                                      _buildFilterPill(
                                        label: '➕ Creazioni ($createCount)',
                                        isSelected: _model.filtroTipo == 'create',
                                        activeColor: const Color(0xFF10B981),
                                        cardBg: innerInputBg,
                                        cardBorder: cardBorder,
                                        textPrimary: textPrimary,
                                        textSecondary: textSecondary,
                                        onTap: () => safeSetState(() => _model.filtroTipo = 'create'),
                                      ),
                                      if (restoreCount > 0) ...[
                                        const SizedBox(width: 8.0),
                                        _buildFilterPill(
                                          label: '🔄 Ripristini ($restoreCount)',
                                          isSelected: _model.filtroTipo == 'restore',
                                          activeColor: const Color(0xFF06B6D4),
                                          cardBg: innerInputBg,
                                          cardBorder: cardBorder,
                                          textPrimary: textPrimary,
                                          textSecondary: textSecondary,
                                          onTap: () => safeSetState(() => _model.filtroTipo = 'restore'),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),

                                // Filtro per Ristorante (se presente più di 1)
                                if (listaRistoranti.length > 2) ...[
                                  const SizedBox(height: 12.0),
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.storefront_rounded,
                                          size: 16.0,
                                          color: textSecondary,
                                        ),
                                        const SizedBox(width: 8.0),
                                        ...listaRistoranti.map((rist) {
                                          final isSel = _model.filtroRistorante == rist;
                                          return Padding(
                                            padding: const EdgeInsets.only(right: 6.0),
                                            child: InkWell(
                                              onTap: () {
                                                safeSetState(() {
                                                  _model.filtroRistorante = isSel ? 'Tutti' : rist;
                                                });
                                              },
                                              borderRadius: BorderRadius.circular(16.0),
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                                                decoration: BoxDecoration(
                                                  color: isSel
                                                      ? purpleAccent.withValues(alpha: 0.15)
                                                      : innerInputBg,
                                                  borderRadius: BorderRadius.circular(16.0),
                                                  border: Border.all(
                                                    color: isSel ? purpleAccent : cardBorder,
                                                    width: isSel ? 1.4 : 1.0,
                                                  ),
                                                ),
                                                child: Text(
                                                  rist,
                                                  style: TextStyle(
                                                    fontSize: 12.0,
                                                    fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                                                    color: isSel ? purpleAccent : textPrimary,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        }),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),

                          const SizedBox(height: 20.0),

                          // ── 4. FEED DEGLI EVENTI AUDIT ──────────────────────
                          if (allLogs.isEmpty)
                            _buildEmptyState(
                              cardBg: cardBg,
                              cardBorder: cardBorder,
                              textPrimary: textPrimary,
                              textSecondary: textSecondary,
                              icon: Icons.history_toggle_off_rounded,
                              title: 'Nessuna azione registrata finora',
                              description:
                                  'Non appena i ristoratori effettueranno eliminazioni o modifiche a categorie e piatti, troverai qui l\'elenco dettagliato degli eventi.',
                            )
                          else if (filteredList.isEmpty)
                            _buildEmptyState(
                              cardBg: cardBg,
                              cardBorder: cardBorder,
                              textPrimary: textPrimary,
                              textSecondary: textSecondary,
                              icon: Icons.search_off_rounded,
                              title: 'Nessuna azione trovata',
                              description:
                                  'Nessun evento corrisponde ai filtri impostati o alla ricerca corrente.',
                              showResetButton: true,
                            )
                          else
                            ListView.separated(
                              padding: const EdgeInsets.only(bottom: 28.0),
                              primary: false,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: filteredList.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 12.0),
                              itemBuilder: (context, index) {
                                final log = filteredList[index];
                                return _buildLogCard(
                                  log: log,
                                  cardBg: cardBg,
                                  cardBorder: cardBorder,
                                  innerInputBg: innerInputBg,
                                  textPrimary: textPrimary,
                                  textSecondary: textSecondary,
                                  purpleAccent: purpleAccent,
                                  isDark: isDark,
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
  Widget _buildAuditKpiCard({
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

  // ─── CARD LOG UNIFORME ───────────────────────────────────────────────────
  Widget _buildLogCard({
    required ActionLogsRecord log,
    required Color cardBg,
    required Color cardBorder,
    required Color innerInputBg,
    required Color textPrimary,
    required Color textSecondary,
    required Color purpleAccent,
    required bool isDark,
  }) {
    Color badgeColor;
    String badgeText;
    IconData badgeIcon;

    switch (log.tipoAzione) {
      case 'delete':
        badgeColor = const Color(0xFFEF4444);
        badgeText = 'ELIMINAZIONE';
        badgeIcon = Icons.delete_outline_rounded;
        break;
      case 'update':
        badgeColor = const Color(0xFFF59E0B);
        badgeText = 'MODIFICA';
        badgeIcon = Icons.edit_note_rounded;
        break;
      case 'create':
        badgeColor = const Color(0xFF10B981);
        badgeText = 'CREAZIONE';
        badgeIcon = Icons.add_circle_outline_rounded;
        break;
      case 'restore':
        badgeColor = const Color(0xFF06B6D4);
        badgeText = 'RIPRISTINO';
        badgeIcon = Icons.restore_rounded;
        break;
      default:
        badgeColor = const Color(0xFF6B7280);
        badgeText = 'AZIONE';
        badgeIcon = Icons.info_outline_rounded;
    }

    final dataAmichevole = _formatFriendlyTimestamp(log.dataOra);

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: log.tipoAzione == 'delete'
              ? const Color(0xFFEF4444).withValues(alpha: 0.3)
              : cardBorder,
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 10.0,
            offset: const Offset(0.0, 3.0),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header: Ristorante + Orario
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Badge Ristorante
              Flexible(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.5),
                  decoration: BoxDecoration(
                    color: purpleAccent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.storefront_rounded,
                        size: 15.0,
                        color: purpleAccent,
                      ),
                      const SizedBox(width: 6.0),
                      Flexible(
                        child: Text(
                          log.ristoranteNome.isNotEmpty
                              ? log.ristoranteNome
                              : 'Ristorante',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: purpleAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 12.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8.0),
              // Data e ora
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.access_time_rounded,
                    size: 14.0,
                    color: textSecondary,
                  ),
                  const SizedBox(width: 4.0),
                  Text(
                    dataAmichevole,
                    style: TextStyle(
                      color: textSecondary,
                      fontSize: 12.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 14.0),

          // 2. Info Utente Autore dell'Azione
          Row(
            children: [
              Container(
                width: 34.0,
                height: 34.0,
                decoration: BoxDecoration(
                  color: purpleAccent.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  log.utenteNome.isNotEmpty
                      ? log.utenteNome[0].toUpperCase()
                      : 'U',
                  style: TextStyle(
                    color: purpleAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 14.0,
                  ),
                ),
              ),
              const SizedBox(width: 10.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      log.utenteNome.isNotEmpty ? log.utenteNome : 'Utente',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13.5,
                        color: textPrimary,
                      ),
                    ),
                    if (log.utenteEmail.isNotEmpty)
                      Text(
                        log.utenteEmail,
                        style: TextStyle(
                          color: textSecondary,
                          fontSize: 11.5,
                        ),
                      ),
                  ],
                ),
              ),
              // Badge Tipo Azione (es. ELIMINAZIONE)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.5),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(
                    color: badgeColor.withValues(alpha: 0.30),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      badgeIcon,
                      size: 14.0,
                      color: badgeColor,
                    ),
                    const SizedBox(width: 4.0),
                    Text(
                      badgeText,
                      style: TextStyle(
                        color: badgeColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 10.5,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14.0),

          // 3. Box Dettagli Azione
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14.0),
            decoration: BoxDecoration(
              color: innerInputBg,
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(color: cardBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  log.azione.isNotEmpty ? log.azione : 'Azione eseguita',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13.0,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  log.dettagli.isNotEmpty
                      ? log.dettagli
                      : 'Nessun dettaglio aggiuntivo',
                  style: TextStyle(
                    fontSize: 13.5,
                    height: 1.4,
                    color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14.0),

          // 4. Footer con Protezione App + Tasto "Copia risposta gentile per il cliente"
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Badge Scagionamento / Tutela
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.verified_user_rounded,
                    size: 15.0,
                    color: Color(0xFF10B981),
                  ),
                  const SizedBox(width: 5.0),
                  Text(
                    'Tracciato con successo nei log',
                    style: TextStyle(
                      color: const Color(0xFF10B981).withValues(alpha: 0.9),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              // Bottone per copiare la risposta gentile
              TextButton.icon(
                onPressed: () {
                  final textToCopy =
                      'Ciao ${log.utenteNome.isNotEmpty ? log.utenteNome : "cliente"}, da un controllo nei nostri registri di sistema risulta che $dataAmichevole è stata eseguita l\'azione: "${log.dettagli}". L\'app ha eseguito correttamente l\'operazione richiesta. Se si è trattato di una svista o di un click involontario, puoi ricrearlo facilmente dal tuo pannello!';
                  Clipboard.setData(ClipboardData(text: textToCopy));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Row(
                        children: [
                          Icon(Icons.copy_rounded,
                              color: Colors.white, size: 18.0),
                          SizedBox(width: 8.0),
                          Expanded(
                            child: Text(
                              'Risposta gentile per il cliente copiata negli appunti!',
                              style: TextStyle(fontSize: 13.0),
                            ),
                          ),
                        ],
                      ),
                      backgroundColor: Color(0xFF10B981),
                      behavior: SnackBarBehavior.floating,
                      duration: Duration(seconds: 3),
                    ),
                  );
                },
                icon: Icon(
                  Icons.content_copy_rounded,
                  size: 14.0,
                  color: purpleAccent,
                ),
                label: Text(
                  'Copia risposta per cliente',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                    color: purpleAccent,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 4.0),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── STATO VUOTO UNIFORME ────────────────────────────────────────────────
  Widget _buildEmptyState({
    required Color cardBg,
    required Color cardBorder,
    required Color textPrimary,
    required Color textSecondary,
    required IconData icon,
    required String title,
    required String description,
    bool showResetButton = false,
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
              icon,
              size: 48.0,
              color: textSecondary.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 14.0),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17.0,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 6.0),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textSecondary,
                fontSize: 13.5,
              ),
            ),
            if (showResetButton) ...[
              const SizedBox(height: 16.0),
              OutlinedButton.icon(
                onPressed: () {
                  _model.searchController?.clear();
                  safeSetState(() {
                    _model.filtroTipo = 'Tutti';
                    _model.filtroRistorante = 'Tutti';
                  });
                },
                icon: const Icon(Icons.refresh_rounded, size: 16.0),
                label: const Text('Reimposta filtri e ricerca'),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

