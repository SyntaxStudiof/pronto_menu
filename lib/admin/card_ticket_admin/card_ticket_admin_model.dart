import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'card_ticket_admin_widget.dart' show CardTicketAdminWidget;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class CardTicketAdminModel extends FlutterFlowModel<CardTicketAdminWidget> {
  ///  State fields for stateful widgets in this component.

  // State field(s) for Column widget.
  ScrollController? columnController;
  // State field(s) for testoRisposta widget.
  FocusNode? testoRispostaFocusNode;
  TextEditingController? testoRispostaTextController;
  String? Function(BuildContext, String?)? testoRispostaTextControllerValidator;

  @override
  void initState(BuildContext context) {
    columnController = ScrollController();
  }

  @override
  void dispose() {
    columnController?.dispose();
    testoRispostaFocusNode?.dispose();
    testoRispostaTextController?.dispose();
  }
}
