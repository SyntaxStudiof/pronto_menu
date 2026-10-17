import '/auth/firebase_auth/auth_util.dart';
import '/backend/firebase_storage/storage.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/upload_data.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'popup_foto_piatto_model.dart';
export 'popup_foto_piatto_model.dart';

class PopupFotoPiattoWidget extends StatefulWidget {
  const PopupFotoPiattoWidget({super.key});

  @override
  State<PopupFotoPiattoWidget> createState() => _PopupFotoPiattoWidgetState();
}

class _PopupFotoPiattoWidgetState extends State<PopupFotoPiattoWidget> {
  late PopupFotoPiattoModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PopupFotoPiattoModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();
    final theme = Theme.of(context);

    final hasFoto = FFAppState().fotoInMemoria.isNotEmpty;
    final bool isUltra = currentUserDocument?.hasUltra ?? false;

    if (!isUltra) {
      return Container(
        width: MediaQuery.sizeOf(context).width * 1.0,
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24.0)),
        ),
        padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52.0,
              height: 52.0,
              decoration: BoxDecoration(
                color: const Color(0xFF673AB7).withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.photo_camera_rounded,
                color: Color(0xFF673AB7),
                size: 26.0,
              ),
            ),
            const SizedBox(height: 14.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFF673AB7).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: const Text(
                    'PIANO ULTRA 👑',
                    style: TextStyle(
                      color: Color(0xFF673AB7),
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12.0),
            Text(
              'Foto Piatti in Alta Risoluzione',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 19.0,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8.0),
            Text(
              'La possibilità di caricare e mostrare le foto dei piatti nel menù digitale è inclusa nel piano ProntoMenu Ultra. Con i piani Pro e Plus puoi inserire piatti completi di descrizioni dettagliate, ingredienti, prezzi e filtri allergeni.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.hintColor,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 22.0),
            FFButtonWidget(
              onPressed: () {
                Navigator.pop(context);
                context.pushNamed(AbbonamentoWidget.routeName);
              },
              text: 'Scopri ProntoMenu Ultra 👑',
              options: FFButtonOptions(
                width: double.infinity,
                height: 48.0,
                color: const Color(0xFF673AB7),
                textStyle: theme.textTheme.titleSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                elevation: 0.0,
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
            if (hasFoto) ...[
              const SizedBox(height: 10.0),
              TextButton.icon(
                onPressed: () {
                  FFAppState().fotoInMemoria = '';
                  safeSetState(() {});
                  Navigator.pop(context);
                },
                icon: Icon(
                  Icons.delete_outline_rounded,
                  color: theme.colorScheme.error,
                  size: 18.0,
                ),
                label: Text(
                  'Rimuovi foto esistente',
                  style: TextStyle(
                    color: theme.colorScheme.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    }

    return Container(
      width: MediaQuery.sizeOf(context).width * 1.0,
      height: hasFoto ? 295.0 : 240.0,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            RichText(
              textScaler: MediaQuery.of(context).textScaler,
              text: TextSpan(
                style: theme.textTheme.bodySmall?.copyWith(
                  height: 1.4,
                ),
                children: [
                  TextSpan(
                    text: '💡 Consiglio: ',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const TextSpan(
                    text:
                        'Per un risultato ottimale, utilizza foto in formato orizzontale con il piatto ben centrato. Evita foto verticali per non perdere dettagli.',
                  )
                ],
              ),
              textAlign: TextAlign.center,
            ),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(0.0, 24.0, 0.0, 0.0),
              child: FFButtonWidget(
                onPressed: () async {
                  final selectedMedia = await selectMediaWithSourceBottomSheet(
                    context: context,
                    maxWidth: 1024.00,
                    maxHeight: 800.00,
                    imageQuality: 55,
                    allowPhoto: true,
                  );
                  if (selectedMedia != null &&
                      selectedMedia.every(
                          (m) => validateFileFormat(m.storagePath, context))) {
                    safeSetState(
                        () => _model.isDataUploading_uploadDataQve = true);
                    var selectedUploadedFiles = <FFUploadedFile>[];

                    var downloadUrls = <String>[];
                    try {
                      selectedUploadedFiles = selectedMedia
                          .map((m) => FFUploadedFile(
                                name: m.storagePath.split('/').last,
                                bytes: m.bytes,
                                height: m.dimensions?.height,
                                width: m.dimensions?.width,
                                blurHash: m.blurHash,
                                originalFilename: m.originalFilename,
                              ))
                          .toList();

                      downloadUrls = (await Future.wait(
                        selectedMedia.map(
                          (m) async => await uploadData(m.storagePath, m.bytes),
                        ),
                      ))
                          .where((u) => u != null)
                          .map((u) => u!)
                          .toList();
                    } finally {
                      _model.isDataUploading_uploadDataQve = false;
                    }
                    if (selectedUploadedFiles.length == selectedMedia.length &&
                        downloadUrls.length == selectedMedia.length) {
                      safeSetState(() {
                        _model.uploadedLocalFile_uploadDataQve =
                            selectedUploadedFiles.first;
                        _model.uploadedFileUrl_uploadDataQve =
                            downloadUrls.first;
                      });
                    } else {
                      safeSetState(() {});
                      return;
                    }
                  }

                  FFAppState().fotoInMemoria =
                      _model.uploadedFileUrl_uploadDataQve;
                  safeSetState(() {});
                  Navigator.pop(context);
                },
                text: 'Scegli foto dalla galleria',
                options: FFButtonOptions(
                  width: 280.0,
                  height: 48.0,
                  padding: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                  iconPadding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                  elevation: 0.0,
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),
            if (hasFoto) ...[
              const SizedBox(height: 12.0),
              TextButton.icon(
                onPressed: () {
                  FFAppState().fotoInMemoria = '';
                  safeSetState(() {});
                  Navigator.pop(context);
                },
                icon: Icon(
                  Icons.delete_outline_rounded,
                  color: theme.colorScheme.error,
                  size: 18.0,
                ),
                label: Text(
                  'Elimina foto attuale',
                  style: TextStyle(
                    color: theme.colorScheme.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
