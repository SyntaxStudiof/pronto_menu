import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/components/cestino_vuoto_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/actions/index.dart' as actions;
import '/services/audit_log_service.dart';
import '/services/cestino_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'cestino_model.dart';
export 'cestino_model.dart';

/// qua le pagine rimarrano per 7 ulteriori giorni
class CestinoWidget extends StatefulWidget {
  const CestinoWidget({
    super.key,
    this.embedded = false,
  });

  final bool embedded;

  static String routeName = 'Cestino';
  static String routePath = '/cestino';

  @override
  State<CestinoWidget> createState() => _CestinoWidgetState();
}

class _CestinoWidgetState extends State<CestinoWidget> {
  late CestinoModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CestinoModel());

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await CestinoService.pulisciPiattiScaduti(
        ristoranteRef: currentUserReference,
      );
      if (mounted) safeSetState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _model.dispose();
    super.dispose();
  }

  Future<void> _confermaSvuotaTutto(ThemeData theme) async {
    final confirm = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.error.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.delete_sweep_rounded, color: theme.colorScheme.error, size: 24.0),
                ),
                const SizedBox(width: 12.0),
                const Text('Svuota intero cestino?', style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
              ],
            ),
            content: const Text(
              'Tutti i piatti presenti nel cestino e le relative foto verranno eliminati per sempre dal database.\n\nQuesta azione è irreversibile. Vuoi procedere?',
              style: TextStyle(fontSize: 13.5, height: 1.4),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Annulla'),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.delete_forever_rounded, size: 16.0),
                label: const Text('Elimina tutti'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.error,
                  foregroundColor: Colors.white,
                  elevation: 0.0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                ),
                onPressed: () => Navigator.pop(ctx, true),
              ),
            ],
          ),
        ) ??
        false;

    if (confirm) {
      await actions.svuotaCestinoMassivo(currentUserReference);
      await AuditLogService.logAction(
        azione: "Ha svuotato l'intero cestino",
        dettagli: "Eliminazione definitiva massiva di tutti i piatti presenti nel cestino",
        tipoAzione: 'eliminazione',
        tipoEntita: 'piatto',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cestino svuotato con successo!'),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _ripristinaPiatto(PiattiRecord dish, ThemeData theme) async {
    final dishName = dish.nome;
    await dish.reference.update({
      ...createPiattiRecordData(
        isCestinato: false,
      ),
      ...mapToFirestore({
        'dataCestinamento': FieldValue.delete(),
      }),
    });

    await AuditLogService.logAction(
      azione: "Ha ripristinato dal cestino il piatto '$dishName'",
      dettagli: "Piatto '$dishName' ripristinato nel menu attivo",
      tipoAzione: 'ripristino',
      tipoEntita: 'piatto',
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18.0),
              const SizedBox(width: 8.0),
              Text('Piatto "$dishName" ripristinato nel menù!'),
            ],
          ),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF10B981),
        ),
      );
    }
  }

  Future<void> _eliminaDefinitivamente(PiattiRecord dish, ThemeData theme) async {
    final dishName = dish.nome;
    final confirm = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
            title: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: theme.colorScheme.error, size: 24.0),
                const SizedBox(width: 10.0),
                const Text('Elimina definitivamente', style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
              ],
            ),
            content: Text(
              'Sei sicuro di voler eliminare per sempre "$dishName"?\nIl piatto e la sua foto verranno cancellati in modo permanente e non potranno più essere recuperati.',
              style: const TextStyle(fontSize: 13.5, height: 1.4),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Annulla'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.error,
                  foregroundColor: Colors.white,
                  elevation: 0.0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                ),
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Elimina'),
              ),
            ],
          ),
        ) ??
        false;

    if (confirm) {
      if (dish.foto.isNotEmpty) {
        try {
          await FirebaseStorage.instance.refFromURL(dish.foto).delete();
        } catch (_) {}
      }
      await dish.reference.delete();
      await AuditLogService.logAction(
        azione: "Ha eliminato definitivamente il piatto '$dishName'",
        dettagli: "Eliminazione definitiva dal cestino del piatto '$dishName' e foto da storage",
        tipoAzione: 'eliminazione',
        tipoEntita: 'piatto',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Piatto "$dishName" eliminato definitivamente.'),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        appBar: widget.embedded
            ? null
            : AppBar(
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
                    color: theme.colorScheme.onSurface,
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
                        color: theme.colorScheme.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.delete_outline_rounded,
                        color: theme.colorScheme.primary,
                        size: 20.0,
                      ),
                    ),
                    const SizedBox(width: 10.0),
                    Text(
                      'Cestino Piatti',
                      style: theme.appBarTheme.titleTextStyle ??
                          theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 19.0,
                            letterSpacing: -0.4,
                            color: theme.colorScheme.onSurface,
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
          child: StreamBuilder<List<PiattiRecord>>(
            stream: queryPiattiRecord(
              queryBuilder: (piattiRecord) => piattiRecord
                  .where('isCestinato', isEqualTo: true)
                  .where('proprietario', isEqualTo: currentUserReference),
            ),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: SizedBox(
                    width: 48.0,
                    height: 48.0,
                    child: SpinKitPulse(
                      color: theme.colorScheme.primary,
                      size: 48.0,
                    ),
                  ),
                );
              }

              final allDishes = snapshot.data!;

              // Se il cestino è vuoto, mostra la card informativa professionale a centro schermo
              if (allDishes.isEmpty) {
                return LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minHeight: constraints.maxHeight),
                        child: const Center(
                          child: CestinoVuotoWidget(),
                        ),
                      ),
                    );
                  },
                );
              }

              final filteredDishes = _searchQuery.trim().isEmpty
                  ? allDishes
                  : allDishes
                      .where((d) => d.nome.toLowerCase().contains(_searchQuery.trim().toLowerCase()))
                      .toList();

              return LayoutBuilder(
                builder: (context, constraints) {
                  final isDesktop = constraints.maxWidth >= 768 || widget.embedded;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ── Barra Superiore di Controllo & Ricerca ─────────────────────────────
                      if (isDesktop)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                          margin: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 14.0),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E293B) : Colors.white,
                            borderRadius: BorderRadius.circular(14.0),
                            border: Border.all(
                              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                              width: 1.0,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                                blurRadius: 10.0,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // Badge Conteggio
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(10.0),
                                  border: Border.all(
                                    color: theme.colorScheme.primary.withValues(alpha: 0.25),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.inventory_2_outlined, size: 16.0, color: theme.colorScheme.primary),
                                    const SizedBox(width: 8.0),
                                    Text(
                                      '${allDishes.length} ${allDishes.length == 1 ? 'piatto nel cestino' : 'piatti nel cestino'}',
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.bold,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10.0),

                              // Badge Policy Conservazione
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(10.0),
                                  border: Border.all(
                                    color: const Color(0xFFF59E0B).withValues(alpha: 0.25),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.schedule_rounded, size: 15.0, color: Color(0xFFF59E0B)),
                                    const SizedBox(width: 6.0),
                                    Text(
                                      'Conservazione: 7 giorni',
                                      style: TextStyle(
                                        fontSize: 12.0,
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Spacer(),

                              // Campo di ricerca piatti
                              ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 240.0),
                                child: TextField(
                                  controller: _searchController,
                                  onChanged: (val) => safeSetState(() => _searchQuery = val),
                                  style: const TextStyle(fontSize: 12.5),
                                  decoration: InputDecoration(
                                    hintText: 'Cerca piatto...',
                                    hintStyle: TextStyle(
                                      fontSize: 12.5,
                                      color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                                    ),
                                    prefixIcon: const Icon(Icons.search_rounded, size: 18.0),
                                    suffixIcon: _searchQuery.isNotEmpty
                                        ? IconButton(
                                            icon: const Icon(Icons.close_rounded, size: 16.0),
                                            onPressed: () {
                                              _searchController.clear();
                                              safeSetState(() => _searchQuery = '');
                                            },
                                          )
                                        : null,
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                                    filled: true,
                                    fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide: BorderSide(
                                        color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide: BorderSide(
                                        color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide: BorderSide(
                                        color: theme.colorScheme.primary,
                                        width: 1.5,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12.0),

                              // Pulsante Svuota Cestino
                              ElevatedButton.icon(
                                onPressed: () => _confermaSvuotaTutto(theme),
                                icon: const Icon(Icons.delete_sweep_rounded, size: 17.0),
                                label: const Text('Svuota Cestino', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.colorScheme.error.withValues(alpha: 0.12),
                                  foregroundColor: theme.colorScheme.error,
                                  side: BorderSide(color: theme.colorScheme.error.withValues(alpha: 0.3)),
                                  elevation: 0.0,
                                  padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        // Control bar Mobile
                        Padding(
                          padding: const EdgeInsets.fromLTRB(14.0, 10.0, 14.0, 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.primary.withValues(alpha: 0.08),
                                        borderRadius: BorderRadius.circular(8.0),
                                        border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.2)),
                                      ),
                                      child: Text(
                                        '${allDishes.length} nel cestino • Scadenza 7 gg',
                                        style: TextStyle(
                                          fontSize: 11.0,
                                          fontWeight: FontWeight.bold,
                                          color: theme.colorScheme.primary,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8.0),
                                  OutlinedButton.icon(
                                    onPressed: () => _confermaSvuotaTutto(theme),
                                    icon: const Icon(Icons.delete_sweep_rounded, size: 15.0),
                                    label: const Text('Svuota', style: TextStyle(fontSize: 11.5)),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: theme.colorScheme.error,
                                      side: BorderSide(color: theme.colorScheme.error.withValues(alpha: 0.4)),
                                      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8.0),
                              TextField(
                                controller: _searchController,
                                onChanged: (val) => safeSetState(() => _searchQuery = val),
                                style: const TextStyle(fontSize: 13.0),
                                decoration: InputDecoration(
                                  hintText: 'Cerca piatto nel cestino...',
                                  hintStyle: const TextStyle(fontSize: 12.5),
                                  prefixIcon: const Icon(Icons.search_rounded, size: 18.0),
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                                  filled: true,
                                  fillColor: theme.cardColor,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide(color: theme.dividerColor.withValues(alpha: 0.2)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // ── Lista / Griglia Piatti ─────────────────────────────────────────────
                      Expanded(
                        child: filteredDishes.isEmpty
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(24.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.search_off_rounded, size: 40.0, color: theme.hintColor),
                                      const SizedBox(height: 10.0),
                                      Text(
                                        'Nessun piatto trovato per "$_searchQuery"',
                                        style: TextStyle(
                                          fontSize: 14.0,
                                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : isDesktop
                                ? GridView.builder(
                                    padding: const EdgeInsets.fromLTRB(24.0, 4.0, 24.0, 32.0),
                                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                                      maxCrossAxisExtent: 480.0,
                                      mainAxisExtent: 100.0,
                                      crossAxisSpacing: 16.0,
                                      mainAxisSpacing: 12.0,
                                    ),
                                    itemCount: filteredDishes.length,
                                    itemBuilder: (context, index) {
                                      return _buildDishCard(
                                        filteredDishes[index],
                                        theme,
                                        true,
                                      );
                                    },
                                  )
                                : ListView.builder(
                                    padding: const EdgeInsets.fromLTRB(12.0, 4.0, 12.0, 24.0),
                                    itemCount: filteredDishes.length,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: 8.0),
                                        child: _buildDishCard(
                                          filteredDishes[index],
                                          theme,
                                          false,
                                        ),
                                      );
                                    },
                                  ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDishCard(PiattiRecord dish, ThemeData theme, bool isDesktop) {
    final isDark = theme.brightness == Brightness.dark;
    final giorniRimanenti = CestinoService.calcolaGiorniRimanenti(dish.dataCestinamento);
    final isUrgent = giorniRimanenti <= 1;
    final isWarning = giorniRimanenti <= 3 && !isUrgent;

    final Color badgeBg = isUrgent
        ? const Color(0xFFEF4444).withValues(alpha: 0.12)
        : isWarning
            ? const Color(0xFFF59E0B).withValues(alpha: 0.12)
            : const Color(0xFF10B981).withValues(alpha: 0.12);

    final Color badgeColor = isUrgent
        ? const Color(0xFFEF4444)
        : isWarning
            ? (isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706))
            : (isDark ? const Color(0xFF34D399) : const Color(0xFF059669));

    final String badgeText = isUrgent
        ? 'Scade oggi!'
        : giorniRimanenti == 1
            ? 'Scade domani'
            : 'Scade tra $giorniRimanenti gg';

    final IconData badgeIcon = isUrgent
        ? Icons.warning_amber_rounded
        : isWarning
            ? Icons.timer_outlined
            : Icons.shield_outlined;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 8.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Foto Piatto con fallback
          ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: CachedNetworkImage(
              imageUrl: valueOrDefault<String>(
                dish.foto,
                'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/pronto-menu-f0och1/assets/2n9hc9ugo68c/Immagine_standard.png',
              ),
              width: 60.0,
              height: 60.0,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) => Container(
                width: 60.0,
                height: 60.0,
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                alignment: Alignment.center,
                child: Icon(Icons.restaurant_rounded, color: theme.colorScheme.primary, size: 24.0),
              ),
            ),
          ),
          const SizedBox(width: 12.0),

          // Dati Piatto (Nome, Prezzo, Scadenza)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  dish.nome,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: isDesktop ? 14.0 : 13.5,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.2,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 3.5),
                Row(
                  children: [
                    Text(
                      formatNumber(
                        dish.prezzo,
                        formatType: FormatType.decimal,
                        decimalType: DecimalType.commaDecimal,
                        currency: '€',
                      ),
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6.5, vertical: 2.0),
                      decoration: BoxDecoration(
                        color: badgeBg,
                        borderRadius: BorderRadius.circular(6.0),
                        border: Border.all(color: badgeColor.withValues(alpha: 0.25)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(badgeIcon, size: 11.5, color: badgeColor),
                          const SizedBox(width: 3.5),
                          Text(
                            badgeText,
                            style: TextStyle(
                              fontSize: 10.0,
                              fontWeight: FontWeight.bold,
                              color: badgeColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8.0),

          // Azioni Rapide (Ripristina + Elimina per sempre)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () => _ripristinaPiatto(dish, theme),
                icon: const Icon(Icons.restore_rounded, size: 15.0),
                label: const Text('Ripristina', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.12),
                  foregroundColor: theme.colorScheme.primary,
                  elevation: 0.0,
                  side: BorderSide(color: theme.colorScheme.primary.withValues(alpha: 0.35)),
                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 7.0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                ),
              ),
              const SizedBox(width: 6.0),
              IconButton(
                tooltip: 'Elimina definitivamente',
                icon: Icon(
                  Icons.delete_forever_rounded,
                  color: theme.colorScheme.error,
                  size: 21.0,
                ),
                onPressed: () => _eliminaDefinitivamente(dish, theme),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

