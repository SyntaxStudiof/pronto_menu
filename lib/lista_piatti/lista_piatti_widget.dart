import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/components/popup_categoria_widget.dart';
import '/flutter_flow/flutter_flow_choice_chips.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import '/backend/schema/util/allergeni_data.dart';
import '/components/pannello_modifica_piatto_widget.dart';
import 'lista_piatti_model.dart';
export 'lista_piatti_model.dart';

/// Pagina del ristoratore per vedere i piatti esistenti
class ListaPiattiWidget extends StatefulWidget {
  const ListaPiattiWidget({
    super.key,
    required this.nomeCategoria,
    required this.categoriaAttuale,
    required this.ristoranteRef,
  });

  final String? nomeCategoria;
  final DocumentReference? categoriaAttuale;
  final DocumentReference? ristoranteRef;

  static String routeName = 'lista_piatti';
  static String routePath = '/listaPiatti';

  @override
  State<ListaPiattiWidget> createState() => _ListaPiattiWidgetState();
}

class _ListaPiattiWidgetState extends State<ListaPiattiWidget> {
  late ListaPiattiModel _model;
  PiattiRecord? _piattoInModifica;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ListaPiattiModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      _model.piattiScaricati = await queryPiattiRecordOnce(
        queryBuilder: (piattiRecord) => piattiRecord.where(
          'proprietario',
          isEqualTo: currentUserReference,
        ),
      );
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  void _selezionaPiatto(PiattiRecord piatto) async {
    final isWide = MediaQuery.sizeOf(context).width >= 850;
    if (isWide) {
      safeSetState(() {
        if (_piattoInModifica?.reference.id == piatto.reference.id) {
          _piattoInModifica = null;
        } else {
          _piattoInModifica = piatto;
        }
      });
    } else {
      await showModalBottomSheet(
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        enableDrag: true,
        context: context,
        builder: (bottomSheetContext) {
          final keyboardBottom =
              MediaQuery.viewInsetsOf(bottomSheetContext).bottom;
          return Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.paddingOf(context).top + 20,
              bottom: keyboardBottom,
            ),
            child: SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.88,
              child: PannelloModificaPiattoWidget(
                piatto: piatto,
                categoriaRef: widget.categoriaAttuale!,
                ristoranteRef: widget.ristoranteRef,
                onClose: () => Navigator.pop(bottomSheetContext),
                onSaved: (aggiornato) => Navigator.pop(bottomSheetContext),
              ),
            ),
          );
        },
      );
    }
  }

  Widget _buildDishItem({
    required BuildContext context,
    required PiattiRecord piatto,
  }) {
    final theme = Theme.of(context);
    final isSelectedForEdit =
        _piattoInModifica?.reference.id == piatto.reference.id;

    return Container(
      decoration: BoxDecoration(
        color: isSelectedForEdit
            ? theme.colorScheme.primary.withValues(alpha: 0.08)
            : theme.cardColor,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: isSelectedForEdit
              ? theme.colorScheme.primary
              : theme.dividerColor.withValues(alpha: 0.15),
          width: isSelectedForEdit ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelectedForEdit
                ? theme.colorScheme.primary.withValues(alpha: 0.12)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: isSelectedForEdit ? 12.0 : 8.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16.0),
          hoverColor: theme.dividerColor.withValues(alpha: 0.08),
          onTap: () => _selezionaPiatto(piatto),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Immagine piatto
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: Container(
                    width: 64.0,
                    height: 64.0,
                    color: theme.dividerColor.withValues(alpha: 0.1),
                    child: piatto.foto.isNotEmpty
                        ? Image.network(
                            piatto.foto,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                              color: theme.dividerColor.withValues(alpha: 0.1),
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.restaurant_outlined,
                                color: theme.iconTheme.color
                                        ?.withValues(alpha: 0.5) ??
                                    theme.hintColor,
                                size: 26.0,
                              ),
                            ),
                          )
                        : Container(
                            color: theme.dividerColor.withValues(alpha: 0.08),
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.restaurant_outlined,
                              color: theme.iconTheme.color
                                      ?.withValues(alpha: 0.4) ??
                                  theme.hintColor,
                              size: 26.0,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 16.0),

                // Info piatto
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        piatto.nome,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (piatto.ingredienti.isNotEmpty) ...[
                        const SizedBox(height: 4.0),
                        Text(
                          piatto.ingredienti,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            height: 1.3,
                          ),
                        ),
                      ],
                      if (piatto.intolleranze.isNotEmpty || piatto.allergeni.isNotEmpty) ...[
                        const SizedBox(height: 4.0),
                        Wrap(
                          spacing: 4.0,
                          runSpacing: 2.0,
                          children: [
                            ...piatto.intolleranze.map((tag) {
                              final f = AllergeniData.getFiltroMagicoById(tag);
                              if (f == null) return const SizedBox.shrink();
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: f.badgeColor.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6.0),
                                ),
                                child: Text(
                                  '${f.emoji} ${f.label}',
                                  style: TextStyle(
                                    color: f.badgeColor,
                                    fontSize: 10.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            }),
                            if (piatto.allergeni.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6.0),
                                ),
                                child: Text(
                                  '⚠️ ${piatto.allergeni.length} allergeni',
                                  style: TextStyle(
                                    color: Colors.orange.shade800,
                                    fontSize: 10.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 14.0),

                // Prezzo
                Text(
                  formatNumber(
                    piatto.prezzo,
                    formatType: FormatType.decimal,
                    decimalType: DecimalType.periodDecimal,
                    currency: '€',
                  ),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 12.0),

                // Azione Elimina
                Tooltip(
                  message: 'Cestina piatto',
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8.0),
                    onTap: () async {
                      final confirmDialogResponse = await showDialog<bool>(
                            context: context,
                            builder: (alertDialogContext) {
                              return AlertDialog(
                                backgroundColor: theme.cardColor,
                                title: Text(
                                  'Elimina piatto',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                content: Text(
                                  'Sei sicuro di voler eliminare questo piatto? Rimarrà nel cestino per 7 giorni prima di essere eliminato definitivamente.',
                                  style: theme.textTheme.bodyMedium,
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(alertDialogContext, false),
                                    child: const Text('Annulla'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(alertDialogContext, true),
                                    child: Text(
                                      'Sì, elimina',
                                      style: TextStyle(
                                        color: theme.colorScheme.error,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ) ??
                          false;
                      if (confirmDialogResponse) {
                        if (_piattoInModifica?.reference.id == piatto.reference.id) {
                          safeSetState(() {
                            _piattoInModifica = null;
                          });
                        }
                        await piatto.reference.update(
                          createPiattiRecordData(
                            isCestinato: true,
                            dataCestinamento: functions.aggiungiSetteGiorni(
                                getCurrentTimestamp),
                          ),
                        );
                      }
                    },
                    child: Container(
                      width: 36.0,
                      height: 36.0,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.error.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Icon(
                        Icons.delete_outline_rounded,
                        color: theme.colorScheme.error,
                        size: 18.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
            context.pushNamed(
              CreaPiattoWidget.routeName,
              queryParameters: {
                'categoriaSelezionata': serializeParam(
                  widget.categoriaAttuale,
                  ParamType.DocumentReference,
                ),
                'ristoranteRef': serializeParam(
                  widget.ristoranteRef,
                  ParamType.DocumentReference,
                ),
              }.withoutNulls,
            );
          },
          backgroundColor: theme.colorScheme.primary,
          elevation: 4.0,
          child: Icon(
            Icons.add_rounded,
            color: theme.colorScheme.onPrimary,
            size: 28.0,
          ),
        ),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          automaticallyImplyLeading: false,
          leading: FlutterFlowIconButton(
            borderColor: Colors.transparent,
            borderRadius: 30.0,
            borderWidth: 0.0,
            buttonSize: 40.0,
            icon: Icon(
              Icons.arrow_back_rounded,
              color: theme.colorScheme.onSurface,
              size: 24.0,
            ),
            onPressed: () async {
              if (_piattoInModifica != null) {
                safeSetState(() {
                  _piattoInModifica = null;
                });
              } else {
                context.pop();
              }
            },
          ),
          title: Text(
            valueOrDefault<String>(
              widget.nomeCategoria,
              'Categoria',
            ),
            style: theme.appBarTheme.titleTextStyle ??
                theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
          ),
          centerTitle: true,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: FlutterFlowIconButton(
                borderColor: Colors.transparent,
                borderRadius: 30.0,
                borderWidth: 0.0,
                buttonSize: 40.0,
                icon: Icon(
                  Icons.edit,
                  color: theme.colorScheme.onSurface,
                  size: 22.0,
                ),
                onPressed: () async {
                  await showModalBottomSheet(
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    enableDrag: false,
                    context: context,
                    builder: (context) {
                      return GestureDetector(
                        onTap: () {
                          FocusScope.of(context).unfocus();
                          FocusManager.instance.primaryFocus?.unfocus();
                        },
                        child: Padding(
                          padding: MediaQuery.viewInsetsOf(context),
                          child: PopupCategoriaWidget(
                            refCategoria: widget.categoriaAttuale!,
                            nomeAttuale: widget.nomeCategoria!,
                            categoriaInModifica: widget.categoriaAttuale!,
                          ),
                        ),
                      );
                    },
                  ).then((value) => safeSetState(() {}));
                },
              ),
            ),
          ],
        ),
        body: SafeArea(
          top: true,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 850;
              final showSplitView = isWide && _piattoInModifica != null;

              return Align(
                alignment: Alignment.topCenter,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeInOutCubic,
                  constraints: BoxConstraints(
                    maxWidth: showSplitView ? 1440.0 : 860.0,
                    maxHeight: constraints.maxHeight,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Colonna Sinistra (Lista piatti)
                      Expanded(
                        flex: showSplitView ? 5 : 1,
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(0.0, 15.0, 0.0, 0.0),
                              child: AuthUserStreamWidget(
                                builder: (context) => FlutterFlowChoiceChips(
                                  options: const [ChipData('A - Z'), ChipData('Prezzo')],
                                  onChanged: (val) async {
                                    safeSetState(
                                        () => _model.choiceChipsValue = val?.firstOrNull);
                                    _model.sceltaOrdinamento = _model.choiceChipsValue!;
                                    safeSetState(() {});

                                    await currentUserReference!.update(createUsersRecordData(
                                      ordinePreferito: _model.choiceChipsValue,
                                    ));
                                  },
                                  selectedChipStyle: ChipStyle(
                                    backgroundColor: theme.colorScheme.primary,
                                    textStyle: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.onPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    iconColor: theme.colorScheme.onPrimary,
                                    iconSize: 16.0,
                                    elevation: 0.0,
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  unselectedChipStyle: ChipStyle(
                                    backgroundColor: theme.cardColor,
                                    textStyle: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.textTheme.bodySmall?.color,
                                    ),
                                    iconColor: theme.iconTheme.color,
                                    iconSize: 16.0,
                                    elevation: 0.0,
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  chipSpacing: 8.0,
                                  rowSpacing: 8.0,
                                  multiselect: false,
                                  initialized: _model.choiceChipsValue != null,
                                  alignment: WrapAlignment.start,
                                  controller: _model.choiceChipsValueController ??=
                                      FormFieldController<List<String>>(
                                    [
                                      valueOrDefault<String>(
                                        valueOrDefault(
                                            currentUserDocument?.ordinePreferito, ''),
                                        'A - Z',
                                      )
                                    ],
                                  ),
                                  wrapped: true,
                                ),
                              ),
                            ),
                            if (_model.choiceChipsValue == 'A - Z')
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      16.0, 20.0, 16.0, 80.0),
                                  child: StreamBuilder<List<PiattiRecord>>(
                                    stream: queryPiattiRecord(
                                      queryBuilder: (piattiRecord) => piattiRecord
                                          .where(
                                            'Categoria',
                                            isEqualTo: widget.categoriaAttuale?.id,
                                          )
                                          .where(
                                            'proprietario',
                                            isEqualTo: widget.ristoranteRef,
                                          )
                                          .where(
                                            'isCestinato',
                                            isEqualTo: false,
                                          )
                                          .orderBy('Nome'),
                                    ),
                                    builder: (context, snapshot) {
                                      if (!snapshot.hasData) {
                                        return Center(
                                          child: SizedBox(
                                            width: 44.0,
                                            height: 44.0,
                                            child: SpinKitPulse(
                                              color: theme.colorScheme.primary,
                                              size: 44.0,
                                            ),
                                          ),
                                        );
                                      }
                                      List<PiattiRecord> listViewPiattiRecordList =
                                          snapshot.data!;

                                      return ListView.separated(
                                        padding: EdgeInsets.zero,
                                        shrinkWrap: true,
                                        scrollDirection: Axis.vertical,
                                        itemCount: listViewPiattiRecordList.length,
                                        separatorBuilder: (context, index) =>
                                            const SizedBox(height: 10.0),
                                        itemBuilder: (context, listViewIndex) {
                                          final piatto =
                                              listViewPiattiRecordList[listViewIndex];
                                          return _buildDishItem(
                                            context: context,
                                            piatto: piatto,
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ),
                            if (_model.choiceChipsValue == 'Prezzo')
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      16.0, 20.0, 16.0, 80.0),
                                  child: StreamBuilder<List<PiattiRecord>>(
                                    stream: queryPiattiRecord(
                                      queryBuilder: (piattiRecord) => piattiRecord
                                          .where(
                                            'Categoria',
                                            isEqualTo: widget.categoriaAttuale?.id,
                                          )
                                          .where(
                                            'proprietario',
                                            isEqualTo: widget.ristoranteRef,
                                          )
                                          .where(
                                            'isCestinato',
                                            isEqualTo: false,
                                          )
                                          .orderBy('Prezzo'),
                                    ),
                                    builder: (context, snapshot) {
                                      if (!snapshot.hasData) {
                                        return Center(
                                          child: SizedBox(
                                            width: 44.0,
                                            height: 44.0,
                                            child: SpinKitPulse(
                                              color: theme.colorScheme.primary,
                                              size: 44.0,
                                            ),
                                          ),
                                        );
                                      }
                                      List<PiattiRecord> listViewPiattiRecordList =
                                          snapshot.data!;

                                      return ListView.separated(
                                        padding: EdgeInsets.zero,
                                        shrinkWrap: true,
                                        scrollDirection: Axis.vertical,
                                        itemCount: listViewPiattiRecordList.length,
                                        separatorBuilder: (context, index) =>
                                            const SizedBox(height: 10.0),
                                        itemBuilder: (context, listViewIndex) {
                                          final piatto =
                                              listViewPiattiRecordList[listViewIndex];
                                          return _buildDishItem(
                                            context: context,
                                            piatto: piatto,
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),

                      // Colonna Destra (Pannello Modifica animato)
                      if (showSplitView)
                        Expanded(
                          flex: 6,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16.0, 15.0, 16.0, 30.0),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              switchInCurve: Curves.easeOutCubic,
                              switchOutCurve: Curves.easeInCubic,
                              transitionBuilder: (child, animation) {
                                final slideAnimation = Tween<Offset>(
                                  begin: const Offset(0.08, 0.0),
                                  end: Offset.zero,
                                ).animate(animation);
                                return FadeTransition(
                                  opacity: animation,
                                  child: SlideTransition(
                                    position: slideAnimation,
                                    child: child,
                                  ),
                                );
                              },
                              child: PannelloModificaPiattoWidget(
                                key: ValueKey(_piattoInModifica!.reference.id),
                                piatto: _piattoInModifica!,
                                categoriaRef: widget.categoriaAttuale!,
                                ristoranteRef: widget.ristoranteRef,
                                onClose: () {
                                  safeSetState(() {
                                    _piattoInModifica = null;
                                  });
                                },
                                onSaved: (piattoAggiornato) {
                                  safeSetState(() {
                                    _piattoInModifica = piattoAggiornato;
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
