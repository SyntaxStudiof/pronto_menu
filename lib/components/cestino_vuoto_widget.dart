import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 420.0),
      margin: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
      padding: const EdgeInsets.all(32.0),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24.0),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.15),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 16.0,
            color: Colors.black.withValues(alpha: 0.04),
            offset: const Offset(0.0, 4.0),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72.0,
            height: 72.0,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: FaIcon(
              FontAwesomeIcons.solidSmileBeam,
              color: theme.colorScheme.primary,
              size: 36.0,
            ),
          ),
          const SizedBox(height: 20.0),
          Text(
            'Il cestino è vuoto',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            'Non hai nessun piatto eliminato.\nI piatti cancellati rimarranno qui per 7 giorni prima dell\'eliminazione definitiva.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodySmall?.color,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
