import '/auth/firebase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'abbonamento_model.dart';
export 'abbonamento_model.dart';

class AbbonamentoWidget extends StatefulWidget {
  const AbbonamentoWidget({super.key});

  static String routeName = 'Abbonamento';
  static String routePath = '/abbonamento';

  @override
  State<AbbonamentoWidget> createState() => _AbbonamentoWidgetState();
}

class _AbbonamentoWidgetState extends State<AbbonamentoWidget> {
  late AbbonamentoModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AbbonamentoModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();
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
            child: SingleChildScrollView(
              controller: _model.columnController,
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 28.0),
              child: Center(
                child: Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxWidth: 520.0),
                  padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 36.0),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(24.0),
                    border: Border.all(
                      color: theme.dividerColor.withValues(alpha: 0.5),
                      width: 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 24.0,
                        color: Colors.black.withValues(alpha: 0.06),
                        offset: const Offset(0.0, 8.0),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 6.0),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star_rounded,
                              color: theme.colorScheme.primary,
                              size: 16.0,
                            ),
                            const SizedBox(width: 6.0),
                            Text(
                              'PIANO PRO RISTORATORE',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontSize: 12.0,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      Container(
                        width: 110.0,
                        height: 110.0,
                        decoration: BoxDecoration(
                          color: theme.scaffoldBackgroundColor,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: theme.dividerColor,
                            width: 2.0,
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Image.network(
                          'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/pronto-menu-f0och1/assets/i4ccmvv80eni/IMG_8006.png',
                          width: 110.0,
                          height: 110.0,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Image.asset(
                            'assets/images/IMG_8006.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18.0),
                      Text(
                        'Sblocca il potenziale del tuo locale',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontSize: 25.0,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.6,
                        ),
                      ),
                      const SizedBox(height: 6.0),
                      Text(
                        'Gestisci ordini, tavoli e menu senza intermediari',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.hintColor,
                          fontSize: 14.5,
                        ),
                      ),
                      const SizedBox(height: 24.0),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 16.0),
                        decoration: BoxDecoration(
                          color: theme.scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(18.0),
                          border: Border.all(
                            color: theme.dividerColor.withValues(alpha: 0.5),
                            width: 1.0,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildFeatureRow(
                              context,
                              'Ricezione ordini in tempo reale',
                            ),
                            _buildFeatureRow(
                              context,
                              'Gestione separata tra cucina e cassa',
                            ),
                            _buildFeatureRow(
                              context,
                              'Gestione illimitata del menu',
                            ),
                            _buildFeatureRow(
                              context,
                              'Creazione di categorie e sottocategorie',
                            ),
                            _buildFeatureRow(
                              context,
                              'Zero commissioni sul venduto',
                              isLast: true,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22.0),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(16.0),
                          border: Border.all(
                            color: theme.colorScheme.primary.withValues(alpha: 0.2),
                            width: 1.2,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!valueOrDefault<bool>(
                                currentUserDocument?.haUsatoProva, false))
                              AuthUserStreamWidget(
                                builder: (context) => Padding(
                                  padding: const EdgeInsets.only(bottom: 4.0),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 3.0),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF2D6A4F),
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    child: const Text(
                                      'PROVA GRATUITA 7 GIORNI',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.6,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            const SizedBox(height: 6.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  '19,90€',
                                  style: theme.textTheme.headlineMedium?.copyWith(
                                    fontSize: 34.0,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -1.0,
                                  ),
                                ),
                                const SizedBox(width: 4.0),
                                Text(
                                  '/ mese',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: theme.hintColor,
                                    fontSize: 17.0,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4.0),
                            Wrap(
                              alignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Icon(
                                  Icons.lock_outline_rounded,
                                  size: 13.0,
                                  color: theme.hintColor,
                                ),
                                const SizedBox(width: 4.0),
                                Text(
                                  'Nessun vincolo, disdici quando vuoi con un click',
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.hintColor,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      FFButtonWidget(
                        onPressed: () async {
                          if (valueOrDefault<bool>(
                              currentUserDocument?.haUsatoProva, false)) {
                            await launchURL(
                                'https://buy.stripe.com/test_9B69AM82w238ddbcJEfQI01?client_reference_id=$currentUserUid');
                          } else {
                            await launchURL(
                                'https://buy.stripe.com/test_fZu3cofuYbDIgpneRMfQI00?client_reference_id=$currentUserUid');
                          }
                        },
                        text: 'Inizia la prova gratuita ora',
                        options: FFButtonOptions(
                          width: double.infinity,
                          height: 52.0,
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              24.0, 0.0, 24.0, 0.0),
                          iconPadding: const EdgeInsetsDirectional.fromSTEB(
                              0.0, 0.0, 0.0, 0.0),
                          color: theme.colorScheme.primary,
                          textStyle: theme.textTheme.titleSmall?.copyWith(
                            color: theme.colorScheme.onPrimary,
                            fontSize: 16.5,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.2,
                          ),
                          elevation: 0.0,
                          borderRadius: BorderRadius.circular(14.0),
                        ),
                      ),
                      const SizedBox(height: 12.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.verified_user_outlined,
                            size: 14.0,
                            color: theme.hintColor,
                          ),
                          const SizedBox(width: 5.0),
                          Text(
                            'Pagamenti sicuri e crittografati con Stripe',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.hintColor,
                              fontSize: 12.0,
                            ),
                          ),
                        ],
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

  Widget _buildFeatureRow(BuildContext context, String text, {bool isLast = false}) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, isLast ? 0.0 : 12.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 22.0,
            height: 22.0,
            decoration: const BoxDecoration(
              color: Color(0xFFE8F5E9),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.check_rounded,
              color: Color(0xFF2E7D32),
              size: 15.0,
            ),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 14.5,
                fontWeight: FontWeight.w500,
                letterSpacing: -0.1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
