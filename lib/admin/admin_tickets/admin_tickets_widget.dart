import '/admin/card_ticket_admin/card_ticket_admin_widget.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
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
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          elevation: 0.0,
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
              context.safePop();
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
                  Icons.support_agent_rounded,
                  color: theme.colorScheme.primary,
                  size: 20.0,
                ),
              ),
              const SizedBox(width: 10.0),
              Text(
                'Supporto clienti',
                style: theme.appBarTheme.titleTextStyle ??
                    theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 19.0,
                      letterSpacing: -0.4,
                    ),
              ),
            ],
          ),
          actions: const [
            SizedBox(width: 48.0),
          ],
          centerTitle: true,
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
                            constraints: const BoxConstraints(maxWidth: 440.0),
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
                                  blurRadius: 20.0,
                                  color: Colors.black.withValues(alpha: 0.04),
                                  offset: const Offset(0.0, 6.0),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Icona con cerchi concentrici e badge
                                Stack(
                                  alignment: Alignment.center,
                                  clipBehavior: Clip.none,
                                  children: [
                                    Container(
                                      width: 88.0,
                                      height: 88.0,
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.primary
                                            .withValues(alpha: 0.08),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    Container(
                                      width: 68.0,
                                      height: 68.0,
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.primary
                                            .withValues(alpha: 0.15),
                                        shape: BoxShape.circle,
                                      ),
                                      alignment: Alignment.center,
                                      child: Icon(
                                        Icons.support_agent_rounded,
                                        color: theme.colorScheme.primary,
                                        size: 36.0,
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 2.0,
                                      right: 2.0,
                                      child: Container(
                                        padding: const EdgeInsets.all(4.0),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF10B981),
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: theme.cardColor,
                                            width: 2.5,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(0xFF10B981)
                                                  .withValues(alpha: 0.35),
                                              blurRadius: 6.0,
                                              offset: const Offset(0.0, 2.0),
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.check_rounded,
                                          color: Colors.white,
                                          size: 14.0,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 22.0),

                                // Badge di stato positivo
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14.0,
                                    vertical: 6.0,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF10B981)
                                        .withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(30.0),
                                    border: Border.all(
                                      color: const Color(0xFF10B981)
                                          .withValues(alpha: 0.28),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.verified_rounded,
                                        size: 15.0,
                                        color: Color(0xFF10B981),
                                      ),
                                      const SizedBox(width: 6.0),
                                      Text(
                                        'Zero ticket in sospeso',
                                        style: theme.textTheme.labelMedium
                                            ?.copyWith(
                                          color: const Color(0xFF10B981),
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 18.0),

                                // Titolo
                                Text(
                                  'Nessuna richiesta di supporto',
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20.0,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                const SizedBox(height: 8.0),

                                // Descrizione
                                Text(
                                  'Ottime notizie! Tutti i ticket sono stati gestiti o nessun ristoratore ha aperto segnalazioni al momento.',
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.hintColor,
                                    height: 1.5,
                                    fontSize: 14.0,
                                  ),
                                ),
                                const SizedBox(height: 24.0),

                                // Box informativo
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(14.0),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.surface
                                        .withValues(alpha: 0.5),
                                    borderRadius: BorderRadius.circular(16.0),
                                    border: Border.all(
                                      color: theme.dividerColor
                                          .withValues(alpha: 0.12),
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(6.0),
                                            decoration: BoxDecoration(
                                              color: theme.colorScheme.primary
                                                  .withValues(alpha: 0.12),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.bolt_rounded,
                                              size: 16.0,
                                              color: theme.colorScheme.primary,
                                            ),
                                          ),
                                          const SizedBox(width: 10.0),
                                          Expanded(
                                            child: Text(
                                              'I nuovi ticket appariranno qui in tempo reale.',
                                              style: theme.textTheme.bodySmall
                                                  ?.copyWith(
                                                color: theme.hintColor,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10.0),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(6.0),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF3B82F6)
                                                  .withValues(alpha: 0.12),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons
                                                  .notifications_active_outlined,
                                              size: 16.0,
                                              color: Color(0xFF3B82F6),
                                            ),
                                          ),
                                          const SizedBox(width: 10.0),
                                          Expanded(
                                            child: Text(
                                              'Puoi rispondere e risolvere le richieste direttamente da qui.',
                                              style: theme.textTheme.bodySmall
                                                  ?.copyWith(
                                                color: theme.hintColor,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
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
