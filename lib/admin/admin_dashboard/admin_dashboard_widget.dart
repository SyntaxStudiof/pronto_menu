import '/admin/admin_drawer_menu/admin_drawer_menu_widget.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart' as gorouter;
import 'package:provider/provider.dart';
import 'admin_dashboard_model.dart';
export 'admin_dashboard_model.dart';

class AdminDashboardWidget extends StatefulWidget {
  const AdminDashboardWidget({
    super.key,
    this.embedded = false,
  });

  final bool embedded;

  static String routeName = 'AdminDashboard';
  static String routePath = '/adminDashboard';

  @override
  State<AdminDashboardWidget> createState() => _AdminDashboardWidgetState();
}

class _AdminDashboardWidgetState extends State<AdminDashboardWidget> {
  late AdminDashboardModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AdminDashboardModel());

    _model.barraRicercaTextController ??= TextEditingController();
    _model.barraRicercaFocusNode ??= FocusNode();

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

    return StreamBuilder<List<UsersRecord>>(
      stream: queryUsersRecord(
        queryBuilder: (usersRecord) => usersRecord.where(
          'isAdmin',
          isEqualTo: false,
        ),
      ),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Errore caricamento dati: ${snapshot.error}',
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }

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
        List<UsersRecord> adminDashboardUsersRecordList = snapshot.data!;

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
                model: _model.adminDrawerMenuModel,
                updateCallback: () => safeSetState(() {}),
                child: const AdminDrawerMenuWidget(),
              ),
            ),
            appBar: widget.embedded
                ? null
                : AppBar(
              automaticallyImplyLeading: false,
              leading: const SizedBox(width: 48.0),
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 36.0,
                    height: 36.0,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.admin_panel_settings_rounded,
                      color: theme.colorScheme.primary,
                      size: 20.0,
                    ),
                  ),
                  const SizedBox(width: 10.0),
                  Text(
                    'Dashboard Admin',
                    style: theme.appBarTheme.titleTextStyle ??
                        theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 19.0,
                          letterSpacing: -0.4,
                        ),
                  ),
                ],
              ),
              actions: [
                StreamBuilder<List<TicketsRecord>>(
                  stream: queryTicketsRecord(),
                  builder: (context, snapshot) {
                    final apertiCount = snapshot.hasData
                        ? snapshot.data!.where((t) {
                            final s = t.stato.trim().toLowerCase();
                            return s == 'aperto' || s.isEmpty;
                          }).length
                        : 0;

                    return IconButton(
                      icon: Badge(
                        isLabelVisible: apertiCount > 0,
                        backgroundColor: const Color(0xFFEF4444),
                        label: Text(
                          apertiCount > 99 ? '99+' : apertiCount.toString(),
                          style: const TextStyle(
                            fontSize: 10.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        child: const Icon(
                          Icons.menu_rounded,
                          size: 24.0,
                        ),
                      ),
                      onPressed: () => scaffoldKey.currentState?.openEndDrawer(),
                    );
                  },
                ),
              ],
              centerTitle: true,
              elevation: 0.0,
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(1.0),
                child: Divider(
                  height: 1.0,
                  thickness: 1.0,
                  color: theme.dividerColor.withValues(alpha: 0.5),
                ),
              ),
            ),
            body: SafeArea(
              top: true,
              child: Align(
                alignment: const AlignmentDirectional(0.0, -1.0),
                child: SingleChildScrollView(
                  controller: _model.columnController,
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 28.0),
                  child: Center(
                    child: Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(maxWidth: 720.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24.0),
                            decoration: BoxDecoration(
                              color: theme.cardColor,
                              borderRadius: BorderRadius.circular(20.0),
                              border: Border.all(
                                color: theme.dividerColor.withValues(alpha: 0.6),
                                width: 1.0,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  blurRadius: 20.0,
                                  color: Colors.black.withValues(alpha: 0.04),
                                  offset: const Offset(0.0, 4.0),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Benvenuto Capo \u{1F44B}',
                                        style: theme.textTheme.headlineMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4.0),
                                      Text(
                                        'Gestione e monitoraggio di tutti i ristoranti registrati',
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          color: theme.textTheme.bodySmall?.color ??
                                              theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(14.0),
                                    border: Border.all(
                                      color: theme.colorScheme.primary.withValues(alpha: 0.20),
                                      width: 1.0,
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        formatNumber(
                                          adminDashboardUsersRecordList.length,
                                          formatType: FormatType.compact,
                                        ),
                                        style: theme.textTheme.headlineSmall?.copyWith(
                                          color: theme.colorScheme.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        'Ristoranti',
                                        style: theme.textTheme.labelMedium?.copyWith(
                                          color: theme.colorScheme.primary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16.0),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFFF59E0B).withValues(alpha: 0.12),
                                  const Color(0xFF8B5CF6).withValues(alpha: 0.08),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(18.0),
                              border: Border.all(
                                color: const Color(0xFFF59E0B).withValues(alpha: 0.28),
                                width: 1.0,
                              ),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(18.0),
                                onTap: () => context.pushNamed(AdminMetricheWidget.routeName),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 14.0),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 44.0,
                                        height: 44.0,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF59E0B).withValues(alpha: 0.20),
                                          borderRadius: BorderRadius.circular(12.0),
                                        ),
                                        alignment: Alignment.center,
                                        child: const Icon(
                                          Icons.insights_rounded,
                                          color: Color(0xFFD97706),
                                          size: 24.0,
                                        ),
                                      ),
                                      const SizedBox(width: 14.0),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Metriche del Business & Costi Server',
                                              style: theme.textTheme.titleSmall?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15.0,
                                              ),
                                            ),
                                            const SizedBox(height: 2.0),
                                            Text(
                                              'Ristoranti attivi oggi, utenti registrati e spazio GB foto Firebase',
                                              style: theme.textTheme.bodySmall?.copyWith(
                                                color: theme.textTheme.bodySmall?.color ??
                                                    theme.colorScheme.onSurface.withValues(alpha: 0.65),
                                                fontSize: 12.0,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8.0),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFD97706),
                                          borderRadius: BorderRadius.circular(10.0),
                                        ),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              'Vedi',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12.0,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(width: 4.0),
                                            Icon(
                                              Icons.arrow_forward_rounded,
                                              color: Colors.white,
                                              size: 14.0,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12.0),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFF3B82F6).withValues(alpha: 0.12),
                                  const Color(0xFF06B6D4).withValues(alpha: 0.08),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(18.0),
                              border: Border.all(
                                color: const Color(0xFF3B82F6).withValues(alpha: 0.28),
                                width: 1.0,
                              ),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(18.0),
                                onTap: () => context.pushNamed(AdminCronologiaAzioniWidget.routeName),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 14.0),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 44.0,
                                        height: 44.0,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF3B82F6).withValues(alpha: 0.20),
                                          borderRadius: BorderRadius.circular(12.0),
                                        ),
                                        alignment: Alignment.center,
                                        child: const Icon(
                                          Icons.manage_history_rounded,
                                          color: Color(0xFF2563EB),
                                          size: 24.0,
                                        ),
                                      ),
                                      const SizedBox(width: 14.0),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Cronologia Azioni (Audit Log)',
                                              style: theme.textTheme.titleSmall?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15.0,
                                              ),
                                            ),
                                            const SizedBox(height: 2.0),
                                            Text(
                                              'Tracciamento eliminazioni e modifiche piatti/categorie',
                                              style: theme.textTheme.bodySmall?.copyWith(
                                                color: theme.textTheme.bodySmall?.color ??
                                                    theme.colorScheme.onSurface.withValues(alpha: 0.65),
                                                fontSize: 12.0,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8.0),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF2563EB),
                                          borderRadius: BorderRadius.circular(10.0),
                                        ),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              'Vedi',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12.0,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(width: 4.0),
                                            Icon(
                                              Icons.arrow_forward_rounded,
                                              color: Colors.white,
                                              size: 14.0,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20.0),
                          Container(
                            decoration: BoxDecoration(
                              color: theme.cardColor,
                              borderRadius: BorderRadius.circular(16.0),
                              border: Border.all(
                                color: theme.dividerColor.withValues(alpha: 0.6),
                                width: 1.0,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  blurRadius: 14.0,
                                  color: Colors.black.withValues(alpha: 0.03),
                                  offset: const Offset(0.0, 3.0),
                                ),
                              ],
                            ),
                            child: TextFormField(
                              controller: _model.barraRicercaTextController,
                              focusNode: _model.barraRicercaFocusNode,
                              onChanged: (_) => EasyDebounce.debounce(
                                '_model.barraRicercaTextController',
                                const Duration(milliseconds: 400),
                                () => safeSetState(() {}),
                              ),
                              autofocus: false,
                              enabled: true,
                              obscureText: false,
                              decoration: InputDecoration(
                                isDense: false,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                                prefixIcon: Icon(
                                  Icons.search_rounded,
                                  color: theme.colorScheme.primary,
                                  size: 22.0,
                                ),
                                suffixIcon: (_model.barraRicercaTextController?.text.isNotEmpty ?? false)
                                    ? IconButton(
                                        icon: const Icon(Icons.clear_rounded, size: 20.0),
                                        onPressed: () {
                                          _model.barraRicercaTextController?.clear();
                                          safeSetState(() {});
                                        },
                                      )
                                    : null,
                                hintText: 'Cerca per email o nome ristorante...',
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                focusedErrorBorder: InputBorder.none,
                                filled: false,
                              ),
                              style: theme.textTheme.bodyMedium,
                              keyboardType: TextInputType.emailAddress,
                              cursorColor: theme.colorScheme.primary,
                              enableInteractiveSelection: true,
                              validator: _model.barraRicercaTextControllerValidator.asValidator(context),
                            ),
                          ),
                          const SizedBox(height: 24.0),
                          Builder(
                            builder: (context) {
                              final utentiFiltrati = functions
                                  .cercaRistoranti(
                                      adminDashboardUsersRecordList.toList(),
                                      _model.barraRicercaTextController.text)
                                  .toList();

                              if (utentiFiltrati.isEmpty) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
                                  decoration: BoxDecoration(
                                    color: theme.cardColor,
                                    borderRadius: BorderRadius.circular(20.0),
                                    border: Border.all(
                                      color: theme.dividerColor.withValues(alpha: 0.6),
                                      width: 1.0,
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 64.0,
                                        height: 64.0,
                                        decoration: BoxDecoration(
                                          color: theme.dividerColor.withValues(alpha: 0.2),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.storefront_outlined,
                                          size: 32.0,
                                          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                                        ),
                                      ),
                                      const SizedBox(height: 16.0),
                                      Text(
                                        'Nessun ristorante trovato',
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 6.0),
                                      Text(
                                        'Prova a modificare i termini di ricerca',
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }

                              return ListView.separated(
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                scrollDirection: Axis.vertical,
                                itemCount: utentiFiltrati.length,
                                separatorBuilder: (context, _) => const SizedBox(height: 12.0),
                                itemBuilder: (context, utentiFiltratiIndex) {
                                  final utentiFiltratiItem = utentiFiltrati[utentiFiltratiIndex];
                                  final initialLetter = utentiFiltratiItem.displayName.isNotEmpty
                                      ? utentiFiltratiItem.displayName[0].toUpperCase()
                                      : 'R';

                                  return Container(
                                    decoration: BoxDecoration(
                                      color: theme.cardColor,
                                      borderRadius: BorderRadius.circular(16.0),
                                      border: Border.all(
                                        color: theme.dividerColor.withValues(alpha: 0.6),
                                        width: 1.0,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          blurRadius: 10.0,
                                          color: Colors.black.withValues(alpha: 0.03),
                                          offset: const Offset(0.0, 2.0),
                                        ),
                                      ],
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      borderRadius: BorderRadius.circular(16.0),
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(16.0),
                                        onTap: () async {
                                          context.pushNamed(
                                            AdminDettaglioRistoranteWidget.routeName,
                                            queryParameters: {
                                              'utenteRef': serializeParam(
                                                utentiFiltratiItem.reference,
                                                ParamType.DocumentReference,
                                              ),
                                            }.withoutNulls,
                                          );
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 44.0,
                                                height: 44.0,
                                                decoration: BoxDecoration(
                                                  color: theme.colorScheme.primary.withValues(alpha: 0.12),
                                                  borderRadius: BorderRadius.circular(12.0),
                                                ),
                                                alignment: Alignment.center,
                                                child: utentiFiltratiItem.photoUrl.isNotEmpty
                                                    ? ClipRRect(
                                                        borderRadius: BorderRadius.circular(12.0),
                                                        child: Image.network(
                                                          utentiFiltratiItem.photoUrl,
                                                          width: 44.0,
                                                          height: 44.0,
                                                          fit: BoxFit.cover,
                                                          errorBuilder: (_, __, ___) => Text(
                                                            initialLetter,
                                                            style: theme.textTheme.titleMedium?.copyWith(
                                                              color: theme.colorScheme.primary,
                                                              fontWeight: FontWeight.bold,
                                                            ),
                                                          ),
                                                        ),
                                                      )
                                                    : Text(
                                                        initialLetter,
                                                        style: theme.textTheme.titleMedium?.copyWith(
                                                          color: theme.colorScheme.primary,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                              ),
                                              const SizedBox(width: 14.0),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      utentiFiltratiItem.displayName.isNotEmpty
                                                          ? utentiFiltratiItem.displayName
                                                          : 'Ristorante senza nome',
                                                      style: theme.textTheme.titleSmall?.copyWith(
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 2.0),
                                                    Text(
                                                      utentiFiltratiItem.email,
                                                      style: theme.textTheme.bodyMedium?.copyWith(
                                                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(width: 10.0),
                                              Container(
                                                width: 32.0,
                                                height: 32.0,
                                                decoration: BoxDecoration(
                                                  color: theme.dividerColor.withValues(alpha: 0.2),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Icon(
                                                  Icons.chevron_right_rounded,
                                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
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
          ),
        );
      },
    );
  }
}