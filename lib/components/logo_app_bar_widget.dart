import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'logo_app_bar_model.dart';
export 'logo_app_bar_model.dart';

class LogoAppBarWidget extends StatefulWidget {
  const LogoAppBarWidget({super.key});

  @override
  State<LogoAppBarWidget> createState() => _LogoAppBarWidgetState();
}

class _LogoAppBarWidgetState extends State<LogoAppBarWidget> {
  late LogoAppBarModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => LogoAppBarModel());

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

    return RichText(
      textScaler: MediaQuery.of(context).textScaler,
      text: TextSpan(
        style: theme.textTheme.displayMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
        children: [
          const TextSpan(
            text: 'Pronto',
          ),
          TextSpan(
            text: 'Menu',
            style: TextStyle(
              color: theme.colorScheme.primary,
            ),
          )
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}
