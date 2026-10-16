import '/auth/firebase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/index.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '/components/google_sign_in_button.dart';
import 'auth_registration_model.dart';
export 'auth_registration_model.dart';

/// Pagina di registrazione
class AuthRegistrationWidget extends StatefulWidget {
  const AuthRegistrationWidget({super.key});

  static String routeName = 'auth_registration';
  static String routePath = '/authRegistration';

  @override
  State<AuthRegistrationWidget> createState() => _AuthRegistrationWidgetState();
}

class _AuthRegistrationWidgetState extends State<AuthRegistrationWidget> {
  late AuthRegistrationModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AuthRegistrationModel());

    _model.txtNomeRegistrazioneTextController ??= TextEditingController();
    _model.txtNomeRegistrazioneFocusNode ??= FocusNode();

    _model.txtEmailRegistrazioneTextController ??= TextEditingController();
    _model.txtEmailRegistrazioneFocusNode ??= FocusNode();

    _model.txtPasswordRegistrazioneTextController ??= TextEditingController();
    _model.txtPasswordRegistrazioneFocusNode ??= FocusNode();

    _model.confirmPasswordTextController ??= TextEditingController();
    _model.textFieldFocusNode ??= FocusNode();

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
          child: Center(
            child: SingleChildScrollView(
              controller: _model.columnController,
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 32.0),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 460.0),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(24.0),
                  border: Border.all(
                    color: theme.dividerColor.withValues(alpha: 0.2),
                    width: 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 24.0,
                      offset: const Offset(0.0, 8.0),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo + Branding
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16.0),
                        child: Image.asset(
                          'assets/images/IMG_8006.png',
                          width: 80.0,
                          height: 80.0,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Center(
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Pronto',
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.5,
                              ),
                            ),
                            TextSpan(
                              text: 'Menu',
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 6.0),
                    Center(
                      child: Text(
                        'Crea il tuo account ristoratore',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.hintColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28.0),

                    // Campo Nome del ristorante
                    Text(
                      'Nome del ristorante',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    TextFormField(
                      controller: _model.txtNomeRegistrazioneTextController,
                      focusNode: _model.txtNomeRegistrazioneFocusNode,
                      autofocus: false,
                      enabled: true,
                      obscureText: false,
                      decoration: InputDecoration(
                        isDense: true,
                        filled: true,
                        fillColor: theme.scaffoldBackgroundColor,
                        prefixIcon: Icon(
                          Icons.storefront_outlined,
                          color: theme.hintColor,
                          size: 20.0,
                        ),
                        hintText: 'Es. Pizzeria Da Mario',
                        hintStyle: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.hintColor.withValues(alpha: 0.6),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: theme.dividerColor.withValues(alpha: 0.2),
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(14.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: theme.colorScheme.primary,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(14.0),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: theme.colorScheme.error,
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(14.0),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: theme.colorScheme.error,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(14.0),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                      ),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      keyboardType: TextInputType.text,
                      cursorColor: theme.colorScheme.primary,
                      enableInteractiveSelection: true,
                      validator: _model.txtNomeRegistrazioneTextControllerValidator.asValidator(context),
                    ),
                    const SizedBox(height: 18.0),

                    // Campo Email
                    Text(
                      'Email',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    TextFormField(
                      controller: _model.txtEmailRegistrazioneTextController,
                      focusNode: _model.txtEmailRegistrazioneFocusNode,
                      autofocus: false,
                      enabled: true,
                      obscureText: false,
                      decoration: InputDecoration(
                        isDense: true,
                        filled: true,
                        fillColor: theme.scaffoldBackgroundColor,
                        prefixIcon: Icon(
                          Icons.mail_outline_rounded,
                          color: theme.hintColor,
                          size: 20.0,
                        ),
                        hintText: 'nome@ristorante.it',
                        hintStyle: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.hintColor.withValues(alpha: 0.6),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: theme.dividerColor.withValues(alpha: 0.2),
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(14.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: theme.colorScheme.primary,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(14.0),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: theme.colorScheme.error,
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(14.0),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: theme.colorScheme.error,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(14.0),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                      ),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      keyboardType: TextInputType.emailAddress,
                      cursorColor: theme.colorScheme.primary,
                      enableInteractiveSelection: true,
                      validator: _model.txtEmailRegistrazioneTextControllerValidator.asValidator(context),
                    ),
                    const SizedBox(height: 18.0),

                    // Campo Password
                    Text(
                      'Password',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    TextFormField(
                      controller: _model.txtPasswordRegistrazioneTextController,
                      focusNode: _model.txtPasswordRegistrazioneFocusNode,
                      autofocus: false,
                      enabled: true,
                      obscureText: !_model.txtPasswordRegistrazioneVisibility,
                      decoration: InputDecoration(
                        isDense: true,
                        filled: true,
                        fillColor: theme.scaffoldBackgroundColor,
                        prefixIcon: Icon(
                          Icons.lock_outline_rounded,
                          color: theme.hintColor,
                          size: 20.0,
                        ),
                        suffixIcon: InkWell(
                          onTap: () async {
                            safeSetState(() => _model.txtPasswordRegistrazioneVisibility =
                                !_model.txtPasswordRegistrazioneVisibility);
                          },
                          focusNode: FocusNode(skipTraversal: true),
                          child: Icon(
                            _model.txtPasswordRegistrazioneVisibility
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: theme.hintColor,
                            size: 20.0,
                          ),
                        ),
                        hintText: 'Crea una password sicura',
                        hintStyle: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.hintColor.withValues(alpha: 0.6),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: theme.dividerColor.withValues(alpha: 0.2),
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(14.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: theme.colorScheme.primary,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(14.0),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: theme.colorScheme.error,
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(14.0),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: theme.colorScheme.error,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(14.0),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                      ),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      cursorColor: theme.colorScheme.primary,
                      enableInteractiveSelection: true,
                      validator: _model.txtPasswordRegistrazioneTextControllerValidator.asValidator(context),
                    ),
                    const SizedBox(height: 18.0),

                    // Campo Conferma Password
                    Text(
                      'Conferma password',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    TextFormField(
                      controller: _model.confirmPasswordTextController,
                      focusNode: _model.textFieldFocusNode,
                      autofocus: false,
                      enabled: true,
                      obscureText: !_model.passwordVisibility,
                      decoration: InputDecoration(
                        isDense: true,
                        filled: true,
                        fillColor: theme.scaffoldBackgroundColor,
                        prefixIcon: Icon(
                          Icons.lock_outline_rounded,
                          color: theme.hintColor,
                          size: 20.0,
                        ),
                        suffixIcon: InkWell(
                          onTap: () async {
                            safeSetState(() => _model.passwordVisibility =
                                !_model.passwordVisibility);
                          },
                          focusNode: FocusNode(skipTraversal: true),
                          child: Icon(
                            _model.passwordVisibility
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: theme.hintColor,
                            size: 20.0,
                          ),
                        ),
                        hintText: 'Ripeti la password',
                        hintStyle: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.hintColor.withValues(alpha: 0.6),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: theme.dividerColor.withValues(alpha: 0.2),
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(14.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: theme.colorScheme.primary,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(14.0),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: theme.colorScheme.error,
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(14.0),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: theme.colorScheme.error,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(14.0),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                      ),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      cursorColor: theme.colorScheme.primary,
                      enableInteractiveSelection: true,
                      validator: _model.confirmPasswordTextControllerValidator.asValidator(context),
                    ),
                    const SizedBox(height: 24.0),

                    // Bottone Registrati
                    FFButtonWidget(
                      onPressed: () async {
                        GoRouter.of(context).prepareAuthEvent();
                        if (_model.txtPasswordRegistrazioneTextController.text !=
                            _model.confirmPasswordTextController.text) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Le password non coincidono!',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.onError,
                                ),
                              ),
                              backgroundColor: theme.colorScheme.error,
                            ),
                          );
                          return;
                        }

                        final user = await authManager.createAccountWithEmail(
                          context,
                          _model.txtEmailRegistrazioneTextController.text,
                          _model.txtPasswordRegistrazioneTextController.text,
                        );
                        if (user == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Registrazione fallita: email già registrata o dati non validi.',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.onError,
                                ),
                              ),
                              backgroundColor: theme.colorScheme.error,
                            ),
                          );
                          return;
                        }

                        await UsersRecord.collection
                            .doc(user.uid)
                            .set(createUsersRecordData(
                              displayName: _model.txtNomeRegistrazioneTextController.text,
                              email: _model.txtEmailRegistrazioneTextController.text,
                              isAdmin: false,
                              isPremium: false,
                              temaScelto: 'c',
                            ));

                        FFAppState().loginProvider = 'password';
                        safeSetState(() {});

                        try {
                          await authManager.sendEmailVerification();
                        } catch (_) {}

                        try {
                          await InviaRubricaCall.call(
                            emailUtente: _model.txtEmailRegistrazioneTextController.text,
                          );
                        } catch (_) {}

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Account creato! Ora accedi con le tue credenziali.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onPrimary,
                              ),
                            ),
                            duration: const Duration(milliseconds: 8000),
                            backgroundColor: theme.colorScheme.primary,
                          ),
                        );
                        GoRouter.of(context).prepareAuthEvent();
                        await authManager.signOut();
                        GoRouter.of(context).clearRedirectLocation();

                        context.pushNamedAuth(
                            AuthWelcomeWidget.routeName, context.mounted);
                      },
                      text: 'Registrati',
                      options: FFButtonOptions(
                        width: double.infinity,
                        height: 48.0,
                        color: theme.colorScheme.primary,
                        textStyle: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onPrimary,
                        ),
                        elevation: 0.0,
                        borderRadius: BorderRadius.circular(14.0),
                      ),
                    ),
                    const SizedBox(height: 22.0),

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
                          padding: const EdgeInsets.symmetric(horizontal: 14.0),
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
                    const SizedBox(height: 22.0),

                    // Bottone Continua con Google
                    GoogleSignInButton(
                      onTap: () async {
                        GoRouter.of(context).prepareAuthEvent();
                        final user = await authManager.signInWithGoogle(context);
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
                    const SizedBox(height: 26.0),

                    // Link Accedi
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Hai già un account? ',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.hintColor,
                          ),
                        ),
                        InkWell(
                          onTap: () async {
                            context.pushNamed(AuthWelcomeWidget.routeName);
                          },
                          child: Text(
                            'Accedi',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
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
    );
  }
}
