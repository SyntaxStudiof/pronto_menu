import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:badges/badges.dart' as badges;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'nav_bar_dinamica_model.dart';
export 'nav_bar_dinamica_model.dart';

class NavBarDinamicaWidget extends StatefulWidget {
  const NavBarDinamicaWidget({
    super.key,
    required this.paginaAttiva,
    this.ristoranteRef,
  });

  final int? paginaAttiva;
  final DocumentReference? ristoranteRef;

  @override
  State<NavBarDinamicaWidget> createState() => _NavBarDinamicaWidgetState();
}

class _NavBarDinamicaWidgetState extends State<NavBarDinamicaWidget> {
  late NavBarDinamicaModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => NavBarDinamicaModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  void _mostraUpgradePlus(BuildContext context, String featureName) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (bContext) => Container(
        padding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 32.0),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24.0),
            topRight: Radius.circular(24.0),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50.0,
              height: 50.0,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.lock_rounded,
                color: theme.colorScheme.primary,
                size: 26.0,
              ),
            ),
            const SizedBox(height: 14.0),
            Text(
              'Funzionalità ProntoMenu Plus & Ultra',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              '$featureName è inclusa nei piani Plus e Ultra.\nPassa a Plus a soli 11,90€/mese per sbloccarla subito!',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.hintColor,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 20.0),
            SizedBox(
              width: double.infinity,
              height: 48.0,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(bContext);
                  context.pushNamed(AbbonamentoWidget.routeName);
                },
                icon: const Icon(Icons.arrow_upward_rounded, size: 18.0),
                label: const Text('Scopri i Piani & Esegui Upgrade'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();
    final theme = Theme.of(context);
    final activeColor = theme.colorScheme.primary;
    final inactiveColor = theme.unselectedWidgetColor != null
        ? theme.unselectedWidgetColor!
        : theme.dividerColor.withValues(alpha: 0.6);

    return Stack(
      children: [
        Container(
          height: 70.0,
          decoration: BoxDecoration(
            color: theme.cardColor,
            border: Border(
              top: BorderSide(
                color: theme.dividerColor.withValues(alpha: 0.1),
                width: 1.0,
              ),
            ),
            boxShadow: [
              BoxShadow(
                blurRadius: 10.0,
                color: Colors.black.withValues(alpha: 0.05),
                offset: const Offset(0.0, -2.0),
              )
            ],
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16.0),
              topRight: Radius.circular(16.0),
            ),
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680.0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: InkWell(
                      splashColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () async {
                        context.goNamed(
                          HomeRistoratoreWidget.routeName,
                          queryParameters: {
                            'ristoranteRef': serializeParam(
                              widget.ristoranteRef,
                              ParamType.DocumentReference,
                            ),
                          }.withoutNulls,
                          extra: <String, dynamic>{
                            '__transition_info__': const TransitionInfo(
                              hasTransition: true,
                              transitionType: PageTransitionType.fade,
                              duration: Duration(milliseconds: 0),
                            ),
                          },
                        );
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.home_outlined,
                            color: widget.paginaAttiva == 1
                                ? activeColor
                                : inactiveColor,
                            size: 24.0,
                          ),
                          Text(
                            'Home',
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: widget.paginaAttiva == 1
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              color: widget.paginaAttiva == 1
                                  ? activeColor
                                  : inactiveColor,
                            ),
                          ),
                        ].divide(const SizedBox(height: 5.0)),
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      splashColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () async {
                        if (currentUserDocument != null && !currentUserDocument!.hasPlus) {
                          _mostraUpgradePlus(context, 'La gestione Cucina e comande in tempo reale');
                          return;
                        }
                        context.goNamed(
                          DashboardRistoranteWidget.routeName,
                          queryParameters: {
                            'ristoranteRef': serializeParam(
                              widget.ristoranteRef,
                              ParamType.DocumentReference,
                            ),
                          }.withoutNulls,
                          extra: <String, dynamic>{
                            '__transition_info__': const TransitionInfo(
                              hasTransition: true,
                              transitionType: PageTransitionType.fade,
                              duration: Duration(milliseconds: 0),
                            ),
                          },
                        );
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          StreamBuilder<List<OrdersRecord>>(
                            stream: queryOrdersRecord(
                              queryBuilder: (ordersRecord) => ordersRecord
                                  .where(
                                    'visto',
                                    isEqualTo: false,
                                  )
                                  .where(
                                    'stato_ordine',
                                    isEqualTo: 'in_attesa',
                                  ),
                            ),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return Center(
                                  child: SizedBox(
                                    width: 24.0,
                                    height: 24.0,
                                    child: SpinKitPulse(
                                      color: theme.colorScheme.primary,
                                      size: 24.0,
                                    ),
                                  ),
                                );
                              }
                              List<OrdersRecord> containerOrdersRecordList =
                                  snapshot.data!;

                              return Container(
                                decoration: const BoxDecoration(),
                                child: badges.Badge(
                                  badgeContent: const Text(''),
                                  showBadge:
                                      (containerOrdersRecordList.isNotEmpty) &&
                                          (widget.paginaAttiva != 2),
                                  shape: badges.BadgeShape.circle,
                                  badgeColor: theme.colorScheme.error,
                                  elevation: 2.0,
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      6.0, 6.0, 6.0, 6.0),
                                  position: badges.BadgePosition.topEnd(),
                                  animationType:
                                      badges.BadgeAnimationType.scale,
                                  toAnimate: true,
                                  child: Icon(
                                    Icons.restaurant_rounded,
                                    color: widget.paginaAttiva == 2
                                        ? activeColor
                                        : inactiveColor,
                                    size: 24.0,
                                  ),
                                ),
                              );
                            },
                          ),
                          Text(
                            'Lista ordini',
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: widget.paginaAttiva == 2
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              color: widget.paginaAttiva == 2
                                  ? activeColor
                                  : inactiveColor,
                            ),
                          ),
                        ].divide(const SizedBox(height: 5.0)),
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      splashColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () async {
                        if (currentUserDocument != null && !currentUserDocument!.hasPlus) {
                          _mostraUpgradePlus(context, 'La cassa e lo storico comande completate');
                          return;
                        }
                        context.goNamed(
                          StoricoOrdiniWidget.routeName,
                          queryParameters: {
                            'ristoranteRef': serializeParam(
                              widget.ristoranteRef,
                              ParamType.DocumentReference,
                            ),
                          }.withoutNulls,
                          extra: <String, dynamic>{
                            '__transition_info__': const TransitionInfo(
                              hasTransition: true,
                              transitionType: PageTransitionType.fade,
                              duration: Duration(milliseconds: 0),
                            ),
                          },
                        );
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          StreamBuilder<List<OrdersRecord>>(
                            stream: queryOrdersRecord(
                              queryBuilder: (ordersRecord) => ordersRecord
                                  .where(
                                    'visto',
                                    isEqualTo: false,
                                  )
                                  .where(
                                    'stato_ordine',
                                    isEqualTo: 'Completato',
                                  ),
                            ),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return Center(
                                  child: SizedBox(
                                    width: 24.0,
                                    height: 24.0,
                                    child: SpinKitPulse(
                                      color: theme.colorScheme.primary,
                                      size: 24.0,
                                    ),
                                  ),
                                );
                              }
                              List<OrdersRecord> containerOrdersRecordList =
                                  snapshot.data!;

                              return Container(
                                decoration: const BoxDecoration(),
                                child: badges.Badge(
                                  badgeContent: const Text(''),
                                  showBadge:
                                      (containerOrdersRecordList.isNotEmpty) &&
                                          (widget.paginaAttiva != 3),
                                  shape: badges.BadgeShape.circle,
                                  badgeColor: theme.colorScheme.error,
                                  elevation: 2.0,
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      6.0, 6.0, 6.0, 6.0),
                                  position: badges.BadgePosition.topEnd(),
                                  animationType:
                                      badges.BadgeAnimationType.scale,
                                  toAnimate: true,
                                  child: Icon(
                                    Icons.checklist_rounded,
                                    color: widget.paginaAttiva == 3
                                        ? activeColor
                                        : inactiveColor,
                                    size: 24.0,
                                  ),
                                ),
                              );
                            },
                          ),
                          Text(
                            'Completati',
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: widget.paginaAttiva == 3
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              color: widget.paginaAttiva == 3
                                  ? activeColor
                                  : inactiveColor,
                            ),
                          ),
                        ].divide(const SizedBox(height: 5.0)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
