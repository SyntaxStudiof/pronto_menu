import '/flutter_flow/flutter_flow_util.dart';
import 'card_ticket_admin_widget.dart' show CardTicketAdminWidget;
import 'package:flutter/material.dart';

class CardTicketAdminModel extends FlutterFlowModel<CardTicketAdminWidget> {
  /// State fields for stateful widgets in this component.
  ScrollController? columnController;
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
