import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'crea_sottocategoria_model.dart';
export 'crea_sottocategoria_model.dart';

class CreaSottocategoriaWidget extends StatefulWidget {
  const CreaSottocategoriaWidget({
    super.key,
    required this.categoriaRicevuta,
  });

  final DocumentReference? categoriaRicevuta;

  @override
  State<CreaSottocategoriaWidget> createState() =>
      _CreaSottocategoriaWidgetState();
}

class _CreaSottocategoriaWidgetState extends State<CreaSottocategoriaWidget> {
  late CreaSottocategoriaModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CreaSottocategoriaModel());

    _model.nomeSottocategoriaTextController ??= TextEditingController();
    _model.nomeSottocategoriaFocusNode ??= FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      height: MediaQuery.sizeOf(context).height * 0.6,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
      ),
      child: SingleChildScrollView(
        controller: _model.columnController,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 0.0),
              child: Container(
                width: 280.0,
                child: TextFormField(
                  controller: _model.nomeSottocategoriaTextController,
                  focusNode: _model.nomeSottocategoriaFocusNode,
                  autofocus: false,
                  enabled: true,
                  obscureText: false,
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: 'Scrivi una sottocategoria...',
                    hintStyle: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.hintColor,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: theme.dividerColor.withValues(alpha: 0.2),
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: theme.colorScheme.primary,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: theme.colorScheme.error,
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: theme.colorScheme.error,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    filled: true,
                    fillColor: theme.scaffoldBackgroundColor,
                  ),
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                  cursorColor: theme.colorScheme.primary,
                  enableInteractiveSelection: true,
                  validator: _model.nomeSottocategoriaTextControllerValidator
                      .asValidator(context),
                ),
              ),
            ),
            FFButtonWidget(
              onPressed: () async {
                var sottocategorieRecordReference =
                    SottocategorieRecord.collection.doc();
                await sottocategorieRecordReference
                    .set(createSottocategorieRecordData(
                  nome: _model.nomeSottocategoriaTextController.text,
                  categoriaPadreRef: widget.categoriaRicevuta,
                  proprietario: currentUserReference,
                ));
                _model.nuovaSottocat = SottocategorieRecord.getDocumentFromData(
                    createSottocategorieRecordData(
                      nome: _model.nomeSottocategoriaTextController.text,
                      categoriaPadreRef: widget.categoriaRicevuta,
                      proprietario: currentUserReference,
                    ),
                    sottocategorieRecordReference);
                Navigator.pop(context, _model.nuovaSottocat?.reference);

                safeSetState(() {});
              },
              text: 'Aggiungi',
              options: FFButtonOptions(
                width: 280.0,
                height: 45.0,
                padding: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                iconPadding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                elevation: 0.0,
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
          ].divide(const SizedBox(height: 10.0)),
        ),
      ),
    );
  }
}
