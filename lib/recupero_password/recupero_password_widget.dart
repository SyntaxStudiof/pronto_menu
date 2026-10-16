import '/auth/firebase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'recupero_password_model.dart';
export 'recupero_password_model.dart';

/// Pagina "Hai dimenticato la password?"
class RecuperoPasswordWidget extends StatefulWidget {
  const RecuperoPasswordWidget({super.key});

  static String routeName = 'RecuperoPassword';
  static String routePath = '/recuperoPassword';

  @override
  State<RecuperoPasswordWidget> createState() => _RecuperoPasswordWidgetState();
}

class _RecuperoPasswordWidgetState extends State<RecuperoPasswordWidget> {
  late RecuperoPasswordModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => RecuperoPasswordModel());

    _model.txtEmailRecuperoTextController ??= TextEditingController();
    _model.txtEmailRecuperoFocusNode ??= FocusNode();

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
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 32.0),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 440.0),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(24.0),
                  border: Border.all(
                    color: theme.dividerColor.withValues(alpha: 0.5),
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
                    // Tasto Indietro
                    Align(
                      alignment: Alignment.centerLeft,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12.0),
                        onTap: () async {
                          context.pushNamed(AuthWelcomeWidget.routeName);
                        },
                        child: Container(
                          width: 40.0,
                          height: 40.0,
                          decoration: BoxDecoration(
                            color: theme.scaffoldBackgroundColor,
                            borderRadius: BorderRadius.circular(12.0),
                            border: Border.all(
                              color: theme.dividerColor.withValues(alpha: 0.5),
                              width: 1.0,
                            ),
                          ),
                          child: Icon(
                            Icons.arrow_back_rounded,
                            color: theme.iconTheme.color,
                            size: 20.0,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),

                    // Icona / Badge recupero
                    Center(
                      child: Container(
                        width: 76.0,
                        height: 76.0,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.lock_reset_rounded,
                          color: theme.colorScheme.primary,
                          size: 38.0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20.0),

                    // Titolo
                    Text(
                      'Recupera Password',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 8.0),

                    // Descrizione
                    Text(
                      'Non preoccuparti! Inserisci l\'email associata al tuo account e ti invieremo un link per crearne una nuova.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.hintColor,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 28.0),

                    // Label Email
                    Text(
                      'Email',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8.0),

                    // Campo Email
                    TextFormField(
                      controller: _model.txtEmailRecuperoTextController,
                      focusNode: _model.txtEmailRecuperoFocusNode,
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
                          color: theme.hintColor,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: theme.dividerColor,
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
                      validator: _model.txtEmailRecuperoTextControllerValidator
                          .asValidator(context),
                    ),
                    const SizedBox(height: 24.0),

                    // Bottone Invia Link
                    FFButtonWidget(
                      onPressed: () async {
                        final email = _model.txtEmailRecuperoTextController.text.trim();
                        if (email.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Inserisci la tua email per reimpostare la password.',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.onError,
                                ),
                              ),
                              backgroundColor: theme.colorScheme.error,
                            ),
                          );
                          return;
                        }

                        await authManager.resetPassword(
                          email: email,
                          context: context,
                        );

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Email inviata! Controlla la tua casella di posta.',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.onPrimary,
                                ),
                              ),
                              duration: const Duration(milliseconds: 5000),
                              backgroundColor: theme.colorScheme.primary,
                            ),
                          );
                          context.pushNamed(AuthWelcomeWidget.routeName);
                        }
                      },
                      text: 'Invia link di recupero',
                      options: FFButtonOptions(
                        width: double.infinity,
                        height: 48.0,
                        color: theme.colorScheme.primary,
                        textStyle: theme.textTheme.titleSmall?.copyWith(
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onPrimary,
                        ),
                        elevation: 0.0,
                        borderRadius: BorderRadius.circular(14.0),
                      ),
                    ),
                    const SizedBox(height: 24.0),

                    // Link Torna al Login
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Ricordi la password? ',
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
