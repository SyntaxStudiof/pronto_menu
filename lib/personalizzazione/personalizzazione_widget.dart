import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/theme_provider.dart';
import '/app_themes.dart';
import 'personalizzazione_presets.dart';
import 'simulatore_menu_cliente_widget.dart';
import 'personalizzazione_model.dart';

export 'personalizzazione_model.dart';

class PersonalizzazioneWidget extends StatefulWidget {
  const PersonalizzazioneWidget({
    super.key,
    this.ristoranteRef,
    this.initialTab = 0,
    this.embedded = false,
  });

  final DocumentReference? ristoranteRef;
  final int initialTab;
  final bool embedded;

  static String routeName = 'personalizzazione';
  static String routePath = '/personalizzazione';

  @override
  State<PersonalizzazioneWidget> createState() =>
      _PersonalizzazioneWidgetState();
}

class _PersonalizzazioneWidgetState extends State<PersonalizzazioneWidget>
    with TickerProviderStateMixin {
  late PersonalizzazioneModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  // 0 = Design & Preset, 1 = Tipografia & Font
  late int _mainTab;

  // 0 = Titoli & Prezzi, 1 = Testi & Descrizioni
  int _fontTargetTab = 0;

  // Feedback interattivo sul finto pulsante del menu
  bool _isFakeButtonAdded = false;

  // Track dello stile appena cliccato per animare l'icona
  AppDesignStyle? _justClickedStyle;

  // Trigger per animazione elastica dell'icona del piatto in anteprima
  int _dishWiggleTrigger = 0;

  // Override modalità Chiaro/Scuro nel simulatore anteprima cliente desktop (null = eredita, true = dark, false = light)
  bool? _previewDarkModeOverride;

  // Font disponibili per Titoli (nomi dei piatti, prezzi, intestazioni)
  final List<FontOption> _titleFontOptions = const [
    FontOption('Playfair Display', 'Serif lusso ed eleganza classica', 'Fine dining & wine'),
    FontOption('Cinzel', 'Classico regale e maestoso', 'Enoteche & bistrot'),
    FontOption('Cormorant Garamond', 'Serif sottile e sofisticato', 'Gourmet d\'autore'),
    FontOption('Lora', 'Serif caloroso e leggibile', 'Trattorie & pizzerie'),
    FontOption('Rubik', 'Bold morbido e accogliente', 'Pub & burger house'),
    FontOption('Montserrat', 'Geometrico contemporaneo e pulito', 'Caffetterie & lounge'),
    FontOption('Bebas Neue', 'Display all-caps forte e incisivo', 'Steakhouse & barbecue'),
    FontOption('Oswald', 'Condensato dinamico e moderno', 'Street food & birrerie'),
    FontOption('Space Grotesk', 'Geometrico zen d\'avanguardia', 'Sushi & cucina fusion'),
    FontOption('Poppins', 'Geometrico arrotondato e solare', 'Poké & fast casual'),
    FontOption('Fraunces', 'Vintage materico espressivo', 'Forni & pasticcerie'),
  ];

  // Font disponibili per Testi & Dettagli (ingredienti, descrizioni, note)
  final List<FontOption> _bodyFontOptions = const [
    FontOption('Plus Jakarta Sans', 'Massima leggibilità contemporanea', 'Moderno e pulito'),
    FontOption('Inter', 'Trasparente, neutro e chiarissimo', 'Standard universale'),
    FontOption('Nunito', 'Morbido, arrotondato e amichevole', 'Accogliente e caldo'),
    FontOption('Roboto', 'Bilanciato e rassicurante', 'Leggibilità infallibile'),
    FontOption('Lato', 'Armonioso, caldo e proporzionato', 'Classico raffinato'),
    FontOption('Space Grotesk', 'Geometrico essenziale zen', 'Cucina contemporanea'),
    FontOption('Lora', 'Serif letterario caldo per descrizioni', 'Tradizione autentica'),
    FontOption('Open Sans', 'Universale e confortevole da leggere', 'Ampio respiro'),
    FontOption('Work Sans', 'Nitido, geometrico e rigoroso', 'Stile scandinavo'),
    FontOption('DM Sans', 'Compatto ad alto contrasto', 'Minimalista'),
  ];

  // Palette Colori Gourmet Selezionate
  final List<GourmetColorOption> _gourmetColors = const [
    GourmetColorOption('Oro Imperiale', 'Fine dining, champagne & wine bar', Color(0xFFC5A059), 'Lusso'),
    GourmetColorOption('Rosso Pizzeria', 'Pizzerie, trattorie tipiche e primi piatti', Color(0xFFB71C1C), 'Tradizione'),
    GourmetColorOption('Ambra & Birra', 'Pub, birrerie artigianali & burger house', Color(0xFFD97706), 'Rustico'),
    GourmetColorOption('Verde Salvia', 'Cucina biologica, agriturismi & poke green', Color(0xFF10B981), 'Fresco'),
    GourmetColorOption('Blu Mediterraneo', 'Specialità marinare & pesce fresco', Color(0xFF0284C7), 'Marino'),
    GourmetColorOption('Bordeaux Nobile', 'Enoteche, carni selezionate e cantine', Color(0xFF881337), 'Classico'),
    GourmetColorOption('Ardesia Zen', 'Sushi bar & cucina fusion contemporanea', Color(0xFF334155), 'Minimal'),
    GourmetColorOption('Terracotta Rustico', 'Osterie, forni a legna & bracerie', Color(0xFFEA580C), 'Autentico'),
    GourmetColorOption('Viola Lounge', 'Cocktail bar & locali serali d\'avanguardia', Color(0xFF7C3AED), 'Glamour'),
    GourmetColorOption('Lampone Vivace', 'Pasticcerie, dolci, pokè & fast casual', Color(0xFFE11D48), 'Vivace'),
    GourmetColorOption('Indaco Notte', 'Ristopub, lounge bar & bistrot moderni', Color(0xFF4F46E5), 'Moderno'),
    GourmetColorOption('Smeraldo Etnico', 'Tapas bar, ristoranti asiatici & messicani', Color(0xFF0D9488), 'Esotico'),
  ];

  late TextEditingController _hexController;
  late TextEditingController _bannerUrlController;
  bool _isSavingCloud = false;
  bool _isPreviewExpanded = true;
  bool _hasLoadedTheme = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PersonalizzazioneModel());
    _mainTab = widget.initialTab.clamp(0, 2);
    _hexController = TextEditingController();
    _bannerUrlController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
      _hexController.text = themeProvider.primaryColor
          .toARGB32()
          .toRadixString(16)
          .padLeft(8, '0')
          .substring(2)
          .toUpperCase();
      _bannerUrlController.text = themeProvider.coverBanner;
      _loadRestaurantTheme(themeProvider);
    });
  }

  @override
  void dispose() {
    _hexController.dispose();
    _bannerUrlController.dispose();
    _model.dispose();
    super.dispose();
  }

  Future<void> _loadRestaurantTheme(ThemeProvider themeProvider) async {
    if (_hasLoadedTheme) return;
    _hasLoadedTheme = true;
    try {
      final docRef = widget.ristoranteRef ?? currentUserReference;
      if (docRef != null) {
        final doc = await docRef.get();
        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>? ?? {};
          final tema = data['temaScelto'] as String?;
          final colore = data['colore_primario'] as String?;
          final fontTitoli = data['font_titoli'] as String?;
          final fontTesti = data['font_testi'] as String?;
          final layoutPiatti = data['layout_piatti'] as String?;
          final bannerCopertina = data['banner_copertina'] as String?;
          final textureSfondo = data['texture_sfondo'] as String?;
          final stileBadge = data['stile_badge'] as String?;

          if (tema != null ||
              colore != null ||
              fontTitoli != null ||
              fontTesti != null ||
              layoutPiatti != null ||
              bannerCopertina != null ||
              textureSfondo != null ||
              stileBadge != null) {
            themeProvider.syncFromRestaurant(
              temaScelto: tema,
              colorePrimarioHex: colore,
              fontTitoli: fontTitoli,
              fontTesti: fontTesti,
              layoutPiatti: layoutPiatti,
              bannerCopertina: bannerCopertina,
              textureSfondo: textureSfondo,
              stileBadge: stileBadge,
            );
            if (mounted) {
              _hexController.text = themeProvider.primaryColor
                  .toARGB32()
                  .toRadixString(16)
                  .padLeft(8, '0')
                  .substring(2)
                  .toUpperCase();
              _bannerUrlController.text = themeProvider.coverBanner;
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Errore caricamento tema ristorante: $e');
    }
  }

  Future<void> _publishThemeToCloud(ThemeProvider themeProvider) async {
    final docRef = widget.ristoranteRef ?? currentUserReference;
    if (docRef == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profilo ristorante non trovato per la sincronizzazione.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSavingCloud = true);

    try {
      final hexColor = '#${themeProvider.primaryColor.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
      await docRef.set({
        'temaScelto': themeProvider.designStyle.name,
        'colore_primario': hexColor,
        'font_titoli': themeProvider.titleFont,
        'font_testi': themeProvider.bodyFont,
        'layout_piatti': themeProvider.dishCardLayout.name,
        'banner_copertina': themeProvider.coverBanner,
        'texture_sfondo': themeProvider.backgroundTexture.name,
        'stile_badge': themeProvider.badgeStyle.value,
      }, SetOptions(merge: true));

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white, size: 22.0),
              SizedBox(width: 12.0),
              Expanded(
                child: Text(
                  'Stile pubblicato! Tutti i clienti vedranno subito la nuova grafica del menù.',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13.5,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          margin: const EdgeInsets.all(16.0),
          duration: const Duration(seconds: 4),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Errore durante la pubblicazione: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSavingCloud = false);
      }
    }
  }

  Future<void> _autoSaveToCloud(ThemeProvider themeProvider) async {
    try {
      final docRef = widget.ristoranteRef ?? currentUserReference;
      if (docRef == null) return;
      final hexColor = '#${themeProvider.primaryColor.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
      await docRef.set({
        'temaScelto': themeProvider.designStyle.name,
        'colore_primario': hexColor,
        'font_titoli': themeProvider.titleFont,
        'font_testi': themeProvider.bodyFont,
        'layout_piatti': themeProvider.dishCardLayout.name,
        'banner_copertina': themeProvider.coverBanner,
        'texture_sfondo': themeProvider.backgroundTexture.name,
        'stile_badge': themeProvider.badgeStyle.value,
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Errore auto-salvataggio tema cloud: $e');
    }
  }

  void _onFakeButtonTap() {
    setState(() {
      _isFakeButtonAdded = true;
    });
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (mounted) {
        setState(() {
          _isFakeButtonAdded = false;
        });
      }
    });
  }

  void _selectPreset(ThemeProvider themeProvider, AppDesignStyle preset) {
    setState(() {
      _justClickedStyle = preset;
      _dishWiggleTrigger++;
    });
    themeProvider.setDesignStyle(preset);
    _hexController.text = preset.defaultPrimaryColor
        .toARGB32()
        .toRadixString(16)
        .padLeft(8, '0')
        .substring(2)
        .toUpperCase();
    _autoSaveToCloud(themeProvider);
  }

  void _openSimulator(BuildContext context, ThemeProvider themeProvider) {
    final docRef = widget.ristoranteRef ?? currentUserReference;
    if (docRef == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ristorante non trovato.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    SimulatoreMenuClienteWidget.open(
      context,
      ristoranteRef: docRef,
      initialDesignStyle: themeProvider.designStyle,
      initialPrimaryColor: themeProvider.primaryColor,
      initialTitleFont: themeProvider.titleFont,
      initialBodyFont: themeProvider.bodyFont,
      initialDishLayout: themeProvider.dishCardLayout,
      initialCoverBanner: themeProvider.coverBanner,
      initialBackgroundTexture: themeProvider.backgroundTexture,
      initialBadgeStyle: themeProvider.badgeStyle,
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final customTheme = theme.appCustomTheme;
    final currentStyle = themeProvider.designStyle;
    final primaryColor = themeProvider.primaryColor;
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: colorScheme.surfaceContainerLowest,
        appBar: widget.embedded
            ? null
            : AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          automaticallyImplyLeading: false,
          leading: FlutterFlowIconButton(
            borderColor: Colors.transparent,
            borderRadius: 30.0,
            borderWidth: 0.0,
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
                  color: colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.palette_rounded,
                  color: colorScheme.primary,
                  size: 20.0,
                ),
              ),
              const SizedBox(width: 10.0),
              Text(
                'Personalizzazione',
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
          centerTitle: true,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 4.0),
              child: IconButton(
                tooltip: 'Simulatore Menù dal Vivo',
                icon: Container(
                  width: 36.0,
                  height: 36.0,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.smartphone_rounded,
                    color: colorScheme.primary,
                    size: 20.0,
                  ),
                ),
                onPressed: () => _openSimulator(context, themeProvider),
              ),
            ),
          ],
        ),
        body: SafeArea(
          top: true,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth >= 900 || widget.embedded;

              if (isDesktop) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ═════════════════════════════════════════════════════════
                    // 1. HEADER STUDIO STATS & KPI RAPIDI
                    // ═════════════════════════════════════════════════════════
                    _buildStudioMetricBar(
                      context: context,
                      themeProvider: themeProvider,
                      currentStyle: currentStyle,
                      primaryColor: primaryColor,
                      isDark: isDark,
                      colorScheme: colorScheme,
                    ),

                    // ═════════════════════════════════════════════════════════
                    // 2. CORPO DIVISO: CONTROLLI (SX) & DEVICE STUDIO (DX)
                    // ═════════════════════════════════════════════════════════
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Colonna Sinistra (~55%): Tab, Controlli, Palette, Salva
                          Expanded(
                            flex: 6,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Switcher principale dei Tab
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(28.0, 8.0, 28.0, 10.0),
                                  child: _buildMain3TabSwitcher(
                                    context: context,
                                    primaryColor: primaryColor,
                                    isDark: isDark,
                                  ),
                                ),

                                // Area scrollabile dei controlli
                                Expanded(
                                  child: SingleChildScrollView(
                                    padding: const EdgeInsets.fromLTRB(28.0, 6.0, 28.0, 24.0),
                                    child: AnimatedSwitcher(
                                      duration: const Duration(milliseconds: 250),
                                      child: switch (_mainTab) {
                                        0 => _buildBrandAndStyleTab(
                                            key: const ValueKey('brand_style_tab'),
                                            context: context,
                                            themeProvider: themeProvider,
                                            currentStyle: currentStyle,
                                            primaryColor: primaryColor,
                                            isDark: isDark,
                                            isDesktop: true,
                                          ),
                                        1 => _buildDishesAndBadgesTab(
                                            key: const ValueKey('dishes_badges_tab'),
                                            context: context,
                                            themeProvider: themeProvider,
                                            primaryColor: primaryColor,
                                            isDark: isDark,
                                          ),
                                        _ => _buildBackgroundAndCoverTab(
                                            key: const ValueKey('bg_cover_tab'),
                                            context: context,
                                            themeProvider: themeProvider,
                                            primaryColor: primaryColor,
                                            isDark: isDark,
                                          ),
                                      },
                                    ),
                                  ),
                                ),

                                // Barra di pubblicazione fissa in basso
                                _buildPublishBottomBar(
                                  context: context,
                                  themeProvider: themeProvider,
                                  primaryColor: primaryColor,
                                  isDark: isDark,
                                ),
                              ],
                            ),
                          ),

                          // Divisore verticale
                          VerticalDivider(
                            width: 1.0,
                            thickness: 1.0,
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.08)
                                : const Color(0xFFE2E8F0),
                          ),

                          // Colonna Destra (~45%): Live Mobile Device Studio
                          Expanded(
                            flex: 5,
                            child: _buildDesktopPhoneStudio(
                              context: context,
                              themeProvider: themeProvider,
                              currentStyle: currentStyle,
                              primaryColor: primaryColor,
                              isDark: isDark,
                              customTheme: customTheme,
                              colorScheme: colorScheme,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }

              // Modalità Mobile classica
              return Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 680.0),
                  child: Column(
                    children: [
                      // Area fissa in alto
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildStickyPreviewCard(
                              context: context,
                              themeProvider: themeProvider,
                              style: currentStyle,
                              primaryColor: primaryColor,
                              isDark: isDark,
                              customTheme: customTheme,
                              titleFont: themeProvider.titleFont,
                              bodyFont: themeProvider.bodyFont,
                            ),
                            const SizedBox(height: 8.0),
                            _buildMain3TabSwitcher(
                              context: context,
                              primaryColor: primaryColor,
                              isDark: isDark,
                            ),
                            const SizedBox(height: 6.0),
                          ],
                        ),
                      ),

                      // Area scrollabile
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 6.0,
                          ),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            child: switch (_mainTab) {
                              0 => _buildBrandAndStyleTab(
                                  key: const ValueKey('brand_style_tab'),
                                  context: context,
                                  themeProvider: themeProvider,
                                  currentStyle: currentStyle,
                                  primaryColor: primaryColor,
                                  isDark: isDark,
                                ),
                              1 => _buildDishesAndBadgesTab(
                                  key: const ValueKey('dishes_badges_tab'),
                                  context: context,
                                  themeProvider: themeProvider,
                                  primaryColor: primaryColor,
                                  isDark: isDark,
                                ),
                              _ => _buildBackgroundAndCoverTab(
                                  key: const ValueKey('bg_cover_tab'),
                                  context: context,
                                  themeProvider: themeProvider,
                                  primaryColor: primaryColor,
                                  isDark: isDark,
                                ),
                            },
                          ),
                        ),
                      ),

                      // Bottone Salva & Pubblica
                      _buildPublishBottomBar(
                        context: context,
                        themeProvider: themeProvider,
                        primaryColor: primaryColor,
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ═══════════════════════════════════════════════════════════════════════════
  // 1. COMPONENTI DI SUPPORTO & SELETTORI
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildMiniThemeModeSegment({
    required ThemeProvider themeProvider,
    required Color primaryColor,
    required bool isDark,
    required ColorScheme colorScheme,
  }) {
    final currentMode = themeProvider.themeMode;
    return Container(
      padding: const EdgeInsets.all(2.0),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildMiniThemeBtn(
            icon: Icons.wb_sunny_rounded,
            isSelected: currentMode == ThemeMode.light,
            tooltip: 'Chiaro',
            primaryColor: primaryColor,
            isDark: isDark,
            onTap: () => themeProvider.setThemeMode(ThemeMode.light),
          ),
          _buildMiniThemeBtn(
            icon: Icons.dark_mode_rounded,
            isSelected: currentMode == ThemeMode.dark,
            tooltip: 'Scuro',
            primaryColor: primaryColor,
            isDark: isDark,
            onTap: () => themeProvider.setThemeMode(ThemeMode.dark),
          ),
          _buildMiniThemeBtn(
            icon: Icons.devices_rounded,
            isSelected: currentMode == ThemeMode.system,
            tooltip: 'Sistema',
            primaryColor: primaryColor,
            isDark: isDark,
            onTap: () => themeProvider.setThemeMode(ThemeMode.system),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniThemeBtn({
    required IconData icon,
    required bool isSelected,
    required String tooltip,
    required Color primaryColor,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6.0),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(4.5),
          decoration: BoxDecoration(
            color: isSelected ? primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(6.0),
          ),
          child: Icon(
            icon,
            size: 13.0,
            color: isSelected
                ? Colors.white
                : (isDark ? Colors.white70 : Colors.black54),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color primaryColor,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 4.0, bottom: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7.0),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Icon(icon, size: 16.0, color: primaryColor),
          ),
          const SizedBox(width: 10.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.2,
                  ),
                ),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 1B. KPI STUDIO METRIC BAR & SMARTPHONE LIVE STUDIO (DESKTOP WORKSPACE)
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildStudioMetricBar({
    required BuildContext context,
    required ThemeProvider themeProvider,
    required AppDesignStyle currentStyle,
    required Color primaryColor,
    required bool isDark,
    required ColorScheme colorScheme,
  }) {
    final hexCode = '#${primaryColor.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
    final layoutName = themeProvider.dishCardLayout.displayName.split(' ').first;
    final badgeName = themeProvider.badgeStyle.displayName;

    return Padding(
      padding: const EdgeInsets.fromLTRB(28.0, 16.0, 28.0, 12.0),
      child: Row(
        children: [
          Expanded(
            child: _buildStudioKpiCard(
              title: 'Mood & Preset',
              value: currentStyle.displayName,
              subtitle: currentStyle.targetAudience,
              icon: currentStyle.defaultIcon,
              color: currentStyle.defaultPrimaryColor,
              isDark: isDark,
            ),
          ),
          const SizedBox(width: 14.0),
          Expanded(
            child: _buildStudioKpiCard(
              title: 'Colore Brand',
              value: hexCode,
              subtitle: primaryColor.computeLuminance() > 0.4 ? 'Tonalità Chiara' : 'Tonalità Intensa',
              icon: Icons.palette_rounded,
              color: primaryColor,
              isDark: isDark,
              swatchColor: primaryColor,
            ),
          ),
          const SizedBox(width: 14.0),
          Expanded(
            child: _buildStudioKpiCard(
              title: 'Layout & Font',
              value: layoutName,
              subtitle: '${themeProvider.titleFont} • ${themeProvider.bodyFont}',
              icon: Icons.auto_awesome_mosaic_rounded,
              color: const Color(0xFF3B82F6),
              isDark: isDark,
            ),
          ),
          const SizedBox(width: 14.0),
          Expanded(
            child: _buildStudioKpiCard(
              title: 'Badge & Menù Live',
              value: badgeName,
              subtitle: 'Sincronizzato sul QR',
              icon: Icons.verified_rounded,
              color: const Color(0xFF10B981),
              isDark: isDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudioKpiCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isDark,
    Color? swatchColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 13.0),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.03),
            blurRadius: 8.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42.0,
            height: 42.0,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Center(
              child: swatchColor != null
                  ? Container(
                      width: 20.0,
                      height: 20.0,
                      decoration: BoxDecoration(
                        color: swatchColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark ? Colors.white30 : Colors.black12,
                          width: 1.5,
                        ),
                      ),
                    )
                  : Icon(icon, color: color, size: 21.0),
            ),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 2.0),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 1.5),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10.5,
                    color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopPhoneStudio({
    required BuildContext context,
    required ThemeProvider themeProvider,
    required AppDesignStyle currentStyle,
    required Color primaryColor,
    required bool isDark,
    required AppCustomTheme? customTheme,
    required ColorScheme colorScheme,
  }) {
    final clientDark = _previewDarkModeOverride ?? isDark;
    final resolvedBanner = PersonalizzazionePresets.resolveBannerUrl(themeProvider.coverBanner);
    final hasTexture = themeProvider.backgroundTexture != BackgroundTexture.nessuna;
    final textureDecoration = PersonalizzazionePresets.getTextureDecoration(
      texture: themeProvider.backgroundTexture,
      isDark: clientDark,
      theme: Theme.of(context),
    );
    final restaurantName = currentUserDocument?.displayName.isNotEmpty == true
        ? currentUserDocument!.displayName
        : 'Pizzeria Pantesca';
    final dishLayout = themeProvider.dishCardLayout;
    final badgeStyle = themeProvider.badgeStyle;
    final titleFont = themeProvider.titleFont;
    final bodyFont = themeProvider.bodyFont;

    return Container(
      color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      padding: const EdgeInsets.fromLTRB(24.0, 8.0, 28.0, 20.0),
      child: Column(
        children: [
          // ── 1. Studio Toolbar Superiore ───────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(14.0),
              border: Border.all(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                  blurRadius: 8.0,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Live Dot + Label
                Container(
                  width: 8.0,
                  height: 8.0,
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF10B981).withValues(alpha: 0.6),
                        blurRadius: 6.0,
                        spreadRadius: 1.5,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8.0),
                Text(
                  'STUDIO ANTEPRIMA MENÙ',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(width: 8.0),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                  child: const Text(
                    'Live Sync',
                    style: TextStyle(
                      fontSize: 10.0,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF10B981),
                    ),
                  ),
                ),
                const Spacer(),
                // Selettore Tema Menù Cliente (Chiaro / Scuro)
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  padding: const EdgeInsets.all(2.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: () => setState(() => _previewDarkModeOverride = false),
                        borderRadius: BorderRadius.circular(6.0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.5),
                          decoration: BoxDecoration(
                            color: !clientDark
                                ? (isDark ? const Color(0xFF334155) : Colors.white)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(6.0),
                            boxShadow: !clientDark
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.08),
                                      blurRadius: 4.0,
                                    )
                                  ]
                                : null,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.light_mode_rounded,
                                size: 13.0,
                                color: !clientDark ? const Color(0xFFF59E0B) : const Color(0xFF94A3B8),
                              ),
                              const SizedBox(width: 4.0),
                              Text(
                                'Chiaro',
                                style: TextStyle(
                                  fontSize: 11.0,
                                  fontWeight: FontWeight.w600,
                                  color: !clientDark
                                      ? (isDark ? Colors.white : const Color(0xFF0F172A))
                                      : const Color(0xFF94A3B8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () => setState(() => _previewDarkModeOverride = true),
                        borderRadius: BorderRadius.circular(6.0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.5),
                          decoration: BoxDecoration(
                            color: clientDark
                                ? (isDark ? const Color(0xFF334155) : Colors.white)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(6.0),
                            boxShadow: clientDark
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.08),
                                      blurRadius: 4.0,
                                    )
                                  ]
                                : null,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.dark_mode_rounded,
                                size: 13.0,
                                color: clientDark ? const Color(0xFF818CF8) : const Color(0xFF94A3B8),
                              ),
                              const SizedBox(width: 4.0),
                              Text(
                                'Scuro',
                                style: TextStyle(
                                  fontSize: 11.0,
                                  fontWeight: FontWeight.w600,
                                  color: clientDark
                                      ? (isDark ? Colors.white : const Color(0xFF0F172A))
                                      : const Color(0xFF94A3B8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8.0),
                // Tasto fullscreen simulatore
                Tooltip(
                  message: 'Apri Simulatore a Schermo Intero',
                  child: InkWell(
                    onTap: () => _openSimulator(context, themeProvider),
                    borderRadius: BorderRadius.circular(8.0),
                    child: Container(
                      padding: const EdgeInsets.all(6.0),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Icon(Icons.fullscreen_rounded, size: 18.0, color: colorScheme.primary),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12.0),

          // ── 2. Mockup Smartphone Interattivo ──────────────────────────────
          Expanded(
            child: Center(
              child: Container(
                width: 375.0,
                decoration: BoxDecoration(
                  color: clientDark ? const Color(0xFF0B1120) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(38.0),
                  border: Border.all(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFF94A3B8),
                    width: 7.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.6 : 0.16),
                      blurRadius: 26.0,
                      spreadRadius: 2.0,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(31.0),
                  child: Container(
                    decoration: hasTexture
                        ? textureDecoration
                        : BoxDecoration(
                            color: clientDark ? const Color(0xFF0F172A) : const Color(0xFFFFFFFF),
                          ),
                    child: Column(
                      children: [
                        // A. Barra di Stato & Dynamic Island
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 6.0),
                          color: clientDark ? Colors.black.withValues(alpha: 0.6) : Colors.black.withValues(alpha: 0.05),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '12:30',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                  color: clientDark ? Colors.white : Colors.black87,
                                ),
                              ),
                              // Dynamic Island
                              Container(
                                width: 80.0,
                                height: 16.0,
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                              Row(
                                children: [
                                  Icon(Icons.wifi_rounded, size: 13.0, color: clientDark ? Colors.white : Colors.black87),
                                  const SizedBox(width: 4.0),
                                  Icon(Icons.battery_full_rounded, size: 14.0, color: clientDark ? Colors.white : Colors.black87),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // B. Schermo scorrevole del menù cliente
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(12.0, 8.0, 12.0, 12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Cover Banner & Info Ristorante
                                _buildMockupRestaurantHeader(
                                  bannerUrl: resolvedBanner,
                                  restaurantName: restaurantName,
                                  titleFont: titleFont,
                                  primaryColor: primaryColor,
                                  clientDark: clientDark,
                                ),

                                const SizedBox(height: 10.0),

                                // Categorie a Scorrimento
                                _buildMockupCategories(
                                  primaryColor: primaryColor,
                                  titleFont: titleFont,
                                  clientDark: clientDark,
                                ),

                                const SizedBox(height: 12.0),

                                // Piatti reattivi al layout selezionato (Classico, Foto Grande, Griglia 2 Col, Minimale)
                                _buildMockupDishesSection(
                                  context: context,
                                  dishLayout: dishLayout,
                                  badgeStyle: badgeStyle,
                                  currentStyle: currentStyle,
                                  primaryColor: primaryColor,
                                  titleFont: titleFont,
                                  bodyFont: bodyFont,
                                  clientDark: clientDark,
                                ),

                                const SizedBox(height: 8.0),
                              ],
                            ),
                          ),
                        ),

                        // C. Barra Carrello Flottante in basso al telefono
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
                          decoration: BoxDecoration(
                            color: clientDark ? const Color(0xFF1E293B) : Colors.white,
                            border: Border(
                              top: BorderSide(
                                color: clientDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 8.0,
                                    height: 8.0,
                                    decoration: BoxDecoration(
                                      color: primaryColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8.0),
                                  Text(
                                    '1 Piatto • € 8,50',
                                    style: GoogleFonts.getFont(
                                      titleFont,
                                      textStyle: TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.bold,
                                        color: clientDark ? Colors.white : const Color(0xFF0F172A),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                                decoration: BoxDecoration(
                                  color: primaryColor,
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.shopping_bag_outlined, size: 13.0, color: Colors.white),
                                    const SizedBox(width: 4.0),
                                    Text(
                                      'Carrello',
                                      style: GoogleFonts.getFont(
                                        titleFont,
                                        textStyle: const TextStyle(
                                          fontSize: 11.0,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
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
            ),
          ),

          const SizedBox(height: 10.0),

          // ── 3. Box Guida & Info per il Ristoratore ─────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.tips_and_updates_outlined, size: 16.0, color: colorScheme.primary),
                const SizedBox(width: 8.0),
                Expanded(
                  child: Text(
                    'Tutti i cambiamenti a font, colori, badge e stile dei piatti si riflettono in tempo reale in questo simulatore prima della pubblicazione.',
                    style: TextStyle(
                      fontSize: 11.0,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMockupRestaurantHeader({
    required String bannerUrl,
    required String restaurantName,
    required String titleFont,
    required Color primaryColor,
    required bool clientDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: clientDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(14.0),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (bannerUrl.isNotEmpty)
            Image.network(
              bannerUrl,
              height: 75.0,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 55.0,
                color: primaryColor.withValues(alpha: 0.15),
                child: Center(child: Icon(Icons.restaurant_rounded, color: primaryColor)),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Container(
                  width: 34.0,
                  height: 34.0,
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
                  ),
                  child: Center(
                    child: Icon(Icons.restaurant_menu_rounded, color: primaryColor, size: 18.0),
                  ),
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        restaurantName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.getFont(
                          titleFont,
                          textStyle: TextStyle(
                            fontSize: 13.0,
                            fontWeight: FontWeight.bold,
                            color: clientDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                      ),
                      const SizedBox(height: 2.0),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, size: 12.0, color: Color(0xFFF59E0B)),
                          const SizedBox(width: 3.0),
                          Text(
                            '4.9 • Aperto • Tavolo 4',
                            style: TextStyle(
                              fontSize: 10.0,
                              color: clientDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMockupCategories({
    required Color primaryColor,
    required String titleFont,
    required bool clientDark,
  }) {
    final categories = ['🍕 Pizze', '🥗 Antipasti', '🍺 Birre', '🍰 Dolci'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.asMap().entries.map((entry) {
          final isFirst = entry.key == 0;
          return Padding(
            padding: const EdgeInsets.only(right: 6.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 9.0, vertical: 4.5),
              decoration: BoxDecoration(
                color: isFirst
                    ? primaryColor
                    : (clientDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(
                entry.value,
                style: GoogleFonts.getFont(
                  titleFont,
                  textStyle: TextStyle(
                    fontSize: 10.5,
                    fontWeight: isFirst ? FontWeight.bold : FontWeight.w500,
                    color: isFirst
                        ? Colors.white
                        : (clientDark ? const Color(0xFF94A3B8) : const Color(0xFF475569)),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMockupDishesSection({
    required BuildContext context,
    required DishCardLayout dishLayout,
    required BadgeStyle badgeStyle,
    required AppDesignStyle currentStyle,
    required Color primaryColor,
    required String titleFont,
    required String bodyFont,
    required bool clientDark,
  }) {
    switch (dishLayout) {
      case DishCardLayout.griglia:
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildMockupGridDishCard(
                context: context,
                name: 'Margherita DOP',
                description: 'Pomodoro San Marzano DOP, mozzarella di bufala campana',
                price: '€ 8,50',
                badgeLabel: 'CONSIGLIATO',
                imageUrl: 'https://images.unsplash.com/photo-1574071318508-1cdbab80d002?auto=format&fit=crop&w=400&q=80',
                badgeStyle: badgeStyle,
                style: currentStyle,
                primaryColor: primaryColor,
                titleFont: titleFont,
                bodyFont: bodyFont,
                clientDark: clientDark,
              ),
            ),
            const SizedBox(width: 8.0),
            Expanded(
              child: _buildMockupGridDishCard(
                context: context,
                name: 'Vesuvio Piccante',
                description: 'Salame piccante di Spilinga, fiordilatte, \'nduja',
                price: '€ 10,50',
                badgeLabel: 'PICCANTE 🌶️',
                imageUrl: 'https://images.unsplash.com/photo-1628840042765-356cda07504e?auto=format&fit=crop&w=400&q=80',
                badgeStyle: badgeStyle,
                style: currentStyle,
                primaryColor: primaryColor,
                titleFont: titleFont,
                bodyFont: bodyFont,
                clientDark: clientDark,
              ),
            ),
          ],
        );

      case DishCardLayout.minimale:
        return Container(
          decoration: BoxDecoration(
            color: clientDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(
              color: clientDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: clientDark ? 0.2 : 0.04),
                blurRadius: 6.0,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 11.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildMockupMinimaleDishCard(
                context: context,
                name: 'Pizza Margherita DOP',
                description: 'Pomodoro San Marzano DOP, mozzarella di bufala campana, basilico fresco, olio EVO',
                price: '€ 8,50',
                badgeLabel: 'CONSIGLIATO',
                badgeStyle: badgeStyle,
                style: currentStyle,
                primaryColor: primaryColor,
                titleFont: titleFont,
                bodyFont: bodyFont,
                clientDark: clientDark,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Divider(
                  color: clientDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFE2E8F0),
                  height: 1.0,
                  thickness: 1.0,
                ),
              ),
              _buildMockupMinimaleDishCard(
                context: context,
                name: 'Pizza Vesuvio Piccante',
                description: 'Salame piccante di Spilinga, fiordilatte, \'nduja calabrese, peperoncino fresco',
                price: '€ 10,50',
                badgeLabel: 'PICCANTE 🌶️',
                badgeStyle: badgeStyle,
                style: currentStyle,
                primaryColor: primaryColor,
                titleFont: titleFont,
                bodyFont: bodyFont,
                clientDark: clientDark,
              ),
            ],
          ),
        );

      case DishCardLayout.fotoGrande:
      case DishCardLayout.classico:
        return Column(
          children: [
            _buildMockupDishCard(
              context: context,
              name: 'Pizza Margherita DOP',
              description: 'Pomodoro San Marzano DOP, mozzarella di bufala campana, basilico fresco, olio EVO',
              price: '€ 8,50',
              badgeLabel: 'CONSIGLIATO',
              imageUrl: 'https://images.unsplash.com/photo-1574071318508-1cdbab80d002?auto=format&fit=crop&w=400&q=80',
              layout: dishLayout,
              badgeStyle: badgeStyle,
              style: currentStyle,
              primaryColor: primaryColor,
              titleFont: titleFont,
              bodyFont: bodyFont,
              clientDark: clientDark,
            ),
            const SizedBox(height: 9.0),
            _buildMockupDishCard(
              context: context,
              name: 'Pizza Vesuvio Piccante',
              description: 'Salame piccante di Spilinga, fiordilatte, \'nduja calabrese, peperoncino fresco',
              price: '€ 10,50',
              badgeLabel: 'PICCANTE 🌶️',
              imageUrl: 'https://images.unsplash.com/photo-1628840042765-356cda07504e?auto=format&fit=crop&w=400&q=80',
              layout: dishLayout,
              badgeStyle: badgeStyle,
              style: currentStyle,
              primaryColor: primaryColor,
              titleFont: titleFont,
              bodyFont: bodyFont,
              clientDark: clientDark,
            ),
          ],
        );
    }
  }

  Widget _buildMockupGridDishCard({
    required BuildContext context,
    required String name,
    required String description,
    required String price,
    required String badgeLabel,
    required String imageUrl,
    required BadgeStyle badgeStyle,
    required AppDesignStyle style,
    required Color primaryColor,
    required String titleFont,
    required String bodyFont,
    required bool clientDark,
  }) {
    final BorderRadius cardRadius = switch (style) {
      AppDesignStyle.premium => BorderRadius.circular(6.0),
      AppDesignStyle.pub => BorderRadius.circular(16.0),
      AppDesignStyle.minimal => BorderRadius.zero,
      AppDesignStyle.tradizionale => BorderRadius.circular(12.0),
    };

    final badgeDeco = PersonalizzazionePresets.getBadgeDecoration(
      style: badgeStyle,
      baseColor: primaryColor,
      isDark: clientDark,
      isFilled: true,
    );
    final badgeTextColor = PersonalizzazionePresets.getBadgeTextColor(
      style: badgeStyle,
      baseColor: primaryColor,
      isDark: clientDark,
      isFilled: true,
    );

    final cardBg = clientDark ? const Color(0xFF1E293B) : Colors.white;
    final cardBorder = clientDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: cardRadius,
        border: Border.all(color: cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: clientDark ? 0.2 : 0.04),
            blurRadius: 6.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            children: [
              Image.network(
                imageUrl,
                height: 76.0,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 76.0,
                  color: primaryColor.withValues(alpha: 0.1),
                  child: Center(child: Icon(Icons.fastfood_rounded, color: primaryColor, size: 22.0)),
                ),
              ),
              Positioned(
                top: 5.0,
                left: 5.0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 2.0),
                  decoration: badgeDeco,
                  child: Text(
                    badgeLabel,
                    style: TextStyle(
                      fontSize: 7.5,
                      fontWeight: FontWeight.bold,
                      color: badgeTextColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(7.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.getFont(
                    titleFont,
                    textStyle: TextStyle(
                      fontSize: 11.0,
                      fontWeight: FontWeight.bold,
                      color: clientDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                ),
                const SizedBox(height: 2.0),
                Text(
                  description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.getFont(
                    bodyFont,
                    textStyle: TextStyle(
                      fontSize: 8.5,
                      color: clientDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                  ),
                ),
                const SizedBox(height: 6.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5.5, vertical: 2.0),
                      decoration: badgeDeco,
                      child: Text(
                        price,
                        style: GoogleFonts.getFont(
                          titleFont,
                          textStyle: TextStyle(
                            fontSize: 10.0,
                            fontWeight: FontWeight.bold,
                            color: badgeTextColor,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: 22.0,
                      height: 22.0,
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(6.0),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 14.0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMockupMinimaleDishCard({
    required BuildContext context,
    required String name,
    required String description,
    required String price,
    required String badgeLabel,
    required BadgeStyle badgeStyle,
    required AppDesignStyle style,
    required Color primaryColor,
    required String titleFont,
    required String bodyFont,
    required bool clientDark,
  }) {
    final badgeDeco = PersonalizzazionePresets.getBadgeDecoration(
      style: badgeStyle,
      baseColor: primaryColor,
      isDark: clientDark,
      isFilled: true,
    );
    final badgeTextColor = PersonalizzazionePresets.getBadgeTextColor(
      style: badgeStyle,
      baseColor: primaryColor,
      isDark: clientDark,
      isFilled: true,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.getFont(
                            titleFont,
                            textStyle: TextStyle(
                              fontSize: 12.0,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.2,
                              color: clientDark ? Colors.white : const Color(0xFF0F172A),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 5.0),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4.5, vertical: 1.5),
                        decoration: badgeDeco,
                        child: Text(
                          badgeLabel,
                          style: TextStyle(
                            fontSize: 7.5,
                            fontWeight: FontWeight.bold,
                            color: badgeTextColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2.0),
                  Text(
                    description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.getFont(
                      bodyFont,
                      textStyle: TextStyle(
                        fontSize: 9.0,
                        color: clientDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        height: 1.25,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.5),
                  decoration: badgeDeco,
                  child: Text(
                    price,
                    style: GoogleFonts.getFont(
                      titleFont,
                      textStyle: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        color: badgeTextColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4.0),
                Container(
                  width: 22.0,
                  height: 22.0,
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.add,
                    color: primaryColor,
                    size: 14.0,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMockupDishCard({
    required BuildContext context,
    required String name,
    required String description,
    required String price,
    required String badgeLabel,
    required String imageUrl,
    required DishCardLayout layout,
    required BadgeStyle badgeStyle,
    required AppDesignStyle style,
    required Color primaryColor,
    required String titleFont,
    required String bodyFont,
    required bool clientDark,
  }) {
    if (layout == DishCardLayout.griglia) {
      return _buildMockupGridDishCard(
        context: context,
        name: name,
        description: description,
        price: price,
        badgeLabel: badgeLabel,
        imageUrl: imageUrl,
        badgeStyle: badgeStyle,
        style: style,
        primaryColor: primaryColor,
        titleFont: titleFont,
        bodyFont: bodyFont,
        clientDark: clientDark,
      );
    }

    if (layout == DishCardLayout.minimale) {
      return Container(
        decoration: BoxDecoration(
          color: clientDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: clientDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: clientDark ? 0.2 : 0.04),
              blurRadius: 6.0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
        child: _buildMockupMinimaleDishCard(
          context: context,
          name: name,
          description: description,
          price: price,
          badgeLabel: badgeLabel,
          badgeStyle: badgeStyle,
          style: style,
          primaryColor: primaryColor,
          titleFont: titleFont,
          bodyFont: bodyFont,
          clientDark: clientDark,
        ),
      );
    }

    final BorderRadius cardRadius = switch (style) {
      AppDesignStyle.premium => BorderRadius.circular(6.0),
      AppDesignStyle.pub => BorderRadius.circular(16.0),
      AppDesignStyle.minimal => BorderRadius.zero,
      AppDesignStyle.tradizionale => BorderRadius.circular(12.0),
    };

    final badgeDeco = PersonalizzazionePresets.getBadgeDecoration(
      style: badgeStyle,
      baseColor: primaryColor,
      isDark: clientDark,
      isFilled: true,
    );
    final badgeTextColor = PersonalizzazionePresets.getBadgeTextColor(
      style: badgeStyle,
      baseColor: primaryColor,
      isDark: clientDark,
      isFilled: true,
    );

    final cardBg = clientDark ? const Color(0xFF1E293B) : Colors.white;
    final cardBorder = clientDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

    if (layout == DishCardLayout.fotoGrande) {
      return Container(
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: cardRadius,
          border: Border.all(color: cardBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: clientDark ? 0.2 : 0.04),
              blurRadius: 6.0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              children: [
                Image.network(
                  imageUrl,
                  height: 85.0,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 85.0,
                    color: primaryColor.withValues(alpha: 0.1),
                    child: Center(child: Icon(Icons.fastfood_rounded, color: primaryColor)),
                  ),
                ),
                Positioned(
                  top: 6.0,
                  left: 6.0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.5),
                    decoration: badgeDeco,
                    child: Text(
                      badgeLabel,
                      style: TextStyle(
                        fontSize: 8.5,
                        fontWeight: FontWeight.bold,
                        color: badgeTextColor,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 6.0,
                  right: 6.0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7.0, vertical: 3.5),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                    child: Text(
                      price,
                      style: GoogleFonts.getFont(
                        titleFont,
                        textStyle: const TextStyle(
                          fontSize: 11.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(9.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.getFont(
                      titleFont,
                      textStyle: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color: clientDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                  ),
                  const SizedBox(height: 2.5),
                  Text(
                    description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.getFont(
                      bodyFont,
                      textStyle: TextStyle(
                        fontSize: 10.0,
                        color: clientDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        height: 1.3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 7.0),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9.0, vertical: 4.0),
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: cardRadius,
                      ),
                      child: Text(
                        '+ Aggiungi',
                        style: GoogleFonts.getFont(
                          titleFont,
                          textStyle: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Default Standard & Compatto (Classico Orizzontale)
    return Container(
      padding: const EdgeInsets.all(9.0),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: cardRadius,
        border: Border.all(color: cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: clientDark ? 0.2 : 0.04),
            blurRadius: 6.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: cardRadius,
            child: Image.network(
              imageUrl,
              width: 62.0,
              height: 62.0,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 62.0,
                height: 62.0,
                color: primaryColor.withValues(alpha: 0.1),
                child: Center(child: Icon(Icons.fastfood_rounded, color: primaryColor)),
              ),
            ),
          ),
          const SizedBox(width: 9.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.getFont(
                          titleFont,
                          textStyle: TextStyle(
                            fontSize: 12.0,
                            fontWeight: FontWeight.bold,
                            color: clientDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                      ),
                    ),
                    Text(
                      price,
                      style: GoogleFonts.getFont(
                        titleFont,
                        textStyle: TextStyle(
                          fontSize: 12.0,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2.5),
                Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.getFont(
                    bodyFont,
                    textStyle: TextStyle(
                      fontSize: 9.5,
                      color: clientDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      height: 1.3,
                    ),
                  ),
                ),
                const SizedBox(height: 5.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 2.0),
                      decoration: badgeDeco,
                      child: Text(
                        badgeLabel,
                        style: TextStyle(
                          fontSize: 8.5,
                          fontWeight: FontWeight.bold,
                          color: badgeTextColor,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6.0),
                      ),
                      child: Text(
                        '+ Aggiungi',
                        style: GoogleFonts.getFont(
                          titleFont,
                          textStyle: TextStyle(
                            fontSize: 10.0,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 2. FINESTRA DI ANTEPRIMA BLOCCATA IN ALTO (STICKY & COLLAPSIBLE)
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildStickyPreviewCard({
    required BuildContext context,
    required ThemeProvider themeProvider,
    required AppDesignStyle style,
    required Color primaryColor,
    required bool isDark,
    required AppCustomTheme? customTheme,
    required String titleFont,
    required String bodyFont,
    bool forceExpanded = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final IconData dishIcon = style.defaultIcon;
    final String styleTag = customTheme?.styleTag ?? 'FINE DINING';
    final resolvedBanner = PersonalizzazionePresets.resolveBannerUrl(themeProvider.coverBanner);
    final hasTexture = themeProvider.backgroundTexture != BackgroundTexture.nessuna;
    final textureDecoration = PersonalizzazionePresets.getTextureDecoration(
      texture: themeProvider.backgroundTexture,
      isDark: isDark,
      theme: theme,
    );
    final dishLayout = themeProvider.dishCardLayout;
    final isExpanded = forceExpanded || _isPreviewExpanded;

    final Color contrastPrimaryText = isDark
        ? (primaryColor.computeLuminance() < 0.40
            ? HSLColor.fromColor(primaryColor).withLightness(0.70).toColor()
            : primaryColor)
        : (primaryColor.computeLuminance() > 0.22
            ? HSLColor.fromColor(primaryColor).withLightness(0.32).withSaturation(0.85).toColor()
            : primaryColor);

    return Card(
      elevation: 2.0,
      shadowColor: isDark
          ? Colors.black.withValues(alpha: 0.4)
          : primaryColor.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
        side: BorderSide.none,
      ),
      color: hasTexture ? Colors.transparent : colorScheme.surface,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: hasTexture
            ? textureDecoration.copyWith(borderRadius: BorderRadius.circular(16.0))
            : BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(16.0),
              ),
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Barra di comando superiore dell'anteprima
            Row(
              children: [
                // Live Dot + "ANTEPRIMA"
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8.0,
                      height: 8.0,
                      decoration: BoxDecoration(
                        color: Colors.greenAccent.shade700,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.greenAccent.shade700.withValues(alpha: 0.5),
                            blurRadius: 4.0,
                            spreadRadius: 1.0,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6.0),
                    Text(
                      'ANTEPRIMA',
                      style: GoogleFonts.getFont(
                        titleFont,
                        textStyle: TextStyle(
                          fontSize: 11.0,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                          color: contrastPrimaryText,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8.0),
                // Se collassata, mostriamo subito il nome del preset
                if (!isExpanded) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: isDark ? 0.20 : 0.12),
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                    child: Text(
                      styleTag,
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: contrastPrimaryText,
                      ),
                    ),
                  ),
                ],
                const Spacer(),
                // Selettore compatto modalità Chiaro / Scuro integrato
                _buildMiniThemeModeSegment(
                  themeProvider: themeProvider,
                  primaryColor: primaryColor,
                  isDark: isDark,
                  colorScheme: colorScheme,
                ),
                const SizedBox(width: 6.0),
                // Tasto rapido simulatore a schermo intero
                Tooltip(
                  message: 'Simulatore Menù',
                  child: InkWell(
                    onTap: () => _openSimulator(context, themeProvider),
                    borderRadius: BorderRadius.circular(6.0),
                    child: Container(
                      padding: const EdgeInsets.all(4.5),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6.0),
                      ),
                      child: Icon(Icons.fullscreen_rounded, size: 15.0, color: primaryColor),
                    ),
                  ),
                ),
                if (!forceExpanded) ...[
                  const SizedBox(width: 4.0),
                  // Tasto espandi / riduci anteprima per dare più spazio
                  Tooltip(
                    message: _isPreviewExpanded ? 'Riduci anteprima' : 'Espandi anteprima',
                    child: InkWell(
                      onTap: () => setState(() => _isPreviewExpanded = !_isPreviewExpanded),
                      borderRadius: BorderRadius.circular(6.0),
                      child: Container(
                        padding: const EdgeInsets.all(4.5),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(6.0),
                        ),
                        child: Icon(
                          _isPreviewExpanded
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.keyboard_arrow_down_rounded,
                          size: 15.0,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),

            if (isExpanded) ...[
              const SizedBox(height: 8.0),
              // Sub-header tags: layout & style
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6.0, vertical: 2.5),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6.0),
                      border: Border.all(
                        color: primaryColor.withValues(alpha: 0.3),
                        width: 1.0,
                      ),
                    ),
                    child: Text(
                      dishLayout.displayName.split(' ').first.toUpperCase(),
                      style: GoogleFonts.getFont(
                        titleFont,
                        textStyle: TextStyle(
                          fontSize: 8.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.4,
                          color: primaryColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 5.0),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 7.0, vertical: 2.5),
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                    child: Text(
                      styleTag,
                      style: GoogleFonts.getFont(
                        titleFont,
                        textStyle: const TextStyle(
                          fontSize: 9.0,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              if (resolvedBanner.isNotEmpty) ...[
                const SizedBox(height: 8.0),
                Container(
                  height: 48.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    image: DecorationImage(
                      image: NetworkImage(resolvedBanner),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.65),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                    alignment: Alignment.bottomLeft,
                    child: Row(
                      children: [
                        const Icon(Icons.wallpaper_rounded, color: Colors.white, size: 13.0),
                        const SizedBox(width: 5.0),
                        Text(
                          'Banner Menu Attivo',
                          style: GoogleFonts.getFont(
                            titleFont,
                            textStyle: const TextStyle(
                              color: Colors.white,
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 8.0),

              // Dettagli piatto (Pizza Margherita) animato in base al DishCardLayout e BadgeStyle
              _buildDishCardPreviewBody(
                context: context,
                style: style,
                dishLayout: dishLayout,
                badgeStyle: themeProvider.badgeStyle,
                primaryColor: primaryColor,
                dishIcon: dishIcon,
                titleFont: titleFont,
                bodyFont: bodyFont,
                colorScheme: colorScheme,
                isDark: isDark,
              ),

              const SizedBox(height: 8.0),

              // Pulsante interattivo compatto con titleFont
              _buildInteractiveFakeButton(style, primaryColor, titleFont),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDishCardPreviewBody({
    required BuildContext context,
    required AppDesignStyle style,
    required DishCardLayout dishLayout,
    required BadgeStyle badgeStyle,
    required Color primaryColor,
    required IconData dishIcon,
    required String titleFont,
    required String bodyFont,
    required ColorScheme colorScheme,
    required bool isDark,
  }) {
    final BorderRadius radius = switch (style) {
      AppDesignStyle.premium => BorderRadius.circular(6.0),
      AppDesignStyle.pub => BorderRadius.circular(18.0),
      AppDesignStyle.minimal => BorderRadius.zero,
      AppDesignStyle.tradizionale => BorderRadius.circular(10.0),
    };

    final badgeDeco = PersonalizzazionePresets.getBadgeDecoration(
      style: badgeStyle,
      baseColor: primaryColor,
      isDark: isDark,
      isFilled: true,
    );
    final badgeTextColor = PersonalizzazionePresets.getBadgeTextColor(
      style: badgeStyle,
      baseColor: primaryColor,
      isDark: isDark,
      isFilled: true,
    );
    final allergenDeco = PersonalizzazionePresets.getBadgeDecoration(
      style: badgeStyle,
      baseColor: Colors.deepOrange,
      isDark: isDark,
      isFilled: false,
    );
    final allergenTextColor = PersonalizzazionePresets.getBadgeTextColor(
      style: badgeStyle,
      baseColor: Colors.deepOrange,
      isDark: isDark,
      isFilled: false,
    );

    switch (dishLayout) {
      case DishCardLayout.fotoGrande:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 58.0,
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(dishIcon, color: primaryColor, size: 28.0),
                  ),
                  Positioned(
                    top: 6.0,
                    right: 8.0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7.0, vertical: 3.0),
                      decoration: badgeDeco,
                      child: Text(
                        '€ 9,50',
                        style: GoogleFonts.getFont(
                          titleFont,
                          textStyle: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: badgeTextColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6.0),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Pizza Margherita',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.getFont(
                      titleFont,
                      textStyle: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2.0),
            Text(
              'Pomodoro San Marzano, mozzarella di bufala campana DOP.',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.getFont(
                bodyFont,
                textStyle: TextStyle(
                  fontSize: 11.0,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: 4.0),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                  decoration: allergenDeco,
                  child: Text(
                    '🌾 Glutine  🥛 Lattosio',
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w600,
                      color: allergenTextColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );

      case DishCardLayout.griglia:
        return Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(
                    color: primaryColor.withValues(alpha: 0.2),
                    width: 1.0,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Icon(dishIcon, color: primaryColor, size: 24.0),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      'Margherita',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.getFont(
                        titleFont,
                        textStyle: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                      decoration: badgeDeco,
                      child: Text(
                        '€ 9,50',
                        style: GoogleFonts.getFont(
                          titleFont,
                          textStyle: TextStyle(
                            fontSize: 11.0,
                            fontWeight: FontWeight.bold,
                            color: badgeTextColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8.0),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                    width: 1.0,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Icon(Icons.ramen_dining_rounded, color: primaryColor.withValues(alpha: 0.7), size: 24.0),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      'Spaghetti Pom.',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.getFont(
                        titleFont,
                        textStyle: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                      decoration: badgeDeco,
                      child: Text(
                        '€ 8,00',
                        style: GoogleFonts.getFont(
                          titleFont,
                          textStyle: TextStyle(
                            fontSize: 11.0,
                            fontWeight: FontWeight.bold,
                            color: badgeTextColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );

      case DishCardLayout.minimale:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Pizza Margherita',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.getFont(
                      titleFont,
                      textStyle: TextStyle(
                        fontSize: 15.0,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
                  decoration: badgeDeco,
                  child: Text(
                    '€ 9,50',
                    style: GoogleFonts.getFont(
                      titleFont,
                      textStyle: TextStyle(
                        fontSize: 13.0,
                        fontWeight: FontWeight.w700,
                        color: badgeTextColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 3.0),
            Text(
              'Pomodoro San Marzano DOP, fior di latte campano, basilico fresco.',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.getFont(
                bodyFont,
                textStyle: TextStyle(
                  fontSize: 11.5,
                  fontStyle: FontStyle.italic,
                  color: colorScheme.onSurfaceVariant,
                  height: 1.3,
                ),
              ),
            ),
            const SizedBox(height: 4.0),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                  decoration: allergenDeco,
                  child: Text(
                    '🌾 Glutine  🥛 Lattosio',
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w600,
                      color: allergenTextColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );

      case DishCardLayout.classico:
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  _dishWiggleTrigger++;
                });
              },
              child: TweenAnimationBuilder<double>(
                key: ValueKey('dish_$_dishWiggleTrigger'),
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 380),
                curve: Curves.elasticOut,
                builder: (context, val, child) {
                  final scale = 0.85 + (0.15 * val);
                  final rotation = (1.0 - val) * 0.25;
                  return Transform.rotate(
                    angle: rotation,
                    child: Transform.scale(
                      scale: scale,
                      child: child,
                    ),
                  );
                },
                child: Container(
                  width: 44.0,
                  height: 44.0,
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: radius,
                  ),
                  child: Center(
                    child: Icon(
                      dishIcon,
                      color: Colors.white,
                      size: 22.0,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Pizza Margherita',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.getFont(
                      titleFont,
                      textStyle: TextStyle(
                        fontSize: 15.0,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2.0),
                  Text(
                    'Pomodoro San Marzano, mozzarella di bufala campana DOP.',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.getFont(
                      bodyFont,
                      textStyle: TextStyle(
                        fontSize: 11.5,
                        color: colorScheme.onSurfaceVariant,
                        height: 1.3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                    decoration: allergenDeco,
                    child: Text(
                      '🌾 Glutine  🥛 Lattosio',
                      style: TextStyle(
                        fontSize: 9.0,
                        fontWeight: FontWeight.w600,
                        color: allergenTextColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8.0),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              decoration: badgeDeco,
              child: Text(
                '€ 9,50',
                style: GoogleFonts.getFont(
                  titleFont,
                  textStyle: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: badgeTextColor,
                  ),
                ),
              ),
            ),
          ],
        );
    }
  }

  Widget _buildInteractiveFakeButton(
    AppDesignStyle style,
    Color primaryColor,
    String titleFont,
  ) {
    final isMinimal = style == AppDesignStyle.minimal;
    final isPub = style == AppDesignStyle.pub;

    final BorderRadius radius = switch (style) {
      AppDesignStyle.premium => BorderRadius.circular(6.0),
      AppDesignStyle.pub => BorderRadius.circular(18.0),
      AppDesignStyle.minimal => BorderRadius.zero,
      AppDesignStyle.tradizionale => BorderRadius.circular(10.0),
    };

    final String normalLabel =
        isMinimal ? 'AGGIUNGI AL MENU' : 'Aggiungi al Menu';
    final String activeLabel =
        isMinimal ? 'AGGIUNTO AL CARRELLO ✓' : 'Aggiunto al Menu ✓';

    return Material(
      color: Colors.transparent,
      elevation: isPub ? 2.5 : 0.0,
      shadowColor:
          isPub ? primaryColor.withValues(alpha: 0.35) : Colors.transparent,
      borderRadius: radius,
      child: InkWell(
        onTap: _onFakeButtonTap,
        borderRadius: radius,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 38.0,
          decoration: BoxDecoration(
            color: _isFakeButtonAdded
                ? const Color(0xFF0B9F74)
                : primaryColor,
            borderRadius: radius,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, anim) => ScaleTransition(
                  scale: anim,
                  child: child,
                ),
                child: Icon(
                  _isFakeButtonAdded
                      ? Icons.check_circle_rounded
                      : Icons.add_shopping_cart_rounded,
                  key: ValueKey(_isFakeButtonAdded),
                  color: Colors.white,
                  size: 16.0,
                ),
              ),
              const SizedBox(width: 7.0),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Text(
                  _isFakeButtonAdded ? activeLabel : normalLabel,
                  key: ValueKey(_isFakeButtonAdded),
                  style: GoogleFonts.getFont(
                    titleFont,
                    textStyle: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: isMinimal ? 1.0 : 0.2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 3. SWITCHER PRINCIPALE (3 MACRO-AREE ORGANIZZATE)
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildMain3TabSwitcher({
    required BuildContext context,
    required Color primaryColor,
    required bool isDark,
  }) {
    final theme = Theme.of(context);
    final cardBg = theme.colorScheme.surface;
    final barBg = theme.colorScheme.surfaceContainerHigh;

    return Container(
      padding: const EdgeInsets.all(3.0),
      decoration: BoxDecoration(
        color: barBg,
        borderRadius: BorderRadius.circular(14.0),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildMainTabPill(
              title: 'Brand & Stile',
              icon: Icons.palette_rounded,
              isSelected: _mainTab == 0,
              primaryColor: primaryColor,
              activeBg: cardBg,
              isDark: isDark,
              onTap: () {
                if (_mainTab != 0) setState(() => _mainTab = 0);
              },
            ),
          ),
          const SizedBox(width: 4.0),
          Expanded(
            child: _buildMainTabPill(
              title: 'Piatti & Badge',
              icon: Icons.restaurant_rounded,
              isSelected: _mainTab == 1,
              primaryColor: primaryColor,
              activeBg: cardBg,
              isDark: isDark,
              onTap: () {
                if (_mainTab != 1) setState(() => _mainTab = 1);
              },
            ),
          ),
          const SizedBox(width: 4.0),
          Expanded(
            child: _buildMainTabPill(
              title: 'Sfondo & Cover',
              icon: Icons.wallpaper_rounded,
              isSelected: _mainTab == 2,
              primaryColor: primaryColor,
              activeBg: cardBg,
              isDark: isDark,
              onTap: () {
                if (_mainTab != 2) setState(() => _mainTab = 2);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainTabPill({
    required String title,
    required IconData icon,
    required bool isSelected,
    required Color primaryColor,
    required Color activeBg,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(11.0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 7.0),
        decoration: BoxDecoration(
          color: isSelected ? activeBg : Colors.transparent,
          borderRadius: BorderRadius.circular(11.0),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withValues(alpha: 0.3)
                        : Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4.0,
                    offset: const Offset(0, 1),
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 14.5,
              color: isSelected
                  ? (isDark
                      ? (primaryColor.computeLuminance() < 0.40
                          ? HSLColor.fromColor(primaryColor).withLightness(0.68).toColor()
                          : primaryColor)
                      : (primaryColor.computeLuminance() > 0.25
                          ? HSLColor.fromColor(primaryColor).withLightness(0.35).toColor()
                          : primaryColor))
                  : (isDark ? const Color(0xFFB0B0B0) : const Color(0xFF475569)),
            ),
            const SizedBox(width: 4.0),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  title,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: isSelected
                        ? (isDark ? Colors.white : Colors.black87)
                        : (isDark ? const Color(0xFFB0B0B0) : const Color(0xFF475569)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 4. STRUTTURA DELLE 3 MACRO-AREE
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildBrandAndStyleTab({
    Key? key,
    required BuildContext context,
    required ThemeProvider themeProvider,
    required AppDesignStyle currentStyle,
    required Color primaryColor,
    required bool isDark,
    bool isDesktop = false,
  }) {
    final dividerColor = Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.35);

    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionHeader(
          context: context,
          title: 'Stile Gastronomico & Mood',
          subtitle: 'Scegli un preset studiato per il tuo locale con 1 click',
          icon: Icons.auto_awesome_rounded,
          primaryColor: primaryColor,
        ),
        _buildPresetList(
          context: context,
          themeProvider: themeProvider,
          currentStyle: currentStyle,
          isDark: isDark,
          isDesktop: isDesktop,
        ),
        const SizedBox(height: 12.0),
        Divider(color: dividerColor, height: 1.0),
        const SizedBox(height: 14.0),
        _buildSectionHeader(
          context: context,
          title: 'Colore Primario del Brand',
          subtitle: 'Personalizza la palette principale o digita un codice HEX',
          icon: Icons.color_lens_rounded,
          primaryColor: primaryColor,
        ),
        _buildColorCustomizationView(
          context: context,
          themeProvider: themeProvider,
          primaryColor: primaryColor,
          isDark: isDark,
        ),
        const SizedBox(height: 12.0),
        Divider(color: dividerColor, height: 1.0),
        const SizedBox(height: 14.0),
        _buildSectionHeader(
          context: context,
          title: 'Tipografia & Font',
          subtitle: 'Imposta i caratteri tipografici per titoli e descrizioni',
          icon: Icons.font_download_rounded,
          primaryColor: primaryColor,
        ),
        _buildFontCustomizationView(
          context: context,
          themeProvider: themeProvider,
          primaryColor: primaryColor,
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildDishesAndBadgesTab({
    Key? key,
    required BuildContext context,
    required ThemeProvider themeProvider,
    required Color primaryColor,
    required bool isDark,
  }) {
    final dividerColor = Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.35);

    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionHeader(
          context: context,
          title: 'Layout Schede Piatto',
          subtitle: 'Scegli la struttura visiva per presentare le tue pietanze',
          icon: Icons.view_agenda_rounded,
          primaryColor: primaryColor,
        ),
        _buildDishLayoutCustomizationView(
          context: context,
          themeProvider: themeProvider,
          primaryColor: primaryColor,
          isDark: isDark,
        ),
        const SizedBox(height: 12.0),
        Divider(color: dividerColor, height: 1.0),
        const SizedBox(height: 14.0),
        _buildSectionHeader(
          context: context,
          title: 'Stile Badge & Tag',
          subtitle: 'Personalizza l\'aspetto di prezzi, allergeni e promozioni',
          icon: Icons.label_rounded,
          primaryColor: primaryColor,
        ),
        _buildBadgeCustomizationView(
          context: context,
          themeProvider: themeProvider,
          primaryColor: primaryColor,
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildBackgroundAndCoverTab({
    Key? key,
    required BuildContext context,
    required ThemeProvider themeProvider,
    required Color primaryColor,
    required bool isDark,
  }) {
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionHeader(
          context: context,
          title: 'Copertina & Sfondo Menù',
          subtitle: 'Aggiungi un banner fotografico e texture raffinate al menù',
          icon: Icons.wallpaper_rounded,
          primaryColor: primaryColor,
        ),
        _buildBannerTextureCustomizationView(
          context: context,
          themeProvider: themeProvider,
          primaryColor: primaryColor,
          isDark: isDark,
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 4A. TAB 0: ELENCO PRESET RISTORAZIONE
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildPresetList({
    Key? key,
    required BuildContext context,
    required ThemeProvider themeProvider,
    required AppDesignStyle currentStyle,
    required bool isDark,
    bool isDesktop = false,
  }) {
    if (isDesktop) {
      return Column(
        key: key,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Preset Gastronomici',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Text(
                  'Tocca per applicare tutto con 1 click',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8.0),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildPresetCard(
                  context: context,
                  preset: AppDesignStyle.premium,
                  currentStyle: currentStyle,
                  themeProvider: themeProvider,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: _buildPresetCard(
                  context: context,
                  preset: AppDesignStyle.pub,
                  currentStyle: currentStyle,
                  themeProvider: themeProvider,
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12.0),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildPresetCard(
                  context: context,
                  preset: AppDesignStyle.minimal,
                  currentStyle: currentStyle,
                  themeProvider: themeProvider,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: _buildPresetCard(
                  context: context,
                  preset: AppDesignStyle.tradizionale,
                  currentStyle: currentStyle,
                  themeProvider: themeProvider,
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16.0),
        ],
      );
    }

    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Preset Gastronomici',
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              Text(
                'Tocca per applicare tutto',
                style: TextStyle(
                  fontSize: 11.5,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8.0),
        _buildPresetCard(
          context: context,
          preset: AppDesignStyle.premium,
          currentStyle: currentStyle,
          themeProvider: themeProvider,
          isDark: isDark,
        ),
        const SizedBox(height: 10.0),
        _buildPresetCard(
          context: context,
          preset: AppDesignStyle.pub,
          currentStyle: currentStyle,
          themeProvider: themeProvider,
          isDark: isDark,
        ),
        const SizedBox(height: 10.0),
        _buildPresetCard(
          context: context,
          preset: AppDesignStyle.minimal,
          currentStyle: currentStyle,
          themeProvider: themeProvider,
          isDark: isDark,
        ),
        const SizedBox(height: 10.0),
        _buildPresetCard(
          context: context,
          preset: AppDesignStyle.tradizionale,
          currentStyle: currentStyle,
          themeProvider: themeProvider,
          isDark: isDark,
        ),
        const SizedBox(height: 24.0),
      ],
    );
  }

  Widget _buildPresetCard({
    required BuildContext context,
    required AppDesignStyle preset,
    required AppDesignStyle currentStyle,
    required ThemeProvider themeProvider,
    required bool isDark,
  }) {
    final theme = Theme.of(context);
    final isSelected = currentStyle == preset;
    final presetColor = preset.defaultPrimaryColor;
    final cardBg = theme.colorScheme.surface;
    final Color selectedBg = isSelected
        ? presetColor.withValues(alpha: isDark ? 0.16 : 0.08)
        : (isDark ? const Color(0xFF1E293B) : cardBg);

    // Mini palette dots per preview istantanea del preset
    final List<Color> paletteDots = switch (preset) {
      AppDesignStyle.premium => const [Color(0xFFC5A059), Color(0xFF0F172A), Color(0xFFE2E8F0)],
      AppDesignStyle.pub => const [Color(0xFFD97706), Color(0xFF78350F), Color(0xFFFEF3C7)],
      AppDesignStyle.minimal => const [Color(0xFF0F172A), Color(0xFF64748B), Color(0xFFF8FAFC)],
      AppDesignStyle.tradizionale => const [Color(0xFFB71C1C), Color(0xFFEA580C), Color(0xFFFEE2E2)],
    };

    return Card(
      elevation: isSelected ? 3.0 : 1.0,
      shadowColor: isSelected
          ? presetColor.withValues(alpha: isDark ? 0.35 : 0.18)
          : Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
        side: BorderSide(
          color: isSelected
              ? presetColor
              : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
          width: isSelected ? 2.0 : 1.0,
        ),
      ),
      color: selectedBg,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: () => _selectPreset(themeProvider, preset),
        borderRadius: BorderRadius.circular(16.0),
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _AnimatedPresetBadge(
                    icon: preset.defaultIcon,
                    isSelected: isSelected,
                    presetColor: presetColor,
                    isDark: isDark,
                    isJustClicked: _justClickedStyle == preset,
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              preset.displayName,
                              style: TextStyle(
                                fontSize: 15.0,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(width: 7.0),
                            Container(
                              width: 8.0,
                              height: 8.0,
                              decoration: BoxDecoration(
                                color: presetColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2.0),
                        Text(
                          preset.targetAudience,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11.0,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Selettore check
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 24.0,
                    height: 24.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected
                          ? presetColor
                          : theme.colorScheme.surfaceContainerHigh,
                    ),
                    child: Center(
                      child: isSelected
                          ? const Icon(
                              Icons.check_rounded,
                              size: 15.0,
                              color: Colors.white,
                            )
                          : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8.0),
              Text(
                preset.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.0,
                  height: 1.35,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 10.0),
              // Mini color palette dots
              Row(
                children: [
                  Text(
                    'Palette:',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(width: 6.0),
                  ...paletteDots.map((c) => Padding(
                        padding: const EdgeInsets.only(right: 4.0),
                        child: Container(
                          width: 12.0,
                          height: 12.0,
                          decoration: BoxDecoration(
                            color: c,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isDark ? Colors.white24 : Colors.black12,
                              width: 1.0,
                            ),
                          ),
                        ),
                      )),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 4E. TAB 4: STILE DEI BADGE & DETTAGLI PIATTO
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildBadgeCustomizationView({
    Key? key,
    required BuildContext context,
    required ThemeProvider themeProvider,
    required Color primaryColor,
    required bool isDark,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currentBadgeStyle = themeProvider.badgeStyle;

    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Stile dei Badge & Tag',
                style: TextStyle(
                  fontSize: 15.0,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 2.0),
              Text(
                'Personalizza la forma e lo stile di prezzi, allergeni e tag nel menù cliente.',
                style: TextStyle(
                  fontSize: 12.0,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10.0),

        ...BadgeStyle.values.map((bStyle) {
          final isSelected = currentBadgeStyle == bStyle;
          final priceDeco = PersonalizzazionePresets.getBadgeDecoration(
            style: bStyle,
            baseColor: primaryColor,
            isDark: isDark,
            isFilled: true,
          );
          final priceTextColor = PersonalizzazionePresets.getBadgeTextColor(
            style: bStyle,
            baseColor: primaryColor,
            isDark: isDark,
            isFilled: true,
          );

          final allergenDeco = PersonalizzazionePresets.getBadgeDecoration(
            style: bStyle,
            baseColor: Colors.deepOrange,
            isDark: isDark,
            isFilled: false,
          );
          final allergenTextColor = PersonalizzazionePresets.getBadgeTextColor(
            style: bStyle,
            baseColor: Colors.deepOrange,
            isDark: isDark,
            isFilled: false,
          );

          final chefDeco = PersonalizzazionePresets.getBadgeDecoration(
            style: bStyle,
            baseColor: const Color(0xFFD97706),
            isDark: isDark,
            isFilled: true,
          );
          final chefTextColor = PersonalizzazionePresets.getBadgeTextColor(
            style: bStyle,
            baseColor: const Color(0xFFD97706),
            isDark: isDark,
            isFilled: true,
          );

          return Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: Card(
              elevation: isSelected ? 2.0 : 0.5,
              shadowColor: isSelected
                  ? primaryColor.withValues(alpha: isDark ? 0.35 : 0.15)
                  : Colors.transparent,
              color: isSelected
                  ? primaryColor.withValues(alpha: isDark ? 0.15 : 0.06)
                  : colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.0),
                side: BorderSide(
                  color: isSelected
                      ? primaryColor
                      : colorScheme.outlineVariant.withValues(alpha: 0.35),
                  width: isSelected ? 1.8 : 1.0,
                ),
              ),
              child: InkWell(
                onTap: () {
                  themeProvider.setBadgeStyle(bStyle);
                  _autoSaveToCloud(themeProvider);
                },
                borderRadius: BorderRadius.circular(14.0),
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 38.0,
                            height: 38.0,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? primaryColor
                                  : primaryColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              bStyle.icon,
                              color: isSelected
                                  ? (primaryColor.computeLuminance() > 0.55 ? Colors.black87 : Colors.white)
                                  : (isDark
                                      ? (primaryColor.computeLuminance() < 0.40
                                          ? HSLColor.fromColor(primaryColor).withLightness(0.68).toColor()
                                          : primaryColor)
                                      : (primaryColor.computeLuminance() > 0.25
                                          ? HSLColor.fromColor(primaryColor).withLightness(0.35).toColor()
                                          : primaryColor)),
                              size: 19.0,
                            ),
                          ),
                          const SizedBox(width: 10.0),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        bStyle.displayName,
                                        style: TextStyle(
                                          fontSize: 14.5,
                                          fontWeight: FontWeight.bold,
                                          color: colorScheme.onSurface,
                                        ),
                                      ),
                                    ),
                                    if (isSelected)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 7.0, vertical: 2.0),
                                        decoration: BoxDecoration(
                                          color: primaryColor,
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.check_rounded,
                                              size: 12.0,
                                              color: primaryColor.computeLuminance() > 0.55
                                                  ? Colors.black87
                                                  : Colors.white,
                                            ),
                                            const SizedBox(width: 3.0),
                                            Text(
                                              'ATTIVO',
                                              style: TextStyle(
                                                color: primaryColor.computeLuminance() > 0.55
                                                    ? Colors.black87
                                                    : Colors.white,
                                                fontSize: 9.5,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 2.0),
                                Text(
                                  bStyle.description,
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12.0),
                      // Anteprima dal vivo dei 3 badge per questo stile
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 8.0),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.black.withValues(alpha: 0.25)
                              : Colors.grey.shade100.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Row(
                          children: [
                            const Text(
                              'Esempi:',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(width: 8.0),
                            // Badge Prezzo
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0, vertical: 3.0),
                              decoration: priceDeco,
                              child: Text(
                                '€ 9,50',
                                style: TextStyle(
                                  color: priceTextColor,
                                  fontSize: 11.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6.0),
                            // Badge Allergeni
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7.0, vertical: 2.5),
                              decoration: allergenDeco,
                              child: Text(
                                '🌾 Glutine',
                                style: TextStyle(
                                  color: allergenTextColor,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6.0),
                            // Badge Chef
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7.0, vertical: 2.5),
                              decoration: chefDeco,
                              child: Text(
                                '★ Chef',
                                style: TextStyle(
                                  color: chefTextColor,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
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
            ),
          );
        }),

        const SizedBox(height: 12.0),

        // Box promozionale per aprire il simulatore a schermo intero
        Card(
          elevation: 1.0,
          color: primaryColor.withValues(alpha: isDark ? 0.12 : 0.05),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.0),
            side: BorderSide(
              color: primaryColor.withValues(alpha: 0.3),
              width: 1.0,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Row(
              children: [
                Container(
                  width: 44.0,
                  height: 44.0,
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.smartphone_rounded,
                    color: Colors.white,
                    size: 24.0,
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Vuoi testare tutto dal vivo?',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2.0),
                      Text(
                        'Apri il simulatore per provare la navigazione del cliente a schermo intero.',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8.0),
                ElevatedButton(
                  onPressed: () => _openSimulator(context, themeProvider),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12.0, vertical: 8.0),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0)),
                  ),
                  child: const Text('Simula',
                      style: TextStyle(
                          fontSize: 12.0, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20.0),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 4B. TAB 1: PERSONALIZZAZIONE FONT (TITOLI & PREZZI vs TESTI & DETTAGLI)
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildFontCustomizationView({
    Key? key,
    required BuildContext context,
    required ThemeProvider themeProvider,
    required Color primaryColor,
    required bool isDark,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currentTitleFont = themeProvider.titleFont;
    final currentBodyFont = themeProvider.bodyFont;

    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Intestazione con pulsante di reset rapido ai font del preset
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tipografia Indipendente',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  'Scegli i caratteri per il tuo menu',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            TextButton.icon(
              onPressed: () => themeProvider.resetFontsToPreset(),
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
                foregroundColor: primaryColor,
              ),
              icon: const Icon(Icons.refresh_rounded, size: 16.0),
              label: const Text(
                'Default Preset',
                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),

        const SizedBox(height: 10.0),

        // Sub-switcher per selezionare se personalizzare Titoli o Body
        Container(
          padding: const EdgeInsets.all(3.0),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildSubTabPill(
                  title: 'Titoli & Prezzi',
                  subtitle: currentTitleFont,
                  icon: Icons.title_rounded,
                  isSelected: _fontTargetTab == 0,
                  primaryColor: primaryColor,
                  colorScheme: colorScheme,
                  onTap: () => setState(() => _fontTargetTab = 0),
                ),
              ),
              const SizedBox(width: 4.0),
              Expanded(
                child: _buildSubTabPill(
                  title: 'Testi & Descrizioni',
                  subtitle: currentBodyFont,
                  icon: Icons.notes_rounded,
                  isSelected: _fontTargetTab == 1,
                  primaryColor: primaryColor,
                  colorScheme: colorScheme,
                  onTap: () => setState(() => _fontTargetTab = 1),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14.0),

        // Lista dei Font con anteprima live per ciascun font
        if (_fontTargetTab == 0) ...[
          Padding(
            padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
            child: Text(
              'Font per Nomi dei Piatti, Prezzi e Pulsanti:',
              style: TextStyle(
                fontSize: 12.0,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          ..._titleFontOptions.map((opt) {
            final isSelected = opt.family == currentTitleFont;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: _buildFontOptionCard(
                family: opt.family,
                genre: opt.genre,
                description: opt.description,
                isSelected: isSelected,
                primaryColor: primaryColor,
                colorScheme: colorScheme,
                onTap: () {
                  themeProvider.setTitleFont(opt.family);
                  _autoSaveToCloud(themeProvider);
                },
              ),
            );
          }),
        ] else ...[
          Padding(
            padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
            child: Text(
              'Font per Descrizioni, Ingredienti e Dettagli:',
              style: TextStyle(
                fontSize: 12.0,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          ..._bodyFontOptions.map((opt) {
            final isSelected = opt.family == currentBodyFont;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: _buildFontOptionCard(
                family: opt.family,
                genre: opt.genre,
                description: opt.description,
                isSelected: isSelected,
                primaryColor: primaryColor,
                colorScheme: colorScheme,
                onTap: () {
                  themeProvider.setBodyFont(opt.family);
                  _autoSaveToCloud(themeProvider);
                },
              ),
            );
          }),
        ],

        const SizedBox(height: 28.0),
      ],
    );
  }

  Widget _buildSubTabPill({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required Color primaryColor,
    required ColorScheme colorScheme,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 15.0,
                  color: isSelected ? primaryColor : colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 5.0),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12.0,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? colorScheme.onSurface : colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2.0),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? primaryColor : colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFontOptionCard({
    required String family,
    required String genre,
    required String description,
    required bool isSelected,
    required Color primaryColor,
    required ColorScheme colorScheme,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: isSelected ? 2.0 : 0.5,
      shadowColor: isSelected
          ? primaryColor.withValues(alpha: 0.25)
          : Colors.black.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14.0),
        side: BorderSide.none,
      ),
      color: isSelected
          ? primaryColor.withValues(alpha: 0.08)
          : colorScheme.surface,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
          child: Row(
            children: [
              // Anteprima campione tipografico "Aa"
              Container(
                width: 44.0,
                height: 44.0,
                decoration: BoxDecoration(
                  color: isSelected
                      ? primaryColor.withValues(alpha: 0.16)
                      : colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Center(
                  child: Text(
                    'Aa',
                    style: GoogleFonts.getFont(
                      family,
                      textStyle: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? primaryColor : colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 14.0),

              // Nome del font mostrato nel font stesso + dettagli
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            family,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.getFont(
                              family,
                              textStyle: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6.0, vertical: 2.0),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(6.0),
                          ),
                          child: Text(
                            genre,
                            style: TextStyle(
                              fontSize: 9.5,
                              color: colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2.0),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8.0),

              // Indicatore radio checkmark
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 24.0,
                height: 24.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? primaryColor
                      : colorScheme.surfaceContainerHigh,
                ),
                child: Center(
                  child: isSelected
                      ? const Icon(
                          Icons.check_rounded,
                          size: 15.0,
                          color: Colors.white,
                        )
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 4C. TAB 1: PERSONALIZZAZIONE COLORI BRAND & PALETTE GOURMET
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildColorCustomizationView({
    Key? key,
    required BuildContext context,
    required ThemeProvider themeProvider,
    required Color primaryColor,
    required bool isDark,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currentStyle = themeProvider.designStyle;

    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Guida introduttiva semplice per principianti
        Container(
          padding: const EdgeInsets.all(14.0),
          decoration: BoxDecoration(
            color: primaryColor.withValues(alpha: isDark ? 0.18 : 0.08),
            borderRadius: BorderRadius.circular(14.0),
            border: Border.all(
              color: primaryColor.withValues(alpha: 0.25),
              width: 1.0,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Icon(
                  Icons.palette_rounded,
                  color: primaryColor,
                  size: 20.0,
                ),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Colore Identitario del Menù',
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 3.0),
                    Text(
                      'Definisce la tinta di pulsanti, prezzi, badge e dettagli del menù per i tuoi clienti. Scegli una tonalità gourmet abbinata al tuo locale oppure inserisci il codice esatto del tuo logo.',
                      style: TextStyle(
                        fontSize: 12.0,
                        height: 1.35,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14.0),

        // Selettore Colore HEX personalizzato
        _buildHexColorCard(
          context: context,
          themeProvider: themeProvider,
          primaryColor: primaryColor,
          currentStyle: currentStyle,
          isDark: isDark,
        ),

        const SizedBox(height: 18.0),

        // Titolo sezione palette gourmet
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Palette Gourmet Consigliate',
              style: TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
            Text(
              '12 tonalità studiate',
              style: TextStyle(
                fontSize: 11.5,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10.0),

        // Griglia / Lista delle 12 palette
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _gourmetColors.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8.0),
          itemBuilder: (context, index) {
            final opt = _gourmetColors[index];
            final isSelected = primaryColor.toARGB32() == opt.color.toARGB32();

            return InkWell(
              onTap: () {
                themeProvider.setPrimaryColor(opt.color);
                _hexController.text = opt.color
                    .toARGB32()
                    .toRadixString(16)
                    .padLeft(8, '0')
                    .substring(2)
                    .toUpperCase();
                _autoSaveToCloud(themeProvider);
              },
              borderRadius: BorderRadius.circular(14.0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
                decoration: BoxDecoration(
                  color: isSelected
                      ? opt.color.withValues(alpha: isDark ? 0.22 : 0.08)
                      : colorScheme.surface,
                  borderRadius: BorderRadius.circular(14.0),
                  border: Border.all(
                    color: isSelected
                        ? opt.color
                        : colorScheme.outlineVariant.withValues(alpha: 0.5),
                    width: isSelected ? 2.0 : 1.0,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: opt.color.withValues(alpha: 0.18),
                            blurRadius: 8.0,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  children: [
                    // Campione colore tondo grande
                    Container(
                      width: 42.0,
                      height: 42.0,
                      decoration: BoxDecoration(
                        color: opt.color,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: opt.color.withValues(alpha: 0.35),
                            blurRadius: 6.0,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: isSelected
                          ? const Center(
                              child: Icon(Icons.check_rounded, color: Colors.white, size: 22.0),
                            )
                          : null,
                    ),
                    const SizedBox(width: 14.0),
                    // Nome e categoria suggerita
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  opt.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w700,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8.0),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                                decoration: BoxDecoration(
                                  color: opt.color.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6.0),
                                ),
                                child: Text(
                                  opt.tag,
                                  style: TextStyle(
                                    fontSize: 10.0,
                                    fontWeight: FontWeight.w700,
                                    color: opt.color,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3.0),
                          Text(
                            opt.recommendedFor,
                            style: TextStyle(
                              fontSize: 12.0,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    // Badge codice HEX
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Text(
                        '#${opt.color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}',
                        style: TextStyle(
                          fontSize: 11.0,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'monospace',
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 16.0),
      ],
    );
  }

  Widget _buildHexColorCard({
    required BuildContext context,
    required ThemeProvider themeProvider,
    required Color primaryColor,
    required AppDesignStyle currentStyle,
    required bool isDark,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.6),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(Icons.colorize_rounded, size: 17.0, color: primaryColor),
                    const SizedBox(width: 6.0),
                    Flexible(
                      child: Text(
                        'Codice Colore (HEX)',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13.0,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4.0),
              TextButton.icon(
                onPressed: () {
                  final defaultColor = currentStyle.defaultPrimaryColor;
                  themeProvider.setPrimaryColor(defaultColor);
                  _hexController.text = defaultColor
                      .toARGB32()
                      .toRadixString(16)
                      .padLeft(8, '0')
                      .substring(2)
                      .toUpperCase();
                  _autoSaveToCloud(themeProvider);
                },
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  foregroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 6.0),
                ),
                icon: const Icon(Icons.restart_alt_rounded, size: 14.0),
                label: const Text(
                  'Colore Tema',
                  style: TextStyle(fontSize: 11.0, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10.0),
          Row(
            children: [
              // Anteprima colore corrente
              Container(
                width: 44.0,
                height: 44.0,
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.8),
                    width: 2.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.35),
                      blurRadius: 6.0,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12.0),
              // Campo input codice HEX
              Expanded(
                child: SizedBox(
                  height: 44.0,
                  child: TextField(
                    controller: _hexController,
                    textCapitalization: TextCapitalization.characters,
                    maxLength: 6,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w700,
                      fontSize: 15.0,
                      letterSpacing: 2.0,
                      color: colorScheme.onSurface,
                    ),
                    decoration: InputDecoration(
                      prefixText: '# ',
                      prefixStyle: TextStyle(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w700,
                        fontSize: 15.0,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      counterText: '',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(
                          color: colorScheme.outlineVariant,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(
                          color: primaryColor,
                          width: 2.0,
                        ),
                      ),
                      hintText: 'E63946',
                      hintStyle: TextStyle(
                        fontFamily: 'monospace',
                        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                      ),
                    ),
                    onSubmitted: (val) => _applyHexColor(val, themeProvider),
                  ),
                ),
              ),
              const SizedBox(width: 10.0),
              // Bottone Applica
              ElevatedButton(
                onPressed: () => _applyHexColor(_hexController.text, themeProvider),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  minimumSize: const Size(0, 44.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: const Text(
                  'Applica',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.0),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _applyHexColor(String hexText, ThemeProvider themeProvider) {
    String cleanHex = hexText.replaceAll('#', '').trim();
    if (cleanHex.length == 3) {
      cleanHex = cleanHex.split('').map((c) => '$c$c').join();
    }
    if (cleanHex.length == 6) {
      final intVal = int.tryParse('FF$cleanHex', radix: 16);
      if (intVal != null) {
        final newColor = Color(intVal);
        themeProvider.setPrimaryColor(newColor);
        _hexController.text = cleanHex.toUpperCase();
        _autoSaveToCloud(themeProvider);
        return;
      }
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Codice HEX non valido. Inserisci 6 caratteri es. E63946'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 4C. TAB 2: LAYOUT DELLE SCHEDE PIATTO
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildDishLayoutCustomizationView({
    Key? key,
    required BuildContext context,
    required ThemeProvider themeProvider,
    required Color primaryColor,
    required bool isDark,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currentLayout = themeProvider.dishCardLayout;

    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Layout Schede Piatto',
                style: TextStyle(
                  fontSize: 15.0,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 2.0),
              Text(
                'Scegli come visualizzare i piatti nel menù per i tuoi clienti.',
                style: TextStyle(
                  fontSize: 12.0,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10.0),
        ...DishCardLayout.values.map((layout) {
          final isSelected = currentLayout == layout;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: Card(
              elevation: isSelected ? 2.0 : 0.5,
              shadowColor: isSelected
                  ? primaryColor.withValues(alpha: isDark ? 0.35 : 0.15)
                  : Colors.transparent,
              color: isSelected
                  ? primaryColor.withValues(alpha: isDark ? 0.15 : 0.06)
                  : colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.0),
                side: BorderSide(
                  color: isSelected
                      ? primaryColor
                      : colorScheme.outlineVariant.withValues(alpha: 0.35),
                  width: isSelected ? 1.8 : 1.0,
                ),
              ),
              child: InkWell(
                onTap: () {
                  themeProvider.setDishCardLayout(layout);
                  _autoSaveToCloud(themeProvider);
                },
                borderRadius: BorderRadius.circular(14.0),
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 44.0,
                        height: 44.0,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? primaryColor
                              : primaryColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          layout.icon,
                          color: isSelected ? Colors.white : primaryColor,
                          size: 22.0,
                        ),
                      ),
                      const SizedBox(width: 12.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    layout.displayName,
                                    style: TextStyle(
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0, vertical: 2.0),
                                    decoration: BoxDecoration(
                                      color: primaryColor,
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.check_rounded,
                                          size: 13.0,
                                          color: primaryColor.computeLuminance() > 0.55
                                              ? Colors.black87
                                              : Colors.white,
                                        ),
                                        const SizedBox(width: 3.0),
                                        Text(
                                          'ATTIVO',
                                          style: TextStyle(
                                            color: primaryColor.computeLuminance() > 0.55
                                                ? Colors.black87
                                                : Colors.white,
                                            fontSize: 10.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4.0),
                            Text(
                              layout.description,
                              style: TextStyle(
                                fontSize: 12.0,
                                height: 1.35,
                                color: colorScheme.onSurfaceVariant,
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
          );
        }),
        const SizedBox(height: 8.0),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 4D. TAB 3: BANNER DI COPERTINA & TEXTURE DI SFONDO
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildBannerTextureCustomizationView({
    Key? key,
    required BuildContext context,
    required ThemeProvider themeProvider,
    required Color primaryColor,
    required bool isDark,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currentBanner = themeProvider.coverBanner;
    final currentTexture = themeProvider.backgroundTexture;

    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ─── SEZIONE 1: BANNER DI COPERTINA ───
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Banner di Copertina',
                      style: TextStyle(
                        fontSize: 15.0,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2.0),
                    Text(
                      'Hero header mostrato in cima al menù digitale.',
                      style: TextStyle(
                        fontSize: 12.0,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (currentBanner.isNotEmpty) ...[
                const SizedBox(width: 8.0),
                TextButton.icon(
                  onPressed: () {
                    themeProvider.setCoverBanner('');
                    _bannerUrlController.clear();
                    _autoSaveToCloud(themeProvider);
                  },
                  icon: const Icon(Icons.close_rounded, size: 14.0),
                  label: const Text('Rimuovi', style: TextStyle(fontSize: 11.5)),
                  style: TextButton.styleFrom(
                    foregroundColor: colorScheme.error,
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 8.0),

        // Opzione: Nessun banner
        Card(
          elevation: currentBanner.isEmpty ? 2.0 : 0.5,
          color: currentBanner.isEmpty
              ? primaryColor.withValues(alpha: isDark ? 0.15 : 0.06)
              : colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
            side: BorderSide(
              color: currentBanner.isEmpty
                  ? primaryColor
                  : colorScheme.outlineVariant.withValues(alpha: 0.35),
              width: currentBanner.isEmpty ? 1.8 : 1.0,
            ),
          ),
          child: InkWell(
            onTap: () {
              themeProvider.setCoverBanner('');
              _bannerUrlController.clear();
              _autoSaveToCloud(themeProvider);
            },
            borderRadius: BorderRadius.circular(12.0),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 11.0),
              child: Row(
                children: [
                  Icon(
                    Icons.hide_image_outlined,
                    color: currentBanner.isEmpty ? primaryColor : colorScheme.onSurfaceVariant,
                    size: 20.0,
                  ),
                  const SizedBox(width: 10.0),
                  Expanded(
                    child: Text(
                      'Nessun Banner (Header pulito)',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: currentBanner.isEmpty ? FontWeight.bold : FontWeight.w500,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                  if (currentBanner.isEmpty)
                    Icon(Icons.check_circle_rounded, color: primaryColor, size: 18.0),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 10.0),

        // Preset HD Banner Gastronomici
        Text(
          'Preset Fotografici HD Selezionati',
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8.0),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: PersonalizzazionePresets.banners.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.35,
            crossAxisSpacing: 10.0,
            mainAxisSpacing: 10.0,
          ),
          itemBuilder: (context, index) {
            final b = PersonalizzazionePresets.banners[index];
            final isSelected = currentBanner == b.id || currentBanner == b.imageUrl;

            return ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: InkWell(
                onTap: () {
                  themeProvider.setCoverBanner(b.id);
                  _bannerUrlController.text = b.id;
                  _autoSaveToCloud(themeProvider);
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(
                      color: isSelected ? primaryColor : Colors.transparent,
                      width: isSelected ? 2.5 : 0.0,
                    ),
                    image: DecorationImage(
                      image: NetworkImage(b.imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.75),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Align(
                          alignment: Alignment.topRight,
                          child: isSelected
                              ? Container(
                                  padding: const EdgeInsets.all(3.0),
                                  decoration: BoxDecoration(
                                    color: primaryColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.check_rounded, color: Colors.white, size: 14.0),
                                )
                              : const SizedBox.shrink(),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              b.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 11.5,
                              ),
                            ),
                            Text(
                              b.subtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 9.5,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 12.0),

        // Campo inserimento URL Banner personalizzato
        Container(
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.4),
              width: 1.0,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Oppure inserisci URL foto personalizzata:',
                style: TextStyle(
                  fontSize: 12.0,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8.0),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _bannerUrlController,
                      style: TextStyle(fontSize: 12.5, color: colorScheme.onSurface),
                      decoration: InputDecoration(
                        hintText: 'https://images.unsplash.com/...',
                        hintStyle: TextStyle(fontSize: 12.0, color: colorScheme.onSurfaceVariant),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide(color: colorScheme.outlineVariant),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  ElevatedButton(
                    onPressed: () {
                      final val = _bannerUrlController.text.trim();
                      if (val.isNotEmpty) {
                        themeProvider.setCoverBanner(val);
                        _autoSaveToCloud(themeProvider);
                        FocusScope.of(context).unfocus();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                    ),
                    child: const Text('Applica', style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 20.0),
        Divider(color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
        const SizedBox(height: 12.0),

        // ─── SEZIONE 2: TEXTURE DI SFONDO ───
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Texture & Sfondo Menù',
                style: TextStyle(
                  fontSize: 15.0,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 2.0),
              Text(
                'Personalizza l\'atmosfera materica dello sfondo del tuo menù.',
                style: TextStyle(
                  fontSize: 12.0,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10.0),

        ...BackgroundTexture.values.map((texture) {
          final isSelected = currentTexture == texture;
          final texDeco = PersonalizzazionePresets.getTextureDecoration(
            texture: texture,
            isDark: isDark,
            theme: theme,
          );

          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Card(
              elevation: isSelected ? 2.0 : 0.5,
              color: isSelected
                  ? primaryColor.withValues(alpha: isDark ? 0.15 : 0.06)
                  : colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
                side: BorderSide(
                  color: isSelected
                      ? primaryColor
                      : colorScheme.outlineVariant.withValues(alpha: 0.35),
                  width: isSelected ? 1.8 : 1.0,
                ),
              ),
              child: InkWell(
                onTap: () {
                  themeProvider.setBackgroundTexture(texture);
                  _autoSaveToCloud(themeProvider);
                },
                borderRadius: BorderRadius.circular(12.0),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    children: [
                      // Miniature texture container
                      Container(
                        width: 44.0,
                        height: 44.0,
                        decoration: texDeco.copyWith(
                          borderRadius: BorderRadius.circular(10.0),
                          border: Border.all(
                            color: isSelected
                                ? primaryColor
                                : colorScheme.outlineVariant.withValues(alpha: 0.5),
                            width: 1.0,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          texture.icon,
                          size: 20.0,
                          color: isSelected ? primaryColor : colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 12.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              texture.displayName,
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 2.0),
                            Text(
                              texture.description,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11.0,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        Icon(Icons.check_circle_rounded, color: primaryColor, size: 20.0),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
        const SizedBox(height: 10.0),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 5. STICKY BOTTOM BAR: SALVATAGGIO & PUBBLICAZIONE NEL CLOUD (QR MENU)
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildPublishBottomBar({
    required BuildContext context,
    required ThemeProvider themeProvider,
    required Color primaryColor,
    required bool isDark,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
            width: 1.0,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.06),
            blurRadius: 10.0,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              height: 48.0,
              child: ElevatedButton.icon(
                onPressed: _isSavingCloud ? null : () => _publishThemeToCloud(themeProvider),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: primaryColor.withValues(alpha: 0.6),
                  elevation: 2.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                icon: _isSavingCloud
                    ? const SizedBox(
                        width: 20.0,
                        height: 20.0,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.cloud_done_rounded, size: 22.0),
                label: Text(
                  _isSavingCloud ? 'Pubblicazione in corso...' : 'Pubblica Modifiche nel Menù',
                  style: const TextStyle(
                    fontSize: 15.0,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.sync_rounded,
                  size: 13.0,
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                ),
                const SizedBox(width: 5.0),
                Flexible(
                  child: Text(
                    'Sincronizzato in tempo reale con il QR Code del menù',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11.0,
                      color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// MODELLO FONT OPTION
// ═══════════════════════════════════════════════════════════════════════════

class FontOption {
  final String family;
  final String genre;
  final String description;

  const FontOption(this.family, this.genre, this.description);
}

// ═══════════════════════════════════════════════════════════════════════════
// MODELLO GOURMET COLOR OPTION
// ═══════════════════════════════════════════════════════════════════════════

class GourmetColorOption {
  final String name;
  final String recommendedFor;
  final Color color;
  final String tag;

  const GourmetColorOption(this.name, this.recommendedFor, this.color, this.tag);
}

// ═══════════════════════════════════════════════════════════════════════════
// BADGE PRESET CON ANIMAZIONE ELASTICA AL CLICK
// ═══════════════════════════════════════════════════════════════════════════

class _AnimatedPresetBadge extends StatefulWidget {
  final IconData icon;
  final bool isSelected;
  final Color presetColor;
  final bool isDark;
  final bool isJustClicked;

  const _AnimatedPresetBadge({
    required this.icon,
    required this.isSelected,
    required this.presetColor,
    required this.isDark,
    required this.isJustClicked,
  });

  @override
  State<_AnimatedPresetBadge> createState() => _AnimatedPresetBadgeState();
}

class _AnimatedPresetBadgeState extends State<_AnimatedPresetBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.25), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.25, end: 0.95), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.95, end: 1.0), weight: 30),
    ]).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOut,
    ));

    _rotationAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -0.15), weight: 35),
      TweenSequenceItem(tween: Tween(begin: -0.15, end: 0.15), weight: 35),
      TweenSequenceItem(tween: Tween(begin: 0.15, end: 0.0), weight: 30),
    ]).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(covariant _AnimatedPresetBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if ((widget.isSelected && !oldWidget.isSelected) || widget.isJustClicked) {
      _animController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color badgeBg = widget.isSelected
        ? widget.presetColor.withValues(alpha: widget.isDark ? 0.25 : 0.15)
        : theme.colorScheme.surfaceContainerHigh;

    final Color iconColor = widget.isSelected
        ? widget.presetColor
        : theme.colorScheme.onSurfaceVariant;

    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotationAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: 46.0,
              height: 46.0,
              decoration: BoxDecoration(
                color: badgeBg,
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Center(
                child: Icon(
                  widget.icon,
                  size: 24.0,
                  color: iconColor,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
