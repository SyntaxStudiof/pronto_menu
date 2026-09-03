import '/backend/firebase_storage/storage.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/upload_data.dart';
import 'dart:ui';
import 'popup_foto_piatto_widget.dart' show PopupFotoPiattoWidget;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class PopupFotoPiattoModel extends FlutterFlowModel<PopupFotoPiattoWidget> {
  ///  State fields for stateful widgets in this component.

  bool isDataUploading_uploadDataQve = false;
  FFUploadedFile uploadedLocalFile_uploadDataQve =
      FFUploadedFile(bytes: Uint8List.fromList([]), originalFilename: '');
  String uploadedFileUrl_uploadDataQve = '';

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
