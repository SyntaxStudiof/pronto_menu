import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'privacy_policy_model.dart';
export 'privacy_policy_model.dart';

class PrivacyPolicyWidget extends StatefulWidget {
  const PrivacyPolicyWidget({super.key});

  static String routeName = 'PrivacyPolicy';
  static String routePath = '/privacyPolicy';

  @override
  State<PrivacyPolicyWidget> createState() => _PrivacyPolicyWidgetState();
}

class _PrivacyPolicyWidgetState extends State<PrivacyPolicyWidget> {
  late PrivacyPolicyModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PrivacyPolicyModel());

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

    final titleStyle = theme.textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.bold,
    );
    final bodyRegular = theme.textTheme.bodyMedium?.copyWith(
      fontWeight: FontWeight.w500,
    );
    final bodyBold = theme.textTheme.bodyMedium?.copyWith(
      fontWeight: FontWeight.bold,
    );

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: theme.appBarTheme.backgroundColor ?? theme.cardColor,
          automaticallyImplyLeading: false,
          leading: FlutterFlowIconButton(
            borderColor: Colors.transparent,
            borderRadius: 30.0,
            borderWidth: 1.0,
            buttonSize: 40.0,
            icon: Icon(
              Icons.arrow_back_rounded,
              color: theme.appBarTheme.foregroundColor ?? theme.iconTheme.color,
              size: 24.0,
            ),
            onPressed: () async {
              context.safePop();
            },
          ),
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
                  Icons.shield_rounded,
                  color: theme.colorScheme.primary,
                  size: 20.0,
                ),
              ),
              const SizedBox(width: 10.0),
              Text(
                'Informativa privacy',
                style: theme.appBarTheme.titleTextStyle ??
                    theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 19.0,
                      letterSpacing: -0.4,
                    ),
              ),
            ],
          ),
          actions: const [
            SizedBox(width: 48.0),
          ],
          centerTitle: true,
          elevation: 0.0,
        ),
        body: SafeArea(
          top: true,
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(20.0, 20.0, 20.0, 40.0),
            child: SingleChildScrollView(
              controller: _model.columnController,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Informativa sulla Privacy di ProntoMenu',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 0.0),
                    child: RichText(
                      textScaler: MediaQuery.of(context).textScaler,
                      text: TextSpan(
                        style: theme.textTheme.bodyMedium,
                        children: [
                          TextSpan(
                            text: 'Ultimo aggiornamento: ',
                            style: bodyBold,
                          ),
                          TextSpan(
                            text: '24 Marzo 2026',
                            style: bodyRegular,
                          )
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 0.0),
                    child: RichText(
                      textScaler: MediaQuery.of(context).textScaler,
                      text: TextSpan(
                        style: theme.textTheme.bodyMedium,
                        children: [
                          TextSpan(
                            text:
                                'La presente Informativa sulla Privacy descrive le modalità con cui ',
                            style: bodyRegular,
                          ),
                          TextSpan(
                            text: 'ProntoMenu ',
                            style: bodyBold,
                          ),
                          TextSpan(
                            text:
                                'raccoglie, utilizza e protegge i dati personali degli utenti  che utilizzano l\'applicazione.',
                            style: bodyRegular,
                          )
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 0.0),
                    child: Text(
                      '1. Titolare del Trattamento dei Dati',
                      textAlign: TextAlign.center,
                      style: titleStyle,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(0.0, 5.0, 0.0, 0.0),
                    child: RichText(
                      textScaler: MediaQuery.of(context).textScaler,
                      text: TextSpan(
                        style: theme.textTheme.bodyMedium,
                        children: [
                          TextSpan(
                            text: 'Il Titolare del trattamento è: ',
                            style: bodyRegular,
                          ),
                          TextSpan(
                            text: 'ProntoMenu\n',
                            style: bodyBold,
                          ),
                          TextSpan(
                            text: 'Contatto email:',
                            style: bodyRegular,
                          ),
                          TextSpan(
                            text: ' prontomenu.f@gmail.com',
                            style: bodyBold,
                          )
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 0.0),
                    child: Text(
                      '2. Tipologia di Dati Raccolti',
                      textAlign: TextAlign.center,
                      style: titleStyle,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(0.0, 5.0, 0.0, 0.0),
                    child: RichText(
                      textScaler: MediaQuery.of(context).textScaler,
                      text: TextSpan(
                        style: theme.textTheme.bodyMedium,
                        children: [
                          TextSpan(
                            text:
                                'L\'applicazione raccoglie i seguenti dati necessari al funzionamento del servizio:\n',
                            style: bodyRegular,
                          ),
                          TextSpan(
                            text: '- Dati di Registrazione: ',
                            style: bodyBold,
                          ),
                          TextSpan(
                            text:
                                'Indirizzo email e password (gestiti tramite Google Firebase Auth)\n',
                            style: bodyRegular,
                          ),
                          TextSpan(
                            text: '- Dati del Profilo: ',
                            style: bodyBold,
                          ),
                          TextSpan(
                            text: 'Come nome, cognome e nome ristorante\n',
                            style: bodyRegular,
                          ),
                          TextSpan(
                            text: '- Dati di Utilizzo: ',
                            style: bodyBold,
                          ),
                          TextSpan(
                            text:
                                'Informazioni tecniche sulla navigazione nell\'app per fini di sicurezza e ottimizzazione.',
                            style: bodyRegular,
                          )
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 0.0),
                    child: Text(
                      '3. Finalità del Trattamento',
                      textAlign: TextAlign.center,
                      style: titleStyle,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(0.0, 5.0, 0.0, 0.0),
                    child: Text(
                      'I dati vengono raccolti per le seguenti finalità:\n- Consentire la creazione e la gestione dell\'account.\n- Permettere la configurazione e la visualizzazione del menu digitale.\n- Fornire assistenza tecnica e comunicazioni relative al servizio.\n- Garantire la sicurezza degli accessi (tramite la procedura di cambio password verificata).',
                      textAlign: TextAlign.center,
                      style: bodyRegular,
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 0.0),
                    child: Text(
                      '4. Base Giuridica del Trattamento',
                      textAlign: TextAlign.center,
                      style: titleStyle,
                    ),
                  ),
                  Text(
                    'Trattiamo i tuoi dati solo se:\n- È necessario per l\'esecuzione del servizio (fornitura della piattaforma ProntoMenu).\n- Hai prestato il tuo consenso per finalità specifiche.\n- Esiste un legittimo interesse legato alla sicurezza e al miglioramento dell\'app.',
                    textAlign: TextAlign.center,
                    style: bodyRegular,
                  ),
                  Padding(
                    padding:
                        const EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 0.0),
                    child: Text(
                      '5. Servizi di Terze Parti',
                      textAlign: TextAlign.center,
                      style: titleStyle,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(0.0, 5.0, 0.0, 0.0),
                    child: Text(
                      'Per il corretto funzionamento, l\'app si avvale di:',
                      textAlign: TextAlign.center,
                      style: bodyRegular,
                    ),
                  ),
                  RichText(
                    textScaler: MediaQuery.of(context).textScaler,
                    text: TextSpan(
                      style: theme.textTheme.bodyMedium,
                      children: [
                        TextSpan(
                          text: '- Google Firebase: ',
                          style: bodyBold,
                        ),
                        TextSpan(
                          text:
                              'Per l\'autenticazione sicura e l\'archiviazione dei dati nel database. I dati sono conservati su server protetti conformi agli standard internazionali di sicurezza.',
                          style: bodyRegular,
                        )
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Padding(
                    padding:
                        const EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 0.0),
                    child: Text(
                      '6. Diritti dell\'Utente',
                      textAlign: TextAlign.center,
                      style: titleStyle,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(0.0, 5.0, 0.0, 0.0),
                    child: Text(
                      'In conformità al GDPR (Regolamento UE 2016/679), hai il diritto di:\n- Accedere ai tuoi dati personali in ogni momento.\n- Chiedere la rettifica o la cancellazione degli stessi.\n- Opporsi al trattamento o chiederne la limitazione.\n- Esercitare il diritto alla portabilità dei dati.',
                      textAlign: TextAlign.center,
                      style: bodyRegular,
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsetsDirectional.fromSTEB(0.0, 10.0, 0.0, 0.0),
                    child: RichText(
                      textScaler: MediaQuery.of(context).textScaler,
                      text: TextSpan(
                        style: theme.textTheme.bodyMedium,
                        children: [
                          TextSpan(
                            text:
                                'Puoi esercitare questi diritti scrivendo a: ',
                            style: bodyRegular,
                          ),
                          TextSpan(
                            text: 'prontomenu.f@gmail.com',
                            style: bodyBold,
                          )
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 0.0),
                    child: Text(
                      '7. Sicurezza dei Dati',
                      textAlign: TextAlign.center,
                      style: titleStyle,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(0.0, 5.0, 0.0, 0.0),
                    child: Text(
                      'Adottiamo misure di sicurezza tecniche (come la crittografia e procedure di autenticazione sicura) per proteggere i tuoi dati da accessi non autorizzati o perdite accidentali.',
                      textAlign: TextAlign.center,
                      style: bodyRegular,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
