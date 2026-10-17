import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
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
  });

  final DocumentReference? ristoranteRef;
  final UsersRecord? userDoc;
  final Widget? mobileFallback;

  @override
  State<DashboardDesktopShell> createState() => _DashboardDesktopShellState();
}

class _DashboardDesktopShellState extends State<DashboardDesktopShell> {
  int _activeNavIndex = 0;
  bool _forceMobilePreview = false;

  final List<_SidebarSection> _navSections = const [
    _SidebarSection(
      index: 0,
      title: 'Menù & Categorie',
      subtitle: 'Gestione piatti, prezzi e categorie',
      icon: Icons.restaurant_menu_rounded,
    ),
    _SidebarSection(
      index: 1,
      title: 'Ordini Live',
      subtitle: 'Comande in cucina in tempo reale',
      icon: Icons.soup_kitchen_rounded,
    ),
    _SidebarSection(
      index: 2,
      title: 'Storico & Cassa',
      subtitle: 'Comande completate e riepilogo vendite',
      icon: Icons.receipt_long_rounded,
    ),
  ];

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

    final activeSection = _navSections.firstWhere(
      (s) => s.index == _activeNavIndex,
      orElse: () => _navSections[0],
    );

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      body: Row(
        children: [
          // ═════════════════════════════════════════════════════════════════
          // 1. SIDEBAR LATERALE A SINISTRA (Desktop PC)
          // ═════════════════════════════════════════════════════════════════
          Container(
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
                // Header Logo & Brand
                Padding(
                  padding: const EdgeInsets.fromLTRB(20.0, 24.0, 20.0, 16.0),
                  child: Row(
                    children: [
                      Container(
                        width: 42.0,
                        height: 42.0,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              colorScheme.primary,
                              colorScheme.primary.withValues(alpha: 0.8),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12.0),
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
                          size: 24.0,
                        ),
                      ),
                      const SizedBox(width: 12.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'ProntoMenu',
                              style: TextStyle(
                                fontSize: 17.0,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.4,
                                color: isDark ? Colors.white : const Color(0xFF0F172A),
                              ),
                            ),
                            Text(
                              'Dashboard Ristoratore',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w500,
                                color: isDark
                                    ? const Color(0xFF94A3B8)
                                    : const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
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
                        isSelected: _activeNavIndex == 0,
                        colorScheme: colorScheme,
                        isDark: isDark,
                        onTap: () => setState(() => _activeNavIndex = 0),
                      ),
                      _buildSidebarItem(
                        icon: Icons.soup_kitchen_rounded,
                        title: 'Ordini Live',
                        isSelected: _activeNavIndex == 1,
                        colorScheme: colorScheme,
                        isDark: isDark,
                        badgeCountStream: queryOrdersRecord(
                          queryBuilder: (q) => q
                              .where('visto', isEqualTo: false)
                              .where('stato_ordine', isEqualTo: 'in_attesa'),
                        ),
                        onTap: () => setState(() => _activeNavIndex = 1),
                      ),
                      _buildSidebarItem(
                        icon: Icons.receipt_long_rounded,
                        title: 'Storico & Cassa',
                        isSelected: _activeNavIndex == 2,
                        colorScheme: colorScheme,
                        isDark: isDark,
                        onTap: () => setState(() => _activeNavIndex = 2),
                      ),

                      const SizedBox(height: 14.0),
                      _buildNavCategoryHeader('STRUMENTI MENU', isDark),
                      _buildSidebarItem(
                        icon: Icons.visibility_rounded,
                        title: 'Vedi come Cliente',
                        isSelected: false,
                        colorScheme: colorScheme,
                        isDark: isDark,
                        iconColor: const Color(0xFF10B981),
                        onTap: () {
                          context.pushNamed(
                            HubClienteWidget.routeName,
                            queryParameters: {
                              'ristoranteRef': serializeParam(
                                docRef,
                                ParamType.DocumentReference,
                              ),
                              'isAnteprima': serializeParam(
                                true,
                                ParamType.bool,
                              ),
                            }.withoutNulls,
                          );
                        },
                      ),
                      _buildSidebarItem(
                        icon: Icons.qr_code_2_rounded,
                        title: 'QR Code Menù',
                        isSelected: false,
                        colorScheme: colorScheme,
                        isDark: isDark,
                        iconColor: const Color(0xFF0EA5E9),
                        onTap: () {
                          context.pushNamed(ImpostazioniQRWidget.routeName);
                        },
                      ),
                      _buildSidebarItem(
                        icon: Icons.palette_rounded,
                        title: 'Personalizza Stile',
                        isSelected: false,
                        colorScheme: colorScheme,
                        isDark: isDark,
                        iconColor: const Color(0xFF8B5CF6),
                        onTap: () {
                          context.pushNamed(
                            PersonalizzazioneWidget.routeName,
                            queryParameters: {
                              'ristoranteRef': serializeParam(
                                docRef,
                                ParamType.DocumentReference,
                              ),
                            }.withoutNulls,
                          );
                        },
                      ),
                      if (widget.userDoc?.dispensaAttiva == true)
                        _buildSidebarItem(
                          icon: Icons.kitchen_rounded,
                          title: 'Dispensa',
                          isSelected: false,
                          colorScheme: colorScheme,
                          isDark: isDark,
                          iconColor: const Color(0xFFF97316),
                          onTap: () {
                            context.pushNamed(
                              GestioneDispensaWidget.routeName,
                              queryParameters: {
                                'ristoranteRef': serializeParam(
                                  docRef,
                                  ParamType.DocumentReference,
                                ),
                              }.withoutNulls,
                            );
                          },
                        ),
                      _buildSidebarItem(
                        icon: Icons.delete_outline_rounded,
                        title: 'Cestino',
                        isSelected: false,
                        colorScheme: colorScheme,
                        isDark: isDark,
                        iconColor: const Color(0xFFD97706),
                        onTap: () {
                          context.pushNamed(CestinoWidget.routeName);
                        },
                      ),

                      const SizedBox(height: 14.0),
                      _buildNavCategoryHeader('CONFIGURAZIONE', isDark),
                      _buildSidebarItem(
                        icon: Icons.person_rounded,
                        title: 'Il mio Profilo',
                        isSelected: false,
                        colorScheme: colorScheme,
                        isDark: isDark,
                        iconColor: const Color(0xFF2563EB),
                        onTap: () {
                          context.pushNamed(
                            ProfiloUtenteWidget.routeName,
                            queryParameters: {
                              'ristoranteRef': serializeParam(
                                docRef,
                                ParamType.DocumentReference,
                              ),
                            }.withoutNulls,
                          );
                        },
                      ),
                      _buildSidebarItem(
                        icon: Icons.settings_rounded,
                        title: 'Impostazioni',
                        isSelected: false,
                        colorScheme: colorScheme,
                        isDark: isDark,
                        iconColor: const Color(0xFF64748B),
                        onTap: () {
                          context.pushNamed(
                            ImpostazioniUtenteWidget.routeName,
                            queryParameters: {
                              'ristoranteRef': serializeParam(
                                docRef,
                                ParamType.DocumentReference,
                              ),
                            }.withoutNulls,
                          );
                        },
                      ),
                      _buildSidebarItem(
                        icon: Icons.help_outline_rounded,
                        title: 'Supporto Clienti',
                        isSelected: false,
                        colorScheme: colorScheme,
                        isDark: isDark,
                        iconColor: const Color(0xFF059669),
                        onTap: () {
                          context.pushNamed(
                            SupportoRistoratoreWidget.routeName,
                            queryParameters: {
                              'ristoranteRef': serializeParam(
                                docRef,
                                ParamType.DocumentReference,
                              ),
                            }.withoutNulls,
                          );
                        },
                      ),
                      if (currentUserDocument?.isAdmin == true)
                        _buildSidebarItem(
                          icon: Icons.admin_panel_settings_rounded,
                          title: 'Admin Dashboard',
                          isSelected: false,
                          colorScheme: colorScheme,
                          isDark: isDark,
                          iconColor: const Color(0xFFDC2626),
                          onTap: () {
                            context.pushNamed(AdminDashboardWidget.routeName);
                          },
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

          // ═════════════════════════════════════════════════════════════════
          // 2. AREA CONTENUTO PRINCIPALE (A destra della Sidebar)
          // ═════════════════════════════════════════════════════════════════
          Expanded(
            child: Column(
              children: [
                // TopBar Superiore
                Container(
                  height: 64.0,
                  padding: const EdgeInsets.symmetric(horizontal: 28.0),
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
                  child: Center(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 620.0),
                      padding: const EdgeInsets.all(40.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 88.0,
                            height: 88.0,
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withValues(alpha: 0.08),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: colorScheme.primary.withValues(alpha: 0.2),
                                width: 2.0,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              activeSection.icon,
                              size: 42.0,
                              color: colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 24.0),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 5.0),
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                            child: Text(
                              'SEZIONE: ${activeSection.title.toUpperCase()}',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16.0),
                          Text(
                            'Dashboard in costruzione',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 28.0,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 12.0),
                          Text(
                            'Stiamo sviluppando la vista desktop per la gestione di "${activeSection.title}" su schermi grandi. Dal menu laterale a sinistra puoi accedere direttamente a tutti gli strumenti del tuo ristorante.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14.5,
                              height: 1.5,
                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 28.0),
                          // Bottone per aprire vista mobile corrispondente
                          ElevatedButton.icon(
                            onPressed: () {
                              if (_activeNavIndex == 1) {
                                context.pushNamed(
                                  DashboardRistoranteWidget.routeName,
                                  queryParameters: {
                                    'ristoranteRef': serializeParam(
                                      docRef,
                                      ParamType.DocumentReference,
                                    ),
                                  }.withoutNulls,
                                );
                              } else if (_activeNavIndex == 2) {
                                context.pushNamed(
                                  StoricoOrdiniWidget.routeName,
                                  queryParameters: {
                                    'ristoranteRef': serializeParam(
                                      docRef,
                                      ParamType.DocumentReference,
                                    ),
                                  }.withoutNulls,
                                );
                              } else {
                                setState(() => _forceMobilePreview = true);
                              }
                            },
                            icon: const Icon(Icons.open_in_new_rounded, size: 16.0),
                            label: Text(
                              _activeNavIndex == 0
                                  ? 'Apri Gestione Menù (Versione Mobile)'
                                  : (_activeNavIndex == 1
                                      ? 'Apri Schermata Cucina Live'
                                      : 'Apri Storico Ordini'),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.0),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
    required this.index,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final int index;
  final String title;
  final String subtitle;
  final IconData icon;
}
