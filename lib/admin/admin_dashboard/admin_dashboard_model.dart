import '/admin/admin_drawer_menu/admin_drawer_menu_widget.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'admin_dashboard_widget.dart' show AdminDashboardWidget;
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class AdminDashboardModel extends FlutterFlowModel<AdminDashboardWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for Column widget.
  ScrollController? columnController;
  // State field(s) for BarraRicerca widget.
  FocusNode? barraRicercaFocusNode;
  TextEditingController? barraRicercaTextController;
  String? Function(BuildContext, String?)? barraRicercaTextControllerValidator;
  // Model for AdminDrawerMenu component.
  late AdminDrawerMenuModel adminDrawerMenuModel;

  @override
  void initState(BuildContext context) {
    columnController = ScrollController();
    adminDrawerMenuModel = createModel(context, () => AdminDrawerMenuModel());
  }

  @override
  void dispose() {
    columnController?.dispose();
    barraRicercaFocusNode?.dispose();
    barraRicercaTextController?.dispose();

    adminDrawerMenuModel.dispose();
  }
}
