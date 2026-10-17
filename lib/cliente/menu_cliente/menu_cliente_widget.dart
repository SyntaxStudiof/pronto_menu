import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/cliente/comp_carrello/comp_carrello_widget.dart';
import '/cliente/dettagli_piatto_popup/dettagli_piatto_popup_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/index.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';
import '/backend/schema/util/allergeni_data.dart';
import 'modal_filtro_allergeni_widget.dart';
import '/cliente/modal_personalizza_piatto_widget.dart';
import '/cliente/jukebox_modal/jukebox_modal_widget.dart';
import '/services/translation_service.dart';
import '/services/mutaforma_service.dart';
import '/cliente/ingredienti_helper.dart';
import '/app_themes.dart';
import '/theme_provider.dart';
import 'menu_cliente_model.dart';
export 'menu_cliente_model.dart';

/// il menu che vede il cliente
class MenuClienteWidget extends StatefulWidget {
  const MenuClienteWidget({
    super.key,
    required this.ristoranteRef,
    this.isAnteprima = false,
    this.fasciaId,
    this.solaConsultazione = false,
  });

  final DocumentReference? ristoranteRef;
  final bool isAnteprima;
  final String? fasciaId;
  final bool solaConsultazione;

  static String routeName = 'MenuCliente';
  static String routePath = '/MenuCliente';

  @override
  State<MenuClienteWidget> createState() => _MenuClienteWidgetState();
}

