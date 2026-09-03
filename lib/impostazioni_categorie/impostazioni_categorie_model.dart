import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import 'impostazioni_categorie_widget.dart' show ImpostazioniCategorieWidget;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ImpostazioniCategorieModel
    extends FlutterFlowModel<ImpostazioniCategorieWidget> {
  ///  Local state fields for this page.

  List<DocumentReference> listaCategorieDaOrdinare = [];
  void addToListaCategorieDaOrdinare(DocumentReference item) =>
      listaCategorieDaOrdinare.add(item);
  void removeFromListaCategorieDaOrdinare(DocumentReference item) =>
      listaCategorieDaOrdinare.remove(item);
  void removeAtIndexFromListaCategorieDaOrdinare(int index) =>
      listaCategorieDaOrdinare.removeAt(index);
  void insertAtIndexInListaCategorieDaOrdinare(
          int index, DocumentReference item) =>
      listaCategorieDaOrdinare.insert(index, item);
  void updateListaCategorieDaOrdinareAtIndex(
          int index, Function(DocumentReference) updateFn) =>
      listaCategorieDaOrdinare[index] =
          updateFn(listaCategorieDaOrdinare[index]);

  List<CategoriesRecord> listaCategorie = [];
  void addToListaCategorie(CategoriesRecord item) => listaCategorie.add(item);
  void removeFromListaCategorie(CategoriesRecord item) =>
      listaCategorie.remove(item);
  void removeAtIndexFromListaCategorie(int index) =>
      listaCategorie.removeAt(index);
  void insertAtIndexInListaCategorie(int index, CategoriesRecord item) =>
      listaCategorie.insert(index, item);
  void updateListaCategorieAtIndex(
          int index, Function(CategoriesRecord) updateFn) =>
      listaCategorie[index] = updateFn(listaCategorie[index]);

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Firestore Query - Query a collection] action in ImpostazioniCategorie widget.
  List<CategoriesRecord>? categorieTrovate;
  // State field(s) for Column widget.
  ScrollController? columnController;
  // Stores action output result for [Custom Action - riordinaLista] action in riordinoCategorie widget.
  List<CategoriesRecord>? listaAggiornata;

  @override
  void initState(BuildContext context) {
    columnController = ScrollController();
  }

  @override
  void dispose() {
    columnController?.dispose();
  }
}
