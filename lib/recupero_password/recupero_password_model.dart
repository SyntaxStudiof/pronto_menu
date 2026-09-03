import '/auth/firebase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/index.dart';
import 'recupero_password_widget.dart' show RecuperoPasswordWidget;
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class RecuperoPasswordModel extends FlutterFlowModel<RecuperoPasswordWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for txtEmailRecupero widget.
  FocusNode? txtEmailRecuperoFocusNode;
  TextEditingController? txtEmailRecuperoTextController;
  String? Function(BuildContext, String?)?
      txtEmailRecuperoTextControllerValidator;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    txtEmailRecuperoFocusNode?.dispose();
    txtEmailRecuperoTextController?.dispose();
  }
}
