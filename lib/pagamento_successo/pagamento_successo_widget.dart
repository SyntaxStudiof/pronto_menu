import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'pagamento_successo_model.dart';
export 'pagamento_successo_model.dart';

class PagamentoSuccessoWidget extends StatefulWidget {
  const PagamentoSuccessoWidget({super.key});

  static String routeName = 'PagamentoSuccesso';
  static String routePath = '/pagamentoSuccesso';

  @override
  State<PagamentoSuccessoWidget> createState() =>
      _PagamentoSuccessoWidgetState();
}

class _PagamentoSuccessoWidgetState extends State<PagamentoSuccessoWidget> {
  late PagamentoSuccessoModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PagamentoSuccessoModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      await currentUserReference!.update(createUsersRecordData(
        isPremium: true,
        haUsatoProva: true,
      ));

      if (mounted) {
        context.pushNamed(
          HomeRistoratoreWidget.routeName,
          queryParameters: {
            'ristoranteRef': serializeParam(
              currentUserReference,
              ParamType.DocumentReference,
            ),
          }.withoutNulls,
        );
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          top: true,
          child: Align(
            alignment: const AlignmentDirectional(0.0, 0.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Pagamento andato a buon fine!\nStiamo sbloccando il tuo menu...',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                CircularPercentIndicator(
                  percent: 1.0,
                  radius: 60.0,
                  lineWidth: 12.0,
                  animation: true,
                  animateFromLastPercent: true,
                  progressColor: theme.colorScheme.primary,
                  backgroundColor: theme.dividerColor,
                  center: Text(
                    '100%',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ].divide(const SizedBox(height: 20.0)),
            ),
          ),
        ),
      ),
    );
  }
}
