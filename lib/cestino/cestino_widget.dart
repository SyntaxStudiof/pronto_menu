import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/components/cestino_vuoto_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/actions/index.dart' as actions;
import '/services/audit_log_service.dart';
import '/services/cestino_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'cestino_model.dart';
export 'cestino_model.dart';

/// qua le pagine rimarrano per 7 ulteriori giorni
class CestinoWidget extends StatefulWidget {
  const CestinoWidget({
    super.key,
    this.embedded = false,
  });

  final bool embedded;

  static String routeName = 'Cestino';
  static String routePath = '/cestino';

  @override
  State<CestinoWidget> createState() => _CestinoWidgetState();
}

class _CestinoWidgetState extends State<CestinoWidget> {
  late CestinoModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CestinoModel());

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await CestinoService.pulisciPiattiScaduti(
        ristoranteRef: currentUserReference,
      );
      if (mounted) safeSetState(() {});
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

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            var confirmDialogResponse = await showDialog<bool>(
                  context: context,
                  builder: (alertDialogContext) {
                    return AlertDialog(
                      title: const Text(
                          'Sei sicuro di voler svuotare tutto il cestino? L\'azione è irreversibile.'),
                      actions: [
                        TextButton(
                          onPressed: () =>
                              Navigator.pop(alertDialogContext, false),
                          child: const Text('Annulla'),
                        ),
                        TextButton(
                          onPressed: () =>
                              Navigator.pop(alertDialogContext, true),
                          child: const Text('Conferma'),
                        ),
                      ],
                    );
                  },
                ) ??
                false;
            if (confirmDialogResponse) {
              await actions.svuotaCestinoMassivo(
                currentUserReference,
              );
              await AuditLogService.logAction(
                azione: "Ha svuotato l'intero cestino",
                dettagli: "Eliminazione definitiva massiva di tutti i piatti presenti nel cestino",
                tipoAzione: 'eliminazione',
                tipoEntita: 'piatto',
              );
            }
          },
          elevation: 2.0,
          child: const Icon(
            Icons.delete,
            size: 28.0,
          ),
        ),
        appBar: widget.embedded
            ? null
            : AppBar(
          automaticallyImplyLeading: false,
          leading: FlutterFlowIconButton(
            borderRadius: 30.0,
            buttonSize: 40.0,
            icon: const Icon(
              Icons.arrow_back_rounded,
              size: 24.0,
            ),
            onPressed: () async {
              context.pop();
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
                  Icons.delete_outline_rounded,
                  color: theme.colorScheme.primary,
                  size: 20.0,
                ),
              ),
              const SizedBox(width: 10.0),
              Text(
                'Cestino',
                style: theme.appBarTheme.titleTextStyle ??
                    theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                      letterSpacing: -0.4,
                    ),
              ),
            ],
          ),
          actions: const [
            SizedBox(width: 48.0),
          ],
          centerTitle: true,
          elevation: 0.0,
        ),
        body: SafeArea(
          top: true,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(14.0, 14.0, 14.0, 10.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.2),
                      width: 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.auto_delete_outlined,
                        color: theme.colorScheme.primary,
                        size: 20.0,
                      ),
                      const SizedBox(width: 10.0),
                      Expanded(
                        child: Text(
                          'I piatti restano nel cestino per 7 giorni. Dopo tale periodo vengono eliminati automaticamente da Firebase.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              StreamBuilder<List<PiattiRecord>>(
                stream: queryPiattiRecord(
                  queryBuilder: (piattiRecord) => piattiRecord
                      .where(
                        'isCestinato',
                        isEqualTo: true,
                      )
                      .where(
                        'proprietario',
                        isEqualTo: currentUserReference,
                      ),
                ),
                builder: (context, snapshot) {
                  // Customize what your widget looks like when it's loading.
                  if (!snapshot.hasData) {
                    return Center(
                      child: SizedBox(
                        width: 50.0,
                        height: 50.0,
                        child: SpinKitPulse(
                          color: theme.colorScheme.primary,
                          size: 50.0,
                        ),
                      ),
                    );
                  }
                  List<PiattiRecord> listViewPiattiRecordList = snapshot.data!;
                  if (listViewPiattiRecordList.isEmpty) {
                    return const Center(
                      child: CestinoVuotoWidget(),
                    );
                  }

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final isDesktop = constraints.maxWidth >= 800 || widget.embedded;

                      if (isDesktop) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Header Desktop con Stat e Tasto Svuota rapido
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.inventory_2_outlined, size: 16.0, color: theme.colorScheme.primary),
                                        const SizedBox(width: 8.0),
                                        Text(
                                          '${listViewPiattiRecordList.length} piatti nel cestino',
                                          style: TextStyle(
                                            fontSize: 13.0,
                                            fontWeight: FontWeight.bold,
                                            color: theme.colorScheme.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  ElevatedButton.icon(
                                    onPressed: () async {
                                      var confirm = await showDialog<bool>(
                                            context: context,
                                            builder: (ctx) => AlertDialog(
                                              title: const Text('Svuota intero cestino?'),
                                              content: const Text(
                                                  'Tutti i piatti nel cestino verranno eliminati per sempre. L\'azione è irreversibile.'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.pop(ctx, false),
                                                  child: const Text('Annulla'),
                                                ),
                                                ElevatedButton(
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: theme.colorScheme.error,
                                                    foregroundColor: Colors.white,
                                                  ),
                                                  onPressed: () => Navigator.pop(ctx, true),
                                                  child: const Text('Elimina tutti'),
                                                ),
                                              ],
                                            ),
                                          ) ??
                                          false;
                                      if (confirm) {
                                        await actions.svuotaCestinoMassivo(currentUserReference);
                                      }
                                    },
                                    icon: const Icon(Icons.delete_sweep_rounded, size: 18.0),
                                    label: const Text('Svuota Cestino'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: theme.colorScheme.error.withValues(alpha: 0.12),
                                      foregroundColor: theme.colorScheme.error,
                                      elevation: 0.0,
                                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10.0),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16.0),

                              // Grid Desktop a più colonne
                              GridView.builder(
                                padding: const EdgeInsets.only(bottom: 32.0),
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: 480.0,
                                  mainAxisExtent: 108.0,
                                  crossAxisSpacing: 16.0,
                                  mainAxisSpacing: 14.0,
                                ),
                                itemCount: listViewPiattiRecordList.length,
                                itemBuilder: (context, index) {
                                  return _buildDishCard(
                                    listViewPiattiRecordList[index],
                                    theme,
                                  );
                                },
                              ),
                            ],
                          ),
                        );
                      }

                      // Layout Mobile classico
                      return ListView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        itemCount: listViewPiattiRecordList.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                10.0, 6.0, 10.0, 6.0),
                            child: _buildDishCard(
                              listViewPiattiRecordList[index],
                              theme,
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDishCard(PiattiRecord listViewPiattiRecord, ThemeData theme) {
    final giorniRimanenti = CestinoService.calcolaGiorniRimanenti(
      listViewPiattiRecord.dataCestinamento,
    );
    final isUrgent = giorniRimanenti <= 1;

    return Card(
      elevation: 0.0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14.0),
        side: BorderSide(
          color: theme.dividerColor.withValues(alpha: 0.6),
          width: 1.0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(12.0, 10.0, 12.0, 10.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: CachedNetworkImage(
                fadeInDuration: const Duration(milliseconds: 300),
                fadeOutDuration: const Duration(milliseconds: 300),
                imageUrl: valueOrDefault<String>(
                  listViewPiattiRecord.foto,
                  'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/pronto-menu-f0och1/assets/2n9hc9ugo68c/Immagine_standard.png',
                ),
                width: 60.0,
                height: 60.0,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) => Container(
                  color: theme.dividerColor.withValues(alpha: 0.1),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.restaurant_outlined,
                    color: theme.iconTheme.color?.withValues(alpha: 0.5) ?? theme.hintColor,
                    size: 24.0,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14.0),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    listViewPiattiRecord.nome,
                    textAlign: TextAlign.start,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Row(
                    children: [
                      Text(
                        formatNumber(
                          listViewPiattiRecord.prezzo,
                          formatType: FormatType.decimal,
                          decimalType: DecimalType.commaDecimal,
                          currency: '€',
                        ),
                        textAlign: TextAlign.start,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                        decoration: BoxDecoration(
                          color: isUrgent
                              ? const Color(0xFFEF4444).withValues(alpha: 0.12)
                              : const Color(0xFFD97706).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6.0),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.timer_outlined,
                              size: 11.0,
                              color: isUrgent ? const Color(0xFFEF4444) : const Color(0xFFD97706),
                            ),
                            const SizedBox(width: 3.0),
                            Text(
                              isUrgent ? 'Scade oggi' : '$giorniRimanenti gg',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                                color: isUrgent ? const Color(0xFFEF4444) : const Color(0xFFD97706),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: 'Ripristina nel menù',
                  icon: Icon(
                    Icons.restore_rounded,
                    color: theme.colorScheme.primary,
                    size: 22.0,
                  ),
                  onPressed: () async {
                    await listViewPiattiRecord.reference.update({
                      ...createPiattiRecordData(
                        isCestinato: false,
                      ),
                      ...mapToFirestore(
                        {
                          'dataCestinamento': FieldValue.delete(),
                        },
                      ),
                    });
                    final dishName = listViewPiattiRecord.nome;
                    await AuditLogService.logAction(
                      azione: "Ha ripristinato dal cestino il piatto '$dishName'",
                      dettagli: "Piatto '$dishName' ripristinato nel menu attivo",
                      tipoAzione: 'ripristino',
                      tipoEntita: 'piatto',
                    );
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Piatto "$dishName" ripristinato con successo!'),
                          duration: const Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                ),
                IconButton(
                  tooltip: 'Elimina definitivamente',
                  icon: Icon(
                    Icons.delete_outline_rounded,
                    color: theme.colorScheme.error,
                    size: 22.0,
                  ),
                  onPressed: () async {
                    var confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Elimina definitivamente'),
                            content: const Text(
                                'Sei sicuro? Il piatto e la sua foto verranno cancellati per sempre e non potrai più recuperarli'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: const Text('Annulla'),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.colorScheme.error,
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: () => Navigator.pop(ctx, true),
                                child: const Text('Elimina'),
                              ),
                            ],
                          ),
                        ) ??
                        false;
                    if (confirm) {
                      if (listViewPiattiRecord.foto.isNotEmpty) {
                        try {
                          await FirebaseStorage.instance
                              .refFromURL(listViewPiattiRecord.foto)
                              .delete();
                        } catch (_) {}
                      }
                      final dishName = listViewPiattiRecord.nome;
                      await listViewPiattiRecord.reference.delete();
                      await AuditLogService.logAction(
                        azione: "Ha eliminato definitivamente il piatto '$dishName'",
                        dettagli:
                            "Eliminazione definitiva dal cestino del piatto '$dishName' e foto da storage",
                        tipoAzione: 'eliminazione',
                        tipoEntita: 'piatto',
                      );
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

