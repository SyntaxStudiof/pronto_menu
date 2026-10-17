import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/theme_provider.dart';
import '/app_themes.dart';
import '/services/translation_service.dart';
import '/cliente/dettagli_piatto_popup/dettagli_piatto_popup_widget.dart';
import 'personalizzazione_presets.dart';

/// Simulatore interattivo a schermo intero del menù cliente.
/// Permette al ristoratore di testare l'esperienza dei clienti dal vivo
/// con cambio tema chiaro/scuro, frame smartphone e cambio lingua.
class SimulatoreMenuClienteWidget extends StatefulWidget {
  final DocumentReference ristoranteRef;
  final AppDesignStyle initialDesignStyle;
  final Color initialPrimaryColor;
  final String initialTitleFont;
  final String initialBodyFont;
  final DishCardLayout initialDishLayout;
  final String initialCoverBanner;
  final BackgroundTexture initialBackgroundTexture;
  final BadgeStyle initialBadgeStyle;

  const SimulatoreMenuClienteWidget({
    super.key,
    required this.ristoranteRef,
    required this.initialDesignStyle,
    required this.initialPrimaryColor,
    required this.initialTitleFont,
    required this.initialBodyFont,
    required this.initialDishLayout,
    required this.initialCoverBanner,
    required this.initialBackgroundTexture,
    required this.initialBadgeStyle,
  });

  static Future<bool?> open(
    BuildContext context, {
    required DocumentReference ristoranteRef,
    required AppDesignStyle initialDesignStyle,
    required Color initialPrimaryColor,
    required String initialTitleFont,
    required String initialBodyFont,
    required DishCardLayout initialDishLayout,
    required String initialCoverBanner,
    required BackgroundTexture initialBackgroundTexture,
    required BadgeStyle initialBadgeStyle,
  }) {
    return Navigator.of(context).push<bool>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (ctx) => SimulatoreMenuClienteWidget(
          ristoranteRef: ristoranteRef,
          initialDesignStyle: initialDesignStyle,
          initialPrimaryColor: initialPrimaryColor,
          initialTitleFont: initialTitleFont,
          initialBodyFont: initialBodyFont,
          initialDishLayout: initialDishLayout,
          initialCoverBanner: initialCoverBanner,
          initialBackgroundTexture: initialBackgroundTexture,
          initialBadgeStyle: initialBadgeStyle,
        ),
      ),
    );
  }

  @override
  State<SimulatoreMenuClienteWidget> createState() =>
      _SimulatoreMenuClienteWidgetState();
}

