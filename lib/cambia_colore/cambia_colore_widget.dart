import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'cambia_colore_model.dart';
export 'cambia_colore_model.dart';

class CambiaColoreWidget extends StatefulWidget {
  const CambiaColoreWidget({
    super.key,
    this.ristoranteRef,
  });

  final DocumentReference? ristoranteRef;

  static String routeName = 'cambiaColore';
  static String routePath = '/cambiaColore';

  @override
  State<CambiaColoreWidget> createState() => _CambiaColoreWidgetState();
}

class _CambiaColoreWidgetState extends State<CambiaColoreWidget> {
  late CambiaColoreModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CambiaColoreModel());

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
          leading: FlutterFlowIconButton(
            borderColor: Colors.transparent,
            borderRadius: 30.0,
            borderWidth: 1.0,
            buttonSize: 40.0,
            icon: Icon(
              Icons.arrow_back_rounded,
              color: FFAppState().temaPrimaryText,
              size: 24.0,
            ),
            onPressed: () async {
              context.safePop();
            },
          ),
          title: Text(
            'Tema',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                  font: GoogleFonts.outfit(
                    fontWeight:
                        FlutterFlowTheme.of(context).headlineMedium.fontWeight,
                    fontStyle:
                        FlutterFlowTheme.of(context).headlineMedium.fontStyle,
                  ),
                  color: FFAppState().temaPrimaryText,
                  fontSize: 22.0,
                  letterSpacing: 0.0,
                  fontWeight:
                      FlutterFlowTheme.of(context).headlineMedium.fontWeight,
                  fontStyle:
                      FlutterFlowTheme.of(context).headlineMedium.fontStyle,
                ),
          ),
          actions: [],
          centerTitle: true,
          elevation: 2.0,
        ),
        body: SafeArea(
          top: true,
          child: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 0.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 24.0),
                      child: Text(
                        'Scegli il tuo tema preferito',
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              font: GoogleFonts.openSans(
                                fontWeight: FontWeight.bold,
                                fontStyle: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .fontStyle,
                              ),
                              color: FFAppState().temaPrimaryText,
                              fontSize: 20.0,
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.bold,
                              fontStyle: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .fontStyle,
                            ),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'ProntoMenu',
                              style: FlutterFlowTheme.of(context)
                                  .titleSmall
                                  .override(
                                    font: GoogleFonts.outfit(
                                      fontWeight: FontWeight.bold,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .titleSmall
                                          .fontStyle,
                                    ),
                                    color: FFAppState().temaPrimaryText,
                                    fontSize: 20.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .titleSmall
                                        .fontStyle,
                                  ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 10.0, 0.0, 25.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    12.0, 12.0, 12.0, 12.0),
                                child: AuthUserStreamWidget(
                                  builder: (context) => InkWell(
                                    splashColor: Colors.transparent,
                                    focusColor: Colors.transparent,
                                    hoverColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    onTap: () async {
                                      setDarkModeSetting(
                                          context, ThemeMode.light);
                                      FFAppState().temaPrimary =
                                          Color(0xFF2C5E4F);
                                      FFAppState().temaSecondary =
                                          Color(0xFFD8CAB7);
                                      FFAppState().temaTertiary =
                                          Color(0xFFA6343C);
                                      FFAppState().temaAlternate =
                                          Color(0xFF333333);
                                      FFAppState().temaPrimaryBackground =
                                          Color(0xFFFFFAF5);
                                      FFAppState().temaSecondaryBackground =
                                          Color(0xFFF1E8DC);
                                      FFAppState().temaPrimaryText =
                                          Color(0xFF413F3E);
                                      FFAppState().temaSecondaryText =
                                          Color(0xFFA59D96);
                                      FFAppState().temaAccent1 =
                                          Color(0x322C5E4F);
                                      FFAppState().temaAccent2 =
                                          Color(0xFFE0E0E0);
                                      FFAppState().temaAccent3 =
                                          Color(0x34D8CAB7);
                                      FFAppState().temaAccent4 =
                                          Color(0xFF310055);
                                      FFAppState().temaSuccess =
                                          Color(0xFF0B9F74);
                                      FFAppState().temaError =
                                          Color(0xFFF8464C);
                                      FFAppState().temaWarning =
                                          Color(0xFFFFA926);
                                      FFAppState().temaInfo = Color(0xFF4F85E0);
                                      safeSetState(() {});

                                      await currentUserReference!
                                          .update(createUsersRecordData(
                                        temaScelto: 'ProntoMenulight',
                                      ));
                                    },
                                    child: Container(
                                      height: 100.0,
                                      decoration: BoxDecoration(
                                        color: FFAppState()
                                            .temaSecondaryBackground,
                                        boxShadow: [
                                          BoxShadow(
                                            blurRadius: 4.0,
                                            color: FFAppState().temaAccent3,
                                            offset: Offset(
                                              0.0,
                                              2.0,
                                            ),
                                          )
                                        ],
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                        border: Border.all(
                                          color: valueOrDefault(
                                                      currentUserDocument
                                                          ?.temaScelto,
                                                      '') ==
                                                  'ProntoMenulight'
                                              ? FFAppState().temaPrimary
                                              : Colors.transparent,
                                          width: 2.0,
                                        ),
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.sunny,
                                            color: FFAppState().temaPrimaryText,
                                            size: 24.0,
                                          ),
                                          Padding(
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    5.0, 0.0, 5.0, 0.0),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                Container(
                                                  width: 30.0,
                                                  height: 30.0,
                                                  decoration: BoxDecoration(
                                                    color: Color(0xFF2C5E4F),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            25.0),
                                                  ),
                                                ),
                                                Container(
                                                  width: 30.0,
                                                  height: 30.0,
                                                  decoration: BoxDecoration(
                                                    color: Color(0xFFD8CAB7),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            25.0),
                                                  ),
                                                ),
                                                Container(
                                                  width: 30.0,
                                                  height: 30.0,
                                                  decoration: BoxDecoration(
                                                    color: Color(0xFFA6343C),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            25.0),
                                                  ),
                                                ),
                                                Container(
                                                  width: 30.0,
                                                  height: 30.0,
                                                  decoration: BoxDecoration(
                                                    color: Color(0xFFFFFAF5),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            25.0),
                                                  ),
                                                ),
                                              ].divide(SizedBox(width: 5.0)),
                                            ),
                                          ),
                                        ].divide(SizedBox(height: 10.0)),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 100.0,
                                child: VerticalDivider(
                                  thickness: 2.0,
                                  color: FFAppState().temaAccent2,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    12.0, 12.0, 12.0, 12.0),
                                child: AuthUserStreamWidget(
                                  builder: (context) => InkWell(
                                    splashColor: Colors.transparent,
                                    focusColor: Colors.transparent,
                                    hoverColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    onTap: () async {
                                      setDarkModeSetting(
                                          context, ThemeMode.dark);
                                      FFAppState().temaPrimary =
                                          Color(0xFF21493D);
                                      FFAppState().temaSecondary =
                                          Color(0xFF8E7C6C);
                                      FFAppState().temaTertiary =
                                          Color(0xFF782329);
                                      FFAppState().temaAlternate =
                                          Color(0xFFF2ECE4);
                                      FFAppState().temaPrimaryBackground =
                                          Color(0xFF121212);
                                      FFAppState().temaSecondaryBackground =
                                          Color(0xFF1E1E1E);
                                      FFAppState().temaPrimaryText =
                                          Color(0xFFFDF6ED);
                                      FFAppState().temaSecondaryText =
                                          Color(0xFFC1B4AB);
                                      FFAppState().temaAccent1 =
                                          Color(0xFF367160);
                                      FFAppState().temaAccent2 =
                                          Color(0x33A6343C);
                                      FFAppState().temaAccent3 =
                                          Color(0xFFC03C46);
                                      FFAppState().temaAccent4 =
                                          Color(0xFF6F9CEF);
                                      FFAppState().temaSuccess =
                                          Color(0xFF11C694);
                                      FFAppState().temaError =
                                          Color(0xFFF75A60);
                                      FFAppState().temaWarning =
                                          Color(0xFFFFB84D);
                                      FFAppState().temaInfo = Color(0xFF6F9CEF);
                                      safeSetState(() {});

                                      await currentUserReference!
                                          .update(createUsersRecordData(
                                        temaScelto: 'ProntoMenudark',
                                      ));
                                    },
                                    child: Container(
                                      height: 100.0,
                                      decoration: BoxDecoration(
                                        color: FFAppState()
                                            .temaSecondaryBackground,
                                        boxShadow: [
                                          BoxShadow(
                                            blurRadius: 4.0,
                                            color: FFAppState().temaAccent3,
                                            offset: Offset(
                                              0.0,
                                              2.0,
                                            ),
                                          )
                                        ],
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                        border: Border.all(
                                          color: valueOrDefault(
                                                      currentUserDocument
                                                          ?.temaScelto,
                                                      '') ==
                                                  'ProntoMenudark'
                                              ? FFAppState().temaPrimary
                                              : Colors.transparent,
                                          width: 2.0,
                                        ),
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          FaIcon(
                                            FontAwesomeIcons.solidMoon,
                                            color: FFAppState().temaPrimaryText,
                                            size: 24.0,
                                          ),
                                          Padding(
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    5.0, 0.0, 5.0, 0.0),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                Container(
                                                  width: 30.0,
                                                  height: 30.0,
                                                  decoration: BoxDecoration(
                                                    color: Color(0xFF21493D),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            25.0),
                                                  ),
                                                ),
                                                Container(
                                                  width: 30.0,
                                                  height: 30.0,
                                                  decoration: BoxDecoration(
                                                    color: Color(0xFF8E7C6C),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            25.0),
                                                  ),
                                                ),
                                                Container(
                                                  width: 30.0,
                                                  height: 30.0,
                                                  decoration: BoxDecoration(
                                                    color: Color(0xFF782329),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            25.0),
                                                  ),
                                                ),
                                                Container(
                                                  width: 30.0,
                                                  height: 30.0,
                                                  decoration: BoxDecoration(
                                                    color: Color(0xFF121212),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            25.0),
                                                  ),
                                                ),
                                              ].divide(SizedBox(width: 5.0)),
                                            ),
                                          ),
                                        ].divide(SizedBox(height: 10.0)),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Amethyst Slate',
                              style: FlutterFlowTheme.of(context)
                                  .titleSmall
                                  .override(
                                    font: GoogleFonts.outfit(
                                      fontWeight: FontWeight.w600,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .titleSmall
                                          .fontStyle,
                                    ),
                                    color: FFAppState().temaPrimaryText,
                                    fontSize: 20.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w600,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .titleSmall
                                        .fontStyle,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(0.0, 10.0, 0.0, 25.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                12.0, 12.0, 12.0, 12.0),
                            child: AuthUserStreamWidget(
                              builder: (context) => InkWell(
                                splashColor: Colors.transparent,
                                focusColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () async {
                                  setDarkModeSetting(context, ThemeMode.light);
                                  FFAppState().temaPrimary = Color(0xFF4B0082);
                                  FFAppState().temaSecondary =
                                      Color(0xFF008080);
                                  FFAppState().temaTertiary = Color(0xFFFFD700);
                                  FFAppState().temaAlternate =
                                      Color(0xFF800080);
                                  FFAppState().temaPrimaryBackground =
                                      Color(0xFFE5E4E2);
                                  FFAppState().temaSecondaryBackground =
                                      Color(0xFFF5F5F5);
                                  FFAppState().temaPrimaryText =
                                      Color(0xFF1C1C1C);
                                  FFAppState().temaSecondaryText =
                                      Color(0xFF666666);
                                  FFAppState().temaAccent1 = Color(0x344B0082);
                                  FFAppState().temaAccent2 = Color(0xFFE0E0E0);
                                  FFAppState().temaAccent3 = Colors.white;
                                  FFAppState().temaAccent4 = Color(0xFF310055);
                                  FFAppState().temaSuccess = Color(0xFF228B22);
                                  FFAppState().temaError = Color(0xFFB00020);
                                  FFAppState().temaWarning = Color(0xFFFF8C00);
                                  FFAppState().temaInfo = Color(0xFF4169E1);
                                  safeSetState(() {});

                                  await currentUserReference!
                                      .update(createUsersRecordData(
                                    temaScelto: 'AmethystSlatelight',
                                  ));
                                },
                                child: Container(
                                  height: 100.0,
                                  decoration: BoxDecoration(
                                    color: FFAppState().temaSecondaryBackground,
                                    boxShadow: [
                                      BoxShadow(
                                        blurRadius: 4.0,
                                        color: FFAppState().temaAccent3,
                                        offset: Offset(
                                          0.0,
                                          2.0,
                                        ),
                                      )
                                    ],
                                    borderRadius: BorderRadius.circular(12.0),
                                    border: Border.all(
                                      color: valueOrDefault(
                                                  currentUserDocument
                                                      ?.temaScelto,
                                                  '') ==
                                              'AmethystSlatelight'
                                          ? FFAppState().temaPrimary
                                          : Colors.transparent,
                                      width: 2.0,
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.sunny,
                                        color: FFAppState().temaPrimaryText,
                                        size: 24.0,
                                      ),
                                      Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            5.0, 0.0, 5.0, 0.0),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            Container(
                                              width: 30.0,
                                              height: 30.0,
                                              decoration: BoxDecoration(
                                                color: Color(0xFF4B0082),
                                                borderRadius:
                                                    BorderRadius.circular(25.0),
                                              ),
                                            ),
                                            Container(
                                              width: 30.0,
                                              height: 30.0,
                                              decoration: BoxDecoration(
                                                color: Color(0xFF008080),
                                                borderRadius:
                                                    BorderRadius.circular(25.0),
                                              ),
                                            ),
                                            Container(
                                              width: 30.0,
                                              height: 30.0,
                                              decoration: BoxDecoration(
                                                color: Color(0xFFFFD700),
                                                borderRadius:
                                                    BorderRadius.circular(25.0),
                                              ),
                                            ),
                                            Container(
                                              width: 30.0,
                                              height: 30.0,
                                              decoration: BoxDecoration(
                                                color: Color(0xFFF5F5F5),
                                                borderRadius:
                                                    BorderRadius.circular(25.0),
                                              ),
                                            ),
                                          ].divide(SizedBox(width: 5.0)),
                                        ),
                                      ),
                                    ].divide(SizedBox(height: 10.0)),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 100.0,
                            child: VerticalDivider(
                              thickness: 2.0,
                              color: FFAppState().temaAccent2,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                12.0, 12.0, 12.0, 12.0),
                            child: AuthUserStreamWidget(
                              builder: (context) => InkWell(
                                splashColor: Colors.transparent,
                                focusColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () async {
                                  setDarkModeSetting(context, ThemeMode.dark);
                                  FFAppState().temaPrimary = Color(0xFFBB86FC);
                                  FFAppState().temaSecondary =
                                      Color(0xFF03DAC6);
                                  FFAppState().temaTertiary = Color(0xFFFFD700);
                                  FFAppState().temaAlternate =
                                      Color(0xFF9932CC);
                                  FFAppState().temaPrimaryBackground =
                                      Color(0xFF121212);
                                  FFAppState().temaSecondaryBackground =
                                      Color(0xFF1E1E1E);
                                  FFAppState().temaPrimaryText = Colors.white;
                                  FFAppState().temaSecondaryText =
                                      Color(0xFFA0A0A0);
                                  FFAppState().temaAccent1 = Color(0x25BB86FC);
                                  FFAppState().temaAccent2 = Color(0xFFE0E0E0);
                                  FFAppState().temaAccent3 = Color(0xFF2C2C2C);
                                  FFAppState().temaAccent4 = Color(0xFFD1A3FF);
                                  FFAppState().temaSuccess = Color(0xFF81C784);
                                  FFAppState().temaError = Color(0xFFCF6679);
                                  FFAppState().temaWarning = Color(0xFFFFB74D);
                                  FFAppState().temaInfo = Color(0xFF64B5F6);
                                  safeSetState(() {});

                                  await currentUserReference!
                                      .update(createUsersRecordData(
                                    temaScelto: 'AmethystSlatedark',
                                  ));
                                },
                                child: Container(
                                  height: 100.0,
                                  decoration: BoxDecoration(
                                    color: FFAppState().temaSecondaryBackground,
                                    boxShadow: [
                                      BoxShadow(
                                        blurRadius: 4.0,
                                        color: FFAppState().temaAccent3,
                                        offset: Offset(
                                          0.0,
                                          2.0,
                                        ),
                                      )
                                    ],
                                    borderRadius: BorderRadius.circular(12.0),
                                    border: Border.all(
                                      color: valueOrDefault(
                                                  currentUserDocument
                                                      ?.temaScelto,
                                                  '') ==
                                              'AmethystSlatedark'
                                          ? FFAppState().temaPrimary
                                          : Colors.transparent,
                                      width: 2.0,
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      FaIcon(
                                        FontAwesomeIcons.solidMoon,
                                        color: FFAppState().temaPrimaryText,
                                        size: 24.0,
                                      ),
                                      Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            5.0, 0.0, 5.0, 0.0),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            Container(
                                              width: 30.0,
                                              height: 30.0,
                                              decoration: BoxDecoration(
                                                color: Color(0xFFBB86FC),
                                                borderRadius:
                                                    BorderRadius.circular(25.0),
                                              ),
                                            ),
                                            Container(
                                              width: 30.0,
                                              height: 30.0,
                                              decoration: BoxDecoration(
                                                color: Color(0xFF03DAC6),
                                                borderRadius:
                                                    BorderRadius.circular(25.0),
                                              ),
                                            ),
                                            Container(
                                              width: 30.0,
                                              height: 30.0,
                                              decoration: BoxDecoration(
                                                color: Color(0xFFFFD700),
                                                borderRadius:
                                                    BorderRadius.circular(25.0),
                                              ),
                                            ),
                                            Container(
                                              width: 30.0,
                                              height: 30.0,
                                              decoration: BoxDecoration(
                                                color: Color(0xFF121212),
                                                borderRadius:
                                                    BorderRadius.circular(25.0),
                                              ),
                                            ),
                                          ].divide(SizedBox(width: 5.0)),
                                        ),
                                      ),
                                    ].divide(SizedBox(height: 10.0)),
                                  ),
                                ),
                              ),
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
        ),
      ),
    );
  }
}
