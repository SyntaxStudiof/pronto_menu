import '/auth/firebase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/index.dart';
import 'auth_registration_widget.dart' show AuthRegistrationWidget;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class AuthRegistrationModel extends FlutterFlowModel<AuthRegistrationWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for Column widget.
  ScrollController? columnController;
  // State field(s) for txtNomeRegistrazione widget.
  FocusNode? txtNomeRegistrazioneFocusNode;
  TextEditingController? txtNomeRegistrazioneTextController;
  String? Function(BuildContext, String?)?
      txtNomeRegistrazioneTextControllerValidator;
  // State field(s) for txtEmailRegistrazione widget.
  FocusNode? txtEmailRegistrazioneFocusNode;
  TextEditingController? txtEmailRegistrazioneTextController;
  String? Function(BuildContext, String?)?
      txtEmailRegistrazioneTextControllerValidator;
  // State field(s) for txtPasswordRegistrazione widget.
  FocusNode? txtPasswordRegistrazioneFocusNode;
  TextEditingController? txtPasswordRegistrazioneTextController;
  late bool txtPasswordRegistrazioneVisibility;
  String? Function(BuildContext, String?)?
      txtPasswordRegistrazioneTextControllerValidator;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode;
  TextEditingController? confirmPasswordTextController;
  late bool passwordVisibility;
  String? Function(BuildContext, String?)?
      confirmPasswordTextControllerValidator;

  @override
  void initState(BuildContext context) {
    columnController = ScrollController();
    txtPasswordRegistrazioneVisibility = false;
    passwordVisibility = false;
  }

  @override
  void dispose() {
    columnController?.dispose();
    txtNomeRegistrazioneFocusNode?.dispose();
    txtNomeRegistrazioneTextController?.dispose();

    txtEmailRegistrazioneFocusNode?.dispose();
    txtEmailRegistrazioneTextController?.dispose();

    txtPasswordRegistrazioneFocusNode?.dispose();
    txtPasswordRegistrazioneTextController?.dispose();

    textFieldFocusNode?.dispose();
    confirmPasswordTextController?.dispose();
  }
}
