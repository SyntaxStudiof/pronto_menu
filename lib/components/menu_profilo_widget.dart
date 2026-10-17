import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'menu_profilo_model.dart';
export 'menu_profilo_model.dart';

class MenuProfiloWidget extends StatefulWidget {
  const MenuProfiloWidget({
    super.key,
    required this.ristoranteRef,
  });

  final DocumentReference? ristoranteRef;

  @override
  State<MenuProfiloWidget> createState() => _MenuProfiloWidgetState();
}

class _MenuProfiloWidgetState extends State<MenuProfiloWidget> {
  late MenuProfiloModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MenuProfiloModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();
    super.dispose();
  }

  void _mostraUpgradePro(BuildContext context, String featureName) {
    final theme = Theme.of(context);
    const proColor = Color(0xFF0D9488);
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
                color: proColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.workspace_premium_rounded,
                color: proColor,
                size: 26.0,
              ),
            ),
            const SizedBox(height: 14.0),
            Text(
              'Disponibile con ProntoMenu Pro',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              '$featureName richiede un abbonamento ProntoMenu attivo.\nScegli il piano per attivarlo subito con 7 giorni di prova gratuita!',
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
                label: const Text('Scopri i Piani ProntoMenu'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: proColor,
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

  Widget _buildMenuItem({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required VoidCallback onTap,
    Widget? trailingBadge,
    bool isDestructive = false,
  }) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0),
        hoverColor: isDestructive
            ? theme.colorScheme.error.withValues(alpha: 0.1)
            : theme.dividerColor.withValues(alpha: 0.1),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
          child: Row(
            children: [
              Container(
                width: 38.0,
                height: 38.0,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                alignment: Alignment.center,
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 20.0,
                ),
              ),
              const SizedBox(width: 14.0),
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isDestructive ? theme.colorScheme.error : null,
                        ),
                      ),
                    ),
                    if (trailingBadge != null) ...[
                      const SizedBox(width: 8.0),
                      trailingBadge,
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: isDestructive
                    ? theme.colorScheme.error.withValues(alpha: 0.5)
                    : theme.iconTheme.color?.withValues(alpha: 0.4) ??
                        theme.dividerColor.withValues(alpha: 0.6),
                size: 20.0,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();
    final theme = Theme.of(context);

    return Container(
      width: 320.0,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20.0),
          bottomLeft: Radius.circular(20.0),
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 24.0,
            color: Colors.black.withValues(alpha: 0.15),
            offset: const Offset(-4.0, 0.0),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Header del Drawer
            Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 16.0, 16.0, 16.0),
              child: Row(
                children: [
                  Container(
                    width: 44.0,
                    height: 44.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.colorScheme.primary,
                        width: 2.0,
                      ),
                    ),
                    child: ClipOval(
                      child: Image.network(
                        valueOrDefault<String>(
                          currentUserPhoto,
                          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
                        ),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Image.asset(
                          'assets/images/IMG_8006.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          valueOrDefault<String>(
                            currentUserDisplayName,
                            'Il mio ristorante',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 2.0),
                        Text(
                          currentUserEmail,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall,
                        ),
                        AuthUserStreamWidget(
                          builder: (context) {
                            final isPremium = valueOrDefault<bool>(currentUserDocument?.isPremium, false);
                            final tier = currentUserDocument?.pianoAbbonamento ?? (isPremium ? 'ultra' : 'nessuno');
                            String tierName;
                            Color tierColor;
                            switch (tier) {
                              case 'pro':
                                tierName = 'Piano Pro';
                                tierColor = const Color(0xFF0D9488);
                                break;
                              case 'plus':
                                tierName = 'Piano Plus ⭐';
                                tierColor = theme.colorScheme.primary;
                                break;
                              case 'ultra':
                                tierName = 'Piano Ultra 👑';
                                tierColor = const Color(0xFF7C3AED);
                                break;
                              default:
                                tierName = 'Non attivo';
                                tierColor = theme.colorScheme.error;
                                break;
                            }
                            return Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7.0, vertical: 2.0),
                                decoration: BoxDecoration(
                                  color: tierColor.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(6.0),
                                  border: Border.all(
                                    color: tierColor.withValues(alpha: 0.3),
                                    width: 0.8,
                                  ),
                                ),
                                child: Text(
                                  tierName,
                                  style: TextStyle(
                                    color: tierColor,
                                    fontSize: 10.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.close_rounded,
                      size: 22.0,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Divider(
              height: 1.0,
              thickness: 1.0,
              color: theme.dividerColor.withValues(alpha: 0.15),
            ),
            // Menu Items List
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _buildMenuItem(
                      context: context,
                      title: 'Il mio profilo',
                      icon: Icons.person_rounded,
                      iconColor: const Color(0xFF2563EB),
                      iconBgColor: const Color(0xFF2563EB).withValues(alpha: 0.12),
                      onTap: () async {
                        Navigator.pop(context);
                        context.pushNamed(
                          ProfiloUtenteWidget.routeName,
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
                    AuthUserStreamWidget(
                      builder: (context) =>
                          valueOrDefault<bool>(currentUserDocument?.isAdmin, false)
                              ? Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const SizedBox(height: 4.0),
                                    _buildMenuItem(
                                      context: context,
                                      title: 'Admin Dashboard',
                                      icon: Icons.admin_panel_settings_rounded,
                                      iconColor: const Color(0xFF7C3AED),
                                      iconBgColor: const Color(0xFF7C3AED).withValues(alpha: 0.12),
                                      onTap: () async {
                                        Navigator.pop(context);
                                        context.pushNamed(AdminDashboardWidget.routeName);
                                      },
                                    ),
                                  ],
                                )
                              : const SizedBox.shrink(),
                    ),
                    const SizedBox(height: 4.0),
                    _buildMenuItem(
                      context: context,
                      title: 'QR code menu',
                      icon: Icons.qr_code_2_rounded,
                      iconColor: const Color(0xFF0EA5E9),
                      iconBgColor: const Color(0xFF0EA5E9).withValues(alpha: 0.12),
                      onTap: () async {
                        Navigator.pop(context);
                        context.pushNamed(
                          ImpostazioniQRWidget.routeName,
                          extra: <String, dynamic>{
                            '__transition_info__': const TransitionInfo(
                              hasTransition: true,
                              transitionType: PageTransitionType.rightToLeft,
                            ),
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 4.0),
                    _buildMenuItem(
                      context: context,
                      title: 'Vedi menu come cliente',
                      icon: Icons.visibility_rounded,
                      iconColor: const Color(0xFF10B981),
                      iconBgColor:
                          const Color(0xFF10B981).withValues(alpha: 0.12),
                      onTap: () async {
                        Navigator.pop(context);
                        context.pushNamed(
                          HubClienteWidget.routeName,
                          queryParameters: {
                            'ristoranteRef': serializeParam(
                              widget.ristoranteRef,
                              ParamType.DocumentReference,
                            ),
                            'isAnteprima': serializeParam(
                              true,
                              ParamType.bool,
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
                    const SizedBox(height: 4.0),
                    _buildMenuItem(
                      context: context,
                      title: 'Cestino',
                      icon: Icons.delete_outline_rounded,
                      iconColor: const Color(0xFFD97706),
                      iconBgColor: const Color(0xFFD97706).withValues(alpha: 0.12),
                      trailingBadge: (currentUserDocument != null && !currentUserDocument!.hasPro)
                          ? Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0D9488).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(4.0),
                              ),
                              child: const Text('PRO', style: TextStyle(color: Color(0xFF0D9488), fontSize: 9.5, fontWeight: FontWeight.bold)),
                            )
                          : null,
                      onTap: () async {
                        Navigator.pop(context);
                        if (currentUserDocument != null && !currentUserDocument!.hasPro) {
                          _mostraUpgradePro(context, 'Il cestino di sicurezza e recupero piatti');
                          return;
                        }
                        context.pushNamed(
                          CestinoWidget.routeName,
                          extra: <String, dynamic>{
                            '__transition_info__': const TransitionInfo(
                              hasTransition: true,
                              transitionType: PageTransitionType.rightToLeft,
                            ),
                          },
                        );
                      },
                    ),
                    if (valueOrDefault<bool>(
                        currentUserDocument?.dispensaAttiva, false)) ...[
                      const SizedBox(height: 4.0),
                      _buildMenuItem(
                        context: context,
                        title: 'Dispensa',
                        icon: Icons.kitchen_rounded,
                        iconColor: const Color(0xFFF97316),
                        iconBgColor:
                            const Color(0xFFF97316).withValues(alpha: 0.12),
                        onTap: () async {
                          Navigator.pop(context);
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
                                transitionType: PageTransitionType.rightToLeft,
                              ),
                            },
                          );
                        },
                      ),
                    ],
                    const SizedBox(height: 4.0),
                    _buildMenuItem(
                      context: context,
                      title: 'Impostazioni',
                      icon: Icons.settings_rounded,
                      iconColor: const Color(0xFF6B7280),
                      iconBgColor: const Color(0xFF6B7280).withValues(alpha: 0.12),
                      onTap: () async {
                        if (Navigator.of(context).canPop()) {
                          context.pop();
                        }
                        context.pushNamed(
                          ImpostazioniUtenteWidget.routeName,
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
                    const SizedBox(height: 4.0),
                    StreamBuilder<List<TicketsRecord>>(
                      stream: queryTicketsRecord(
                        queryBuilder: (q) => q.where(
                          'ristoratore_ref',
                          isEqualTo: currentUserReference,
                        ),
                      ),
                      builder: (context, snapshot) {
                        final tickets = snapshot.data ?? [];
                        final hasUnreadReply = tickets.any((t) =>
                            t.rispostaAdmin.trim().isNotEmpty &&
                            !t.rispostaLetta);

                        return _buildMenuItem(
                          context: context,
                          title: 'Supporto',
                          icon: Icons.help_outline_rounded,
                          iconColor: const Color(0xFF059669),
                          iconBgColor:
                              const Color(0xFF059669).withValues(alpha: 0.12),
                          trailingBadge: hasUnreadReply
                              ? Container(
                                  width: 20.0,
                                  height: 20.0,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEF4444),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFEF4444)
                                            .withValues(alpha: 0.4),
                                        blurRadius: 4.0,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  alignment: Alignment.center,
                                  child: const Text(
                                    '!',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 13.0,
                                      height: 1.1,
                                    ),
                                  ),
                                )
                              : null,
                          onTap: () async {
                            Navigator.pop(context);
                            context.pushNamed(
                              SupportoRistoratoreWidget.routeName,
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
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            Divider(
              height: 1.0,
              thickness: 1.0,
              color: theme.dividerColor.withValues(alpha: 0.15),
            ),
            // Bottone Log Out
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 16.0),
              child: _buildMenuItem(
                context: context,
                title: 'Log Out',
                icon: Icons.logout_rounded,
                iconColor: theme.colorScheme.error,
                iconBgColor: theme.colorScheme.error.withValues(alpha: 0.12),
                isDestructive: true,
                onTap: () async {
                  Navigator.pop(context);
                  GoRouter.of(context).prepareAuthEvent();
                  await authManager.signOut();
                  if (!context.mounted) return;
                  GoRouter.of(context).clearRedirectLocation();

                  context.pushNamedAuth(
                    AuthWelcomeWidget.routeName,
                    context.mounted,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
