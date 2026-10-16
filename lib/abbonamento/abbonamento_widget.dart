import '/auth/firebase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
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
    final canPop = Navigator.of(context).canPop();
    final haUsatoProva = valueOrDefault<bool>(currentUserDocument?.haUsatoProva, false);

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          elevation: 0.0,
          leading: canPop
              ? FlutterFlowIconButton(
                  borderColor: Colors.transparent,
                  borderRadius: 24.0,
                  borderWidth: 1.0,
                  buttonSize: 40.0,
                  icon: Icon(
                    Icons.arrow_back_rounded,
                    color: theme.colorScheme.onSurface,
                    size: 24.0,
                  ),
                  onPressed: () async {
                    context.safePop();
                  },
                )
              : null,
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
                  Icons.workspace_premium_rounded,
                  color: theme.colorScheme.primary,
                  size: 20.0,
                ),
              ),
              const SizedBox(width: 10.0),
              Text(
                'Piano ProntoMenu',
                style: theme.appBarTheme.titleTextStyle ??
                    theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 19.0,
                      letterSpacing: -0.4,
                      color: theme.colorScheme.onSurface,
                    ),
              ),
            ],
          ),
          actions: [
            if (canPop) const SizedBox(width: 48.0),
          ],
          centerTitle: true,
        ),
        body: SafeArea(
          top: true,
          child: Align(
            alignment: const AlignmentDirectional(0.0, 0.0),
            child: SingleChildScrollView(
              controller: _model.columnController,
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
              child: Center(
                child: Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxWidth: 560.0),
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 28.0),
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
                      // Badge Piano
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
                      const SizedBox(height: 18.0),
                      // Logo
                      Container(
                        width: 96.0,
                        height: 96.0,
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
                          width: 96.0,
                          height: 96.0,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Image.asset(
                            'assets/images/IMG_8006.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      Text(
                        'Sblocca il potenziale del tuo locale',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.6,
                        ),
                      ),
                      const SizedBox(height: 6.0),
                      Text(
                        'Gestisci ordini, comande, intrattenimento ai tavoli e menu senza intermediari',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.hintColor,
                          fontSize: 14.0,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 22.0),

                      // Box Servizi Inclusi
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18.0),
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.check_circle_outline_rounded,
                                  color: theme.colorScheme.primary,
                                  size: 18.0,
                                ),
                                const SizedBox(width: 8.0),
                                Text(
                                  'TUTTI I SERVIZI INCLUSI',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.6,
                                    fontSize: 12.0,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14.0),
                            _buildFeatureItem(
                              context,
                              icon: Icons.receipt_long_rounded,
                              iconColor: const Color(0xFFE65100),
                              title: 'Ricezione ordini in tempo reale',
                              subtitle: 'Notifiche immediate e comande istantanee dai tavoli dei clienti',
                            ),
                            _buildFeatureItem(
                              context,
                              icon: Icons.soup_kitchen_rounded,
                              iconColor: const Color(0xFF00897B),
                              title: 'Schermi dedicati Cucina e Cassa',
                              subtitle: 'Avanzamento comande (In preparazione, Pronto, Servito) e conti',
                            ),
                            _buildFeatureItem(
                              context,
                              icon: Icons.qr_code_2_rounded,
                              iconColor: const Color(0xFF1E88E5),
                              title: 'Menu Digitale QR Code interattivo',
                              subtitle: 'Consultazione istantanea senza app, con QR dedicato per ogni tavolo',
                            ),
                            _buildFeatureItem(
                              context,
                              icon: Icons.restaurant_menu_rounded,
                              iconColor: const Color(0xFFD81B60),
                              title: 'Catalogo illimitato & Allergeni',
                              subtitle: 'Piatti, varianti, ingredienti completi, foto HD e filtri allergeni',
                            ),
                            _buildFeatureItem(
                              context,
                              icon: Icons.format_list_bulleted_rounded,
                              iconColor: const Color(0xFF3949AB),
                              title: 'Categorie & Sottocategorie personalizzabili',
                              subtitle: 'Organizzazione flessibile del menu con ordinamento rapido',
                            ),
                            _buildFeatureItem(
                              context,
                              icon: Icons.music_note_rounded,
                              iconColor: const Color(0xFF8E24AA),
                              title: 'Jukebox Digitale per i clienti',
                              subtitle: 'I commensali richiedono e votano i brani musicali dal tavolo',
                            ),
                            _buildFeatureItem(
                              context,
                              icon: Icons.sports_esports_rounded,
                              iconColor: const Color(0xFF5E35B1),
                              title: 'Giochi ai tavoli (Tris & Quiz del Gusto)',
                              subtitle: 'Intrattenimento interattivo al tavolo per azzerare i tempi di attesa',
                            ),
                            _buildFeatureItem(
                              context,
                              icon: Icons.palette_rounded,
                              iconColor: const Color(0xFFF4511E),
                              title: 'Personalizzazione completa del Brand',
                              subtitle: 'Logo, copertina, colori aziendali, contatti e orari del tuo locale',
                            ),
                            _buildFeatureItem(
                              context,
                              icon: Icons.bar_chart_rounded,
                              iconColor: const Color(0xFF0288D1),
                              title: 'Statistiche & Analisi ordini',
                              subtitle: 'Monitoraggio vendite, piatti più popolari e performance del locale',
                            ),
                            _buildFeatureItem(
                              context,
                              icon: Icons.delete_sweep_rounded,
                              iconColor: const Color(0xFF546E7A),
                              title: 'Cestino di sicurezza e recupero',
                              subtitle: 'Ripristino immediato di piatti o categorie eliminate per errore',
                            ),
                            _buildFeatureItem(
                              context,
                              icon: Icons.percent_rounded,
                              iconColor: const Color(0xFF2E7D32),
                              title: 'Zero commissioni sul venduto',
                              subtitle: '0% trattenute, l\'intero incasso dei tuoi ordini rimane al 100% tuo',
                            ),
                            _buildFeatureItem(
                              context,
                              icon: Icons.support_agent_rounded,
                              iconColor: const Color(0xFF00ACC1),
                              title: 'Assistenza & Supporto dedicato',
                              subtitle: 'Ticket prioritari in-app con supporto rapido e aggiornamenti inclusi',
                              isLast: true,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20.0),

                      // Box Prezzo & Periodo Prova
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
                            if (!haUsatoProva)
                              AuthUserStreamWidget(
                                builder: (context) => Padding(
                                  padding: const EdgeInsets.only(bottom: 6.0),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
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
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20.0),

                      // Bottone CTA Stripe
                      FFButtonWidget(
                        onPressed: () async {
                          if (haUsatoProva) {
                            await launchURL(
                                'https://buy.stripe.com/test_9B69AM82w238ddbcJEfQI01?client_reference_id=$currentUserUid');
                          } else {
                            await launchURL(
                                'https://buy.stripe.com/test_fZu3cofuYbDIgpneRMfQI00?client_reference_id=$currentUserUid');
                          }
                        },
                        text: haUsatoProva
                            ? 'Abbonati ora a 19,90€/mese'
                            : 'Inizia la prova gratuita ora (7 giorni)',
                        options: FFButtonOptions(
                          width: double.infinity,
                          height: 52.0,
                          padding: const EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
                          iconPadding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                          color: theme.colorScheme.primary,
                          textStyle: theme.textTheme.titleSmall?.copyWith(
                            color: theme.colorScheme.onPrimary,
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.2,
                          ),
                          elevation: 0.0,
                          borderRadius: BorderRadius.circular(14.0),
                        ),
                      ),
                      const SizedBox(height: 12.0),

                      // Garanzia Stripe
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

  Widget _buildFeatureItem(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    bool isLast = false,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, isLast ? 0.0 : 13.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36.0,
            height: 36.0,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10.0),
            ),
            alignment: Alignment.center,
            child: Icon(
              icon,
              color: iconColor,
              size: 19.0,
            ),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 2.0),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.hintColor,
                    fontSize: 12.0,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8.0),
          Padding(
            padding: const EdgeInsets.only(top: 2.0),
            child: Container(
              width: 20.0,
              height: 20.0,
              decoration: const BoxDecoration(
                color: Color(0xFFE8F5E9),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.check_rounded,
                color: Color(0xFF2E7D32),
                size: 14.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
