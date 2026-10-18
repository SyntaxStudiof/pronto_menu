import '/auth/firebase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'impostazioni_utente_model.dart';

export 'impostazioni_utente_model.dart';

class ImpostazioniUtenteWidget extends StatefulWidget {
  const ImpostazioniUtenteWidget({
    super.key,
    this.ristoranteRef,
    this.embedded = false,
  });

  final DocumentReference? ristoranteRef;
  final bool embedded;

  static String routeName = 'impostazioniUtente';
  static String routePath = '/impostazioniUtente';

  @override
  State<ImpostazioniUtenteWidget> createState() =>
      _ImpostazioniUtenteWidgetState();
}

class _ImpostazioniUtenteWidgetState extends State<ImpostazioniUtenteWidget> {
  late ImpostazioniUtenteModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ImpostazioniUtenteModel());
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
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    // Palette fedele al design system della Dashboard
    final bgCanvas = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: bgCanvas,
        appBar: widget.embedded
            ? null
            : AppBar(
                backgroundColor: bgCanvas,
                elevation: 0.0,
                scrolledUnderElevation: 0.0,
                automaticallyImplyLeading: false,
                leading: FlutterFlowIconButton(
                  borderColor: Colors.transparent,
                  borderRadius: 24.0,
                  borderWidth: 1.0,
                  buttonSize: 40.0,
                  icon: Icon(
                    Icons.arrow_back_rounded,
                    color: colorScheme.onSurface,
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
                        color: colorScheme.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.settings_rounded,
                        color: colorScheme.primary,
                        size: 20.0,
                      ),
                    ),
                    const SizedBox(width: 10.0),
                    Text(
                      'Impostazioni',
                      style: theme.appBarTheme.titleTextStyle ??
                          theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 19.0,
                            letterSpacing: -0.4,
                            color: colorScheme.onSurface,
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
          child: Align(
            alignment: Alignment.topCenter,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isDesktop = widget.embedded || constraints.maxWidth >= 850;

                return ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: isDesktop ? 1200.0 : 680.0),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: isDesktop ? 28.0 : 18.0,
                      vertical: 20.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ── Header intro ──────────────────────────────────────────
                        Padding(
                          padding: const EdgeInsets.only(left: 4.0, bottom: 24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Preferenze & Configurazione',
                                style: TextStyle(
                                  fontSize: 22.0,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.5,
                                  color: textPrimary,
                                ),
                              ),
                              const SizedBox(height: 6.0),
                              Text(
                                'Gestisci le preferenze del menu, le opzioni di ordinazione dei clienti e le impostazioni del locale.',
                                style: TextStyle(
                                  fontSize: 14.0,
                                  color: textSecondary,
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),

                        if (isDesktop)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ═════════════════════════════════════════════════════
                              // COLONNA SINISTRA: Menù & Ordini
                              // ═════════════════════════════════════════════════════
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    _buildStrutturaMenuSection(context, isDark, colorScheme),
                                    const SizedBox(height: 24.0),
                                    _buildRegoleOrdiniDispensaSection(context, isDark, colorScheme),
                                    const SizedBox(height: 24.0),
                                    _buildMutaformaSection(context, isDark, colorScheme),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 24.0),
                              // ═════════════════════════════════════════════════════
                              // COLONNA DESTRA: Account, Servizi & Privacy
                              // ═════════════════════════════════════════════════════
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    _buildAccountSection(context, isDark, colorScheme),
                                    const SizedBox(height: 24.0),
                                    _buildJukeboxSection(context, isDark, colorScheme),
                                    const SizedBox(height: 24.0),
                                    _buildPrivacySection(context, isDark, colorScheme),
                                  ],
                                ),
                              ),
                            ],
                          )
                        else ...[
                          _buildStrutturaMenuSection(context, isDark, colorScheme),
                          const SizedBox(height: 22.0),
                          _buildRegoleOrdiniDispensaSection(context, isDark, colorScheme),
                          const SizedBox(height: 22.0),
                          _buildMutaformaSection(context, isDark, colorScheme),
                          const SizedBox(height: 22.0),
                          _buildAccountSection(context, isDark, colorScheme),
                          const SizedBox(height: 22.0),
                          _buildJukeboxSection(context, isDark, colorScheme),
                          const SizedBox(height: 22.0),
                          _buildPrivacySection(context, isDark, colorScheme),
                        ],

                        const SizedBox(height: 40.0),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 1. STRUTTURA & PORTATE DEL MENÙ
  // (Nota: "Personalizzazione" rimossa perché già presente nel menù laterale)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildStrutturaMenuSection(BuildContext context, bool isDark, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionHeader(
          context: context,
          title: 'Struttura & Portate',
          icon: Icons.format_list_bulleted_rounded,
          color: const Color(0xFF3B82F6),
        ),
        const SizedBox(height: 8.0),
        _buildSettingsCard(
          context: context,
          isDark: isDark,
          children: [
            _buildSettingsTile(
              context: context,
              icon: Icons.sort_rounded,
              iconBgColor: const Color(0xFF3B82F6).withValues(alpha: 0.12),
              iconColor: const Color(0xFF3B82F6),
              title: 'Ordina categorie',
              subtitle: 'Organizza la sequenza di visualizzazione delle portate',
              onTap: () {
                context.pushNamed(
                  ImpostazioniCategorieWidget.routeName,
                  extra: <String, dynamic>{
                    '__transition_info__': const TransitionInfo(
                      hasTransition: true,
                      transitionType: PageTransitionType.rightToLeft,
                    ),
                  },
                );
              },
            ),
            _buildDivider(isDark),
            _buildSettingsTile(
              context: context,
              icon: Icons.account_tree_rounded,
              iconBgColor: const Color(0xFF8B5CF6).withValues(alpha: 0.12),
              iconColor: const Color(0xFF8B5CF6),
              title: 'Gestione sottocategorie',
              subtitle: 'Modifica, crea o elimina le sottocategorie del menu',
              onTap: () {
                context.pushNamed(
                  ImpostazioniSottocategorieWidget.routeName,
                  extra: <String, dynamic>{
                    '__transition_info__': const TransitionInfo(
                      hasTransition: true,
                      transitionType: PageTransitionType.rightToLeft,
                    ),
                  },
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 2. DISPENSA & ORDINAZIONI CLIENTI
  // (Nota: "Apri Dispensa" rimosso perché già presente nel menù laterale)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildRegoleOrdiniDispensaSection(BuildContext context, bool isDark, ColorScheme colorScheme) {
    final dispensaAttiva = valueOrDefault<bool>(currentUserDocument?.dispensaAttiva, false);
    final modificheAttive = valueOrDefault<bool>(currentUserDocument?.modifichePiattiAttive, true);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionHeader(
          context: context,
          title: 'Dispensa & Regole Ordini',
          icon: Icons.kitchen_rounded,
          color: const Color(0xFFF97316),
        ),
        const SizedBox(height: 8.0),
        _buildSettingsCard(
          context: context,
          isDark: isDark,
          children: [
            _buildSettingsSwitchTile(
              context: context,
              icon: Icons.kitchen_rounded,
              iconBgColor: const Color(0xFFF97316).withValues(alpha: 0.12),
              iconColor: const Color(0xFFF97316),
              title: 'Modulo Dispensa',
              subtitle:
                  'Traccia scorte, autocompleta ingredienti dei piatti e sbarra quelli esauriti nel menu cliente',
              value: dispensaAttiva,
              onChanged: (val) async {
                await currentUserReference?.update({
                  'dispensa_attiva': val,
                });
                safeSetState(() {});
              },
            ),
            _buildDivider(isDark),
            _buildSettingsSwitchTile(
              context: context,
              icon: Icons.tune_rounded,
              iconBgColor: const Color(0xFF10B981).withValues(alpha: 0.12),
              iconColor: const Color(0xFF10B981),
              title: 'Personalizzazione Piatti dai Clienti',
              subtitle: dispensaAttiva
                  ? 'I clienti possono aggiungere ingredienti abilitati nella dispensa o toglierne dai piatti'
                  : 'I clienti possono scrivere a mano libera le aggiunte desiderate o togliere ingredienti',
              value: modificheAttive,
              onChanged: (val) async {
                await currentUserReference?.update({
                  'modifiche_piatti_attive': val,
                });
                safeSetState(() {});
              },
            ),
            if (!dispensaAttiva && modificheAttive) ...[
              _buildDivider(isDark),
              _buildSettingsTile(
                context: context,
                icon: Icons.price_change_rounded,
                iconBgColor: const Color(0xFF3B82F6).withValues(alpha: 0.12),
                iconColor: const Color(0xFF3B82F6),
                title: 'Prezzo Aggiunta Manuale',
                subtitle:
                    'Costo per ingrediente scritto a mano dal cliente: € ${(currentUserDocument?.prezzoAggiuntaManuale ?? 0.0).toStringAsFixed(2)}',
                onTap: () => _mostraDialogPrezzoManuale(
                  context,
                  currentUserDocument?.prezzoAggiuntaManuale ?? 0.0,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 3. MENÙ MUTAFORMA (FASCE ORARIE)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildMutaformaSection(BuildContext context, bool isDark, ColorScheme colorScheme) {
    final mutaformaAttivo = valueOrDefault<bool>(currentUserDocument?.menuMutaformaAttivo, false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionHeader(
          context: context,
          title: 'Menù Mutaforma (Fasce Orarie)',
          icon: Icons.auto_awesome_rounded,
          color: const Color(0xFF6366F1),
        ),
        const SizedBox(height: 8.0),
        _buildSettingsCard(
          context: context,
          isDark: isDark,
          children: [
            _buildSettingsSwitchTile(
              context: context,
              icon: Icons.auto_awesome_rounded,
              iconBgColor: const Color(0xFF6366F1).withValues(alpha: 0.12),
              iconColor: const Color(0xFF6366F1),
              title: 'Attiva Menù Mutaforma',
              subtitle:
                  'Mostra ai clienti il menù adatto in base all\'orario (Colazione, Pranzo, Aperitivo, Cena).',
              trailingBadge: (currentUserDocument != null && !currentUserDocument!.hasPlus)
                  ? _buildTierBadge('PLUS', const Color(0xFF6366F1))
                  : null,
              value: mutaformaAttivo,
              onChanged: (val) async {
                if (currentUserDocument != null && !currentUserDocument!.hasPlus) {
                  _mostraUpgradePrompt(
                    context,
                    requiredPlan: 'Plus',
                    featureName: 'I Menù Mutaforma per fasce orarie',
                  );
                  return;
                }
                await currentUserReference?.update({
                  'menu_mutaforma_attivo': val,
                });
                safeSetState(() {});
              },
            ),
            if (mutaformaAttivo) ...[
              _buildDivider(isDark),
              _buildSettingsTile(
                context: context,
                icon: Icons.schedule_rounded,
                iconBgColor: const Color(0xFF4F46E5).withValues(alpha: 0.12),
                iconColor: const Color(0xFF4F46E5),
                title: 'Configura Fasce Orarie & Menù',
                subtitle:
                    'Crea fasce orarie e assegna quali categorie mostrare ai clienti',
                onTap: () {
                  context.pushNamed(
                    ImpostazioniMutaformaWidget.routeName,
                    extra: <String, dynamic>{
                      '__transition_info__': const TransitionInfo(
                        hasTransition: true,
                        transitionType: PageTransitionType.rightToLeft,
                      ),
                    },
                  );
                },
              ),
            ],
          ],
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 4. ACCOUNT & PIANO
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildAccountSection(BuildContext context, bool isDark, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionHeader(
          context: context,
          title: 'Account & Piano',
          icon: Icons.workspace_premium_rounded,
          color: const Color(0xFFF59E0B),
        ),
        const SizedBox(height: 8.0),
        _buildSettingsCard(
          context: context,
          isDark: isDark,
          children: [
            _buildSettingsTile(
              context: context,
              icon: Icons.workspace_premium_rounded,
              iconBgColor: const Color(0xFFF59E0B).withValues(alpha: 0.12),
              iconColor: const Color(0xFFF59E0B),
              title: 'Gestisci abbonamento',
              subtitle: 'Piano attivo, rinnovo, fatturazione e vantaggi',
              onTap: () {
                context.pushNamed(
                  PaginaAbbonamentoWidget.routeName,
                  extra: <String, dynamic>{
                    '__transition_info__': const TransitionInfo(
                      hasTransition: true,
                      transitionType: PageTransitionType.rightToLeft,
                    ),
                  },
                );
              },
            ),
            if (FFAppState().loginProvider == 'password') ...[
              _buildDivider(isDark),
              _buildSettingsTile(
                context: context,
                icon: Icons.lock_reset_rounded,
                iconBgColor: const Color(0xFF8B5CF6).withValues(alpha: 0.12),
                iconColor: const Color(0xFF8B5CF6),
                title: 'Cambia password',
                subtitle: 'Aggiorna le credenziali di accesso al locale',
                onTap: () {
                  context.pushNamed(
                    CambiaPasswordWidget.routeName,
                    extra: <String, dynamic>{
                      '__transition_info__': const TransitionInfo(
                        hasTransition: true,
                        transitionType: PageTransitionType.rightToLeft,
                      ),
                    },
                  );
                },
              ),
            ],
          ],
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 5. INTRATTENIMENTO & JUKEBOX
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildJukeboxSection(BuildContext context, bool isDark, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionHeader(
          context: context,
          title: 'Intrattenimento & Jukebox',
          icon: Icons.music_note_rounded,
          color: const Color(0xFF1DB954),
        ),
        const SizedBox(height: 8.0),
        _buildSettingsCard(
          context: context,
          isDark: isDark,
          children: [
            _buildSettingsTile(
              context: context,
              icon: Icons.music_note_rounded,
              iconBgColor: const Color(0xFF1DB954).withValues(alpha: 0.12),
              iconColor: const Color(0xFF1DB954),
              title: 'Jukebox & Musica',
              subtitle:
                  'Consenti ai clienti di richiedere brani dalla tua playlist Spotify',
              trailingBadge: (currentUserDocument != null && !currentUserDocument!.hasUltra)
                  ? _buildTierBadge('ULTRA', const Color(0xFF7C3AED))
                  : null,
              onTap: () {
                if (currentUserDocument != null && !currentUserDocument!.hasUltra) {
                  _mostraUpgradePrompt(
                    context,
                    requiredPlan: 'Ultra',
                    featureName: 'Il Jukebox Digitale e la musica per i clienti',
                  );
                  return;
                }
                context.pushNamed(
                  ImpostazioniJukeboxWidget.routeName,
                  extra: <String, dynamic>{
                    '__transition_info__': const TransitionInfo(
                      hasTransition: true,
                      transitionType: PageTransitionType.rightToLeft,
                    ),
                  },
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 6. INFORMAZIONI & PRIVACY
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildPrivacySection(BuildContext context, bool isDark, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionHeader(
          context: context,
          title: 'Info & Note Legali',
          icon: Icons.shield_outlined,
          color: const Color(0xFF10B981),
        ),
        const SizedBox(height: 8.0),
        _buildSettingsCard(
          context: context,
          isDark: isDark,
          children: [
            _buildSettingsTile(
              context: context,
              icon: Icons.shield_outlined,
              iconBgColor: const Color(0xFF10B981).withValues(alpha: 0.12),
              iconColor: const Color(0xFF10B981),
              title: 'Informativa sulla privacy',
              subtitle: 'Trattamento dei dati personali, cookie e termini legali',
              onTap: () {
                context.pushNamed(
                  PrivacyPolicyWidget.routeName,
                  extra: <String, dynamic>{
                    '__transition_info__': const TransitionInfo(
                      hasTransition: true,
                      transitionType: PageTransitionType.rightToLeft,
                    ),
                  },
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // COMPONENTI GRAFICI DI STILE DASHBOARD
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildSectionHeader({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
      child: Row(
        children: [
          Container(
            width: 26.0,
            height: 26.0,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(7.0),
            ),
            child: Icon(icon, size: 14.5, color: color),
          ),
          const SizedBox(width: 8.0),
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard({
    required BuildContext context,
    required bool isDark,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.03),
            blurRadius: 10.0,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }

  Widget _buildSettingsTile({
    required BuildContext context,
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailingBadge,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: colorScheme.primary.withValues(alpha: 0.08),
        highlightColor: colorScheme.primary.withValues(alpha: 0.04),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          child: Row(
            children: [
              Container(
                width: 40.0,
                height: 40.0,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(11.0),
                ),
                child: Center(
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 20.0,
                  ),
                ),
              ),
              const SizedBox(width: 14.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15.0,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2.5),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailingBadge != null) ...[
                const SizedBox(width: 8.0),
                trailingBadge,
              ],
              const SizedBox(width: 8.0),
              Icon(
                Icons.chevron_right_rounded,
                color: isDark ? const Color(0xFF475569) : const Color(0xFF94A3B8),
                size: 22.0,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsSwitchTile({
    required BuildContext context,
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    Widget? trailingBadge,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 13.0),
      child: Row(
        children: [
          Container(
            width: 40.0,
            height: 40.0,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(11.0),
            ),
            child: Center(
              child: Icon(
                icon,
                color: iconColor,
                size: 20.0,
              ),
            ),
          ),
          const SizedBox(width: 14.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15.0,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2.5),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          if (trailingBadge != null) ...[
            const SizedBox(width: 8.0),
            trailingBadge,
          ],
          const SizedBox(width: 8.0),
          Switch(
            value: value,
            activeTrackColor: colorScheme.primary.withValues(alpha: 0.45),
            activeThumbColor: colorScheme.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildTierBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6.0),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _mostraUpgradePrompt(
    BuildContext context, {
    required String requiredPlan,
    required String featureName,
  }) {
    final theme = Theme.of(context);
    final isUltra = requiredPlan.toLowerCase().contains('ultra');
    final accentColor = isUltra ? const Color(0xFF7C3AED) : theme.colorScheme.primary;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (bContext) => Container(
        padding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 32.0),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24.0),
            topRight: Radius.circular(24.0),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50.0,
              height: 50.0,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(
                isUltra ? Icons.workspace_premium_rounded : Icons.lock_rounded,
                color: accentColor,
                size: 26.0,
              ),
            ),
            const SizedBox(height: 14.0),
            Text(
              'Funzionalità ProntoMenu $requiredPlan',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              '$featureName è disponibile con il piano ProntoMenu $requiredPlan.\nPassa al piano superiore per sbloccare questo strumento!',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.hintColor,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 20.0),
            SizedBox(
              width: double.infinity,
              height: 48.0,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(bContext);
                  context.pushNamed(AbbonamentoWidget.routeName);
                },
                icon: const Icon(Icons.arrow_upward_rounded, size: 18.0),
                label: Text('Passa a ProntoMenu $requiredPlan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _mostraDialogPrezzoManuale(BuildContext context, double prezzoAttuale) async {
    final controller = TextEditingController(
      text: prezzoAttuale > 0
          ? (prezzoAttuale % 1 == 0
              ? prezzoAttuale.toInt().toString()
              : prezzoAttuale.toStringAsFixed(2))
          : '1.00',
    );
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    await showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        title: Row(
          children: [
            Container(
              width: 36.0,
              height: 36.0,
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10.0),
              ),
              alignment: Alignment.center,
              child: Icon(Icons.euro_rounded, color: colorScheme.primary, size: 20.0),
            ),
            const SizedBox(width: 10.0),
            const Expanded(
              child: Text(
                'Prezzo aggiunta',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Imposta il costo addebitato per ciascuna aggiunta manuale scritta dal cliente (0 per gratuita).',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.hintColor,
                fontSize: 13.0,
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Costo per aggiunta (€)',
                hintText: 'Es. 1.00',
                prefixIcon: Icon(Icons.euro_rounded, color: colorScheme.primary),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14.0)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text('Annulla', style: TextStyle(color: theme.hintColor)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
            ),
            onPressed: () async {
              final val = double.tryParse(controller.text.trim().replaceAll(',', '.')) ?? 0.0;
              await currentUserReference?.update({
                'prezzo_aggiunta_manuale': val,
              });
              if (dialogCtx.mounted) Navigator.pop(dialogCtx);
              safeSetState(() {});
            },
            child: const Text('Salva'),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1.0,
      thickness: 1.0,
      indent: 70.0,
      endIndent: 16.0,
      color: isDark
          ? const Color(0xFF334155).withValues(alpha: 0.6)
          : const Color(0xFFF1F5F9),
    );
  }
}
