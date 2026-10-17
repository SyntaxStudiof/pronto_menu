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

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: colorScheme.surfaceContainerLowest,
        appBar: widget.embedded
            ? null
            : AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          scrolledUnderElevation: 0.0,
          automaticallyImplyLeading: false,
          leading: FlutterFlowIconButton(
            borderRadius: 30.0,
            borderWidth: 0.0,
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
                      fontSize: 20.0,
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
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680.0),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18.0,
                  vertical: 12.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Header intro ──────────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.only(left: 4.0, bottom: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Preferenze & Configurazione',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4.0),
                          Text(
                            'Gestisci l\'aspetto visivo, l\'ordinamento del menu e le impostazioni del tuo account.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ── Sezione 1: Personalizzazione & Menu ────────────────────
                    _buildSectionHeader(
                      context: context,
                      title: 'ASPETTO & MENU',
                    ),
                    const SizedBox(height: 8.0),
                    _buildSettingsCard(
                      context: context,
                      children: [
                        _buildSettingsTile(
                          context: context,
                          icon: Icons.palette_rounded,
                          iconBgColor: colorScheme.primary.withValues(alpha: 0.15),
                          iconColor: colorScheme.primary,
                          title: 'Personalizzazione',
                          subtitle: 'Preset di design, stile grafico e tema',
                          trailingBadge: (currentUserDocument != null && !currentUserDocument!.hasPlus)
                              ? _buildTierBadge('PLUS', colorScheme.primary)
                              : null,
                          onTap: () {
                            if (currentUserDocument != null && !currentUserDocument!.hasPlus) {
                              _mostraUpgradePrompt(
                                context,
                                requiredPlan: 'Plus',
                                featureName: 'La personalizzazione grafica e del tema',
                              );
                              return;
                            }
                            context.pushNamed(
                              PersonalizzazioneWidget.routeName,
                              queryParameters: {
                                'ristoranteRef': serializeParam(
                                  widget.ristoranteRef,
                                  ParamType.DocumentReference,
                                ),
                              }.withoutNulls,
                              extra: <String, dynamic>{
                                '__transition_info__': const TransitionInfo(
                                  hasTransition: true,
                                  transitionType: PageTransitionType.rightToLeft,
                                ),
                              },
                            );
                          },
                        ),
                        _buildDivider(colorScheme),
                        _buildSettingsTile(
                          context: context,
                          icon: Icons.format_list_bulleted_rounded,
                          iconBgColor: const Color(0xFF3B82F6).withValues(alpha: 0.15),
                          iconColor: const Color(0xFF3B82F6),
                          title: 'Ordina categorie',
                          subtitle: 'Organizza la sequenza delle portate nel menu',
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
                        _buildDivider(colorScheme),
                        _buildSettingsTile(
                          context: context,
                          icon: Icons.account_tree_rounded,
                          iconBgColor: const Color(0xFF8B5CF6).withValues(alpha: 0.15),
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

                    const SizedBox(height: 24.0),

                    // ── Sezione: Menù Mutaforma (Fasce Orarie) ───────────────
                    _buildSectionHeader(
                      context: context,
                      title: 'MENÙ MUTAFORMA (FASCE ORARIE)',
                    ),
                    const SizedBox(height: 8.0),
                    _buildSettingsCard(
                      context: context,
                      children: [
                        _buildSettingsSwitchTile(
                          context: context,
                          icon: Icons.auto_awesome_rounded,
                          iconBgColor:
                              const Color(0xFF6366F1).withValues(alpha: 0.15),
                          iconColor: const Color(0xFF6366F1),
                          title: 'Attiva Menù Mutaforma',
                          subtitle:
                              'Mostra ai clienti il menù adatto in base all\'orario (Colazione, Pranzo, Aperitivo, Cena). Gli altri menù saranno invisibili.',
                          trailingBadge: (currentUserDocument != null && !currentUserDocument!.hasPlus)
                              ? _buildTierBadge('PLUS', const Color(0xFF6366F1))
                              : null,
                          value: valueOrDefault<bool>(
                              currentUserDocument?.menuMutaformaAttivo, false),
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
                        if (valueOrDefault<bool>(
                            currentUserDocument?.menuMutaformaAttivo, false)) ...[
                          _buildDivider(colorScheme),
                          _buildSettingsTile(
                            context: context,
                            icon: Icons.schedule_rounded,
                            iconBgColor:
                                const Color(0xFF4F46E5).withValues(alpha: 0.15),
                            iconColor: const Color(0xFF4F46E5),
                            title: 'Configura Menù & Orari',
                            subtitle:
                                'Crea fasce orarie e assegna quali categorie mostrare ai clienti',
                            onTap: () {
                              context.pushNamed(
                                ImpostazioniMutaformaWidget.routeName,
                                extra: <String, dynamic>{
                                  '__transition_info__': const TransitionInfo(
                                    hasTransition: true,
                                    transitionType:
                                        PageTransitionType.rightToLeft,
                                  ),
                                },
                              );
                            },
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 24.0),

                    // ── Sezione: Intrattenimento & Jukebox ───────────────────
                    _buildSectionHeader(
                      context: context,
                      title: 'INTRATTENIMENTO & JUKEBOX',
                    ),
                    const SizedBox(height: 8.0),
                    _buildSettingsCard(
                      context: context,
                      children: [
                        _buildSettingsTile(
                          context: context,
                          icon: Icons.music_note_rounded,
                          iconBgColor:
                              const Color(0xFF1DB954).withValues(alpha: 0.15),
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
                                  transitionType:
                                      PageTransitionType.rightToLeft,
                                ),
                              },
                            );
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 24.0),

                    // ── Sezione: Dispensa & Ingredienti ─────────────────────
                    _buildSectionHeader(
                      context: context,
                      title: 'DISPENSA & INGREDIENTI',
                    ),
                    const SizedBox(height: 8.0),
                    _buildSettingsCard(
                      context: context,
                      children: [
                        _buildSettingsSwitchTile(
                          context: context,
                          icon: Icons.kitchen_rounded,
                          iconBgColor:
                              const Color(0xFFF97316).withValues(alpha: 0.15),
                          iconColor: const Color(0xFFF97316),
                          title: 'Gestione Dispensa',
                          subtitle:
                              'Traccia scorte, autocompleta gli ingredienti dei piatti e sbarra quelli esauriti nel menu cliente',
                          value: valueOrDefault<bool>(
                              currentUserDocument?.dispensaAttiva, false),
                          onChanged: (val) async {
                            await currentUserReference?.update({
                              'dispensa_attiva': val,
                            });
                            safeSetState(() {});
                          },
                        ),
                        if (valueOrDefault<bool>(
                            currentUserDocument?.dispensaAttiva, false)) ...[
                          _buildDivider(colorScheme),
                          _buildSettingsTile(
                            context: context,
                            icon: Icons.inventory_2_rounded,
                            iconBgColor:
                                const Color(0xFFEA580C).withValues(alpha: 0.15),
                            iconColor: const Color(0xFFEA580C),
                            title: 'Apri Dispensa',
                            subtitle:
                                'Visualizza ingredienti, gestisci scorte, esauriti e prezzi aggiunte',
                            onTap: () {
                              context.pushNamed(
                                GestioneDispensaWidget.routeName,
                                queryParameters: {
                                  'ristoranteRef': serializeParam(
                                    widget.ristoranteRef,
                                    ParamType.DocumentReference,
                                  ),
                                }.withoutNulls,
                                extra: <String, dynamic>{
                                  '__transition_info__': const TransitionInfo(
                                    hasTransition: true,
                                    transitionType:
                                        PageTransitionType.rightToLeft,
                                  ),
                                },
                              );
                            },
                          ),
                        ],
                        _buildDivider(colorScheme),
                        _buildSettingsSwitchTile(
                          context: context,
                          icon: Icons.tune_rounded,
                          iconBgColor:
                              const Color(0xFF10B981).withValues(alpha: 0.15),
                          iconColor: const Color(0xFF10B981),
                          title: 'Modifiche ai Piatti dai Clienti',
                          subtitle: valueOrDefault<bool>(
                                  currentUserDocument?.dispensaAttiva, false)
                              ? 'I clienti potranno aggiungere ingredienti dalla tua dispensa (con i prezzi impostati) o togliere ingredienti'
                              : 'I clienti potranno scrivere a mano le aggiunte desiderate o togliere ingredienti',
                          value: valueOrDefault<bool>(
                              currentUserDocument?.modifichePiattiAttive, true),
                          onChanged: (val) async {
                            await currentUserReference?.update({
                              'modifiche_piatti_attive': val,
                            });
                            safeSetState(() {});
                          },
                        ),
                        if (!valueOrDefault<bool>(
                                currentUserDocument?.dispensaAttiva, false) &&
                            valueOrDefault<bool>(
                                currentUserDocument?.modifichePiattiAttive, true)) ...[
                          _buildDivider(colorScheme),
                          _buildSettingsTile(
                            context: context,
                            icon: Icons.price_change_rounded,
                            iconBgColor:
                                const Color(0xFF3B82F6).withValues(alpha: 0.15),
                            iconColor: const Color(0xFF3B82F6),
                            title: 'Prezzo Aggiunta Manuale',
                            subtitle:
                                'Costo per ciascun ingrediente scritto a mano: € ${(currentUserDocument?.prezzoAggiuntaManuale ?? 0.0).toStringAsFixed(2)}',
                            onTap: () => _mostraDialogPrezzoManuale(
                              context,
                              currentUserDocument?.prezzoAggiuntaManuale ?? 0.0,
                            ),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 24.0),

                    // ── Sezione 2: Abbonamento & Account ───────────────────────
                    _buildSectionHeader(
                      context: context,
                      title: 'ACCOUNT & PIANO',
                    ),
                    const SizedBox(height: 8.0),
                    _buildSettingsCard(
                      context: context,
                      children: [
                        _buildSettingsTile(
                          context: context,
                          icon: Icons.workspace_premium_rounded,
                          iconBgColor: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                          iconColor: const Color(0xFFF59E0B),
                          title: 'Gestisci abbonamento',
                          subtitle: 'Piano attivo, rinnovo e fatturazione',
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
                          _buildDivider(colorScheme),
                          _buildSettingsTile(
                            context: context,
                            icon: Icons.lock_reset_rounded,
                            iconBgColor: const Color(0xFF8B5CF6).withValues(alpha: 0.15),
                            iconColor: const Color(0xFF8B5CF6),
                            title: 'Cambia password',
                            subtitle: 'Aggiorna le credenziali di accesso',
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

                    const SizedBox(height: 24.0),

                    // ── Sezione 3: Legale & Info ───────────────────────────────
                    _buildSectionHeader(
                      context: context,
                      title: 'INFO & PRIVACY',
                    ),
                    const SizedBox(height: 8.0),
                    _buildSettingsCard(
                      context: context,
                      children: [
                        _buildSettingsTile(
                          context: context,
                          icon: Icons.shield_outlined,
                          iconBgColor: const Color(0xFF10B981).withValues(alpha: 0.15),
                          iconColor: const Color(0xFF10B981),
                          title: 'Informativa sulla privacy',
                          subtitle: 'Trattamento dei dati personali e termini legali',
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

                    const SizedBox(height: 36.0),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required BuildContext context,
    required String title,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 6.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.1,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildSettingsCard({
    required BuildContext context,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      elevation: 1.5,
      shadowColor: isDark
          ? Colors.black.withValues(alpha: 0.35)
          : Colors.black.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18.0),
        side: BorderSide.none,
      ),
      color: theme.colorScheme.surface,
      margin: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18.0),
        child: Column(
          children: children,
        ),
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      splashColor: colorScheme.primary.withValues(alpha: 0.08),
      highlightColor: colorScheme.primary.withValues(alpha: 0.04),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        child: Row(
          children: [
            // Icon badge arrotondato moderno
            Container(
              width: 42.0,
              height: 42.0,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Center(
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 22.0,
                ),
              ),
            ),
            const SizedBox(width: 14.0),
            // Testi titolo e descrizione
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2.0),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: colorScheme.onSurfaceVariant,
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
            // Freccia di navigazione morbida
            Icon(
              Icons.chevron_right_rounded,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              size: 24.0,
            ),
          ],
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          Container(
            width: 42.0,
            height: 42.0,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Center(
              child: Icon(
                icon,
                color: iconColor,
                size: 22.0,
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
                    fontSize: 15.5,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2.0),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: colorScheme.onSurfaceVariant,
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
            activeTrackColor: colorScheme.primary.withValues(alpha: 0.5),
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

  Widget _buildDivider(ColorScheme colorScheme) {
    return Divider(
      height: 1.0,
      thickness: 1.0,
      indent: 72.0, // Indenta dopo l'icona badge per un look stile iOS/Material pulito
      endIndent: 16.0,
      color: colorScheme.outlineVariant.withValues(alpha: 0.4),
    );
  }
}
