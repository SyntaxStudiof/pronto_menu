import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/components/comp_add_category_widget.dart';
import '/components/pannello_modifica_piatto_widget.dart';
import '/components/popup_categoria_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import '/services/category_icon_helper.dart';
import '/services/audit_log_service.dart';

/// Vista Desktop Master-Detail per la gestione completa di Menù & Categorie
class DesktopMenuView extends StatefulWidget {
  const DesktopMenuView({
    super.key,
    required this.ristoranteRef,
  });

  final DocumentReference? ristoranteRef;

  @override
  State<DesktopMenuView> createState() => _DesktopMenuViewState();
}

class _DesktopMenuViewState extends State<DesktopMenuView> {
  static final Map<String, List<CategoriesRecord>> _globalCategoriesCache = {};
  static final Map<String, List<PiattiRecord>> _globalDishesCache = {};

  DocumentReference? _selectedCategoryRef;
  String _dishSearchQuery = '';
  final TextEditingController _dishSearchController = TextEditingController();
  PiattiRecord? _editingDish;

  Stream<List<CategoriesRecord>>? _categoriesStream;
  List<CategoriesRecord>? _cachedCategories;

  Stream<List<PiattiRecord>>? _dishesStream;
  List<PiattiRecord>? _cachedDishes;
  DocumentReference? _currentDishStreamCatRef;
  DocumentReference? _lastDocRef;

  @override
  void dispose() {
    _dishSearchController.dispose();
    super.dispose();
  }

