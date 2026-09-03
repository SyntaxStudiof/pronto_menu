import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/backend/firebase_storage/storage.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/upload_data.dart';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/index.dart';
import 'profilo_utente_widget.dart' show ProfiloUtenteWidget;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ProfiloUtenteModel extends FlutterFlowModel<ProfiloUtenteWidget> {
  ///  Local state fields for this page.

  DateTime? dataScelta;

  bool mouseSopra = false;

  bool mostraBottone = false;

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Custom Action - checkProvider] action in ProfiloUtente widget.
  bool? isEmail;
  // State field(s) for Column widget.
  ScrollController? columnController;
  bool isDataUploading_uploadData3sa = false;
  FFUploadedFile uploadedLocalFile_uploadData3sa =
      FFUploadedFile(bytes: Uint8List.fromList([]), originalFilename: '');
  String uploadedFileUrl_uploadData3sa = '';

  // State field(s) for Nome widget.
  FocusNode? nomeFocusNode;
  TextEditingController? nomeTextController;
  String? Function(BuildContext, String?)? nomeTextControllerValidator;
  // State field(s) for Cognome widget.
  FocusNode? cognomeFocusNode;
  TextEditingController? cognomeTextController;
  String? Function(BuildContext, String?)? cognomeTextControllerValidator;
  // State field(s) for Ristorante widget.
  FocusNode? ristoranteFocusNode;
  TextEditingController? ristoranteTextController;
  String? Function(BuildContext, String?)? ristoranteTextControllerValidator;
  // State field(s) for MouseRegion widget.
  bool mouseRegionHovered = false;
  DateTime? datePicked;

  @override
  void initState(BuildContext context) {
    columnController = ScrollController();
  }

  @override
  void dispose() {
    columnController?.dispose();
    nomeFocusNode?.dispose();
    nomeTextController?.dispose();

    cognomeFocusNode?.dispose();
    cognomeTextController?.dispose();

    ristoranteFocusNode?.dispose();
    ristoranteTextController?.dispose();
  }
}
