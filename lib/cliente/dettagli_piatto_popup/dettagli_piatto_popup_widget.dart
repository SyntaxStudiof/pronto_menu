import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:styled_divider/styled_divider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';
import 'dettagli_piatto_popup_model.dart';
export 'dettagli_piatto_popup_model.dart';

class DettagliPiattoPopupWidget extends StatefulWidget {
  const DettagliPiattoPopupWidget({
    super.key,
    required this.piattoSelezionato,
  });

  final PiattiRecord? piattoSelezionato;

  @override
  State<DettagliPiattoPopupWidget> createState() =>
      _DettagliPiattoPopupWidgetState();
}

class _DettagliPiattoPopupWidgetState extends State<DettagliPiattoPopupWidget> {
  late DettagliPiattoPopupModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DettagliPiattoPopupModel());

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

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.7,
      ),
      decoration: BoxDecoration(
        color: FFAppState().temaSecondaryBackground,
      ),
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(16.0, 10.0, 16.0, 10.0),
        child: SingleChildScrollView(
          controller: _model.columnController,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Align(
                    alignment: AlignmentDirectional(0.0, 0.0),
                    child: CircularPercentIndicator(
                      percent: 1.0,
                      radius: 122.5,
                      lineWidth: 40.0,
                      animation: true,
                      animateFromLastPercent: true,
                      progressColor: FFAppState().temaPrimary,
                      backgroundColor: FFAppState().temaSecondary,
                      center: Text(
                        '50%',
                        style:
                            FlutterFlowTheme.of(context).headlineSmall.override(
                                  font: GoogleFonts.outfit(
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .headlineSmall
                                        .fontStyle,
                                  ),
                                  color: FFAppState().temaTertiary,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.bold,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .headlineSmall
                                      .fontStyle,
                                ),
                      ),
                    ),
                  ),
                  if (widget!.piattoSelezionato?.foto != null &&
                      widget!.piattoSelezionato?.foto != '')
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.network(
                        valueOrDefault<String>(
                          widget!.piattoSelezionato?.foto,
                          'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/pronto-menu-f0och1/assets/2n9hc9ugo68c/Immagine_standard.png',
                        ),
                        width: double.infinity,
                        height: 250.0,
                        fit: BoxFit.cover,
                      ),
                    ),
                ],
              ),
              Text(
                valueOrDefault<String>(
                  widget!.piattoSelezionato?.nome,
                  'Piatto assente',
                ),
                textAlign: TextAlign.center,
                style: FlutterFlowTheme.of(context).headlineSmall.override(
                      font: GoogleFonts.outfit(
                        fontWeight: FlutterFlowTheme.of(context)
                            .headlineSmall
                            .fontWeight,
                        fontStyle: FlutterFlowTheme.of(context)
                            .headlineSmall
                            .fontStyle,
                      ),
                      color: FFAppState().temaPrimaryText,
                      letterSpacing: 0.0,
                      fontWeight:
                          FlutterFlowTheme.of(context).headlineSmall.fontWeight,
                      fontStyle:
                          FlutterFlowTheme.of(context).headlineSmall.fontStyle,
                    ),
              ),
              if (widget!.piattoSelezionato?.ingredienti != null &&
                  widget!.piattoSelezionato?.ingredienti != '')
                SizedBox(
                  width: 290.0,
                  child: StyledDivider(
                    thickness: 1.0,
                    color: FFAppState().temaAlternate,
                    lineStyle: DividerLineStyle.dashdotted,
                  ),
                ),
              if (widget!.piattoSelezionato?.ingredienti != null &&
                  widget!.piattoSelezionato?.ingredienti != '')
                Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Text(
                      'Ingredienti:',
                      textAlign: TextAlign.center,
                      style: FlutterFlowTheme.of(context).titleMedium.override(
                            font: GoogleFonts.outfit(
                              fontWeight: FlutterFlowTheme.of(context)
                                  .titleMedium
                                  .fontWeight,
                              fontStyle: FlutterFlowTheme.of(context)
                                  .titleMedium
                                  .fontStyle,
                            ),
                            color: FFAppState().temaPrimaryText,
                            letterSpacing: 0.0,
                            fontWeight: FlutterFlowTheme.of(context)
                                .titleMedium
                                .fontWeight,
                            fontStyle: FlutterFlowTheme.of(context)
                                .titleMedium
                                .fontStyle,
                          ),
                    ),
                    Text(
                      valueOrDefault<String>(
                        widget!.piattoSelezionato?.ingredienti,
                        'Ingredienti assenti',
                      ),
                      textAlign: TextAlign.center,
                      style: FlutterFlowTheme.of(context).titleMedium.override(
                            font: GoogleFonts.outfit(
                              fontWeight: FlutterFlowTheme.of(context)
                                  .titleMedium
                                  .fontWeight,
                              fontStyle: FlutterFlowTheme.of(context)
                                  .titleMedium
                                  .fontStyle,
                            ),
                            color: FFAppState().temaPrimaryText,
                            fontSize: 18.0,
                            letterSpacing: 0.0,
                            fontWeight: FlutterFlowTheme.of(context)
                                .titleMedium
                                .fontWeight,
                            fontStyle: FlutterFlowTheme.of(context)
                                .titleMedium
                                .fontStyle,
                          ),
                    ),
                  ],
                ),
              if (widget!.piattoSelezionato?.descrizione != null &&
                  widget!.piattoSelezionato?.descrizione != '')
                SizedBox(
                  width: 290.0,
                  child: StyledDivider(
                    thickness: 1.0,
                    color: FFAppState().temaAlternate,
                    lineStyle: DividerLineStyle.dashdotted,
                  ),
                ),
              if (widget!.piattoSelezionato?.descrizione != null &&
                  widget!.piattoSelezionato?.descrizione != '')
                Text(
                  valueOrDefault<String>(
                    widget!.piattoSelezionato?.descrizione,
                    'Descrizione assente',
                  ),
                  textAlign: TextAlign.center,
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.openSans(
                          fontWeight: FontWeight.w500,
                          fontStyle:
                              FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                        ),
                        color: FFAppState().temaPrimaryText,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.w500,
                        fontStyle:
                            FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                      ),
                ),
              if (widget!.piattoSelezionato?.prezzo != null)
                SizedBox(
                  width: 290.0,
                  child: StyledDivider(
                    thickness: 1.0,
                    color: FFAppState().temaAlternate,
                    lineStyle: DividerLineStyle.dashdotted,
                  ),
                ),
              if (widget!.piattoSelezionato?.prezzo != null)
                Text(
                  formatNumber(
                    widget!.piattoSelezionato!.prezzo,
                    formatType: FormatType.decimal,
                    decimalType: DecimalType.commaDecimal,
                    currency: '€',
                  ),
                  textAlign: TextAlign.center,
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.openSans(
                          fontWeight: FlutterFlowTheme.of(context)
                              .bodyMedium
                              .fontWeight,
                          fontStyle:
                              FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                        ),
                        color: FFAppState().temaPrimaryText,
                        letterSpacing: 0.0,
                        fontWeight:
                            FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                        fontStyle:
                            FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                      ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
