import '/flutter_flow/flutter_flow_util.dart';
import 'supporto_ristoratore_widget.dart' show SupportoRistoratoreWidget;
import 'package:flutter/material.dart';

class SupportoRistoratoreModel
    extends FlutterFlowModel<SupportoRistoratoreWidget> {
  /// Local state
  int selectedTabIndex = 0; // 0 = Apri Ticket, 1 = I Miei Ticket
  String? categoriaSelezionata;
  String filtroStato = 'Tutti'; // 'Tutti', 'Aperto', 'Risolto'
  bool isSubmitting = false;

  /// Controllers
  ScrollController? scrollController;
  FocusNode? titoloTicketFocusNode;
  TextEditingController? titoloTicketTextController;
  String? Function(BuildContext, String?)? titoloTicketTextControllerValidator;

  FocusNode? descrizioneTicketFocusNode;
  TextEditingController? descrizioneTicketTextController;
  String? Function(BuildContext, String?)?
      descrizioneTicketTextControllerValidator;

  @override
  void initState(BuildContext context) {
    scrollController = ScrollController();
  }

  @override
  void dispose() {
    scrollController?.dispose();
    titoloTicketFocusNode?.dispose();
    titoloTicketTextController?.dispose();
    descrizioneTicketFocusNode?.dispose();
    descrizioneTicketTextController?.dispose();
  }
}
