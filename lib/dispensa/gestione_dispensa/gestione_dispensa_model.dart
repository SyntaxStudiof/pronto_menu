import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'gestione_dispensa_widget.dart' show GestioneDispensaWidget;

class GestioneDispensaModel extends FlutterFlowModel<GestioneDispensaWidget> {
  /// State fields for stateful widgets in this page.
  final unfocusNode = FocusNode();

  // Search controller & focus
  TextEditingController? searchController;
  FocusNode? searchFocusNode;

  // Selected filter: 'tutti', 'disponibili', 'esaurimento', 'esauriti'
  String filtroStato = 'tutti';

  @override
  void initState(BuildContext context) {
    searchController ??= TextEditingController();
    searchFocusNode ??= FocusNode();
  }

  @override
  void dispose() {
    unfocusNode.dispose();
    searchController?.dispose();
    searchFocusNode?.dispose();
  }
}
