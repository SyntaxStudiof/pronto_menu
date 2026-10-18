import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

import '/admin/admin_drawer_menu/admin_drawer_menu_widget.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/custom_functions.dart' as functions;
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import '/theme_provider.dart';
import 'admin_dashboard_model.dart';
export 'admin_dashboard_model.dart';

class AdminDashboardWidget extends StatefulWidget {
  const AdminDashboardWidget({
    super.key,
    this.embedded = false,
  });

  final bool embedded;

  static String routeName = 'AdminDashboard';
  static String routePath = '/adminDashboard';

  @override
  State<AdminDashboardWidget> createState() => _AdminDashboardWidgetState();
}

class _AdminDashboardWidgetState extends State<AdminDashboardWidget> {
  late AdminDashboardModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  // Desktop shell state
  bool _forceMobilePreview = false;
  bool _sidebarCollapsed = false;
  String _currentViewId = 'ristoranti'; // 'ristoranti', 'metriche', 'cronologia', 'supporto'
  final Set<String> _visitedViews = {'ristoranti'};

  // Filtri e ordinamento desktop
  String _filtroFoto = 'tutti'; // 'tutti', 'con_foto', 'senza_foto'
  String _ordinamento = 'nome_asc'; // 'nome_asc', 'nome_desc', 'email'

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AdminDashboardModel());

    _model.barraRicercaTextController ??= TextEditingController();
    _model.barraRicercaFocusNode ??= FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  void _switchView(String newId) {
    if (_currentViewId != newId) {
      setState(() {
        _currentViewId = newId;
        _visitedViews.add(newId);
      });
    }
  }

  _AdminSectionInfo _getSectionInfo(String viewId) {
    switch (viewId) {
      case 'metriche':
        return const _AdminSectionInfo(
          id: 'metriche',
          title: 'Metriche Business & Costi',
          subtitle: 'Ristoranti attivi oggi, utenti registrati e spazio GB foto Firebase',
          icon: Icons.insights_rounded,
        );
      case 'cronologia':
        return const _AdminSectionInfo(
          id: 'cronologia',
          title: 'Cronologia Azioni (Audit Log)',
          subtitle: 'Tracciamento modifiche piatti, categorie e menù',
          icon: Icons.manage_history_rounded,
        );
      case 'supporto':
        return const _AdminSectionInfo(
          id: 'supporto',
          title: 'Supporto Clienti (Ticket)',
          subtitle: 'Gestione e risposta tempestiva alle richieste dei ristoratori',
          icon: Icons.support_agent_rounded,
        );
      case 'ristoranti':
      default:
        return const _AdminSectionInfo(
          id: 'ristoranti',
          title: 'Ristoranti & Locali Registrati',
          subtitle: 'Monitoraggio e gestione completa degli esercenti ProntoMenu',
          icon: Icons.storefront_rounded,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return StreamBuilder<List<UsersRecord>>(
      stream: queryUsersRecord(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline_rounded, size: 48.0, color: colorScheme.error),
                    const SizedBox(height: 12.0),
                    Text(
                      'Errore caricamento dati: ${snapshot.error}',
                      style: theme.textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (!snapshot.hasData) {
          return Scaffold(
            backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
            body: Center(
              child: SizedBox(
                width: 50.0,
                height: 50.0,
                child: SpinKitPulse(
                  color: colorScheme.primary,
                  size: 50.0,
                ),
              ),
            ),
          );
        }

        final List<UsersRecord> adminDashboardUsersRecordList =
            snapshot.data!.where((u) => !u.isAdmin).toList();

        // Filtro ricerca
        final query = _model.barraRicercaTextController?.text.trim() ?? '';
        List<UsersRecord> utentiFiltrati = functions
            .cercaRistoranti(adminDashboardUsersRecordList.toList(), query)
            .toList();

        // Filtro presenza foto
        if (_filtroFoto == 'con_foto') {
          utentiFiltrati = utentiFiltrati.where((u) => u.photoUrl.isNotEmpty).toList();
        } else if (_filtroFoto == 'senza_foto') {
          utentiFiltrati = utentiFiltrati.where((u) => u.photoUrl.isEmpty).toList();
        }

        // Ordinamento
        utentiFiltrati.sort((a, b) {
          if (_ordinamento == 'nome_desc') {
            return b.displayName.toLowerCase().compareTo(a.displayName.toLowerCase());
          } else if (_ordinamento == 'email') {
            return a.email.toLowerCase().compareTo(b.email.toLowerCase());
          } else {
            return a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase());
          }
        });

        final mobileUI = _buildMobileUI(
          theme: theme,
          colorScheme: colorScheme,
          isDark: isDark,
          allRestaurants: adminDashboardUsersRecordList,
          filteredRestaurants: utentiFiltrati,
        );

        // Se l'utente è su desktop ma ha attivato la simulazione mobile
        if (_forceMobilePreview) {
          return Stack(
            children: [
              mobileUI,
              Positioned(
                bottom: 24.0,
                right: 24.0,
                child: FloatingActionButton.extended(
                  onPressed: () => setState(() => _forceMobilePreview = false),
                  icon: const Icon(Icons.desktop_windows_rounded),
                  label: const Text('Torna alla Vista PC'),
                  backgroundColor: colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          );
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 800.0;

            // Se è incorporato in un'altra shell desktop (es. DesktopDashboardShell ristoratore)
            if (widget.embedded) {
              return _buildRistorantiCanvas(
                theme: theme,
                colorScheme: colorScheme,
                isDark: isDark,
                allRestaurants: adminDashboardUsersRecordList,
                filteredRestaurants: utentiFiltrati,
                isEmbedded: true,
              );
            }

            // Se siamo su schermo mobile (< 800px)
            if (!isDesktop) {
              return mobileUI;
            }

            // Vista Desktop completa con Sidebar e TopBar
            return _buildDesktopShell(
              theme: theme,
              colorScheme: colorScheme,
              isDark: isDark,
              allRestaurants: adminDashboardUsersRecordList,
              filteredRestaurants: utentiFiltrati,
              mobileFallback: mobileUI,
            );
          },
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SHELL DESKTOP PER AMMINISTRATORE (>= 800px)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildDesktopShell({
    required ThemeData theme,
    required ColorScheme colorScheme,
    required bool isDark,
    required List<UsersRecord> allRestaurants,
    required List<UsersRecord> filteredRestaurants,
    required Widget mobileFallback,
  }) {
    final activeSection = _getSectionInfo(_currentViewId);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      body: Row(
        children: [
          // ─── 1. SIDEBAR DESKTOP A SINISTRA ──────────────────────────────────
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOutCubic,
            width: _sidebarCollapsed ? 0.0 : 270.0,
            child: ClipRect(
              child: OverflowBox(
                minWidth: 270.0,
                maxWidth: 270.0,
                alignment: Alignment.topLeft,
                child: Container(
                  width: 270.0,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    border: Border(
                      right: BorderSide(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : const Color(0xFFE2E8F0),
                        width: 1.0,
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.03),
                        blurRadius: 10.0,
                        offset: const Offset(2, 0),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Header Logo & Brand con pulsante di compressione
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16.0, 20.0, 12.0, 14.0),
                        child: Row(
                          children: [
                            Container(
                              width: 38.0,
                              height: 38.0,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF7C3AED),
                                    Color(0xFF6D28D9),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(10.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF7C3AED).withValues(alpha: 0.30),
                                    blurRadius: 8.0,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.admin_panel_settings_rounded,
                                color: Colors.white,
                                size: 22.0,
                              ),
                            ),
                            const SizedBox(width: 10.0),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'ProntoMenu',
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.4,
                                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                                    ),
                                  ),
                                  Text(
                                    'Dashboard Amministratore',
                                    style: TextStyle(
                                      fontSize: 11.0,
                                      fontWeight: FontWeight.w500,
                                      color: isDark
                                          ? const Color(0xFF94A3B8)
                                          : const Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  _sidebarCollapsed = true;
                                });
                              },
                              tooltip: 'Comprimi barra laterale',
                              icon: Icon(
                                Icons.menu_open_rounded,
                                size: 20.0,
                                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                              ),
                              hoverColor: colorScheme.primary.withValues(alpha: 0.08),
                              splashRadius: 20.0,
                              padding: const EdgeInsets.all(6.0),
                            ),
                          ],
                        ),
                      ),

                      // Card Profilo Amministratore Connesso
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                        child: Container(
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.04)
                                : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(12.0),
                            border: Border.all(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.06)
                                  : const Color(0xFFE2E8F0),
                            ),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 18.0,
                                backgroundColor: const Color(0xFF7C3AED).withValues(alpha: 0.15),
                                backgroundImage: currentUserPhoto.isNotEmpty
                                    ? NetworkImage(currentUserPhoto)
                                    : null,
                                child: currentUserPhoto.isEmpty
                                    ? const Icon(
                                        Icons.admin_panel_settings_rounded,
                                        size: 20.0,
                                        color: Color(0xFF7C3AED),
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 10.0),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            currentUserDisplayName.isNotEmpty
                                                ? currentUserDisplayName
                                                : 'Amministratore',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 13.0,
                                              fontWeight: FontWeight.w700,
                                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 5.0),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 1.5),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF7C3AED).withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(4.0),
                                          ),
                                          child: const Text(
                                            'ADMIN',
                                            style: TextStyle(
                                              fontSize: 9.0,
                                              fontWeight: FontWeight.w800,
                                              color: Color(0xFF7C3AED),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2.0),
                                    Row(
                                      children: [
                                        Container(
                                          width: 7.0,
                                          height: 7.0,
                                          decoration: const BoxDecoration(
                                            color: Color(0xFF10B981),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 5.0),
                                        const Text(
                                          'Super Admin • Online',
                                          style: TextStyle(
                                            fontSize: 10.5,
                                            color: Color(0xFF10B981),
                                            fontWeight: FontWeight.w600,
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

                      const SizedBox(height: 12.0),

                      // Voci del Menu Laterale
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.symmetric(horizontal: 14.0),
                          children: [
                            _buildNavCategoryHeader('PANORAMICA PIATTAFORMA', isDark),
                            _buildSidebarItem(
                              icon: Icons.storefront_rounded,
                              title: 'Ristoranti Registrati',
                              isSelected: _currentViewId == 'ristoranti',
                              colorScheme: colorScheme,
                              isDark: isDark,
                              iconColor: const Color(0xFF7C3AED),
                              badgeText: '${allRestaurants.length}',
                              onTap: () => _switchView('ristoranti'),
                            ),
                            _buildSidebarItem(
                              icon: Icons.insights_rounded,
                              title: 'Metriche Business',
                              isSelected: _currentViewId == 'metriche',
                              colorScheme: colorScheme,
                              isDark: isDark,
                              iconColor: const Color(0xFFF59E0B),
                              onTap: () => _switchView('metriche'),
                            ),
                            _buildSidebarItem(
                              icon: Icons.manage_history_rounded,
                              title: 'Cronologia Azioni',
                              isSelected: _currentViewId == 'cronologia',
                              colorScheme: colorScheme,
                              isDark: isDark,
                              iconColor: const Color(0xFF2563EB),
                              onTap: () => _switchView('cronologia'),
                            ),
                            StreamBuilder<List<TicketsRecord>>(
                              stream: queryTicketsRecord(),
                              builder: (context, snap) {
                                final apertiCount = snap.hasData
                                    ? snap.data!.where((t) {
                                        final s = t.stato.trim().toLowerCase();
                                        return s == 'aperto' || s.isEmpty;
                                      }).length
                                    : 0;

                                return _buildSidebarItem(
                                  icon: Icons.support_agent_rounded,
                                  title: 'Supporto Clienti',
                                  isSelected: _currentViewId == 'supporto',
                                  colorScheme: colorScheme,
                                  isDark: isDark,
                                  iconColor: const Color(0xFF059669),
                                  badgeText: apertiCount > 0 ? '$apertiCount' : null,
                                  badgeColor: const Color(0xFFEF4444),
                                  onTap: () => _switchView('supporto'),
                                );
                              },
                            ),

                            const SizedBox(height: 16.0),
                            _buildNavCategoryHeader('ACCESSO RAPIDO', isDark),
                            _buildSidebarItem(
                              icon: Icons.restaurant_menu_rounded,
                              title: 'Il mio Menù (Ristoratore)',
                              isSelected: false,
                              colorScheme: colorScheme,
                              isDark: isDark,
                              iconColor: const Color(0xFF6366F1),
                              onTap: () {
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
                          ],
                        ),
                      ),

                      // Footer Sidebar con Dark Mode e Logout
                      Container(
                        padding: const EdgeInsets.all(14.0),
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.08)
                                  : const Color(0xFFE2E8F0),
                              width: 1.0,
                            ),
                          ),
                        ),
                        child: Column(
                          children: [
                            // Selettore Tema
                            InkWell(
                              onTap: () {
                                themeProvider.setThemeMode(
                                  isDark ? ThemeMode.light : ThemeMode.dark,
                                );
                              },
                              borderRadius: BorderRadius.circular(10.0),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                                child: Row(
                                  children: [
                                    Icon(
                                      isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                                      size: 18.0,
                                      color: isDark ? const Color(0xFFFBBF24) : const Color(0xFF64748B),
                                    ),
                                    const SizedBox(width: 10.0),
                                    Text(
                                      isDark ? 'Tema Chiaro' : 'Tema Scuro',
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                                      ),
                                    ),
                                    const Spacer(),
                                    Icon(
                                      Icons.swap_horiz_rounded,
                                      size: 16.0,
                                      color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 4.0),
                            // Log Out
                            InkWell(
                              onTap: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Disconnessione'),
                                    content: const Text('Sei sicuro di voler uscire dal tuo account amministratore?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(ctx, false),
                                        child: const Text('Annulla'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () => Navigator.pop(ctx, true),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: colorScheme.error,
                                          foregroundColor: Colors.white,
                                        ),
                                        child: const Text('Esci'),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirm == true) {
                                  if (!mounted) return;
                                  GoRouter.of(context).prepareAuthEvent();
                                  await authManager.signOut();
                                  if (!mounted) return;
                                  GoRouter.of(context).clearRedirectLocation();
                                  context.pushNamedAuth(
                                    AuthWelcomeWidget.routeName,
                                    mounted,
                                  );
                                }
                              },
                              borderRadius: BorderRadius.circular(10.0),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.logout_rounded,
                                      size: 18.0,
                                      color: colorScheme.error,
                                    ),
                                    const SizedBox(width: 10.0),
                                    Text(
                                      'Disconnetti',
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w600,
                                        color: colorScheme.error,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ─── 2. CONTENUTO CENTRALE CON TOPBAR ──────────────────────────────
          Expanded(
            child: Column(
              children: [
                // TopBar Superiore (Altezza 64px uniforme con il design system)
                Container(
                  height: 64.0,
                  padding: EdgeInsets.symmetric(horizontal: _sidebarCollapsed ? 18.0 : 28.0),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    border: Border(
                      bottom: BorderSide(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : const Color(0xFFE2E8F0),
                        width: 1.0,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Riapri barra se compressa
                      if (_sidebarCollapsed) ...[
                        Tooltip(
                          message: 'Espandi barra laterale',
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _sidebarCollapsed = false;
                              });
                            },
                            borderRadius: BorderRadius.circular(8.0),
                            child: Container(
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                color: colorScheme.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8.0),
                                border: Border.all(
                                  color: colorScheme.primary.withValues(alpha: 0.25),
                                ),
                              ),
                              child: Icon(
                                Icons.menu_rounded,
                                size: 20.0,
                                color: colorScheme.primary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16.0),
                      ],

                      // Titolo Sezione Corrente
                      Icon(
                        activeSection.icon,
                        color: const Color(0xFF7C3AED),
                        size: 22.0,
                      ),
                      const SizedBox(width: 10.0),
                      Text(
                        activeSection.title,
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(width: 12.0),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFF7C3AED).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6.0),
                        ),
                        child: const Text(
                          'Admin Desktop',
                          style: TextStyle(
                            fontSize: 11.0,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF7C3AED),
                          ),
                        ),
                      ),

                      const Spacer(),

                      // Simula vista Mobile
                      OutlinedButton.icon(
                        onPressed: () => setState(() => _forceMobilePreview = true),
                        icon: const Icon(Icons.phone_iphone_rounded, size: 16.0),
                        label: const Text('Simula vista Mobile', style: TextStyle(fontSize: 12.5)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                          side: BorderSide(
                            color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
                          ),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
                        ),
                      ),

                      const SizedBox(width: 12.0),

                      // Badge Firebase Connesso
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20.0),
                          border: Border.all(
                            color: const Color(0xFF10B981).withValues(alpha: 0.3),
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.cloud_done_rounded,
                              size: 15.0,
                              color: Color(0xFF10B981),
                            ),
                            SizedBox(width: 6.0),
                            Text(
                              'Firebase Connesso',
                              style: TextStyle(
                                fontSize: 12.0,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF10B981),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Canvas Principale con IndexedStack
                Expanded(
                  child: IndexedStack(
                    index: _getIndexForViewId(_currentViewId),
                    children: [
                      // Tab 0: Ristoranti Registrati
                      _buildRistorantiCanvas(
                        theme: theme,
                        colorScheme: colorScheme,
                        isDark: isDark,
                        allRestaurants: allRestaurants,
                        filteredRestaurants: filteredRestaurants,
                        isEmbedded: false,
                      ),
                      // Tab 1: Metriche Business
                      _visitedViews.contains('metriche')
                          ? const AdminMetricheWidget(
                              key: PageStorageKey('admin_metriche_tab'),
                              embedded: true,
                            )
                          : const SizedBox.shrink(),
                      // Tab 2: Cronologia Azioni
                      _visitedViews.contains('cronologia')
                          ? const AdminCronologiaAzioniWidget(
                              key: PageStorageKey('admin_cronologia_tab'),
                              embedded: true,
                            )
                          : const SizedBox.shrink(),
                      // Tab 3: Supporto Clienti
                      _visitedViews.contains('supporto')
                          ? const AdminTicketsWidget(
                              key: PageStorageKey('admin_tickets_tab'),
                              embedded: true,
                            )
                          : const SizedBox.shrink(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  int _getIndexForViewId(String id) {
    switch (id) {
      case 'metriche':
        return 1;
      case 'cronologia':
        return 2;
      case 'supporto':
        return 3;
      case 'ristoranti':
      default:
        return 0;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CANVAS RISTORANTI PER DESKTOP (Griglia responsive, KPI e filtri avanzati)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildRistorantiCanvas({
    required ThemeData theme,
    required ColorScheme colorScheme,
    required bool isDark,
    required List<UsersRecord> allRestaurants,
    required List<UsersRecord> filteredRestaurants,
    required bool isEmbedded,
  }) {
    final withPhotoCount = allRestaurants.where((u) => u.photoUrl.isNotEmpty).length;
    final withoutPhotoCount = allRestaurants.where((u) => u.photoUrl.isEmpty).length;

    return Container(
      color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(28.0, 24.0, 28.0, 40.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1400.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── 1. KPI COUNTER CARDS DI CONTROLLO ─────────────────────────
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth >= 960;
                    return isWide
                        ? Row(
                            children: [
                              Expanded(
                                child: _buildKpiCard(
                                  title: 'Ristoranti Totali',
                                  value: '${allRestaurants.length}',
                                  subtitle: '$withPhotoCount con logo • $withoutPhotoCount senza',
                                  icon: Icons.storefront_rounded,
                                  accentColor: const Color(0xFF7C3AED),
                                  isDark: isDark,
                                ),
                              ),
                              const SizedBox(width: 16.0),
                              Expanded(
                                child: _buildKpiCard(
                                  title: 'Metriche Business',
                                  value: 'Performance',
                                  subtitle: 'Costi server, utenti & storage',
                                  icon: Icons.insights_rounded,
                                  accentColor: const Color(0xFFF59E0B),
                                  isDark: isDark,
                                  onTap: () => _switchView('metriche'),
                                ),
                              ),
                              const SizedBox(width: 16.0),
                              Expanded(
                                child: _buildKpiCard(
                                  title: 'Audit Log Azioni',
                                  value: 'Cronologia',
                                  subtitle: 'Eliminazioni e modifiche menù',
                                  icon: Icons.manage_history_rounded,
                                  accentColor: const Color(0xFF2563EB),
                                  isDark: isDark,
                                  onTap: () => _switchView('cronologia'),
                                ),
                              ),
                              const SizedBox(width: 16.0),
                              Expanded(
                                child: StreamBuilder<List<TicketsRecord>>(
                                  stream: queryTicketsRecord(),
                                  builder: (context, snap) {
                                    final apertiCount = snap.hasData
                                        ? snap.data!.where((t) {
                                            final s = t.stato.trim().toLowerCase();
                                            return s == 'aperto' || s.isEmpty;
                                          }).length
                                        : 0;

                                    return _buildKpiCard(
                                      title: 'Ticket Assistenza',
                                      value: apertiCount > 0 ? '$apertiCount Aperti' : '0 In Attesa',
                                      subtitle: apertiCount > 0
                                          ? 'Richieste da gestire'
                                          : 'Nessun ticket in attesa',
                                      icon: Icons.support_agent_rounded,
                                      accentColor: apertiCount > 0
                                          ? const Color(0xFFEF4444)
                                          : const Color(0xFF10B981),
                                      isDark: isDark,
                                      onTap: () => _switchView('supporto'),
                                    );
                                  },
                                ),
                              ),
                            ],
                          )
                        : Wrap(
                            spacing: 12.0,
                            runSpacing: 12.0,
                            children: [
                              SizedBox(
                                width: (constraints.maxWidth - 12.0) / 2,
                                child: _buildKpiCard(
                                  title: 'Ristoranti Totali',
                                  value: '${allRestaurants.length}',
                                  subtitle: '$withPhotoCount con logo • $withoutPhotoCount senza',
                                  icon: Icons.storefront_rounded,
                                  accentColor: const Color(0xFF7C3AED),
                                  isDark: isDark,
                                ),
                              ),
                              SizedBox(
                                width: (constraints.maxWidth - 12.0) / 2,
                                child: _buildKpiCard(
                                  title: 'Metriche Business',
                                  value: 'Performance',
                                  subtitle: 'Costi server & storage',
                                  icon: Icons.insights_rounded,
                                  accentColor: const Color(0xFFF59E0B),
                                  isDark: isDark,
                                  onTap: () => _switchView('metriche'),
                                ),
                              ),
                            ],
                          );
                  },
                ),

                const SizedBox(height: 20.0),

                // ── 2. BARRA DI RICERCA & FILTRI DESKTOP ──────────────────────
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(16.0),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : const Color(0xFFE2E8F0),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                        blurRadius: 10.0,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          // Casella di ricerca
                          Expanded(
                            child: Container(
                              height: 46.0,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF0F172A)
                                    : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(10.0),
                                border: Border.all(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.08)
                                      : const Color(0xFFE2E8F0),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const SizedBox(width: 12.0),
                                  Icon(
                                    Icons.search_rounded,
                                    size: 20.0,
                                    color: isDark
                                        ? const Color(0xFF94A3B8)
                                        : const Color(0xFF64748B),
                                  ),
                                  const SizedBox(width: 8.0),
                                  Expanded(
                                    child: TextField(
                                      controller: _model.barraRicercaTextController,
                                      focusNode: _model.barraRicercaFocusNode,
                                      onChanged: (_) => EasyDebounce.debounce(
                                        '_model.barraRicercaTextController',
                                        const Duration(milliseconds: 300),
                                        () => safeSetState(() {}),
                                      ),
                                      style: TextStyle(
                                        fontSize: 13.5,
                                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                                      ),
                                      decoration: InputDecoration(
                                        hintText: 'Cerca per nome locale o email del proprietario...',
                                        hintStyle: TextStyle(
                                          fontSize: 13.0,
                                          color: isDark
                                              ? const Color(0xFF64748B)
                                              : const Color(0xFF94A3B8),
                                        ),
                                        border: InputBorder.none,
                                        isDense: true,
                                        contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
                                      ),
                                    ),
                                  ),
                                  if (_model.barraRicercaTextController?.text.isNotEmpty ?? false)
                                    IconButton(
                                      icon: const Icon(Icons.clear_rounded, size: 18.0),
                                      onPressed: () {
                                        _model.barraRicercaTextController?.clear();
                                        safeSetState(() {});
                                      },
                                    ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(width: 14.0),

                          // Menu Ordinamento
                          Container(
                            height: 46.0,
                            padding: const EdgeInsets.symmetric(horizontal: 12.0),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF0F172A)
                                  : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(10.0),
                              border: Border.all(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.08)
                                    : const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _ordinamento,
                                icon: const Icon(Icons.swap_vert_rounded, size: 18.0),
                                style: TextStyle(
                                  fontSize: 13.0,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                                ),
                                dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                                items: const [
                                  DropdownMenuItem(
                                    value: 'nome_asc',
                                    child: Text('Nome (A-Z)'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'nome_desc',
                                    child: Text('Nome (Z-A)'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'email',
                                    child: Text('Per Email'),
                                  ),
                                ],
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() => _ordinamento = val);
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12.0),

                      // Filtri Chips Foto & Contatore
                      Row(
                        children: [
                          _buildFilterChip(
                            label: 'Tutti (${allRestaurants.length})',
                            isSelected: _filtroFoto == 'tutti',
                            isDark: isDark,
                            onTap: () => setState(() => _filtroFoto = 'tutti'),
                          ),
                          const SizedBox(width: 8.0),
                          _buildFilterChip(
                            label: 'Con Logo ($withPhotoCount)',
                            isSelected: _filtroFoto == 'con_foto',
                            isDark: isDark,
                            onTap: () => setState(() => _filtroFoto = 'con_foto'),
                          ),
                          const SizedBox(width: 8.0),
                          _buildFilterChip(
                            label: 'Senza Logo ($withoutPhotoCount)',
                            isSelected: _filtroFoto == 'senza_foto',
                            isDark: isDark,
                            onTap: () => setState(() => _filtroFoto = 'senza_foto'),
                          ),
                          const Spacer(),
                          Text(
                            'Trovati: ${filteredRestaurants.length} ${filteredRestaurants.length == 1 ? 'ristorante' : 'ristoranti'}',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20.0),

                // ── 3. GRIGLIA RESPONSIVE RISTORANTI DESKTOP ──────────────────
                if (filteredRestaurants.isEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 60.0),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      borderRadius: BorderRadius.circular(16.0),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 64.0,
                          height: 64.0,
                          decoration: BoxDecoration(
                            color: const Color(0xFF7C3AED).withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.storefront_outlined,
                            size: 32.0,
                            color: Color(0xFF7C3AED),
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        Text(
                          'Nessun ristorante trovato',
                          style: TextStyle(
                            fontSize: 17.0,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 6.0),
                        Text(
                          'Nessun risultato corrisponde ai criteri di ricerca o filtro attuali.',
                          style: TextStyle(
                            fontSize: 13.5,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        OutlinedButton(
                          onPressed: () {
                            _model.barraRicercaTextController?.clear();
                            setState(() {
                              _filtroFoto = 'tutti';
                            });
                          },
                          child: const Text('Reimposta filtri'),
                        ),
                      ],
                    ),
                  )
                else
                  LayoutBuilder(
                    builder: (context, constraints) {
                      // Griglia a 3 colonne su schermi larghi, 2 su medi, 1 su stretti
                      final double maxWidth = constraints.maxWidth;
                      final int crossAxisCount = maxWidth >= 1200 ? 3 : (maxWidth >= 760 ? 2 : 1);

                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          mainAxisSpacing: 16.0,
                          crossAxisSpacing: 16.0,
                          mainAxisExtent: 182.0,
                        ),
                        itemCount: filteredRestaurants.length,
                        itemBuilder: (context, index) {
                          final restaurant = filteredRestaurants[index];
                          return _buildDesktopRestaurantCard(
                            theme: theme,
                            colorScheme: colorScheme,
                            isDark: isDark,
                            restaurant: restaurant,
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

  // ─── CARD RISTORANTE DESKTOP ──────────────────────────────────────────────
  Widget _buildDesktopRestaurantCard({
    required ThemeData theme,
    required ColorScheme colorScheme,
    required bool isDark,
    required UsersRecord restaurant,
  }) {
    final initialLetter = restaurant.displayName.isNotEmpty
        ? restaurant.displayName[0].toUpperCase()
        : 'R';

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : const Color(0xFFE2E8F0),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 8.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16.0),
        child: InkWell(
          borderRadius: BorderRadius.circular(16.0),
          onTap: () {
            context.pushNamed(
              AdminDettaglioRistoranteWidget.routeName,
              queryParameters: {
                'utenteRef': serializeParam(
                  restaurant.reference,
                  ParamType.DocumentReference,
                ),
              }.withoutNulls,
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Intestazione con Avatar, Nome ed Email
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48.0,
                      height: 48.0,
                      decoration: BoxDecoration(
                        color: const Color(0xFF7C3AED).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(
                          color: const Color(0xFF7C3AED).withValues(alpha: 0.25),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: restaurant.photoUrl.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(11.0),
                              child: Image.network(
                                restaurant.photoUrl,
                                width: 48.0,
                                height: 48.0,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Text(
                                  initialLetter,
                                  style: const TextStyle(
                                    color: Color(0xFF7C3AED),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18.0,
                                  ),
                                ),
                              ),
                            )
                          : Text(
                              initialLetter,
                              style: const TextStyle(
                                color: Color(0xFF7C3AED),
                                fontWeight: FontWeight.bold,
                                fontSize: 18.0,
                              ),
                            ),
                    ),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            restaurant.displayName.isNotEmpty
                                ? restaurant.displayName
                                : 'Ristorante senza nome',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 15.0,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.2,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 2.0),
                          Text(
                            restaurant.email.isNotEmpty
                                ? restaurant.email
                                : 'Nessuna email specificata',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12.0,
                              color: isDark
                                  ? const Color(0xFF94A3B8)
                                  : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    // Badge stato
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(
                          color: const Color(0xFF10B981).withValues(alpha: 0.25),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            radius: 3.5,
                            backgroundColor: Color(0xFF10B981),
                          ),
                          SizedBox(width: 5.0),
                          Text(
                            'Attivo',
                            style: TextStyle(
                              fontSize: 11.0,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF10B981),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Separatore sottile
                Divider(
                  height: 16.0,
                  thickness: 1.0,
                  color: isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFF1F5F9),
                ),

                // Pulsanti di azione rapida
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          context.pushNamed(
                            AdminDettaglioRistoranteWidget.routeName,
                            queryParameters: {
                              'utenteRef': serializeParam(
                                restaurant.reference,
                                ParamType.DocumentReference,
                              ),
                            }.withoutNulls,
                          );
                        },
                        icon: const Icon(Icons.manage_accounts_rounded, size: 15.0),
                        label: const Text(
                          'Dettagli',
                          style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.w600),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                          side: BorderSide(
                            color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
                          ),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          context.pushNamed(
                            HomeRistoratoreWidget.routeName,
                            queryParameters: {
                              'ristoranteRef': serializeParam(
                                restaurant.reference,
                                ParamType.DocumentReference,
                              ),
                            }.withoutNulls,
                          );
                        },
                        icon: const Icon(Icons.restaurant_menu_rounded, size: 15.0),
                        label: const Text(
                          'Vedi Menù',
                          style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.w600),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7C3AED),
                          foregroundColor: Colors.white,
                          elevation: 0.0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── CARD KPI TOP BAR ─────────────────────────────────────────────────────
  Widget _buildKpiCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    required bool isDark,
    VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 8.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16.0),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16.0),
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        value,
                        style: TextStyle(
                          fontSize: 22.0,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.5,
                          color: accentColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 44.0,
                  height: 44.0,
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    icon,
                    color: accentColor,
                    size: 22.0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── CHIP FILTRO ──────────────────────────────────────────────────────────
  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 7.0),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF7C3AED)
              : (isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF7C3AED)
                : (isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0)),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.0,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected
                ? Colors.white
                : (isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569)),
          ),
        ),
      ),
    );
  }

  // ─── NAV CATEGORY HEADER ──────────────────────────────────────────────────
  Widget _buildNavCategoryHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 6.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
        ),
      ),
    );
  }

  // ─── VOCE DEL MENU LATERALE ───────────────────────────────────────────────
  Widget _buildSidebarItem({
    required IconData icon,
    required String title,
    required bool isSelected,
    required ColorScheme colorScheme,
    required bool isDark,
    required VoidCallback onTap,
    Color? iconColor,
    String? badgeText,
    Color? badgeColor,
  }) {
    final effectiveIconColor = isSelected ? const Color(0xFF7C3AED) : (iconColor ?? const Color(0xFF64748B));

    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF7C3AED).withValues(alpha: isDark ? 0.20 : 0.10)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10.0),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF7C3AED).withValues(alpha: 0.35)
                  : Colors.transparent,
              width: 1.0,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20.0,
                color: effectiveIconColor,
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13.0,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? (isDark ? Colors.white : const Color(0xFF7C3AED))
                        : (isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569)),
                  ),
                ),
              ),
              if (badgeText != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7.0, vertical: 2.0),
                  decoration: BoxDecoration(
                    color: badgeColor ?? (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Text(
                    badgeText,
                    style: TextStyle(
                      fontSize: 11.0,
                      fontWeight: FontWeight.bold,
                      color: badgeColor != null
                          ? Colors.white
                          : (isDark ? Colors.white : const Color(0xFF0F172A)),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // VISTA MOBILE (< 800px) CONFORME AL DESIGN SYSTEM GEMINI.md
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildMobileUI({
    required ThemeData theme,
    required ColorScheme colorScheme,
    required bool isDark,
    required List<UsersRecord> allRestaurants,
    required List<UsersRecord> filteredRestaurants,
  }) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: theme.scaffoldBackgroundColor,
        endDrawer: Drawer(
          width: 320.0,
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          child: wrapWithModel(
            model: _model.adminDrawerMenuModel,
            updateCallback: () => safeSetState(() {}),
            child: const AdminDrawerMenuWidget(),
          ),
        ),
        appBar: widget.embedded
            ? null
            : AppBar(
                automaticallyImplyLeading: false,
                leading: const SizedBox(width: 48.0),
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
                        Icons.admin_panel_settings_rounded,
                        color: theme.colorScheme.primary,
                        size: 20.0,
                      ),
                    ),
                    const SizedBox(width: 10.0),
                    Text(
                      'Dashboard Admin',
                      style: theme.appBarTheme.titleTextStyle ??
                          theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 19.0,
                            letterSpacing: -0.4,
                          ),
                    ),
                  ],
                ),
                actions: [
                  StreamBuilder<List<TicketsRecord>>(
                    stream: queryTicketsRecord(),
                    builder: (context, snapshot) {
                      final apertiCount = snapshot.hasData
                          ? snapshot.data!.where((t) {
                              final s = t.stato.trim().toLowerCase();
                              return s == 'aperto' || s.isEmpty;
                            }).length
                          : 0;

                      return IconButton(
                        icon: Badge(
                          isLabelVisible: apertiCount > 0,
                          backgroundColor: const Color(0xFFEF4444),
                          label: Text(
                            apertiCount > 99 ? '99+' : apertiCount.toString(),
                            style: const TextStyle(
                              fontSize: 10.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          child: const Icon(
                            Icons.menu_rounded,
                            size: 24.0,
                          ),
                        ),
                        onPressed: () => scaffoldKey.currentState?.openEndDrawer(),
                      );
                    },
                  ),
                ],
                centerTitle: true,
                elevation: 0.0,
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(1.0),
                  child: Divider(
                    height: 1.0,
                    thickness: 1.0,
                    color: theme.dividerColor.withValues(alpha: 0.5),
                  ),
                ),
              ),
        body: SafeArea(
          top: true,
          child: Align(
            alignment: const AlignmentDirectional(0.0, -1.0),
            child: SingleChildScrollView(
              controller: _model.columnController,
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
              child: Center(
                child: Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxWidth: 720.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Banner Benvenuto Capo
                      Container(
                        padding: const EdgeInsets.all(24.0),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(20.0),
                          border: Border.all(
                            color: theme.dividerColor.withValues(alpha: 0.6),
                            width: 1.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 20.0,
                              color: Colors.black.withValues(alpha: 0.04),
                              offset: const Offset(0.0, 4.0),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Benvenuto Capo \u{1F44B}',
                                    style: theme.textTheme.headlineMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4.0),
                                  Text(
                                    'Gestione e monitoraggio di tutti i ristoranti registrati',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.textTheme.bodySmall?.color ??
                                          theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(14.0),
                                border: Border.all(
                                  color: theme.colorScheme.primary.withValues(alpha: 0.20),
                                  width: 1.0,
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    formatNumber(
                                      allRestaurants.length,
                                      formatType: FormatType.compact,
                                    ),
                                    style: theme.textTheme.headlineSmall?.copyWith(
                                      color: theme.colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Ristoranti',
                                    style: theme.textTheme.labelMedium?.copyWith(
                                      color: theme.colorScheme.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16.0),

                      // Card Scorciatoia Metriche
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFFF59E0B).withValues(alpha: 0.12),
                              const Color(0xFF8B5CF6).withValues(alpha: 0.08),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(18.0),
                          border: Border.all(
                            color: const Color(0xFFF59E0B).withValues(alpha: 0.28),
                            width: 1.0,
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(18.0),
                            onTap: () => context.pushNamed(AdminMetricheWidget.routeName),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 14.0),
                              child: Row(
                                children: [
                                  Container(
                                    width: 44.0,
                                    height: 44.0,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF59E0B).withValues(alpha: 0.20),
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    alignment: Alignment.center,
                                    child: const Icon(
                                      Icons.insights_rounded,
                                      color: Color(0xFFD97706),
                                      size: 24.0,
                                    ),
                                  ),
                                  const SizedBox(width: 14.0),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Metriche del Business & Costi Server',
                                          style: theme.textTheme.titleSmall?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15.0,
                                          ),
                                        ),
                                        const SizedBox(height: 2.0),
                                        Text(
                                          'Ristoranti attivi oggi, utenti registrati e spazio GB foto Firebase',
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            color: theme.textTheme.bodySmall?.color ??
                                                theme.colorScheme.onSurface.withValues(alpha: 0.65),
                                            fontSize: 12.0,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8.0),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFD97706),
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Vedi',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(width: 4.0),
                                        Icon(
                                          Icons.arrow_forward_rounded,
                                          color: Colors.white,
                                          size: 14.0,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12.0),

                      // Card Scorciatoia Cronologia Azioni
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF3B82F6).withValues(alpha: 0.12),
                              const Color(0xFF06B6D4).withValues(alpha: 0.08),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(18.0),
                          border: Border.all(
                            color: const Color(0xFF3B82F6).withValues(alpha: 0.28),
                            width: 1.0,
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(18.0),
                            onTap: () => context.pushNamed(AdminCronologiaAzioniWidget.routeName),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 14.0),
                              child: Row(
                                children: [
                                  Container(
                                    width: 44.0,
                                    height: 44.0,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF3B82F6).withValues(alpha: 0.20),
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    alignment: Alignment.center,
                                    child: const Icon(
                                      Icons.manage_history_rounded,
                                      color: Color(0xFF2563EB),
                                      size: 24.0,
                                    ),
                                  ),
                                  const SizedBox(width: 14.0),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Cronologia Azioni (Audit Log)',
                                          style: theme.textTheme.titleSmall?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15.0,
                                          ),
                                        ),
                                        const SizedBox(height: 2.0),
                                        Text(
                                          'Tracciamento eliminazioni e modifiche piatti/categorie',
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            color: theme.textTheme.bodySmall?.color ??
                                                theme.colorScheme.onSurface.withValues(alpha: 0.65),
                                            fontSize: 12.0,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8.0),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF2563EB),
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Vedi',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(width: 4.0),
                                        Icon(
                                          Icons.arrow_forward_rounded,
                                          color: Colors.white,
                                          size: 14.0,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20.0),

                      // Barra di Ricerca Mobile
                      Container(
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(16.0),
                          border: Border.all(
                            color: theme.dividerColor.withValues(alpha: 0.6),
                            width: 1.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 14.0,
                              color: Colors.black.withValues(alpha: 0.03),
                              offset: const Offset(0.0, 3.0),
                            ),
                          ],
                        ),
                        child: TextFormField(
                          controller: _model.barraRicercaTextController,
                          focusNode: _model.barraRicercaFocusNode,
                          onChanged: (_) => EasyDebounce.debounce(
                            '_model.barraRicercaTextController',
                            const Duration(milliseconds: 300),
                            () => safeSetState(() {}),
                          ),
                          decoration: InputDecoration(
                            isDense: false,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                            prefixIcon: Icon(
                              Icons.search_rounded,
                              color: theme.colorScheme.primary,
                              size: 22.0,
                            ),
                            suffixIcon: (_model.barraRicercaTextController?.text.isNotEmpty ?? false)
                                ? IconButton(
                                    icon: const Icon(Icons.clear_rounded, size: 20.0),
                                    onPressed: () {
                                      _model.barraRicercaTextController?.clear();
                                      safeSetState(() {});
                                    },
                                  )
                                : null,
                            hintText: 'Cerca per email o nome ristorante...',
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                          ),
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),

                      const SizedBox(height: 24.0),

                      // Lista Ristoranti Mobile
                      if (filteredRestaurants.isEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            borderRadius: BorderRadius.circular(20.0),
                            border: Border.all(
                              color: theme.dividerColor.withValues(alpha: 0.6),
                              width: 1.0,
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 64.0,
                                height: 64.0,
                                decoration: BoxDecoration(
                                  color: theme.dividerColor.withValues(alpha: 0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.storefront_outlined,
                                  size: 32.0,
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                                ),
                              ),
                              const SizedBox(height: 16.0),
                              Text(
                                'Nessun ristorante trovato',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6.0),
                              Text(
                                'Prova a modificare i termini di ricerca',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        ListView.separated(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: filteredRestaurants.length,
                          separatorBuilder: (context, _) => const SizedBox(height: 12.0),
                          itemBuilder: (context, index) {
                            final item = filteredRestaurants[index];
                            final initialLetter = item.displayName.isNotEmpty
                                ? item.displayName[0].toUpperCase()
                                : 'R';

                            return Container(
                              decoration: BoxDecoration(
                                color: theme.cardColor,
                                borderRadius: BorderRadius.circular(16.0),
                                border: Border.all(
                                  color: theme.dividerColor.withValues(alpha: 0.6),
                                  width: 1.0,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    blurRadius: 10.0,
                                    color: Colors.black.withValues(alpha: 0.03),
                                    offset: const Offset(0.0, 2.0),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(16.0),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(16.0),
                                  onTap: () {
                                    context.pushNamed(
                                      AdminDettaglioRistoranteWidget.routeName,
                                      queryParameters: {
                                        'utenteRef': serializeParam(
                                          item.reference,
                                          ParamType.DocumentReference,
                                        ),
                                      }.withoutNulls,
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 44.0,
                                          height: 44.0,
                                          decoration: BoxDecoration(
                                            color: theme.colorScheme.primary.withValues(alpha: 0.12),
                                            borderRadius: BorderRadius.circular(12.0),
                                          ),
                                          alignment: Alignment.center,
                                          child: item.photoUrl.isNotEmpty
                                              ? ClipRRect(
                                                  borderRadius: BorderRadius.circular(12.0),
                                                  child: Image.network(
                                                    item.photoUrl,
                                                    width: 44.0,
                                                    height: 44.0,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (_, __, ___) => Text(
                                                      initialLetter,
                                                      style: theme.textTheme.titleMedium?.copyWith(
                                                        color: theme.colorScheme.primary,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              : Text(
                                                  initialLetter,
                                                  style: theme.textTheme.titleMedium?.copyWith(
                                                    color: theme.colorScheme.primary,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                        ),
                                        const SizedBox(width: 14.0),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item.displayName.isNotEmpty
                                                    ? item.displayName
                                                    : 'Ristorante senza nome',
                                                style: theme.textTheme.titleSmall?.copyWith(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              const SizedBox(height: 2.0),
                                              Text(
                                                item.email,
                                                style: theme.textTheme.bodyMedium?.copyWith(
                                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 10.0),
                                        Container(
                                          width: 32.0,
                                          height: 32.0,
                                          decoration: BoxDecoration(
                                            color: theme.dividerColor.withValues(alpha: 0.2),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.chevron_right_rounded,
                                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                            size: 20.0,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AdminSectionInfo {
  const _AdminSectionInfo({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
}