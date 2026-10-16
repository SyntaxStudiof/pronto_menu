import '/auth/firebase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'cambia_password_model.dart';
export 'cambia_password_model.dart';

/// Pagina per cambiare password direttamente in app
class CambiaPasswordWidget extends StatefulWidget {
  const CambiaPasswordWidget({super.key});

  static String routeName = 'CambiaPassword';
  static String routePath = '/cambiaPassword';

  @override
  State<CambiaPasswordWidget> createState() => _CambiaPasswordWidgetState();
}

class _CambiaPasswordWidgetState extends State<CambiaPasswordWidget> {
  late CambiaPasswordModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CambiaPasswordModel());

    _model.vecchiaPasswordTextController ??= TextEditingController();
    _model.vecchiaPasswordFocusNode ??= FocusNode();

    _model.nuovaPasswordTextController ??= TextEditingController();
    _model.nuovaPasswordFocusNode ??= FocusNode();

    _model.confermaPasswordTextController ??= TextEditingController();
    _model.confermaPasswordFocusNode ??= FocusNode();

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
            borderRadius: 22.0,
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
            'Cambia Password',
            style: theme.appBarTheme.titleTextStyle ??
                theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 22.0,
                ),
          ),
          actions: const [],
          centerTitle: true,
          elevation: 0.0,
        ),
        body: SafeArea(
          top: true,
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 30.0),
            child: SingleChildScrollView(
              controller: _model.columnController1,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding:
                        const EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
                    child: SingleChildScrollView(
                      controller: _model.columnController2,
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Container(
                                    width: 40.0,
                                    height: 40.0,
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primary,
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    child: Align(
                                      alignment: const AlignmentDirectional(0.0, 0.0),
                                      child: Icon(
                                        Icons.lock_outline,
                                        color: theme.colorScheme.onPrimary,
                                        size: 20.0,
                                      ),
                                    ),
                                  ),
                                  Column(
                                    mainAxisSize: MainAxisSize.max,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Sicurezza Account',
                                        style: theme.textTheme.titleLarge?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        'Aggiorna la tua password',
                                        style: theme.textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                ].divide(const SizedBox(width: 8.0)),
                              ),
                            ].divide(const SizedBox(height: 8.0)),
                          ),
                          Divider(
                            thickness: 1.0,
                            color: theme.dividerColor,
                          ),
                          Form(
                            key: _model.formKey,
                            autovalidateMode: AutovalidateMode.disabled,
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Icon(
                                          Icons.lock_rounded,
                                          color: theme.colorScheme.primary,
                                          size: 16.0,
                                        ),
                                        Text(
                                          'Password Attuale',
                                          style: theme.textTheme.labelLarge?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ].divide(const SizedBox(width: 6.0)),
                                    ),
                                    Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                      ),
                                      child: TextFormField(
                                        controller: _model
                                            .vecchiaPasswordTextController,
                                        focusNode:
                                            _model.vecchiaPasswordFocusNode,
                                        autofocus: false,
                                        textInputAction: TextInputAction.next,
                                        obscureText:
                                            !_model.vecchiaPasswordVisibility,
                                        decoration: InputDecoration(
                                          isDense: false,
                                          hintText:
                                              'Inserisci la password attuale',
                                          hintStyle: theme.textTheme.bodyMedium?.copyWith(
                                            color: theme.hintColor,
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: theme.dividerColor,
                                              width: 1.0,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: theme.colorScheme.primary,
                                              width: 1.5,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                          ),
                                          errorBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: theme.colorScheme.error,
                                              width: 1.0,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                          ),
                                          focusedErrorBorder:
                                              OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: theme.colorScheme.error,
                                              width: 1.5,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                          ),
                                          filled: true,
                                          fillColor: theme.cardColor,
                                          contentPadding:
                                              const EdgeInsetsDirectional.fromSTEB(
                                                  16.0, 16.0, 16.0, 16.0),
                                          suffixIcon: InkWell(
                                            onTap: () async {
                                              safeSetState(() => _model
                                                      .vecchiaPasswordVisibility =
                                                  !_model
                                                      .vecchiaPasswordVisibility);
                                            },
                                            focusNode:
                                                FocusNode(skipTraversal: true),
                                            child: Icon(
                                              _model.vecchiaPasswordVisibility
                                                  ? Icons.visibility_outlined
                                                  : Icons
                                                      .visibility_off_outlined,
                                              color: theme.colorScheme.primary,
                                              size: 20.0,
                                            ),
                                          ),
                                        ),
                                        style: theme.textTheme.bodyMedium,
                                        cursorColor: theme.colorScheme.primary,
                                        validator: _model
                                            .vecchiaPasswordTextControllerValidator
                                            .asValidator(context),
                                      ),
                                    ),
                                  ].divide(const SizedBox(height: 8.0)),
                                ),
                              ].divide(const SizedBox(height: 24.0)),
                            ),
                          ),
                          Divider(
                            thickness: 1.0,
                            color: theme.dividerColor,
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Icon(
                                    Icons.lock_open_rounded,
                                    color: theme.hintColor,
                                    size: 16.0,
                                  ),
                                  Text(
                                    'Nuova Password',
                                    style: theme.textTheme.labelLarge?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ].divide(const SizedBox(width: 6.0)),
                              ),
                              Opacity(
                                opacity: 1.0,
                                child: Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  child: TextFormField(
                                    controller:
                                        _model.nuovaPasswordTextController,
                                    focusNode: _model.nuovaPasswordFocusNode,
                                    onChanged: (_) => EasyDebounce.debounce(
                                      '_model.nuovaPasswordTextController',
                                      const Duration(milliseconds: 100),
                                      () => safeSetState(() {}),
                                    ),
                                    autofocus: false,
                                    textInputAction: TextInputAction.next,
                                    obscureText:
                                        !_model.nuovaPasswordVisibility,
                                    decoration: InputDecoration(
                                      isDense: false,
                                      hintText: 'Inserisci la nuova password',
                                      hintStyle: theme.textTheme.bodyMedium?.copyWith(
                                        color: theme.hintColor,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: theme.dividerColor,
                                          width: 1.0,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: theme.colorScheme.primary,
                                          width: 1.5,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: theme.colorScheme.error,
                                          width: 1.0,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: theme.colorScheme.error,
                                          width: 1.5,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                      ),
                                      filled: true,
                                      fillColor: theme.cardColor,
                                      contentPadding:
                                          const EdgeInsetsDirectional.fromSTEB(
                                              16.0, 16.0, 16.0, 16.0),
                                      suffixIcon: InkWell(
                                        onTap: () async {
                                          safeSetState(() => _model
                                                  .nuovaPasswordVisibility =
                                              !_model.nuovaPasswordVisibility);
                                        },
                                        focusNode:
                                            FocusNode(skipTraversal: true),
                                        child: Icon(
                                          _model.nuovaPasswordVisibility
                                              ? Icons.visibility_outlined
                                              : Icons.visibility_off_outlined,
                                          color: theme.colorScheme.primary,
                                          size: 20.0,
                                        ),
                                      ),
                                    ),
                                    style: theme.textTheme.bodyMedium,
                                    cursorColor: theme.colorScheme.primary,
                                    validator: _model
                                        .nuovaPasswordTextControllerValidator
                                        .asValidator(context),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    4.0, 0.0, 4.0, 0.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'La password deve contenere almeno:',
                                      style: theme.textTheme.bodySmall,
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Icon(
                                          Icons.fiber_manual_record,
                                          color: _model.nuovaPasswordTextController.text.length >= 8
                                              ? const Color(0xFF10B981)
                                              : theme.hintColor,
                                          size: 12.0,
                                        ),
                                        Text(
                                          '8 caratteri',
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            color: _model.nuovaPasswordTextController.text.length >= 8
                                                ? const Color(0xFF10B981)
                                                : theme.hintColor,
                                          ),
                                        ),
                                      ].divide(const SizedBox(width: 6.0)),
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Icon(
                                          Icons.fiber_manual_record,
                                          color: RegExp(r'(?=.*[a-z])(?=.*[A-Z])')
                                                  .hasMatch(_model.nuovaPasswordTextController.text)
                                              ? const Color(0xFF10B981)
                                              : theme.hintColor,
                                          size: 12.0,
                                        ),
                                        Text(
                                          'Una lettera maiuscola e una minuscola',
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            color: RegExp(r'(?=.*[a-z])(?=.*[A-Z])')
                                                    .hasMatch(_model.nuovaPasswordTextController.text)
                                                ? const Color(0xFF10B981)
                                                : theme.hintColor,
                                          ),
                                        ),
                                      ].divide(const SizedBox(width: 6.0)),
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Icon(
                                          Icons.fiber_manual_record,
                                          color: RegExp(r'[\d\W]')
                                                  .hasMatch(_model.nuovaPasswordTextController.text)
                                              ? const Color(0xFF10B981)
                                              : theme.hintColor,
                                          size: 12.0,
                                        ),
                                        Text(
                                          'Un numero o un carattere speciale',
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            color: RegExp(r'[\d\W]')
                                                    .hasMatch(_model.nuovaPasswordTextController.text)
                                                ? const Color(0xFF10B981)
                                                : theme.hintColor,
                                          ),
                                        ),
                                      ].divide(const SizedBox(width: 6.0)),
                                    ),
                                  ].divide(const SizedBox(height: 6.0)),
                                ),
                              ),
                            ].divide(const SizedBox(height: 8.0)),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    0.0, 20.0, 0.0, 0.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Icon(
                                      Icons.verified_user_outlined,
                                      color: theme.hintColor,
                                      size: 16.0,
                                    ),
                                    Text(
                                      'Conferma Nuova Password',
                                      style: theme.textTheme.labelLarge?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ].divide(const SizedBox(width: 6.0)),
                                ),
                              ),
                              Opacity(
                                opacity: 1.0,
                                child: Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  child: TextFormField(
                                    controller:
                                        _model.confermaPasswordTextController,
                                    focusNode: _model.confermaPasswordFocusNode,
                                    autofocus: false,
                                    textInputAction: TextInputAction.done,
                                    obscureText:
                                        !_model.confermaPasswordVisibility,
                                    decoration: InputDecoration(
                                      isDense: false,
                                      hintText: 'Ripeti la nuova password',
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
                                          width: 1.5,
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
                                          width: 1.5,
                                        ),
                                        borderRadius: BorderRadius.circular(12.0),
                                      ),
                                      filled: true,
                                      fillColor: theme.cardColor,
                                      contentPadding:
                                          const EdgeInsetsDirectional.fromSTEB(
                                              16.0, 16.0, 16.0, 16.0),
                                      suffixIcon: InkWell(
                                        onTap: () async {
                                          safeSetState(() => _model
                                                  .confermaPasswordVisibility =
                                              !_model
                                                  .confermaPasswordVisibility);
                                        },
                                        focusNode:
                                            FocusNode(skipTraversal: true),
                                        child: Icon(
                                          _model.confermaPasswordVisibility
                                              ? Icons.visibility_outlined
                                              : Icons.visibility_off_outlined,
                                          color: theme.colorScheme.primary,
                                          size: 20.0,
                                        ),
                                      ),
                                    ),
                                    style: theme.textTheme.bodyMedium,
                                    cursorColor: theme.colorScheme.primary,
                                    validator: _model
                                        .confermaPasswordTextControllerValidator
                                        .asValidator(context),
                                  ),
                                ),
                              ),
                            ].divide(const SizedBox(height: 8.0)),
                          ),
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                0.0, 8.0, 0.0, 0.0),
                            child: FFButtonWidget(
                              onPressed: !((String pass) {
                                return pass.length >= 8 &&
                                    RegExp(r'(?=.*[a-z])(?=.*[A-Z])')
                                        .hasMatch(pass) &&
                                    RegExp(r'[\d\W]').hasMatch(pass);
                              }(_model.nuovaPasswordTextController.text))
                                  ? null
                                  : () async {
                                      Function() _navigate = () {};
                                      if (_model.nuovaPasswordTextController
                                              .text ==
                                          _model
                                              .confermaPasswordTextController
                                              .text) {
                                        await authManager.updatePassword(
                                          newPassword: _model
                                              .nuovaPasswordTextController
                                              .text,
                                          context: context,
                                        );
                                        safeSetState(() {});

                                        GoRouter.of(context)
                                            .prepareAuthEvent();
                                        await authManager.signOut();
                                        GoRouter.of(context)
                                            .clearRedirectLocation();

                                        _navigate = () => context.goNamedAuth(
                                            AuthWelcomeWidget.routeName,
                                            context.mounted);
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Le password non coincidono',
                                              style: theme.textTheme.titleSmall?.copyWith(
                                                color: theme.colorScheme.onError,
                                              ),
                                            ),
                                            duration:
                                                const Duration(milliseconds: 4000),
                                            backgroundColor:
                                                theme.colorScheme.error,
                                          ),
                                        );
                                      }

                                      _navigate();
                                    },
                              text: 'Aggiorna Password',
                              options: FFButtonOptions(
                                width: double.infinity,
                                height: 48.0,
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    24.0, 0.0, 24.0, 0.0),
                                iconPadding: const EdgeInsetsDirectional.fromSTEB(
                                    0.0, 0.0, 0.0, 0.0),
                                color: theme.colorScheme.primary,
                                textStyle: theme.textTheme.titleSmall?.copyWith(
                                  color: theme.colorScheme.onPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                                elevation: 2.0,
                                borderRadius: BorderRadius.circular(12.0),
                                disabledColor: theme.dividerColor,
                                disabledTextColor: theme.hintColor,
                              ),
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.info_outline_rounded,
                                color: theme.hintColor,
                                size: 14.0,
                              ),
                              Text(
                                'Verrai disconnesso dopo aver cambiato la password',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.hintColor,
                                ),
                              ),
                            ].divide(const SizedBox(width: 6.0)),
                          ),
                        ]
                            .divide(const SizedBox(height: 0.0))
                            .addToStart(const SizedBox(height: 32.0))
                            .addToEnd(const SizedBox(height: 32.0)),
                      ),
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
