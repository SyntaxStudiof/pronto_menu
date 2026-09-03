import '/auth/firebase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/index.dart';
import 'cambia_password_widget.dart' show CambiaPasswordWidget;
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class CambiaPasswordModel extends FlutterFlowModel<CambiaPasswordWidget> {
  ///  Local state fields for this page.

  bool passwordVerificata = false;

  ///  State fields for stateful widgets in this page.

  final formKey = GlobalKey<FormState>();
  // State field(s) for Column widget.
  ScrollController? columnController1;
  // State field(s) for Column widget.
  ScrollController? columnController2;
  // State field(s) for vecchia_password widget.
  FocusNode? vecchiaPasswordFocusNode;
  TextEditingController? vecchiaPasswordTextController;
  late bool vecchiaPasswordVisibility;
  String? Function(BuildContext, String?)?
      vecchiaPasswordTextControllerValidator;
  // State field(s) for nuova_password widget.
  FocusNode? nuovaPasswordFocusNode;
  TextEditingController? nuovaPasswordTextController;
  late bool nuovaPasswordVisibility;
  String? Function(BuildContext, String?)? nuovaPasswordTextControllerValidator;
  // State field(s) for conferma_password widget.
  FocusNode? confermaPasswordFocusNode;
  TextEditingController? confermaPasswordTextController;
  late bool confermaPasswordVisibility;
  String? Function(BuildContext, String?)?
      confermaPasswordTextControllerValidator;

  @override
  void initState(BuildContext context) {
    columnController1 = ScrollController();
    columnController2 = ScrollController();
    vecchiaPasswordVisibility = false;
    nuovaPasswordVisibility = false;
    confermaPasswordVisibility = false;
  }

  @override
  void dispose() {
    columnController1?.dispose();
    columnController2?.dispose();
    vecchiaPasswordFocusNode?.dispose();
    vecchiaPasswordTextController?.dispose();

    nuovaPasswordFocusNode?.dispose();
    nuovaPasswordTextController?.dispose();

    confermaPasswordFocusNode?.dispose();
    confermaPasswordTextController?.dispose();
  }
}
