import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'impostazioni_notifiche_model.dart';
export 'impostazioni_notifiche_model.dart';

/// Attiva o disattiva le notifiche, ma solo come app iOS e android
class ImpostazioniNotificheWidget extends StatefulWidget {
  const ImpostazioniNotificheWidget({super.key});

  static String routeName = 'ImpostazioniNotifiche';
  static String routePath = '/impostazioniNotifiche';

  @override
  State<ImpostazioniNotificheWidget> createState() =>
      _ImpostazioniNotificheWidgetState();
}

class _ImpostazioniNotificheWidgetState
    extends State<ImpostazioniNotificheWidget> {
  late ImpostazioniNotificheModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ImpostazioniNotificheModel());

    _model.switchOrdiniValue =
        valueOrDefault<bool>(currentUserDocument?.notificheOrdini, false);
    _model.switchPromozioniValue =
        valueOrDefault<bool>(currentUserDocument?.notifichePromo, false);
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
        appBar: AppBar(
          backgroundColor: theme.appBarTheme.backgroundColor ?? theme.cardColor,
          automaticallyImplyLeading: false,
          leading: FlutterFlowIconButton(
            borderColor: Colors.transparent,
            borderRadius: 24.0,
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
          title: Text(
            'Notifiche',
            style: theme.appBarTheme.titleTextStyle ??
                theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 22.0,
                ),
          ),
          actions: const [],
          centerTitle: true,
          elevation: theme.appBarTheme.elevation ?? 2.0,
        ),
        body: SafeArea(
          top: true,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Nuovi Ordini',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0,
                          ),
                        ),
                        Text(
                          'Ricevi un avviso quando un cliente ordina',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.hintColor,
                          ),
                        ),
                      ],
                    ),
                    AuthUserStreamWidget(
                      builder: (context) => Switch.adaptive(
                        value: _model.switchOrdiniValue!,
                        onChanged: (newValue) async {
                          safeSetState(
                              () => _model.switchOrdiniValue = newValue);
                          if (newValue) {
                            await currentUserReference!
                                .update(createUsersRecordData(
                              notificheOrdini: true,
                            ));
                          } else {
                            await currentUserReference!
                                .update(createUsersRecordData(
                              notificheOrdini: false,
                            ));
                          }
                        },
                        activeThumbColor: theme.colorScheme.primary,
                        activeTrackColor: theme.colorScheme.primary.withValues(alpha: 0.38),
                        inactiveTrackColor: theme.dividerColor,
                        inactiveThumbColor: theme.cardColor,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 0.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Promozioni e Novità',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0,
                            ),
                          ),
                          Text(
                            'Ricevi un avviso quando sono disponibili\npromozioni o novità',
                            maxLines: 2,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.hintColor,
                            ),
                          ),
                        ],
                      ),
                      AuthUserStreamWidget(
                        builder: (context) => Switch.adaptive(
                          value: _model.switchPromozioniValue!,
                          onChanged: (newValue) async {
                            safeSetState(
                                () => _model.switchPromozioniValue = newValue);
                            if (newValue) {
                              await currentUserReference!
                                  .update(createUsersRecordData(
                                notifichePromo: true,
                              ));
                            } else {
                              await currentUserReference!
                                  .update(createUsersRecordData(
                                notifichePromo: false,
                              ));
                            }
                          },
                          activeThumbColor: theme.colorScheme.primary,
                          activeTrackColor: theme.colorScheme.primary.withValues(alpha: 0.38),
                          inactiveTrackColor: theme.dividerColor,
                          inactiveThumbColor: theme.cardColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
