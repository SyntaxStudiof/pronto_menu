import 'package:flutter/material.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/personalizzazione/personalizzazione_widget.dart';
import 'cambia_colore_model.dart';

export 'cambia_colore_model.dart';

class CambiaColoreWidget extends StatefulWidget {
  const CambiaColoreWidget({
    super.key,
    this.ristoranteRef,
  });

  final DocumentReference? ristoranteRef;

  static String routeName = 'cambiaColore';
  static String routePath = '/cambiaColore';

  @override
  State<CambiaColoreWidget> createState() => _CambiaColoreWidgetState();
}

class _CambiaColoreWidgetState extends State<CambiaColoreWidget> {
  late CambiaColoreModel _model;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CambiaColoreModel());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PersonalizzazioneWidget(
      ristoranteRef: widget.ristoranteRef,
      initialTab: 1,
    );
  }
}
