import '/flutter_flow/flutter_flow_util.dart';
import 'admin_tickets_widget.dart' show AdminTicketsWidget;
import 'package:flutter/material.dart';

class AdminTicketsModel extends FlutterFlowModel<AdminTicketsWidget> {
  /// Local state
  String filtroStato = 'Tutti'; // 'Tutti', 'Aperto', 'Risolto'

  /// State fields
  ScrollController? columnController;
  TextEditingController? cercaTextController;
  FocusNode? cercaFocusNode;

  @override
  void initState(BuildContext context) {
    columnController = ScrollController();
    cercaTextController = TextEditingController();
    cercaFocusNode = FocusNode();
  }

  @override
  void dispose() {
    columnController?.dispose();
    cercaTextController?.dispose();
    cercaFocusNode?.dispose();
  }
}
