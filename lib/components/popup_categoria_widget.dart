import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'popup_categoria_model.dart';
export 'popup_categoria_model.dart';

class PopupCategoriaWidget extends StatefulWidget {
  const PopupCategoriaWidget({
    super.key,
    required this.refCategoria,
    required this.nomeAttuale,
    required this.categoriaInModifica,
  });

  final DocumentReference? refCategoria;
  final String? nomeAttuale;
  final DocumentReference? categoriaInModifica;

  @override
  State<PopupCategoriaWidget> createState() => _PopupCategoriaWidgetState();
}

class _PopupCategoriaWidgetState extends State<PopupCategoriaWidget> {
  late PopupCategoriaModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PopupCategoriaModel());

    _model.textController ??= TextEditingController(text: widget.nomeAttuale);
    _model.textFieldFocusNode ??= FocusNode();

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

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 5.0),
      child: Container(
        width: 320.0,
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16.0, 20.0, 16.0, 24.0),
          child: SingleChildScrollView(
            controller: _model.columnController,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Opzioni categoria',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  width: 280.0,
                  child: TextFormField(
                    controller: _model.textController,
                    focusNode: _model.textFieldFocusNode,
                    autofocus: false,
                    enabled: true,
                    obscureText: false,
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: 'Nome categoria',
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
                    validator:
                        _model.textControllerValidator.asValidator(context),
                  ),
                ),
                FFButtonWidget(
                  onPressed: () async {
                    await widget.refCategoria!
                        .update(createCategoriesRecordData(
                      name: _model.textController.text,
                    ));
                    Navigator.pop(context);
                  },
                  text: 'Sostituisci nome categoria',
                  options: FFButtonOptions(
                    width: 280.0,
                    height: 45.0,
                    padding:
                        const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                    iconPadding:
                        const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                    elevation: 0.0,
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                FFButtonWidget(
                  onPressed: () async {
                    var confirmDialogResponse = await showDialog<bool>(
                          context: context,
                          builder: (alertDialogContext) {
                            return AlertDialog(
                              title: const Text('Attenzione!'),
                              content: const Text(
                                  'Sei sicuro di voler eliminare questa categoria? Verranno eliminati anche i piatti al suo interno!'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(alertDialogContext, false),
                                  child: const Text('Annulla'),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(alertDialogContext, true),
                                  child: const Text('Si, conferma'),
                                ),
                              ],
                            );
                          },
                        ) ??
                        false;
                    if (confirmDialogResponse) {
                      _model.piattiDaEliminare = await queryPiattiRecordOnce(
                        queryBuilder: (piattiRecord) => piattiRecord.where(
                          'Categoria',
                          isEqualTo: widget.refCategoria?.id,
                        ),
                      );
                      for (int loop1Index = 0;
                          loop1Index < _model.piattiDaEliminare!.length;
                          loop1Index++) {
                        final currentLoop1Item =
                            _model.piattiDaEliminare![loop1Index];
                        await currentLoop1Item.reference.delete();
                      }
                      await widget.refCategoria!.delete();
                      Navigator.pop(context);
                      context.safePop();
                    }

                    safeSetState(() {});
                  },
                  text: 'Elimina categoria',
                  options: FFButtonOptions(
                    width: 280.0,
                    height: 45.0,
                    padding:
                        const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                    iconPadding:
                        const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                    color: theme.colorScheme.error,
                    textStyle: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.onError,
                      fontWeight: FontWeight.w600,
                    ),
                    elevation: 0.0,
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
              ].divide(const SizedBox(height: 16.0)),
            ),
          ),
        ),
      ),
    );
  }
}
