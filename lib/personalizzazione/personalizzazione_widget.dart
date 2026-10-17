import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/theme_provider.dart';
import '/app_themes.dart';
import 'personalizzazione_model.dart';

export 'personalizzazione_model.dart';

class PersonalizzazioneWidget extends StatefulWidget {
  const PersonalizzazioneWidget({
    super.key,
    this.ristoranteRef,
    this.initialTab = 0,
  });

  final DocumentReference? ristoranteRef;
  final int initialTab;

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
  bool _isSavingCloud = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PersonalizzazioneModel());
    _mainTab = widget.initialTab.clamp(0, 2);
    _hexController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
      _hexController.text = themeProvider.primaryColor
          .toARGB32()
          .toRadixString(16)
          .padLeft(8, '0')
          .substring(2)
          .toUpperCase();
      _loadRestaurantTheme(themeProvider);
    });
  }

  @override
  void dispose() {
    _hexController.dispose();
    _model.dispose();
    super.dispose();
  }

  Future<void> _loadRestaurantTheme(ThemeProvider themeProvider) async {
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

          if (tema != null || colore != null || fontTitoli != null || fontTesti != null) {
            themeProvider.syncFromRestaurant(
              temaScelto: tema,
              colorePrimarioHex: colore,
              fontTitoli: fontTitoli,
              fontTesti: fontTesti,
            );
            if (mounted) {
              _hexController.text = themeProvider.primaryColor
                  .toARGB32()
                  .toRadixString(16)
                  .padLeft(8, '0')
                  .substring(2)
                  .toUpperCase();
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
      await docRef.update({
        'temaScelto': themeProvider.designStyle.name,
        'colore_primario': hexColor,
        'font_titoli': themeProvider.titleFont,
        'font_testi': themeProvider.bodyFont,
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
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
        appBar: AppBar(
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
          actions: const [
            SizedBox(width: 48.0),
          ],
        ),
        body: SafeArea(
          top: true,
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680.0),
              child: Column(
                children: [
                  // ═════════════════════════════════════════════════════════════
                  // 📌 AREA FISSA IN ALTO (STICKY / BLOCCATA DURANTE LO SCROLL)
                  // ═════════════════════════════════════════════════════════════
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 1. Selettore modalità (Chiaro / Scuro / Sistema)
                        _buildThemeModeCard(
                          context: context,
                          themeProvider: themeProvider,
                          primaryColor: primaryColor,
                          isDark: isDark,
                        ),

                        const SizedBox(height: 10.0),

                        // 2. Finestra di Anteprima Bloccata (Pizza Margherita)
                        _buildStickyPreviewCard(
                          context: context,
                          style: currentStyle,
                          primaryColor: primaryColor,
                          isDark: isDark,
                          customTheme: customTheme,
                          titleFont: themeProvider.titleFont,
                          bodyFont: themeProvider.bodyFont,
                        ),

                        const SizedBox(height: 10.0),

                        // 3. Switcher principale: Design vs Font
                        _buildMainTabSwitcher(
                          context: context,
                          primaryColor: primaryColor,
                          isDark: isDark,
                        ),

                        const SizedBox(height: 8.0),
                      ],
                    ),
                  ),

                  // ═════════════════════════════════════════════════════════════
                  // 📜 AREA SCROLLABILE (CONTROLLI PRESET O SELEZIONE DEI FONT)
                  // ═════════════════════════════════════════════════════════════
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 6.0,
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: _mainTab == 0
                            ? _buildPresetList(
                                key: const ValueKey('presets_tab'),
                                context: context,
                                themeProvider: themeProvider,
                                currentStyle: currentStyle,
                                isDark: isDark,
                              )
                            : (_mainTab == 1
                                ? _buildColorCustomizationView(
                                    key: const ValueKey('colors_tab'),
                                    context: context,
                                    themeProvider: themeProvider,
                                    primaryColor: primaryColor,
                                    isDark: isDark,
                                  )
                                : _buildFontCustomizationView(
                                    key: const ValueKey('fonts_tab'),
                                    context: context,
                                    themeProvider: themeProvider,
                                    primaryColor: primaryColor,
                                    isDark: isDark,
                                  )),
                      ),
                    ),
                  ),

                  // ═════════════════════════════════════════════════════════════
                  // 🚀 BOTTONE SALVA & PUBBLICA NEL MENÙ (STICKY BOTTOM BAR)
                  // ═════════════════════════════════════════════════════════════
                  _buildPublishBottomBar(
                    context: context,
                    themeProvider: themeProvider,
                    primaryColor: primaryColor,
                    isDark: isDark,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 1. SELETTORE MODALITÀ
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildThemeModeCard({
    required BuildContext context,
    required ThemeProvider themeProvider,
    required Color primaryColor,
    required bool isDark,
  }) {
    final theme = Theme.of(context);
    final currentMode = themeProvider.themeMode;

    return Card(
      elevation: 1.0,
      shadowColor: isDark
          ? Colors.black.withValues(alpha: 0.35)
          : Colors.black.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
        side: BorderSide.none,
      ),
      color: theme.colorScheme.surface,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
        child: Row(
          children: [
            Expanded(
              child: _buildThemeModePill(
                context: context,
                label: 'Chiaro',
                icon: Icons.wb_sunny_rounded,
                isSelected: currentMode == ThemeMode.light,
                primaryColor: primaryColor,
                isDark: isDark,
                onTap: () => themeProvider.setThemeMode(ThemeMode.light),
              ),
            ),
            const SizedBox(width: 6.0),
            Expanded(
              child: _buildThemeModePill(
                context: context,
                label: 'Scuro',
                icon: Icons.dark_mode_rounded,
                isSelected: currentMode == ThemeMode.dark,
                primaryColor: primaryColor,
                isDark: isDark,
                onTap: () => themeProvider.setThemeMode(ThemeMode.dark),
              ),
            ),
            const SizedBox(width: 6.0),
            Expanded(
              child: _buildThemeModePill(
                context: context,
                label: 'Sistema',
                icon: Icons.devices_rounded,
                isSelected: currentMode == ThemeMode.system,
                primaryColor: primaryColor,
                isDark: isDark,
                onTap: () => themeProvider.setThemeMode(ThemeMode.system),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeModePill({
    required BuildContext context,
    required String label,
    required IconData icon,
    required bool isSelected,
    required Color primaryColor,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final Color activeBg = primaryColor.withValues(alpha: isDark ? 0.22 : 0.12);
    final Color inactiveBg = theme.colorScheme.surfaceContainerHigh;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 7.0),
        decoration: BoxDecoration(
          color: isSelected ? activeBg : inactiveBg,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16.0,
              color: isSelected ? primaryColor : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 6.0),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.0,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? primaryColor
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 2. FINESTRA DI ANTEPRIMA BLOCCATA IN ALTO (STICKY)
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildStickyPreviewCard({
    required BuildContext context,
    required AppDesignStyle style,
    required Color primaryColor,
    required bool isDark,
    required AppCustomTheme? customTheme,
    required String titleFont,
    required String bodyFont,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final IconData dishIcon = style.defaultIcon;
    final String styleTag = customTheme?.styleTag ?? 'FINE DINING';

    return Card(
      elevation: 2.0,
      shadowColor: isDark
          ? Colors.black.withValues(alpha: 0.4)
          : primaryColor.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
        side: BorderSide.none,
      ),
      color: colorScheme.surface,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header anteprima con tag preset
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.remove_red_eye_rounded,
                      size: 15.0,
                      color: primaryColor,
                    ),
                    const SizedBox(width: 6.0),
                    Text(
                      'ANTEPRIMA IN TEMPO REALE',
                      style: GoogleFonts.getFont(
                        titleFont,
                        textStyle: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 3.0),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                  child: Text(
                    styleTag,
                    style: GoogleFonts.getFont(
                      titleFont,
                      textStyle: const TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10.0),

            // Dettagli piatto (Pizza Margherita) con font dedicati live
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Icona Piatto reattiva al tap
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
                        borderRadius: switch (style) {
                          AppDesignStyle.premium => BorderRadius.circular(6.0),
                          AppDesignStyle.pub => BorderRadius.circular(18.0),
                          AppDesignStyle.minimal => BorderRadius.zero,
                          AppDesignStyle.tradizionale =>
                            BorderRadius.circular(10.0),
                        },
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
                      // Titolo piatto con titleFont
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
                      // Descrizione piatto con bodyFont
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
                    ],
                  ),
                ),

                const SizedBox(width: 8.0),

                // Prezzo con titleFont
                Text(
                  '€ 9,50',
                  style: GoogleFonts.getFont(
                    titleFont,
                    textStyle: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w700,
                      color: primaryColor,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10.0),

            // Pulsante interattivo compatto con titleFont
            _buildInteractiveFakeButton(style, primaryColor, titleFont),
          ],
        ),
      ),
    );
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
  // 3. SWITCHER PRINCIPALE (DESIGN vs FONT)
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildMainTabSwitcher({
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
              title: 'Stile',
              icon: Icons.auto_awesome_rounded,
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
              title: 'Colori',
              icon: Icons.palette_rounded,
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
              title: 'Caratteri',
              icon: Icons.font_download_rounded,
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
        padding: const EdgeInsets.symmetric(vertical: 8.0),
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
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15.0,
              color: isSelected ? primaryColor : (isDark ? const Color(0xFF9E9E9E) : const Color(0xFF6B7280)),
            ),
            const SizedBox(width: 4.0),
            Flexible(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.0,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? (isDark ? Colors.white : Colors.black87)
                      : (isDark ? const Color(0xFF9E9E9E) : const Color(0xFF6B7280)),
                ),
              ),
            ),
          ],
        ),
      ),
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
  }) {
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
        : cardBg;

    return Card(
      elevation: isSelected ? 2.0 : 1.0,
      shadowColor: isSelected
          ? presetColor.withValues(alpha: isDark ? 0.35 : 0.16)
          : Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
        side: BorderSide.none,
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
                                fontSize: 15.5,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(width: 7.0),
                            Container(
                              width: 10.0,
                              height: 10.0,
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
                          style: TextStyle(
                            fontSize: 11.5,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 26.0,
                    height: 26.0,
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
                              size: 16.0,
                              color: Colors.white,
                            )
                          : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10.0),
              Text(
                preset.description,
                style: TextStyle(
                  fontSize: 12.5,
                  height: 1.35,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
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
                onTap: () => themeProvider.setTitleFont(opt.family),
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
                onTap: () => themeProvider.setBodyFont(opt.family),
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
