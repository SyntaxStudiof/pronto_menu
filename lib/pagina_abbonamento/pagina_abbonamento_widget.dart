import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import 'package:flutter/material.dart';
import 'pagina_abbonamento_model.dart';
export 'pagina_abbonamento_model.dart';

class PaginaAbbonamentoWidget extends StatefulWidget {
  const PaginaAbbonamentoWidget({super.key});

  static String routeName = 'paginaAbbonamento';
  static String routePath = '/paginaAbbonamento';

  @override
  State<PaginaAbbonamentoWidget> createState() =>
      _PaginaAbbonamentoWidgetState();
}

class _PaginaAbbonamentoWidgetState extends State<PaginaAbbonamentoWidget> {
  late PaginaAbbonamentoModel _model;
  bool _mostraModuloDisdetta = false;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PaginaAbbonamentoModel());

    _model.textController ??= TextEditingController();
    _model.textFieldFocusNode ??= FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          automaticallyImplyLeading: false,
          elevation: 0.0,
          leading: FlutterFlowIconButton(
            borderColor: Colors.transparent,
            borderRadius: 24.0,
            borderWidth: 1.0,
            buttonSize: 40.0,
            icon: Icon(
              Icons.arrow_back_rounded,
              color: theme.colorScheme.onSurface,
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
                  Icons.workspace_premium_rounded,
                  color: theme.colorScheme.primary,
                  size: 20.0,
                ),
              ),
              const SizedBox(width: 10.0),
              Text(
                'Gestisci abbonamento',
                style: theme.appBarTheme.titleTextStyle ??
                    theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 19.0,
                      letterSpacing: -0.4,
                      color: theme.colorScheme.onSurface,
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
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
            child: Center(
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxWidth: 580.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Card Riepilogo Abbonamento Attivo
                    Container(
                      padding: const EdgeInsets.all(22.0),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(20.0),
                        border: Border.all(
                          color: theme.dividerColor.withValues(alpha: 0.6),
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8F5E9),
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.check_circle_rounded,
                                      size: 14.0,
                                      color: Color(0xFF2E7D32),
                                    ),
                                    SizedBox(width: 4.0),
                                    Text(
                                      'PIANO ATTIVO',
                                      style: TextStyle(
                                        color: Color(0xFF2E7D32),
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '19,90€ / mese',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14.0),
                          Text(
                            'Piano Pro Ristoratore',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 22.0,
                              letterSpacing: -0.4,
                            ),
                          ),
                          const SizedBox(height: 4.0),
                          Row(
                            children: [
                              Icon(
                                Icons.email_outlined,
                                size: 14.0,
                                color: theme.hintColor,
                              ),
                              const SizedBox(width: 6.0),
                              Expanded(
                                child: Text(
                                  currentUserEmail,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.hintColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12.0),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                            decoration: BoxDecoration(
                              color: theme.scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.verified_outlined,
                                  color: Color(0xFF2D6A4F),
                                  size: 18.0,
                                ),
                                const SizedBox(width: 8.0),
                                Expanded(
                                  child: Text(
                                    'Accesso a tutti i 12 servizi della piattaforma • 0% commissioni',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24.0),

                    // Servizi Abilitati
                    Text(
                      'I tuoi servizi inclusi',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 17.0,
                      ),
                    ),
                    const SizedBox(height: 12.0),

                    Container(
                      padding: const EdgeInsets.all(18.0),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(18.0),
                        border: Border.all(
                          color: theme.dividerColor.withValues(alpha: 0.6),
                        ),
                      ),
                      child: Column(
                        children: [
                          _buildServiceTile(
                            context,
                            icon: Icons.receipt_long_rounded,
                            iconColor: const Color(0xFFE65100),
                            title: 'Ricezione ordini in tempo reale',
                            desc: 'Notifiche e gestione comande istantanee dai tavoli',
                          ),
                          _buildServiceTile(
                            context,
                            icon: Icons.soup_kitchen_rounded,
                            iconColor: const Color(0xFF00897B),
                            title: 'Schermi dedicati Cucina e Cassa',
                            desc: 'Avanzamento piatti e totale conti con filtri rapidi',
                          ),
                          _buildServiceTile(
                            context,
                            icon: Icons.qr_code_2_rounded,
                            iconColor: const Color(0xFF1E88E5),
                            title: 'Menu QR Code illimitato',
                            desc: 'Accesso da smartphone per ogni tavolo senza scaricare app',
                          ),
                          _buildServiceTile(
                            context,
                            icon: Icons.restaurant_menu_rounded,
                            iconColor: const Color(0xFFD81B60),
                            title: 'Catalogo illimitato & Allergeni',
                            desc: 'Foto HD, varianti, ingredienti e filtri allergeni completi',
                          ),
                          _buildServiceTile(
                            context,
                            icon: Icons.format_list_bulleted_rounded,
                            iconColor: const Color(0xFF3949AB),
                            title: 'Categorie e sottocategorie',
                            desc: 'Ordinamento rapido e organizzazione personalizzata',
                          ),
                          _buildServiceTile(
                            context,
                            icon: Icons.music_note_rounded,
                            iconColor: const Color(0xFF8E24AA),
                            title: 'Jukebox Digitale clienti',
                            desc: 'Richiesta e votazione brani con approvazione del locale',
                          ),
                          _buildServiceTile(
                            context,
                            icon: Icons.sports_esports_rounded,
                            iconColor: const Color(0xFF5E35B1),
                            title: 'Giochi ai tavoli (Tris & Quiz)',
                            desc: 'Intrattenimento esclusivo al tavolo tra commensali',
                          ),
                          _buildServiceTile(
                            context,
                            icon: Icons.palette_rounded,
                            iconColor: const Color(0xFFF4511E),
                            title: 'Personalizzazione del Brand',
                            desc: 'Logo, cover, contatti, orari e colori aziendali',
                          ),
                          _buildServiceTile(
                            context,
                            icon: Icons.bar_chart_rounded,
                            iconColor: const Color(0xFF0288D1),
                            title: 'Statistiche e analisi vendite',
                            desc: 'Report ordini e piatti più venduti in tempo reale',
                          ),
                          _buildServiceTile(
                            context,
                            icon: Icons.delete_sweep_rounded,
                            iconColor: const Color(0xFF546E7A),
                            title: 'Cestino di sicurezza e ripristino',
                            desc: 'Recupero immediato di piatti o categorie cancellate',
                          ),
                          _buildServiceTile(
                            context,
                            icon: Icons.percent_rounded,
                            iconColor: const Color(0xFF2E7D32),
                            title: 'Zero commissioni sul venduto',
                            desc: '100% dell\'incasso rimane sempre al ristorante',
                          ),
                          _buildServiceTile(
                            context,
                            icon: Icons.support_agent_rounded,
                            iconColor: const Color(0xFF00ACC1),
                            title: 'Assistenza & Supporto ticket in-app',
                            desc: 'Canale prioritario e aggiornamenti continui inclusi',
                            isLast: true,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28.0),

                    // Sezione Disdetta
                    Container(
                      padding: const EdgeInsets.all(18.0),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(18.0),
                        border: Border.all(
                          color: theme.dividerColor.withValues(alpha: 0.6),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: () {
                              setState(() {
                                _mostraModuloDisdetta = !_mostraModuloDisdetta;
                              });
                            },
                            borderRadius: BorderRadius.circular(10.0),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4.0),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.help_outline_rounded,
                                    color: theme.hintColor,
                                    size: 20.0,
                                  ),
                                  const SizedBox(width: 10.0),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Vuoi disdire l\'abbonamento?',
                                          style: theme.textTheme.titleSmall?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          'Nessun vincolo, puoi inviare una richiesta in qualsiasi momento',
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            color: theme.hintColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    _mostraModuloDisdetta
                                        ? Icons.keyboard_arrow_up_rounded
                                        : Icons.keyboard_arrow_down_rounded,
                                    color: theme.hintColor,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          if (_mostraModuloDisdetta) ...[
                            const Divider(height: 24.0),
                            Text(
                              'Motivo della disdetta (opzionale):',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            FlutterFlowDropDown<String>(
                              controller: _model.dropDownValueController ??=
                                  FormFieldController<String>(
                                _model.dropDownValue ??= 'Preferisco non dirlo',
                              ),
                              options: const [
                                'Preferisco non dirlo',
                                'Troppo costoso',
                                'Non uso abbastanza il servizio',
                                'Ho trovato un\'alternativa migliore',
                                'Altro'
                              ],
                              onChanged: (val) =>
                                  safeSetState(() => _model.dropDownValue = val),
                              width: double.infinity,
                              height: 48.0,
                              textStyle: theme.textTheme.bodyMedium ?? const TextStyle(),
                              icon: const Icon(
                                Icons.keyboard_arrow_down_rounded,
                                size: 24.0,
                              ),
                              elevation: 2.0,
                              borderColor: theme.dividerColor,
                              borderWidth: 1.0,
                              borderRadius: 10.0,
                              margin: const EdgeInsetsDirectional.fromSTEB(14.0, 0.0, 14.0, 0.0),
                              hidesUnderline: true,
                              isOverButton: false,
                              isSearchable: false,
                              isMultiSelect: false,
                            ),
                            const SizedBox(height: 14.0),
                            Text(
                              'Vuoi aggiungere qualcosa? (opzionale)',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            TextFormField(
                              controller: _model.textController,
                              focusNode: _model.textFieldFocusNode,
                              autofocus: false,
                              enabled: true,
                              obscureText: false,
                              maxLines: 3,
                              decoration: InputDecoration(
                                isDense: true,
                                hintText: 'Dicci come possiamo migliorare...',
                                hintStyle: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.hintColor,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: theme.dividerColor,
                                    width: 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: theme.colorScheme.primary,
                                    width: 1.5,
                                  ),
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                filled: true,
                                fillColor: theme.scaffoldBackgroundColor,
                              ),
                              style: theme.textTheme.bodyMedium,
                              enableInteractiveSelection: true,
                              validator: _model.textControllerValidator.asValidator(context),
                            ),
                            const SizedBox(height: 12.0),
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time_rounded,
                                  size: 14.0,
                                  color: theme.hintColor,
                                ),
                                const SizedBox(width: 6.0),
                                Expanded(
                                  child: Text(
                                    'La richiesta verrà elaborata entro 24-48 ore',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.hintColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16.0),
                            FFButtonWidget(
                              onPressed: () async {
                                await CancellationRequestsRecord.collection
                                    .doc()
                                    .set(createCancellationRequestsRecordData(
                                      email: currentUserEmail,
                                      requestedAt: getCurrentTimestamp,
                                      status: 'pending',
                                      motivo: _model.dropDownValue,
                                      nota: _model.textController.text,
                                    ));
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Richiesta inviata! Ti contatteremo entro 24-48 ore.',
                                    ),
                                    duration: Duration(milliseconds: 4000),
                                  ),
                                );
                                context.safePop();
                              },
                              text: 'Invia richiesta disdetta',
                              options: FFButtonOptions(
                                width: double.infinity,
                                height: 46.0,
                                padding: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                                iconPadding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                                color: theme.colorScheme.error,
                                textStyle: theme.textTheme.titleSmall?.copyWith(
                                  color: theme.colorScheme.onError,
                                  fontWeight: FontWeight.bold,
                                ),
                                elevation: 0.0,
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 24.0),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildServiceTile(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String desc,
    bool isLast = false,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, isLast ? 0.0 : 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34.0,
            height: 34.0,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8.0),
            ),
            alignment: Alignment.center,
            child: Icon(
              icon,
              color: iconColor,
              size: 18.0,
            ),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 13.5,
                  ),
                ),
                Text(
                  desc,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.hintColor,
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8.0),
          const Padding(
            padding: EdgeInsets.only(top: 2.0),
            child: Icon(
              Icons.check_circle_rounded,
              color: Color(0xFF2E7D32),
              size: 16.0,
            ),
          ),
        ],
      ),
    );
  }
}
