import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'admin_drawer_menu_model.dart';
export 'admin_drawer_menu_model.dart';

class AdminDrawerMenuWidget extends StatefulWidget {
  const AdminDrawerMenuWidget({
    super.key,
    this.ristoranteRef,
  });

  final DocumentReference? ristoranteRef;

  @override
  State<AdminDrawerMenuWidget> createState() => _AdminDrawerMenuWidgetState();
}

class _AdminDrawerMenuWidgetState extends State<AdminDrawerMenuWidget> {
  late AdminDrawerMenuModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AdminDrawerMenuModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();
    super.dispose();
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
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                valueOrDefault<String>(
                                  currentUserDisplayName,
                                  'Amministratore',
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.3,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6.0),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                              decoration: BoxDecoration(
                                color: const Color(0xFF7C3AED).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6.0),
                              ),
                              child: const Text(
                                'ADMIN',
                                style: TextStyle(
                                  fontSize: 10.0,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF7C3AED),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2.0),
                        Text(
                          currentUserEmail,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall,
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
                      title: 'Dashboard Admin',
                      icon: Icons.admin_panel_settings_rounded,
                      iconColor: const Color(0xFF7C3AED),
                      iconBgColor: const Color(0xFF7C3AED).withValues(alpha: 0.12),
                      onTap: () async {
                        Navigator.pop(context);
                        context.goNamed(AdminDashboardWidget.routeName);
                      },
                    ),
                    const SizedBox(height: 4.0),
                    _buildMenuItem(
                      context: context,
                      title: 'Metriche Business',
                      icon: Icons.insights_rounded,
                      iconColor: const Color(0xFFF59E0B),
                      iconBgColor: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                      onTap: () async {
                        Navigator.pop(context);
                        context.pushNamed(AdminMetricheWidget.routeName);
                      },
                    ),
                    const SizedBox(height: 4.0),
                    _buildMenuItem(
                      context: context,
                      title: 'Cronologia Azioni',
                      icon: Icons.manage_history_rounded,
                      iconColor: const Color(0xFF2563EB),
                      iconBgColor: const Color(0xFF2563EB).withValues(alpha: 0.12),
                      onTap: () async {
                        Navigator.pop(context);
                        context.pushNamed(AdminCronologiaAzioniWidget.routeName);
                      },
                    ),
                    const SizedBox(height: 4.0),
                    _buildMenuItem(
                      context: context,
                      title: 'Il mio menu',
                      icon: Icons.restaurant_menu_rounded,
                      iconColor: const Color(0xFF2563EB),
                      iconBgColor: const Color(0xFF2563EB).withValues(alpha: 0.12),
                      onTap: () async {
                        Navigator.pop(context);
                        context.goNamed(
                          HomeRistoratoreWidget.routeName,
                          queryParameters: {
                            'ristoranteRef': serializeParam(
                              currentUserReference,
                              ParamType.DocumentReference,
                            ),
                          }.withoutNulls,
                        );
                      },
                    ),
                    const SizedBox(height: 4.0),
                    StreamBuilder<List<TicketsRecord>>(
                      stream: queryTicketsRecord(),
                      builder: (context, snapshot) {
                        final apertiCount = snapshot.hasData
                            ? snapshot.data!.where((t) {
                                final s = t.stato.trim().toLowerCase();
                                return s == 'aperto' || s.isEmpty;
                              }).length
                            : 0;

                        return _buildMenuItem(
                          context: context,
                          title: 'Supporto clienti',
                          icon: Icons.support_agent_rounded,
                          iconColor: const Color(0xFF059669),
                          iconBgColor:
                              const Color(0xFF059669).withValues(alpha: 0.12),
                          trailingBadge: apertiCount > 0
                              ? Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0,
                                    vertical: 2.5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEF4444),
                                    borderRadius: BorderRadius.circular(10.0),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFEF4444)
                                            .withValues(alpha: 0.35),
                                        blurRadius: 4.0,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    apertiCount > 99
                                        ? '99+'
                                        : apertiCount.toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11.5,
                                    ),
                                  ),
                                )
                              : null,
                          onTap: () async {
                            Navigator.pop(context);
                            context.pushNamed(AdminTicketsWidget.routeName);
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