import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
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
  bool _isSubmitting = false;

  final List<String> _risposteRapide = [
    'Problema risolto con successo! ✅',
    'Configurazione aggiornata. Riprova ora 🚀',
    'Ti abbiamo contattato direttamente per risolvere 💬',
    'Stiamo verificando la segnalazione e ti aggiorniamo a breve 🔍',
  ];

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

  Future<void> _inviaRisposta(ThemeData theme) async {
    final risposta = _model.testoRispostaTextController.text.trim();
    if (risposta.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Scrivi un messaggio di risposta')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await widget.ticketCorrente!.reference.update(createTicketsRecordData(
        rispostaAdmin: risposta,
        stato: 'Risolto',
        rispostaLetta: false,
      ));

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle_rounded,
                  color: Colors.white, size: 20.0),
              SizedBox(width: 10.0),
              Text(
                'Risposta inviata e ticket contrassegnato come Risolto!',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          backgroundColor: Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
        ),
      );

      setState(() {
        _isSubmitting = false;
        _model.testoRispostaTextController?.clear();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Errore durante l\'aggiornamento: $e'),
          backgroundColor: theme.colorScheme.error,
        ),
      );
    }
  }

  Future<void> _riapriTicket() async {
    await widget.ticketCorrente!.reference.update(createTicketsRecordData(
      stato: 'Aperto',
    ));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Ticket riaperto con successo'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final isAperto = widget.ticketCorrente?.stato == 'Aperto';
    final dataCreazione = widget.ticketCorrente?.dataCreazione;
    final dataStr = dataCreazione != null
        ? dateTimeFormat('d MMM y, HH:mm', dataCreazione)
        : '';

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(
          color: isAperto
              ? Colors.orange.withValues(alpha: 0.35)
              : theme.dividerColor.withValues(alpha: 0.12),
          width: isAperto ? 1.3 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 16.0,
            color: Colors.black.withValues(alpha: 0.04),
            offset: const Offset(0.0, 4.0),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Data, Titolo e Badge di Stato
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (dataStr.isNotEmpty)
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 13.0,
                            color: theme.hintColor,
                          ),
                          const SizedBox(width: 4.0),
                          Text(
                            dataStr,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.hintColor,
                              fontSize: 11.5,
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 4.0),
                    Text(
                      valueOrDefault<String>(
                        widget.ticketCorrente?.titolo,
                        'Richiesta senza titolo',
                      ),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 17.5,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12.0),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.5),
                decoration: BoxDecoration(
                  color: (isAperto ? Colors.orange : const Color(0xFF10B981))
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(
                    color: (isAperto ? Colors.orange : const Color(0xFF10B981))
                        .withValues(alpha: 0.30),
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
                        color: isAperto
                            ? Colors.orange.shade700
                            : const Color(0xFF10B981),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5.0),
                    Text(
                      isAperto ? 'IN ATTESA' : 'RISOLTO',
                      style: TextStyle(
                        fontSize: 11.0,
                        fontWeight: FontWeight.bold,
                        color: isAperto
                            ? Colors.orange.shade800
                            : const Color(0xFF047857),
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14.0),

          // Stream Ristoratore Info
          if (widget.ticketCorrente?.ristoratoreRef != null)
            StreamBuilder<UsersRecord>(
              stream:
                  UsersRecord.getDocument(widget.ticketCorrente!.ristoratoreRef!),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox.shrink();
                final rest = snapshot.data!;
                final String restNome = rest.displayName.isNotEmpty
                    ? rest.displayName
                    : 'Ristorante senza nome';

                return Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12.0, vertical: 8.0),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(
                      color: colorScheme.primary.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 32.0,
                        height: 32.0,
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: rest.photoUrl.isNotEmpty
                            ? ClipOval(
                                child: Image.network(
                                  rest.photoUrl,
                                  width: 32.0,
                                  height: 32.0,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Icon(
                                    Icons.restaurant_rounded,
                                    size: 16.0,
                                    color: colorScheme.primary,
                                  ),
                                ),
                              )
                            : Icon(
                                Icons.restaurant_rounded,
                                size: 16.0,
                                color: colorScheme.primary,
                              ),
                      ),
                      const SizedBox(width: 10.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              restNome,
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 13.0,
                              ),
                            ),
                            Text(
                              rest.email,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.hintColor,
                                fontSize: 11.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (rest.phoneNumber.isNotEmpty) ...[
                        const SizedBox(width: 8.0),
                        Icon(
                          Icons.phone_rounded,
                          size: 14.0,
                          color: theme.hintColor,
                        ),
                        const SizedBox(width: 4.0),
                        Text(
                          rest.phoneNumber,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          const SizedBox(height: 14.0),

          // Box Descrizione del Problema
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14.0),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(14.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.help_outline_rounded,
                      size: 14.0,
                      color: theme.hintColor,
                    ),
                    const SizedBox(width: 6.0),
                    Text(
                      'SEGNALAZIONE DEL CLIENTE',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.hintColor,
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6.0),
                Text(
                  valueOrDefault<String>(
                    widget.ticketCorrente?.descrizione,
                    'Nessuna descrizione fornita',
                  ),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 14.0,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16.0),

          // SEZIONE AZIONE ADMIN: RISPONDI (SE APERTO) O MOSTRA RISPOSTA (SE RISOLTO)
          if (isAperto) ...[
            Text(
              'Risposte rapide:',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 11.5,
                color: theme.hintColor,
              ),
            ),
            const SizedBox(height: 6.0),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _risposteRapide.map((r) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 6.0),
                    child: ActionChip(
                      label: Text(r),
                      labelStyle: TextStyle(
                        fontSize: 11.0,
                        color: colorScheme.onSurface,
                      ),
                      backgroundColor:
                          colorScheme.primary.withValues(alpha: 0.08),
                      side: BorderSide(
                        color: colorScheme.primary.withValues(alpha: 0.20),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      onPressed: () {
                        setState(() {
                          _model.testoRispostaTextController.text = r;
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 10.0),
            TextFormField(
              controller: _model.testoRispostaTextController,
              focusNode: _model.testoRispostaFocusNode,
              autofocus: false,
              enabled: !_isSubmitting,
              maxLines: 3,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.all(14.0),
                hintText: 'Scrivi qui la risposta per il ristoratore...',
                hintStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.hintColor,
                  fontSize: 13.5,
                ),
                filled: true,
                fillColor: theme.scaffoldBackgroundColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14.0),
                  borderSide: BorderSide(
                    color: theme.dividerColor.withValues(alpha: 0.15),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14.0),
                  borderSide: BorderSide(
                    color: theme.dividerColor.withValues(alpha: 0.15),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14.0),
                  borderSide: BorderSide(
                    color: colorScheme.primary,
                    width: 1.5,
                  ),
                ),
              ),
              style: theme.textTheme.bodyMedium?.copyWith(fontSize: 14.0),
              cursorColor: colorScheme.primary,
            ),
            const SizedBox(height: 12.0),
            Align(
              alignment: Alignment.centerRight,
              child: FFButtonWidget(
                onPressed: _isSubmitting ? null : () => _inviaRisposta(theme),
                text: _isSubmitting
                    ? 'Invio in corso...'
                    : 'Invia Risposta & Risolvi Ticket',
                icon: _isSubmitting
                    ? null
                    : const Icon(
                        Icons.check_circle_rounded,
                        size: 16.0,
                        color: Colors.white,
                      ),
                options: FFButtonOptions(
                  height: 42.0,
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  color: colorScheme.primary,
                  textStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                  ),
                  elevation: 0.0,
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),
          ] else ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14.0),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14.0),
                border: Border.all(
                  color: const Color(0xFF10B981).withValues(alpha: 0.25),
                  width: 1.0,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            color: Color(0xFF047857),
                            size: 15.0,
                          ),
                          SizedBox(width: 6.0),
                          Text(
                            'RISPOSTA FORNITA DALL\'ADMIN',
                            style: TextStyle(
                              color: Color(0xFF047857),
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      InkWell(
                        onTap: _riapriTicket,
                        borderRadius: BorderRadius.circular(6.0),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6.0, vertical: 2.0),
                          child: Text(
                            'Riapri ticket',
                            style: TextStyle(
                              fontSize: 11.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange.shade800,
                              decoration: TextDecoration.underline,
                            ),
                          ),
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
                      color: const Color(0xFF064E3B),
                      fontSize: 14.0,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
