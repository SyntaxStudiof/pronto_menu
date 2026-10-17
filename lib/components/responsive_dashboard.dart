import 'package:flutter/material.dart';
import '/backend/backend.dart';

/// Componente responsive che rileva la dimensione dello schermo:
/// - Larghezza < 800px: Mostra la UI mobile attuale.
/// - Larghezza >= 800px: Mostra la vista Dashboard per schermi grandi (PC).
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
  /// Se omesso, mostra la pagina predefinita [DashboardPlaceholderWidget].
  final Widget? desktop;

  /// Punto di interruzione in pixel (default: 800.0px)
  final double breakpoint;

  /// Riferimento Firebase del ristorante (stesso database)
  final DocumentReference? ristoranteRef;

  /// Dati utente/ristorante caricati da Firestore
  final UsersRecord? userDoc;

  /// Metodo statico di utilità per verificare se il contesto corrente è Desktop
  static bool isDesktop(BuildContext context, [double breakpoint = 800.0]) {
    return MediaQuery.sizeOf(context).width >= breakpoint;
  }

  /// Metodo statico di utilità per verificare se il contesto corrente è Mobile
  static bool isMobile(BuildContext context, [double breakpoint = 800.0]) {
    return MediaQuery.sizeOf(context).width < breakpoint;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= breakpoint) {
          return desktop ??
              DashboardPlaceholderWidget(
                ristoranteRef: ristoranteRef,
                userDoc: userDoc,
              );
        }
        return mobile;
      },
    );
  }
}

/// Pagina segnaposto per schermi grandi (PC)
class DashboardPlaceholderWidget extends StatelessWidget {
  const DashboardPlaceholderWidget({
    super.key,
    this.ristoranteRef,
    this.userDoc,
  });

  final DocumentReference? ristoranteRef;
  final UsersRecord? userDoc;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final nomeRistorante = userDoc?.displayName.isNotEmpty == true
        ? userDoc!.displayName
        : 'Il tuo Ristorante';

    return Scaffold(
      backgroundColor: isDark ? colorScheme.surface : Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // Header superiore pulito
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
                decoration: BoxDecoration(
                  color: isDark ? colorScheme.surface : Colors.white,
                  border: Border(
                    bottom: BorderSide(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                      width: 1.0,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 38.0,
                      height: 38.0,
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.dashboard_rounded,
                        color: colorScheme.primary,
                        size: 22.0,
                      ),
                    ),
                    const SizedBox(width: 14.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'ProntoMenu Dashboard',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface,
                            letterSpacing: -0.3,
                          ),
                        ),
                        Text(
                          nomeRistorante,
                          style: TextStyle(
                            fontSize: 12.5,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20.0),
                        border: Border.all(
                          color: colorScheme.primary.withValues(alpha: 0.3),
                          width: 1.0,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.cloud_done_rounded,
                            size: 15.0,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 6.0),
                          Text(
                            'Firebase Connesso',
                            style: TextStyle(
                              fontSize: 12.0,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Contenuto centrale con 'Dashboard in costruzione'
            Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 580.0),
                padding: const EdgeInsets.all(40.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 90.0,
                      height: 90.0,
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
                        Icons.desktop_windows_rounded,
                        size: 44.0,
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
                        'VISTA PC / DESKTOP (>= 800px)',
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
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12.0),
                    Text(
                      'Stiamo predisponendo la nuova interfaccia estesa per computer desktop. Tutti i dati visualizzati qui utilizzeranno lo stesso identico database Firebase del tuo menu e della tua app mobile.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15.0,
                        height: 1.5,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
