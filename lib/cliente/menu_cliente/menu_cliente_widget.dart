import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/cliente/comp_carrello/comp_carrello_widget.dart';
import '/cliente/dettagli_piatto_popup/dettagli_piatto_popup_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/index.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';
import 'menu_cliente_model.dart';
export 'menu_cliente_model.dart';

/// il menu che vede il cliente
class MenuClienteWidget extends StatefulWidget {
  const MenuClienteWidget({
    super.key,
    required this.ristoranteRef,
  });

  final DocumentReference? ristoranteRef;

  static String routeName = 'MenuCliente';
  static String routePath = '/MenuCliente';

  @override
  State<MenuClienteWidget> createState() => _MenuClienteWidgetState();
}

class _MenuClienteWidgetState extends State<MenuClienteWidget> {
  late MenuClienteModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MenuClienteModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      FFAppState().ristoranteSalvato = widget!.ristoranteRef;
      safeSetState(() {});
      _model.datiRistorante =
          await UsersRecord.getDocumentOnce(FFAppState().ristoranteSalvato!);
      if (_model.datiRistorante?.temaScelto == 'AmethystSlatelight') {
        FFAppState().temaPrimary = Color(0xFF4B0082);
        FFAppState().temaSecondary = Color(0xFF008080);
        FFAppState().temaTertiary = Color(0xFFFFD700);
        FFAppState().temaAlternate = Color(0xFF800080);
        FFAppState().temaPrimaryBackground = Color(0xFFE5E4E2);
        FFAppState().temaSecondaryBackground = Color(0xFFF5F5F5);
        FFAppState().temaPrimaryText = Color(0xFF1C1C1C);
        FFAppState().temaSecondaryText = Color(0xFF666666);
        FFAppState().temaAccent1 = Color(0x344B0082);
        FFAppState().temaAccent2 = Color(0xFFE0E0E0);
        FFAppState().temaAccent3 = Colors.white;
        FFAppState().temaAccent4 = Color(0xFF310055);
        FFAppState().temaSuccess = Color(0xFF228B22);
        FFAppState().temaError = Color(0xFFB00020);
        FFAppState().temaWarning = Color(0xFFFF8C00);
        FFAppState().temaInfo = Color(0xFF4169E1);
        safeSetState(() {});
        setDarkModeSetting(context, ThemeMode.light);
      } else {
        if (_model.datiRistorante?.temaScelto == 'ProntoMenudark') {
          FFAppState().temaPrimary = Color(0xFF21493D);
          FFAppState().temaSecondary = Color(0xFF8E7C6C);
          FFAppState().temaTertiary = Color(0xFF782329);
          FFAppState().temaAlternate = Color(0xFFF2ECE4);
          FFAppState().temaPrimaryBackground = Color(0xFF121212);
          FFAppState().temaSecondaryBackground = Color(0xFF1E1E1E);
          FFAppState().temaPrimaryText = Color(0xFFFDF6ED);
          FFAppState().temaSecondaryText = Color(0xFFC1B4AB);
          FFAppState().temaAccent1 = Color(0xFF367160);
          FFAppState().temaAccent2 = Color(0x33A6343C);
          FFAppState().temaAccent3 = Color(0xFFC03C46);
          FFAppState().temaAccent4 = Color(0xFF6F9CEF);
          FFAppState().temaSuccess = Color(0xFF11C694);
          FFAppState().temaError = Color(0xFFF75A60);
          FFAppState().temaWarning = Color(0xFFFFB84D);
          FFAppState().temaInfo = Color(0xFF6F9CEF);
          safeSetState(() {});
          setDarkModeSetting(context, ThemeMode.dark);
        } else {
          if (_model.datiRistorante?.temaScelto == 'AmethystSlatedark') {
            FFAppState().temaPrimary = Color(0xFFBB86FC);
            FFAppState().temaSecondary = Color(0xFF03DAC6);
            FFAppState().temaTertiary = Color(0xFFFFD700);
            FFAppState().temaAlternate = Color(0xFF9932CC);
            FFAppState().temaPrimaryBackground = Color(0xFF121212);
            FFAppState().temaSecondaryBackground = Color(0xFF1E1E1E);
            FFAppState().temaPrimaryText = Colors.white;
            FFAppState().temaSecondaryText = Color(0xFFA0A0A0);
            FFAppState().temaAccent1 = Color(0x25BB86FC);
            FFAppState().temaAccent2 = Color(0xFFE0E0E0);
            FFAppState().temaAccent3 = Color(0xFF2C2C2C);
            FFAppState().temaAccent4 = Color(0xFFD1A3FF);
            FFAppState().temaSuccess = Color(0xFF81C784);
            FFAppState().temaError = Color(0xFFCF6679);
            FFAppState().temaWarning = Color(0xFFFFB74D);
            FFAppState().temaInfo = Color(0xFF64B5F6);
            safeSetState(() {});
            setDarkModeSetting(context, ThemeMode.dark);
          } else {
            FFAppState().temaPrimary = Color(0xFF2C5E4F);
            FFAppState().temaSecondary = Color(0xFFD8CAB7);
            FFAppState().temaTertiary = Color(0xFFA6343C);
            FFAppState().temaAlternate = Color(0xFF333333);
            FFAppState().temaPrimaryBackground = Color(0xFFFFFAF5);
            FFAppState().temaSecondaryBackground = Color(0xFFF1E8DC);
            FFAppState().temaPrimaryText = Color(0xFF413F3E);
            FFAppState().temaSecondaryText = Color(0xFFA59D96);
            FFAppState().temaAccent1 = Color(0x322C5E4F);
            FFAppState().temaAccent2 = Color(0x33A6343C);
            FFAppState().temaAccent3 = Color(0x34D8CAB7);
            FFAppState().temaAccent4 = Color(0xFF4F85E0);
            FFAppState().temaSuccess = Color(0xFF0B9F74);
            FFAppState().temaError = Color(0xFFF8464C);
            FFAppState().temaWarning = Color(0xFFFFA926);
            FFAppState().temaInfo = Color(0xFF4F85E0);
            safeSetState(() {});
            setDarkModeSetting(context, ThemeMode.light);
          }
        }
      }

