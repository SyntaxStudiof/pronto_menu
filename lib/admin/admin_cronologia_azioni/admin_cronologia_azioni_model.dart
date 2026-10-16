import '/flutter_flow/flutter_flow_util.dart';
import 'admin_cronologia_azioni_widget.dart' show AdminCronologiaAzioniWidget;
import 'package:flutter/material.dart';

class AdminCronologiaAzioniModel
    extends FlutterFlowModel<AdminCronologiaAzioniWidget> {
  /// State fields
  ScrollController? scrollController;
  TextEditingController? searchController;
  FocusNode? searchFocusNode;

  String filtroTipo = 'Tutti'; // 'Tutti', 'delete', 'update', 'create', 'restore'
  String filtroRistorante = 'Tutti';

  @override
  void initState(BuildContext context) {
    scrollController = ScrollController();
    searchController = TextEditingController();
    searchFocusNode = FocusNode();
  }

  @override
  void dispose() {
    scrollController?.dispose();
    searchController?.dispose();
    searchFocusNode?.dispose();
  }
}
