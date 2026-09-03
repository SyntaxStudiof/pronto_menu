import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/index.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';
import 'loader_menu_model.dart';
export 'loader_menu_model.dart';

class LoaderMenuWidget extends StatefulWidget {
  const LoaderMenuWidget({
    super.key,
    required this.ristoranteRef,
  });

  final DocumentReference? ristoranteRef;

  static String routeName = 'LoaderMenu';
  static String routePath = '/loaderMenu';

  @override
  State<LoaderMenuWidget> createState() => _LoaderMenuWidgetState();
}

class _LoaderMenuWidgetState extends State<LoaderMenuWidget> {
  late LoaderMenuModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => LoaderMenuModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(
        Duration(
          milliseconds: 500,
        ),
      );
      _model.datiRistorante =
          await UsersRecord.getDocumentOnce(widget!.ristoranteRef!);
      FFAppState().ristoranteSalvato = widget!.ristoranteRef;
      safeSetState(() {});
      if (valueOrDefault(currentUserDocument?.temaScelto, '') ==
          'AmethystSlatelight') {
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
      } else {
        if (valueOrDefault(currentUserDocument?.temaScelto, '') ==
            'ProntoMenudark') {
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
        } else {
          if (valueOrDefault(currentUserDocument?.temaScelto, '') ==
              'AmethystSlatedark') {
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
      } else {
        context.pushNamed(
          MenuClienteWidget.routeName,
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

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: SafeArea(
          top: true,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Align(
                alignment: AlignmentDirectional(0.0, 0.0),
                child: CircularPercentIndicator(
                  percent: 1.0,
                  radius: 60.0,
                  lineWidth: 12.0,
                  animation: true,
                  animateFromLastPercent: true,
                  progressColor: FFAppState().temaPrimary,
                  backgroundColor: FFAppState().temaSecondary,
                  center: Text(
                    '100%',
                    style: FlutterFlowTheme.of(context).headlineSmall.override(
                          font: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                            fontStyle: FlutterFlowTheme.of(context)
                                .headlineSmall
                                .fontStyle,
                          ),
                          color: FFAppState().temaTertiary,
                          fontSize: 30.0,
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.bold,
                          fontStyle: FlutterFlowTheme.of(context)
                              .headlineSmall
                              .fontStyle,
                        ),
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
