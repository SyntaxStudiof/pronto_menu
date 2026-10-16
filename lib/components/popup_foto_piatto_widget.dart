import '/backend/firebase_storage/storage.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/upload_data.dart';
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
