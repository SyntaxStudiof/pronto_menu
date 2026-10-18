import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/dashboard_ristorante/desktop_orders_table_view.dart';
import '/dashboard_ristorante/desktop_menu_view.dart';
import '/dashboard_ristorante/desktop_client_preview_view.dart';
import '/dashboard_ristorante/desktop_archive_view.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/theme_provider.dart';
import '/index.dart';

/// Componente responsive che rileva la dimensione dello schermo:
/// - Larghezza < 800px: Mostra la UI mobile attuale.
/// - Larghezza >= 800px: Mostra la vista Dashboard per schermi grandi (PC) con Sidebar a sinistra.
class ResponsiveDashboard extends StatelessWidget {
  const ResponsiveDashboard({
    super.key,
    required this.mobile,
    this.desktop,
    this.breakpoint = 800.0,
    this.ristoranteRef,
    this.userDoc,
    this.initialNavIndex = 0,
  });

  /// Widget mostrato su smartphone e schermi stretti (< breakpoint)
  final Widget mobile;

  /// Widget personalizzato per desktop/PC (>= breakpoint).
  /// Se omesso, mostra la shell predefinita con Sidebar [DashboardDesktopShell].
  final Widget? desktop;

  /// Punto di interruzione in pixel (default: 800.0px)
  final double breakpoint;

  /// Riferimento Firebase del ristorante (stesso database)
  final DocumentReference? ristoranteRef;

  /// Dati utente/ristorante caricati da Firestore
  final UsersRecord? userDoc;

  /// Indice della sezione inizialmente attiva (0: Menù, 1: Ordini, 2: Storico)
  final int initialNavIndex;

  /// Metodo statico per verificare se lo schermo è Desktop
  static bool isDesktop(BuildContext context, [double breakpoint = 800.0]) {
    return MediaQuery.sizeOf(context).width >= breakpoint;
  }

  /// Metodo statico per verificare se lo schermo è Mobile
  static bool isMobile(BuildContext context, [double breakpoint = 800.0]) {
    return MediaQuery.sizeOf(context).width < breakpoint;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= breakpoint) {
          return desktop ??
              DashboardDesktopShell(
                ristoranteRef: ristoranteRef,
                userDoc: userDoc,
                mobileFallback: mobile,
                initialNavIndex: initialNavIndex,
              );
        }
        return mobile;
      },
    );
  }
}

/// Shell Desktop per schermi grandi (PC) con Sidebar a sinistra
class DashboardDesktopShell extends StatefulWidget {
  const DashboardDesktopShell({
    super.key,
    this.ristoranteRef,
    this.userDoc,
    this.mobileFallback,
    this.initialNavIndex = 0,
  });

  final DocumentReference? ristoranteRef;
  final UsersRecord? userDoc;
  final Widget? mobileFallback;
  final int initialNavIndex;

  @override
  State<DashboardDesktopShell> createState() => _DashboardDesktopShellState();
}

class _DashboardDesktopShellState extends State<DashboardDesktopShell> {
  static const List<String> _viewIds = [
    'menu',
    'ordini',
    'archivio',
    'anteprima_cliente',
    'qr_code',
    'personalizzazione',
    'dispensa',
    'cestino',
    'profilo',
    'impostazioni',
    'supporto',
    'admin',
  ];

  late String _currentViewId;
  final Set<String> _visitedViews = {};
  bool _forceMobilePreview = false;
  bool _sidebarCollapsed = false;
  late Stream<List<OrdersRecord>> _badgeCountStream;