  void _showAddCategoryDialog(BuildContext context, DocumentReference docRef) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480.0),
          child: CompAddCategoryWidget(ristoranteRef: docRef),
        ),
      ),
    );
  }

  void _showEditCategoryDialog(
    BuildContext context,
    CategoriesRecord cat,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480.0),
          child: PopupCategoriaWidget(
            refCategoria: cat.reference,
            nomeAttuale: cat.name,
            categoriaInModifica: cat.reference,
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDeleteCategory(
    BuildContext context,
    CategoriesRecord cat,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Elimina "${cat.name}"?'),
        content: const Text(
          'Eliminando questa categoria, i piatti al suo interno rimarranno nel database ma non saranno più associati ad essa. Sei sicuro di voler procedere?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annulla'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Elimina'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await cat.reference.delete();
      if (mounted && _selectedCategoryRef == cat.reference) {
        setState(() => _selectedCategoryRef = null);
      }
    }
  }

  void _openCreateDish(BuildContext context, DocumentReference docRef, DocumentReference? categoryRef) {
    context.pushNamed(
      CreaPiattoWidget.routeName,
      queryParameters: {
        'ristoranteRef': serializeParam(docRef, ParamType.DocumentReference),
        if (categoryRef != null)
          'categoriaSelezionata': serializeParam(categoryRef, ParamType.DocumentReference),
      }.withoutNulls,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final docRef = widget.ristoranteRef ?? currentUserReference!;
    final catCacheKey = docRef.id;

    if (_categoriesStream == null || _lastDocRef != docRef) {
      _lastDocRef = docRef;
      _cachedCategories = _globalCategoriesCache[catCacheKey];
      _categoriesStream = queryCategoriesRecord(
        queryBuilder: (q) => q
            .where('proprietario', isEqualTo: docRef)
            .orderBy('ordine_categoria'),
      );
    }

    return StreamBuilder<List<CategoriesRecord>>(
      stream: _categoriesStream,
      initialData: _cachedCategories,
      builder: (context, catSnapshot) {
        if (catSnapshot.hasData && catSnapshot.data != null) {
          _cachedCategories = catSnapshot.data;
          _globalCategoriesCache[catCacheKey] = catSnapshot.data!;
        }
        if (!catSnapshot.hasData) {
          return Center(
            child: SpinKitPulse(
              color: colorScheme.primary,
              size: 44.0,
            ),
          );
        }

        final categories = catSnapshot.data!.toList()
          ..sort((a, b) => a.ordineCategoria.compareTo(b.ordineCategoria));

        // Seleziona la prima categoria se nessuna è selezionata
        if (categories.isNotEmpty) {
          if (_selectedCategoryRef == null ||
              !categories.any((c) => c.reference == _selectedCategoryRef)) {
            _selectedCategoryRef = categories.first.reference;
          }
        } else {
          _selectedCategoryRef = null;
        }

        final currentCategory = categories.firstWhereOrNull(
          (c) => c.reference == _selectedCategoryRef,
        );

        if (currentCategory != null) {
          final dishCacheKey = '${docRef.id}_${currentCategory.reference.id}';
          if (_dishesStream == null ||
              _currentDishStreamCatRef != currentCategory.reference) {
            _currentDishStreamCatRef = currentCategory.reference;
            _cachedDishes = _globalDishesCache[dishCacheKey];
            _dishesStream = queryPiattiRecord(
              queryBuilder: (q) => q
                  .where('proprietario', isEqualTo: docRef)
                  .where('Categoria', isEqualTo: currentCategory.reference.id)
                  .where('isCestinato', isEqualTo: false),
            );
          }
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ═════════════════════════════════════════════════════════════════
            // COLONNA SINISTRA: LISTA DELLE CATEGORIE (~340px)
            // ═════════════════════════════════════════════════════════════════
            Container(
              width: 340.0,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                border: Border(
                  right: BorderSide(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : const Color(0xFFE2E8F0),
                    width: 1.0,
                  ),
                ),
              ),
              child: Column(
                children: [
                  // Header Categorie
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18.0, 18.0, 18.0, 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Categorie',
                                  style: TextStyle(
                                    fontSize: 17.0,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.3,
                                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(width: 8.0),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                                  decoration: BoxDecoration(
                                    color: colorScheme.primary.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  child: Text(
                                    '${categories.length}',
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            // Tasto Nuova Categoria
                            ElevatedButton.icon(
                              onPressed: () => _showAddCategoryDialog(context, docRef),
                              icon: const Icon(Icons.add_rounded, size: 16.0),
                              label: const Text('Nuova', style: TextStyle(fontSize: 12.5)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colorScheme.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12.0),

                        // Azioni Rapide Categorie (Ordina / Sottocategorie)
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => context.pushNamed(ImpostazioniCategorieWidget.routeName),
                                icon: const Icon(Icons.format_list_bulleted_rounded, size: 14.0),
                                label: const Text('Ordina', style: TextStyle(fontSize: 11.5)),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8.0),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => context.pushNamed(ImpostazioniSottocategorieWidget.routeName),
                                icon: const Icon(Icons.account_tree_rounded, size: 14.0),
                                label: const Text('Sottocat.', style: TextStyle(fontSize: 11.5)),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const Divider(height: 1.0),

                  // Lista Scorrevole Categorie
                  Expanded(
                    child: categories.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.restaurant_menu_rounded,
                                    size: 40.0,
                                    color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                                  ),
                                  const SizedBox(height: 12.0),
                                  Text(
                                    'Nessuna categoria',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                                    ),
                                  ),
                                  const SizedBox(height: 6.0),
                                  Text(
                                    'Crea la tua prima categoria per iniziare.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 12.0,
                                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
                            itemCount: categories.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 6.0),
                            itemBuilder: (context, index) {
                              final cat = categories[index];
                              final isSelected = cat.reference == _selectedCategoryRef;

                              return Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      _selectedCategoryRef = cat.reference;
                                      _editingDish = null;
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(10.0),
                                  hoverColor: colorScheme.primary.withValues(alpha: 0.05),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 150),
                                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? colorScheme.primary.withValues(alpha: isDark ? 0.16 : 0.10)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(10.0),
                                      border: Border.all(
                                        color: isSelected
                                            ? colorScheme.primary.withValues(alpha: 0.35)
                                            : Colors.transparent,
                                        width: 1.0,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        // Icona Categoria
                                        Container(
                                          width: 36.0,
                                          height: 36.0,
                                          decoration: BoxDecoration(
                                            color: colorScheme.primary.withValues(alpha: isSelected ? 0.2 : 0.08),
                                            borderRadius: BorderRadius.circular(8.0),
                                          ),
                                          alignment: Alignment.center,
                                          child: Icon(
                                            CategoryIconHelper.getCategoryIcon(cat.name),
                                            size: 19.0,
                                            color: colorScheme.primary,
                                          ),
                                        ),
                                        const SizedBox(width: 12.0),
                                        // Nome
                                        Expanded(
                                          child: Text(
                                            cat.name,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 13.5,
                                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                              color: isSelected
                                                  ? colorScheme.primary
                                                  : (isDark ? Colors.white : const Color(0xFF1E293B)),
                                            ),
                                          ),
                                        ),
                                        // Menu a comparsa Modifica / Elimina Categoria
                                        PopupMenuButton<String>(
                                          tooltip: 'Opzioni Categoria',
                                          icon: Icon(
                                            Icons.more_vert_rounded,
                                            size: 18.0,
                                            color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                                          ),
                                          onSelected: (val) {
                                            if (val == 'edit') {
                                              _showEditCategoryDialog(context, cat);
                                            } else if (val == 'delete') {
                                              _confirmDeleteCategory(context, cat);
                                            }
                                          },
                                          itemBuilder: (ctx) => [
                                            const PopupMenuItem(
                                              value: 'edit',
                                              child: Row(
                                                children: [
                                                  Icon(Icons.edit_rounded, size: 16.0),
                                                  SizedBox(width: 8.0),
                                                  Text('Rinomina Categoria'),
                                                ],
                                              ),
                                            ),
                                            const PopupMenuItem(
                                              value: 'delete',
                                              child: Row(
                                                children: [
                                                  Icon(Icons.delete_outline_rounded, color: Colors.red, size: 16.0),
                                                  SizedBox(width: 8.0),
                                                  Text('Elimina Categoria', style: TextStyle(color: Colors.red)),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),

            // ═════════════════════════════════════════════════════════════════
            // COLONNA CENTRALE/DESTRA: PIATTI DELLA CATEGORIA SELEZIONATA
            // ═════════════════════════════════════════════════════════════════
            Expanded(
              child: currentCategory == null
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.category_rounded,
                            size: 48.0,
                            color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                          ),
                          const SizedBox(height: 16.0),
                          Text(
                            'Seleziona o crea una categoria',
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          ElevatedButton.icon(
                            onPressed: () => _showAddCategoryDialog(context, docRef),
                            icon: const Icon(Icons.add_rounded),
                            label: const Text('Crea la prima Categoria'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.primary,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Lista Piatti
                        Expanded(
                          child: Column(
                            children: [
                              // Top Bar della Categoria Selezionata
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                                  border: Border(
                                    bottom: BorderSide(
                                      color: isDark
                                          ? Colors.white.withValues(alpha: 0.08)
                                          : const Color(0xFFE2E8F0),
                                      width: 1.0,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      CategoryIconHelper.getCategoryIcon(currentCategory.name),
                                      color: colorScheme.primary,
                                      size: 24.0,
                                    ),
                                    const SizedBox(width: 12.0),
                                    Text(
                                      currentCategory.name,
                                      style: TextStyle(
                                        fontSize: 19.0,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: -0.4,
                                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                                      ),
                                    ),
                                    const SizedBox(width: 16.0),

                                    // Campo Ricerca Piatto
                                    SizedBox(
                                      width: 220.0,
                                      height: 38.0,
                                      child: TextField(
                                        controller: _dishSearchController,
                                        onChanged: (val) => setState(() => _dishSearchQuery = val.trim().toLowerCase()),
                                        style: const TextStyle(fontSize: 13.0),
                                        decoration: InputDecoration(
                                          hintText: 'Cerca piatto...',
                                          prefixIcon: const Icon(Icons.search_rounded, size: 18.0),
                                          suffixIcon: _dishSearchQuery.isNotEmpty
                                              ? IconButton(
                                                  icon: const Icon(Icons.close_rounded, size: 16.0),
                                                  onPressed: () {
                                                    _dishSearchController.clear();
                                                    setState(() => _dishSearchQuery = '');
                                                  },
                                                )
                                              : null,
                                          isDense: true,
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(8.0),
                                            borderSide: BorderSide(
                                              color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),

                                    const Spacer(),

                                    // Tasto + Nuovo Piatto
                                    ElevatedButton.icon(
                                      onPressed: () => _openCreateDish(context, docRef, currentCategory.reference),
                                      icon: const Icon(Icons.add_circle_outline_rounded, size: 17.0),
                                      label: const Text(
                                        'Nuovo Piatto',
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.0),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: colorScheme.primary,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Contenuto Piatti
                              Expanded(
                                child: StreamBuilder<List<PiattiRecord>>(
                                  stream: _dishesStream,
                                  initialData: _cachedDishes,
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData && snapshot.data != null) {
                                      _cachedDishes = snapshot.data;
                                      final dKey = '${docRef.id}_${currentCategory.reference.id}';
                                      _globalDishesCache[dKey] = snapshot.data!;
                                    }
                                    if (!snapshot.hasData) {
                                      return Center(
                                        child: SpinKitPulse(color: colorScheme.primary, size: 40.0),
                                      );
                                    }

                                    var dishes = snapshot.data!;
                                    if (_dishSearchQuery.isNotEmpty) {
                                      dishes = dishes.where((p) {
                                        final nameMatch = p.nome.toLowerCase().contains(_dishSearchQuery);
                                        final descMatch = p.descrizione.toLowerCase().contains(_dishSearchQuery);
                                        final ingMatch = p.ingredienti.toLowerCase().contains(_dishSearchQuery);
                                        return nameMatch || descMatch || ingMatch;
                                      }).toList();
                                    }

                                    if (dishes.isEmpty) {
                                      return Center(
                                        child: Padding(
                                          padding: const EdgeInsets.all(32.0),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                width: 64.0,
                                                height: 64.0,
                                                decoration: BoxDecoration(
                                                  color: colorScheme.primary.withValues(alpha: 0.1),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Icon(
                                                  Icons.flatware_rounded,
                                                  size: 32.0,
                                                  color: colorScheme.primary,
                                                ),
                                              ),
                                              const SizedBox(height: 16.0),
                                              Text(
                                                _dishSearchQuery.isNotEmpty
                                                    ? 'Nessun piatto trovato per "$_dishSearchQuery"'
                                                    : 'Nessun piatto in "${currentCategory.name}"',
                                                style: TextStyle(
                                                  fontSize: 16.0,
                                                  fontWeight: FontWeight.bold,
                                                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                                                ),
                                              ),
                                              const SizedBox(height: 8.0),
                                              Text(
                                                _dishSearchQuery.isNotEmpty
                                                    ? 'Prova a modificare i termini di ricerca.'
                                                    : 'Aggiungi il tuo primo piatto a questa categoria per renderlo disponibile.',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize: 13.0,
                                                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                                ),
                                              ),
                                              if (_dishSearchQuery.isEmpty) ...[
                                                const SizedBox(height: 18.0),
                                                ElevatedButton.icon(
                                                  onPressed: () => _openCreateDish(context, docRef, currentCategory.reference),
                                                  icon: const Icon(Icons.add_rounded),
                                                  label: const Text('Aggiungi Piatto Adesso'),
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: colorScheme.primary,
                                                    foregroundColor: Colors.white,
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                      );
                                    }

                                    return GridView.builder(
                                      padding: const EdgeInsets.all(20.0),
                                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                                        maxCrossAxisExtent: 440.0,
                                        mainAxisExtent: 185.0,
                                        crossAxisSpacing: 16.0,
                                        mainAxisSpacing: 16.0,
                                      ),
                                      itemCount: dishes.length,
                                      itemBuilder: (context, index) {
                                        final dish = dishes[index];
                                        final isEditingThis = _editingDish?.reference.id == dish.reference.id;

                                        return _buildDishCard(
                                          context: context,
                                          dish: dish,
                                          isDark: isDark,
                                          colorScheme: colorScheme,
                                          isSelectedForEdit: isEditingThis,
                                          docRef: docRef,
                                          onEdit: () {
                                            setState(() {
                                              if (_editingDish?.reference.id == dish.reference.id) {
                                                _editingDish = null;
                                              } else {
                                                _editingDish = dish;
                                              }
                                            });
                                          },
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Pannello Laterale di Modifica Piatto Desktop (se aperto)
                        if (_editingDish != null)
                          Container(
                            width: 420.0,
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF1E293B) : Colors.white,
                              border: Border(
                                left: BorderSide(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.08)
                                      : const Color(0xFFE2E8F0),
                                  width: 1.0,
                                ),
                              ),
                            ),
                            child: PannelloModificaPiattoWidget(
                              piatto: _editingDish!,
                              categoriaRef: currentCategory.reference,
                              ristoranteRef: docRef,
                              onClose: () => setState(() => _editingDish = null),
                              onSaved: (aggiornato) => setState(() => _editingDish = null),
                            ),
                          ),
                      ],
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDishCard({
    required BuildContext context,
    required PiattiRecord dish,
    required bool isDark,
    required ColorScheme colorScheme,
    required bool isSelectedForEdit,
    required DocumentReference docRef,
    required VoidCallback onEdit,
  }) {
    final hasImage = dish.foto.isNotEmpty;
    final allergeniCount = dish.allergeni.length;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(
          color: isSelectedForEdit
              ? colorScheme.primary
              : (isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0)),
          width: isSelectedForEdit ? 2.0 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 8.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onEdit,
          borderRadius: BorderRadius.circular(14.0),
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Immagine Piatto
                ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: Container(
                    width: 78.0,
                    height: 78.0,
                    color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                    child: hasImage
                        ? CachedNetworkImage(
                            imageUrl: dish.foto,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Center(
                              child: SpinKitPulse(color: colorScheme.primary, size: 20.0),
                            ),
                            errorWidget: (_, __, ___) => Icon(
                              Icons.restaurant_rounded,
                              color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                            ),
                          )
                        : Icon(
                            Icons.restaurant_rounded,
                            size: 32.0,
                            color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                          ),
                  ),
                ),

                const SizedBox(width: 14.0),

                // Informazioni Piatto
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Titolo e Prezzo
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              dish.nome,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 15.0,
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white : const Color(0xFF0F172A),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8.0),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7.0, vertical: 3.0),
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6.0),
                            ),
                            child: Text(
                              '€ ${dish.prezzo.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 13.0,
                                fontWeight: FontWeight.w800,
                                color: colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 4.0),

                      // Ingredienti / Descrizione
                      Text(
                        dish.ingredienti.isNotEmpty
                            ? dish.ingredienti
                            : (dish.descrizione.isNotEmpty ? dish.descrizione : 'Nessuna descrizione specificata'),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.0,
                          height: 1.35,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        ),
                      ),

                      const Spacer(),

                      // Barra Azioni & Disponibilità
                      Row(
                        children: [
                          // Badge Menu Attivo
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.5),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6.0),
                              border: Border.all(
                                color: const Color(0xFF10B981).withValues(alpha: 0.25),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6.0,
                                  height: 6.0,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF10B981),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 5.0),
                                const Text(
                                  'Attivo nel menu',
                                  style: TextStyle(
                                    fontSize: 11.0,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF059669),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (allergeniCount > 0) ...[
                            const SizedBox(width: 8.0),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7.0, vertical: 3.5),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6.0),
                              ),
                              child: Text(
                                '$allergeniCount allergeni',
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFD97706),
                                ),
                              ),
                            ),
                          ],

                          const Spacer(),

                          // Tasto Modifica
                          IconButton(
                            tooltip: 'Modifica Piatto',
                            icon: Icon(
                              Icons.edit_rounded,
                              size: 18.0,
                              color: colorScheme.primary,
                            ),
                            onPressed: onEdit,
                          ),

                          // Tasto Cestina
                          IconButton(
                            tooltip: 'Sposta nel Cestino',
                            icon: const Icon(
                              Icons.delete_outline_rounded,
                              size: 18.0,
                              color: Color(0xFFEF4444),
                            ),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: Text('Cestinare "${dish.nome}"?'),
                                  content: const Text(
                                    'Il piatto verrà spostato nel Cestino per 7 giorni prima di essere eliminato definitivamente.',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx, false),
                                      child: const Text('Annulla'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () => Navigator.pop(ctx, true),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFFEF4444),
                                        foregroundColor: Colors.white,
                                      ),
                                      child: const Text('Sposta nel Cestino'),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true) {
                                await dish.reference.update({
                                  ...createPiattiRecordData(
                                    isCestinato: true,
                                  ),
                                  ...mapToFirestore(
                                    {
                                      'dataCestinamento': DateTime.now().add(const Duration(days: 7)),
                                    },
                                  ),
                                });
                                await AuditLogService.logAction(
                                  ristoranteRef: docRef,
                                  azione: "Ha spostato nel cestino il piatto '${dish.nome}'",
                                  dettagli: "Piatto spostato nel cestino temporaneo da vista desktop",
                                  tipoAzione: 'eliminazione_temporanea',
                                  tipoEntita: 'piatto',
                                );
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('"${dish.nome}" spostato nel cestino'),
                                      duration: const Duration(seconds: 2),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                }
                              }
                            },
                          ),
                        ],
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
  }
}
