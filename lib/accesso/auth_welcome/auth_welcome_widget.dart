import '/auth/firebase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/components/google_sign_in_button.dart';
import 'auth_welcome_model.dart';
export 'auth_welcome_model.dart';

/// Pagina di registrazione
class AuthWelcomeWidget extends StatefulWidget {
  const AuthWelcomeWidget({super.key});

  static String routeName = 'auth_welcome';
  static String routePath = '/authWelcome';

  @override
  State<AuthWelcomeWidget> createState() => _AuthWelcomeWidgetState();
}

class _AuthWelcomeWidgetState extends State<AuthWelcomeWidget> {
  late AuthWelcomeModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AuthWelcomeModel());

    _model.emailLoginTextController ??= TextEditingController();
    _model.emailLoginFocusNode ??= FocusNode();

    _model.passwordLoginTextController ??= TextEditingController();
    _model.passwordLoginFocusNode ??= FocusNode();

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
          child: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 20.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.asset(
                      'assets/images/IMG_8006.png',
                      width: 200.0,
                      height: 200.0,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 36.0),
                  child: RichText(
                    textScaler: MediaQuery.of(context).textScaler,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Pronto',
                          style: theme.textTheme.displayMedium,
                        ),
                        TextSpan(
                          text: 'Menu',
                          style: theme.textTheme.displayMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      ],
                      style: theme.textTheme.displayMedium,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Container(
                  width: 280.0,
                  child: TextFormField(
                    controller: _model.emailLoginTextController,
                    focusNode: _model.emailLoginFocusNode,
                    autofocus: false,
                    enabled: true,
                    obscureText: false,
                    decoration: InputDecoration(
                      isDense: true,
                      labelStyle: theme.textTheme.labelMedium,
                      hintText: 'Inserisci la tua email',
                      hintStyle: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.hintColor,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: theme.dividerColor,
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: theme.colorScheme.primary,
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: theme.colorScheme.error,
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: theme.colorScheme.error,
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      filled: true,
                      fillColor: theme.cardColor,
                    ),
                    style: theme.textTheme.bodyMedium,
                    keyboardType: TextInputType.emailAddress,
                    cursorColor: theme.colorScheme.primary,
                    enableInteractiveSelection: true,
                    validator: _model.emailLoginTextControllerValidator
                        .asValidator(context),
                  ),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0.0, 16.0, 0.0, 0.0),
                  child: Container(
                    width: 280.0,
                    child: TextFormField(
                      controller: _model.passwordLoginTextController,
                      focusNode: _model.passwordLoginFocusNode,
                      autofocus: false,
                      enabled: true,
                      obscureText: !_model.passwordLoginVisibility,
                      decoration: InputDecoration(
                        isDense: true,
                        labelStyle: theme.textTheme.labelMedium,
                        hintText: 'Inserisci la tua password',
                        hintStyle: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.hintColor,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: theme.dividerColor,
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: theme.colorScheme.primary,
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: theme.colorScheme.error,
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: theme.colorScheme.error,
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        filled: true,
                        fillColor: theme.cardColor,
                        suffixIcon: InkWell(
                          onTap: () async {
                            safeSetState(() => _model.passwordLoginVisibility =
                                !_model.passwordLoginVisibility);
                          },
                          focusNode: FocusNode(skipTraversal: true),
                          child: Icon(
                            _model.passwordLoginVisibility
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: theme.colorScheme.primary,
                            size: 22,
                          ),
                        ),
                      ),
                      style: theme.textTheme.bodyMedium,
                      cursorColor: theme.colorScheme.primary,
                      enableInteractiveSelection: true,
                      validator: _model.passwordLoginTextControllerValidator
                          .asValidator(context),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: TextButton.icon(
                      onPressed: () async {
                        context.pushNamed(RecuperoPasswordWidget.routeName);
                      },
                      icon: Icon(
                        Icons.lock_reset_rounded,
                        size: 17.0,
                        color: theme.colorScheme.primary,
                      ),
                      label: Text(
                        'Password dimenticata?',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13.5,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12.0, vertical: 4.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0.0, 24.0, 0.0, 16.0),
                  child: FFButtonWidget(
                    onPressed: () async {
                      await authManager.refreshUser();
                      GoRouter.of(context).prepareAuthEvent();

                      final user = await authManager.signInWithEmail(
                        context,
                        _model.emailLoginTextController.text,
                        _model.passwordLoginTextController.text,
                      );
                      if (user == null) {
                        return;
                      }

                      FFAppState().loginProvider = 'password';
                      safeSetState(() {});
                      if (currentUserEmailVerified) {
                        if (valueOrDefault<bool>(
                                currentUserDocument?.isPremium, false) ==
                            true) {
                          context.pushNamedAuth(
                            HomeRistoratoreWidget.routeName,
                            context.mounted,
                            queryParameters: {
                              'ristoranteRef': serializeParam(
                                currentUserReference,
                                ParamType.DocumentReference,
                              ),
                            }.withoutNulls,
                          );
                        } else {
                          context.pushNamedAuth(
                              AbbonamentoWidget.routeName, context.mounted);
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Attenzione! Devi prima verificare la tua email! Controlla la posta.',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.onError,
                              ),
                            ),
                            duration: Duration(milliseconds: 4000),
                            backgroundColor: theme.colorScheme.error,
                          ),
                        );
                        GoRouter.of(context).prepareAuthEvent();
                        await authManager.signOut();
                        GoRouter.of(context).clearRedirectLocation();
                      }
                    },
                    text: 'Accedi',
                    options: FFButtonOptions(
                      width: 280.0,
                      height: 48.0,
                      padding:
                          EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                      iconPadding:
                          EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                      color: theme.colorScheme.primary,
                      textStyle: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                        color: theme.colorScheme.onPrimary,
                      ),
                      elevation: 2.0,
                      borderRadius: BorderRadius.circular(14.0),
                      borderSide: theme.brightness == Brightness.dark
                          ? BorderSide(
                              color: Colors.white.withValues(alpha: 0.15),
                              width: 1.0,
                            )
                          : BorderSide.none,
                    ),
                  ),
                ),
                SizedBox(
                  width: 280.0,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Divisore "oppure"
                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: theme.dividerColor.withValues(alpha: 0.2),
                              height: 1.0,
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 14.0),
                            child: Text(
                              'oppure',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.hintColor,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: theme.dividerColor.withValues(alpha: 0.2),
                              height: 1.0,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16.0),

                      // Bottone Continua con Google
                      GoogleSignInButton(
                        onTap: () async {
                          GoRouter.of(context).prepareAuthEvent();
                          final user =
                              await authManager.signInWithGoogle(context);
                          if (user == null) {
                            return;
                          }
                          FFAppState().loginProvider = 'google.com';
                          safeSetState(() {});
                          if (valueOrDefault<bool>(
                                  currentUserDocument?.isPremium, false) ==
                              true) {
                            await InviaRubricaCall.call(
                              emailUtente: currentUserEmail,
                            );

                            context.pushNamedAuth(
                              HomeRistoratoreWidget.routeName,
                              context.mounted,
                              queryParameters: {
                                'ristoranteRef': serializeParam(
                                  currentUserReference,
                                  ParamType.DocumentReference,
                                ),
                              }.withoutNulls,
                            );
                          } else {
                            if (valueOrDefault<bool>(
                                    currentUserDocument?.isAdmin, false) ==
                                true) {
                              context.pushNamedAuth(
                                  AdminDashboardWidget.routeName,
                                  context.mounted);
                            } else {
                              context.pushNamedAuth(
                                  AbbonamentoWidget.routeName, context.mounted);
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0.0, 24.0, 0.0, 0.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Non hai un account? ',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.hintColor,
                        ),
                      ),
                      InkWell(
                        splashColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        borderRadius: BorderRadius.circular(8.0),
                        onTap: () async {
                          context.pushNamed(AuthRegistrationWidget.routeName);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 4.0),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary
                                .withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(
                              color: theme.colorScheme.primary
                                  .withValues(alpha: 0.35),
                              width: 1.0,
                            ),
                          ),
                          child: Text(
                            'Registrati',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
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
