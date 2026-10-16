import '/flutter_flow/flutter_flow_util.dart';
import 'admin_metriche_widget.dart' show AdminMetricheWidget;
import 'package:flutter/material.dart';

class AdminMetricheModel extends FlutterFlowModel<AdminMetricheWidget> {
  ScrollController? scrollController;
  bool isRefreshing = false;

  @override
  void initState(BuildContext context) {
    scrollController = ScrollController();
  }

  @override
  void dispose() {
    scrollController?.dispose();
  }
}