class _SimulatoreMenuClienteWidgetState
    extends State<SimulatoreMenuClienteWidget> {
  late bool _isDarkMode;
  bool _isPhoneFrameMode = false;
  String _currentLang = 'it';
  bool _isSaving = false;

  String? _selectedCategoryName;

  @override
  void initState() {
    super.initState();
    _isDarkMode = false;
  }

  Future<void> _publishAndSave() async {
    setState(() => _isSaving = true);
    try {
      final hex =
          '#${widget.initialPrimaryColor.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';

      await widget.ristoranteRef.update({
        'temaScelto': widget.initialDesignStyle.name,
        'colore_primario': hex,
        'font_titoli': widget.initialTitleFont,
        'font_testi': widget.initialBodyFont,
        'layout_piatti': widget.initialDishLayout.name,
        'banner_copertina': widget.initialCoverBanner,
        'texture_sfondo': widget.initialBackgroundTexture.name,
        'stile_badge': widget.initialBadgeStyle.value,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.check_circle_rounded, color: Colors.white, size: 20.0),
              SizedBox(width: 10.0),
              Text(
                'Menù pubblicato con successo sul Cloud!',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF0B9F74),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Errore durante il salvataggio: $e'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final clientTheme = AppThemes.buildTheme(
      designStyle: widget.initialDesignStyle,
      primaryColor: widget.initialPrimaryColor,
      brightness: _isDarkMode ? Brightness.dark : Brightness.light,
      titleFont: widget.initialTitleFont,
      bodyFont: widget.initialBodyFont,
    );

    return Scaffold(
      backgroundColor: const Color(0xFF111418),
      body: SafeArea(
        child: Column(
          children: [
            // ─── TOOLBAR DI CONTROLLO SIMULATORE ───
            _buildSimulationToolbar(clientTheme),

            // ─── VIEWPORT MENÙ (INTERO O CORNICE SMARTPHONE) ───
            Expanded(
              child: Center(
                child: _isPhoneFrameMode
                    ? _buildPhoneFrame(clientTheme)
                    : _buildFullMenuCanvas(clientTheme),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimulationToolbar(ThemeData clientTheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: const Color(0xFF1E232B),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withValues(alpha: 0.08),
            width: 1.0,
          ),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Chiudi simulatore
            IconButton(
              icon: const Icon(Icons.close_rounded, color: Colors.white, size: 22.0),
              tooltip: 'Esci dal simulatore',
              onPressed: () => Navigator.of(context).pop(false),
            ),
            const SizedBox(width: 4.0),

            // Indicatore modalità
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
              decoration: BoxDecoration(
                color: widget.initialPrimaryColor.withValues(alpha: 0.20),
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(
                  color: widget.initialPrimaryColor.withValues(alpha: 0.40),
                  width: 1.0,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.smartphone_rounded,
                      color: widget.initialPrimaryColor, size: 15.0),
                  const SizedBox(width: 5.0),
                  Text(
                    'SIMULATORE MENÙ DAL VIVO',
                    style: TextStyle(
                      color: widget.initialPrimaryColor,
                      fontSize: 11.0,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10.0),

            // Toggle Cornice Telefono
            Tooltip(
              message: _isPhoneFrameMode ? 'Schermo intero' : 'Cornice smartphone',
              child: InkWell(
                borderRadius: BorderRadius.circular(8.0),
                onTap: () => setState(() => _isPhoneFrameMode = !_isPhoneFrameMode),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
                  decoration: BoxDecoration(
                    color: _isPhoneFrameMode
                        ? Colors.white.withValues(alpha: 0.18)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                      width: 1.0,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _isPhoneFrameMode ? Icons.fullscreen_rounded : Icons.phone_android_rounded,
                        color: Colors.white,
                        size: 16.0,
                      ),
                      const SizedBox(width: 4.0),
                      Text(
                        _isPhoneFrameMode ? 'Intero' : 'Cornice',
                        style: const TextStyle(color: Colors.white, fontSize: 11.5),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8.0),

            // Toggle Dark / Light Mode
            Tooltip(
              message: _isDarkMode ? 'Passa a tema Chiaro' : 'Passa a tema Scuro',
              child: InkWell(
                borderRadius: BorderRadius.circular(8.0),
                onTap: () => setState(() => _isDarkMode = !_isDarkMode),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                        color: _isDarkMode ? Colors.amberAccent : Colors.orangeAccent,
                        size: 16.0,
                      ),
                      const SizedBox(width: 4.0),
                      Text(
                        _isDarkMode ? 'Scuro' : 'Chiaro',
                        style: const TextStyle(color: Colors.white, fontSize: 11.5),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8.0),

            // Selettore lingua veloce
            PopupMenuButton<String>(
              initialValue: _currentLang,
              tooltip: 'Cambia lingua di simulazione',
              color: const Color(0xFF232934),
              onSelected: (val) => setState(() => _currentLang = val),
              itemBuilder: (ctx) => [
                const PopupMenuItem(value: 'it', child: Text('🇮🇹 Italiano', style: TextStyle(color: Colors.white))),
                const PopupMenuItem(value: 'en', child: Text('🇬🇧 English', style: TextStyle(color: Colors.white))),
                const PopupMenuItem(value: 'es', child: Text('🇪🇸 Español', style: TextStyle(color: Colors.white))),
                const PopupMenuItem(value: 'fr', child: Text('🇫🇷 Français', style: TextStyle(color: Colors.white))),
                const PopupMenuItem(value: 'de', child: Text('🇩🇪 Deutsch', style: TextStyle(color: Colors.white))),
              ],
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _currentLang.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 11.5,
                      ),
                    ),
                    const Icon(Icons.arrow_drop_down_rounded, color: Colors.white, size: 16.0),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12.0),

            // Pulsante Salva & Pubblica ORA
            ElevatedButton.icon(
              onPressed: _isSaving ? null : _publishAndSave,
              icon: _isSaving
                  ? const SizedBox(
                      width: 14.0,
                      height: 14.0,
                      child: CircularProgressIndicator(strokeWidth: 2.0, color: Colors.white),
                    )
                  : const Icon(Icons.cloud_upload_rounded, size: 16.0),
              label: const Text(
                'Salva & Pubblica',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.0),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0B9F74),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhoneFrame(ThemeData clientTheme) {
    return Container(
      width: 375.0,
      margin: const EdgeInsets.symmetric(vertical: 16.0),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(44.0),
        border: Border.all(
          color: const Color(0xFF2C323E),
          width: 8.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            blurRadius: 30.0,
            offset: const Offset(0.0, 10.0),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Dynamic Island / Speaker bar
          Container(
            height: 28.0,
            color: clientTheme.scaffoldBackgroundColor,
            alignment: Alignment.center,
            child: Container(
              width: 90.0,
              height: 12.0,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
          // Schermo smartphone
          Expanded(
            child: _buildFullMenuCanvas(clientTheme),
          ),
        ],
      ),
    );
  }

  Widget _buildFullMenuCanvas(ThemeData clientTheme) {
    return Theme(
      data: clientTheme,
      child: Container(
        decoration: PersonalizzazionePresets.getTextureDecoration(
          texture: widget.initialBackgroundTexture,
          isDark: _isDarkMode,
          theme: clientTheme,
        ),
        child: StreamBuilder<UsersRecord>(
          stream: UsersRecord.getDocument(widget.ristoranteRef),
          builder: (context, snapshot) {
            final restaurant = snapshot.data;
            final restaurantName = restaurant?.displayName ?? 'Ristorante';
            final photoUrl = restaurant?.photoUrl;
            final resolvedBanner =
                PersonalizzazionePresets.resolveBannerUrl(widget.initialCoverBanner);

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // ─── HERO COVER BANNER & APP BAR ───
                SliverAppBar(
                  expandedHeight: resolvedBanner.isNotEmpty ? 190.0 : 100.0,
                  pinned: true,
                  elevation: 1.0,
                  automaticallyImplyLeading: false,
                  backgroundColor: clientTheme.appBarTheme.backgroundColor ??
                      clientTheme.scaffoldBackgroundColor,
                  flexibleSpace: FlexibleSpaceBar(
                    titlePadding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 12.0),
                    title: Row(
                      children: [
                        if (photoUrl != null && photoUrl.isNotEmpty) ...[
                          Container(
                            width: 32.0,
                            height: 32.0,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: widget.initialPrimaryColor,
                                width: 1.5,
                              ),
                              image: DecorationImage(
                                image: NetworkImage(photoUrl),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8.0),
                        ],
                        Expanded(
                          child: Text(
                            restaurantName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.getFont(
                              widget.initialTitleFont,
                              textStyle: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                                color: clientTheme.appBarTheme.foregroundColor ??
                                    clientTheme.colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    background: resolvedBanner.isNotEmpty
                        ? Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.network(
                                resolvedBanner,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  color: widget.initialPrimaryColor
                                      .withValues(alpha: 0.2),
                                ),
                              ),
                              Container(
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
                              ),
                            ],
                          )
                        : null,
                  ),
                ),

                // ─── BARRA CATEGORIE ORIZZONTALE ───
                SliverToBoxAdapter(
                  child: _buildCategoriesStream(clientTheme),
                ),

                // ─── ELENCO PIATTI CON IL LAYOUT SCELTO ───
                _buildDishesSliver(clientTheme, restaurant),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCategoriesStream(ThemeData clientTheme) {
    return StreamBuilder<List<CategoriesRecord>>(
      stream: queryCategoriesRecord(
        queryBuilder: (query) => query
            .where('proprietario', isEqualTo: widget.ristoranteRef)
            .orderBy('ordine_categoria'),
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox(height: 50.0);
        final categories = snapshot.data!;
        if (categories.isEmpty) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 14.0),
            child: Row(
              children: [
                // Pillola Tutte le Categorie
                _buildCategoryPill(
                  title: TranslationService.getUi('tutte_le_categorie', _currentLang),
                  icon: Icons.restaurant_menu_rounded,
                  isSelected: _selectedCategoryName == null || _selectedCategoryName!.isEmpty,
                  clientTheme: clientTheme,
                  onTap: () {
                    setState(() {
                      _selectedCategoryName = null;
                    });
                  },
                ),
                const SizedBox(width: 8.0),
                ...categories.map((cat) {
                  final isSel = _selectedCategoryName == cat.name;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: _buildCategoryPill(
                      title: TranslationService.getCategoryName(cat.name, _currentLang),
                      icon: Icons.local_dining_rounded,
                      isSelected: isSel,
                      clientTheme: clientTheme,
                      onTap: () {
                        setState(() {
                          if (isSel) {
                            _selectedCategoryName = null;
                          } else {
                            _selectedCategoryName = cat.name;
                          }
                        });
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoryPill({
    required String title,
    required IconData icon,
    required bool isSelected,
    required ThemeData clientTheme,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 7.0),
        decoration: BoxDecoration(
          color: isSelected
              ? widget.initialPrimaryColor
              : clientTheme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(
            color: isSelected
                ? widget.initialPrimaryColor
                : clientTheme.dividerColor.withValues(alpha: 0.2),
            width: 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: widget.initialPrimaryColor.withValues(alpha: 0.3),
                    blurRadius: 6.0,
                    offset: const Offset(0.0, 2.0),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14.0,
              color: isSelected ? Colors.white : widget.initialPrimaryColor,
            ),
            const SizedBox(width: 6.0),
            Text(
              title,
              style: GoogleFonts.getFont(
                widget.initialTitleFont,
                textStyle: TextStyle(
                  fontSize: 12.5,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  color: isSelected
                      ? Colors.white
                      : clientTheme.colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDishesSliver(ThemeData clientTheme, UsersRecord? restaurant) {
    return StreamBuilder<List<PiattiRecord>>(
      stream: queryPiattiRecord(
        queryBuilder: (query) {
          var q = query
              .where('proprietario', isEqualTo: widget.ristoranteRef)
              .where('isCestinato', isEqualTo: false);
          if (_selectedCategoryName != null && _selectedCategoryName!.isNotEmpty) {
            q = q.where('Categoria', isEqualTo: _selectedCategoryName);
          }
          return q;
        },
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final dishes = snapshot.data!;
        if (dishes.isEmpty) {
          return SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Text(
                'Nessun piatto in questa categoria.',
                style: TextStyle(
                  color: clientTheme.colorScheme.onSurfaceVariant,
                  fontSize: 13.5,
                ),
              ),
            ),
          );
        }

        switch (widget.initialDishLayout) {
          case DishCardLayout.griglia:
            return SliverPadding(
              padding: const EdgeInsets.fromLTRB(12.0, 6.0, 12.0, 40.0),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.68,
                  crossAxisSpacing: 10.0,
                  mainAxisSpacing: 10.0,
                ),
                delegate: SliverChildBuilderDelegate(
                  (ctx, idx) => _buildDishItem(clientTheme, dishes[idx], restaurant),
                  childCount: dishes.length,
                ),
              ),
            );

          case DishCardLayout.fotoGrande:
          case DishCardLayout.minimale:
          case DishCardLayout.classico:
            return SliverPadding(
              padding: const EdgeInsets.fromLTRB(12.0, 6.0, 12.0, 40.0),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, idx) => _buildDishItem(clientTheme, dishes[idx], restaurant),
                  childCount: dishes.length,
                ),
              ),
            );
        }
      },
    );
  }

  Widget _buildDishItem(
    ThemeData clientTheme,
    PiattiRecord dish,
    UsersRecord? restaurant,
  ) {
    final title = dish.nome;
    final desc = dish.descrizione.isNotEmpty
        ? TranslationService.getDishDescription(dish, _currentLang)
        : TranslationService.getDishIngredients(dish, _currentLang);
    final priceStr = '€ ${dish.prezzo.toStringAsFixed(2)}';
    final hasPhoto = dish.foto.isNotEmpty;

    final badgeDeco = PersonalizzazionePresets.getBadgeDecoration(
      style: widget.initialBadgeStyle,
      baseColor: widget.initialPrimaryColor,
      isDark: _isDarkMode,
      isFilled: true,
    );
    final badgeTextColor = PersonalizzazionePresets.getBadgeTextColor(
      style: widget.initialBadgeStyle,
      baseColor: widget.initialPrimaryColor,
      isDark: _isDarkMode,
      isFilled: true,
    );

    return InkWell(
      onTap: () {
        if (restaurant != null) {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (ctx) => DettagliPiattoPopupWidget(
              piattoSelezionato: dish,
              currentLang: _currentLang,
              ingredientiEsauriti: const <String>{},
              ristoranteRef: widget.ristoranteRef,
              dispensaAttiva: restaurant.dispensaAttiva,
              modifichePiattiAttive: restaurant.modifichePiattiAttive,
              ingredientiManualiAttivi: restaurant.ingredientiManualiAttivi,
              prezzoAggiuntaManuale: restaurant.prezzoAggiuntaManuale,
              solaConsultazione: true,
              mostraFoto: restaurant.hasUltra,
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10.0),
        decoration: BoxDecoration(
          color: clientTheme.cardColor,
          borderRadius: BorderRadius.circular(14.0),
          border: Border.all(
            color: clientTheme.dividerColor.withValues(alpha: 0.15),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: _isDarkMode ? 0.25 : 0.04),
              blurRadius: 8.0,
              offset: const Offset(0.0, 3.0),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: _buildDishLayoutContent(
          clientTheme,
          dish,
          title,
          desc,
          priceStr,
          hasPhoto,
          badgeDeco,
          badgeTextColor,
        ),
      ),
    );
  }

  Widget _buildDishLayoutContent(
    ThemeData clientTheme,
    PiattiRecord dish,
    String title,
    String desc,
    String priceStr,
    bool hasPhoto,
    BoxDecoration badgeDeco,
    Color badgeTextColor,
  ) {
    switch (widget.initialDishLayout) {
      case DishCardLayout.fotoGrande:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (hasPhoto)
              SizedBox(
                height: 140.0,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(dish.foto, fit: BoxFit.cover),
                    Positioned(
                      top: 8.0,
                      right: 8.0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9.0, vertical: 4.0),
                        decoration: badgeDeco,
                        child: Text(
                          priceStr,
                          style: GoogleFonts.getFont(
                            widget.initialTitleFont,
                            textStyle: TextStyle(
                              color: badgeTextColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.getFont(
                      widget.initialTitleFont,
                      textStyle: TextStyle(
                        fontSize: 15.0,
                        fontWeight: FontWeight.bold,
                        color: clientTheme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  if (desc.isNotEmpty) ...[
                    const SizedBox(height: 3.0),
                    Text(
                      desc,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.getFont(
                        widget.initialBodyFont,
                        textStyle: TextStyle(
                          fontSize: 11.5,
                          color: clientTheme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        );

      case DishCardLayout.griglia:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 3,
              child: hasPhoto
                  ? Image.network(dish.foto, fit: BoxFit.cover)
                  : Container(
                      color: widget.initialPrimaryColor.withValues(alpha: 0.1),
                      child: Icon(Icons.restaurant_rounded, color: widget.initialPrimaryColor),
                    ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.getFont(
                        widget.initialTitleFont,
                        textStyle: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7.0, vertical: 2.5),
                      decoration: badgeDeco,
                      child: Text(
                        priceStr,
                        style: TextStyle(
                          color: badgeTextColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 11.0,
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
        return Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: GoogleFonts.getFont(
                        widget.initialTitleFont,
                        textStyle: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
                    decoration: badgeDeco,
                    child: Text(
                      priceStr,
                      style: TextStyle(
                        color: badgeTextColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12.0,
                      ),
                    ),
                  ),
                ],
              ),
              if (desc.isNotEmpty) ...[
                const SizedBox(height: 3.0),
                Text(
                  desc,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.getFont(
                    widget.initialBodyFont,
                    textStyle: TextStyle(
                      fontSize: 11.5,
                      fontStyle: FontStyle.italic,
                      color: clientTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );

      case DishCardLayout.classico:
        return Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (hasPhoto) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: Image.network(
                    dish.foto,
                    width: 64.0,
                    height: 64.0,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 10.0),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.getFont(
                        widget.initialTitleFont,
                        textStyle: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
                      ),
                    ),
                    if (desc.isNotEmpty) ...[
                      const SizedBox(height: 2.0),
                      Text(
                        desc,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.getFont(
                          widget.initialBodyFont,
                          textStyle: TextStyle(
                            fontSize: 11.5,
                            color: clientTheme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8.0),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.5),
                decoration: badgeDeco,
                child: Text(
                  priceStr,
                  style: GoogleFonts.getFont(
                    widget.initialTitleFont,
                    textStyle: TextStyle(
                      color: badgeTextColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
    }
  }
}