  void _switchView(String newId) {
    if (_currentViewId != newId) {
      setState(() {
        _currentViewId = newId;
        _visitedViews.add(newId);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    switch (widget.initialNavIndex) {
      case 1:
        _currentViewId = 'ordini';
        break;
      case 2:
        _currentViewId = 'archivio';
        break;
      default:
        _currentViewId = 'menu';
    }
    _visitedViews.add(_currentViewId);

    _badgeCountStream = queryOrdersRecord(
      queryBuilder: (q) => q
          .where('visto', isEqualTo: false)
          .where('stato_ordine', isEqualTo: 'in_attesa'),
      limit: 20,
    );
  }

  _SidebarSection _getSectionInfo(String viewId) {
    switch (viewId) {
      case 'ordini':
        return const _SidebarSection(
          id: 'ordini',
          title: 'Ordini Live',
          subtitle: 'Comande in cucina in tempo reale',
          icon: Icons.soup_kitchen_rounded,
        );
      case 'archivio':
      case 'storico':
        return const _SidebarSection(
          id: 'archivio',
          title: 'Archivio Ordini',
          subtitle: 'Comande archiviate, statistiche e report CSV',
          icon: Icons.inventory_2_rounded,
        );
      case 'anteprima_cliente':
        return const _SidebarSection(
          id: 'anteprima_cliente',
          title: 'Anteprima Menù Cliente',
          subtitle: 'Visualizzazione fedele su smartphone',
          icon: Icons.visibility_rounded,
        );
      case 'qr_code':
        return const _SidebarSection(
          id: 'qr_code',
          title: 'QR Code Menù',
          subtitle: 'Generatore, stampa e download del QR code',
          icon: Icons.qr_code_2_rounded,
        );
      case 'personalizzazione':
        return const _SidebarSection(
          id: 'personalizzazione',
          title: 'Personalizza Stile',
          subtitle: 'Temi, palette colori, font e layout piatti',
          icon: Icons.palette_rounded,
        );
      case 'dispensa':
        return const _SidebarSection(
          id: 'dispensa',
          title: 'Gestione Dispensa',
          subtitle: 'Giacenze, scorte e ingredienti esauriti',
          icon: Icons.kitchen_rounded,
        );
      case 'cestino':
        return const _SidebarSection(
          id: 'cestino',
          title: 'Cestino Piatti',
          subtitle: 'Piatti eliminati temporaneamente',
          icon: Icons.delete_outline_rounded,
        );
      case 'profilo':
        return const _SidebarSection(
          id: 'profilo',
          title: 'Il mio Profilo',
          subtitle: 'Dati anagrafici e del ristorante',
          icon: Icons.person_rounded,
        );
      case 'impostazioni':
        return const _SidebarSection(
          id: 'impostazioni',
          title: 'Impostazioni',
          subtitle: 'Configurazioni generali e preferenze',
          icon: Icons.settings_rounded,
        );
      case 'supporto':
        return const _SidebarSection(
          id: 'supporto',
          title: 'Supporto Clienti',
          subtitle: 'Assistenza e ticket per il ristoratore',
          icon: Icons.help_outline_rounded,
        );
      case 'admin':
        return const _SidebarSection(
          id: 'admin',
          title: 'Admin Dashboard',
          subtitle: 'Pannello di controllo amministrativo',
          icon: Icons.admin_panel_settings_rounded,
        );
      case 'menu':
      default:
        return const _SidebarSection(
          id: 'menu',
          title: 'Menù & Categorie',
          subtitle: 'Gestione piatti, prezzi e categorie',
          icon: Icons.restaurant_menu_rounded,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final themeProvider = Provider.of<ThemeProvider>(context);

    // Se l'utente attiva la simulazione mobile su PC
    if (_forceMobilePreview && widget.mobileFallback != null) {
      return Stack(
        children: [
          widget.mobileFallback!,
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

    final docRef = widget.ristoranteRef ?? currentUserReference;
    final nomeRistorante = widget.userDoc?.displayName.isNotEmpty == true
        ? widget.userDoc!.displayName
        : (currentUserDisplayName.isNotEmpty ? currentUserDisplayName : 'Il tuo Ristorante');

    final activeSection = _getSectionInfo(_currentViewId);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      body: Row(
        children: [
          // ═════════════════════════════════════════════════════════════════
          // 1. SIDEBAR LATERALE A SINISTRA (Desktop PC)
          // ═════════════════════════════════════════════════════════════════
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
                                gradient: LinearGradient(
                                  colors: [
                                    colorScheme.primary,
                                    colorScheme.primary.withValues(alpha: 0.8),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(10.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: colorScheme.primary.withValues(alpha: 0.25),
                                    blurRadius: 8.0,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.restaurant_rounded,
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
                                    'Dashboard Ristoratore',
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

                // Card Ristorante Connesso
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
                          backgroundColor: colorScheme.primary.withValues(alpha: 0.15),
                          child: Icon(
                            Icons.storefront_rounded,
                            size: 20.0,
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 10.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                nomeRistorante,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13.0,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                                ),
                              ),
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
                                    'Online • Firebase Live',
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

                // Voci del Menu Navigazione
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 14.0),
                    children: [
                      _buildNavCategoryHeader('PRINCIPALE', isDark),
                      _buildSidebarItem(
                        icon: Icons.restaurant_menu_rounded,
                        title: 'Menù & Categorie',
                        isSelected: _currentViewId == 'menu',
                        colorScheme: colorScheme,
                        isDark: isDark,
                        onTap: () => _switchView('menu'),
                      ),
                      _buildSidebarItem(
                        icon: Icons.soup_kitchen_rounded,
                        title: 'Ordini Live',
                        isSelected: _currentViewId == 'ordini',
                        colorScheme: colorScheme,
                        isDark: isDark,
                        badgeCountStream: _badgeCountStream,
                        onTap: () => _switchView('ordini'),
                      ),
                      _buildSidebarItem(
                        icon: Icons.inventory_2_rounded,
                        title: 'Archivio Ordini',
                        isSelected: _currentViewId == 'archivio',
                        colorScheme: colorScheme,
                        isDark: isDark,
                        iconColor: const Color(0xFF6366F1),
                        onTap: () => _switchView('archivio'),
                      ),

                      const SizedBox(height: 14.0),
                      _buildNavCategoryHeader('STRUMENTI MENU', isDark),
                      _buildSidebarItem(
                        icon: Icons.visibility_rounded,
                        title: 'Vedi come Cliente',
                        isSelected: _currentViewId == 'anteprima_cliente',
                        colorScheme: colorScheme,
                        isDark: isDark,
                        iconColor: const Color(0xFF10B981),
                        onTap: () => _switchView('anteprima_cliente'),
                      ),
                      _buildSidebarItem(
                        icon: Icons.qr_code_2_rounded,
                        title: 'QR Code Menù',
                        isSelected: _currentViewId == 'qr_code',
                        colorScheme: colorScheme,
                        isDark: isDark,
                        iconColor: const Color(0xFF0EA5E9),
                        onTap: () => _switchView('qr_code'),
                      ),
                      _buildSidebarItem(
                        icon: Icons.palette_rounded,
                        title: 'Personalizza Stile',
                        isSelected: _currentViewId == 'personalizzazione',
                        colorScheme: colorScheme,
                        isDark: isDark,
                        iconColor: const Color(0xFF8B5CF6),
                        onTap: () => _switchView('personalizzazione'),
                      ),
                      if (widget.userDoc?.dispensaAttiva == true)
                        _buildSidebarItem(
                          icon: Icons.kitchen_rounded,
                          title: 'Dispensa',
                          isSelected: _currentViewId == 'dispensa',
                          colorScheme: colorScheme,
                          isDark: isDark,
                          iconColor: const Color(0xFFF97316),
                          onTap: () => _switchView('dispensa'),
                        ),
                      _buildSidebarItem(
                        icon: Icons.delete_outline_rounded,
                        title: 'Cestino',
                        isSelected: _currentViewId == 'cestino',
                        colorScheme: colorScheme,
                        isDark: isDark,
                        iconColor: const Color(0xFFD97706),
                        onTap: () => _switchView('cestino'),
                      ),

                      const SizedBox(height: 14.0),
                      _buildNavCategoryHeader('CONFIGURAZIONE', isDark),
                      _buildSidebarItem(
                        icon: Icons.person_rounded,
                        title: 'Il mio Profilo',
                        isSelected: _currentViewId == 'profilo',
                        colorScheme: colorScheme,
                        isDark: isDark,
                        iconColor: const Color(0xFF2563EB),
                        onTap: () => _switchView('profilo'),
                      ),
                      _buildSidebarItem(
                        icon: Icons.settings_rounded,
                        title: 'Impostazioni',
                        isSelected: _currentViewId == 'impostazioni',
                        colorScheme: colorScheme,
                        isDark: isDark,
                        iconColor: const Color(0xFF64748B),
                        onTap: () => _switchView('impostazioni'),
                      ),
                      _buildSidebarItem(
                        icon: Icons.help_outline_rounded,
                        title: 'Supporto Clienti',
                        isSelected: _currentViewId == 'supporto',
                        colorScheme: colorScheme,
                        isDark: isDark,
                        iconColor: const Color(0xFF059669),
                        onTap: () => _switchView('supporto'),
                      ),
                      if (currentUserDocument?.isAdmin == true)
                        _buildSidebarItem(
                          icon: Icons.admin_panel_settings_rounded,
                          title: 'Admin Dashboard',
                          isSelected: false,
                          colorScheme: colorScheme,
                          isDark: isDark,
                          iconColor: const Color(0xFFDC2626),
                          onTap: () => context.goNamed(AdminDashboardWidget.routeName),
                        ),
                    ],
                  ),
                ),

                // Footer con Tema e Logout
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
                      // Selettore Dark/Light Mode
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
                      // Tasto Log Out
                      InkWell(
                        onTap: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Disconnessione'),
                              content: const Text('Sei sicuro di voler uscire dal tuo account?'),
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
                            if (!context.mounted) return;
                            GoRouter.of(context).prepareAuthEvent();
                            await authManager.signOut();
                            if (!context.mounted) return;
                            GoRouter.of(context).clearRedirectLocation();
                            context.pushNamedAuth(
                              AuthWelcomeWidget.routeName,
                              context.mounted,
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

          // ═════════════════════════════════════════════════════════════════
          // 2. AREA CONTENUTO PRINCIPALE (A destra della Sidebar)
          // ═════════════════════════════════════════════════════════════════
          Expanded(
            child: Column(
              children: [
                // TopBar Superiore
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
                      // Pulsante Riapri Barra Laterale (visibile quando compressa)
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
                        color: colorScheme.primary,
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
                          color: colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6.0),
                        ),
                        child: Text(
                          'Desktop View',
                          style: TextStyle(
                            fontSize: 11.0,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                      const Spacer(),

                      // Pulsante: Prova vista mobile
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

                      // Badge Firebase Online
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

                // Canvas Centrale
                Expanded(
                  child: _buildCanvasContent(activeSection, docRef, isDark, colorScheme),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCanvasContent(
    _SidebarSection activeSection,
    DocumentReference? docRef,
    bool isDark,
    ColorScheme colorScheme,
  ) {
    final targetRef = docRef ?? currentUserReference;

    final currentIndex = _viewIds.indexOf(_currentViewId);
    final effectiveIndex = currentIndex >= 0 ? currentIndex : 0;

    return IndexedStack(
      index: effectiveIndex,
      children: _viewIds.map((id) {
        if (!_visitedViews.contains(id)) {
          return const SizedBox.shrink();
        }
        switch (id) {
          case 'menu':
            return DesktopMenuView(
              key: const PageStorageKey('tab_view_menu'),
              ristoranteRef: targetRef,
            );
          case 'ordini':
            return DesktopOrdersTableView(
              key: const PageStorageKey('tab_view_ordini'),
              ristoranteRef: targetRef,
              initialStatusFilter: 'all',
            );
          case 'archivio':
          case 'storico':
            return DesktopArchiveView(
              key: const PageStorageKey('tab_view_archivio'),
              ristoranteRef: targetRef,
            );
          case 'anteprima_cliente':
            return DesktopClientPreviewView(
              key: const PageStorageKey('tab_view_anteprima_cliente'),
              ristoranteRef: targetRef,
              onNavigateToQR: () => _switchView('qr_code'),
            );
          case 'qr_code':
            return const ImpostazioniQRWidget(
              key: PageStorageKey('tab_view_qr_code'),
              embedded: true,
            );
          case 'personalizzazione':
            return PersonalizzazioneWidget(
              key: const PageStorageKey('tab_view_personalizzazione'),
              ristoranteRef: targetRef,
              embedded: true,
            );
          case 'dispensa':
            return GestioneDispensaWidget(
              key: const PageStorageKey('tab_view_dispensa'),
              ristoranteRef: targetRef,
              embedded: true,
            );
          case 'cestino':
            return const CestinoWidget(
              key: PageStorageKey('tab_view_cestino'),
              embedded: true,
            );
          case 'profilo':
            return ProfiloUtenteWidget(
              key: const PageStorageKey('tab_view_profilo'),
              ristoranteRef: targetRef,
              embedded: true,
            );
          case 'impostazioni':
            return ImpostazioniUtenteWidget(
              key: const PageStorageKey('tab_view_impostazioni'),
              ristoranteRef: targetRef,
              embedded: true,
            );
          case 'supporto':
            return SupportoRistoratoreWidget(
              key: const PageStorageKey('tab_view_supporto'),
              ristoranteRef: targetRef,
              embedded: true,
            );
          case 'admin':
            return const AdminDashboardWidget(
              key: PageStorageKey('tab_view_admin'),
              embedded: true,
            );
          default:
            return const SizedBox.shrink();
        }
      }).toList(),
    );
  }

  Widget _buildNavCategoryHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10.0, 8.0, 10.0, 6.0),
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

  Widget _buildSidebarItem({
    required IconData icon,
    required String title,
    required bool isSelected,
    required ColorScheme colorScheme,
    required bool isDark,
    required VoidCallback onTap,
    Color? iconColor,
    Stream<List<OrdersRecord>>? badgeCountStream,
  }) {
    final effectiveIconColor = iconColor ?? (isSelected ? colorScheme.primary : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)));

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10.0),
          hoverColor: colorScheme.primary.withValues(alpha: isDark ? 0.08 : 0.05),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 9.5),
            decoration: BoxDecoration(
              color: isSelected
                  ? colorScheme.primary.withValues(alpha: isDark ? 0.16 : 0.10)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10.0),
              border: Border.all(
                color: isSelected
                    ? colorScheme.primary.withValues(alpha: 0.3)
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
                          ? colorScheme.primary
                          : (isDark ? const Color(0xFFE2E8F0) : const Color(0xFF334155)),
                    ),
                  ),
                ),
                if (badgeCountStream != null)
                  StreamBuilder<List<OrdersRecord>>(
                    stream: badgeCountStream,
                    builder: (context, snapshot) {
                      final count = snapshot.data?.length ?? 0;
                      if (count == 0) return const SizedBox.shrink();
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7.0, vertical: 2.0),
                        decoration: BoxDecoration(
                          color: colorScheme.error,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Text(
                          '$count',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
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
    );
  }
}

class _SidebarSection {
  const _SidebarSection({
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
