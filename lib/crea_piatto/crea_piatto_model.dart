import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/components/crea_sottocategoria_widget.dart';
import '/components/popup_foto_piatto_widget.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import 'dart:ui';
import '/flutter_flow/custom_functions.dart' as functions;
import 'crea_piatto_widget.dart' show CreaPiattoWidget;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';

class CreaPiattoModel extends FlutterFlowModel<CreaPiattoWidget> {
  ///  Local state fields for this page.

  String fotoInMemoria =
      'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/pronto-menu-f0och1/assets/i4ccmvv80eni/IMG_8006.png';

  List<String> intolleranzeSelezionate = [];
  List<String> allergeniSelezionati = [];

  ///  State fields for stateful widgets in this page.

  // State field(s) for Column widget.
  ScrollController? columnController;
  // State field(s) for SelezionaSottocategoria widget.
  String? selezionaSottocategoriaValue;
  FormFieldController<String>? selezionaSottocategoriaValueController;
  // Stores action output result for [Bottom Sheet - creaSottocategoria] action in Icon widget.
  DocumentReference? risultatoPopup;
  // State field(s) for NomePiatto widget.
  FocusNode? nomePiattoFocusNode;
  TextEditingController? nomePiattoTextController;
  String? Function(BuildContext, String?)? nomePiattoTextControllerValidator;
  // State field(s) for Prezzo widget.
  FocusNode? prezzoFocusNode;
  TextEditingController? prezzoTextController;
  String? Function(BuildContext, String?)? prezzoTextControllerValidator;
  // State field(s) for Ingredienti widget.
  FocusNode? ingredientiFocusNode;
  TextEditingController? ingredientiTextController;
  String? Function(BuildContext, String?)? ingredientiTextControllerValidator;
  // State field(s) for Descrizione widget.
  FocusNode? descrizioneFocusNode;
  TextEditingController? descrizioneTextController;
  String? Function(BuildContext, String?)? descrizioneTextControllerValidator;
  // Stores action output result for [Firestore Query - Query a collection] action in ButtonSalva widget.
  SottocategorieRecord? sottoCategoriaTrovata;

  @override
  void initState(BuildContext context) {
    columnController = ScrollController();
  }

  @override
  void dispose() {
    columnController?.dispose();
    nomePiattoFocusNode?.dispose();
    nomePiattoTextController?.dispose();

    prezzoFocusNode?.dispose();
    prezzoTextController?.dispose();

    ingredientiFocusNode?.dispose();
    ingredientiTextController?.dispose();

    descrizioneFocusNode?.dispose();
    descrizioneTextController?.dispose();
  }
}
