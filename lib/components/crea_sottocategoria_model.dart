import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'crea_sottocategoria_widget.dart' show CreaSottocategoriaWidget;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class CreaSottocategoriaModel
    extends FlutterFlowModel<CreaSottocategoriaWidget> {
  ///  State fields for stateful widgets in this component.

  // State field(s) for Column widget.
  ScrollController? columnController;
  // State field(s) for nomeSottocategoria widget.
  FocusNode? nomeSottocategoriaFocusNode;
  TextEditingController? nomeSottocategoriaTextController;
  String? Function(BuildContext, String?)?
      nomeSottocategoriaTextControllerValidator;
  // Stores action output result for [Backend Call - Create Document] action in Button widget.
  SottocategorieRecord? nuovaSottocat;

  @override
  void initState(BuildContext context) {
    columnController = ScrollController();
  }

  @override
  void dispose() {
    columnController?.dispose();
    nomeSottocategoriaFocusNode?.dispose();
    nomeSottocategoriaTextController?.dispose();
  }
}
