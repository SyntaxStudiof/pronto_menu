import 'package:flutter/material.dart';
import '/personalizzazione/personalizzazione_widget.dart';

class SceltaStileWidget extends StatelessWidget {
  const SceltaStileWidget({super.key});

  static String routeName = 'sceltaStile';
  static String routePath = '/sceltaStile';

  @override
  Widget build(BuildContext context) {
    return const PersonalizzazioneWidget(initialTab: 0);
  }
}
