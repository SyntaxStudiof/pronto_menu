import '/services/translation_service.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/flutter_flow/custom_functions.dart' as functions;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'popup_tavolo_model.dart';
export 'popup_tavolo_model.dart';

class PopupTavoloWidget extends StatefulWidget {
  const PopupTavoloWidget({
    super.key,
    this.ristoranteRef,
    this.currentLang = 'it',
  });

  final DocumentReference? ristoranteRef;
  final String currentLang;

  @override
  State<PopupTavoloWidget> createState() => _PopupTavoloWidgetState();
}

class _PopupTavoloWidgetState extends State<PopupTavoloWidget> {
  late PopupTavoloModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PopupTavoloModel());

    final prefilledTable = FFAppState().numeroTavolo;
    _model.textController ??= TextEditingController(
      text: prefilledTable.isNotEmpty ? prefilledTable : '',
    );
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

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 16.0),
        child: SingleChildScrollView(
          controller: _model.columnController,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(12.0, 32.0, 12.0, 0.0),
                child: Container(
                  width: 280.0,
                  child: TextFormField(
                    controller: _model.textController,
                    focusNode: _model.textFieldFocusNode,
                    onChanged: (_) => EasyDebounce.debounce(
                      '_model.textController',
                      Duration(milliseconds: 0),
                      () => safeSetState(() {}),
                    ),
                    autofocus: false,
                    enabled: true,
                    obscureText: false,
                    decoration: InputDecoration(
                      isDense: true,
                      labelStyle: theme.textTheme.labelMedium,
                      hintText: TranslationService.getUi('inserisci_tavolo', widget.currentLang),
                      hintStyle: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.hintColor,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: theme.dividerColor,
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: theme.colorScheme.primary,
                          width: 1.0,
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
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      filled: true,
                      fillColor: theme.scaffoldBackgroundColor,
                    ),
                    style: theme.textTheme.bodyMedium,
                    keyboardType: TextInputType.number,
                    cursorColor: theme.colorScheme.primary,
                    enableInteractiveSelection: true,
                    validator:
                        _model.textControllerValidator.asValidator(context),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(12.0, 20.0, 12.0, 32.0),
                child: FFButtonWidget(
                  onPressed: (_model.textController.text == null ||
                          _model.textController.text == '')
                      ? null
                      : () async {
                          await OrdersRecord.collection.doc().set({
                            ...createOrdersRecordData(
                              tavolo: int.tryParse(_model.textController.text),
                              totale: FFAppState().totaleCarrello,
                              dataCreazione: getCurrentTimestamp,
                              statoOrdine: 'in_attesa',
                              listaPiatti: functions.unisciNomiCarrello(
                                  FFAppState().CarrelloNomi.toList()),
                              visto: false,
                              ristoranteRef: widget!.ristoranteRef,
                            ),
                            ...mapToFirestore(
                              {
                                'lista_piatti_ref': FFAppState().Carrello,
                              },
                            ),
                          });
                          Navigator.pop(context);
                          FFAppState().Carrello = [];
                          FFAppState().totaleCarrello = 0.0;
                          FFAppState().CarrelloNomi = [];
                          FFAppState().CarrelloPrezzi = [];
                          safeSetState(() {});
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Ordine inviato con successo! Lo stiamo preparando per te.',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.onPrimary,
                                ),
                              ),
                              duration: Duration(milliseconds: 3000),
                              backgroundColor: theme.colorScheme.primary,
                            ),
                          );
                          FFAppState().Carrello = [];
                          FFAppState().CarrelloNomi = [];
                          FFAppState().CarrelloPrezzi = [];
                          safeSetState(() {});
                        },
                  text: TranslationService.getUi('conferma_ordine', widget.currentLang),
                  options: FFButtonOptions(
                    width: 280.0,
                    height: 48.0,
                    padding:
                        const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                    iconPadding: EdgeInsets.zero,
                    color: theme.colorScheme.primary,
                    textStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                    elevation: 2.0,
                    borderRadius: BorderRadius.circular(12.0),
                    disabledColor: theme.disabledColor,
                    disabledTextColor: theme.hintColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
