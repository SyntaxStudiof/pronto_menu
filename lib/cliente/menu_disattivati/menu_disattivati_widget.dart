import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/cliente/menu_cliente/menu_cliente_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/services/mutaforma_service.dart';
import '/services/translation_service.dart';
import 'menu_disattivati_model.dart';

export 'menu_disattivati_model.dart';

class MenuDisattivatiWidget extends StatefulWidget {
  const MenuDisattivatiWidget({
    super.key,
    required this.ristoranteRef,
  });

  final DocumentReference? ristoranteRef;

  static String routeName = 'MenuDisattivati';
  static String routePath = '/menuDisattivati';

  @override
  State<MenuDisattivatiWidget> createState() => _MenuDisattivatiWidgetState();
}

class _MenuDisattivatiWidgetState extends State<MenuDisattivatiWidget> {
  late MenuDisattivatiModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MenuDisattivatiModel());
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
    final colorScheme = theme.colorScheme;

    return StreamBuilder<UsersRecord>(
      stream: UsersRecord.getDocument(widget.ristoranteRef!),
      builder: (context, userSnapshot) {
        if (!userSnapshot.hasData) {
          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            body: Center(
              child: SpinKitPulse(
                color: colorScheme.primary,
                size: 50.0,
              ),
            ),
          );
        }

        final userRecord = userSnapshot.data!;
        final List<FasciaMutaforma> tutteFasce =
            MutaformaService.decodeFasce(userRecord.fasceMutaforma);
        final FasciaMutaforma? fasciaAttiva =
            MutaformaService.getFasciaAttiva(tutteFasce);

        // Menù disattivati (tutte le fasce che non sono attive ora)
        final List<FasciaMutaforma> fasceDisattivate =
            tutteFasce.where((f) => f.id != fasciaAttiva?.id).toList();

        return StreamBuilder<List<CategoriesRecord>>(
          stream: queryCategoriesRecord(
            queryBuilder: (q) => q
                .where('proprietario', isEqualTo: widget.ristoranteRef)
                .orderBy('ordine_categoria'),
          ),
          builder: (context, catSnapshot) {
            final tutteCategorie = catSnapshot.data ?? [];
            final Map<String, String> catNameMap = {
              for (final c in tutteCategorie) c.reference.id: c.name,
            };

            return Scaffold(
              key: scaffoldKey,
              backgroundColor: theme.scaffoldBackgroundColor,
              appBar: AppBar(
                backgroundColor:
                    theme.appBarTheme.backgroundColor ?? theme.cardColor,
                automaticallyImplyLeading: false,
                elevation: 0.0,
                centerTitle: true,
                leading: FlutterFlowIconButton(
                  borderColor: Colors.transparent,
                  borderRadius: 24.0,
                  borderWidth: 1.0,
                  buttonSize: 40.0,
                  icon: Icon(
                    Icons.arrow_back_rounded,
                    color: colorScheme.onSurface,
                    size: 24.0,
                  ),
                  onPressed: () async {
                    context.safePop();
                  },
                ),
                title: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 36.0,
                      height: 36.0,
                      decoration: BoxDecoration(
                        color: const Color(0xFF673AB7).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.auto_awesome_motion_rounded,
                        color: Color(0xFF673AB7),
                        size: 20.0,
                      ),
                    ),
                    const SizedBox(width: 10.0),
                    Text(
                      'Menù Fuori Orario',
                      style: theme.appBarTheme.titleTextStyle ??
                          theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 19.0,
                            letterSpacing: -0.4,
                            color: colorScheme.onSurface,
                          ),
                    ),
                  ],
                ),
                actions: const [
                  SizedBox(width: 48.0),
                ],
              ),
              body: SafeArea(
                top: true,
                child: fasceDisattivate.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.folder_off_rounded,
                                size: 54.0,
                                color: theme.hintColor,
                              ),
                              const SizedBox(height: 14.0),
                              Text(
                                'Nessun altro menù disponibile',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6.0),
                              Text(
                                'Al momento non ci sono altri menù configurati per questo locale.',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.hintColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 20.0),
                        children: [
                          // Banner info sola consultazione
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 12.0),
                            decoration: BoxDecoration(
                              color: const Color(0xFF673AB7)
                                  .withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(16.0),
                              border: Border.all(
                                color: const Color(0xFF673AB7)
                                    .withValues(alpha: 0.20),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.info_outline_rounded,
                                  color: Color(0xFF673AB7),
                                  size: 22.0,
                                ),
                                const SizedBox(width: 12.0),
                                Expanded(
                                  child: Text(
                                    'Questi menù non sono attualmente ordinabili, ma puoi sfogliarli liberamente per scoprire le nostre specialità!',
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      color: colorScheme.onSurface
                                          .withValues(alpha: 0.85),
                                      height: 1.35,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20.0),

                          Text(
                            'SCEGLI UN MENÙ DA SFOGLIARE (${fasceDisattivate.length})',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.6,
                              color: theme.hintColor,
                            ),
                          ),
                          const SizedBox(height: 12.0),

                          // Lista card menù
                          ...fasceDisattivate.map((fascia) {
                            final nomiCategorie = fascia.categoriaIds
                                .map((id) => catNameMap[id])
                                .where((name) => name != null)
                                .cast<String>()
                                .toList();

                            return Container(
                              margin: const EdgeInsets.only(bottom: 14.0),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    context.pushNamed(
                                      MenuClienteWidget.routeName,
                                      queryParameters: {
                                        'ristoranteRef': serializeParam(
                                          widget.ristoranteRef,
                                          ParamType.DocumentReference,
                                        ),
                                        'fasciaId': serializeParam(
                                          fascia.id,
                                          ParamType.String,
                                        ),
                                        'solaConsultazione': serializeParam(
                                          true,
                                          ParamType.bool,
                                        ),
                                      }.withoutNulls,
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(18.0),
                                  child: Container(
                                    padding: const EdgeInsets.all(18.0),
                                    decoration: BoxDecoration(
                                      color: theme.cardColor,
                                      borderRadius:
                                          BorderRadius.circular(18.0),
                                      border: Border.all(
                                        color: theme.dividerColor
                                            .withValues(alpha: 0.12),
                                        width: 1.2,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black
                                              .withValues(alpha: 0.03),
                                          blurRadius: 10.0,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              width: 42.0,
                                              height: 42.0,
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF673AB7)
                                                    .withValues(alpha: 0.12),
                                                borderRadius:
                                                    BorderRadius.circular(12.0),
                                              ),
                                              alignment: Alignment.center,
                                              child: const Icon(
                                                Icons.restaurant_rounded,
                                                color: Color(0xFF673AB7),
                                                size: 22.0,
                                              ),
                                            ),
                                            const SizedBox(width: 14.0),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    fascia.nome,
                                                    style: theme
                                                        .textTheme.titleMedium
                                                        ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16.5,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 2.0),
                                                  Text(
                                                    '${fascia.orarioInizio} - ${fascia.orarioFine} • ${MutaformaService.formatGiorni(fascia.giorni)}',
                                                    style: theme
                                                        .textTheme.bodySmall
                                                        ?.copyWith(
                                                      color: theme.hintColor,
                                                      fontSize: 12.0,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8.0,
                                                      vertical: 4.0),
                                              decoration: BoxDecoration(
                                                color: theme.dividerColor
                                                    .withValues(alpha: 0.1),
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    Icons.remove_red_eye_rounded,
                                                    size: 13.0,
                                                    color: theme.hintColor,
                                                  ),
                                                  const SizedBox(width: 4.0),
                                                  Text(
                                                    'CONSULTA',
                                                    style: TextStyle(
                                                      fontSize: 10.0,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: theme.hintColor,
                                                      letterSpacing: 0.3,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (nomiCategorie.isNotEmpty) ...[
                                          const SizedBox(height: 14.0),
                                          Wrap(
                                            spacing: 6.0,
                                            runSpacing: 6.0,
                                            children: nomiCategorie
                                                .take(5)
                                                .map((nomeCat) {
                                              return Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10.0,
                                                        vertical: 4.0),
                                                decoration: BoxDecoration(
                                                  color: colorScheme.surfaceContainerHighest
                                                      .withValues(alpha: 0.5),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                ),
                                                child: Text(
                                                  nomeCat,
                                                  style: TextStyle(
                                                    fontSize: 11.5,
                                                    color: colorScheme.onSurface
                                                        .withValues(alpha: 0.8),
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                          if (nomiCategorie.length > 5) ...[
                                            const SizedBox(height: 4.0),
                                            Text(
                                              '+ altre ${nomiCategorie.length - 5} categorie',
                                              style: TextStyle(
                                                fontSize: 11.0,
                                                fontStyle: FontStyle.italic,
                                                color: theme.hintColor,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
              ),
            );
          },
        );
      },
    );
  }
}