      if (currentUserUid != null && currentUserUid != '') {
        context.pushNamed(
          HomeRistoratoreWidget.routeName,
          queryParameters: {
            'ristoranteRef': serializeParam(
              widget!.ristoranteRef,
              ParamType.DocumentReference,
            ),
          }.withoutNulls,
        );
      }
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

    return StreamBuilder<UsersRecord>(
      stream: UsersRecord.getDocument(widget!.ristoranteRef!),
      builder: (context, snapshot) {
        // Customize what your widget looks like when it's loading.
        if (!snapshot.hasData) {
          return Scaffold(
            backgroundColor: FFAppState().temaPrimaryBackground,
            body: Center(
              child: SizedBox(
                width: 50.0,
                height: 50.0,
                child: SpinKitPulse(
                  color: FlutterFlowTheme.of(context).primary,
                  size: 50.0,
                ),
              ),
            ),
          );
        }

        final menuClienteUsersRecord = snapshot.data!;

        return GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Scaffold(
            key: scaffoldKey,
            backgroundColor: FFAppState().temaPrimaryBackground,
            appBar: AppBar(
              backgroundColor: FFAppState().temaSecondary,
              automaticallyImplyLeading: false,
              actions: [],
              flexibleSpace: FlexibleSpaceBar(
                title: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      width: 45.0,
                      decoration: BoxDecoration(
                        color: FFAppState().temaSecondaryBackground,
                      ),
                    ),
                    Text(
                      'Categoria',
                      textAlign: TextAlign.center,
                      style:
                          FlutterFlowTheme.of(context).headlineSmall.override(
                                font: GoogleFonts.outfit(
                                  fontWeight: FontWeight.w600,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .headlineSmall
                                      .fontStyle,
                                ),
                                color: FFAppState().temaPrimaryText,
                                fontSize: 22.0,
                                letterSpacing: 0.0,
                                fontWeight: FontWeight.w600,
                                fontStyle: FlutterFlowTheme.of(context)
                                    .headlineSmall
                                    .fontStyle,
                              ),
                    ),
                    InkWell(
                      splashColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () async {
                        context.pushNamed(
                          RiepilogoFinaleWidget.routeName,
                          queryParameters: {
                            'ristoranteRef': serializeParam(
                              widget!.ristoranteRef,
                              ParamType.DocumentReference,
                            ),
                          }.withoutNulls,
                        );
                      },
                      child: wrapWithModel(
                        model: _model.compCarrelloModel,
                        updateCallback: () => safeSetState(() {}),
                        child: CompCarrelloWidget(),
                      ),
                    ),
                  ],
                ),
                centerTitle: true,
                expandedTitleScale: 1.0,
              ),
              elevation: 2.0,
            ),
            body: SafeArea(
              top: true,
              child: FutureBuilder<int>(
                future: querySottocategorieRecordCount(
                  queryBuilder: (sottocategorieRecord) => sottocategorieRecord
                      .where(
                        'categoria_padre_ref',
                        isEqualTo: _model.categoriaSelezionataRef,
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
                          color: FlutterFlowTheme.of(context).primary,
                          size: 50.0,
                        ),
                      ),
                    );
                  }
                  int columnCount = snapshot.data!;

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 60.0,
                        decoration: BoxDecoration(
                          color: FFAppState().temaPrimaryBackground,
                        ),
                        child: StreamBuilder<List<CategoriesRecord>>(
                          stream: queryCategoriesRecord(
                            queryBuilder: (categoriesRecord) => categoriesRecord
                                .where(
                                  'proprietario',
                                  isEqualTo: widget!.ristoranteRef,
                                )
                                .orderBy('ordine_categoria'),
                          ),
                          builder: (context, snapshot) {
                            // Customize what your widget looks like when it's loading.
                            if (!snapshot.hasData) {
                              return Center(
                                child: SizedBox(
                                  width: 50.0,
                                  height: 50.0,
                                  child: SpinKitPulse(
                                    color: FlutterFlowTheme.of(context).primary,
                                    size: 50.0,
                                  ),
                                ),
                              );
                            }
                            List<CategoriesRecord>
                                listViewCategoriesRecordList = snapshot.data!;

                            return ListView.builder(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              itemCount: listViewCategoriesRecordList.length,
                              itemBuilder: (context, listViewIndex) {
                                final listViewCategoriesRecord =
                                    listViewCategoriesRecordList[listViewIndex];
                                return Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      16.0, 10.0, 16.0, 10.0),
                                  child: InkWell(
                                    splashColor: Colors.transparent,
                                    focusColor: Colors.transparent,
                                    hoverColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    onTap: () async {
                                      _model.sottocategoriaSelezionata = null;
                                      safeSetState(() {});
                                      if (_model.categoriaSelezionataRef ==
                                          listViewCategoriesRecord.reference) {
                                        _model.categoriaSelezionataRef = null;
                                        _model.categoriaSelezionata = null;
                                        safeSetState(() {});
                                      } else {
                                        _model.categoriaSelezionataRef =
                                            listViewCategoriesRecord.reference;
                                        _model.categoriaSelezionata =
                                            listViewCategoriesRecord
                                                .reference.id;
                                        safeSetState(() {});
                                      }
                                    },
                                    child: Material(
                                      color: Colors.transparent,
                                      elevation: 2.0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                      ),
                                      child: Container(
                                        height: 50.0,
                                        constraints: BoxConstraints(
                                          minWidth: 100.0,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _model.categoriaSelezionata ==
                                                  listViewCategoriesRecord
                                                      .reference.id
                                              ? FFAppState().temaPrimary
                                              : FFAppState()
                                                  .temaSecondaryBackground,
                                          borderRadius:
                                              BorderRadius.circular(12.0),
                                        ),
                                        alignment:
                                            AlignmentDirectional(0.0, 0.0),
                                        child: Text(
                                          listViewCategoriesRecord.name,
                                          maxLines: 1,
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                font: GoogleFonts.openSans(
                                                  fontWeight: FontWeight.bold,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontStyle,
                                                ),
                                                color: _model
                                                            .categoriaSelezionata ==
                                                        listViewCategoriesRecord
                                                            .reference.id
                                                    ? FFAppState()
                                                        .temaPrimaryBackground
                                                    : FFAppState()
                                                        .temaSecondaryText,
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.bold,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontStyle,
                                              ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                      if ((_model.categoriaSelezionataRef != null) &&
                          (columnCount > 0))
                        Container(
                          width: double.infinity,
                          height: 60.0,
                          decoration: BoxDecoration(
                            color: FFAppState().temaSecondaryBackground,
                          ),
                          child: StreamBuilder<List<SottocategorieRecord>>(
                            stream: querySottocategorieRecord(
                              queryBuilder: (sottocategorieRecord) =>
                                  sottocategorieRecord
                                      .where(
                                        'categoria_padre_ref',
                                        isEqualTo:
                                            _model.categoriaSelezionataRef,
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
                                      color:
                                          FlutterFlowTheme.of(context).primary,
                                      size: 50.0,
                                    ),
                                  ),
                                );
                              }
                              List<SottocategorieRecord>
                                  listViewSottocategorieRecordList =
                                  snapshot.data!;

                              return ListView.builder(
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                                itemCount:
                                    listViewSottocategorieRecordList.length,
                                itemBuilder: (context, listViewIndex) {
                                  final listViewSottocategorieRecord =
                                      listViewSottocategorieRecordList[
                                          listViewIndex];
                                  return Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        16.0, 10.0, 16.0, 10.0),
                                    child: InkWell(
                                      splashColor: Colors.transparent,
                                      focusColor: Colors.transparent,
                                      hoverColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      onTap: () async {
                                        if (_model.sottocategoriaSelezionata ==
                                            listViewSottocategorieRecord
                                                .reference) {
                                          _model.sottocategoriaSelezionata =
                                              null;
                                          safeSetState(() {});
                                        } else {
                                          _model.sottocategoriaSelezionata =
                                              listViewSottocategorieRecord
                                                  .reference;
                                          safeSetState(() {});
                                        }
                                      },
                                      child: Material(
                                        color: Colors.transparent,
                                        elevation: 2.0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12.0),
                                        ),
                                        child: Container(
                                          height: 50.0,
                                          constraints: BoxConstraints(
                                            minWidth: 100.0,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _model
                                                        .sottocategoriaSelezionata ==
                                                    listViewSottocategorieRecord
                                                        .reference
                                                ? FFAppState().temaPrimary
                                                : FFAppState()
                                                    .temaPrimaryBackground,
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                          ),
                                          alignment:
                                              AlignmentDirectional(0.0, 0.0),
                                          child: Text(
                                            listViewSottocategorieRecord.nome,
                                            maxLines: 1,
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  font: GoogleFonts.openSans(
                                                    fontWeight: FontWeight.bold,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodyMedium
                                                            .fontStyle,
                                                  ),
                                                  color: _model
                                                              .sottocategoriaSelezionata ==
                                                          listViewSottocategorieRecord
                                                              .reference
                                                      ? FFAppState()
                                                          .temaPrimaryBackground
                                                      : FFAppState()
                                                          .temaSecondaryText,
                                                  letterSpacing: 0.0,
                                                  fontWeight: FontWeight.bold,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontStyle,
                                                ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      if ((menuClienteUsersRecord.ordinePreferito == 'A - Z') &&
                          (_model.categoriaSelezionata != null &&
                              _model.categoriaSelezionata != ''))
                        Expanded(
                          child: Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 30.0, 0.0, 80.0),
                            child: StreamBuilder<List<PiattiRecord>>(
                              stream: queryPiattiRecord(
                                queryBuilder: (piattiRecord) => piattiRecord
                                    .where(
                                      'proprietario',
                                      isEqualTo: widget!.ristoranteRef,
                                    )
                                    .where(
                                      'isCestinato',
                                      isEqualTo: false,
                                    )
                                    .where(
                                      'sottocategoria_ref',
                                      isEqualTo:
                                          _model.sottocategoriaSelezionata,
                                    )
                                    .where(
                                      'Categoria',
                                      isEqualTo:
                                          _model.categoriaSelezionata != ''
                                              ? _model.categoriaSelezionata
                                              : null,
                                    )
                                    .orderBy('Nome'),
                              ),
                              builder: (context, snapshot) {
                                // Customize what your widget looks like when it's loading.
                                if (!snapshot.hasData) {
                                  return Center(
                                    child: SizedBox(
                                      width: 50.0,
                                      height: 50.0,
                                      child: SpinKitPulse(
                                        color: FlutterFlowTheme.of(context)
                                            .primary,
                                        size: 50.0,
                                      ),
                                    ),
                                  );
                                }
                                List<PiattiRecord>
                                    listViewNomePiattiRecordList =
                                    snapshot.data!;

                                return ListView.builder(
                                  padding: EdgeInsets.zero,
                                  shrinkWrap: true,
                                  scrollDirection: Axis.vertical,
                                  itemCount:
                                      listViewNomePiattiRecordList.length,
                                  itemBuilder: (context, listViewNomeIndex) {
                                    final listViewNomePiattiRecord =
                                        listViewNomePiattiRecordList[
                                            listViewNomeIndex];
                                    return Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          10.0, 10.0, 10.0, 10.0),
                                      child: InkWell(
                                        splashColor: Colors.transparent,
                                        focusColor: Colors.transparent,
                                        hoverColor: Colors.transparent,
                                        highlightColor: Colors.transparent,
                                        onTap: () async {
                                          await showModalBottomSheet(
                                            isScrollControlled: true,
                                            backgroundColor: Colors.transparent,
                                            context: context,
                                            builder: (context) {
                                              return GestureDetector(
                                                onTap: () {
                                                  FocusScope.of(context)
                                                      .unfocus();
                                                  FocusManager
                                                      .instance.primaryFocus
                                                      ?.unfocus();
                                                },
                                                child: Padding(
                                                  padding:
                                                      MediaQuery.viewInsetsOf(
                                                          context),
                                                  child:
                                                      DettagliPiattoPopupWidget(
                                                    piattoSelezionato:
                                                        listViewNomePiattiRecord,
                                                  ),
                                                ),
                                              );
                                            },
                                          ).then(
                                              (value) => safeSetState(() {}));
                                        },
                                        child: Material(
                                          color: Colors.transparent,
                                          elevation: 2.0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                          ),
                                          child: Container(
                                            width: MediaQuery.sizeOf(context)
                                                    .width *
                                                1.0,
                                            height: 70.0,
                                            decoration: BoxDecoration(
                                              color: FFAppState()
                                                  .temaSecondaryBackground,
                                              borderRadius:
                                                  BorderRadius.circular(12.0),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.stretch,
                                              children: [
                                                if (listViewNomePiattiRecord
                                                            .foto !=
                                                        null &&
                                                    listViewNomePiattiRecord
                                                            .foto !=
                                                        '')
                                                  Align(
                                                    alignment:
                                                        AlignmentDirectional(
                                                            0.0, 0.0),
                                                    child: Container(
                                                      width: 60.0,
                                                      height: 60.0,
                                                      child: Stack(
                                                        children: [
                                                          Align(
                                                            alignment:
                                                                AlignmentDirectional(
                                                                    0.0, 0.0),
                                                            child:
                                                                CircularPercentIndicator(
                                                              percent: 1.0,
                                                              radius: 25.0,
                                                              lineWidth: 12.0,
                                                              animation: true,
                                                              animateFromLastPercent:
                                                                  true,
                                                              progressColor:
                                                                  FFAppState()
                                                                      .temaPrimary,
                                                              backgroundColor:
                                                                  FFAppState()
                                                                      .temaSecondary,
                                                            ),
                                                          ),
                                                          ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        12.0),
                                                            child:
                                                                Image.network(
                                                              valueOrDefault<
                                                                  String>(
                                                                listViewNomePiattiRecord
                                                                    .foto,
                                                                'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/pronto-menu-f0och1/assets/2n9hc9ugo68c/Immagine_standard.png',
                                                              ),
                                                              width: 60.0,
                                                              height: 60.0,
                                                              fit: BoxFit.cover,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                Expanded(
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            EdgeInsetsDirectional
                                                                .fromSTEB(
                                                                    10.0,
                                                                    0.0,
                                                                    0.0,
                                                                    0.0),
                                                        child: Text(
                                                          listViewNomePiattiRecord
                                                              .nome,
                                                          maxLines: 1,
                                                          style: FlutterFlowTheme
                                                                  .of(context)
                                                              .bodyMedium
                                                              .override(
                                                                font: GoogleFonts
                                                                    .openSans(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .fontStyle,
                                                                ),
                                                                color: FFAppState()
                                                                    .temaPrimaryText,
                                                                fontSize: 18.0,
                                                                letterSpacing:
                                                                    0.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontStyle: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontStyle,
                                                              ),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            EdgeInsetsDirectional
                                                                .fromSTEB(
                                                                    12.0,
                                                                    0.0,
                                                                    0.0,
                                                                    0.0),
                                                        child: Text(
                                                          listViewNomePiattiRecord
                                                              .ingredienti,
                                                          maxLines: 2,
                                                          style: FlutterFlowTheme
                                                                  .of(context)
                                                              .bodyMedium
                                                              .override(
                                                                font: GoogleFonts
                                                                    .openSans(
                                                                  fontWeight: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .fontWeight,
                                                                  fontStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .fontStyle,
                                                                ),
                                                                color: FFAppState()
                                                                    .temaSecondaryText,
                                                                fontSize: 12.0,
                                                                letterSpacing:
                                                                    0.0,
                                                                fontWeight: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontWeight,
                                                                fontStyle: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontStyle,
                                                              ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  children: [
                                                    SizedBox(
                                                      height: 50.0,
                                                      child: VerticalDivider(
                                                        thickness: 1.0,
                                                        color: FFAppState()
                                                            .temaAlternate,
                                                      ),
                                                    ),
                                                    Container(
                                                      width: 70.0,
                                                      decoration:
                                                          BoxDecoration(),
                                                      child: Padding(
                                                        padding:
                                                            EdgeInsetsDirectional
                                                                .fromSTEB(
                                                                    0.0,
                                                                    0.0,
                                                                    8.0,
                                                                    0.0),
                                                        child: Text(
                                                          formatNumber(
                                                            listViewNomePiattiRecord
                                                                .prezzo,
                                                            formatType:
                                                                FormatType
                                                                    .decimal,
                                                            decimalType:
                                                                DecimalType
                                                                    .periodDecimal,
                                                            currency: '€',
                                                          ),
                                                          textAlign:
                                                              TextAlign.end,
                                                          style: FlutterFlowTheme
                                                                  .of(context)
                                                              .bodyMedium
                                                              .override(
                                                                font: GoogleFonts
                                                                    .openSans(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  fontStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .fontStyle,
                                                                ),
                                                                color: FFAppState()
                                                                    .temaSecondaryText,
                                                                letterSpacing:
                                                                    0.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                fontStyle: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontStyle,
                                                              ),
                                                        ),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  0.0,
                                                                  0.0,
                                                                  5.0,
                                                                  0.0),
                                                      child:
                                                          FlutterFlowIconButton(
                                                        borderRadius: 25.0,
                                                        buttonSize: 40.0,
                                                        fillColor: FFAppState()
                                                            .temaPrimary,
                                                        icon: FaIcon(
                                                          FontAwesomeIcons.plus,
                                                          color: FFAppState()
                                                              .temaPrimaryBackground,
                                                          size: 20.0,
                                                        ),
                                                        onPressed: () async {
                                                          FFAppState().addToCarrello(
                                                              listViewNomePiattiRecord
                                                                  .reference);
                                                          safeSetState(() {});
                                                          FFAppState()
                                                                  .totaleCarrello =
                                                              FFAppState()
                                                                      .totaleCarrello +
                                                                  listViewNomePiattiRecord
                                                                      .prezzo;
                                                          safeSetState(() {});
                                                          FFAppState()
                                                              .addToCarrelloNomi(
                                                                  listViewNomePiattiRecord
                                                                      .nome);
                                                          safeSetState(() {});
                                                        },
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                      if ((menuClienteUsersRecord.ordinePreferito ==
                              'Prezzo') &&
                          (_model.categoriaSelezionata != null &&
                              _model.categoriaSelezionata != ''))
                        Expanded(
                          child: Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 30.0, 0.0, 80.0),
                            child: StreamBuilder<List<PiattiRecord>>(
                              stream: queryPiattiRecord(
                                queryBuilder: (piattiRecord) => piattiRecord
                                    .where(
                                      'proprietario',
                                      isEqualTo: widget!.ristoranteRef,
                                    )
                                    .where(
                                      'isCestinato',
                                      isEqualTo: false,
                                    )
                                    .where(
                                      'sottocategoria_ref',
                                      isEqualTo:
                                          _model.sottocategoriaSelezionata,
                                    )
                                    .where(
                                      'Categoria',
                                      isEqualTo:
                                          _model.categoriaSelezionata != ''
                                              ? _model.categoriaSelezionata
                                              : null,
                                    )
                                    .orderBy('Prezzo'),
                              ),
                              builder: (context, snapshot) {
                                // Customize what your widget looks like when it's loading.
                                if (!snapshot.hasData) {
                                  return Center(
                                    child: SizedBox(
                                      width: 50.0,
                                      height: 50.0,
                                      child: SpinKitPulse(
                                        color: FlutterFlowTheme.of(context)
                                            .primary,
                                        size: 50.0,
                                      ),
                                    ),
                                  );
                                }
                                List<PiattiRecord>
                                    listViewPrezzoPiattiRecordList =
                                    snapshot.data!;

                                return ListView.builder(
                                  padding: EdgeInsets.zero,
                                  shrinkWrap: true,
                                  scrollDirection: Axis.vertical,
                                  itemCount:
                                      listViewPrezzoPiattiRecordList.length,
                                  itemBuilder: (context, listViewPrezzoIndex) {
                                    final listViewPrezzoPiattiRecord =
                                        listViewPrezzoPiattiRecordList[
                                            listViewPrezzoIndex];
                                    return Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          10.0, 10.0, 10.0, 10.0),
                                      child: InkWell(
                                        splashColor: Colors.transparent,
                                        focusColor: Colors.transparent,
                                        hoverColor: Colors.transparent,
                                        highlightColor: Colors.transparent,
                                        onTap: () async {
                                          await showModalBottomSheet(
                                            isScrollControlled: true,
                                            backgroundColor: Colors.transparent,
                                            context: context,
                                            builder: (context) {
                                              return GestureDetector(
                                                onTap: () {
                                                  FocusScope.of(context)
                                                      .unfocus();
                                                  FocusManager
                                                      .instance.primaryFocus
                                                      ?.unfocus();
                                                },
                                                child: Padding(
                                                  padding:
                                                      MediaQuery.viewInsetsOf(
                                                          context),
                                                  child:
                                                      DettagliPiattoPopupWidget(
                                                    piattoSelezionato:
                                                        listViewPrezzoPiattiRecord,
                                                  ),
                                                ),
                                              );
                                            },
                                          ).then(
                                              (value) => safeSetState(() {}));
                                        },
                                        child: Material(
                                          color: Colors.transparent,
                                          elevation: 2.0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                          ),
                                          child: Container(
                                            width: MediaQuery.sizeOf(context)
                                                    .width *
                                                1.0,
                                            height: 70.0,
                                            decoration: BoxDecoration(
                                              color: FFAppState()
                                                  .temaSecondaryBackground,
                                              borderRadius:
                                                  BorderRadius.circular(12.0),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.stretch,
                                              children: [
                                                if (listViewPrezzoPiattiRecord
                                                            .foto !=
                                                        null &&
                                                    listViewPrezzoPiattiRecord
                                                            .foto !=
                                                        '')
                                                  Align(
                                                    alignment:
                                                        AlignmentDirectional(
                                                            0.0, 0.0),
                                                    child: Container(
                                                      width: 60.0,
                                                      height: 60.0,
                                                      child: Stack(
                                                        children: [
                                                          Align(
                                                            alignment:
                                                                AlignmentDirectional(
                                                                    0.0, 0.0),
                                                            child:
                                                                CircularPercentIndicator(
                                                              percent: 1.0,
                                                              radius: 25.0,
                                                              lineWidth: 12.0,
                                                              animation: true,
                                                              animateFromLastPercent:
                                                                  true,
                                                              progressColor:
                                                                  FFAppState()
                                                                      .temaPrimary,
                                                              backgroundColor:
                                                                  FFAppState()
                                                                      .temaSecondary,
                                                            ),
                                                          ),
                                                          ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        12.0),
                                                            child:
                                                                Image.network(
                                                              valueOrDefault<
                                                                  String>(
                                                                listViewPrezzoPiattiRecord
                                                                    .foto,
                                                                'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/pronto-menu-f0och1/assets/2n9hc9ugo68c/Immagine_standard.png',
                                                              ),
                                                              width: 60.0,
                                                              height: 60.0,
                                                              fit: BoxFit.cover,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                Expanded(
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            EdgeInsetsDirectional
                                                                .fromSTEB(
                                                                    10.0,
                                                                    0.0,
                                                                    0.0,
                                                                    0.0),
                                                        child: Text(
                                                          listViewPrezzoPiattiRecord
                                                              .nome,
                                                          maxLines: 1,
                                                          style: FlutterFlowTheme
                                                                  .of(context)
                                                              .bodyMedium
                                                              .override(
                                                                font: GoogleFonts
                                                                    .openSans(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .fontStyle,
                                                                ),
                                                                color: FFAppState()
                                                                    .temaPrimaryText,
                                                                fontSize: 18.0,
                                                                letterSpacing:
                                                                    0.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontStyle: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontStyle,
                                                              ),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            EdgeInsetsDirectional
                                                                .fromSTEB(
                                                                    12.0,
                                                                    0.0,
                                                                    0.0,
                                                                    0.0),
                                                        child: Text(
                                                          listViewPrezzoPiattiRecord
                                                              .ingredienti,
                                                          maxLines: 2,
                                                          style: FlutterFlowTheme
                                                                  .of(context)
                                                              .bodyMedium
                                                              .override(
                                                                font: GoogleFonts
                                                                    .openSans(
                                                                  fontWeight: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .fontWeight,
                                                                  fontStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .fontStyle,
                                                                ),
                                                                color: FFAppState()
                                                                    .temaSecondaryText,
                                                                fontSize: 12.0,
                                                                letterSpacing:
                                                                    0.0,
                                                                fontWeight: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontWeight,
                                                                fontStyle: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontStyle,
                                                              ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  children: [
                                                    SizedBox(
                                                      height: 50.0,
                                                      child: VerticalDivider(
                                                        thickness: 1.0,
                                                        color: FFAppState()
                                                            .temaAlternate,
                                                      ),
                                                    ),
                                                    Container(
                                                      width: 70.0,
                                                      decoration:
                                                          BoxDecoration(),
                                                      child: Padding(
                                                        padding:
                                                            EdgeInsetsDirectional
                                                                .fromSTEB(
                                                                    0.0,
                                                                    0.0,
                                                                    8.0,
                                                                    0.0),
                                                        child: Text(
                                                          formatNumber(
                                                            listViewPrezzoPiattiRecord
                                                                .prezzo,
                                                            formatType:
                                                                FormatType
                                                                    .decimal,
                                                            decimalType:
                                                                DecimalType
                                                                    .periodDecimal,
                                                            currency: '€',
                                                          ),
                                                          textAlign:
                                                              TextAlign.end,
                                                          style: FlutterFlowTheme
                                                                  .of(context)
                                                              .bodyMedium
                                                              .override(
                                                                font: GoogleFonts
                                                                    .openSans(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  fontStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .fontStyle,
                                                                ),
                                                                color: FFAppState()
                                                                    .temaSecondaryText,
                                                                letterSpacing:
                                                                    0.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                fontStyle: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontStyle,
                                                              ),
                                                        ),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  0.0,
                                                                  0.0,
                                                                  5.0,
                                                                  0.0),
                                                      child:
                                                          FlutterFlowIconButton(
                                                        borderRadius: 25.0,
                                                        buttonSize: 40.0,
                                                        fillColor: FFAppState()
                                                            .temaPrimary,
                                                        icon: FaIcon(
                                                          FontAwesomeIcons.plus,
                                                          color: FFAppState()
                                                              .temaPrimaryBackground,
                                                          size: 20.0,
                                                        ),
                                                        onPressed: () async {
                                                          FFAppState().addToCarrello(
                                                              listViewPrezzoPiattiRecord
                                                                  .reference);
                                                          safeSetState(() {});
                                                          FFAppState()
                                                                  .totaleCarrello =
                                                              FFAppState()
                                                                      .totaleCarrello +
                                                                  listViewPrezzoPiattiRecord
                                                                      .prezzo;
                                                          safeSetState(() {});
                                                          FFAppState()
                                                              .addToCarrelloNomi(
                                                                  listViewPrezzoPiattiRecord
                                                                      .nome);
                                                          safeSetState(() {});
                                                        },
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                      if (_model.categoriaSelezionata == null ||
                          _model.categoriaSelezionata == '')
                        Container(
                          decoration: BoxDecoration(),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Scegli una categoria qui in alto \nper scoprire i nostri piatti!',
                                textAlign: TextAlign.center,
                                style: FlutterFlowTheme.of(context)
                                    .titleMedium
                                    .override(
                                      font: GoogleFonts.outfit(
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .titleMedium
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .titleMedium
                                            .fontStyle,
                                      ),
                                      color: FFAppState().temaPrimary,
                                      letterSpacing: 0.0,
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .titleMedium
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .titleMedium
                                          .fontStyle,
                                    ),
                              ),
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    20.0, 0.0, 0.0, 0.0),
                                child: FaIcon(
                                  FontAwesomeIcons.arrowUp,
                                  color: FFAppState().temaPrimary,
                                  size: 24.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
