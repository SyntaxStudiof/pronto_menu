import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'card_ticket_admin_model.dart';
export 'card_ticket_admin_model.dart';

class CardTicketAdminWidget extends StatefulWidget {
  const CardTicketAdminWidget({
    super.key,
    this.parameter1,
    this.parameter2,
    this.parameter3,
    this.parameter4,
    this.parameter5,
    required this.ticketCorrente,
  });

  final String? parameter1;
  final String? parameter2;
  final String? parameter3;
  final DocumentReference? parameter4;
  final DocumentReference? parameter5;
  final TicketsRecord? ticketCorrente;

  @override
  State<CardTicketAdminWidget> createState() => _CardTicketAdminWidgetState();
}

class _CardTicketAdminWidgetState extends State<CardTicketAdminWidget> {
  late CardTicketAdminModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CardTicketAdminModel());

    _model.testoRispostaTextController ??= TextEditingController();
    _model.testoRispostaFocusNode ??= FocusNode();

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

    final isAperto = widget.ticketCorrente?.stato == 'Aperto';

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.5),
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
      padding: const EdgeInsets.all(22.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  valueOrDefault<String>(
                    widget.ticketCorrente?.titolo,
                    'Senza titolo',
                  ),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              const SizedBox(width: 12.0),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 5.0),
                decoration: BoxDecoration(
                  color: isAperto ? const Color(0xFFFEF3E2) : const Color(0xFFE6F4EA),
                  borderRadius: BorderRadius.circular(20.0),
                  border: Border.all(
                    color: isAperto ? const Color(0xFFFFD8A8) : const Color(0xFFB7EB8F),
                    width: 1.0,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7.0,
                      height: 7.0,
                      decoration: BoxDecoration(
                        color: isAperto ? const Color(0xFFE37400) : const Color(0xFF137333),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6.0),
                    Text(
                      valueOrDefault<String>(
                        widget.ticketCorrente?.stato,
                        'Stato',
                      ),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: isAperto ? const Color(0xFFB05A00) : const Color(0xFF0F5A27),
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12.0),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14.0),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(14.0),
              border: Border.all(
                color: theme.dividerColor.withValues(alpha: 0.5),
                width: 1.0,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DESCRIZIONE PROBLEMA',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.hintColor,
                    fontSize: 11.0,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 6.0),
                Text(
                  valueOrDefault<String>(
                    widget.ticketCorrente?.descrizione,
                    'Nessuna descrizione fornita',
                  ),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 14.5,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12.0),
          if (widget.parameter4 != null)
            StreamBuilder<UsersRecord>(
              stream: UsersRecord.getDocument(widget.parameter4!),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const SizedBox.shrink();
                }
                final emailUsersRecord = snapshot.data!;
                return Row(
                  children: [
                    Icon(
                      Icons.mail_outline_rounded,
                      size: 16.0,
                      color: theme.hintColor,
                    ),
                    const SizedBox(width: 6.0),
                    Text(
                      'Ristoratore: ',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.hintColor,
                        fontSize: 13.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      emailUsersRecord.email,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 13.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                );
              },
            ),
          const SizedBox(height: 16.0),
          if (widget.ticketCorrente?.stato == 'Aperto')
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _model.testoRispostaTextController,
                  focusNode: _model.testoRispostaFocusNode,
                  autofocus: false,
                  enabled: true,
                  obscureText: false,
                  maxLines: 3,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(14.0),
                    hintText: 'Scrivi qui la risposta per il ristoratore...',
                    hintStyle: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.hintColor,
                      fontSize: 14.0,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: theme.dividerColor.withValues(alpha: 0.5),
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(14.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: theme.colorScheme.primary,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(14.0),
                    ),
                    filled: true,
                    fillColor: theme.scaffoldBackgroundColor,
                  ),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 14.5,
                  ),
                  cursorColor: theme.colorScheme.primary,
                  validator: _model.testoRispostaTextControllerValidator.asValidator(context),
                ),
                const SizedBox(height: 12.0),
                Align(
                  alignment: Alignment.centerRight,
                  child: FFButtonWidget(
                    onPressed: () async {
                      if (_model.testoRispostaTextController.text.trim().isEmpty) {
                        return;
                      }
                      await widget.ticketCorrente!.reference.update(createTicketsRecordData(
                        rispostaAdmin: _model.testoRispostaTextController.text,
                        stato: 'Risolto',
                      ));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Risposta inviata al ristoratore!',
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: theme.colorScheme.onPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          duration: const Duration(milliseconds: 3000),
                          backgroundColor: theme.colorScheme.primary,
                        ),
                      );
                    },
                    text: 'Invia Risposta',
                    options: FFButtonOptions(
                      height: 44.0,
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      color: theme.colorScheme.primary,
                      textStyle: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.onPrimary,
                        fontSize: 14.5,
                        fontWeight: FontWeight.bold,
                      ),
                      elevation: 0.0,
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                ),
              ],
            ),
          if (widget.ticketCorrente?.stato == 'Risolto')
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14.0),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(14.0),
                border: Border.all(
                  color: const Color(0xFFC8E6C9),
                  width: 1.0,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        color: Color(0xFF2E7D32),
                        size: 16.0,
                      ),
                      const SizedBox(width: 6.0),
                      Text(
                        'RISPOSTA FORNITA DALL\'ADMIN',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: const Color(0xFF2E7D32),
                          fontSize: 11.0,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6.0),
                  Text(
                    valueOrDefault<String>(
                      widget.ticketCorrente?.rispostaAdmin,
                      'Nessun messaggio di risposta registrato.',
                    ),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF1B5E20),
                      fontSize: 14.0,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
