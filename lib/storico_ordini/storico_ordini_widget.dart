import '/backend/backend.dart';
import '/components/nav_bar_dinamica_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/custom_functions.dart' as functions;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'storico_ordini_model.dart';
export 'storico_ordini_model.dart';

/// Pagina dove arrivano i piatti completi dopo che vengono preparati in cucina
class StoricoOrdiniWidget extends StatefulWidget {
  const StoricoOrdiniWidget({
    super.key,
    required this.ristoranteRef,
  });

  final DocumentReference? ristoranteRef;

  static String routeName = 'StoricoOrdini';
  static String routePath = '/storicoOrdini';

  @override
  State<StoricoOrdiniWidget> createState() => _StoricoOrdiniWidgetState();
}

class _StoricoOrdiniWidgetState extends State<StoricoOrdiniWidget> {
  late StoricoOrdiniModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => StoricoOrdiniModel());

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
        floatingActionButton: Align(
          alignment: const AlignmentDirectional(1.0, 1.0),
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 24.0, 85.0),
            child: FloatingActionButton.extended(
              onPressed: () async {
                var confirmDialogResponse = await showDialog<bool>(
                      context: context,
                      builder: (alertDialogContext) {
                        return AlertDialog(
                          backgroundColor: theme.cardColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          title: Text(
                            'Svuota storico ordini',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          content: Text(
                            'Sei sicuro di voler eliminare tutti gli ordini completati? Questa azione cancellerà definitivamente i dati.',
                            style: theme.textTheme.bodyMedium,
                          ),
                          actions: [
                            TextButton(
                              onPressed: () =>
                                  Navigator.pop(alertDialogContext, false),
                              child: const Text('Annulla'),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.error,
                                foregroundColor: theme.colorScheme.onError,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                              onPressed: () =>
                                  Navigator.pop(alertDialogContext, true),
                              child: const Text('Elimina tutti'),
                            ),
                          ],
                        );
                      },
                    ) ??
                    false;
                if (confirmDialogResponse) {
                  _model.ordiniDaEliminare = await queryOrdersRecordOnce(
                    queryBuilder: (ordersRecord) => ordersRecord.where(
                      'stato_ordine',
                      isEqualTo: 'Completato',
                    ),
                  );
                  _model.indiceLoop = 0;
                  safeSetState(() {});
                  while (
                      _model.indiceLoop! < _model.ordiniDaEliminare!.length) {
                    await _model.ordiniDaEliminare!
                        .elementAtOrNull(_model.indiceLoop!)!
                        .reference
                        .delete();
                    _model.indiceLoop = _model.indiceLoop! + 1;
                    safeSetState(() {});
                  }
                }

                safeSetState(() {});
              },
              backgroundColor: theme.colorScheme.error,
              foregroundColor: theme.colorScheme.onError,
              elevation: 4.0,
              icon: const Icon(
                Icons.delete_sweep_rounded,
                size: 20.0,
              ),
              label: const Text(
                'Svuota storico',
              ),
            ),
          ),
        ),
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(68.0),
          child: Container(
            decoration: BoxDecoration(
              color: theme.cardColor,
              border: Border(
                bottom: BorderSide(
                  color: theme.dividerColor.withValues(alpha: 0.15),
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
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'Menu',
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.primary,
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
                                    Icons.done_all_rounded,
                                    color: theme.colorScheme.primary,
                                    size: 14.0,
                                  ),
                                  const SizedBox(width: 4.0),
                                  Text(
                                    'Archivio',
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
                              isEqualTo: 'Completato',
                            ),
                          ),
                          builder: (context, snapshot) {
                            final count =
                                snapshot.hasData ? snapshot.data!.length : 0;
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12.0, vertical: 6.0),
                              decoration: BoxDecoration(
                                color: (count > 0
                                        ? const Color(0xFFF59E0B)
                                        : theme.hintColor)
                                    .withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(20.0),
                                border: Border.all(
                                  color: (count > 0
                                          ? const Color(0xFFF59E0B)
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
                                          ? const Color(0xFFF59E0B)
                                          : theme.hintColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8.0),
                                  Text(
                                    '$count completati',
                                    style: theme.textTheme.labelMedium?.copyWith(
                                      color: count > 0
                                          ? const Color(0xFFD97706)
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
                              color: theme.dividerColor.withValues(alpha: 0.15),
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
                                      'Ordini Completati',
                                      style: theme.textTheme.headlineSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: -0.3,
                                      ),
                                    ),
                                    const SizedBox(height: 6.0),
                                    Text(
                                      'Consulta lo storico delle comande servite e gestisci l\'archivio',
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
                                  color: const Color(0xFF16A34A)
                                      .withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                child: const Icon(
                                  Icons.check_circle_rounded,
                                  color: Color(0xFF16A34A),
                                  size: 22.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24.0),

                        // Orders StreamBuilder
                        StreamBuilder<List<OrdersRecord>>(
                          stream: queryOrdersRecord(
                            queryBuilder: (ordersRecord) => ordersRecord
                                .where(
                                  'stato_ordine',
                                  isEqualTo: 'Completato',
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
                                    color: theme.dividerColor.withValues(alpha: 0.15),
                                    width: 1.0,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Container(
                                      width: 60.0,
                                      height: 60.0,
                                      decoration: BoxDecoration(
                                        color: theme.dividerColor.withValues(alpha: 0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.task_alt_rounded,
                                        color: theme.dividerColor.withValues(alpha: 0.8),
                                        size: 30.0,
                                      ),
                                    ),
                                    const SizedBox(height: 14.0),
                                    Text(
                                      'Nessun ordine completato',
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 6.0),
                                    Text(
                                      'Quando contrassegni un ordine come pronto, verrà archiviato qui.',
                                      textAlign: TextAlign.center,
                                      style: theme.textTheme.bodySmall,
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
                                          const Icon(
                                            Icons.inventory_2_outlined,
                                            color: Color(0xFF16A34A),
                                            size: 20.0,
                                          ),
                                          const SizedBox(width: 8.0),
                                          Text(
                                            'Comande archiviate',
                                            style: theme.textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.bold,
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
                                          color: const Color(0xFF16A34A)
                                              .withValues(alpha: 0.12),
                                          borderRadius:
                                              BorderRadius.circular(20.0),
                                        ),
                                        child: Text(
                                          '${listViewOrdersRecordList.length} totale',
                                          style: theme.textTheme.labelSmall?.copyWith(
                                            color: const Color(0xFF16A34A),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                ListView.separated(
                                  padding: EdgeInsets.zero,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  scrollDirection: Axis.vertical,
                                  itemCount: listViewOrdersRecordList.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(height: 14.0),
                                  itemBuilder: (context, listViewIndex) {
                                    final listViewOrdersRecord = listViewOrdersRecordList[listViewIndex];
                                    final piattiDellOrdine = functions
                                            .raggruppaPiattiDaStringa(listViewOrdersRecord.listaPiatti)
                                            ?.toList() ??
                                        [];

                                    return Container(
                                      decoration: BoxDecoration(
                                        color: theme.cardColor,
                                        borderRadius: BorderRadius.circular(16.0),
                                        border: Border.all(
                                          color: theme.dividerColor.withValues(alpha: 0.15),
                                          width: 1.0,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            blurRadius: 10.0,
                                            color: Colors.black.withValues(alpha: 0.03),
                                            offset: const Offset(0.0, 3.0),
                                          ),
                                        ],
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(18.0),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            // Header Card Ordine: Tavolo, Totale, Ora e Tasto Elimina Singolo
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
                                                      decoration: BoxDecoration(
                                                        color: const Color(0xFF16A34A).withValues(alpha: 0.12),
                                                        borderRadius: BorderRadius.circular(12.0),
                                                      ),
                                                      child: Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          const Icon(
                                                            Icons.table_restaurant_rounded,
                                                            color: Color(0xFF16A34A),
                                                            size: 18.0,
                                                          ),
                                                          const SizedBox(width: 6.0),
                                                          Text(
                                                            'Tavolo ${listViewOrdersRecord.tavolo}',
                                                            style: theme.textTheme.titleMedium?.copyWith(
                                                              color: const Color(0xFF16A34A),
                                                              fontWeight: FontWeight.bold,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    const SizedBox(width: 12.0),
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                                                      decoration: BoxDecoration(
                                                        color: theme.dividerColor.withValues(alpha: 0.1),
                                                        borderRadius: BorderRadius.circular(8.0),
                                                      ),
                                                      child: Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          Icon(
                                                            Icons.access_time_rounded,
                                                            color: theme.textTheme.bodySmall?.color,
                                                            size: 14.0,
                                                          ),
                                                          const SizedBox(width: 4.0),
                                                          Text(
                                                            listViewOrdersRecord.dataCreazione != null
                                                                ? dateTimeFormat("Hm", listViewOrdersRecord.dataCreazione!, locale: FFLocalizations.of(context).languageCode)
                                                                : '--:--',
                                                            style: theme.textTheme.bodySmall?.copyWith(
                                                              fontWeight: FontWeight.w600,
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
                                                        listViewOrdersRecord.totale,
                                                        formatType: FormatType.decimal,
                                                        decimalType: DecimalType.periodDecimal,
                                                        currency: '€',
                                                      ),
                                                      style: theme.textTheme.titleMedium?.copyWith(
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 14.0),
                                                    IconButton(
                                                      tooltip: 'Elimina ordine',
                                                      onPressed: () async {
                                                        var confirmDialogResponse = await showDialog<bool>(
                                                              context: context,
                                                              builder: (alertDialogContext) {
                                                                return AlertDialog(
                                                                  backgroundColor: theme.cardColor,
                                                                  shape: RoundedRectangleBorder(
                                                                    borderRadius: BorderRadius.circular(20.0),
                                                                  ),
                                                                  title: Text(
                                                                    'Elimina ordine',
                                                                    style: theme.textTheme.titleMedium?.copyWith(
                                                                      fontWeight: FontWeight.bold,
                                                                    ),
                                                                  ),
                                                                  content: Text(
                                                                    'Vuoi davvero eliminare questo ordine dallo storico?',
                                                                    style: theme.textTheme.bodyMedium,
                                                                  ),
                                                                  actions: [
                                                                    TextButton(
                                                                      onPressed: () =>
                                                                          Navigator.pop(alertDialogContext, false),
                                                                      child: const Text('Annulla'),
                                                                    ),
                                                                    ElevatedButton(
                                                                      style: ElevatedButton.styleFrom(
                                                                        backgroundColor: theme.colorScheme.error,
                                                                        foregroundColor: theme.colorScheme.onError,
                                                                        shape: RoundedRectangleBorder(
                                                                          borderRadius: BorderRadius.circular(10.0),
                                                                        ),
                                                                      ),
                                                                      onPressed: () =>
                                                                          Navigator.pop(alertDialogContext, true),
                                                                      child: const Text('Elimina'),
                                                                    ),
                                                                  ],
                                                                );
                                                              },
                                                            ) ??
                                                            false;
                                                        if (confirmDialogResponse) {
                                                          await listViewOrdersRecord.reference.delete();
                                                        }
                                                      },
                                                      icon: Icon(
                                                        Icons.delete_outline_rounded,
                                                        color: theme.colorScheme.error,
                                                        size: 20.0,
                                                      ),
                                                      style: IconButton.styleFrom(
                                                        backgroundColor: theme.colorScheme.error.withValues(alpha: 0.12),
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(10.0),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 12.0),
                                              child: Divider(
                                                height: 1.0,
                                                thickness: 1.0,
                                                color: theme.dividerColor.withValues(alpha: 0.15),
                                              ),
                                            ),
                                            // Lista piatti preparati
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: List.generate(
                                                piattiDellOrdine.length,
                                                (piattiDellOrdineIndex) {
                                                  final piattiDellOrdineItem = piattiDellOrdine[piattiDellOrdineIndex];
                                                  return Padding(
                                                    padding: const EdgeInsets.only(bottom: 6.0),
                                                    child: Row(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Padding(
                                                          padding: const EdgeInsets.only(top: 6.0),
                                                          child: Container(
                                                            width: 6.0,
                                                            height: 6.0,
                                                            decoration: const BoxDecoration(
                                                              color: Color(0xFF16A34A),
                                                              shape: BoxShape.circle,
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(width: 10.0),
                                                        Expanded(
                                                          child: Text(
                                                            piattiDellOrdineItem,
                                                            style: theme.textTheme.bodyMedium?.copyWith(
                                                              fontWeight: FontWeight.w500,
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
                    paginaAttiva: 3,
                    ristoranteRef: widget.ristoranteRef,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
