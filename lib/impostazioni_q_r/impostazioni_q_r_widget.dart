import '/auth/firebase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'impostazioni_q_r_model.dart';
export 'impostazioni_q_r_model.dart';

class ImpostazioniQRWidget extends StatefulWidget {
  const ImpostazioniQRWidget({super.key});

  static String routeName = 'ImpostazioniQR';
  static String routePath = '/impostazioniQR';

  @override
  State<ImpostazioniQRWidget> createState() => _ImpostazioniQRWidgetState();
}

class _ImpostazioniQRWidgetState extends State<ImpostazioniQRWidget> {
  late ImpostazioniQRModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ImpostazioniQRModel());

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

    final menuWebUrl =
        'https://prontomenu-6d485.web.app/loaderMenu?ristoranteRef=$currentUserUid';
    final downloadQrUrl =
        'https://api.qrserver.com/v1/create-qr-code/?size=1024x1024&data=${Uri.encodeComponent(menuWebUrl)}';

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
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_rounded,
              color: theme.appBarTheme.foregroundColor ?? theme.iconTheme.color,
              size: 24.0,
            ),
            onPressed: () async {
              context.pop();
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
                  Icons.qr_code_2_rounded,
                  color: theme.colorScheme.primary,
                  size: 20.0,
                ),
              ),
              const SizedBox(width: 12.0),
              Text(
                'QR Code Menu',
                style: theme.appBarTheme.titleTextStyle ??
                    theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
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
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1.0),
            child: Container(
              color: theme.dividerColor.withValues(alpha: 0.5),
              height: 1.0,
            ),
          ),
        ),
        body: SafeArea(
          top: true,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 480.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Main QR Card
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(24.0),
                        border: Border.all(
                          color: theme.dividerColor.withValues(alpha: 0.5),
                          width: 1.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 20.0,
                            color: Colors.black.withValues(alpha: 0.05),
                            offset: const Offset(0.0, 4.0),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Badge circolare QR
                          Container(
                            width: 52.0,
                            height: 52.0,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.qr_code_2_rounded,
                              color: theme.colorScheme.primary,
                              size: 28.0,
                            ),
                          ),
                          const SizedBox(height: 16.0),
                          Text(
                            'Il tuo Menu Digitale',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 22.0,
                              letterSpacing: -0.4,
                            ),
                          ),
                          const SizedBox(height: 6.0),
                          Text(
                            'I clienti inquadrano questo codice con la fotocamera per sfogliare il menu ed ordinare.',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.hintColor,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 28.0),
                          // Frame elegante del QR Code (QR code always needs a white container to be scannable)
                          Container(
                            padding: const EdgeInsets.all(12.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20.0),
                              border: Border.all(
                                color: theme.dividerColor,
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  blurRadius: 12.0,
                                  color: Colors.black.withValues(alpha: 0.03),
                                  offset: const Offset(0.0, 2.0),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12.0),
                              child: QrImageView(
                                data: menuWebUrl,
                                version: QrVersions.auto,
                                size: 190.0,
                                backgroundColor: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24.0),
                          // Bottone Azione Apri / Scarica
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                await launchURL(downloadQrUrl);
                              },
                              icon: Icon(
                                Icons.open_in_new_rounded,
                                color: theme.colorScheme.onPrimary,
                                size: 18.0,
                              ),
                              label: Text(
                                'Apri e scarica QR code (HD)',
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: theme.colorScheme.onPrimary,
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.primary,
                                foregroundColor: theme.colorScheme.onPrimary,
                                elevation: 0.0,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                  vertical: 13.0,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14.0),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12.0),
                          // Bottone per vedere il menu come cliente
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                context.pushNamed(
                                  HubClienteWidget.routeName,
                                  queryParameters: {
                                    'ristoranteRef': serializeParam(
                                      currentUserReference,
                                      ParamType.DocumentReference,
                                    ),
                                  }.withoutNulls,
                                );
                              },
                              icon: Icon(
                                Icons.visibility_rounded,
                                color: theme.colorScheme.primary,
                                size: 18.0,
                              ),
                              label: Text(
                                'Vedi il menu come cliente',
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: theme.colorScheme.primary,
                                  width: 1.5,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                  vertical: 13.0,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14.0),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.info_outline_rounded,
                                color: theme.hintColor,
                                size: 15.0,
                              ),
                              const SizedBox(width: 6.0),
                              Flexible(
                                child: Text(
                                  'Tieni premuto sull\'immagine aperta per salvarla',
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.hintColor,
                                    fontSize: 12.0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
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
