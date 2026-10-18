import '/services/translation_service.dart';
import '/services/category_icon_helper.dart';
import '/app_themes.dart';
import '/theme_provider.dart';
import '/backend/backend.dart';
import '/cliente/popup_tavolo/popup_tavolo_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'riepilogo_finale_model.dart';
export 'riepilogo_finale_model.dart';

/// Riepilogo finale (Carrello)
class RiepilogoFinaleWidget extends StatefulWidget {
  const RiepilogoFinaleWidget({
    super.key,
    this.ristoranteRef,
  });

  final DocumentReference? ristoranteRef;

  static String routeName = 'RiepilogoFinale';
  static String routePath = '/riepilogoFinale';

  @override
  State<RiepilogoFinaleWidget> createState() => _RiepilogoFinaleWidgetState();
}

class _RiepilogoFinaleWidgetState extends State<RiepilogoFinaleWidget> {
  late RiepilogoFinaleModel _model;
  String _currentLang = 'it';
  Stream<UsersRecord>? _ristoranteStream;
  Stream<List<CategoriesRecord>>? _categoriesStream;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => RiepilogoFinaleModel());

    if (widget.ristoranteRef != null) {
      _ristoranteStream = UsersRecord.getDocument(widget.ristoranteRef!);
      _categoriesStream = queryCategoriesRecord(
        queryBuilder: (q) =>
            q.where('proprietario', isEqualTo: widget.ristoranteRef),
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final l = await TranslationService.getSavedLanguage();
      if (mounted) safeSetState(() => _currentLang = l);
    });
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  void _rimuoviPiatto(int index, PiattiRecord rowPiattiRecord) {
    final prezzoDaSottrarre = (index < FFAppState().CarrelloPrezzi.length)
        ? FFAppState().CarrelloPrezzi[index]
        : rowPiattiRecord.prezzo;

    if (index < FFAppState().Carrello.length) {
      FFAppState().removeAtIndexFromCarrello(index);
    }
    if (index < FFAppState().CarrelloNomi.length) {
      FFAppState().removeAtIndexFromCarrelloNomi(index);
    }
    if (index < FFAppState().CarrelloPrezzi.length) {
      FFAppState().removeAtIndexFromCarrelloPrezzi(index);
    }
    FFAppState().totaleCarrello = functions.sottraiPrezzo(
      FFAppState().totaleCarrello,
      prezzoDaSottrarre,
    )!;
    safeSetState(() {});
  }

  void _confermaSvuotaCarrello(BuildContext context, ThemeData theme) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          backgroundColor: theme.cardColor,
          title: Row(
            children: [
              Container(
                width: 36.0,
                height: 36.0,
                decoration: BoxDecoration(
                  color: theme.colorScheme.error.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.delete_outline_rounded,
                  color: theme.colorScheme.error,
                  size: 20.0,
                ),
              ),
              const SizedBox(width: 10.0),
              Expanded(
                child: Text(
                  TranslationService.getUi('svuota_carrello', _currentLang),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            TranslationService.getUi('svuota_carrello_conferma', _currentLang),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                TranslationService.getUi('annulla', _currentLang),
                style: TextStyle(
                  color: theme.hintColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                FFAppState().Carrello.clear();
                FFAppState().CarrelloNomi.clear();
                FFAppState().CarrelloPrezzi.clear();
                FFAppState().totaleCarrello = 0.0;
                safeSetState(() {});
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
                foregroundColor: theme.colorScheme.onError,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              child: Text(
                TranslationService.getUi('svuota', _currentLang),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  void _navigaIndietro() {
    if (Navigator.of(context).canPop()) {
      context.safePop();
    } else if (FFAppState().ristoranteSalvato != null || widget.ristoranteRef != null) {
      context.pushNamed(
        MenuClienteWidget.routeName,
        queryParameters: {
          'ristoranteRef': serializeParam(
            widget.ristoranteRef ?? FFAppState().ristoranteSalvato,
            ParamType.DocumentReference,
          ),
        }.withoutNulls,
      );
    } else {
      context.safePop();
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();
    final baseTheme = Theme.of(context);
    final itemCarrello = FFAppState().Carrello.toList();

    Widget buildContent({
      UsersRecord? usersRecord,
      List<CategoriesRecord>? categories,
    }) {
      ThemeData theme = baseTheme;
      if (usersRecord != null) {
        final AppDesignStyle clientStyle = switch (usersRecord.temaScelto) {
          'pub' => AppDesignStyle.pub,
          'minimal' => AppDesignStyle.minimal,
          'tradizionale' => AppDesignStyle.tradizionale,
          _ => AppDesignStyle.premium,
        };

        Color? clientColor;
        if (usersRecord.colorePrimario.isNotEmpty) {
          try {
            final hex = usersRecord.colorePrimario;
            final clean = hex.replaceAll('#', '').trim();
            if (clean.length == 6) {
              clientColor = Color(int.parse('FF$clean', radix: 16));
            } else if (clean.length == 8) {
              clientColor = Color(int.parse(clean, radix: 16));
            }
          } catch (_) {}
        }

        theme = AppThemes.buildTheme(
          designStyle: clientStyle,
          primaryColor: clientColor ?? clientStyle.defaultPrimaryColor,
          brightness: baseTheme.brightness,
          titleFont: usersRecord.fontTitoli.isNotEmpty
              ? usersRecord.fontTitoli
              : clientStyle.defaultTitleFont,
          bodyFont: usersRecord.fontTesti.isNotEmpty
              ? usersRecord.fontTesti
              : clientStyle.defaultBodyFont,
        );
      }

      final DishCardLayout clientLayout = (usersRecord != null)
          ? DishCardLayoutExtension.fromString(usersRecord.layoutPiatti)
          : DishCardLayout.classico;
      final bool layoutPrevedeImmagine =
          clientLayout != DishCardLayout.minimale;

      final Map<String, String> categoryNames = {};
      if (categories != null) {
        for (final cat in categories) {
          categoryNames[cat.reference.id] = cat.name;
        }
      }

      return Theme(
        data: theme,
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Scaffold(
        key: scaffoldKey,
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: theme.appBarTheme.backgroundColor ?? theme.cardColor,
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
              _navigaIndietro();
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
                  Icons.receipt_long_rounded,
                  color: theme.colorScheme.primary,
                  size: 20.0,
                ),
              ),
              const SizedBox(width: 10.0),
              Text(
                TranslationService.getUi('riepilogo_ordini', _currentLang),
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
          actions: [
            if (itemCarrello.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: FlutterFlowIconButton(
                  borderColor: Colors.transparent,
                  borderRadius: 24.0,
                  buttonSize: 40.0,
                  icon: Icon(
                    Icons.delete_sweep_rounded,
                    color: theme.colorScheme.error,
                    size: 22.0,
                  ),
                  onPressed: () async {
                    _confermaSvuotaCarrello(context, theme);
                  },
                ),
              )
            else
              const SizedBox(width: 48.0),
          ],
        ),
        body: SafeArea(
          top: true,
          child: itemCarrello.isEmpty
              ? _buildEmptyState(theme)
              : Column(
                  children: [
                    // Header informativo con conteggio articoli
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(20.0, 16.0, 20.0, 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.shopping_bag_outlined,
                                size: 18.0,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 6.0),
                              Text(
                                '${itemCarrello.length} ${TranslationService.getUi('piatti_selezionati', _currentLang).toLowerCase()}',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10.0,
                              vertical: 4.0,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: Text(
                              formatNumber(
                                FFAppState().totaleCarrello,
                                formatType: FormatType.decimal,
                                decimalType: DecimalType.periodDecimal,
                                currency: '€',
                              ),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 16.0, thickness: 1.0),
                    // Lista piatti
                    Expanded(
                      child: ListView.separated(
                        controller: _model.columnController,
                        padding: const EdgeInsetsDirectional.fromSTEB(16.0, 8.0, 16.0, 16.0),
                        itemCount: itemCarrello.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12.0),
                        itemBuilder: (context, itemCarrelloIndex) {
                          final itemCarrelloItem =
                              itemCarrello[itemCarrelloIndex];

                          return StreamBuilder<PiattiRecord>(
                            stream:
                                PiattiRecord.getDocument(itemCarrelloItem),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return Container(
                                  height: 84.0,
                                  decoration: BoxDecoration(
                                    color: theme.cardColor,
                                    borderRadius: BorderRadius.circular(16.0),
                                  ),
                                  child: Center(
                                    child: SizedBox(
                                      width: 24.0,
                                      height: 24.0,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.0,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                );
                              }

                              final rowPiattiRecord = snapshot.data!;
                              final nomeVisualizzato = (itemCarrelloIndex <
                                      FFAppState().CarrelloNomi.length)
                                  ? FFAppState()
                                      .CarrelloNomi[itemCarrelloIndex]
                                  : rowPiattiRecord.nome;

                              final prezzoItem = (itemCarrelloIndex <
                                      FFAppState().CarrelloPrezzi.length)
                                  ? FFAppState()
                                      .CarrelloPrezzi[itemCarrelloIndex]
                                  : rowPiattiRecord.prezzo;

                              final isCustomized =
                                  nomeVisualizzato != rowPiattiRecord.nome;

                              final catId = rowPiattiRecord.categoria;
                              final catName = categoryNames[catId] ?? catId;
                              final catIcon =
                                  CategoryIconHelper.getCategoryIcon(catName);
                              final bool hasFoto =
                                  rowPiattiRecord.foto.isNotEmpty;
                              final bool mostraFoto =
                                  layoutPrevedeImmagine && hasFoto;

                              return Container(
                                decoration: BoxDecoration(
                                  color: theme.cardColor,
                                  borderRadius: BorderRadius.circular(16.0),
                                  border: Border.all(
                                    color: theme.colorScheme.outlineVariant
                                        .withValues(alpha: 0.35),
                                    width: 1.0,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.03),
                                      blurRadius: 10.0,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Row(
                                    children: [
                                      // Foto del piatto con fallback raffinato o icona monocromatica categoria
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                        child: mostraFoto
                                            ? CachedNetworkImage(
                                                imageUrl: rowPiattiRecord.foto,
                                                width: 64.0,
                                                height: 64.0,
                                                fit: BoxFit.cover,
                                                placeholder: (context, url) =>
                                                    Container(
                                                  width: 64.0,
                                                  height: 64.0,
                                                  color: theme
                                                      .scaffoldBackgroundColor,
                                                ),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        _buildDishIconPlaceholder(
                                                            theme, catIcon),
                                              )
                                            : _buildDishIconPlaceholder(
                                                theme, catIcon),
                                      ),
                                      const SizedBox(width: 14.0),
                                      // Informazioni Piatto
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              nomeVisualizzato,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: theme.textTheme.titleMedium
                                                  ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15.0,
                                                letterSpacing: -0.2,
                                              ),
                                            ),
                                            if (isCustomized) ...[
                                              const SizedBox(height: 4.0),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 6.0,
                                                  vertical: 2.0,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: theme.colorScheme.primary
                                                      .withValues(alpha: 0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(6.0),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      Icons.tune_rounded,
                                                      size: 11.0,
                                                      color: theme
                                                          .colorScheme.primary,
                                                    ),
                                                    const SizedBox(width: 4.0),
                                                    Text(
                                                      'Personalizzato',
                                                      style: TextStyle(
                                                        fontSize: 10.5,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: theme
                                                            .colorScheme.primary,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                            const SizedBox(height: 6.0),
                                            Text(
                                              formatNumber(
                                                prezzoItem,
                                                formatType: FormatType.decimal,
                                                decimalType:
                                                    DecimalType.periodDecimal,
                                                currency: '€',
                                              ),
                                              style: theme.textTheme.titleSmall
                                                  ?.copyWith(
                                                fontWeight: FontWeight.w800,
                                                color: theme.colorScheme.primary,
                                                fontSize: 15.0,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8.0),
                                      // Pulsante Rimuovi
                                      FlutterFlowIconButton(
                                        borderRadius: 12.0,
                                        buttonSize: 38.0,
                                        fillColor: theme.colorScheme.error
                                            .withValues(alpha: 0.08),
                                        icon: Icon(
                                          Icons.delete_outline_rounded,
                                          color: theme.colorScheme.error,
                                          size: 20.0,
                                        ),
                                        onPressed: () async {
                                          _rimuoviPiatto(
                                            itemCarrelloIndex,
                                            rowPiattiRecord,
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    // Bottom Checkout Bar moderna e raffinata
                    _buildBottomCheckoutBar(theme, itemCarrello),
                  ],
                ),
          ),
        ),
        ),
      );
    }

    if (widget.ristoranteRef == null) {
      return buildContent();
    }

    return StreamBuilder<UsersRecord>(
      stream: _ristoranteStream,
      builder: (context, userSnapshot) {
        return StreamBuilder<List<CategoriesRecord>>(
          stream: _categoriesStream,
          builder: (context, catSnapshot) {
            return buildContent(
              usersRecord: userSnapshot.data,
              categories: catSnapshot.data,
            );
          },
        );
      },
    );
  }

  Widget _buildDishIconPlaceholder(ThemeData theme, IconData icon) {
    return Container(
      width: 64.0,
      height: 64.0,
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12.0),
      ),
      alignment: Alignment.center,
      child: Icon(
        icon,
        color: theme.colorScheme.primary,
        size: 28.0,
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 120.0,
              height: 120.0,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.shopping_bag_outlined,
                size: 58.0,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24.0),
            Text(
              TranslationService.getUi('carrello_vuoto', _currentLang),
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 10.0),
            Text(
              TranslationService.getUi('carrello_vuoto_desc', _currentLang),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.hintColor,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 32.0),
            ElevatedButton.icon(
              icon: const Icon(Icons.restaurant_menu_rounded, size: 20.0),
              label: Text(
                TranslationService.getUi('torna_al_menu', _currentLang),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15.0,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 26.0,
                  vertical: 14.0,
                ),
                elevation: 2.0,
              ),
              onPressed: () {
                _navigaIndietro();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomCheckoutBar(ThemeData theme, List<DocumentReference> itemCarrello) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(22.0),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 18.0,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                TranslationService.getUi('totale_ordine', _currentLang),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.hintColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 12.0,
                ),
              ),
              const SizedBox(height: 2.0),
              Text(
                formatNumber(
                  FFAppState().totaleCarrello,
                  formatType: FormatType.decimal,
                  decimalType: DecimalType.periodDecimal,
                  currency: '€',
                ),
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: theme.colorScheme.primary,
                  letterSpacing: -0.5,
                  fontSize: 22.0,
                ),
              ),
            ],
          ),
          ElevatedButton.icon(
            onPressed: itemCarrello.isEmpty
                ? null
                : () async {
                    await showModalBottomSheet(
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      barrierColor: const Color(0x26000000),
                      enableDrag: false,
                      context: context,
                      builder: (context) {
                        return GestureDetector(
                          onTap: () {
                            FocusScope.of(context).unfocus();
                            FocusManager.instance.primaryFocus?.unfocus();
                          },
                          child: Padding(
                            padding: MediaQuery.viewInsetsOf(context),
                            child: PopupTavoloWidget(
                              ristoranteRef: widget.ristoranteRef ??
                                  FFAppState().ristoranteSalvato,
                              currentLang: _currentLang,
                            ),
                          ),
                        );
                      },
                    ).then((value) => safeSetState(() {}));
                  },
            icon: const Icon(Icons.send_rounded, size: 18.0),
            label: Text(
              TranslationService.getUi('invia_ordine', _currentLang),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              disabledBackgroundColor: theme.disabledColor.withValues(alpha: 0.2),
              disabledForegroundColor: theme.hintColor,
              elevation: 3.0,
              shadowColor: theme.colorScheme.primary.withValues(alpha: 0.35),
              padding: const EdgeInsets.symmetric(
                horizontal: 22.0,
                vertical: 14.0,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              textStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15.5,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
