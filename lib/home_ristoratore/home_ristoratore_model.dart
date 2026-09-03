import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/components/comp_add_category_widget.dart';
import '/components/menu_profilo_widget.dart';
import '/components/nav_bar_dinamica_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'home_ristoratore_widget.dart' show HomeRistoratoreWidget;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class HomeRistoratoreModel extends FlutterFlowModel<HomeRistoratoreWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for NavBarDinamica component.
  late NavBarDinamicaModel navBarDinamicaModel;
  // State field(s) for Column widget.
  ScrollController? columnController;
  // Model for MenuProfilo component.
  late MenuProfiloModel menuProfiloModel;

  @override
  void initState(BuildContext context) {
    navBarDinamicaModel = createModel(context, () => NavBarDinamicaModel());
    columnController = ScrollController();
    menuProfiloModel = createModel(context, () => MenuProfiloModel());
  }

  @override
  void dispose() {
    navBarDinamicaModel.dispose();
    columnController?.dispose();
    menuProfiloModel.dispose();
  }
}
