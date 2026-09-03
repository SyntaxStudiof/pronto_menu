import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/cliente/comp_carrello/comp_carrello_widget.dart';
import '/cliente/dettagli_piatto_popup/dettagli_piatto_popup_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/index.dart';
import 'menu_cliente_widget.dart' show MenuClienteWidget;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';

class MenuClienteModel extends FlutterFlowModel<MenuClienteWidget> {
  ///  Local state fields for this page.

  String? categoriaSelezionata;

  DocumentReference? sottocategoriaSelezionata;

  DocumentReference? categoriaSelezionataRef;

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Backend Call - Read Document] action in MenuCliente widget.
  UsersRecord? datiRistorante;
  // Model for Comp_Carrello component.
  late CompCarrelloModel compCarrelloModel;

  @override
  void initState(BuildContext context) {
    compCarrelloModel = createModel(context, () => CompCarrelloModel());
  }

  @override
  void dispose() {
    compCarrelloModel.dispose();
  }
}
