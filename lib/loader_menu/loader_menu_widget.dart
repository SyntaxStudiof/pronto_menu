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
    this.tavolo,
  });

  final DocumentReference? ristoranteRef;
  final String? tavolo;

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

    // On page load action - immediato senza attese di rete bloccanti.
    SchedulerBinding.instance.addPostFrameCallback((_) {
      FFAppState().ristoranteSalvato = widget.ristoranteRef;
      if (widget.tavolo != null && widget.tavolo!.trim().isNotEmpty) {
        FFAppState().numeroTavolo = widget.tavolo!.trim();
      }
      if (widget.ristoranteRef != null) {
        context.goNamed(
          HubClienteWidget.routeName,
          queryParameters: {
            'ristoranteRef': serializeParam(
              widget.ristoranteRef,
              ParamType.DocumentReference,
            ),
            'isAnteprima': serializeParam(
              currentUserUid.isNotEmpty,
              ParamType.bool,
            ),
          }.withoutNulls,
        );
      } else if (currentUserUid.isNotEmpty) {
        context.goNamed(
          HomeRistoratoreWidget.routeName,
        );
      } else {
        context.goNamed(
          AuthWelcomeWidget.routeName,
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
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: theme.scaffoldBackgroundColor,
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
                  progressColor: theme.colorScheme.primary,
                  backgroundColor: theme.colorScheme.secondary,
                  center: Text('100%', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, fontSize: 30.0)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
