import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/components/comp_add_category_widget.dart';
import '/components/menu_profilo_widget.dart';
import '/components/nav_bar_dinamica_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/custom_functions.dart' as functions;
import '/services/cestino_service.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'home_ristoratore_model.dart';
export 'home_ristoratore_model.dart';

/// Pagina principale del ristoratore
class HomeRistoratoreWidget extends StatefulWidget {
  const HomeRistoratoreWidget({
    super.key,
    required this.ristoranteRef,
  });

  final DocumentReference? ristoranteRef;

  static String routeName = 'home_ristoratore';
  static String routePath = '/homeRistoratore';

  @override
  State<HomeRistoratoreWidget> createState() => _HomeRistoratoreWidgetState();
}

class _HomeRistoratoreWidgetState extends State<HomeRistoratoreWidget> {
  late HomeRistoratoreModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HomeRistoratoreModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      if (valueOrDefault<bool>(currentUserDocument?.isPremium, false) ==
          false) {
        context.pushNamed(AbbonamentoWidget.routeName);
      }
      // Pulizia automatica dei piatti cestinati scaduti (> 7 giorni)
      await CestinoService.pulisciPiattiScaduti(
        ristoranteRef: currentUserReference,
      );
    });

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

    return StreamBuilder<UsersRecord>(
      stream: UsersRecord.getDocument(widget.ristoranteRef!),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Scaffold(
            body: Center(
              child: SizedBox(
                width: 50.0,
                height: 50.0,
                child: SpinKitPulse(
                  color: theme.colorScheme.primary,
                  size: 50.0,
                ),
              ),
            ),
          );
        }

        return GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Scaffold(
            key: scaffoldKey,
            endDrawer: Drawer(
              width: 320.0,
              backgroundColor: Colors.transparent,
              elevation: 0.0,
              child: wrapWithModel(
                model: _model.menuProfiloModel,
                updateCallback: () => safeSetState(() {}),
                child: MenuProfiloWidget(
                  ristoranteRef: widget.ristoranteRef!,
                ),
              ),
            ),
            appBar: (functions.isPremiumAttivo(
                      valueOrDefault<bool>(
                          currentUserDocument?.isPremium, false),
                      currentUserDocument?.premiumExpiryDate) ??
                  false)
                ? PreferredSize(
                    preferredSize: const Size.fromHeight(68.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        border: Border(
                          bottom: BorderSide(
                            color: theme.dividerColor.withValues(alpha: 0.15),
                            width: 1.0,
                          ),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 4.0,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: SafeArea(
                        child: Center(
                          child: ConstrainedBox(
                            constraints:
                                const BoxConstraints(maxWidth: 960.0),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      RichText(
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text: 'Pronto',
                                              style: theme.textTheme.titleLarge?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            TextSpan(
                                              text: 'Menu',
                                              style: theme.textTheme.titleLarge?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: theme.colorScheme.primary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 12.0),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0,
                                          vertical: 3.0,
                                        ),
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.primary
                                              .withValues(alpha: 0.1),
                                          borderRadius:
                                              BorderRadius.circular(6.0),
                                        ),
                                        child: Text(
                                          'Ristoratore',
                                          style: theme.textTheme.labelSmall?.copyWith(
                                            color: theme.colorScheme.primary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  StreamBuilder<List<TicketsRecord>>(
                                    stream: queryTicketsRecord(
                                      queryBuilder: (q) => q.where(
                                        'ristoratore_ref',
                                        isEqualTo: currentUserReference,
                                      ),
                                    ),
                                    builder: (context, snapshot) {
                                      final hasUnreadReply =
                                          (snapshot.data ?? []).any(
                                        (t) =>
                                            t.rispostaAdmin.trim().isNotEmpty &&
                                            !t.rispostaLetta,
                                      );

                                      return Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          borderRadius:
                                              BorderRadius.circular(12.0),
                                          hoverColor: theme.colorScheme.primary
                                              .withValues(alpha: 0.1),
                                          onTap: () {
                                            scaffoldKey.currentState!
                                                .openEndDrawer();
                                          },
                                          child: Container(
                                            width: 40.0,
                                            height: 40.0,
                                            decoration: BoxDecoration(
                                              color: theme.colorScheme.primary
                                                  .withValues(alpha: 0.08),
                                              borderRadius:
                                                  BorderRadius.circular(12.0),
                                              border: Border.all(
                                                color: theme.dividerColor
                                                    .withValues(alpha: 0.15),
                                                width: 1.0,
                                              ),
                                            ),
                                            child: Stack(
                                              alignment: Alignment.center,
                                              clipBehavior: Clip.none,
                                              children: [
                                                Icon(
                                                  Icons.grid_view_rounded,
                                                  color:
                                                      theme.colorScheme.primary,
                                                  size: 22.0,
                                                ),
                                                if (hasUnreadReply)
                                                  Positioned(
                                                    top: -2.0,
                                                    right: -2.0,
                                                    child: Container(
                                                      width: 16.0,
                                                      height: 16.0,
                                                      decoration: BoxDecoration(
                                                        color: const Color(
                                                            0xFFEF4444),
                                                        shape: BoxShape.circle,
                                                        border: Border.all(
                                                          color:
                                                              theme.cardColor,
                                                          width: 2.0,
                                                        ),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: const Color(
                                                                    0xFFEF4444)
                                                                .withValues(
                                                                    alpha: 0.4),
                                                            blurRadius: 4.0,
                                                            offset:
                                                                const Offset(
                                                                    0, 1),
                                                          ),
                                                        ],
                                                      ),
                                                      alignment:
                                                          Alignment.center,
                                                      child: const Text(
                                                        '!',
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 9.5,
                                                          fontWeight:
                                                              FontWeight.w900,
                                                          height: 1.0,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                : null,
            body: SafeArea(
              top: false,
              child: Builder(
                builder: (context) {
                  if (functions.isPremiumAttivo(
                          valueOrDefault<bool>(
                              currentUserDocument?.isPremium, false),
                          currentUserDocument?.premiumExpiryDate) ??
                      false) {
                    return Stack(
                      children: [
                        Align(
                          alignment: Alignment.topCenter,
                          child: ConstrainedBox(
                            constraints:
                                const BoxConstraints(maxWidth: 860.0),
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.fromLTRB(
                                  20.0, 24.0, 20.0, 110.0),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.stretch,
                                children: [
                                  // Welcome / Hero section
                                  Container(
                                    padding: const EdgeInsets.all(20.0),
                                    decoration: BoxDecoration(
                                      color: theme.cardColor,
                                      borderRadius:
                                          BorderRadius.circular(16.0),
                                      border: Border.all(
                                        color: theme.dividerColor
                                            .withValues(alpha: 0.15),
                                        width: 1.0,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black
                                              .withValues(alpha: 0.03),
                                          blurRadius: 8.0,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Ciao ${currentUserDisplayName.isNotEmpty ? currentUserDisplayName : 'Ristoratore'} 👋',
                                                style: theme.textTheme.headlineSmall?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  letterSpacing: -0.3,
                                                ),
                                              ),
                                              const SizedBox(height: 6.0),
                                              Text(
                                                'Ecco cosa succede oggi nel tuo menu',
                                                style: theme.textTheme.bodyMedium?.copyWith(
                                                  color: theme.textTheme.bodySmall?.color,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12.0, vertical: 7.0),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF10B981)
                                                .withValues(alpha: 0.12),
                                            borderRadius:
                                                BorderRadius.circular(20.0),
                                            border: Border.all(
                                              color: const Color(0xFF10B981)
                                                  .withValues(alpha: 0.25),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                width: 8.0,
                                                height: 8.0,
                                                decoration:
                                                    const BoxDecoration(
                                                  color: Color(0xFF10B981),
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                              const SizedBox(width: 7.0),
                                              Text(
                                                'Menu Attivo',
                                                style: theme.textTheme.labelMedium?.copyWith(
                                                  color: const Color(0xFF047857),
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16.0),

                                  // Action banner: Crea nuove categorie
                                  Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius:
                                          BorderRadius.circular(16.0),
                                      hoverColor: theme.dividerColor
                                          .withValues(alpha: 0.08),
                                      onTap: () async {
                                        await showModalBottomSheet(
                                          isScrollControlled: true,
                                          backgroundColor: Colors.transparent,
                                          barrierColor: Colors.black
                                              .withValues(alpha: 0.35),
                                          context: context,
                                          builder: (sheetContext) {
                                            return GestureDetector(
                                              behavior: HitTestBehavior.translucent,
                                              onTap: () {
                                                Navigator.of(sheetContext).pop();
                                              },
                                              child: Padding(
                                                padding:
                                                    MediaQuery.viewInsetsOf(
                                                        sheetContext),
                                                child: Center(
                                                  child: GestureDetector(
                                                    behavior: HitTestBehavior.opaque,
                                                    onTap: () {
                                                      FocusScope.of(sheetContext)
                                                          .unfocus();
                                                      FocusManager
                                                          .instance.primaryFocus
                                                          ?.unfocus();
                                                    },
                                                    child: ConstrainedBox(
                                                      constraints:
                                                          const BoxConstraints(
                                                              maxWidth: 550.0),
                                                      child: SizedBox(
                                                        height: MediaQuery.sizeOf(
                                                                    sheetContext)
                                                                .height *
                                                            0.42,
                                                        child:
                                                            CompAddCategoryWidget(
                                                          ristoranteRef: widget
                                                              .ristoranteRef,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ).then((value) => safeSetState(() {}));
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(18.0),
                                        decoration: BoxDecoration(
                                          color: theme.cardColor,
                                          borderRadius:
                                              BorderRadius.circular(16.0),
                                          border: Border.all(
                                            color: theme.colorScheme.primary
                                                .withValues(alpha: 0.25),
                                            width: 1.5,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black
                                                  .withValues(alpha: 0.03),
                                              blurRadius: 8.0,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 48.0,
                                              height: 48.0,
                                              decoration: BoxDecoration(
                                                color: theme.colorScheme.primary
                                                    .withValues(alpha: 0.12),
                                                borderRadius:
                                                    BorderRadius.circular(12.0),
                                              ),
                                              child: Icon(
                                                Icons.add_circle_outline_rounded,
                                                color: theme.colorScheme.primary,
                                                size: 26.0,
                                              ),
                                            ),
                                            const SizedBox(width: 16.0),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Crea le tue categorie',
                                                    style: theme.textTheme.titleMedium?.copyWith(
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 3.0),
                                                  Text(
                                                    'Inizia aggiungendo una categoria come \'Antipasti\' o \'Pizze\' per organizzare i tuoi piatti',
                                                    style: theme.textTheme.bodySmall?.copyWith(
                                                      height: 1.3,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 12.0),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 14.0,
                                                vertical: 8.0,
                                              ),
                                              decoration: BoxDecoration(
                                                color:
                                                    theme.colorScheme.primary,
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(
                                                    Icons.add_rounded,
                                                    color: Colors.white,
                                                    size: 18.0,
                                                  ),
                                                  const SizedBox(width: 4.0),
                                                  Text(
                                                    'Aggiungi',
                                                    style: theme.textTheme.labelMedium?.copyWith(
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 24.0),

                                  // Categories Section
                                  StreamBuilder<List<CategoriesRecord>>(
                                    stream: queryCategoriesRecord(
                                      queryBuilder: (categoriesRecord) =>
                                          categoriesRecord.where(
                                        'proprietario',
                                        isEqualTo: widget.ristoranteRef,
                                      ),
                                    ),
                                    builder: (context, snapshot) {
                                      if (!snapshot.hasData) {
                                        return Center(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 40.0),
                                            child: SizedBox(
                                              width: 44.0,
                                              height: 44.0,
                                              child: SpinKitPulse(
                                                color: theme.colorScheme.primary,
                                                size: 44.0,
                                              ),
                                            ),
                                          ),
                                        );
                                      }

                                      final categories = snapshot.data!;

                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          // Section Header
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 12.0),
                                            child: Row(
                                              mainAxisAlignment:
                                                MainAxisAlignment
                                                    .spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons
                                                          .restaurant_menu_rounded,
                                                      color: theme.colorScheme.primary,
                                                      size: 20.0,
                                                    ),
                                                    const SizedBox(width: 8.0),
                                                    Text(
                                                      'Le tue categorie',
                                                      style: theme.textTheme.titleMedium?.copyWith(
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 10.0,
                                                    vertical: 4.0,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: theme.dividerColor
                                                        .withValues(
                                                            alpha: 0.1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12.0),
                                                  ),
                                                  child: Text(
                                                    '${categories.length} ${categories.length == 1 ? 'categoria' : 'categorie'}',
                                                    style: theme.textTheme.labelSmall?.copyWith(
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),

                                          // Cards List or Empty State
                                          if (categories.isEmpty)
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                vertical: 48.0,
                                                horizontal: 24.0,
                                              ),
                                              decoration: BoxDecoration(
                                                color: theme.cardColor,
                                                borderRadius:
                                                    BorderRadius.circular(16.0),
                                                border: Border.all(
                                                  color: theme.dividerColor
                                                      .withValues(alpha: 0.15),
                                                  width: 1.0,
                                                ),
                                              ),
                                              child: Column(
                                                children: [
                                                  Container(
                                                    width: 60.0,
                                                    height: 60.0,
                                                    decoration: BoxDecoration(
                                                      color: theme.colorScheme.primary
                                                      .withValues(
                                                          alpha: 0.1),
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: Icon(
                                                      Icons.menu_book_rounded,
                                                      color: theme.colorScheme.primary,
                                                      size: 30.0,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 14.0),
                                                  Text(
                                                    'Nessuna categoria presente',
                                                    style: theme.textTheme.titleMedium?.copyWith(
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 6.0),
                                                  Text(
                                                    'Crea la tua prima categoria per iniziare ad inserire i piatti.',
                                                    textAlign:
                                                        TextAlign.center,
                                                    style: theme.textTheme.bodySmall,
                                                  ),
                                                ],
                                              ),
                                            )
                                          else
                                            ListView.separated(
                                              padding: EdgeInsets.zero,
                                              primary: false,
                                              shrinkWrap: true,
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              itemCount: categories.length,
                                              separatorBuilder:
                                                  (context, index) =>
                                                      const SizedBox(
                                                          height: 10.0),
                                              itemBuilder:
                                                  (context, listViewIndex) {
                                                final cat =
                                                    categories[listViewIndex];
                                                return Container(
                                                  decoration: BoxDecoration(
                                                    color: theme.cardColor,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            14.0),
                                                    border: Border.all(
                                                      color: theme.dividerColor
                                                          .withValues(
                                                              alpha: 0.15),
                                                      width: 1.0,
                                                    ),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black
                                                            .withValues(
                                                                alpha: 0.03),
                                                        blurRadius: 6.0,
                                                        offset:
                                                            const Offset(0, 2),
                                                      ),
                                                    ],
                                                  ),
                                                  child: Material(
                                                    color: Colors.transparent,
                                                    child: InkWell(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              14.0),
                                                      hoverColor: theme.dividerColor
                                                          .withValues(
                                                              alpha: 0.08),
                                                      onTap: () async {
                                                        context.pushNamed(
                                                          ListaPiattiWidget
                                                              .routeName,
                                                          queryParameters: {
                                                            'nomeCategoria':
                                                                serializeParam(
                                                              cat.name,
                                                              ParamType
                                                                  .String,
                                                            ),
                                                            'categoriaAttuale':
                                                                serializeParam(
                                                              cat.reference,
                                                              ParamType
                                                                  .DocumentReference,
                                                            ),
                                                            'ristoranteRef':
                                                                serializeParam(
                                                              widget
                                                                  .ristoranteRef,
                                                              ParamType
                                                                  .DocumentReference,
                                                            ),
                                                          }.withoutNulls,
                                                        );
                                                      },
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                          horizontal: 16.0,
                                                          vertical: 14.0,
                                                        ),
                                                        child: Row(
                                                          children: [
                                                            Container(
                                                              width: 42.0,
                                                              height: 42.0,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: theme.colorScheme.primary
                                                                    .withValues(
                                                                        alpha:
                                                                            0.10),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10.0),
                                                              ),
                                                              child: Icon(
                                                                Icons
                                                                    .restaurant_rounded,
                                                                color: theme.colorScheme.primary,
                                                                size: 20.0,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                                width: 14.0),
                                                            Expanded(
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Text(
                                                                    cat.name,
                                                                    style: theme.textTheme.titleMedium?.copyWith(
                                                                      fontWeight: FontWeight.bold,
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                      height:
                                                                          2.0),
                                                                  Text(
                                                                    'Tocca per gestire i piatti della categoria',
                                                                    style: theme.textTheme.bodySmall,
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            Container(
                                                              width: 32.0,
                                                              height: 32.0,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: theme.dividerColor
                                                                    .withValues(
                                                                        alpha:
                                                                            0.1),
                                                                shape: BoxShape
                                                                    .circle,
                                                              ),
                                                              child: Icon(
                                                                Icons
                                                                    .chevron_right_rounded,
                                                                color: theme.iconTheme.color?.withValues(alpha: 0.6) ??
                                                                    theme.dividerColor.withValues(alpha: 0.8),
                                                                size: 20.0,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                        ],
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Align(
                          alignment: AlignmentDirectional(0.0, 1.0),
                          child: wrapWithModel(
                            model: _model.navBarDinamicaModel,
                            updateCallback: () => safeSetState(() {}),
                            child: NavBarDinamicaWidget(
                              paginaAttiva: 1,
                              ristoranteRef: widget.ristoranteRef,
                            ),
                          ),
                        ),
                      ],
                    );
                  } else {
                    return Align(
                      alignment: AlignmentDirectional(0.0, 0.0),
                      child: Container(
                        width: double.infinity,
                        height: double.infinity,
                        alignment: AlignmentDirectional(0.0, 0.0),
                        child: Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              24.0, 0.0, 24.0, 0.0),
                          child: SingleChildScrollView(
                            controller: _model.columnController,
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      0.0, 0.0, 0.0, 16.0),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: Image.network(
                                      'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/pronto-menu-f0och1/assets/i4ccmvv80eni/IMG_8006.png',
                                      width: 200.0,
                                      height: 200.0,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      0.0, 0.0, 0.0, 8.0),
                                  child: Text(
                                    'Sblocca il tuo menu',
                                    style: theme.textTheme.headlineMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      0.0, 0.0, 0.0, 32.0),
                                  child: Text(
                                    'Il tuo abbonamento non è attivo.\nAbbonati ora per ricevere ordini \ne gestire il tuo ristorante senza limiti.',
                                    textAlign: TextAlign.center,
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                ),
                                FFButtonWidget(
                                  onPressed: () async {
                                    context
                                        .pushNamed(AbbonamentoWidget.routeName);
                                  },
                                  text: 'Abbonati',
                                  options: FFButtonOptions(
                                    width: 280.0,
                                    height: 50.0,
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        16.0, 0.0, 16.0, 0.0),
                                    iconAlignment: IconAlignment.end,
                                    iconPadding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 0.0, 0.0, 0.0),
                                    elevation: 0.0,
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
