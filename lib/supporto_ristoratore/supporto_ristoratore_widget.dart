import '/auth/firebase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'supporto_ristoratore_model.dart';
export 'supporto_ristoratore_model.dart';

/// Pagina per creare nuovi tickets o vedere quelli già esistenti
class SupportoRistoratoreWidget extends StatefulWidget {
  const SupportoRistoratoreWidget({
    super.key,
    this.ristoranteRef,
  });

  final DocumentReference? ristoranteRef;

  static String routeName = 'SupportoRistoratore';
  static String routePath = '/supportoRistoratore';

  @override
  State<SupportoRistoratoreWidget> createState() =>
      _SupportoRistoratoreWidgetState();
}

class _SupportoRistoratoreWidgetState extends State<SupportoRistoratoreWidget> {
  late SupportoRistoratoreModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SupportoRistoratoreModel());

    _model.switchValue = false;
    _model.titoloTicketTextController ??= TextEditingController();
    _model.titoloTicketFocusNode ??= FocusNode();

    _model.descrizioneTicketTextController ??= TextEditingController();
    _model.descrizioneTicketFocusNode ??= FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: theme.appBarTheme.backgroundColor ?? theme.cardColor,
          automaticallyImplyLeading: false,
          leading: FlutterFlowIconButton(
            borderColor: Colors.transparent,
            borderRadius: 24.0,
            borderWidth: 1.0,
            buttonSize: 40.0,
            icon: Icon(
              Icons.arrow_back_rounded,
              color: theme.appBarTheme.foregroundColor ?? theme.iconTheme.color,
              size: 24.0,
            ),
            onPressed: () async {
              context.pushNamed(
                HomeRistoratoreWidget.routeName,
                queryParameters: {
                  'ristoranteRef': serializeParam(
                    widget.ristoranteRef,
                    ParamType.DocumentReference,
                  ),
                }.withoutNulls,
                extra: <String, dynamic>{
                  '__transition_info__': const TransitionInfo(
                    hasTransition: true,
                    transitionType: PageTransitionType.leftToRight,
                  ),
                },
              );
            },
          ),
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36.0,
                height: 36.0,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.help_outline_rounded,
                  color: theme.colorScheme.primary,
                  size: 20.0,
                ),
              ),
              const SizedBox(width: 10.0),
              Text(
                'Supporto',
                style: theme.appBarTheme.titleTextStyle ??
                    theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                      letterSpacing: -0.4,
                    ),
              ),
            ],
          ),
          centerTitle: true,
          actions: const [
            SizedBox(width: 48.0),
          ],
          elevation: 0.0,
        ),
        body: SafeArea(
          top: true,
          child: Align(
            alignment: const AlignmentDirectional(0.0, -1.0),
            child: SingleChildScrollView(
              controller: _model.columnController1,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding:
                        const EdgeInsetsDirectional.fromSTEB(0.0, 10.0, 0.0, 10.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Crea nuovo ticket',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Switch.adaptive(
                          value: _model.switchValue!,
                          onChanged: (newValue) async {
                            safeSetState(() => _model.switchValue = newValue);
                          },
                          activeColor: theme.colorScheme.primary,
                          activeTrackColor: theme.colorScheme.primary.withValues(alpha: 0.38),
                          inactiveTrackColor: theme.dividerColor,
                          inactiveThumbColor: theme.cardColor,
                        ),
                        Text(
                          'Visualizza i ticket',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 300.0,
                    child: Divider(
                      thickness: 2.0,
                      color: theme.dividerColor,
                    ),
                  ),
                  if (_model.switchValue == false)
                    Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        RichText(
                          textScaler: MediaQuery.of(context).textScaler,
                          text: TextSpan(
                            style: theme.textTheme.bodyMedium,
                            children: [
                              TextSpan(
                                text: 'Compila ',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(
                                text: 'i campi sottostanti e ',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              TextSpan(
                                text: 'invia ',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(
                                text: 'la tua richiesta',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              )
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(
                          width: 300.0,
                          child: TextFormField(
                            controller: _model.titoloTicketTextController,
                            focusNode: _model.titoloTicketFocusNode,
                            autofocus: false,
                            enabled: true,
                            obscureText: false,
                            decoration: InputDecoration(
                              isDense: true,
                              labelText: 'Oggetto del problema',
                              labelStyle: theme.textTheme.labelMedium,
                              hintText: 'Oggetto del problema',
                              hintStyle: theme.textTheme.labelMedium?.copyWith(
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
                              fillColor: theme.cardColor,
                            ),
                            style: theme.textTheme.bodyMedium,
                            cursorColor: theme.colorScheme.primary,
                            enableInteractiveSelection: true,
                            validator: _model
                                .titoloTicketTextControllerValidator
                                .asValidator(context),
                          ),
                        ),
                        SizedBox(
                          width: 300.0,
                          child: TextFormField(
                            controller: _model.descrizioneTicketTextController,
                            focusNode: _model.descrizioneTicketFocusNode,
                            autofocus: false,
                            enabled: true,
                            obscureText: false,
                            decoration: InputDecoration(
                              isDense: true,
                              labelText: 'Descrivi il problema',
                              labelStyle: theme.textTheme.labelMedium,
                              hintText: 'Descrivi il problema nel dettaglio...',
                              hintStyle: theme.textTheme.labelMedium?.copyWith(
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
                              fillColor: theme.cardColor,
                            ),
                            style: theme.textTheme.bodyMedium,
                            maxLines: 5,
                            cursorColor: theme.colorScheme.primary,
                            enableInteractiveSelection: true,
                            validator: _model
                                .descrizioneTicketTextControllerValidator
                                .asValidator(context),
                          ),
                        ),
                        FFButtonWidget(
                          onPressed: () async {
                            await TicketsRecord.collection
                                .doc()
                                .set(createTicketsRecordData(
                                  titolo:
                                      _model.titoloTicketTextController.text,
                                  descrizione: _model
                                      .descrizioneTicketTextController.text,
                                  ristoratoreRef: currentUserReference,
                                  dataCreazione: getCurrentTimestamp,
                                  stato: 'Aperto',
                                ));
                            await InviaNotificaWhatsAppCall.call(
                              messaggioTicket:
                                  '🚨 Nuovo Ticket su ProntoMenu! Problema:${_model.titoloTicketTextController.text}',
                            );

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Ticket inviato con successo! Ti risponderemo per email a breve.',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                duration: const Duration(milliseconds: 4000),
                                backgroundColor: theme.colorScheme.primary,
                              ),
                            );
                            safeSetState(() {
                              _model.titoloTicketTextController?.clear();
                              _model.descrizioneTicketTextController?.clear();
                            });
                          },
                          text: 'Invia Richiesta di Aiuto',
                          options: FFButtonOptions(
                            width: 280.0,
                            height: 45.0,
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                16.0, 0.0, 16.0, 0.0),
                            iconPadding: const EdgeInsetsDirectional.fromSTEB(
                                0.0, 0.0, 0.0, 0.0),
                            color: theme.colorScheme.primary,
                            textStyle: const TextStyle(
                              color: Colors.white,
                              fontSize: 15.0,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.3,
                            ),
                            elevation: 2.0,
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                      ].divide(const SizedBox(height: 12.0)),
                    ),
                  if (_model.switchValue == true)
                    SingleChildScrollView(
                      controller: _model.columnController2,
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          StreamBuilder<List<TicketsRecord>>(
                            stream: queryTicketsRecord(
                              queryBuilder: (ticketsRecord) => ticketsRecord
                                  .where(
                                    'ristoratore_ref',
                                    isEqualTo: currentUserReference,
                                  )
                                  .orderBy('data_creazione', descending: true),
                            ),
                            builder: (context, snapshot) {
                              // Customize what your widget looks like when it's loading.
                              if (!snapshot.hasData) {
                                return Center(
                                  child: SizedBox(
                                    width: 50.0,
                                    height: 50.0,
                                    child: SpinKitPulse(
                                      color: theme.colorScheme.primary,
                                      size: 50.0,
                                    ),
                                  ),
                                );
                              }
                              List<TicketsRecord> listViewTicketsRecordList =
                                  snapshot.data!;

                              return ListView.builder(
                                padding: EdgeInsets.zero,
                                primary: false,
                                shrinkWrap: true,
                                scrollDirection: Axis.vertical,
                                itemCount: listViewTicketsRecordList.length,
                                itemBuilder: (context, listViewIndex) {
                                  final listViewTicketsRecord =
                                      listViewTicketsRecordList[listViewIndex];
                                  return Padding(
                                    padding: const EdgeInsetsDirectional.fromSTEB(
                                        16.0, 16.0, 16.0, 0.0),
                                    child: Card(
                                      clipBehavior: Clip.antiAliasWithSaveLayer,
                                      color: theme.cardColor,
                                      elevation: 2.0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Padding(
                                            padding:
                                                const EdgeInsetsDirectional.fromSTEB(
                                                    0.0, 10.0, 0.0, 0.0),
                                            child: Text(
                                              listViewTicketsRecord.titolo,
                                              style: theme.textTheme.titleMedium?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18.0,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            listViewTicketsRecord.descrizione,
                                            style: theme.textTheme.bodyMedium?.copyWith(
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          SizedBox(
                                            width: 200.0,
                                            child: Divider(
                                              thickness: 2.0,
                                              color: theme.dividerColor,
                                            ),
                                          ),
                                          Text(
                                            listViewTicketsRecord.stato,
                                            style: theme.textTheme.bodyMedium?.copyWith(
                                              color: theme.colorScheme.primary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          SizedBox(
                                            width: 200.0,
                                            child: Divider(
                                              thickness: 2.0,
                                              color: theme.dividerColor,
                                            ),
                                          ),
                                          if (listViewTicketsRecord.stato ==
                                              'Risolto')
                                            Padding(
                                              padding: const EdgeInsetsDirectional
                                                  .fromSTEB(
                                                      0.0, 0.0, 0.0, 10.0),
                                              child: Text(
                                                listViewTicketsRecord
                                                    .rispostaAdmin,
                                                style: theme.textTheme.bodyMedium?.copyWith(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 16.0,
                                                ),
                                              ),
                                            ),
                                        ].divide(const SizedBox(height: 12.0)),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
