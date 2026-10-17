import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/backend/firebase_storage/storage.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/upload_data.dart';
import '/custom_code/actions/index.dart' as actions;
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'profilo_utente_model.dart';
export 'profilo_utente_model.dart';

/// Pagina per modificare i propri dati
class ProfiloUtenteWidget extends StatefulWidget {
  const ProfiloUtenteWidget({
    super.key,
    this.ristoranteRef,
    this.embedded = false,
  });

  final DocumentReference? ristoranteRef;
  final bool embedded;

  static String routeName = 'ProfiloUtente';
  static String routePath = '/profiloUtente';

  @override
  State<ProfiloUtenteWidget> createState() => _ProfiloUtenteWidgetState();
}

class _ProfiloUtenteWidgetState extends State<ProfiloUtenteWidget> {
  late ProfiloUtenteModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ProfiloUtenteModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      _model.dataScelta = currentUserDocument?.dataNascita;
      safeSetState(() {});
      _model.isEmail = await actions.checkProvider();
      _model.mostraBottone = _model.isEmail!;
      safeSetState(() {});
    });

    _model.nomeTextController ??= TextEditingController(
        text: valueOrDefault(currentUserDocument?.nome, ''));
    _model.nomeFocusNode ??= FocusNode();

    _model.cognomeTextController ??= TextEditingController(
        text: valueOrDefault(currentUserDocument?.cognome, ''));
    _model.cognomeFocusNode ??= FocusNode();

    _model.ristoranteTextController ??=
        TextEditingController(text: currentUserDisplayName);
    _model.ristoranteFocusNode ??= FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  Widget _buildFormField({
    required BuildContext context,
    required String label,
    required TextEditingController? controller,
    required FocusNode? focusNode,
    required String hintText,
    required String? Function(BuildContext, String?)? validator,
    IconData? prefixIcon,
  }) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6.0),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          autofocus: false,
          decoration: InputDecoration(
            isDense: true,
            hintText: hintText,
            prefixIcon: prefixIcon != null
                ? Icon(
                    prefixIcon,
                    size: 20.0,
                  )
                : null,
          ),
          style: theme.textTheme.bodyMedium,
          cursorColor: theme.colorScheme.primary,
          validator: validator != null ? (val) => validator(context, val) : null,
        ),
      ],
    );
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
        appBar: widget.embedded
            ? null
            : AppBar(
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_rounded,
              size: 22.0,
            ),
            onPressed: () async {
              context.pushNamed(
                HomeRistoratoreWidget.routeName,
                queryParameters: {
                  'ristoranteRef': serializeParam(
                    widget.ristoranteRef ?? currentUserReference,
                    ParamType.DocumentReference,
                  ),
                }.withoutNulls,
                extra: <String, dynamic>{
                  '__transition_info__': const TransitionInfo(
                    hasTransition: true,
                    transitionType: PageTransitionType.leftToRight,
                  ),
                },
              );
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
                  Icons.person_rounded,
                  color: theme.colorScheme.primary,
                  size: 20.0,
                ),
              ),
              const SizedBox(width: 10.0),
              Text(
                'Il mio Profilo',
                style: theme.appBarTheme.titleTextStyle ??
                    theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                      letterSpacing: -0.4,
                    ),
              ),
            ],
          ),
          centerTitle: true,
          actions: const [
            SizedBox(width: 48.0),
          ],
          elevation: 0.0,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1.0),
            child: Divider(
              height: 1.0,
              thickness: 1.0,
              color: theme.dividerColor.withValues(alpha: 0.5),
            ),
          ),
        ),
        body: SafeArea(
          top: true,
          child: StreamBuilder<UsersRecord>(
            stream: UsersRecord.getDocument(widget.ristoranteRef ?? currentUserReference!),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: SizedBox(
                    width: 40.0,
                    height: 40.0,
                    child: SpinKitPulse(
                      color: theme.colorScheme.primary,
                      size: 40.0,
                    ),
                  ),
                );
              }

              final columnUsersRecord = snapshot.data!;

              return Center(
                child: SingleChildScrollView(
                  controller: _model.columnController,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 32.0),
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 560.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Avatar Section
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Container(
                              width: 120.0,
                              height: 120.0,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: theme.cardColor,
                                border: Border.all(
                                  color: theme.colorScheme.primary,
                                  width: 3.0,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    blurRadius: 16.0,
                                    color: Colors.black.withValues(alpha: 0.06),
                                    offset: const Offset(0.0, 4.0),
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: Image.network(
                                  valueOrDefault<String>(
                                    columnUsersRecord.photoUrl,
                                    'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
                                  ),
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Image.asset(
                                    'assets/images/IMG_8006.png',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () async {
                                final selectedMedia =
                                    await selectMediaWithSourceBottomSheet(
                                  context: context,
                                  maxWidth: 800.00,
                                  maxHeight: 800.00,
                                  imageQuality: 60,
                                  allowPhoto: true,
                                );
                                if (selectedMedia != null &&
                                    selectedMedia.every((m) =>
                                        validateFileFormat(
                                            m.storagePath, context))) {
                                  safeSetState(() =>
                                      _model.isDataUploading_uploadData3sa =
                                          true);
                                  var selectedUploadedFiles =
                                      <FFUploadedFile>[];
                                  var downloadUrls = <String>[];
                                  try {
                                    selectedUploadedFiles = selectedMedia
                                        .map((m) => FFUploadedFile(
                                              name:
                                                  m.storagePath.split('/').last,
                                              bytes: m.bytes,
                                              height: m.dimensions?.height,
                                              width: m.dimensions?.width,
                                              blurHash: m.blurHash,
                                              originalFilename:
                                                  m.originalFilename,
                                            ))
                                        .toList();

                                    downloadUrls = (await Future.wait(
                                      selectedMedia.map(
                                        (m) async => await uploadData(
                                            m.storagePath, m.bytes),
                                      ),
                                    ))
                                        .where((u) => u != null)
                                        .map((u) => u!)
                                        .toList();
                                  } finally {
                                    _model.isDataUploading_uploadData3sa = false;
                                  }
                                  if (selectedUploadedFiles.length ==
                                          selectedMedia.length &&
                                  downloadUrls.length ==
                                          selectedMedia.length) {
                                    safeSetState(() {
                                      _model.uploadedLocalFile_uploadData3sa =
                                          selectedUploadedFiles.first;
                                      _model.uploadedFileUrl_uploadData3sa =
                                          downloadUrls.first;
                                    });
                                  } else {
                                    safeSetState(() {});
                                    return;
                                  }
                                }

                                await currentUserReference!
                                    .update(createUsersRecordData(
                                  photoUrl:
                                      _model.uploadedFileUrl_uploadData3sa,
                                ));
                              },
                              child: Container(
                                width: 38.0,
                                height: 38.0,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: theme.cardColor,
                                    width: 2.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      blurRadius: 8.0,
                                      color: Colors.black.withValues(alpha: 0.1),
                                      offset: const Offset(0.0, 2.0),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.camera_alt_rounded,
                                  color: Colors.white,
                                  size: 18.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12.0),
                        Text(
                          valueOrDefault<String>(
                            currentUserDisplayName,
                            'Ristoratore',
                          ),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          currentUserEmail,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                        const SizedBox(height: 12.0),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14.0, vertical: 7.0),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary
                                .withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(20.0),
                            border: Border.all(
                              color: theme.colorScheme.primary
                                  .withValues(alpha: 0.22),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.info_outline_rounded,
                                size: 16.0,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 8.0),
                              Flexible(
                                child: Text(
                                  'La foto impostata apparirà anche nell\'intestazione del tuo menù',
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12.0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24.0),
                        // Profile Data Card Form
                        Card(
                          elevation: 0.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                            side: BorderSide(
                              color: theme.dividerColor.withValues(alpha: 0.6),
                              width: 1.0,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                AuthUserStreamWidget(
                                  builder: (context) => _buildFormField(
                                    context: context,
                                    label: 'Nome',
                                    controller: _model.nomeTextController,
                                    focusNode: _model.nomeFocusNode,
                                    hintText: 'Inserisci il tuo nome',
                                    validator:
                                        _model.nomeTextControllerValidator,
                                    prefixIcon: Icons.person_outline_rounded,
                                  ),
                                ),
                                const SizedBox(height: 16.0),
                                AuthUserStreamWidget(
                                  builder: (context) => _buildFormField(
                                    context: context,
                                    label: 'Cognome',
                                    controller: _model.cognomeTextController,
                                    focusNode: _model.cognomeFocusNode,
                                    hintText: 'Inserisci il tuo cognome',
                                    validator:
                                        _model.cognomeTextControllerValidator,
                                    prefixIcon: Icons.badge_outlined,
                                  ),
                                ),
                                const SizedBox(height: 16.0),
                                AuthUserStreamWidget(
                                  builder: (context) => _buildFormField(
                                    context: context,
                                    label: 'Nome Ristorante',
                                    controller: _model.ristoranteTextController,
                                    focusNode: _model.ristoranteFocusNode,
                                    hintText: 'Nome della tua attività',
                                    validator: _model
                                        .ristoranteTextControllerValidator,
                                    prefixIcon:
                                        Icons.storefront_outlined,
                                  ),
                                ),
                                const SizedBox(height: 16.0),
                                // Date Picker Field
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Data di nascita',
                                      style: theme.textTheme.labelLarge?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 6.0),
                                    InkWell(
                                      onTap: () async {
                                        final datePickedDate =
                                            await showDatePicker(
                                          context: context,
                                          barrierDismissible: false,
                                          initialDate: _model.dataScelta ??
                                              getCurrentTimestamp,
                                          firstDate: DateTime(1900),
                                          lastDate: getCurrentTimestamp,
                                        );

                                        if (datePickedDate != null) {
                                          safeSetState(() {
                                            _model.datePicked = DateTime(
                                              datePickedDate.year,
                                              datePickedDate.month,
                                              datePickedDate.day,
                                            );
                                          });
                                        } else if (_model.datePicked != null) {
                                          safeSetState(() {
                                            _model.datePicked =
                                                getCurrentTimestamp;
                                          });
                                        }
                                        _model.dataScelta = _model.datePicked;
                                        safeSetState(() {});
                                      },
                                      borderRadius: BorderRadius.circular(12.0),
                                      child: Container(
                                        height: 48.0,
                                        decoration: BoxDecoration(
                                          color: theme.inputDecorationTheme.fillColor ??
                                              theme.colorScheme.surface,
                                          borderRadius:
                                              BorderRadius.circular(12.0),
                                          border: Border.all(
                                            color: theme.dividerColor.withValues(alpha: 0.6),
                                            width: 1.0,
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16.0),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.calendar_month_outlined,
                                              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                              size: 20.0,
                                            ),
                                            const SizedBox(width: 12.0),
                                            Text(
                                              valueOrDefault<String>(
                                                dateTimeFormat(
                                                  "d/M/y",
                                                  _model.dataScelta,
                                                  locale:
                                                      FFLocalizations.of(context)
                                                          .languageCode,
                                                ),
                                                'Seleziona data di nascita',
                                              ),
                                              style: theme.textTheme.bodyMedium?.copyWith(
                                                color: _model.dataScelta != null
                                                    ? theme.colorScheme.onSurface
                                                    : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24.0),
                                // Salva Modifiche Button
                                ElevatedButton(
                                  onPressed: () async {
                                    await currentUserReference!
                                        .update(createUsersRecordData(
                                      nome: _model.nomeTextController.text,
                                      cognome: _model.cognomeTextController.text,
                                      displayName:
                                          _model.ristoranteTextController.text,
                                      dataNascita: _model.dataScelta,
                                    ));
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Profilo aggiornato con successo!',
                                          ),
                                          duration:
                                              Duration(milliseconds: 3000),
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                    }
                                  },
                                  child: const Text('Salva modifiche'),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24.0),
                        // Logout Button
                        OutlinedButton.icon(
                          onPressed: () async {
                            GoRouter.of(context).prepareAuthEvent();
                            await authManager.signOut();
                            GoRouter.of(context).clearRedirectLocation();

                            if (context.mounted) {
                              context.goNamedAuth(
                                AuthWelcomeWidget.routeName,
                                context.mounted,
                              );
                            }
                          },
                          icon: const Icon(
                            Icons.logout_rounded,
                            size: 18.0,
                          ),
                          label: const Text('Disconnetti account'),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
