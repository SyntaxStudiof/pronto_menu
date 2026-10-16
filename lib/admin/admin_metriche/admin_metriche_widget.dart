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
  const AdminMetricheWidget({super.key});

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

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
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
                  Icons.insights_rounded,
                  color: colorScheme.primary,
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
                      color: colorScheme.onSurface,
                    ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.refresh_rounded,
                color: colorScheme.primary,
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
                      SpinKitPulse(
                        color: colorScheme.primary,
                        size: 50.0,
                      ),
                      const SizedBox(height: 16.0),
                      Text(
                        'Calcolo metriche globali in corso...',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.hintColor,
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
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6.0),
                        Text(
                          '${snapshot.error}',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.hintColor,
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        ElevatedButton.icon(
                          onPressed: _caricaMetriche,
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Riprova'),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 24.0,
                  ),
                  child: Center(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 800.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Banner Introduzione
                          _buildIntroBanner(theme, colorScheme, metrics),
                          const SizedBox(height: 20.0),

                          // 3 CONTATORI GLOBALI CHIAVE
                          Text(
                            'Contatori Globali Piattaforma',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.5,
                            ),
                          ),
                          const SizedBox(height: 12.0),

                          LayoutBuilder(
                            builder: (context, constraints) {
                              final bool isNarrow = constraints.maxWidth < 600;
                              if (isNarrow) {
                                return Column(
                                  children: [
                                    _buildKpiCard(
                                      theme: theme,
                                      title: 'Ristoranti Attivi Oggi',
                                      value: '${metrics.ristorantiAttiviOggi}',
                                      badgeText: 'su ${metrics.ristorantiTotali} totali',
                                      icon: Icons.storefront_rounded,
                                      iconColor: const Color(0xFF10B981),
                                      accentColor: const Color(0xFF10B981),
                                      subtitle: 'Ristoranti con ordini o attività registrata oggi',
                                    ),
                                    const SizedBox(height: 12.0),
                                    _buildKpiCard(
                                      theme: theme,
                                      title: 'Utenti Registrati',
                                      value: '${metrics.utentiTotali}',
                                      badgeText: '${metrics.ristorantiPremium} Premium',
                                      icon: Icons.people_alt_rounded,
                                      iconColor: const Color(0xFF3B82F6),
                                      accentColor: const Color(0xFF3B82F6),
                                      subtitle: '${metrics.ordiniTotali} ordini clienti serviti in totale',
                                    ),
                                    const SizedBox(height: 12.0),
                                    _buildKpiCard(
                                      theme: theme,
                                      title: 'Foto & Storage Caricato',
                                      value: metrics.gigabyteFotoStimati >= 0.1
                                          ? '${metrics.gigabyteFotoStimati.toStringAsFixed(2)} GB'
                                          : '${metrics.megabyteFotoStimati.toStringAsFixed(0)} MB',
                                      badgeText: '${metrics.fotoTotali} foto menù',
                                      icon: Icons.cloud_upload_rounded,
                                      iconColor: const Color(0xFF8B5CF6),
                                      accentColor: const Color(0xFF8B5CF6),
                                      subtitle: '${metrics.percentualeStorageGratuito.toStringAsFixed(1)}% di 5 GB gratuiti Spark',
                                    ),
                                  ],
                                );
                              }

                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: _buildKpiCard(
                                      theme: theme,
                                      title: 'Ristoranti Attivi Oggi',
                                      value: '${metrics.ristorantiAttiviOggi}',
                                      badgeText: 'su ${metrics.ristorantiTotali} totali',
                                      icon: Icons.storefront_rounded,
                                      iconColor: const Color(0xFF10B981),
                                      accentColor: const Color(0xFF10B981),
                                      subtitle: 'Ristoranti con ordini o attività registrata oggi',
                                    ),
                                  ),
                                  const SizedBox(width: 12.0),
                                  Expanded(
                                    child: _buildKpiCard(
                                      theme: theme,
                                      title: 'Utenti Registrati',
                                      value: '${metrics.utentiTotali}',
                                      badgeText: '${metrics.ristorantiPremium} Premium',
                                      icon: Icons.people_alt_rounded,
                                      iconColor: const Color(0xFF3B82F6),
                                      accentColor: const Color(0xFF3B82F6),
                                      subtitle: '${metrics.ordiniTotali} ordini clienti serviti in totale',
                                    ),
                                  ),
                                  const SizedBox(width: 12.0),
                                  Expanded(
                                    child: _buildKpiCard(
                                      theme: theme,
                                      title: 'Foto & Storage',
                                      value: metrics.gigabyteFotoStimati >= 0.1
                                          ? '${metrics.gigabyteFotoStimati.toStringAsFixed(2)} GB'
                                          : '${metrics.megabyteFotoStimati.toStringAsFixed(0)} MB',
                                      badgeText: '${metrics.fotoTotali} foto',
                                      icon: Icons.cloud_upload_rounded,
                                      iconColor: const Color(0xFF8B5CF6),
                                      accentColor: const Color(0xFF8B5CF6),
                                      subtitle: '${metrics.percentualeStorageGratuito.toStringAsFixed(1)}% di 5 GB Spark',
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 24.0),

                          // MONITORAGGIO COSTI SERVER FIREBASE
                          _buildFirebaseCostCard(theme, colorScheme, metrics),
                          const SizedBox(height: 24.0),

                          // ATTIVITÀ ORDINI & FATTURATO GLOBALE
                          _buildBusinessActivityCard(theme, colorScheme, metrics),
                          const SizedBox(height: 28.0),

                          // DETTAGLIO RISTORANTI PIATTAFORMA
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Dettaglio Ristoranti Registrati',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.5,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10.0,
                                  vertical: 4.0,
                                ),
                                decoration: BoxDecoration(
                                  color: colorScheme.primary.withValues(alpha: 0.10),
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                child: Text(
                                  '${metrics.ristoranti.length} ristoranti',
                                  style: TextStyle(
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12.0),

                          if (metrics.ristoranti.isEmpty)
                            Container(
                              padding: const EdgeInsets.all(24.0),
                              decoration: BoxDecoration(
                                color: theme.cardColor,
                                borderRadius: BorderRadius.circular(16.0),
                                border: Border.all(
                                  color: theme.dividerColor.withValues(alpha: 0.12),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  'Nessun ristorante registrato sulla piattaforma',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.hintColor,
                                  ),
                                ),
                              ),
                            )
                          else
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: metrics.ristoranti.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 10.0),
                              itemBuilder: (context, index) {
                                final r = metrics.ristoranti[index];
                                return _buildRistoranteCard(theme, colorScheme, r);
                              },
                            ),
                          const SizedBox(height: 40.0),
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

  Widget _buildIntroBanner(
      ThemeData theme, ColorScheme colorScheme, BusinessMetrics metrics) {
    return Container(
      padding: const EdgeInsets.all(18.0),
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
            width: 48.0,
            height: 48.0,
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14.0),
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.analytics_rounded,
              color: colorScheme.primary,
              size: 26.0,
            ),
          ),
          const SizedBox(width: 14.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Panoramica Piattaforma & Costi',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.5,
                  ),
                ),
                const SizedBox(height: 2.0),
                Text(
                  'Monitora la crescita dell\'app e tieni sotto controllo l\'infrastruttura Firebase.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.hintColor,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiCard({
    required ThemeData theme,
    required String title,
    required String value,
    required String badgeText,
    required IconData icon,
    required Color iconColor,
    required Color accentColor,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16.0),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 40.0,
                height: 40.0,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                alignment: Alignment.center,
                child: Icon(icon, color: iconColor, size: 22.0),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(
                  badgeText,
                  style: TextStyle(
                    fontSize: 11.0,
                    fontWeight: FontWeight.bold,
                    color: accentColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14.0),
          Text(
            value,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 26.0,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.hintColor,
              fontSize: 11.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFirebaseCostCard(
      ThemeData theme, ColorScheme colorScheme, BusinessMetrics metrics) {
    final bool sottoControllo = metrics.percentualeStorageGratuito < 80.0;

    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(
          color: (sottoControllo ? Colors.green : Colors.orange)
              .withValues(alpha: 0.25),
          width: 1.2,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38.0,
                height: 38.0,
                decoration: BoxDecoration(
                  color: (sottoControllo ? Colors.green : Colors.orange)
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                alignment: Alignment.center,
                child: Icon(
                  sottoControllo
                      ? Icons.verified_rounded
                      : Icons.warning_amber_rounded,
                  color: sottoControllo ? Colors.green : Colors.orange,
                  size: 22.0,
                ),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Stato Costi Server Firebase',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                      ),
                    ),
                    Text(
                      sottoControllo
                          ? 'Operatività al 100% nel piano gratuito Spark (0,00 €/mese)'
                          : 'Prossimo al limite gratuito Spark',
                      style: TextStyle(
                        fontSize: 12.0,
                        fontWeight: FontWeight.w600,
                        color: sottoControllo
                            ? Colors.green.shade700
                            : Colors.orange.shade800,
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
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${metrics.gigabyteFotoStimati.toStringAsFixed(2)} GB / ${metrics.limiteStorageGb.toStringAsFixed(1)} GB',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
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
              backgroundColor: theme.dividerColor.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation<Color>(
                sottoControllo ? const Color(0xFF10B981) : Colors.orange,
              ),
            ),
          ),
          const SizedBox(height: 8.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${metrics.percentualeStorageGratuito.toStringAsFixed(1)}% utilizzato',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.hintColor,
                  fontSize: 11.5,
                ),
              ),
              Text(
                '${(metrics.limiteStorageGb - metrics.gigabyteFotoStimati).clamp(0.0, 5.0).toStringAsFixed(2)} GB rimanenti gratuiti',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.hintColor,
                  fontSize: 11.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16.0),

          // Note informative per l'admin
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 18.0,
                  color: theme.hintColor,
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: Text(
                    'Firebase Storage include 5 GB gratuiti. Oltre questa soglia, il costo di espansione è di appena ~0,026\$ per GB/mese. Firestore include inoltre 50.000 letture e 20.000 scritture al giorno a costo zero.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.hintColor,
                      fontSize: 11.5,
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

  Widget _buildBusinessActivityCard(
      ThemeData theme, ColorScheme colorScheme, BusinessMetrics metrics) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Attività Economica & Volume Ordini',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            'Volume generato dai clienti sui tavoli tramite l\'app',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.hintColor,
            ),
          ),
          const SizedBox(height: 16.0),
          Row(
            children: [
              Expanded(
                child: _buildMiniStat(
                  theme,
                  label: 'Ordini Oggi',
                  value: '${metrics.ordiniOggi}',
                  subvalue: formatNumber(
                    metrics.fatturatoOrdiniOggi,
                    formatType: FormatType.decimal,
                    decimalType: DecimalType.periodDecimal,
                    currency: '€',
                  ),
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: _buildMiniStat(
                  theme,
                  label: 'Ordini Totali',
                  value: '${metrics.ordiniTotali}',
                  subvalue: formatNumber(
                    metrics.fatturatoTotaleOrdini,
                    formatType: FormatType.decimal,
                    decimalType: DecimalType.periodDecimal,
                    currency: '€',
                  ),
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: _buildMiniStat(
                  theme,
                  label: 'Piatti a Menù',
                  value: '${metrics.piattiTotali}',
                  subvalue: '${metrics.fotoTotali} con foto',
                  color: const Color(0xFF8B5CF6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(
    ThemeData theme, {
    required String label,
    required String value,
    required String subvalue,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(14.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.hintColor,
              fontSize: 11.0,
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 18.0,
              color: color,
            ),
          ),
          const SizedBox(height: 2.0),
          Text(
            subvalue,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 11.0,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRistoranteCard(
      ThemeData theme, ColorScheme colorScheme, RistoranteMetricRow r) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: r.attivoOggi
              ? Colors.green.withValues(alpha: 0.35)
              : theme.dividerColor.withValues(alpha: 0.12),
          width: r.attivoOggi ? 1.4 : 1.0,
        ),
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
            padding: const EdgeInsets.all(14.0),
            child: Row(
              children: [
                // Logo o Avatar Ristorante
                Container(
                  width: 44.0,
                  height: 44.0,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12.0),
                    child: r.photoUrl.isNotEmpty
                        ? Image.network(
                            r.photoUrl,
                            width: 44.0,
                            height: 44.0,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Icon(
                              Icons.restaurant_rounded,
                              color: colorScheme.primary,
                              size: 22.0,
                            ),
                          )
                        : Icon(
                            Icons.restaurant_rounded,
                            color: colorScheme.primary,
                            size: 22.0,
                          ),
                  ),
                ),
                const SizedBox(width: 14.0),

                // Info Ristorante
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              r.nome,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (r.attivoOggi) ...[
                            const SizedBox(width: 6.0),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6.0, vertical: 2.0),
                              decoration: BoxDecoration(
                                color: Colors.green.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6.0),
                              ),
                              child: Text(
                                'ATTIVO OGGI',
                                style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade700,
                                ),
                              ),
                            ),
                          ],
                          if (r.isPremium) ...[
                            const SizedBox(width: 4.0),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6.0, vertical: 2.0),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF59E0B)
                                    .withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6.0),
                              ),
                              child: const Text(
                                'PRO',
                                style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFD97706),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2.0),
                      Text(
                        r.email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.hintColor,
                          fontSize: 11.5,
                        ),
                      ),
                      const SizedBox(height: 6.0),
                      Row(
                        children: [
                          _buildPillTag(
                            theme,
                            icon: Icons.receipt_long_rounded,
                            text: '${r.ordiniOggi} ordini oggi (${r.ordiniTotali} tot)',
                            color: r.ordiniOggi > 0
                                ? Colors.green
                                : theme.hintColor,
                          ),
                          const SizedBox(width: 8.0),
                          _buildPillTag(
                            theme,
                            icon: Icons.restaurant_menu_rounded,
                            text: '${r.piattiTotali} piatti',
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 8.0),
                          _buildPillTag(
                            theme,
                            icon: Icons.photo_library_rounded,
                            text: '${r.fotoCaricate} foto',
                            color: const Color(0xFF8B5CF6),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6.0),
                Icon(
                  Icons.chevron_right_rounded,
                  color: theme.hintColor,
                  size: 22.0,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPillTag(
    ThemeData theme, {
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12.0, color: color),
        const SizedBox(width: 3.0),
        Text(
          text,
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w500,
            color: theme.textTheme.bodySmall?.color ?? theme.hintColor,
          ),
        ),
      ],
    );
  }
}
