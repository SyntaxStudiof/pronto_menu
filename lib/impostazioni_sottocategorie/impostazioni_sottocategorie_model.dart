import '/flutter_flow/flutter_flow_util.dart';
import 'impostazioni_sottocategorie_widget.dart'
    show ImpostazioniSottocategorieWidget;
import 'package:flutter/material.dart';

class ImpostazioniSottocategorieModel
    extends FlutterFlowModel<ImpostazioniSottocategorieWidget> {
  ScrollController? scrollController;

  @override
  void initState(BuildContext context) {
    scrollController = ScrollController();
  }

  @override
  void dispose() {
    scrollController?.dispose();
  }
}
