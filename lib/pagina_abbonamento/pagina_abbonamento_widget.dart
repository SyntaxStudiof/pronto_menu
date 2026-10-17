import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import '/index.dart';
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
    final isPremium = valueOrDefault<bool>(currentUserDocument?.isPremium, false);
    final String tier = currentUserDocument?.pianoAbbonamento ?? (isPremium ? 'ultra' : 'nessuno');
    final String interval = currentUserDocument?.intervalloAbbonamento ?? 'mensile';
    final isAnnual = interval == 'annuale';

    String nomePiano;
    String prezzoPiano;
    Color tierColor;
    String tierBadge;

    switch (tier) {
      case 'pro':
        nomePiano = 'ProntoMenu Pro';
        prezzoPiano = isAnnual ? '69,90€ / anno' : '6,90€ / mese';
        tierColor = const Color(0xFF0D9488);
        tierBadge = 'PRO';
        break;
      case 'plus':
        nomePiano = 'ProntoMenu Plus';
        prezzoPiano = isAnnual ? '109,90€ / anno' : '11,90€ / mese';
        tierColor = theme.colorScheme.primary;
        tierBadge = 'PLUS ⭐';
        break;
      case 'ultra':
      default:
        nomePiano = 'ProntoMenu Ultra';
        prezzoPiano = isAnnual ? '289,90€ / anno' : '29,90€ / mese';
        tierColor = const Color(0xFF7C3AED);
        tierBadge = 'ULTRA 👑';
        break;
    }

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
                          color: tierColor.withValues(alpha: 0.6),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 16.0,
                            color: tierColor.withValues(alpha: 0.06),
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
                                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 5.0),
                                decoration: BoxDecoration(
                                  color: tierColor.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                child: Text(
                                  tierBadge,
                                  style: TextStyle(
                                    color: tierColor,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.6,
                                  ),
                                ),
                              ),
                              Text(
                                prezzoPiano,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: tierColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14.0),
                          Text(
                            nomePiano,
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
                          const SizedBox(height: 16.0),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    context.pushNamed(AbbonamentoWidget.routeName);
                                  },
                                  icon: const Icon(Icons.swap_horiz_rounded, size: 18.0),
                                  label: const Text('Cambia piano / Upgrade'),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24.0),

                    // Servizi Inclusi nel tuo piano
                    Text(
                      'Servizi attivi con il tuo piano ($nomePiano)',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.5,
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
                            icon: Icons.qr_code_2_rounded,
                            iconColor: const Color(0xFF0D9488),
                            title: 'Menu Digitale QR Code nativo',
                            desc: 'Accesso istantaneo senza app con categorie, sottocategorie e allergeni',
                            isIncluded: true,
                          ),
                          _buildServiceTile(
                            context,
                            icon: Icons.receipt_long_rounded,
                            iconColor: const Color(0xFFE65100),
                            title: 'Ricezione ordini dal vivo & Prenotazioni',
                            desc: 'Notifiche in tempo reale e gestione prenotazioni direttamente sull\'app',
                            isIncluded: tier == 'plus' || tier == 'ultra',
                            requiredPlan: 'Plus / Ultra',
                          ),
                          _buildServiceTile(
                            context,
                            icon: Icons.soup_kitchen_rounded,
                            iconColor: const Color(0xFF00897B),
                            title: 'Schermi dedicati Cucina e Cassa',
                            desc: 'Avanzamento stati piatti (in preparazione, pronto, servito) e totale cassa',
                            isIncluded: tier == 'plus' || tier == 'ultra',
                            requiredPlan: 'Plus / Ultra',
                          ),
                          _buildServiceTile(
                            context,
                            icon: Icons.auto_awesome_motion_rounded,
                            iconColor: const Color(0xFF673AB7),
                            title: 'Menù Mutaforma (Più Menù)',
                            desc: 'Gestione automatica o manuale di menu per pranzo, cena ed eventi speciali',
                            isIncluded: tier == 'plus' || tier == 'ultra',
                            requiredPlan: 'Plus / Ultra',
                          ),
                          _buildServiceTile(
                            context,
                            icon: Icons.palette_rounded,
                            iconColor: const Color(0xFFF4511E),
                            title: 'Personalizzazione grafica del Brand',
                            desc: 'Colori personalizzati, tema dell\'app e stile coordinato del locale',
                            isIncluded: tier == 'plus' || tier == 'ultra',
                            requiredPlan: 'Plus / Ultra',
                          ),
                          _buildServiceTile(
                            context,
                            icon: Icons.music_note_rounded,
                            iconColor: const Color(0xFF8E24AA),
                            title: 'Jukebox Digitale per i clienti',
                            desc: 'I commensali propongono e votano la musica del locale dal proprio tavolo',
                            isIncluded: tier == 'ultra',
                            requiredPlan: 'Ultra',
                          ),
                          _buildServiceTile(
                            context,
                            icon: Icons.sports_esports_rounded,
                            iconColor: const Color(0xFF5E35B1),
                            title: 'Giochi ai tavoli (Tris & Quiz del Gusto)',
                            desc: 'Intrattenimento esclusivo al tavolo per azzerare i tempi di attesa',
                            isIncluded: tier == 'ultra',
                            requiredPlan: 'Ultra',
                          ),
                          _buildServiceTile(
                            context,
                            icon: Icons.bar_chart_rounded,
                            iconColor: const Color(0xFF0288D1),
                            title: 'Statistiche e analisi ordini',
                            desc: 'Report vendite in tempo reale e classifica piatti più ordinati',
                            isIncluded: tier == 'ultra',
                            requiredPlan: 'Ultra',
                          ),
                          _buildServiceTile(
                            context,
                            icon: Icons.delete_sweep_rounded,
                            iconColor: const Color(0xFF546E7A),
                            title: 'Cestino di sicurezza e recupero',
                            desc: 'Ripristino rapido di piatti o categorie eliminate per sbaglio',
                            isIncluded: tier == 'ultra',
                            requiredPlan: 'Ultra',
                          ),
                          _buildServiceTile(
                            context,
                            icon: Icons.percent_rounded,
                            iconColor: const Color(0xFF2E7D32),
                            title: 'Zero commissioni sul venduto',
                            desc: '0% di trattenute, l\'intero incasso rimane sempre al 100% tuo',
                            isIncluded: true,
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
    required bool isIncluded,
    String? requiredPlan,
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
              color: isIncluded
                  ? iconColor.withValues(alpha: 0.12)
                  : theme.dividerColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.0),
            ),
            alignment: Alignment.center,
            child: Icon(
              icon,
              color: isIncluded ? iconColor : theme.hintColor.withValues(alpha: 0.6),
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
                    color: isIncluded ? null : theme.hintColor,
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
          Padding(
            padding: const EdgeInsets.only(top: 2.0),
            child: isIncluded
                ? const Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFF2E7D32),
                    size: 18.0,
                  )
                : Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                    decoration: BoxDecoration(
                      color: theme.dividerColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                    child: Text(
                      requiredPlan ?? 'Upgrade',
                      style: TextStyle(
                        color: theme.hintColor,
                        fontSize: 10.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
