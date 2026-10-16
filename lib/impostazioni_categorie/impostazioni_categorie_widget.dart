import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/custom_code/actions/index.dart' as actions;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'impostazioni_categorie_model.dart';
export 'impostazioni_categorie_model.dart';

class ImpostazioniCategorieWidget extends StatefulWidget {
  const ImpostazioniCategorieWidget({super.key});

  static String routeName = 'ImpostazioniCategorie';
  static String routePath = '/impostazioniCategorie';

  @override
  State<ImpostazioniCategorieWidget> createState() =>
      _ImpostazioniCategorieWidgetState();
}

class _ImpostazioniCategorieWidgetState
    extends State<ImpostazioniCategorieWidget> {
  late ImpostazioniCategorieModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ImpostazioniCategorieModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      _model.categorieTrovate = await queryCategoriesRecordOnce(
        queryBuilder: (categoriesRecord) => categoriesRecord
            .where(
              'proprietario',
              isEqualTo: currentUserReference,
            )
            .orderBy('ordine_categoria'),
      );
      _model.listaCategorie =
          _model.categorieTrovate!.toList().cast<CategoriesRecord>();
      safeSetState(() {});
    });

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
                  Icons.format_list_bulleted_rounded,
                  color: theme.colorScheme.primary,
                  size: 20.0,
                ),
              ),
              const SizedBox(width: 10.0),
              Text(
                'Ordina categorie',
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
        ),
        body: SafeArea(
          top: true,
          child: SingleChildScrollView(
            controller: _model.columnController,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 0.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.info_outlined,
                        size: 14.0,
                        color: theme.textTheme.bodySmall?.color,
                      ),
                      SizedBox(width: 4.0),
                      Text(
                        'Tieni premuto e sposta le categorie nell\'ordine che preferisci',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 20.0),
                  child: Builder(
                    builder: (context) {
                      final categoriaItem = _model.listaCategorie.toList();

                      return ReorderableListView.builder(
                        padding: EdgeInsets.zero,
                        proxyDecorator: (Widget child, int index,
                                Animation<double> animation) =>
                            Material(color: Colors.transparent, child: child),
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        itemCount: categoriaItem.length,
                        itemBuilder: (context, categoriaItemIndex) {
                          final categoriaItemItem =
                              categoriaItem[categoriaItemIndex];
                          return Container(
                            key: ValueKey("ListView_u3nc8y85" +
                                '_' +
                                categoriaItemIndex.toString()),
                            child: Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  0.0, 0.0, 0.0, 8.0),
                              child: Container(
                                width: double.infinity,
                                height: 60.0,
                                decoration: BoxDecoration(
                                  color: theme.cardColor,
                                  borderRadius: BorderRadius.circular(12.0),
                                  border: Border.all(
                                    color: theme.dividerColor.withValues(alpha: 0.1),
                                  ),
                                ),
                                alignment: AlignmentDirectional(0.0, 0.0),
                                child: Text(
                                  categoriaItemItem.name,
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                        onReorder: (int reorderableOldIndex,
                            int reorderableNewIndex) async {
                          _model.listaAggiornata = await actions.riordinaLista(
                            _model.listaCategorie.toList(),
                            reorderableOldIndex,
                            reorderableNewIndex,
                          );
                          _model.listaCategorie = _model.listaAggiornata!
                              .toList()
                              .cast<CategoriesRecord>();
                          safeSetState(() {});

                          safeSetState(() {});
                        },
                      );
                    },
                  ),
                ),
                FFButtonWidget(
                  onPressed: () async {
                    await actions.salvaOrdineCategorie(
                      _model.listaCategorie.map((e) => e.reference).toList(),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Ordine salvato con successo!',
                        ),
                        duration: Duration(milliseconds: 4000),
                      ),
                    );
                  },
                  text: 'Salva Ordine',
                  options: FFButtonOptions(
                    height: 44.0,
                    padding:
                        EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
                    iconPadding:
                        EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                    elevation: 0.0,
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
