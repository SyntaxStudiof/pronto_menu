import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'miei_ticket_model.dart';
export 'miei_ticket_model.dart';

/// pagina da cui posso vedere i ticket risposti
class MieiTicketWidget extends StatefulWidget {
  const MieiTicketWidget({super.key});

  static String routeName = 'MieiTicket';
  static String routePath = '/mieiTicket';

  @override
  State<MieiTicketWidget> createState() => _MieiTicketWidgetState();
}

class _MieiTicketWidgetState extends State<MieiTicketWidget> {
  late MieiTicketModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MieiTicketModel());

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
            borderRadius: 30.0,
            borderWidth: 1.0,
            buttonSize: 60.0,
            icon: Icon(
              Icons.arrow_back_rounded,
              color: theme.appBarTheme.foregroundColor ?? theme.iconTheme.color,
              size: 24.0,
            ),
            onPressed: () async {
              context.pop();
            },
          ),
          title: Text(
            'Miei tickets',
            textAlign: TextAlign.center,
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
          child: SingleChildScrollView(
            controller: _model.columnController,
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

                    if (listViewTicketsRecordList.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24.0,
                          vertical: 48.0,
                        ),
                        child: Center(
                          child: Container(
                            width: double.infinity,
                            constraints: const BoxConstraints(maxWidth: 420.0),
                            padding: const EdgeInsets.all(28.0),
                            decoration: BoxDecoration(
                              color: theme.cardColor,
                              borderRadius: BorderRadius.circular(24.0),
                              border: Border.all(
                                color:
                                    theme.dividerColor.withValues(alpha: 0.15),
                                width: 1.0,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  blurRadius: 16.0,
                                  color: Colors.black.withValues(alpha: 0.04),
                                  offset: const Offset(0.0, 4.0),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 76.0,
                                  height: 76.0,
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary
                                        .withValues(alpha: 0.12),
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: Alignment.center,
                                  child: Icon(
                                    Icons.chat_bubble_outline_rounded,
                                    color: theme.colorScheme.primary,
                                    size: 36.0,
                                  ),
                                ),
                                const SizedBox(height: 20.0),
                                Text(
                                  'Nessun ticket inviato',
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 19.0,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                const SizedBox(height: 8.0),
                                Text(
                                  'Non hai ancora inviato nessuna richiesta di assistenza. Se hai bisogno di aiuto o riscontri un problema, puoi aprire un nuovo ticket.',
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.hintColor,
                                    height: 1.5,
                                    fontSize: 14.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }

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
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
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
                                Text(
                                  listViewTicketsRecord.stato,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (listViewTicketsRecord.stato == 'Risolto')
                                  Padding(
                                    padding: const EdgeInsetsDirectional.fromSTEB(
                                        0.0, 0.0, 0.0, 10.0),
                                    child: Text(
                                      listViewTicketsRecord.rispostaAdmin,
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
        ),
      ),
    );
  }
}
