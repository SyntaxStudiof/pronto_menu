import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'admin_dettaglio_ristorante_model.dart';
export 'admin_dettaglio_ristorante_model.dart';

class AdminDettaglioRistoranteWidget extends StatefulWidget {
  const AdminDettaglioRistoranteWidget({
    super.key,
    this.utenteRef,
  });

  final DocumentReference? utenteRef;

  static String routeName = 'AdminDettaglioRistorante';
  static String routePath = '/adminDettaglioRistorante';

  @override
  State<AdminDettaglioRistoranteWidget> createState() =>
      _AdminDettaglioRistoranteWidgetState();
}

class _AdminDettaglioRistoranteWidgetState
    extends State<AdminDettaglioRistoranteWidget> {
  late AdminDettaglioRistoranteModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AdminDettaglioRistoranteModel());

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

    return StreamBuilder<UsersRecord>(
      stream: UsersRecord.getDocument(widget.utenteRef!),
      builder: (context, snapshot) {
        // Customize what your widget looks like when it's loading.
        if (!snapshot.hasData) {
          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            body: Center(
              child: SizedBox(
                width: 50.0,
                height: 50.0,
                child: SpinKitPulse(
                  color: theme.colorScheme.primary,
                  size: 50.0,
                ),
              ),
            ),
          );
        }

        final adminDettaglioRistoranteUsersRecord = snapshot.data!;

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
                borderRadius: 30.0,
                borderWidth: 1.0,
                buttonSize: 40.0,
                icon: Icon(
                  Icons.arrow_back_rounded,
                  color: theme.appBarTheme.foregroundColor ?? theme.iconTheme.color,
                  size: 24.0,
                ),
                onPressed: () async {
                  context.pushNamed(AdminDashboardWidget.routeName);
                },
              ),
              title: Text(
                'Dettaglio Ristorante',
                style: theme.appBarTheme.titleTextStyle ??
                    theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 22.0,
                    ),
              ),
              actions: const [],
              centerTitle: true,
              elevation: theme.appBarTheme.elevation ?? 2.0,
            ),
            body: SafeArea(
              top: true,
              child: Align(
                alignment: const AlignmentDirectional(0.0, 0.0),
                child: SingleChildScrollView(
                  controller: _model.columnController,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        adminDettaglioRistoranteUsersRecord.displayName,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 26.0,
                        ),
                      ),
                      Text(
                        adminDettaglioRistoranteUsersRecord.email,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.hintColor,
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(0.0, 15.0, 0.0, 0.0),
                        child: FFButtonWidget(
                          onPressed: () async {
                            context.pushNamed(
                              HomeRistoratoreWidget.routeName,
                              queryParameters: {
                                'ristoranteRef': serializeParam(
                                  widget.utenteRef,
                                  ParamType.DocumentReference,
                                ),
                              }.withoutNulls,
                            );
                          },
                          text: 'Entra e Modifica Menu',
                          options: FFButtonOptions(
                            height: 40.0,
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                16.0, 0.0, 16.0, 0.0),
                            iconPadding: const EdgeInsetsDirectional.fromSTEB(
                                0.0, 0.0, 0.0, 0.0),
                            color: theme.colorScheme.primary,
                            textStyle: theme.textTheme.titleSmall?.copyWith(
                              color: theme.colorScheme.onPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                            elevation: 0.0,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(0.0, 10.0, 0.0, 0.0),
                        child: FFButtonWidget(
                          onPressed: () async {
                            final datePickedDate = await showDatePicker(
                              context: context,
                              initialDate: getCurrentTimestamp,
                              firstDate: getCurrentTimestamp,
                              lastDate: DateTime(2050),
                              builder: (context, child) {
                                return Theme(
                                  data: theme.copyWith(
                                    colorScheme: theme.colorScheme.copyWith(
                                      primary: theme.colorScheme.primary,
                                      onPrimary: theme.colorScheme.onPrimary,
                                      surface: theme.cardColor,
                                      onSurface: theme.textTheme.bodyMedium?.color ?? Colors.black,
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );

                            if (datePickedDate != null) {
                              safeSetState(() {
                                _model.datePicked = DateTime(
                                  datePickedDate.year,
                                  datePickedDate.month,
                                  datePickedDate.day,
                                );
                              });
                            } else if (_model.datePicked != null) {
                              safeSetState(() {
                                _model.datePicked = getCurrentTimestamp;
                              });
                            }
                            _model.datascadenza = _model.datePicked;
                            safeSetState(() {});

                            await adminDettaglioRistoranteUsersRecord.reference
                                .update(createUsersRecordData(
                              premiumExpiryDate: _model.datascadenza,
                            ));
                          },
                          text: 'Scegli data di scadenza',
                          options: FFButtonOptions(
                            height: 40.0,
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                16.0, 0.0, 16.0, 0.0),
                            iconPadding: const EdgeInsetsDirectional.fromSTEB(
                                0.0, 0.0, 0.0, 0.0),
                            color: theme.colorScheme.primary,
                            textStyle: theme.textTheme.titleSmall?.copyWith(
                              color: theme.colorScheme.onPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                            elevation: 0.0,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
