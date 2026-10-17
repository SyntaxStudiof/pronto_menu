import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/cliente/hub_cliente/hub_cliente_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';

/// Vista Desktop per l'Anteprima del Menu Cliente in formato smartphone
class DesktopClientPreviewView extends StatelessWidget {
  const DesktopClientPreviewView({
    super.key,
    required this.ristoranteRef,
    this.onNavigateToQR,
  });

  final DocumentReference? ristoranteRef;
  final VoidCallback? onNavigateToQR;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final docRef = ristoranteRef ?? currentUserReference;
    final uid = docRef?.id ?? currentUserUid;
    final menuWebUrl = 'https://prontomenu-6d485.web.app/loaderMenu?ristoranteRef=$uid';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ═════════════════════════════════════════════════════════════════
        // PANNELLO LATERALE INFO & LINK (~380px)
        // ═════════════════════════════════════════════════════════════════
        Container(
          width: 380.0,
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
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Sezione
                Row(
                  children: [
                    Container(
                      width: 44.0,
                      height: 44.0,
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.visibility_rounded,
                        color: Color(0xFF10B981),
                        size: 24.0,
                      ),
                    ),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Anteprima Cliente',
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.3,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                            ),
                          ),
                          Text(
                            'Esperienza dal vivo su smartphone',
                            style: TextStyle(
                              fontSize: 12.0,
                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24.0),

                // Spiegazione
                Container(
                  padding: const EdgeInsets.all(14.0),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(
                      color: colorScheme.primary.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.touch_app_rounded, color: colorScheme.primary, size: 20.0),
                      const SizedBox(width: 10.0),
                      Expanded(
                        child: Text(
                          'Il simulatore a destra è completamente interattivo! Puoi toccare i piatti, simulare ordini, visualizzare allergeni e testare il menu prima che i clienti lo vedano.',
                          style: TextStyle(
                            fontSize: 12.5,
                            height: 1.45,
                            color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24.0),

                // Box Link Diretto
                Text(
                  'LINK PUBBLICO DEL MENU',
                  style: TextStyle(
                    fontSize: 11.0,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                  ),
                ),
                const SizedBox(height: 8.0),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(
                      color: isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFCBD5E1),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          menuWebUrl,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12.0,
                            fontFamily: 'monospace',
                            color: isDark ? const Color(0xFF93C5FD) : const Color(0xFF1D4ED8),
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Copia Link',
                        icon: const Icon(Icons.copy_rounded, size: 18.0),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: menuWebUrl));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Link del menu copiato negli appunti!'),
                              backgroundColor: Color(0xFF10B981),
                              duration: Duration(seconds: 2),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14.0),

                // Pulsante Apri in Nuova Scheda
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => launchURL(menuWebUrl),
                    icon: const Icon(Icons.open_in_new_rounded, size: 16.0),
                    label: const Text('Apri in Nuova Scheda Browser'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                    ),
                  ),
                ),

                const SizedBox(height: 28.0),

                // Card QR Code rapido
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.04)
                        : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14.0),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 8.0,
                            ),
                          ],
                        ),
                        child: QrImageView(
                          data: menuWebUrl,
                          version: QrVersions.auto,
                          size: 140.0,
                          eyeStyle: const QrEyeStyle(
                            eyeShape: QrEyeShape.square,
                            color: Colors.black,
                          ),
                          dataModuleStyle: const QrDataModuleStyle(
                            dataModuleShape: QrDataModuleShape.square,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12.0),
                      Text(
                        'QR Code Diretto al Tavolo',
                        style: TextStyle(
                          fontSize: 13.0,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        'Scansiona con il tuo smartphone per testare dal vivo',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11.5,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        ),
                      ),
                      if (onNavigateToQR != null) ...[
                        const SizedBox(height: 12.0),
                        OutlinedButton.icon(
                          onPressed: onNavigateToQR,
                          icon: const Icon(Icons.qr_code_2_rounded, size: 16.0),
                          label: const Text('Configura & Stampa QR', style: TextStyle(fontSize: 12.0)),
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // ═════════════════════════════════════════════════════════════════
        // MOCKUP SMARTPHONE INTERATTIVO (Al centro)
        // ═════════════════════════════════════════════════════════════════
        Expanded(
          child: Container(
            color: isDark ? const Color(0xFF0B132B) : const Color(0xFFE2E8F0).withValues(alpha: 0.6),
            padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 24.0),
            child: Center(
              child: Container(
                width: 390.0,
                height: 800.0,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(44.0),
                  border: Border.all(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFF0F172A),
                    width: 9.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.6 : 0.25),
                      blurRadius: 36.0,
                      spreadRadius: 4.0,
                      offset: const Offset(0, 14),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(35.0),
                  child: Stack(
                    children: [
                      // Pagina Hub Cliente
                      Positioned.fill(
                        child: HubClienteWidget(
                          ristoranteRef: docRef,
                          isAnteprima: true,
                        ),
                      ),

                      // Dynamic Island / Notch Superiore dello Smartphone
                      Positioned(
                        top: 8.0,
                        left: 0.0,
                        right: 0.0,
                        child: Center(
                          child: Container(
                            width: 100.0,
                            height: 24.0,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(14.0),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 9.0,
                                  height: 9.0,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF1E293B),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8.0),
                                Container(
                                  width: 6.0,
                                  height: 6.0,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF0EA5E9),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Home indicator pillola inferiore dello Smartphone
                      Positioned(
                        bottom: 6.0,
                        left: 0.0,
                        right: 0.0,
                        child: Center(
                          child: Container(
                            width: 120.0,
                            height: 4.0,
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(3.0),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
