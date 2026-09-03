import '/auth/firebase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/index.dart';
import 'supporto_ristoratore_widget.dart' show SupportoRistoratoreWidget;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class SupportoRistoratoreModel
    extends FlutterFlowModel<SupportoRistoratoreWidget> {
  ///  Local state fields for this page.

  bool mostraLista = false;

  ///  State fields for stateful widgets in this page.

  // State field(s) for Column widget.
  ScrollController? columnController1;
  // State field(s) for Switch widget.
  bool? switchValue;
  // State field(s) for titoloTicket widget.
  FocusNode? titoloTicketFocusNode;
  TextEditingController? titoloTicketTextController;
  String? Function(BuildContext, String?)? titoloTicketTextControllerValidator;
  // State field(s) for descrizioneTicket widget.
  FocusNode? descrizioneTicketFocusNode;
  TextEditingController? descrizioneTicketTextController;
  String? Function(BuildContext, String?)?
      descrizioneTicketTextControllerValidator;
  // State field(s) for Column widget.
  ScrollController? columnController2;

  @override
  void initState(BuildContext context) {
    columnController1 = ScrollController();
    columnController2 = ScrollController();
  }

  @override
  void dispose() {
    columnController1?.dispose();
    titoloTicketFocusNode?.dispose();
    titoloTicketTextController?.dispose();

    descrizioneTicketFocusNode?.dispose();
    descrizioneTicketTextController?.dispose();

    columnController2?.dispose();
  }
}
