import '/flutter_flow/flutter_flow_util.dart';
import 'abbonamento_widget.dart' show AbbonamentoWidget;
import 'package:flutter/material.dart';

class AbbonamentoModel extends FlutterFlowModel<AbbonamentoWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for Column widget.
  ScrollController? columnController;

  // 'mensile' or 'annuale'
  String billingInterval = 'mensile';

  // Selected plan tab / highlight ('pro', 'plus', 'ultra')
  String selectedTier = 'plus';

  @override
  void initState(BuildContext context) {
    columnController = ScrollController();
  }

  @override
  void dispose() {
    columnController?.dispose();
  }
}
