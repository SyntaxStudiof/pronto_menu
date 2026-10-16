import '/flutter_flow/flutter_flow_util.dart';
import 'impostazioni_jukebox_widget.dart' show ImpostazioniJukeboxWidget;
import 'package:flutter/material.dart';

class ImpostazioniJukeboxModel extends FlutterFlowModel<ImpostazioniJukeboxWidget> {
  bool jukeboxAttivo = false;
  TextEditingController? playlistController;
  FocusNode? playlistFocusNode;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    playlistController?.dispose();
    playlistFocusNode?.dispose();
  }
}
