import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/components/nav_bar_dinamica_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/flutter_flow/custom_functions.dart' as functions;
import 'dashboard_ristorante_widget.dart' show DashboardRistoranteWidget;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class DashboardRistoranteModel
    extends FlutterFlowModel<DashboardRistoranteWidget> {
  ///  Local state fields for this page.

  int? indiceLoop = 0;

  ///  State fields for stateful widgets in this page.

  // State field(s) for Column widget.
  ScrollController? columnController;
  // Model for NavBarDinamica component.
  late NavBarDinamicaModel navBarDinamicaModel;
  // Stores action output result for [Firestore Query - Query a collection] action in FloatingActionButton widget.
  List<OrdersRecord>? ordiniDaCompletare;

  @override
  void initState(BuildContext context) {
    columnController = ScrollController();
    navBarDinamicaModel = createModel(context, () => NavBarDinamicaModel());
  }

  @override
  void dispose() {
    columnController?.dispose();
    navBarDinamicaModel.dispose();
  }
}
