import '/admin/card_ticket_admin/card_ticket_admin_widget.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'admin_tickets_model.dart';
export 'admin_tickets_model.dart';

/// Pagina da cui io posso vedere i nuovi tickets e rispondere
class AdminTicketsWidget extends StatefulWidget {
  const AdminTicketsWidget({super.key});

  static String routeName = 'AdminTickets';
  static String routePath = '/adminTickets';

  @override
  State<AdminTicketsWidget> createState() => _AdminTicketsWidgetState();
}

class _AdminTicketsWidgetState extends State<AdminTicketsWidget> {
  late AdminTicketsModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AdminTicketsModel());

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

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FFAppState().temaPrimaryBackground,
        appBar: AppBar(
          backgroundColor: FFAppState().temaPrimary,
          automaticallyImplyLeading: false,
          leading: FlutterFlowIconButton(
            borderColor: Colors.transparent,
            borderRadius: 30.0,
            borderWidth: 1.0,
            buttonSize: 60.0,
            icon: Icon(
              Icons.arrow_back_rounded,
              color: FFAppState().temaPrimaryText,
              size: 30.0,
            ),
            onPressed: () async {
              context.pop();
            },
          ),
          title: Text(
            'Supporto clienti',
            textAlign: TextAlign.start,
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                  font: GoogleFonts.outfit(
                    fontWeight:
                        FlutterFlowTheme.of(context).headlineMedium.fontWeight,
                    fontStyle:
                        FlutterFlowTheme.of(context).headlineMedium.fontStyle,
                  ),
                  color: FFAppState().temaPrimaryText,
                  fontSize: 22.0,
                  letterSpacing: 0.0,
                  fontWeight:
                      FlutterFlowTheme.of(context).headlineMedium.fontWeight,
                  fontStyle:
                      FlutterFlowTheme.of(context).headlineMedium.fontStyle,
                ),
          ),
          actions: [],
          centerTitle: true,
          elevation: 2.0,
        ),
        body: SafeArea(
          top: true,
          child: SingleChildScrollView(
            controller: _model.columnController,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                StreamBuilder<List<TicketsRecord>>(
                  stream: queryTicketsRecord(
                    queryBuilder: (ticketsRecord) => ticketsRecord
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
                            color: FlutterFlowTheme.of(context).primary,
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
                        return CardTicketAdminWidget(
                          key: Key(
                              'Keyvhc_${listViewIndex}_of_${listViewTicketsRecordList.length}'),
                          parameter1: listViewTicketsRecord.titolo,
                          parameter2: listViewTicketsRecord.descrizione,
                          parameter3: listViewTicketsRecord.stato,
                          parameter4: listViewTicketsRecord.ristoratoreRef,
                          parameter5: listViewTicketsRecord.reference,
                          ticketCorrente: listViewTicketsRecord,
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
