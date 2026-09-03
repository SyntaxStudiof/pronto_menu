import '/auth/firebase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';
import 'smistamento_login_model.dart';
export 'smistamento_login_model.dart';

class SmistamentoLoginWidget extends StatefulWidget {
  const SmistamentoLoginWidget({super.key});

  static String routeName = 'SmistamentoLogin';
  static String routePath = '/smistamentoLogin';

  @override
  State<SmistamentoLoginWidget> createState() => _SmistamentoLoginWidgetState();
}

class _SmistamentoLoginWidgetState extends State<SmistamentoLoginWidget> {
  late SmistamentoLoginModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SmistamentoLoginModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      if (valueOrDefault<bool>(currentUserDocument?.isAdmin, false)) {
        context.goNamed(AdminDashboardWidget.routeName);
      } else {
        context.goNamed(
          HomeRistoratoreWidget.routeName,
          queryParameters: {
            'ristoranteRef': serializeParam(
              currentUserReference,
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
          child: Align(
            alignment: AlignmentDirectional(0.0, 0.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularPercentIndicator(
                  percent: 1.0,
                  radius: 150.0,
                  lineWidth: 40.0,
                  animation: true,
                  animateFromLastPercent: true,
                  progressColor: FFAppState().temaPrimary,
                  backgroundColor: FFAppState().temaSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
