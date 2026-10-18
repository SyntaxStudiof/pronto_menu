import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import '/services/business_metrics_service.dart';
import 'admin_metriche_model.dart';
export 'admin_metriche_model.dart';

class AdminMetricheWidget extends StatefulWidget {
  const AdminMetricheWidget({
    super.key,
    this.embedded = false,
  });

  final bool embedded;

  static String routeName = 'AdminMetriche';
  static String routePath = '/adminMetriche';

  @override
  State<AdminMetricheWidget> createState() => _AdminMetricheWidgetState();
}

class _AdminMetricheWidgetState extends State<AdminMetricheWidget> {
  late AdminMetricheModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  Future<BusinessMetrics>? _metricsFuture;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AdminMetricheModel());
    _caricaMetriche();
  }

  void _caricaMetriche() {
    setState(() {
      _metricsFuture = BusinessMetricsService.calcolaMetriche();
    });
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
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final bgCanvas = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final cardBorder = isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0);
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
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
                backgroundColor: bgCanvas,
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
                        Icons.insights_rounded,
                        color: purpleAccent,
                        size: 20.0,
                      ),
                    ),
                    const SizedBox(width: 10.0),
                    Text(
                      'Metriche Business',
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
                actions: [
                  IconButton(
                    icon: const Icon(
                      Icons.refresh_rounded,
                      color: purpleAccent,
                      size: 22.0,
                    ),
                    tooltip: 'Aggiorna metriche',
                    onPressed: _caricaMetriche,
                  ),
                ],
              ),
        body: SafeArea(
          top: true,
          child: FutureBuilder<BusinessMetrics>(
            future: _metricsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SpinKitPulse(
                        color: purpleAccent,
                        size: 50.0,
                      ),
                      const SizedBox(height: 16.0),
                      Text(
                        'Calcolo metriche globali in corso...',
                        style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w500,
                          color: textSecondary,
                        ),
                      ),
                    ],
                  ),
                );
              }

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
                          color: colorScheme.error,
                        ),
                        const SizedBox(height: 12.0),
                        Text(
                          'Errore nel caricamento delle metriche',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6.0),
                        Text(
                          '${snapshot.error}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12.5,
                            color: textSecondary,
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        ElevatedButton.icon(
                          onPressed: _caricaMetriche,
                          icon: const Icon(Icons.refresh_rounded, size: 16.0),
                          label: const Text('Riprova'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: purpleAccent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final metrics = snapshot.data!;

              return RefreshIndicator(
                onRefresh: () async {
                  _caricaMetriche();
                  await _metricsFuture;
                },
                child: SingleChildScrollView(
                  controller: _model.scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(28.0, 24.0, 28.0, 40.0),
                  child: Center(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 1400.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // ── 1. BANNER INTRODUTTIVO ─────────────────────────
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
                                    color: purpleAccent.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  alignment: Alignment.center,
                                  child: const Icon(
                                    Icons.analytics_rounded,
                                    color: purpleAccent,
                                    size: 24.0,
                                  ),
                                ),
                                const SizedBox(width: 14.0),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Panoramica Metriche Business & Risorse Server',
                                        style: TextStyle(
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: -0.2,
                                          color: textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 2.0),
                                      Text(
                                        'Monitoraggio in tempo reale su clienti, comande, spazio foto Storage e utilizzo gratuito Spark',
                                        style: TextStyle(
                                          fontSize: 12.5,
                                          color: textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                OutlinedButton.icon(
                                  onPressed: _caricaMetriche,
                                  icon: const Icon(Icons.refresh_rounded, size: 16.0),
                                  label: const Text('Aggiorna'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                                    side: BorderSide(
                                      color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
                                    ),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                                    padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20.0),

                          // ── 2. CARDS KPI IN STILE UNIFORME ─────────────────
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final isWide = constraints.maxWidth >= 960;
                              if (isWide) {
                                return Row(
                                  children: [
                                    Expanded(
                                      child: _buildMetricKpiCard(
                                        title: 'Ristoranti Attivi Oggi',
                                        value: '${metrics.ristorantiAttiviOggi}',
                                        subtitle: 'su ${metrics.ristorantiTotali} totali',
                                        icon: Icons.storefront_rounded,
                                        accentColor: const Color(0xFF10B981),
                                        cardBg: cardBg,
                                        cardBorder: cardBorder,
                                        textPrimary: textPrimary,
                                        textSecondary: textSecondary,
                                        isDark: isDark,
                                      ),
                                    ),
                                    const SizedBox(width: 16.0),
                                    Expanded(
                                      child: _buildMetricKpiCard(
                                        title: 'Utenti Registrati',
                                        value: '${metrics.utentiTotali}',
                                        subtitle: '${metrics.ristorantiPremium} Premium',
                                        icon: Icons.people_alt_rounded,
                                        accentColor: const Color(0xFF3B82F6),
                                        cardBg: cardBg,
                                        cardBorder: cardBorder,
                                        textPrimary: textPrimary,
                                        textSecondary: textSecondary,
                                        isDark: isDark,
                                      ),
                                    ),
                                    const SizedBox(width: 16.0),
                                    Expanded(
                                      child: _buildMetricKpiCard(
                                        title: 'Volume Ordini Totali',
                                        value: '${metrics.ordiniTotali}',
                                        subtitle: 'Oggi: ${metrics.ordiniOggi} ordini',
                                        icon: Icons.receipt_long_rounded,
                                        accentColor: const Color(0xFFF59E0B),
                                        cardBg: cardBg,
                                        cardBorder: cardBorder,
                                        textPrimary: textPrimary,
                                        textSecondary: textSecondary,
                                        isDark: isDark,
                                      ),
                                    ),
                                    const SizedBox(width: 16.0),
                                    Expanded(
                                      child: _buildMetricKpiCard(
                                        title: 'Spazio Foto Storage',
                                        value: metrics.gigabyteFotoStimati >= 0.1
                                            ? '${metrics.gigabyteFotoStimati.toStringAsFixed(2)} GB'
                                            : '${metrics.megabyteFotoStimati.toStringAsFixed(0)} MB',
                                        subtitle: '${metrics.percentualeStorageGratuito.toStringAsFixed(1)}% di 5 GB Spark',
                                        icon: Icons.cloud_upload_rounded,
                                        accentColor: purpleAccent,
                                        cardBg: cardBg,
                                        cardBorder: cardBorder,
                                        textPrimary: textPrimary,
                                        textSecondary: textSecondary,
                                        isDark: isDark,
                                      ),
                                    ),
                                  ],
                                );
                              }

                              return Wrap(
                                spacing: 12.0,
                                runSpacing: 12.0,
                                children: [
                                  SizedBox(
                                    width: (constraints.maxWidth - 12.0) / 2,
                                    child: _buildMetricKpiCard(
                                      title: 'Ristoranti Attivi Oggi',
                                      value: '${metrics.ristorantiAttiviOggi}',
                                      subtitle: 'su ${metrics.ristorantiTotali} totali',
                                      icon: Icons.storefront_rounded,
                                      accentColor: const Color(0xFF10B981),
                                      cardBg: cardBg,
                                      cardBorder: cardBorder,
                                      textPrimary: textPrimary,
                                      textSecondary: textSecondary,
                                      isDark: isDark,
                                    ),
                                  ),
                                  SizedBox(
                                    width: (constraints.maxWidth - 12.0) / 2,
                                    child: _buildMetricKpiCard(
                                      title: 'Utenti Registrati',
                                      value: '${metrics.utentiTotali}',
                                      subtitle: '${metrics.ristorantiPremium} Premium',
                                      icon: Icons.people_alt_rounded,
                                      accentColor: const Color(0xFF3B82F6),
                                      cardBg: cardBg,
                                      cardBorder: cardBorder,
                                      textPrimary: textPrimary,
                                      textSecondary: textSecondary,
                                      isDark: isDark,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),

                          const SizedBox(height: 20.0),

                          // ── 3. CARD STATO SERVER FIREBASE & SPARK TIER ─────
                          _buildFirebaseCostCard(
                            theme: theme,
                            metrics: metrics,
                            cardBg: cardBg,
                            cardBorder: cardBorder,
                            textPrimary: textPrimary,
                            textSecondary: textSecondary,
                            isDark: isDark,
                          ),

                          const SizedBox(height: 20.0),

                          // ── 4. CARD ATTIVITÀ ECONOMICA GLOBALE ─────────────
                          _buildBusinessActivityCard(
                            theme: theme,
                            metrics: metrics,
                            cardBg: cardBg,
                            cardBorder: cardBorder,
                            textPrimary: textPrimary,
                            textSecondary: textSecondary,
                            isDark: isDark,
                          ),

                          const SizedBox(height: 24.0),

                          // ── 5. ELENCO RISTORANTI & DETTAGLI ATTIVITÀ ────────
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Dettaglio Attività per Locale',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                  color: textPrimary,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                                decoration: BoxDecoration(
                                  color: purpleAccent.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: Text(
                                  '${metrics.ristoranti.length} ristoranti',
                                  style: const TextStyle(
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.bold,
                                    color: purpleAccent,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 14.0),

                          if (metrics.ristoranti.isEmpty)
                            Container(
                              padding: const EdgeInsets.all(24.0),
                              decoration: BoxDecoration(
                                color: cardBg,
                                borderRadius: BorderRadius.circular(16.0),
                                border: Border.all(color: cardBorder),
                              ),
                              child: Center(
                                child: Text(
                                  'Nessun ristorante registrato sulla piattaforma',
                                  style: TextStyle(
                                    color: textSecondary,
                                    fontSize: 14.0,
                                  ),
                                ),
                              ),
                            )
                          else
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: metrics.ristoranti.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 12.0),
                              itemBuilder: (context, index) {
                                final r = metrics.ristoranti[index];
                                return _buildRistoranteCard(
                                  theme: theme,
                                  r: r,
                                  cardBg: cardBg,
                                  cardBorder: cardBorder,
                                  textPrimary: textPrimary,
                                  textSecondary: textSecondary,
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

  // ─── KPI CARD UNIFORME CON SCREENSHOT ─────────────────────────────────────
  Widget _buildMetricKpiCard({
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
  }) {
    return Container(
      padding: const EdgeInsets.all(18.0),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
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
                    color: textSecondary,
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 22.0,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    color: textPrimary,
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
              color: accentColor,
              size: 22.0,
            ),
          ),
        ],
      ),
    );
  }

  // ─── CARD COSTI FIREBASE SPARK ────────────────────────────────────────────
  Widget _buildFirebaseCostCard({
    required ThemeData theme,
    required BusinessMetrics metrics,
    required Color cardBg,
    required Color cardBorder,
    required Color textPrimary,
    required Color textSecondary,
    required bool isDark,
  }) {
    final bool sottoControllo = metrics.percentualeStorageGratuito < 80.0;
    final statusColor = sottoControllo ? const Color(0xFF10B981) : const Color(0xFFF59E0B);

    return Container(
      padding: const EdgeInsets.all(20.0),
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
          Row(
            children: [
              Container(
                width: 42.0,
                height: 42.0,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                alignment: Alignment.center,
                child: Icon(
                  sottoControllo ? Icons.verified_rounded : Icons.warning_amber_rounded,
                  color: statusColor,
                  size: 22.0,
                ),
              ),
              const SizedBox(width: 14.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Stato Costi Server Firebase',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2.0),
                    Text(
                      sottoControllo
                          ? 'Operatività al 100% nel piano gratuito Spark (0,00 €/mese)'
                          : 'Prossimo al limite gratuito Spark di 5 GB',
                      style: TextStyle(
                        fontSize: 12.0,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18.0),

          // Barra di utilizzo dello Storage
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Spazio Foto Firebase Storage',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: textPrimary,
                ),
              ),
              Text(
                '${metrics.gigabyteFotoStimati.toStringAsFixed(2)} GB / ${metrics.limiteStorageGb.toStringAsFixed(1)} GB',
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF7C3AED),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: LinearProgressIndicator(
              value: (metrics.percentualeStorageGratuito / 100.0).clamp(0.01, 1.0),
              minHeight: 10.0,
              backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0),
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
            ),
          ),
          const SizedBox(height: 8.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${metrics.percentualeStorageGratuito.toStringAsFixed(1)}% utilizzato',
                style: TextStyle(
                  fontSize: 11.5,
                  color: textSecondary,
                ),
              ),
              Text(
                '${(metrics.limiteStorageGb - metrics.gigabyteFotoStimati).clamp(0.0, 5.0).toStringAsFixed(2)} GB rimanenti gratuiti',
                style: TextStyle(
                  fontSize: 11.5,
                  color: textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16.0),

          // Note informative per l'admin
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10.0),
              border: Border.all(
                color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFE2E8F0),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 18.0,
                  color: textSecondary,
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: Text(
                    'Firebase Storage include 5 GB gratuiti. Oltre questa soglia, il costo di espansione è di appena ~0,026\$ per GB/mese. Firestore include inoltre 50.000 letture e 20.000 scritture al giorno a costo zero.',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: textSecondary,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── CARD ATTIVITÀ ECONOMICA ──────────────────────────────────────────────
  Widget _buildBusinessActivityCard({
    required ThemeData theme,
    required BusinessMetrics metrics,
    required Color cardBg,
    required Color cardBorder,
    required Color textPrimary,
    required Color textSecondary,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(20.0),
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
          Text(
            'Attività Economica & Volume Ordini',
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            'Volume generato dai clienti sui tavoli tramite l\'app',
            style: TextStyle(
              fontSize: 12.5,
              color: textSecondary,
            ),
          ),
          const SizedBox(height: 16.0),
          Row(
            children: [
              Expanded(
                child: _buildMiniStat(
                  label: 'Ordini Oggi',
                  value: '${metrics.ordiniOggi}',
                  subvalue: formatNumber(
                    metrics.fatturatoOrdiniOggi,
                    formatType: FormatType.decimal,
                    decimalType: DecimalType.periodDecimal,
                    currency: '€',
                  ),
                  color: const Color(0xFF10B981),
                  isDark: isDark,
                  textSecondary: textSecondary,
                ),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: _buildMiniStat(
                  label: 'Ordini Totali',
                  value: '${metrics.ordiniTotali}',
                  subvalue: formatNumber(
                    metrics.fatturatoTotaleOrdini,
                    formatType: FormatType.decimal,
                    decimalType: DecimalType.periodDecimal,
                    currency: '€',
                  ),
                  color: const Color(0xFF7C3AED),
                  isDark: isDark,
                  textSecondary: textSecondary,
                ),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: _buildMiniStat(
                  label: 'Piatti a Menù',
                  value: '${metrics.piattiTotali}',
                  subvalue: '${metrics.fotoTotali} con foto',
                  color: const Color(0xFF3B82F6),
                  isDark: isDark,
                  textSecondary: textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat({
    required String label,
    required String value,
    required String subvalue,
    required Color color,
    required bool isDark,
    required Color textSecondary,
  }) {
    return Container(
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: textSecondary,
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            value,
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2.0),
          Text(
            subvalue,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ─── CARD RISTORANTE NELLA LISTA DETTAGLIO METRICHE ───────────────────────
  Widget _buildRistoranteCard({
    required ThemeData theme,
    required RistoranteMetricRow r,
    required Color cardBg,
    required Color cardBorder,
    required Color textPrimary,
    required Color textSecondary,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: r.attivoOggi
              ? const Color(0xFF10B981).withValues(alpha: 0.40)
              : cardBorder,
          width: r.attivoOggi ? 1.4 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.02),
            blurRadius: 8.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16.0),
        child: InkWell(
          borderRadius: BorderRadius.circular(16.0),
          onTap: () {
            context.pushNamed(
              AdminDettaglioRistoranteWidget.routeName,
              queryParameters: {
                'utenteRef': serializeParam(
                  r.reference,
                  ParamType.DocumentReference,
                ),
              }.withoutNulls,
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Avatar Ristorante
                Container(
                  width: 46.0,
                  height: 46.0,
                  decoration: BoxDecoration(
                    color: const Color(0xFF7C3AED).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(
                      color: const Color(0xFF7C3AED).withValues(alpha: 0.25),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(11.0),
                    child: r.photoUrl.isNotEmpty
                        ? Image.network(
                            r.photoUrl,
                            width: 46.0,
                            height: 46.0,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.restaurant_rounded,
                              color: Color(0xFF7C3AED),
                              size: 22.0,
                            ),
                          )
                        : const Icon(
                            Icons.restaurant_rounded,
                            color: Color(0xFF7C3AED),
                            size: 22.0,
                          ),
                  ),
                ),
                const SizedBox(width: 14.0),

                // Info Principali
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              r.nome.isNotEmpty ? r.nome : 'Ristorante senza nome',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 15.0,
                                fontWeight: FontWeight.bold,
                                color: textPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8.0),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.5),
                            decoration: BoxDecoration(
                              color: r.attivoOggi
                                  ? const Color(0xFF10B981).withValues(alpha: 0.12)
                                  : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                              borderRadius: BorderRadius.circular(6.0),
                              border: Border.all(
                                color: r.attivoOggi
                                    ? const Color(0xFF10B981).withValues(alpha: 0.3)
                                    : Colors.transparent,
                              ),
                            ),
                            child: Text(
                              r.attivoOggi ? 'ATTIVO OGGI' : 'INATTIVO OGGI',
                              style: TextStyle(
                                fontSize: 10.0,
                                fontWeight: FontWeight.bold,
                                color: r.attivoOggi
                                    ? const Color(0xFF10B981)
                                    : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3.0),
                      Text(
                        r.email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.0,
                          color: textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12.0),

                // Badge Statistiche Rapide
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildPillStat(
                      icon: Icons.receipt_rounded,
                      text: '${r.ordiniOggi} oggi',
                      color: const Color(0xFF10B981),
                      isDark: isDark,
                    ),
                    const SizedBox(width: 8.0),
                    _buildPillStat(
                      icon: Icons.inventory_2_rounded,
                      text: '${r.ordiniTotali} tot',
                      color: const Color(0xFF7C3AED),
                      isDark: isDark,
                    ),
                    const SizedBox(width: 8.0),
                    _buildPillStat(
                      icon: Icons.restaurant_menu_rounded,
                      text: '${r.piattiTotali} piatti',
                      color: const Color(0xFF3B82F6),
                      isDark: isDark,
                    ),
                    const SizedBox(width: 8.0),
                    _buildPillStat(
                      icon: Icons.photo_library_rounded,
                      text: '${r.fotoCaricate} foto',
                      color: const Color(0xFFF59E0B),
                      isDark: isDark,
                    ),
                  ],
                ),

                const SizedBox(width: 12.0),
                Icon(
                  Icons.chevron_right_rounded,
                  color: textSecondary,
                  size: 22.0,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPillStat({
    required IconData icon,
    required String text,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: color.withValues(alpha: 0.20),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.0, color: color),
          const SizedBox(width: 5.0),
          Text(
            text,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }
}
