import '/backend/backend.dart';
import '/components/nav_bar_dinamica_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'dashboard_ristorante_model.dart';
export 'dashboard_ristorante_model.dart';

/// Pagina in cui la cucina vede arrivare gli ordini
class DashboardRistoranteWidget extends StatefulWidget {
  const DashboardRistoranteWidget({
    super.key,
    required this.ristoranteRef,
  });

  final DocumentReference? restauranteRef = null;
  final DocumentReference? ristoranteRef;

  static String routeName = 'DashboardRistorante';
  static String routePath = '/dashboardRistorante';

  @override
  State<DashboardRistoranteWidget> createState() =>
      _DashboardRistoranteWidgetState();
}

class _DashboardRistoranteWidgetState extends State<DashboardRistoranteWidget> {
  late DashboardRistoranteModel _model;
  String _selectedPhase = 'in_attesa'; // 'in_attesa' o 'in_preparazione'

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DashboardRistoranteModel());

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

    final mobileUI = GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: theme.scaffoldBackgroundColor,
        floatingActionButton: Align(
          alignment: const AlignmentDirectional(1.0, 1.0),
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 24.0, 85.0),
            child: FloatingActionButton.extended(
              onPressed: () async {
                final isPrep = _selectedPhase == 'in_preparazione';
                final confirmDialogResponse = await showDialog<bool>(
                      context: context,
                      builder: (alertDialogContext) {
                        return AlertDialog(
                          backgroundColor: theme.cardColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          title: Text(
                            isPrep ? 'Completa tutti gli ordini' : 'Inizia preparazione per tutti',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0,
                            ),
                          ),
                          content: Text(
                            isPrep
                                ? 'Sei sicuro di voler completare tutte le comande in preparazione?'
                                : 'Vuoi spostare tutte le comande in attesa su "In Preparazione"?',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.textTheme.bodySmall?.color,
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () =>
                                  Navigator.pop(alertDialogContext, false),
                              child: Text(
                                'Annulla',
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: theme.textTheme.bodySmall?.color,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isPrep ? const Color(0xFF10B981) : const Color(0xFF3B82F6),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                              onPressed: () =>
                                  Navigator.pop(alertDialogContext, true),
                              child: Text(
                                isPrep ? 'Completa tutti' : 'Inizia tutti',
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ) ??
                    false;
                if (confirmDialogResponse) {
                  final targetStatus = isPrep ? 'Completato' : 'in_preparazione';
                  final sourceStatus = _selectedPhase;
                  final ordini = await queryOrdersRecordOnce(
                    queryBuilder: (ordersRecord) => ordersRecord.where(
                      'stato_ordine',
                      isEqualTo: sourceStatus,
                    ),
                  );
                  for (var ord in ordini) {
                    await ord.reference.update(createOrdersRecordData(
                      statoOrdine: targetStatus,
                      visto: isPrep ? false : ord.visto,
                    ));
                  }
                  safeSetState(() {});
                }
              },
              backgroundColor: _selectedPhase == 'in_preparazione' ? const Color(0xFF10B981) : const Color(0xFF3B82F6),
              foregroundColor: Colors.white,
              elevation: 4.0,
              icon: Icon(
                _selectedPhase == 'in_preparazione' ? Icons.done_all_rounded : Icons.soup_kitchen_rounded,
                color: Colors.white,
                size: 20.0,
              ),
              label: Text(
                _selectedPhase == 'in_preparazione' ? 'Completa tutti' : 'Inizia tutti',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14.0,
                ),
              ),
            ),
          ),
        ),
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(68.0),
          child: Container(
            decoration: BoxDecoration(
              color: theme.appBarTheme.backgroundColor ?? theme.cardColor,
              border: Border(
                bottom: BorderSide(
                  color: theme.dividerColor.withValues(alpha: 0.5),
                  width: 1.0,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 4.0,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 960.0),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Pronto',
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 22.0,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'Menu',
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      color: theme.colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 22.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12.0),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                                vertical: 3.0,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6.0),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.restaurant_rounded,
                                    color: theme.colorScheme.primary,
                                    size: 14.0,
                                  ),
                                  const SizedBox(width: 4.0),
                                  Text(
                                    'Cucina',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: theme.colorScheme.primary,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 11.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        StreamBuilder<List<OrdersRecord>>(
                          stream: queryOrdersRecord(
                            queryBuilder: (ordersRecord) => ordersRecord.where(
                              'stato_ordine',
                              isEqualTo: _selectedPhase,
                            ),
                          ),
                          builder: (context, snapshot) {
                            final count =
                                snapshot.hasData ? snapshot.data!.length : 0;
                            final isPrep = _selectedPhase == 'in_preparazione';
                            final mainColor = isPrep ? const Color(0xFF3B82F6) : const Color(0xFFF59E0B);
                            final textColor = isPrep ? const Color(0xFF2563EB) : const Color(0xFFD97706);
                            final label = isPrep ? 'in prep.' : 'in attesa';

                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12.0, vertical: 6.0),
                              decoration: BoxDecoration(
                                color: (count > 0
                                        ? mainColor
                                        : theme.hintColor)
                                    .withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(20.0),
                                border: Border.all(
                                  color: (count > 0
                                          ? mainColor
                                          : theme.dividerColor)
                                      .withValues(alpha: 0.35),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 8.0,
                                    height: 8.0,
                                    decoration: BoxDecoration(
                                      color: count > 0
                                          ? mainColor
                                          : theme.hintColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8.0),
                                  Text(
                                    '$count $label',
                                    style: theme.textTheme.labelMedium?.copyWith(
                                      color: count > 0
                                          ? textColor
                                          : theme.hintColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13.0,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        body: SafeArea(
          top: true,
          child: Stack(
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 860.0),
                  child: SingleChildScrollView(
                    controller: _model.columnController,
                    padding: const EdgeInsets.fromLTRB(20.0, 24.0, 20.0, 110.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Overview Card
                        Container(
                          padding: const EdgeInsets.all(20.0),
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            borderRadius: BorderRadius.circular(16.0),
                            border: Border.all(
                              color: theme.dividerColor.withValues(alpha: 0.5),
                              width: 1.0,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
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
                                  children: [
                                    Text(
                                      'Ordini in Cucina',
                                      style: theme.textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: -0.3,
                                      ),
                                    ),
                                    const SizedBox(height: 6.0),
                                    Text(
                                      'Gestisci e prepara le comande inviate dai clienti in tempo reale',
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: theme.textTheme.bodySmall?.color,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 44.0,
                                height: 44.0,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary
                                      .withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                child: Icon(
                                  Icons.restaurant_rounded,
                                  color: theme.colorScheme.primary,
                                  size: 22.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Segmented Switch per le due fasi della cucina: In Attesa & In Preparazione
                        Container(
                          padding: const EdgeInsets.all(4.0),
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            borderRadius: BorderRadius.circular(14.0),
                            border: Border.all(
                              color: theme.dividerColor.withValues(alpha: 0.5),
                              width: 1.0,
                            ),
                          ),
                          child: StreamBuilder<List<OrdersRecord>>(
                            stream: queryOrdersRecord(
                              queryBuilder: (q) => q.orderBy('data_creazione'),
                            ),
                            builder: (context, allOrdersSnapshot) {
                              final allOrders = allOrdersSnapshot.data ?? [];
                              final countAttesa = allOrders.where((o) => o.statoOrdine.toLowerCase() == 'in_attesa').length;
                              final countPrep = allOrders.where((o) => o.statoOrdine.toLowerCase() == 'in_preparazione').length;

                              return Row(
                                children: [
                                  // Tab In Attesa
                                  Expanded(
                                    child: InkWell(
                                      onTap: () => setState(() => _selectedPhase = 'in_attesa'),
                                      borderRadius: BorderRadius.circular(10.0),
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 200),
                                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                                        decoration: BoxDecoration(
                                          color: _selectedPhase == 'in_attesa'
                                              ? const Color(0xFFF59E0B).withValues(alpha: 0.15)
                                              : Colors.transparent,
                                          borderRadius: BorderRadius.circular(10.0),
                                          border: Border.all(
                                            color: _selectedPhase == 'in_attesa'
                                                ? const Color(0xFFF59E0B)
                                                : Colors.transparent,
                                            width: 1.2,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.hourglass_top_rounded,
                                              size: 16.0,
                                              color: _selectedPhase == 'in_attesa'
                                                  ? const Color(0xFFD97706)
                                                  : theme.textTheme.bodyMedium?.color,
                                            ),
                                            const SizedBox(width: 6.0),
                                            Text(
                                              'In Attesa ($countAttesa)',
                                              style: TextStyle(
                                                fontSize: 13.0,
                                                fontWeight: _selectedPhase == 'in_attesa'
                                                    ? FontWeight.bold
                                                    : FontWeight.w500,
                                                color: _selectedPhase == 'in_attesa'
                                                    ? const Color(0xFFD97706)
                                                    : theme.textTheme.bodyMedium?.color,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6.0),
                                  // Tab In Preparazione
                                  Expanded(
                                    child: InkWell(
                                      onTap: () => setState(() => _selectedPhase = 'in_preparazione'),
                                      borderRadius: BorderRadius.circular(10.0),
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 200),
                                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                                        decoration: BoxDecoration(
                                          color: _selectedPhase == 'in_preparazione'
                                              ? const Color(0xFF3B82F6).withValues(alpha: 0.15)
                                              : Colors.transparent,
                                          borderRadius: BorderRadius.circular(10.0),
                                          border: Border.all(
                                            color: _selectedPhase == 'in_preparazione'
                                                ? const Color(0xFF3B82F6)
                                                : Colors.transparent,
                                            width: 1.2,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.soup_kitchen_rounded,
                                              size: 16.0,
                                              color: _selectedPhase == 'in_preparazione'
                                                  ? const Color(0xFF2563EB)
                                                  : theme.textTheme.bodyMedium?.color,
                                            ),
                                            const SizedBox(width: 6.0),
                                            Text(
                                              'In Prep. ($countPrep)',
                                              style: TextStyle(
                                                fontSize: 13.0,
                                                fontWeight: _selectedPhase == 'in_preparazione'
                                                    ? FontWeight.bold
                                                    : FontWeight.w500,
                                                color: _selectedPhase == 'in_preparazione'
                                                    ? const Color(0xFF2563EB)
                                                    : theme.textTheme.bodyMedium?.color,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 18.0),

                        // Orders StreamBuilder
                        StreamBuilder<List<OrdersRecord>>(
                          stream: queryOrdersRecord(
                            queryBuilder: (ordersRecord) => ordersRecord
                                .where(
                                  'stato_ordine',
                                  isEqualTo: _selectedPhase,
                                )
                                .orderBy('data_creazione'),
                          ),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return Center(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 80.0),
                                  child: SizedBox(
                                    width: 40.0,
                                    height: 40.0,
                                    child: SpinKitPulse(
                                      color: theme.colorScheme.primary,
                                      size: 40.0,
                                    ),
                                  ),
                                ),
                              );
                            }
                            List<OrdersRecord> listViewOrdersRecordList =
                                snapshot.data!;

                            if (listViewOrdersRecordList.isEmpty) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 48.0,
                                  horizontal: 24.0,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.cardColor,
                                  borderRadius: BorderRadius.circular(16.0),
                                  border: Border.all(
                                    color: theme.dividerColor.withValues(alpha: 0.5),
                                    width: 1.0,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Container(
                                      width: 60.0,
                                      height: 60.0,
                                      decoration: BoxDecoration(
                                        color: theme.dividerColor
                                            .withValues(alpha: 0.15),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.outdoor_grill_outlined,
                                        color: theme.hintColor,
                                        size: 30.0,
                                      ),
                                    ),
                                    const SizedBox(height: 14.0),
                                    Text(
                                      _selectedPhase == 'in_attesa'
                                          ? 'Nessun ordine in attesa'
                                          : 'Nessun ordine in preparazione',
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 6.0),
                                    Text(
                                      _selectedPhase == 'in_attesa'
                                          ? 'I nuovi ordini inviati dai tavoli appariranno qui in tempo reale.'
                                          : 'Sposta gli ordini dalla fase "In attesa" quando inizi a prepararli.',
                                      textAlign: TextAlign.center,
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: theme.hintColor,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 12.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.format_list_bulleted_rounded,
                                            color: theme.colorScheme.primary,
                                            size: 20.0,
                                          ),
                                          const SizedBox(width: 8.0),
                                          Text(
                                            'Comande attive',
                                            style: theme.textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18.0,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10.0,
                                          vertical: 4.0,
                                        ),
                                        decoration: BoxDecoration(
                                          color: theme.dividerColor
                                              .withValues(alpha: 0.15),
                                          borderRadius:
                                              BorderRadius.circular(12.0),
                                        ),
                                        child: Text(
                                          '${listViewOrdersRecordList.length} ${listViewOrdersRecordList.length == 1 ? 'comanda' : 'comande'}',
                                          style: theme.textTheme.labelSmall?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12.5,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                ListView.separated(
                                  padding: EdgeInsets.zero,
                                  shrinkWrap: true,
                                  physics:
                                      const NeverScrollableScrollPhysics(),
                                  scrollDirection: Axis.vertical,
                                  itemCount:
                                      listViewOrdersRecordList.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(height: 16.0),
                                  itemBuilder: (context, listViewIndex) {
                                    final listViewOrdersRecord =
                                        listViewOrdersRecordList[listViewIndex];
                                    final piattiDellOrdine = functions
                                            .raggruppaPiattiDaStringa(
                                                listViewOrdersRecord
                                                    .listaPiatti)
                                            ?.toList() ??
                                        [];

                                    return Container(
                                      decoration: BoxDecoration(
                                        color: theme.cardColor,
                                        borderRadius:
                                            BorderRadius.circular(16.0),
                                        border: Border.all(
                                          color: theme.dividerColor
                                              .withValues(alpha: 0.5),
                                          width: 1.0,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            blurRadius: 10.0,
                                            color: Colors.black
                                                .withValues(alpha: 0.03),
                                            offset: const Offset(0.0, 3.0),
                                          ),
                                        ],
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(18.0),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Header Card Ordine: Tavolo, Totale, Ora e Bottone Completa
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 14.0,
                                                          vertical: 8.0),
                                                      decoration: BoxDecoration(
                                                        color: theme.colorScheme.primary
                                                            .withValues(
                                                                alpha: 0.12),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12.0),
                                                      ),
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Icon(
                                                            Icons
                                                                .table_restaurant_rounded,
                                                            color: theme.colorScheme.primary,
                                                            size: 18.0,
                                                          ),
                                                          const SizedBox(
                                                              width: 6.0),
                                                          Text(
                                                            'Tavolo ${listViewOrdersRecord.tavolo}',
                                                            style: theme.textTheme.titleSmall?.copyWith(
                                                              color: theme.colorScheme.primary,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 16.0,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    const SizedBox(width: 12.0),
                                                    Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 10.0,
                                                          vertical: 6.0),
                                                      decoration: BoxDecoration(
                                                        color: theme.dividerColor
                                                            .withValues(
                                                                alpha: 0.15),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0),
                                                      ),
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Icon(
                                                            Icons
                                                                .access_time_rounded,
                                                            color: theme.hintColor,
                                                            size: 14.0,
                                                          ),
                                                          const SizedBox(
                                                              width: 4.0),
                                                          Text(
                                                            listViewOrdersRecord
                                                                        .dataCreazione !=
                                                                    null
                                                                ? dateTimeFormat(
                                                                    "Hm",
                                                                    listViewOrdersRecord
                                                                        .dataCreazione!,
                                                                    locale:
                                                                        FFLocalizations.of(
                                                                                context)
                                                                            .languageCode)
                                                                : '--:--',
                                                            style: theme.textTheme.bodySmall?.copyWith(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontSize: 13.0,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    Text(
                                                      formatNumber(
                                                        listViewOrdersRecord
                                                            .totale,
                                                        formatType:
                                                            FormatType.decimal,
                                                        decimalType: DecimalType
                                                            .periodDecimal,
                                                        currency: '€',
                                                      ),
                                                      style: theme.textTheme.titleMedium?.copyWith(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 17.0,
                                                      ),
                                                    ),

                                                  ],
                                                ),
                                              ],
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 12.0),
                                              child: Divider(
                                                height: 1.0,
                                                thickness: 1.0,
                                                color: theme.dividerColor
                                                    .withValues(alpha: 0.5),
                                              ),
                                            ),
                                            // Lista dei piatti ordinati
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: List.generate(
                                                piattiDellOrdine.length,
                                                (piattiDellOrdineIndex) {
                                                  final piattiDellOrdineItem =
                                                      piattiDellOrdine[
                                                          piattiDellOrdineIndex];
                                                  return Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            bottom: 6.0),
                                                    child: Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  top: 6.0),
                                                          child: Container(
                                                            width: 6.0,
                                                            height: 6.0,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: theme.colorScheme.primary,
                                                              shape: BoxShape
                                                                  .circle,
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            width: 10.0),
                                                        Expanded(
                                                          child: Text(
                                                            piattiDellOrdineItem,
                                                            style: theme.textTheme.bodyMedium?.copyWith(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              fontSize: 14.5,
                                                              height: 1.35,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              ),
                                             ),
                                              const SizedBox(height: 14.0),
                                              if (_selectedPhase == 'in_attesa')
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: ElevatedButton.icon(
                                                        onPressed: () async {
                                                          await listViewOrdersRecord
                                                              .reference
                                                              .update(
                                                                  createOrdersRecordData(
                                                            statoOrdine: 'in_preparazione',
                                                          ));
                                                        },
                                                        icon: const Icon(
                                                          Icons.soup_kitchen_rounded,
                                                          color: Colors.white,
                                                          size: 18.0,
                                                        ),
                                                        label: Text(
                                                          'Inizia preparazione',
                                                          style: theme.textTheme.labelMedium?.copyWith(
                                                            color: Colors.white,
                                                            fontWeight: FontWeight.bold,
                                                            fontSize: 13.5,
                                                          ),
                                                        ),
                                                        style: ElevatedButton.styleFrom(
                                                          backgroundColor: const Color(0xFF3B82F6),
                                                          elevation: 0.0,
                                                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.circular(10.0),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8.0),
                                                    ElevatedButton(
                                                      onPressed: () async {
                                                        await listViewOrdersRecord
                                                            .reference
                                                            .update(
                                                                createOrdersRecordData(
                                                          statoOrdine: 'Completato',
                                                          visto: false,
                                                        ));
                                                      },
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor: const Color(0xFF10B981),
                                                        foregroundColor: Colors.white,
                                                        elevation: 0.0,
                                                        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(10.0),
                                                        ),
                                                      ),
                                                      child: const Icon(Icons.check_rounded, size: 18.0),
                                                    ),
                                                  ],
                                                )
                                              else
                                                Row(
                                                  children: [
                                                    OutlinedButton.icon(
                                                      onPressed: () async {
                                                        await listViewOrdersRecord
                                                            .reference
                                                            .update(
                                                                createOrdersRecordData(
                                                          statoOrdine: 'in_attesa',
                                                        ));
                                                      },
                                                      icon: const Icon(Icons.replay_rounded, size: 16.0),
                                                      label: const Text('In attesa', style: TextStyle(fontSize: 12.0)),
                                                      style: OutlinedButton.styleFrom(
                                                        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(10.0),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8.0),
                                                    Expanded(
                                                      child: ElevatedButton.icon(
                                                        onPressed: () async {
                                                          await listViewOrdersRecord
                                                              .reference
                                                              .update(
                                                                  createOrdersRecordData(
                                                            statoOrdine: 'Completato',
                                                            visto: false,
                                                          ));
                                                        },
                                                        icon: const Icon(
                                                          Icons.check_rounded,
                                                          color: Colors.white,
                                                          size: 18.0,
                                                        ),
                                                        label: Text(
                                                          'Pronto / Completa',
                                                          style: theme.textTheme.labelMedium?.copyWith(
                                                            color: Colors.white,
                                                            fontWeight: FontWeight.bold,
                                                            fontSize: 13.5,
                                                          ),
                                                        ),
                                                        style: ElevatedButton.styleFrom(
                                                          backgroundColor: const Color(0xFF10B981),
                                                          elevation: 0.0,
                                                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.circular(10.0),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Align(
                alignment: const AlignmentDirectional(0.0, 1.0),
                child: wrapWithModel(
                  model: _model.navBarDinamicaModel,
                  updateCallback: () => safeSetState(() {}),
                  child: NavBarDinamicaWidget(
                    paginaAttiva: 2,
                    ristoranteRef: widget.ristoranteRef,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return ResponsiveDashboard(
      ristoranteRef: widget.ristoranteRef,
      initialNavIndex: 1,
      mobile: mobileUI,
    );
  }
}
