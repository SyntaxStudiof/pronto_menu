import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'cestino_vuoto_model.dart';
export 'cestino_vuoto_model.dart';

class CestinoVuotoWidget extends StatefulWidget {
  const CestinoVuotoWidget({super.key});

  @override
  State<CestinoVuotoWidget> createState() => _CestinoVuotoWidgetState();
}

class _CestinoVuotoWidgetState extends State<CestinoVuotoWidget> {
  late CestinoVuotoModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CestinoVuotoModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = colorScheme.primary;

    return Center(
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 480.0),
        margin: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
        padding: const EdgeInsets.all(32.0),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(24.0),
          border: Border.all(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              blurRadius: 24.0,
              color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.06),
              offset: const Offset(0.0, 8.0),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icona Vettoriale Illustrata (Doppio Cerchio con Bagliore)
            Container(
              width: 84.0,
              height: 84.0,
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.10),
                shape: BoxShape.circle,
                border: Border.all(
                  color: primaryColor.withValues(alpha: 0.25),
                  width: 2.0,
                ),
              ),
              alignment: Alignment.center,
              child: Container(
                width: 62.0,
                height: 62.0,
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.delete_sweep_rounded,
                  color: primaryColor,
                  size: 34.0,
                ),
              ),
            ),
            const SizedBox(height: 18.0),

            // Badge di Stato
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.5),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20.0),
                border: Border.all(
                  color: primaryColor.withValues(alpha: 0.25),
                  width: 1.0,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle_outline_rounded,
                    size: 14.0,
                    color: primaryColor,
                  ),
                  const SizedBox(width: 6.0),
                  Text(
                    'TUTTO IN ORDINE',
                    style: TextStyle(
                      fontSize: 11.0,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.6,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14.0),

            // Titolo
            Text(
              'Il cestino è vuoto',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                letterSpacing: -0.4,
                fontSize: 22.0,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8.0),

            // Sottotitolo descrittivo
            Text(
              'Non hai nessun piatto eliminato di recente.\nTutti i piatti creati sono attualmente attivi nel menù.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                height: 1.45,
                fontSize: 13.0,
              ),
            ),
            const SizedBox(height: 24.0),

            // Box Informativo sulle Regole del Cestino
            Container(
              padding: const EdgeInsets.all(14.0),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14.0),
                border: Border.all(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                  width: 1.0,
                ),
              ),
              child: Column(
                children: [
                  _buildPolicyRow(
                    icon: Icons.restore_rounded,
                    iconColor: const Color(0xFF10B981),
                    title: 'Ripristino in 1 Click',
                    description: 'I piatti cancellati possono essere ripristinati in qualsiasi momento.',
                    isDark: isDark,
                  ),
                  const SizedBox(height: 10.0),
                  _buildPolicyRow(
                    icon: Icons.schedule_rounded,
                    iconColor: const Color(0xFFF59E0B),
                    title: 'Conservazione di 7 Giorni',
                    description: 'Hai una settimana di tempo prima della cancellazione permanente.',
                    isDark: isDark,
                  ),
                  const SizedBox(height: 10.0),
                  _buildPolicyRow(
                    icon: Icons.auto_delete_outlined,
                    iconColor: const Color(0xFF6366F1),
                    title: 'Pulizia Automatica',
                    description: 'I piatti scaduti vengono eliminati in automatico liberando spazio.',
                    isDark: isDark,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPolicyRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
    required bool isDark,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28.0,
          height: 28.0,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8.0),
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: 16.0, color: iconColor),
        ),
        const SizedBox(width: 10.0),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12.0,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 1.5),
              Text(
                description,
                style: TextStyle(
                  fontSize: 11.0,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