class _MenuClienteWidgetState extends State<MenuClienteWidget>
    with SingleTickerProviderStateMixin {
  late MenuClienteModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  late AnimationController _fabAnimController;
  late Animation<double> _expandAnimation;
  late Animation<double> _rotationAnimation;
  bool _isSpeedDialOpen = false;
  String _currentLang = 'it';
  StreamSubscription<List<DispensaRecord>>? _dispensaSub;
  Set<String> _ingredientiEsauriti = {};

  Stream<UsersRecord>? _restaurantStream;
  Stream<List<CategoriesRecord>>? _categoriesStream;
  Stream<List<SottocategorieRecord>>? _subcategoriesStream;
  Stream<List<PiattiRecord>>? _allPiattiFilterStream;

  void _applyRestaurantTheme(UsersRecord record) {
    _model.datiRistorante = record;
    final themeToApply = record.temaScelto;
    if (themeToApply.isNotEmpty) {
      FFAppState().applyTheme(themeToApply, context: context);
    }
    if (record.temaScelto == 'AmethystSlatelight') {
      FFAppState().temaPrimary = Color(0xFF4B0082);
      FFAppState().temaSecondary = Color(0xFF008080);
      FFAppState().temaTertiary = Color(0xFFFFD700);
      FFAppState().temaAlternate = Color(0xFF800080);
      FFAppState().temaPrimaryBackground = Color(0xFFE5E4E2);
      FFAppState().temaSecondaryBackground = Color(0xFFF5F5F5);
      FFAppState().temaPrimaryText = Color(0xFF1C1C1C);
      FFAppState().temaSecondaryText = Color(0xFF666666);
      FFAppState().temaAccent1 = Color(0x344B0082);
      FFAppState().temaAccent2 = Color(0xFFE0E0E0);
      FFAppState().temaAccent3 = Colors.white;
      FFAppState().temaAccent4 = Color(0xFF310055);
      FFAppState().temaSuccess = Color(0xFF228B22);
      FFAppState().temaError = Color(0xFFB00020);
      FFAppState().temaWarning = Color(0xFFFF8C00);
      FFAppState().temaInfo = Color(0xFF4169E1);
      safeSetState(() {});
      setDarkModeSetting(context, ThemeMode.light);
    } else if (record.temaScelto == 'ProntoMenudark') {
      FFAppState().temaPrimary = Color(0xFF21493D);
      FFAppState().temaSecondary = Color(0xFF8E7C6C);
      FFAppState().temaTertiary = Color(0xFF782329);
      FFAppState().temaAlternate = Color(0xFFF2ECE4);
      FFAppState().temaPrimaryBackground = Color(0xFF121212);
      FFAppState().temaSecondaryBackground = Color(0xFF1E1E1E);
      FFAppState().temaPrimaryText = Color(0xFFFDF6ED);
      FFAppState().temaSecondaryText = Color(0xFFC1B4AB);
      FFAppState().temaAccent1 = Color(0xFF367160);
      FFAppState().temaAccent2 = Color(0x33A6343C);
      FFAppState().temaAccent3 = Color(0xFFC03C46);
      FFAppState().temaAccent4 = Color(0xFF6F9CEF);
      FFAppState().temaSuccess = Color(0xFF11C694);
      FFAppState().temaError = Color(0xFFF75A60);
      FFAppState().temaWarning = Color(0xFFFFB84D);
      FFAppState().temaInfo = Color(0xFF6F9CEF);
      safeSetState(() {});
      setDarkModeSetting(context, ThemeMode.dark);
    } else if (record.temaScelto == 'AmethystSlatedark') {
      FFAppState().temaPrimary = Color(0xFFBB86FC);
      FFAppState().temaSecondary = Color(0xFF03DAC6);
      FFAppState().temaTertiary = Color(0xFFFFD700);
      FFAppState().temaAlternate = Color(0xFF9932CC);
      FFAppState().temaPrimaryBackground = Color(0xFF121212);
      FFAppState().temaSecondaryBackground = Color(0xFF1E1E1E);
      FFAppState().temaPrimaryText = Colors.white;
      FFAppState().temaSecondaryText = Color(0xFFA0A0A0);
      FFAppState().temaAccent1 = Color(0x25BB86FC);
      FFAppState().temaAccent2 = Color(0xFFE0E0E0);
      FFAppState().temaAccent3 = Color(0xFF2C2C2C);
      FFAppState().temaAccent4 = Color(0xFFD1A3FF);
      FFAppState().temaSuccess = Color(0xFF81C784);
      FFAppState().temaError = Color(0xFFCF6679);
      FFAppState().temaWarning = Color(0xFFFFB74D);
      FFAppState().temaInfo = Color(0xFF64B5F6);
      safeSetState(() {});
      setDarkModeSetting(context, ThemeMode.dark);
    } else {
      FFAppState().temaPrimary = Color(0xFF2C5E4F);
      FFAppState().temaSecondary = Color(0xFFD8CAB7);
      FFAppState().temaTertiary = Color(0xFFA6343C);
      FFAppState().temaAlternate = Color(0xFF333333);
      FFAppState().temaPrimaryBackground = Color(0xFFFFFAF5);
      FFAppState().temaSecondaryBackground = Color(0xFFF1E8DC);
      FFAppState().temaPrimaryText = Color(0xFF413F3E);
      FFAppState().temaSecondaryText = Color(0xFFA59D96);
      FFAppState().temaAccent1 = Color(0x322C5E4F);
      FFAppState().temaAccent2 = Color(0x33A6343C);
      FFAppState().temaAccent3 = Color(0x34D8CAB7);
      FFAppState().temaAccent4 = Color(0xFF4F85E0);
      FFAppState().temaSuccess = Color(0xFF0B9F74);
      FFAppState().temaError = Color(0xFFF8464C);
      FFAppState().temaWarning = Color(0xFFFFA926);
      FFAppState().temaInfo = Color(0xFF4F85E0);
      safeSetState(() {});
      setDarkModeSetting(context, ThemeMode.light);
    }
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MenuClienteModel());

    if (widget.ristoranteRef != null) {
      FFAppState().ristoranteSalvato = widget.ristoranteRef;
      _restaurantStream = UsersRecord.getDocument(widget.ristoranteRef!);
      _categoriesStream = queryCategoriesRecord(
        queryBuilder: (categoriesRecord) => categoriesRecord
            .where(
              'proprietario',
              isEqualTo: widget.ristoranteRef,
            )
            .orderBy('ordine_categoria'),
      );
      _subcategoriesStream = querySottocategorieRecord(
        queryBuilder: (sottocategorieRecord) => sottocategorieRecord
            .where(
              'proprietario',
              isEqualTo: widget.ristoranteRef,
            ),
      );
      _allPiattiFilterStream = queryPiattiRecord(
        queryBuilder: (p) => p
            .where('proprietario', isEqualTo: widget.ristoranteRef)
            .where('isCestinato', isEqualTo: false),
      );

      _dispensaSub = queryDispensaRecord(
        queryBuilder: (q) => q
            .where('proprietario', isEqualTo: widget.ristoranteRef)
            .where('esaurito', isEqualTo: true),
      ).listen((records) {
        if (mounted) {
          setState(() {
            _ingredientiEsauriti = records
                .map((r) => r.nome.trim().toLowerCase())
                .where((n) => n.isNotEmpty)
                .toSet();
          });
        }
      });

      _restaurantStream!.first.then((record) {
        if (mounted && record != null) {
          _applyRestaurantTheme(record);
        }
      });
    }

    TranslationService.getSavedLanguage().then((l) {
      if (mounted && _currentLang != l) {
        setState(() {
          _currentLang = l;
        });
      }
    });
    TranslationService.translationNotifier.addListener(_onTranslationUpdated);

    _fabAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
      reverseDuration: const Duration(milliseconds: 240),
    );

    _expandAnimation = CurvedAnimation(
      parent: _fabAnimController,
      curve: Curves.easeOutBack,
      reverseCurve: Curves.easeInOutCubic,
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(
        parent: _fabAnimController,
        curve: Curves.easeInOutCubic,
      ),
    );

    // Gestione reindirizzamento immediato per ristoratore
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!widget.isAnteprima && currentUserUid.isNotEmpty && widget.ristoranteRef == null) {
        context.pushNamed(
          HomeRistoratoreWidget.routeName,
          queryParameters: {
            'ristoranteRef': serializeParam(
              widget.ristoranteRef,
              ParamType.DocumentReference,
            ),
          }.withoutNulls,
        );
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _dispensaSub?.cancel();
    TranslationService.translationNotifier.removeListener(_onTranslationUpdated);
    _fabAnimController.dispose();
    _model.dispose();

    super.dispose();
  }

  void _onTranslationUpdated() {
    if (mounted) {
      safeSetState(() {});
    }
  }

  void _mostraSelettoreLingua(ThemeData theme) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24.0),
              topRight: Radius.circular(24.0),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  width: 40.0,
                  height: 4.0,
                  decoration: BoxDecoration(
                    color: theme.dividerColor.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(2.0),
                  ),
                ),
                const SizedBox(height: 18.0),
                Row(
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
                        Icons.translate_rounded,
                        color: theme.colorScheme.primary,
                        size: 20.0,
                      ),
                    ),
                    const SizedBox(width: 12.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          TranslationService.getUi('lingua_menu', _currentLang),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          TranslationService.getUi('seleziona_lingua', _currentLang),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.hintColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                Divider(color: theme.dividerColor.withValues(alpha: 0.3)),
                const SizedBox(height: 8.0),
                ...TranslationService.supportedLanguages.map((lang) {
                  final isSelected = lang.code == _currentLang;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Material(
                      color: isSelected
                          ? theme.colorScheme.primary.withValues(alpha: 0.12)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12.0),
                      child: InkWell(
                        onTap: () async {
                          Navigator.pop(context);
                          if (_currentLang != lang.code) {
                            setState(() {
                              _currentLang = lang.code;
                            });
                            await TranslationService.saveLanguage(lang.code);
                          }
                        },
                        borderRadius: BorderRadius.circular(12.0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 12.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.0),
                            border: Border.all(
                              color: isSelected
                                  ? theme.colorScheme.primary.withValues(alpha: 0.4)
                                  : theme.dividerColor.withValues(alpha: 0.2),
                              width: 1.0,
                            ),
                          ),
                          child: Row(
                            children: [
                              Text(
                                lang.flag,
                                style: const TextStyle(fontSize: 24.0),
                              ),
                              const SizedBox(width: 14.0),
                              Expanded(
                                child: Text(
                                  lang.label,
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.w500,
                                    color: isSelected
                                        ? theme.colorScheme.primary
                                        : theme.textTheme.bodyLarge?.color,
                                  ),
                                ),
                              ),
                              if (isSelected)
                                Icon(
                                  Icons.check_circle_rounded,
                                  color: theme.colorScheme.primary,
                                  size: 22.0,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 12.0),
              ],
            ),
          ),
        );
      },
    );
  }

  void _toggleSpeedDial() {
    setState(() {
      _isSpeedDialOpen = !_isSpeedDialOpen;
      if (_isSpeedDialOpen) {
        _fabAnimController.forward();
      } else {
        _fabAnimController.reverse();
      }
    });
  }

  void _closeSpeedDial() {
    if (_isSpeedDialOpen) {
      setState(() {
        _isSpeedDialOpen = false;
        _fabAnimController.reverse();
      });
    }
  }

  Widget _buildDishSkeletonList(ThemeData theme) {
    return ListView.builder(
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: 4,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(10.0, 10.0, 10.0, 10.0),
          child: Material(
            color: Colors.transparent,
            elevation: 2.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Container(
              width: MediaQuery.sizeOf(context).width * 1.0,
              constraints: const BoxConstraints(minHeight: 72.0),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(12.0),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
              child: Row(
                children: [
                  Container(
                    width: 60.0,
                    height: 60.0,
                    decoration: BoxDecoration(
                      color: theme.dividerColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  const SizedBox(width: 14.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 130.0,
                          height: 14.0,
                          decoration: BoxDecoration(
                            color: theme.dividerColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        Container(
                          width: 80.0,
                          height: 10.0,
                          decoration: BoxDecoration(
                            color: theme.dividerColor.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 48.0,
                    height: 14.0,
                    decoration: BoxDecoration(
                      color: theme.dividerColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  IconData _getCategoryIcon(String categoryName) {
    final lower = categoryName.toLowerCase();
    if (lower.contains('pizz')) return Icons.local_pizza_rounded;
    if (lower.contains('burg') ||
        lower.contains('panin') ||
        lower.contains('sandwich')) {
      return Icons.lunch_dining_rounded;
    }
    if (lower.contains('prim') ||
        lower.contains('past') ||
        lower.contains('risott') ||
        lower.contains('noodl') ||
        lower.contains('zupp')) {
      return Icons.ramen_dining_rounded;
    }
    if (lower.contains('second') ||
        lower.contains('carn') ||
        lower.contains('steak') ||
        lower.contains('tagliat')) {
      return Icons.kebab_dining_rounded;
    }
    if (lower.contains('pesc') ||
        lower.contains('fish') ||
        lower.contains('mare') ||
        lower.contains('seafood')) {
      return Icons.set_meal_rounded;
    }
    if (lower.contains('antipas') ||
        lower.contains('starter') ||
        lower.contains('appetiz') ||
        lower.contains('tapas') ||
        lower.contains('sfiz')) {
      return Icons.tapas_rounded;
    }
    if (lower.contains('dolc') ||
        lower.contains('dessert') ||
        lower.contains('tort') ||
        lower.contains('cake')) {
      return Icons.cake_rounded;
    }
    if (lower.contains('gelat') || lower.contains('ice cream')) {
      return Icons.icecream_rounded;
    }
    if (lower.contains('bevand') ||
        lower.contains('drink') ||
        lower.contains('bibit')) {
      return Icons.local_bar_rounded;
    }
    if (lower.contains('vin') || lower.contains('wine')) {
      return Icons.wine_bar_rounded;
    }
    if (lower.contains('birr') || lower.contains('beer')) {
      return Icons.sports_bar_rounded;
    }
    if (lower.contains('caff') ||
        lower.contains('coffee') ||
        lower.contains('colazion')) {
      return Icons.coffee_rounded;
    }
    if (lower.contains('contorn') ||
        lower.contains('insalat') ||
        lower.contains('salad') ||
        lower.contains('verdur')) {
      return Icons.eco_rounded;
    }
    return Icons.restaurant_rounded;
  }

  Widget _buildFilterSpeedDial(ThemeData theme) {
    return StreamBuilder<List<PiattiRecord>>(
      stream: _allPiattiFilterStream ??
          queryPiattiRecord(
            queryBuilder: (p) => p
                .where('proprietario', isEqualTo: widget!.ristoranteRef)
                .where('isCestinato', isEqualTo: false),
          ),
      builder: (context, piattiSnapshot) {
        if (!piattiSnapshot.hasData) {
          return const SizedBox.shrink();
        }

        final allDishes = piattiSnapshot.data ?? [];

        // Raccoglie tutti gli allergeni presenti nei piatti del ristorante
        final Set<String> allergeniPresentiNelMenu = {};
        for (final dish in allDishes) {
          for (final a in dish.allergeni) {
            final clean = a.trim().toLowerCase().replaceAll(' ', '_');
            if (clean.isNotEmpty) {
              allergeniPresentiNelMenu.add(clean);
            }
          }
        }
        final bool hasAllergeni = allergeniPresentiNelMenu.isNotEmpty;

        // Raccoglie le intolleranze (filtri magici) presenti nei piatti del ristorante
        final List<InfoFiltroMagico> intolleranzePresenti =
            AllergeniData.filtriMagici.where((f) {
          return allDishes.any((d) => AllergeniData.dishHasFiltro(d, f.id));
        }).toList();
        final bool hasIntolleranze = intolleranzePresenti.isNotEmpty;

        // Se il ristoratore non ha inserito né allergeni né intolleranze, non mostriamo nemmeno il pulsante
        if (!hasAllergeni && !hasIntolleranze) {
          return const SizedBox.shrink();
        }

        final totalFilters = _model.totalActiveFilters;

        return AnimatedBuilder(
          animation: _fabAnimController,
          builder: (context, child) {
            final isOpenOrAnimating = _fabAnimController.value > 0.01;
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (isOpenOrAnimating) ...[
                  FadeTransition(
                    opacity: _fabAnimController,
                    child: ScaleTransition(
                      scale: _expandAnimation,
                      alignment: Alignment.bottomRight,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4.0, vertical: 6.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            // Tasto Azzera Filtri se ci sono filtri attivi
                            if (totalFilters > 0) ...[
                              Padding(
                                padding: const EdgeInsets.only(bottom: 10.0),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () {
                                      safeSetState(() {
                                        _model.filtriMagiciAttivi.clear();
                                        _model.allergeniEsclusi.clear();
                                      });
                                    },
                                    borderRadius: BorderRadius.circular(20.0),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12.0, vertical: 6.0),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.error
                                            .withValues(alpha: 0.15),
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                        border: Border.all(
                                          color: theme.colorScheme.error
                                              .withValues(alpha: 0.4),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.restart_alt_rounded,
                                              size: 14.0,
                                              color: theme.colorScheme.error),
                                          const SizedBox(width: 4.0),
                                          Text(
                                            '${TranslationService.getUi('azzera_filtri', _currentLang)} ($totalFilters)',
                                            style: TextStyle(
                                              color: theme.colorScheme.error,
                                              fontSize: 12.0,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],

                            // Pulsante Allergeni (MOSTRATO SOLO SE IL RISTORANTE HA INSERITO ALLERGENI)
                            if (hasAllergeni)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 10.0),
                                child: Material(
                                  elevation: 4.0,
                                  shadowColor:
                                      Colors.black.withValues(alpha: 0.25),
                                  borderRadius: BorderRadius.circular(24.0),
                                  color: theme.cardColor,
                                  child: InkWell(
                                    onTap: () async {
                                      await ModalFiltroAllergeniWidget.show(
                                        context: context,
                                        allergeniIniziali:
                                            _model.allergeniEsclusi,
                                        allergeniPresentiNelMenu:
                                            allergeniPresentiNelMenu,
                                        currentLang: _currentLang,
                                        onApplica: (esclusi) {
                                          safeSetState(() {
                                            _model.allergeniEsclusi = esclusi;
                                          });
                                        },
                                      );
                                    },
                                    borderRadius: BorderRadius.circular(24.0),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14.0, vertical: 10.0),
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(24.0),
                                        border: Border.all(
                                          color: _model
                                                  .allergeniEsclusi.isNotEmpty
                                              ? Colors.deepOrange
                                              : theme.dividerColor
                                                  .withValues(alpha: 0.3),
                                          width: _model
                                                  .allergeniEsclusi.isNotEmpty
                                              ? 1.8
                                              : 1.0,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            width: 28.0,
                                            height: 28.0,
                                            decoration: BoxDecoration(
                                              color: Colors.deepOrange
                                                  .withValues(alpha: 0.15),
                                              shape: BoxShape.circle,
                                            ),
                                            alignment: Alignment.center,
                                            child: const Icon(
                                              Icons.shield_outlined,
                                              size: 16.0,
                                              color: Colors.deepOrange,
                                            ),
                                          ),
                                          const SizedBox(width: 8.0),
                                          Text(
                                            TranslationService.getUi('allergeni', _currentLang),
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13.5,
                                              color: theme
                                                  .textTheme.bodyMedium?.color,
                                            ),
                                          ),
                                          if (_model.allergeniEsclusi
                                              .isNotEmpty) ...[
                                            const SizedBox(width: 8.0),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 7.0,
                                                      vertical: 2.0),
                                              decoration: BoxDecoration(
                                                color: Colors.deepOrange,
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                              ),
                                              child: Text(
                                                '${_model.allergeniEsclusi.length} ${TranslationService.getUi('esclusi', _currentLang)}',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10.5,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                          const SizedBox(width: 4.0),
                                          Icon(
                                            Icons.tune_rounded,
                                            size: 16.0,
                                            color: theme.hintColor,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                            // Intolleranze (Filtri Magici presenti nel menu)
                            ...intolleranzePresenti.map((filtro) {
                              final isSelected = _model.filtriMagiciAttivi
                                  .contains(filtro.id);
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Material(
                                  elevation: isSelected ? 4.0 : 2.0,
                                  shadowColor: isSelected
                                      ? filtro.badgeColor
                                          .withValues(alpha: 0.35)
                                      : Colors.black.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(22.0),
                                  color: isSelected
                                      ? filtro.badgeColor
                                      : theme.cardColor,
                                  child: InkWell(
                                    onTap: () {
                                      safeSetState(() {
                                        if (isSelected) {
                                          _model.filtriMagiciAttivi
                                              .remove(filtro.id);
                                        } else {
                                          _model.filtriMagiciAttivi
                                              .add(filtro.id);
                                        }
                                      });
                                    },
                                    borderRadius: BorderRadius.circular(22.0),
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 180),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14.0, vertical: 8.5),
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(22.0),
                                        border: Border.all(
                                          color: isSelected
                                              ? filtro.badgeColor
                                              : theme.dividerColor
                                                  .withValues(alpha: 0.25),
                                          width: 1.0,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(filtro.emoji,
                                              style: const TextStyle(
                                                  fontSize: 15.0)),
                                          const SizedBox(width: 8.0),
                                          Text(
                                            TranslationService.getFiltroLabel(filtro.id, _currentLang),
                                            style: TextStyle(
                                              fontWeight: isSelected
                                                  ? FontWeight.bold
                                                  : FontWeight.w500,
                                              fontSize: 13.0,
                                              color: isSelected
                                                  ? Colors.white
                                                  : theme.textTheme
                                                      .bodyMedium?.color,
                                            ),
                                          ),
                                          if (isSelected) ...[
                                            const SizedBox(width: 6.0),
                                            const Icon(
                                              Icons.check_rounded,
                                              color: Colors.white,
                                              size: 16.0,
                                            ),
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
                    ),
                  ),
                  const SizedBox(height: 6.0),
                ],

                // Pulsante circolare principale con animazione di rotazione
                GestureDetector(
                  onTap: _toggleSpeedDial,
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 58.0,
                        height: 58.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              theme.colorScheme.primary,
                              theme.colorScheme.primary.withValues(alpha: 0.85),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: theme.colorScheme.primary
                                  .withValues(alpha: 0.35),
                              blurRadius: 12.0,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: RotationTransition(
                          turns: _rotationAnimation,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            transitionBuilder: (child, anim) =>
                                ScaleTransition(scale: anim, child: child),
                            child: _isSpeedDialOpen
                                ? Icon(
                                    Icons.close_rounded,
                                    key: const ValueKey('close'),
                                    color: theme.colorScheme.onPrimary,
                                    size: 28.0,
                                  )
                                : Icon(
                                    Icons.tune_rounded,
                                    key: const ValueKey('tune'),
                                    color: theme.colorScheme.onPrimary,
                                    size: 26.0,
                                  ),
                          ),
                        ),
                      ),

                      // Badge contatore filtri attivi
                      if (!_isSpeedDialOpen && totalFilters > 0)
                        Positioned(
                          top: -2.0,
                          right: -2.0,
                          child: Container(
                            padding: const EdgeInsets.all(5.0),
                            constraints: const BoxConstraints(
                                minWidth: 22.0, minHeight: 22.0),
                            decoration: BoxDecoration(
                              color: Colors.deepOrange,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: theme.scaffoldBackgroundColor,
                                width: 2.0,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.25),
                                  blurRadius: 4.0,
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '$totalFilters',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11.0,
                                fontWeight: FontWeight.bold,
                                height: 1.0,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildMutaformaPausaView(
    ThemeData theme,
    FasciaMutaforma? prossimaFascia,
  ) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 88.0,
              height: 88.0,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.schedule_rounded,
                color: theme.colorScheme.primary,
                size: 44.0,
              ),
            ),
            const SizedBox(height: 22.0),
            Text(
              'Menù al momento in pausa',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 22.0,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 10.0),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380.0),
              child: Text(
                'Attualmente non ci sono menù attivi per questo orario. Il ristorante è in pausa tra un turno e l\'altro.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color:
                      theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                  height: 1.4,
                ),
              ),
            ),
            if (prossimaFascia != null) ...[
              const SizedBox(height: 28.0),
              Container(
                constraints: const BoxConstraints(maxWidth: 380.0),
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(18.0),
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.25),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 16.0,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.auto_awesome_rounded,
                          color: theme.colorScheme.primary,
                          size: 18.0,
                        ),
                        const SizedBox(width: 8.0),
                        Text(
                          'PROSSIMO MENÙ IN ARRIVO',
                          style: TextStyle(
                            fontSize: 12.0,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12.0),
                    Text(
                      prossimaFascia.nome,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14.0, vertical: 7.0),
                      decoration: BoxDecoration(
                        color:
                            theme.colorScheme.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.access_time_filled_rounded,
                            size: 15.0,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 6.0),
                          Text(
                            'Dalle ${prossimaFascia.oraInizio} alle ${prossimaFascia.oraFine}',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    Text(
                      MutaformaService.formatGiorni(prossimaFascia.giorniAttivi),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color
                            ?.withValues(alpha: 0.75),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 32.0),
            ElevatedButton.icon(
              onPressed: () {
                safeSetState(() {});
              },
              icon: const Icon(Icons.refresh_rounded, size: 20.0),
              label: const Text('Ricarica orario'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                    horizontal: 26.0, vertical: 14.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.0),
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

    return StreamBuilder<UsersRecord>(
      stream: _restaurantStream ?? UsersRecord.getDocument(widget!.ristoranteRef!),
      builder: (context, snapshot) {
        // Customize what your widget looks like when it's loading.
        if (!snapshot.hasData) {
          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
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

        final menuClienteUsersRecord = snapshot.data!;
        final bool mutaformaAttivo = menuClienteUsersRecord.menuMutaformaAttivo;
        final List<FasciaMutaforma> fasceMutaforma =
            MutaformaService.decodeFasce(menuClienteUsersRecord.fasceMutaforma);
        final FasciaMutaforma? fasciaRichiesta = widget.fasciaId != null
            ? fasceMutaforma
                .where((f) => f.id == widget.fasciaId)
                .firstOrNull
            : null;
        final FasciaMutaforma? fasciaAttiva =
            mutaformaAttivo && fasceMutaforma.isNotEmpty
                ? MutaformaService.getFasciaAttiva(fasceMutaforma)
                : null;
        final FasciaMutaforma? fasciaTarget = fasciaRichiesta ?? fasciaAttiva;

        final bool mutaformaInPausa = widget.fasciaId == null &&
            mutaformaAttivo &&
            fasceMutaforma.isNotEmpty &&
            fasciaAttiva == null;
        final FasciaMutaforma? prossimaFascia =
            mutaformaInPausa ? MutaformaService.getProssimaFascia(fasceMutaforma) : null;
        final bool isSolaConsultazione =
            widget.solaConsultazione || !menuClienteUsersRecord.hasPlus;

        if (fasciaTarget != null &&
            _model.categoriaSelezionata != null &&
            !fasciaTarget.categoriaIds.contains(_model.categoriaSelezionata)) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              safeSetState(() {
                _model.categoriaSelezionata = null;
                _model.categoriaSelezionataRef = null;
                _model.sottocategoriaSelezionata = null;
              });
            }
          });
        }

        final AppDesignStyle clientStyle = switch (menuClienteUsersRecord.temaScelto) {
          'pub' => AppDesignStyle.pub,
          'minimal' => AppDesignStyle.minimal,
          'tradizionale' => AppDesignStyle.tradizionale,
          _ => AppDesignStyle.premium,
        };

        Color? clientColor;
        if (menuClienteUsersRecord.colorePrimario.isNotEmpty) {
          try {
            final clean = menuClienteUsersRecord.colorePrimario.replaceAll('#', '');
            if (clean.length == 6) {
              clientColor = Color(int.parse('FF$clean', radix: 16));
            } else if (clean.length == 8) {
              clientColor = Color(int.parse(clean, radix: 16));
            }
          } catch (_) {}
        }

        final ThemeData clientTheme = AppThemes.buildTheme(
          designStyle: clientStyle,
          primaryColor: clientColor ?? clientStyle.defaultPrimaryColor,
          brightness: theme.brightness,
          titleFont: menuClienteUsersRecord.fontTitoli.isNotEmpty
              ? menuClienteUsersRecord.fontTitoli
              : clientStyle.defaultTitleFont,
          bodyFont: menuClienteUsersRecord.fontTesti.isNotEmpty
              ? menuClienteUsersRecord.fontTesti
              : clientStyle.defaultBodyFont,
        );

        return Theme(
          data: clientTheme,
          child: Builder(
            builder: (context) {
              final theme = Theme.of(context);
              return GestureDetector(
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
              elevation: 2.0,
              centerTitle: true,
              leadingWidth: context.canPop() ? 126.0 : 84.0,
              leading: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(start: 8.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (context.canPop())
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                              minWidth: 32.0, minHeight: 32.0),
                          icon: Icon(
                            Icons.arrow_back_rounded,
                            size: 22.0,
                            color: theme.colorScheme.onSurface,
                          ),
                          onPressed: () => context.safePop(),
                        ),
                      InkWell(
                        onTap: () => _mostraSelettoreLingua(theme),
                        borderRadius: BorderRadius.circular(16.0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6.0, vertical: 4.0),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(16.0),
                        border: Border.all(
                          color:
                              theme.colorScheme.primary.withValues(alpha: 0.28),
                          width: 1.0,
                        ),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              TranslationService.supportedLanguages
                                  .firstWhere((l) => l.code == _currentLang,
                                      orElse: () =>
                                          TranslationService.supportedLanguages.first)
                                  .flag,
                              style: const TextStyle(fontSize: 15.0),
                            ),
                            const SizedBox(width: 3.0),
                            Text(
                              _currentLang.toUpperCase(),
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            Icon(
                              Icons.arrow_drop_down_rounded,
                              size: 16.0,
                              color: theme.colorScheme.primary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
              title: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 36.0,
                    height: 36.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.colorScheme.primary.withValues(alpha: 0.35),
                        width: 1.5,
                      ),
                    ),
                    child: ClipOval(
                      child: Image.network(
                        valueOrDefault<String>(
                          menuClienteUsersRecord.photoUrl,
                          'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/pronto-menu-f0och1/assets/i4ccmvv80eni/IMG_8006.png',
                        ),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Image.asset(
                          'assets/images/IMG_8006.png',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Icon(
                            Icons.restaurant_rounded,
                            color: theme.colorScheme.primary,
                            size: 20.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10.0),
                  Flexible(
                    child: Text(
                      menuClienteUsersRecord.displayName.isNotEmpty
                          ? menuClienteUsersRecord.displayName
                          : TranslationService.getUi('menu', _currentLang),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontSize: 20.0,
                        fontWeight: FontWeight.w600,
                        color: theme.appBarTheme.foregroundColor ??
                            theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                if (!isSolaConsultazione)
                  InkWell(
                    splashColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () async {
                      context.pushNamed(
                        RiepilogoFinaleWidget.routeName,
                        queryParameters: {
                          'ristoranteRef': serializeParam(
                            widget.ristoranteRef,
                            ParamType.DocumentReference,
                          ),
                        }.withoutNulls,
                      );
                    },
                    child: Center(
                      child: wrapWithModel(
                        model: _model.compCarrelloModel,
                        updateCallback: () => safeSetState(() {}),
                        child: CompCarrelloWidget(),
                      ),
                    ),
                  )
                else
                  const SizedBox(width: 48.0),
              ],
            ),
            body: SafeArea(
              top: true,
              child: SizedBox.expand(
                child: mutaformaInPausa
                    ? _buildMutaformaPausaView(theme, prossimaFascia)
                    : Stack(
                        fit: StackFit.expand,
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              if (widget.solaConsultazione && (widget.fasciaId != null || mutaformaInPausa))
                                Container(
                                  width: double.infinity,
                                  margin: const EdgeInsets.fromLTRB(
                                      16.0, 8.0, 16.0, 4.0),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14.0, vertical: 8.0),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF673AB7)
                                        .withValues(alpha: 0.10),
                                    borderRadius: BorderRadius.circular(12.0),
                                    border: Border.all(
                                      color: const Color(0xFF673AB7)
                                          .withValues(alpha: 0.25),
                                      width: 1.0,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.visibility_rounded,
                                        color: Color(0xFF673AB7),
                                        size: 18.0,
                                      ),
                                      const SizedBox(width: 8.0),
                                      Expanded(
                                        child: Text(
                                          fasciaTarget != null
                                              ? 'Menù ${fasciaTarget.nome} • Sola consultazione'
                                              : 'Menù fuori orario • Sola consultazione',
                                          style: const TextStyle(
                                            color: Color(0xFF673AB7),
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12.5,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              Container(
                                width: double.infinity,
                                height: 52.0,
                                decoration: BoxDecoration(
                                  color: theme.scaffoldBackgroundColor,
                                  border: Border(
                                    bottom: BorderSide(
                                      color: theme.dividerColor
                                          .withValues(alpha: 0.08),
                                      width: 1.0,
                                    ),
                                  ),
                                ),
                                child: StreamBuilder<List<CategoriesRecord>>(
                                  stream: _categoriesStream ??
                                      queryCategoriesRecord(
                                        queryBuilder: (categoriesRecord) =>
                                            categoriesRecord
                                                .where(
                                                  'proprietario',
                                                  isEqualTo:
                                                      widget!.ristoranteRef,
                                                )
                                                .orderBy('ordine_categoria'),
                                      ),
                                  builder: (context, snapshot) {
                                    // Skeleton moderno per le categorie mentre caricano
                                    if (!snapshot.hasData) {
                                      return ListView.separated(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16.0, vertical: 7.0),
                                        scrollDirection: Axis.horizontal,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemCount: 4,
                                        separatorBuilder: (context, i) =>
                                            const SizedBox(width: 8.0),
                                        itemBuilder: (context, i) => Container(
                                          width: 105.0,
                                          decoration: BoxDecoration(
                                            color: theme.cardColor
                                                .withValues(alpha: 0.6),
                                            borderRadius:
                                                BorderRadius.circular(24.0),
                                            border: Border.all(
                                              color: theme.dividerColor
                                                  .withValues(alpha: 0.1),
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                    List<CategoriesRecord>
                                        listViewCategoriesRecordList =
                                        snapshot.data!;

                                    if (fasciaTarget != null) {
                                      listViewCategoriesRecordList =
                                          listViewCategoriesRecordList
                                              .where((c) => fasciaTarget
                                                  .categoriaIds
                                                  .contains(c.reference.id))
                                              .toList();
                                    }

                                    if (listViewCategoriesRecordList.isEmpty) {
                                      return Center(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16.0),
                                          child: Text(
                                            'Nessuna categoria attiva in questa fascia oraria',
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                              fontStyle: FontStyle.italic,
                                              color: theme.hintColor,
                                            ),
                                          ),
                                        ),
                                      );
                                    }

                                    final isPanoramicaSelected =
                                        _model.categoriaSelezionata == null ||
                                            _model.categoriaSelezionata == '';

                                    return ListView.separated(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16.0, vertical: 7.0),
                                      scrollDirection: Axis.horizontal,
                                      physics: const BouncingScrollPhysics(),
                                      separatorBuilder: (context, i) =>
                                          const SizedBox(width: 8.0),
                                      itemCount: 1 +
                                          listViewCategoriesRecordList.length,
                                      itemBuilder: (context, index) {
                                        if (index == 0) {
                                          return AnimatedContainer(
                                            duration: const Duration(
                                                milliseconds: 200),
                                            curve: Curves.easeOutCubic,
                                            decoration: BoxDecoration(
                                              color: isPanoramicaSelected
                                                  ? theme.colorScheme.primary
                                                  : theme.cardColor,
                                              borderRadius:
                                                  BorderRadius.circular(24.0),
                                              border: Border.all(
                                                color: isPanoramicaSelected
                                                    ? theme.colorScheme.primary
                                                    : theme.dividerColor
                                                        .withValues(
                                                            alpha: 0.20),
                                                width: 1.0,
                                              ),
                                              boxShadow: isPanoramicaSelected
                                                  ? [
                                                      BoxShadow(
                                                        color: theme
                                                            .colorScheme.primary
                                                            .withValues(
                                                                alpha: 0.35),
                                                        blurRadius: 8.0,
                                                        offset: const Offset(
                                                            0.0, 3.0),
                                                      ),
                                                    ]
                                                  : [
                                                      BoxShadow(
                                                        color: Colors.black
                                                            .withValues(
                                                                alpha: 0.03),
                                                        blurRadius: 4.0,
                                                        offset: const Offset(
                                                            0.0, 1.5),
                                                      ),
                                                    ],
                                            ),
                                            child: InkWell(
                                              borderRadius:
                                                  BorderRadius.circular(24.0),
                                              onTap: () {
                                                _model.categoriaSelezionata =
                                                    null;
                                                _model.categoriaSelezionataRef =
                                                    null;
                                                _model
                                                    .sottocategoriaSelezionata =
                                                    null;
                                                safeSetState(() {});
                                              },
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 14.0,
                                                  vertical: 6.0,
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      Icons
                                                          .restaurant_menu_rounded,
                                                      size: 16.0,
                                                      color:
                                                          isPanoramicaSelected
                                                              ? Colors.white
                                                              : theme
                                                                  .colorScheme
                                                                  .primary,
                                                    ),
                                                    const SizedBox(width: 6.0),
                                                    Text(
                                                      TranslationService.getUi(
                                                          'panoramica',
                                                          _currentLang),
                                                      style:
                                                          GoogleFonts.openSans(
                                                        fontWeight:
                                                            isPanoramicaSelected
                                                                ? FontWeight
                                                                    .bold
                                                                : FontWeight
                                                                    .w600,
                                                        fontSize: 13.0,
                                                        color:
                                                            isPanoramicaSelected
                                                                ? Colors.white
                                                                : theme
                                                                    .colorScheme
                                                                    .onSurface
                                                                    .withValues(
                                                                        alpha:
                                                                            0.85),
                                                        letterSpacing: -0.2,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        }

                                        final catIndex = index - 1;
                                        final catRecord =
                                            listViewCategoriesRecordList[
                                                catIndex];
                                        final isCatSelected = _model
                                                .categoriaSelezionata ==
                                            catRecord.reference.id;
                                        final catIcon =
                                            _getCategoryIcon(catRecord.name);

                                        return AnimatedContainer(
                                          duration: const Duration(
                                              milliseconds: 200),
                                          curve: Curves.easeOutCubic,
                                          decoration: BoxDecoration(
                                            color: isCatSelected
                                                ? theme.colorScheme.primary
                                                : theme.cardColor,
                                            borderRadius:
                                                BorderRadius.circular(24.0),
                                            border: Border.all(
                                              color: isCatSelected
                                                  ? theme.colorScheme.primary
                                                  : theme.dividerColor
                                                      .withValues(
                                                          alpha: 0.20),
                                              width: 1.0,
                                            ),
                                            boxShadow: isCatSelected
                                                ? [
                                                    BoxShadow(
                                                      color: theme
                                                          .colorScheme.primary
                                                          .withValues(
                                                              alpha: 0.35),
                                                      blurRadius: 8.0,
                                                      offset: const Offset(
                                                          0.0, 3.0),
                                                    ),
                                                  ]
                                                : [
                                                    BoxShadow(
                                                      color: Colors.black
                                                          .withValues(
                                                              alpha: 0.03),
                                                      blurRadius: 4.0,
                                                      offset: const Offset(
                                                          0.0, 1.5),
                                                    ),
                                                  ],
                                          ),
                                          child: InkWell(
                                            borderRadius:
                                                BorderRadius.circular(24.0),
                                            onTap: () {
                                              _model
                                                  .sottocategoriaSelezionata =
                                                  null;
                                              if (_model
                                                      .categoriaSelezionataRef ==
                                                  catRecord.reference) {
                                                _model.categoriaSelezionataRef =
                                                    null;
                                                _model.categoriaSelezionata =
                                                    null;
                                              } else {
                                                _model.categoriaSelezionataRef =
                                                    catRecord.reference;
                                                _model.categoriaSelezionata =
                                                    catRecord.reference.id;
                                              }
                                              safeSetState(() {});
                                            },
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 14.0,
                                                vertical: 6.0,
                                              ),
                                              child: Row(
                                                mainAxisSize:
                                                    MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    catIcon,
                                                    size: 16.0,
                                                    color: isCatSelected
                                                        ? Colors.white
                                                        : theme
                                                            .colorScheme
                                                            .primary
                                                            .withValues(
                                                                alpha: 0.85),
                                                  ),
                                                  const SizedBox(width: 6.0),
                                                  Text(
                                                    TranslationService
                                                        .getCategoryName(
                                                            catRecord.name,
                                                            _currentLang),
                                                    maxLines: 1,
                                                    style:
                                                        GoogleFonts.openSans(
                                                      fontWeight: isCatSelected
                                                          ? FontWeight.bold
                                                          : FontWeight.w600,
                                                      fontSize: 13.0,
                                                      color: isCatSelected
                                                          ? Colors.white
                                                          : theme
                                                              .colorScheme
                                                              .onSurface
                                                              .withValues(
                                                                  alpha:
                                                                      0.85),
                                                      letterSpacing: -0.2,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                              StreamBuilder<List<SottocategorieRecord>>(
                                stream: _subcategoriesStream ??
                                    querySottocategorieRecord(
                                      queryBuilder: (sottocategorieRecord) =>
                                          sottocategorieRecord.where(
                                        'proprietario',
                                        isEqualTo: widget!.ristoranteRef,
                                      ),
                                    ),
                                builder: (context, snapshot) {
                                  final allSubcategories =
                                      snapshot.data ?? [];
                                  final currentSubcategories =
                                      _model.categoriaSelezionataRef == null
                                          ? <SottocategorieRecord>[]
                                          : allSubcategories
                                              .where((s) =>
                                                  s.categoriaPadreRef ==
                                                  _model
                                                      .categoriaSelezionataRef)
                                              .toList();

                                  if (_model.categoriaSelezionataRef == null ||
                                      currentSubcategories.isEmpty) {
                                    return const SizedBox.shrink();
                                  }

                                  final isAllSubSelected =
                                      _model.sottocategoriaSelezionata == null;

                                  return Container(
                                    width: double.infinity,
                                    height: 44.0,
                                    decoration: BoxDecoration(
                                      color: theme.cardColor
                                          .withValues(alpha: 0.45),
                                      border: Border(
                                        bottom: BorderSide(
                                          color: theme.dividerColor
                                              .withValues(alpha: 0.08),
                                          width: 1.0,
                                        ),
                                      ),
                                    ),
                                    child: ListView.separated(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16.0, vertical: 6.0),
                                      scrollDirection: Axis.horizontal,
                                      physics: const BouncingScrollPhysics(),
                                      separatorBuilder: (context, i) =>
                                          const SizedBox(width: 6.0),
                                      itemCount:
                                          1 + currentSubcategories.length,
                                      itemBuilder: (context, subIndex) {
                                        if (subIndex == 0) {
                                          return AnimatedContainer(
                                            duration: const Duration(
                                                milliseconds: 180),
                                            decoration: BoxDecoration(
                                              color: isAllSubSelected
                                                  ? theme.colorScheme.primary
                                                      .withValues(alpha: 0.14)
                                                  : theme
                                                      .scaffoldBackgroundColor,
                                              borderRadius:
                                                  BorderRadius.circular(16.0),
                                              border: Border.all(
                                                color: isAllSubSelected
                                                    ? theme.colorScheme.primary
                                                    : theme.dividerColor
                                                        .withValues(
                                                            alpha: 0.16),
                                                width: 1.0,
                                              ),
                                            ),
                                            child: InkWell(
                                              borderRadius:
                                                  BorderRadius.circular(16.0),
                                              onTap: () {
                                                _model
                                                    .sottocategoriaSelezionata =
                                                    null;
                                                safeSetState(() {});
                                              },
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 12.0,
                                                  vertical: 4.0,
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    TranslationService.getUi(
                                                        'tutte', _currentLang),
                                                    style:
                                                        GoogleFonts.openSans(
                                                      fontWeight:
                                                          isAllSubSelected
                                                              ? FontWeight.bold
                                                              : FontWeight
                                                                  .w500,
                                                      fontSize: 12.0,
                                                      color: isAllSubSelected
                                                          ? theme
                                                              .colorScheme
                                                              .primary
                                                          : theme
                                                              .colorScheme
                                                              .onSurface
                                                              .withValues(
                                                                  alpha:
                                                                      0.72),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        }

                                        final subRecord =
                                            currentSubcategories[subIndex - 1];
                                        final isSubSelected = _model
                                                .sottocategoriaSelezionata ==
                                            subRecord.reference;

                                        return AnimatedContainer(
                                          duration: const Duration(
                                              milliseconds: 180),
                                          decoration: BoxDecoration(
                                            color: isSubSelected
                                                ? theme.colorScheme.primary
                                                    .withValues(alpha: 0.14)
                                                : theme
                                                    .scaffoldBackgroundColor,
                                            borderRadius:
                                                BorderRadius.circular(16.0),
                                            border: Border.all(
                                              color: isSubSelected
                                                  ? theme.colorScheme.primary
                                                  : theme.dividerColor
                                                      .withValues(
                                                          alpha: 0.16),
                                              width: 1.0,
                                            ),
                                          ),
                                          child: InkWell(
                                            borderRadius:
                                                BorderRadius.circular(16.0),
                                            onTap: () {
                                              if (_model
                                                      .sottocategoriaSelezionata ==
                                                  subRecord.reference) {
                                                _model
                                                    .sottocategoriaSelezionata =
                                                    null;
                                              } else {
                                                _model
                                                    .sottocategoriaSelezionata =
                                                    subRecord.reference;
                                              }
                                              safeSetState(() {});
                                            },
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 12.0,
                                                vertical: 4.0,
                                              ),
                                              child: Center(
                                                child: Text(
                                                  TranslationService
                                                      .getCategoryName(
                                                          subRecord.nome,
                                                          _currentLang),
                                                  style:
                                                      GoogleFonts.openSans(
                                                    fontWeight: isSubSelected
                                                        ? FontWeight.bold
                                                        : FontWeight.w500,
                                                    fontSize: 12.0,
                                                    color: isSubSelected
                                                        ? theme
                                                            .colorScheme
                                                            .primary
                                                        : theme
                                                            .colorScheme
                                                            .onSurface
                                                            .withValues(
                                                                alpha: 0.72),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                      ),
                                    );
                                  },
                                ),
                      if ((menuClienteUsersRecord.ordinePreferito == 'A - Z') &&
                          (_model.categoriaSelezionata != null &&
                              _model.categoriaSelezionata != ''))
                        Expanded(
                          child: Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 30.0, 0.0, 80.0),
                            child: StreamBuilder<List<PiattiRecord>>(
                              stream: queryPiattiRecord(
                                queryBuilder: (piattiRecord) => piattiRecord
                                    .where(
                                      'proprietario',
                                      isEqualTo: widget!.ristoranteRef,
                                    )
                                    .where(
                                      'isCestinato',
                                      isEqualTo: false,
                                    )
                                    .where(
                                      'sottocategoria_ref',
                                      isEqualTo:
                                          _model.sottocategoriaSelezionata,
                                    )
                                    .where(
                                      'Categoria',
                                      isEqualTo:
                                          _model.categoriaSelezionata != ''
                                              ? _model.categoriaSelezionata
                                              : null,
                                    )
                                    .orderBy('Nome'),
                              ),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return _buildDishSkeletonList(theme);
                                }
                                List<PiattiRecord>
                                    rawNomePiattiRecordList = snapshot.data!;
                                final listViewNomePiattiRecordList =
                                    rawNomePiattiRecordList.where((p) {
                                  return AllergeniData.dishMatchesFilters(
                                    dish: p,
                                    filtriMagici: _model.filtriMagiciAttivi,
                                    allergeniEsclusi: _model.allergeniEsclusi,
                                  );
                                }).toList();

                                if (listViewNomePiattiRecordList.isEmpty) {
                                  return Center(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 24.0, vertical: 32.0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.filter_alt_off_rounded,
                                              size: 48.0,
                                              color: theme.hintColor),
                                          const SizedBox(height: 12.0),
                                          Text(
                                            TranslationService.getUi(
                                                'nessun_piatto_filtri',
                                                _currentLang),
                                            textAlign: TextAlign.center,
                                            style: theme.textTheme.titleMedium
                                                ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 6.0),
                                          Text(
                                            TranslationService.getUi(
                                                'modifica_filtri_hint',
                                                _currentLang),
                                            textAlign: TextAlign.center,
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                                    color: theme.hintColor),
                                          ),
                                          if (_model.totalActiveFilters > 0) ...[
                                            const SizedBox(height: 12.0),
                                            TextButton.icon(
                                              onPressed: () {
                                                safeSetState(() {
                                                  _model.filtriMagiciAttivi.clear();
                                                  _model.allergeniEsclusi.clear();
                                                });
                                              },
                                              icon: const Icon(
                                                  Icons.restart_alt_rounded,
                                                  size: 16.0),
                                              label: Text(
                                                  TranslationService.getUi(
                                                      'azzera_filtri',
                                                      _currentLang)),
                                              style: TextButton.styleFrom(
                                                foregroundColor:
                                                    theme.colorScheme.primary,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  );
                                }

                                return ListView.builder(
                                  padding: EdgeInsets.zero,
                                  shrinkWrap: true,
                                  scrollDirection: Axis.vertical,
                                  itemCount:
                                      listViewNomePiattiRecordList.length,
                                  itemBuilder: (context, listViewNomeIndex) {
                                    final listViewNomePiattiRecord =
                                        listViewNomePiattiRecordList[
                                            listViewNomeIndex];
                                    return Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          10.0, 10.0, 10.0, 10.0),
                                      child: InkWell(
                                        splashColor: Colors.transparent,
                                        focusColor: Colors.transparent,
                                        hoverColor: Colors.transparent,
                                        highlightColor: Colors.transparent,
                                        onTap: () async {
                                          await showModalBottomSheet(
                                            isScrollControlled: true,
                                            backgroundColor: Colors.transparent,
                                            context: context,
                                            builder: (context) {
                                              return GestureDetector(
                                                onTap: () {
                                                  FocusScope.of(context)
                                                      .unfocus();
                                                  FocusManager
                                                      .instance.primaryFocus
                                                      ?.unfocus();
                                                },
                                                child: Padding(
                                                  padding:
                                                      MediaQuery.viewInsetsOf(
                                                          context),
                                                  child:
                                                      DettagliPiattoPopupWidget(
                                                    piattoSelezionato:
                                                        listViewNomePiattiRecord,
                                                    currentLang: _currentLang,
                                                    ingredientiEsauriti:
                                                        _ingredientiEsauriti,
                                                    ristoranteRef:
                                                        widget.ristoranteRef,
                                                    dispensaAttiva:
                                                        menuClienteUsersRecord.dispensaAttiva,
                                                    modifichePiattiAttive:
                                                        menuClienteUsersRecord.modifichePiattiAttive,
                                                    prezzoAggiuntaManuale:
                                                        menuClienteUsersRecord.prezzoAggiuntaManuale,
                                                    ingredientiManualiAttivi:
                                                        menuClienteUsersRecord.ingredientiManualiAttivi,
                                                    solaConsultazione:
                                                        isSolaConsultazione,
                                                    mostraFoto:
                                                        menuClienteUsersRecord
                                                            .hasUltra,
                                                  ),
                                                ),
                                              );
                                            },
                                          ).then(
                                              (value) => safeSetState(() {}));
                                        },
                                        child: Material(
                                          color: Colors.transparent,
                                          elevation: 2.0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                          ),
                                          child: Container(
                                            width: MediaQuery.sizeOf(context)
                                                    .width *
                                                1.0,
                                            constraints: const BoxConstraints(
                                                minHeight: 72.0),
                                            decoration: BoxDecoration(
                                              color: theme.cardColor,
                                              borderRadius:
                                                  BorderRadius.circular(12.0),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                if (menuClienteUsersRecord.hasUltra &&
                                                    listViewNomePiattiRecord
                                                            .foto !=
                                                        null &&
                                                    listViewNomePiattiRecord
                                                            .foto !=
                                                        '')
                                                  Align(
                                                    alignment:
                                                        AlignmentDirectional(
                                                            0.0, 0.0),
                                                    child: Container(
                                                      width: 60.0,
                                                      height: 60.0,
                                                      child: Stack(
                                                        children: [
                                                          Align(
                                                            alignment:
                                                                AlignmentDirectional(
                                                                    0.0, 0.0),
                                                            child:
                                                                CircularPercentIndicator(
                                                              percent: 1.0,
                                                              radius: 25.0,
                                                              lineWidth: 12.0,
                                                              animation: true,
                                                              animateFromLastPercent:
                                                                  true,
                                                              progressColor: theme.colorScheme.primary,
                                                              backgroundColor: theme.colorScheme.secondary,
                                                            ),
                                                          ),
                                                          ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        12.0),
                                                            child:
                                                                Image.network(
                                                              valueOrDefault<
                                                                  String>(
                                                                listViewNomePiattiRecord
                                                                    .foto,
                                                                'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/pronto-menu-f0och1/assets/2n9hc9ugo68c/Immagine_standard.png',
                                                              ),
                                                              width: 60.0,
                                                              height: 60.0,
                                                              fit: BoxFit.cover,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                Expanded(
                                                  child: Padding(
                                                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              EdgeInsetsDirectional
                                                                  .fromSTEB(
                                                                      10.0,
                                                                      0.0,
                                                                      0.0,
                                                                      0.0),
                                                          child: Text(
                                                            listViewNomePiattiRecord.nome, maxLines: 1, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 18.0)),
                                                        ),
                                                        if (listViewNomePiattiRecord.ingredienti != '')
                                                          Padding(
                                                            padding:
                                                                EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        12.0,
                                                                        2.0,
                                                                        0.0,
                                                                        0.0),
                                                            child: IngredientiHelper.buildIngredientiWidget(
                                                              ingredientiText: TranslationService.getDishIngredients(
                                                                  listViewNomePiattiRecord,
                                                                  _currentLang),
                                                              ingredientiOriginali:
                                                                  listViewNomePiattiRecord.ingredienti,
                                                              ingredientiEsauriti: _ingredientiEsauriti,
                                                              baseStyle: theme.textTheme.bodySmall?.copyWith(
                                                                color: theme.hintColor,
                                                                height: 1.35,
                                                              ),
                                                            ),
                                                          ),
                                                        if (listViewNomePiattiRecord.intolleranze.isNotEmpty ||
                                                            listViewNomePiattiRecord.allergeni.isNotEmpty)
                                                          Padding(
                                                            padding: const EdgeInsetsDirectional.fromSTEB(
                                                                10.0, 4.0, 0.0, 0.0),
                                                            child: Wrap(
                                                              spacing: 4.0,
                                                              runSpacing: 2.0,
                                                              children: [
                                                                ...listViewNomePiattiRecord.intolleranze.map((tag) {
                                                                  final f = AllergeniData.getFiltroMagicoById(tag);
                                                                  if (f == null) return const SizedBox.shrink();
                                                                  return Container(
                                                                    padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 1.5),
                                                                    decoration: BoxDecoration(
                                                                      color: f.badgeColor.withValues(alpha: 0.15),
                                                                      borderRadius: BorderRadius.circular(6.0),
                                                                    ),
                                                                    child: Text(
                                                                      '${f.emoji} ${TranslationService.getFiltroLabel(f.id, _currentLang)}',
                                                                      style: TextStyle(
                                                                        color: f.badgeColor,
                                                                        fontSize: 10.0,
                                                                        fontWeight: FontWeight.bold,
                                                                      ),
                                                                    ),
                                                                  );
                                                                }),
                                                                if (listViewNomePiattiRecord.allergeni.isNotEmpty)
                                                                  Container(
                                                                    padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 1.5),
                                                                    decoration: BoxDecoration(
                                                                      color: Colors.orange.withValues(alpha: 0.15),
                                                                      borderRadius: BorderRadius.circular(6.0),
                                                                    ),
                                                                    child: Text(
                                                                      '⚠️ ${listViewNomePiattiRecord.allergeni.length} ${TranslationService.getUi('allergeni_badge', _currentLang)}',
                                                                      style: TextStyle(
                                                                        color: Colors.orange.shade800,
                                                                        fontSize: 10.0,
                                                                        fontWeight: FontWeight.w600,
                                                                      ),
                                                                    ),
                                                                  ),
                                                              ],
                                                            ),
                                                          ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  children: [
                                                    SizedBox(
                                                      height: 50.0,
                                                      child: VerticalDivider(
                                                        thickness: 1.0,
                                                        color: FFAppState()
                                                            .temaAlternate,
                                                      ),
                                                    ),
                                                    Container(
                                                      width: 70.0,
                                                      decoration:
                                                          BoxDecoration(),
                                                      child: Padding(
                                                        padding:
                                                            EdgeInsetsDirectional
                                                                .fromSTEB(
                                                                    0.0,
                                                                    0.0,
                                                                    8.0,
                                                                    0.0),
                                                        child: Text(
                                                          formatNumber(
                                                            listViewNomePiattiRecord.prezzo, formatType: FormatType.decimal, decimalType: DecimalType.periodDecimal, currency: '€'), textAlign: TextAlign.end, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: theme.hintColor)),
                                                      ),
                                                    ),
                                                    if (!isSolaConsultazione) ...[
                                                      if (menuClienteUsersRecord.dispensaAttiva &&
                                                          menuClienteUsersRecord.modifichePiattiAttive &&
                                                          widget.ristoranteRef != null)
                                                        Padding(
                                                          padding: const EdgeInsets.only(right: 6.0),
                                                          child: FlutterFlowIconButton(
                                                            borderRadius: 25.0,
                                                            buttonSize: 38.0,
                                                            fillColor: theme.colorScheme.primary.withValues(alpha: 0.12),
                                                            icon: Icon(
                                                              Icons.tune_rounded,
                                                              color: theme.colorScheme.primary,
                                                              size: 19.0,
                                                            ),
                                                            onPressed: () async {
                                                              await ModalPersonalizzaPiattoWidget.show(
                                                                context: context,
                                                                piatto: listViewNomePiattiRecord,
                                                                ristoranteRef: widget.ristoranteRef!,
                                                                dispensaAttiva: menuClienteUsersRecord.dispensaAttiva,
                                                                prezzoAggiuntaManuale: menuClienteUsersRecord.prezzoAggiuntaManuale,
                                                                currentLang: _currentLang,
                                                              );
                                                              safeSetState(() {});
                                                            },
                                                          ),
                                                        ),
                                                      Padding(
                                                        padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 5.0, 0.0),
                                                        child: FlutterFlowIconButton(
                                                          borderRadius: 25.0,
                                                          buttonSize: 40.0,
                                                          fillColor: theme.colorScheme.primary,
                                                          icon: FaIcon(
                                                            FontAwesomeIcons.plus,
                                                            color: theme.colorScheme.onPrimary,
                                                            size: 20.0,
                                                          ),
                                                          onPressed: () async {
                                                            FFAppState().addToCarrello(
                                                                listViewNomePiattiRecord.reference);
                                                            safeSetState(() {});
                                                            FFAppState().totaleCarrello =
                                                                FFAppState().totaleCarrello +
                                                                    listViewNomePiattiRecord.prezzo;
                                                            safeSetState(() {});
                                                            FFAppState().addToCarrelloNomi(
                                                                listViewNomePiattiRecord.nome);
                                                            safeSetState(() {});
                                                            FFAppState().addToCarrelloPrezzi(
                                                                listViewNomePiattiRecord.prezzo);
                                                            safeSetState(() {});
                                                          },
                                                        ),
                                                      ),
                                                    ] else ...[
                                                      Padding(
                                                        padding: const EdgeInsets.only(right: 8.0),
                                                        child: Icon(
                                                          Icons.remove_red_eye_outlined,
                                                          size: 18.0,
                                                          color: theme.hintColor.withValues(alpha: 0.6),
                                                        ),
                                                      ),
                                                    ],
                                                  ],
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
                          ),
                        ),
                      if ((menuClienteUsersRecord.ordinePreferito ==
                              'Prezzo') &&
                          (_model.categoriaSelezionata != null &&
                              _model.categoriaSelezionata != ''))
                        Expanded(
                          child: Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 30.0, 0.0, 80.0),
                            child: StreamBuilder<List<PiattiRecord>>(
                              stream: queryPiattiRecord(
                                queryBuilder: (piattiRecord) => piattiRecord
                                    .where(
                                      'proprietario',
                                      isEqualTo: widget!.ristoranteRef,
                                    )
                                    .where(
                                      'isCestinato',
                                      isEqualTo: false,
                                    )
                                    .where(
                                      'sottocategoria_ref',
                                      isEqualTo:
                                          _model.sottocategoriaSelezionata,
                                    )
                                    .where(
                                      'Categoria',
                                      isEqualTo:
                                          _model.categoriaSelezionata != ''
                                              ? _model.categoriaSelezionata
                                              : null,
                                    )
                                    .orderBy('Prezzo'),
                              ),
                              builder: (context, snapshot) {
                                // Customize what your widget looks like when it's loading.
                                if (!snapshot.hasData) {
                                  return _buildDishSkeletonList(theme);
                                }
                                List<PiattiRecord>
                                    rawPrezzoPiattiRecordList = snapshot.data!;
                                final listViewPrezzoPiattiRecordList =
                                    rawPrezzoPiattiRecordList.where((p) {
                                  return AllergeniData.dishMatchesFilters(
                                    dish: p,
                                    filtriMagici: _model.filtriMagiciAttivi,
                                    allergeniEsclusi: _model.allergeniEsclusi,
                                  );
                                }).toList();

                                if (listViewPrezzoPiattiRecordList.isEmpty) {
                                  return Center(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 24.0, vertical: 32.0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.filter_alt_off_rounded,
                                              size: 48.0,
                                              color: theme.hintColor),
                                          const SizedBox(height: 12.0),
                                          Text(
                                            TranslationService.getUi(
                                                'nessun_piatto_filtri',
                                                _currentLang),
                                            textAlign: TextAlign.center,
                                            style: theme.textTheme.titleMedium
                                                ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 6.0),
                                          Text(
                                            TranslationService.getUi(
                                                'modifica_filtri_hint',
                                                _currentLang),
                                            textAlign: TextAlign.center,
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                                    color: theme.hintColor),
                                          ),
                                          if (_model.totalActiveFilters > 0) ...[
                                            const SizedBox(height: 12.0),
                                            TextButton.icon(
                                              onPressed: () {
                                                safeSetState(() {
                                                  _model.filtriMagiciAttivi.clear();
                                                  _model.allergeniEsclusi.clear();
                                                });
                                              },
                                              icon: const Icon(
                                                  Icons.restart_alt_rounded,
                                                  size: 16.0),
                                              label: Text(
                                                  TranslationService.getUi(
                                                      'azzera_filtri',
                                                      _currentLang)),
                                              style: TextButton.styleFrom(
                                                foregroundColor:
                                                    theme.colorScheme.primary,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  );
                                }

                                return ListView.builder(
                                  padding: EdgeInsets.zero,
                                  shrinkWrap: true,
                                  scrollDirection: Axis.vertical,
                                  itemCount:
                                      listViewPrezzoPiattiRecordList.length,
                                  itemBuilder: (context, listViewPrezzoIndex) {
                                    final listViewPrezzoPiattiRecord =
                                        listViewPrezzoPiattiRecordList[
                                            listViewPrezzoIndex];
                                    return Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          10.0, 10.0, 10.0, 10.0),
                                      child: InkWell(
                                        splashColor: Colors.transparent,
                                        focusColor: Colors.transparent,
                                        hoverColor: Colors.transparent,
                                        highlightColor: Colors.transparent,
                                        onTap: () async {
                                          await showModalBottomSheet(
                                            isScrollControlled: true,
                                            backgroundColor: Colors.transparent,
                                            context: context,
                                            builder: (context) {
                                              return GestureDetector(
                                                onTap: () {
                                                  FocusScope.of(context)
                                                      .unfocus();
                                                  FocusManager
                                                      .instance.primaryFocus
                                                      ?.unfocus();
                                                },
                                                child: Padding(
                                                  padding:
                                                      MediaQuery.viewInsetsOf(
                                                          context),
                                                  child:
                                                      DettagliPiattoPopupWidget(
                                                    piattoSelezionato:
                                                        listViewPrezzoPiattiRecord,
                                                    currentLang: _currentLang,
                                                    ingredientiEsauriti:
                                                        _ingredientiEsauriti,
                                                    ristoranteRef:
                                                        widget.ristoranteRef,
                                                    dispensaAttiva:
                                                        menuClienteUsersRecord.dispensaAttiva,
                                                    modifichePiattiAttive:
                                                        menuClienteUsersRecord.modifichePiattiAttive,
                                                    prezzoAggiuntaManuale:
                                                        menuClienteUsersRecord.prezzoAggiuntaManuale,
                                                    ingredientiManualiAttivi:
                                                        menuClienteUsersRecord.ingredientiManualiAttivi,
                                                    solaConsultazione:
                                                        isSolaConsultazione,
                                                    mostraFoto:
                                                        menuClienteUsersRecord
                                                            .hasUltra,
                                                  ),
                                                ),
                                              );
                                            },
                                          ).then(
                                              (value) => safeSetState(() {}));
                                        },
                                        child: Material(
                                          color: Colors.transparent,
                                          elevation: 2.0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                          ),
                                          child: Container(
                                            width: MediaQuery.sizeOf(context)
                                                    .width *
                                                1.0,
                                            constraints: const BoxConstraints(
                                                minHeight: 72.0),
                                            decoration: BoxDecoration(
                                              color: theme.cardColor,
                                              borderRadius:
                                                  BorderRadius.circular(12.0),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                if (menuClienteUsersRecord.hasUltra &&
                                                    listViewPrezzoPiattiRecord
                                                            .foto !=
                                                        null &&
                                                    listViewPrezzoPiattiRecord
                                                            .foto !=
                                                        '')
                                                  Align(
                                                    alignment:
                                                        AlignmentDirectional(
                                                            0.0, 0.0),
                                                    child: Container(
                                                      width: 60.0,
                                                      height: 60.0,
                                                      child: Stack(
                                                        children: [
                                                          Align(
                                                            alignment:
                                                                AlignmentDirectional(
                                                                    0.0, 0.0),
                                                            child:
                                                                CircularPercentIndicator(
                                                              percent: 1.0,
                                                              radius: 25.0,
                                                              lineWidth: 12.0,
                                                              animation: true,
                                                              animateFromLastPercent:
                                                                  true,
                                                              progressColor: theme.colorScheme.primary,
                                                              backgroundColor: theme.colorScheme.secondary,
                                                            ),
                                                          ),
                                                          ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        12.0),
                                                            child:
                                                                Image.network(
                                                              valueOrDefault<
                                                                  String>(
                                                                listViewPrezzoPiattiRecord
                                                                    .foto,
                                                                'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/pronto-menu-f0och1/assets/2n9hc9ugo68c/Immagine_standard.png',
                                                              ),
                                                              width: 60.0,
                                                              height: 60.0,
                                                              fit: BoxFit.cover,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                Expanded(
                                                  child: Padding(
                                                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              EdgeInsetsDirectional
                                                                  .fromSTEB(
                                                                      10.0,
                                                                      0.0,
                                                                      0.0,
                                                                      0.0),
                                                          child: Text(
                                                            listViewPrezzoPiattiRecord.nome, maxLines: 1, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 18.0)),
                                                        ),
                                                        if (listViewPrezzoPiattiRecord.ingredienti != '')
                                                          Padding(
                                                            padding:
                                                                EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        12.0,
                                                                        2.0,
                                                                        0.0,
                                                                        0.0),
                                                            child: IngredientiHelper.buildIngredientiWidget(
                                                              ingredientiText: TranslationService.getDishIngredients(
                                                                  listViewPrezzoPiattiRecord,
                                                                  _currentLang),
                                                              ingredientiOriginali:
                                                                  listViewPrezzoPiattiRecord.ingredienti,
                                                              ingredientiEsauriti: _ingredientiEsauriti,
                                                              baseStyle: theme.textTheme.bodySmall?.copyWith(
                                                                color: theme.hintColor,
                                                                height: 1.35,
                                                              ),
                                                            ),
                                                          ),
                                                        if (listViewPrezzoPiattiRecord.intolleranze.isNotEmpty ||
                                                            listViewPrezzoPiattiRecord.allergeni.isNotEmpty)
                                                          Padding(
                                                            padding: const EdgeInsetsDirectional.fromSTEB(
                                                                10.0, 4.0, 0.0, 0.0),
                                                            child: Wrap(
                                                              spacing: 4.0,
                                                              runSpacing: 2.0,
                                                              children: [
                                                                ...listViewPrezzoPiattiRecord.intolleranze.map((tag) {
                                                                  final f = AllergeniData.getFiltroMagicoById(tag);
                                                                  if (f == null) return const SizedBox.shrink();
                                                                  return Container(
                                                                    padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 1.5),
                                                                    decoration: BoxDecoration(
                                                                      color: f.badgeColor.withValues(alpha: 0.15),
                                                                      borderRadius: BorderRadius.circular(6.0),
                                                                    ),
                                                                    child: Text(
                                                                      '${f.emoji} ${TranslationService.getFiltroLabel(f.id, _currentLang)}',
                                                                      style: TextStyle(
                                                                        color: f.badgeColor,
                                                                        fontSize: 10.0,
                                                                        fontWeight: FontWeight.bold,
                                                                      ),
                                                                    ),
                                                                  );
                                                                }),
                                                                if (listViewPrezzoPiattiRecord.allergeni.isNotEmpty)
                                                                  Container(
                                                                    padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 1.5),
                                                                    decoration: BoxDecoration(
                                                                      color: Colors.orange.withValues(alpha: 0.15),
                                                                      borderRadius: BorderRadius.circular(6.0),
                                                                    ),
                                                                    child: Text(
                                                                      '⚠️ ${listViewPrezzoPiattiRecord.allergeni.length} ${TranslationService.getUi('allergeni_badge', _currentLang)}',
                                                                      style: TextStyle(
                                                                        color: Colors.orange.shade800,
                                                                        fontSize: 10.0,
                                                                        fontWeight: FontWeight.w600,
                                                                      ),
                                                                    ),
                                                                  ),
                                                              ],
                                                            ),
                                                          ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  children: [
                                                    SizedBox(
                                                      height: 50.0,
                                                      child: VerticalDivider(
                                                        thickness: 1.0,
                                                        color: FFAppState()
                                                            .temaAlternate,
                                                      ),
                                                    ),
                                                    Container(
                                                      width: 70.0,
                                                      decoration:
                                                          BoxDecoration(),
                                                      child: Padding(
                                                        padding:
                                                            EdgeInsetsDirectional
                                                                .fromSTEB(
                                                                    0.0,
                                                                    0.0,
                                                                    8.0,
                                                                    0.0),
                                                        child: Text(
                                                          formatNumber(
                                                            listViewPrezzoPiattiRecord.prezzo, formatType: FormatType.decimal, decimalType: DecimalType.periodDecimal, currency: '€'), textAlign: TextAlign.end, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: theme.hintColor)),
                                                      ),
                                                    ),
                                                    if (!isSolaConsultazione) ...[
                                                      if (menuClienteUsersRecord.dispensaAttiva &&
                                                          menuClienteUsersRecord.modifichePiattiAttive &&
                                                          widget.ristoranteRef != null)
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets.only(right: 6.0),
                                                          child: FlutterFlowIconButton(
                                                            borderRadius: 25.0,
                                                            buttonSize: 38.0,
                                                            fillColor: theme.colorScheme.primary.withValues(alpha: 0.12),
                                                            icon: Icon(
                                                              Icons.tune_rounded,
                                                              color: theme.colorScheme.primary,
                                                              size: 19.0,
                                                            ),
                                                            onPressed: () async {
                                                              await ModalPersonalizzaPiattoWidget.show(
                                                                context: context,
                                                                piatto: listViewPrezzoPiattiRecord,
                                                                ristoranteRef: widget.ristoranteRef!,
                                                                dispensaAttiva: menuClienteUsersRecord.dispensaAttiva,
                                                                prezzoAggiuntaManuale: menuClienteUsersRecord.prezzoAggiuntaManuale,
                                                                currentLang: _currentLang,
                                                              );
                                                              safeSetState(() {});
                                                            },
                                                          ),
                                                        ),
                                                      Padding(
                                                        padding:
                                                            EdgeInsetsDirectional
                                                                .fromSTEB(
                                                                    0.0,
                                                                    0.0,
                                                                    5.0,
                                                                    0.0),
                                                        child:
                                                            FlutterFlowIconButton(
                                                          borderRadius: 25.0,
                                                          buttonSize: 40.0,
                                                          fillColor: theme.colorScheme.primary,
                                                          icon: FaIcon(
                                                            FontAwesomeIcons.plus,
                                                            color: theme.colorScheme.onPrimary,
                                                            size: 20.0,
                                                          ),
                                                          onPressed: () async {
                                                            FFAppState().addToCarrello(
                                                                listViewPrezzoPiattiRecord
                                                                    .reference);
                                                            safeSetState(() {});
                                                            FFAppState()
                                                                    .totaleCarrello =
                                                                FFAppState()
                                                                        .totaleCarrello +
                                                                    listViewPrezzoPiattiRecord
                                                                        .prezzo;
                                                            safeSetState(() {});
                                                            FFAppState()
                                                                .addToCarrelloNomi(
                                                                    listViewPrezzoPiattiRecord
                                                                        .nome);
                                                            safeSetState(() {});
                                                            FFAppState()
                                                                .addToCarrelloPrezzi(
                                                                    listViewPrezzoPiattiRecord
                                                                        .prezzo);
                                                            safeSetState(() {});
                                                          },
                                                        ),
                                                      ),
                                                    ] else ...[
                                                      Padding(
                                                        padding: const EdgeInsets.only(right: 8.0),
                                                        child: Icon(
                                                          Icons.remove_red_eye_outlined,
                                                          size: 18.0,
                                                          color: theme.hintColor.withValues(alpha: 0.6),
                                                        ),
                                                      ),
                                                    ],
                                                  ],
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
                          ),
                        ),
                      if (_model.categoriaSelezionata == null ||
                          _model.categoriaSelezionata == '')
                        Expanded(
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: SingleChildScrollView(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    20.0, 16.0, 20.0, 40.0),
                                child: Container(
                                  constraints:
                                      const BoxConstraints(maxWidth: 500.0),
                                  decoration: BoxDecoration(
                                    color: theme.cardColor,
                                    borderRadius: BorderRadius.circular(24.0),
                                    border: Border.all(
                                      color: theme.dividerColor
                                          .withValues(alpha: 0.15),
                                      width: 1.0,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black
                                            .withValues(alpha: 0.04),
                                        blurRadius: 18.0,
                                        offset: const Offset(0.0, 6.0),
                                      ),
                                    ],
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24.0,
                                    vertical: 24.0,
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Pill indicatore verso l'alto
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14.0,
                                          vertical: 6.0,
                                        ),
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.primary
                                              .withValues(alpha: 0.12),
                                          borderRadius:
                                              BorderRadius.circular(20.0),
                                          border: Border.all(
                                            color: theme.colorScheme.primary
                                                .withValues(alpha: 0.25),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.arrow_upward_rounded,
                                              color: theme.colorScheme.primary,
                                              size: 16.0,
                                            ),
                                            const SizedBox(width: 6.0),
                                            Text(
                                              TranslationService.getUi('scegli_categoria_in_alto', _currentLang),
                                              style: TextStyle(
                                                color: theme.colorScheme.primary,
                                                fontSize: 12.5,
                                                fontWeight: FontWeight.w600,
                                                letterSpacing: 0.3,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 18.0),

                                      // Logo locale con bordo decorativo
                                      Container(
                                        width: 80.0,
                                        height: 80.0,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: theme.colorScheme.primary
                                                .withValues(alpha: 0.4),
                                            width: 2.5,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: theme.colorScheme.primary
                                                  .withValues(alpha: 0.18),
                                              blurRadius: 16.0,
                                              offset: const Offset(0.0, 4.0),
                                            ),
                                          ],
                                        ),
                                        child: ClipOval(
                                          child: Image.network(
                                            valueOrDefault<String>(
                                              menuClienteUsersRecord.photoUrl,
                                              'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/pronto-menu-f0och1/assets/i4ccmvv80eni/IMG_8006.png',
                                            ),
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error,
                                                    stackTrace) =>
                                                Image.asset(
                                              'assets/images/IMG_8006.png',
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) => Icon(
                                                Icons.restaurant_rounded,
                                                size: 38.0,
                                                color: theme.colorScheme.primary,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 14.0),

                                      // Nome Locale
                                      if (menuClienteUsersRecord
                                          .displayName.isNotEmpty) ...[
                                        Text(
                                          TranslationService.getUi('benvenuto_da', _currentLang),
                                          style: theme.textTheme.labelSmall
                                              ?.copyWith(
                                            color: theme.hintColor
                                                .withValues(alpha: 0.8),
                                            letterSpacing: 1.5,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(height: 4.0),
                                        Text(
                                          menuClienteUsersRecord.displayName,
                                          textAlign: TextAlign.center,
                                          style: theme.textTheme.headlineSmall
                                              ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 22.0,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
              if (_isSpeedDialOpen)
                Positioned.fill(
                  child: GestureDetector(
                    onTap: _closeSpeedDial,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.35),
                    ),
                  ),
                ),
              if (menuClienteUsersRecord.jukeboxAttivo)
                Positioned(
                  bottom: 24.0,
                  left: 18.0,
                  child: Material(
                    elevation: 5.0,
                    borderRadius: BorderRadius.circular(24.0),
                    shadowColor:
                        const Color(0xFF1DB954).withValues(alpha: 0.35),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(24.0),
                      onTap: () {
                        JukeboxModalWidget.show(
                          context,
                          ristoranteRef: widget.ristoranteRef!,
                          ristorante: menuClienteUsersRecord,
                          currentLang: _currentLang,
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14.0,
                          vertical: 9.0,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1DB954),
                          borderRadius: BorderRadius.circular(24.0),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.music_note_rounded,
                              color: Colors.white,
                              size: 18.0,
                            ),
                            SizedBox(width: 6.0),
                            Text(
                              'Jukebox',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              Positioned(
                bottom: 24.0,
                right: 18.0,
                child: _buildFilterSpeedDial(theme),
              ),
            ],
          ),
        ),
      ),
    ),
  );
            },
          ),
        );
      },
    );
  }
}
