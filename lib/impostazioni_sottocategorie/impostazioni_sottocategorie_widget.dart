import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'impostazioni_sottocategorie_model.dart';
export 'impostazioni_sottocategorie_model.dart';

class ImpostazioniSottocategorieWidget extends StatefulWidget {
  const ImpostazioniSottocategorieWidget({super.key});

  static String routeName = 'ImpostazioniSottocategorie';
  static String routePath = '/impostazioniSottocategorie';

  @override
  State<ImpostazioniSottocategorieWidget> createState() =>
      _ImpostazioniSottocategorieWidgetState();
}

class _ImpostazioniSottocategorieWidgetState
    extends State<ImpostazioniSottocategorieWidget> {
  late ImpostazioniSottocategorieModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  DocumentReference? _filtroCategoriaRef;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ImpostazioniSottocategorieModel());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _mostraDialogCrea(
    BuildContext context,
    List<CategoriesRecord> categorie,
  ) async {
    if (categorie.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Devi prima creare almeno una categoria principale.'),
        ),
      );
      return;
    }

    final nomeController = TextEditingController();
    DocumentReference? categoriaSelezionata = _filtroCategoriaRef ?? categorie.first.reference;

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final theme = Theme.of(context);
            final colorScheme = theme.colorScheme;

            return AlertDialog(
              backgroundColor: theme.cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              title: Text(
                'Nuova sottocategoria',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SizedBox(
                width: 400.0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Categoria principale',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 6.0),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      decoration: BoxDecoration(
                        color: theme.scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(
                          color: theme.dividerColor.withValues(alpha: 0.2),
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<DocumentReference>(
                          value: categoriaSelezionata,
                          isExpanded: true,
                          dropdownColor: theme.cardColor,
                          items: categorie.map((cat) {
                            return DropdownMenuItem<DocumentReference>(
                              value: cat.reference,
                              child: Text(
                                cat.name,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setDialogState(() {
                                categoriaSelezionata = val;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Text(
                      'Nome sottocategoria',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 6.0),
                    TextField(
                      controller: nomeController,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: 'Es. Pizze Bianche, Birre Artigianali...',
                        hintStyle: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                        ),
                        filled: true,
                        fillColor: theme.scaffoldBackgroundColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(
                            color: theme.dividerColor.withValues(alpha: 0.2),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(
                            color: theme.dividerColor.withValues(alpha: 0.2),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(
                            color: colorScheme.primary,
                            width: 1.5,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14.0,
                          vertical: 12.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(
                    'Annulla',
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  onPressed: () async {
                    final nome = nomeController.text.trim();
                    if (nome.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Inserisci un nome per la sottocategoria.'),
                        ),
                      );
                      return;
                    }
                    final messenger = ScaffoldMessenger.of(context);
                    Navigator.of(dialogContext).pop();

                    await SottocategorieRecord.collection.doc().set(
                      createSottocategorieRecordData(
                        nome: nome,
                        categoriaPadreRef: categoriaSelezionata,
                        proprietario: currentUserReference,
                      ),
                    );

                    messenger.showSnackBar(
                      SnackBar(
                        content: Text('Sottocategoria "$nome" creata con successo.'),
                        backgroundColor: const Color(0xFF10B981),
                      ),
                    );
                  },
                  child: const Text('Crea'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _mostraDialogModifica(
    BuildContext context,
    SottocategorieRecord sottocategoria,
    List<CategoriesRecord> categorie,
  ) async {
    final nomeController = TextEditingController(text: sottocategoria.nome);
    DocumentReference? categoriaSelezionata = sottocategoria.categoriaPadreRef;

    // Se la categoria salvata non esiste nella lista, usa la prima disponibile
    if (categoriaSelezionata == null ||
        !categorie.any((c) => c.reference == categoriaSelezionata)) {
      if (categorie.isNotEmpty) {
        categoriaSelezionata = categorie.first.reference;
      }
    }

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final theme = Theme.of(context);
            final colorScheme = theme.colorScheme;

            return AlertDialog(
              backgroundColor: theme.cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              title: Text(
                'Modifica sottocategoria',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SizedBox(
                width: 400.0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Categoria principale',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 6.0),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      decoration: BoxDecoration(
                        color: theme.scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(
                          color: theme.dividerColor.withValues(alpha: 0.2),
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<DocumentReference>(
                          value: categoriaSelezionata,
                          isExpanded: true,
                          dropdownColor: theme.cardColor,
                          items: categorie.map((cat) {
                            return DropdownMenuItem<DocumentReference>(
                              value: cat.reference,
                              child: Text(
                                cat.name,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setDialogState(() {
                                categoriaSelezionata = val;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Text(
                      'Nome sottocategoria',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 6.0),
                    TextField(
                      controller: nomeController,
                      decoration: InputDecoration(
                        hintText: 'Nome della sottocategoria',
                        hintStyle: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                        ),
                        filled: true,
                        fillColor: theme.scaffoldBackgroundColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(
                            color: theme.dividerColor.withValues(alpha: 0.2),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(
                            color: theme.dividerColor.withValues(alpha: 0.2),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(
                            color: colorScheme.primary,
                            width: 1.5,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14.0,
                          vertical: 12.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(
                    'Annulla',
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  onPressed: () async {
                    final nome = nomeController.text.trim();
                    if (nome.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Il nome non può essere vuoto.'),
                        ),
                      );
                      return;
                    }

                    final messenger = ScaffoldMessenger.of(context);
                    Navigator.of(dialogContext).pop();

                    await sottocategoria.reference.update(
                      createSottocategorieRecordData(
                        nome: nome,
                        categoriaPadreRef: categoriaSelezionata,
                      ),
                    );

                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text('Sottocategoria aggiornata con successo.'),
                        backgroundColor: Color(0xFF10B981),
                      ),
                    );
                  },
                  child: const Text('Salva modifiche'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _confermaEliminazione(
    BuildContext context,
    SottocategorieRecord sottocategoria,
  ) async {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final messenger = ScaffoldMessenger.of(context);

    final confermato = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: theme.cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.red,
                  size: 22.0,
                ),
              ),
              const SizedBox(width: 12.0),
              const Expanded(
                child: Text(
                  'Elimina sottocategoria',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            'Sei sicuro di voler eliminare "${sottocategoria.nome}"?\n\nI piatti associati non verranno eliminati, ma la loro sottocategoria verrà rimossa.',
            style: TextStyle(
              fontSize: 14.0,
              color: colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(
                'Annulla',
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Elimina'),
            ),
          ],
        );
      },
    );

    if (confermato != true) return;

    try {
      // Disassocia i piatti collegati a questa sottocategoria
      final piattiCollegati = await queryPiattiRecordOnce(
        queryBuilder: (q) => q.where(
          'sottocategoria_ref',
          isEqualTo: sottocategoria.reference,
        ),
      );

      final batch = FirebaseFirestore.instance.batch();
      for (final piatto in piattiCollegati) {
        batch.update(piatto.reference, {
          'sottocategoria_ref': FieldValue.delete(),
        });
      }
      batch.delete(sottocategoria.reference);
      await batch.commit();

      messenger.showSnackBar(
        SnackBar(
          content: Text('Sottocategoria "${sottocategoria.nome}" eliminata.'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Errore durante l\'eliminazione: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return StreamBuilder<List<CategoriesRecord>>(
      stream: queryCategoriesRecord(
        queryBuilder: (categoriesRecord) => categoriesRecord
            .where('proprietario', isEqualTo: currentUserReference)
            .orderBy('ordine_categoria'),
      ),
      builder: (context, catSnapshot) {
        final categorie = catSnapshot.data ?? [];
        final categorieMap = {
          for (final cat in categorie) cat.reference.path: cat.name,
        };

        return StreamBuilder<List<SottocategorieRecord>>(
          stream: querySottocategorieRecord(
            queryBuilder: (sottocategorieRecord) => sottocategorieRecord.where(
              'proprietario',
              isEqualTo: currentUserReference,
            ),
          ),
          builder: (context, sottoSnapshot) {
            final tutteSottocategorie = sottoSnapshot.data ?? [];

            // Filtro per categoria selezionata
            final sottocategorieFiltrate = _filtroCategoriaRef == null
                ? tutteSottocategorie
                : tutteSottocategorie
                    .where((s) => s.categoriaPadreRef == _filtroCategoriaRef)
                    .toList();

            return GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
                FocusManager.instance.primaryFocus?.unfocus();
              },
              child: Scaffold(
                key: scaffoldKey,
                backgroundColor: theme.scaffoldBackgroundColor,
                appBar: AppBar(
                  backgroundColor: theme.cardColor,
                  elevation: 0.0,
                  automaticallyImplyLeading: false,
                  leading: FlutterFlowIconButton(
                    borderColor: Colors.transparent,
                    borderRadius: 24.0,
                    borderWidth: 1.0,
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
                          Icons.account_tree_rounded,
                          color: colorScheme.primary,
                          size: 20.0,
                        ),
                      ),
                      const SizedBox(width: 10.0),
                      Text(
                        'Gestione sottocategorie',
                        style: theme.appBarTheme.titleTextStyle ??
                            theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0,
                              letterSpacing: -0.4,
                              color: colorScheme.onSurface,
                            ),
                      ),
                    ],
                  ),
                  centerTitle: true,
                  actions: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(6.0),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Icon(
                            Icons.add_rounded,
                            color: colorScheme.primary,
                            size: 20.0,
                          ),
                        ),
                        tooltip: 'Nuova sottocategoria',
                        onPressed: () => _mostraDialogCrea(context, categorie),
                      ),
                    ),
                  ],
                ),
                body: SafeArea(
                  top: true,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 860.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // ── Barra di filtro per categoria ───────────────────
                          if (categorie.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 12.0,
                                horizontal: 16.0,
                              ),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(right: 8.0),
                                      child: ChoiceChip(
                                        label: const Text('Tutte'),
                                        selected: _filtroCategoriaRef == null,
                                        onSelected: (selected) {
                                          if (selected) {
                                            setState(() {
                                              _filtroCategoriaRef = null;
                                            });
                                          }
                                        },
                                        selectedColor: colorScheme.primary,
                                        backgroundColor: theme.cardColor,
                                        labelStyle: TextStyle(
                                          color: _filtroCategoriaRef == null
                                              ? colorScheme.onPrimary
                                              : colorScheme.onSurface,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13.0,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20.0),
                                          side: BorderSide(
                                            color: _filtroCategoriaRef == null
                                                ? colorScheme.primary
                                                : theme.dividerColor
                                                    .withValues(alpha: 0.2),
                                          ),
                                        ),
                                      ),
                                    ),
                                    ...categorie.map((cat) {
                                      final isSelected =
                                          _filtroCategoriaRef == cat.reference;
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(right: 8.0),
                                        child: ChoiceChip(
                                          label: Text(cat.name),
                                          selected: isSelected,
                                          onSelected: (selected) {
                                            setState(() {
                                              _filtroCategoriaRef =
                                                  selected ? cat.reference : null;
                                            });
                                          },
                                          selectedColor: colorScheme.primary,
                                          backgroundColor: theme.cardColor,
                                          labelStyle: TextStyle(
                                            color: isSelected
                                                ? colorScheme.onPrimary
                                                : colorScheme.onSurface,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13.0,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20.0),
                                            side: BorderSide(
                                              color: isSelected
                                                  ? colorScheme.primary
                                                  : theme.dividerColor
                                                      .withValues(alpha: 0.2),
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                              ),
                            ),

                          // ── Info banner esplicativo ─────────────────────────
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 4.0,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline_rounded,
                                  size: 15.0,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 6.0),
                                Expanded(
                                  child: Text(
                                    'Organizza i piatti raggruppandoli per sottocategorie dentro le rispettive categorie.',
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8.0),

                          // ── Lista Sottocategorie ────────────────────────────
                          Expanded(
                            child: sottoSnapshot.connectionState ==
                                    ConnectionState.waiting
                                ? Center(
                                    child: SpinKitFadingCircle(
                                      color: colorScheme.primary,
                                      size: 40.0,
                                    ),
                                  )
                                : sottocategorieFiltrate.isEmpty
                                    ? Center(
                                        child: Padding(
                                          padding: const EdgeInsets.all(32.0),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                width: 70.0,
                                                height: 70.0,
                                                decoration: BoxDecoration(
                                                  color: colorScheme.primary
                                                      .withValues(alpha: 0.1),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Icon(
                                                  Icons.account_tree_outlined,
                                                  size: 34.0,
                                                  color: colorScheme.primary,
                                                ),
                                              ),
                                              const SizedBox(height: 16.0),
                                              Text(
                                                'Nessuna sottocategoria trovata',
                                                style: TextStyle(
                                                  fontSize: 16.0,
                                                  fontWeight: FontWeight.bold,
                                                  color: colorScheme.onSurface,
                                                ),
                                              ),
                                              const SizedBox(height: 6.0),
                                              Text(
                                                _filtroCategoriaRef != null
                                                    ? 'Non ci sono sottocategorie per questa categoria.'
                                                    : 'Non hai ancora creato alcuna sottocategoria nel menu.',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize: 13.5,
                                                  color: colorScheme
                                                      .onSurfaceVariant,
                                                ),
                                              ),
                                              const SizedBox(height: 20.0),
                                              ElevatedButton.icon(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      colorScheme.primary,
                                                  foregroundColor:
                                                      colorScheme.onPrimary,
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                    horizontal: 20.0,
                                                    vertical: 12.0,
                                                  ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0),
                                                  ),
                                                ),
                                                icon: const Icon(
                                                  Icons.add_rounded,
                                                  size: 18.0,
                                                ),
                                                label: const Text(
                                                    'Crea sottocategoria'),
                                                onPressed: () =>
                                                    _mostraDialogCrea(
                                                        context, categorie),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    : ListView.separated(
                                        controller: _model.scrollController,
                                        padding: const EdgeInsets.fromLTRB(
                                          16.0,
                                          8.0,
                                          16.0,
                                          24.0,
                                        ),
                                        itemCount:
                                            sottocategorieFiltrate.length,
                                        separatorBuilder: (_, __) =>
                                            const SizedBox(height: 10.0),
                                        itemBuilder: (context, index) {
                                          final sub =
                                              sottocategorieFiltrate[index];
                                          final catNome = categorieMap[sub
                                                  .categoriaPadreRef?.path] ??
                                              'Categoria non trovata';

                                          return Container(
                                            decoration: BoxDecoration(
                                              color: theme.cardColor,
                                              borderRadius:
                                                  BorderRadius.circular(14.0),
                                              border: Border.all(
                                                color: theme.dividerColor
                                                    .withValues(alpha: 0.12),
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withValues(alpha: 0.03),
                                                  blurRadius: 8.0,
                                                  offset:
                                                      const Offset(0.0, 2.0),
                                                ),
                                              ],
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 16.0,
                                                vertical: 12.0,
                                              ),
                                              child: Row(
                                                children: [
                                                  // Icona decorativa
                                                  Container(
                                                    width: 40.0,
                                                    height: 40.0,
                                                    decoration: BoxDecoration(
                                                      color: colorScheme.primary
                                                          .withValues(alpha: 0.1),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10.0),
                                                    ),
                                                    child: Center(
                                                      child: Icon(
                                                        Icons
                                                            .subdirectory_arrow_right_rounded,
                                                        color: colorScheme.primary,
                                                        size: 22.0,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 14.0),

                                                  // Nome e Categoria padre
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          sub.nome,
                                                          style: TextStyle(
                                                            fontSize: 15.5,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color: colorScheme
                                                                .onSurface,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            height: 3.0),
                                                        Row(
                                                          children: [
                                                            Text(
                                                              'Categoria: ',
                                                              style: TextStyle(
                                                                fontSize: 12.0,
                                                                color: colorScheme
                                                                    .onSurfaceVariant,
                                                              ),
                                                            ),
                                                            Container(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                horizontal: 7.0,
                                                                vertical: 2.0,
                                                              ),
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: colorScheme
                                                                    .surfaceContainerHighest,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            6.0),
                                                              ),
                                                              child: Text(
                                                                catNome,
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 11.5,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  color:
                                                                      colorScheme
                                                                          .onSurface,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),

                                                  // Pulsante Modifica
                                                  IconButton(
                                                    tooltip: 'Modifica',
                                                    icon: Icon(
                                                      Icons.edit_outlined,
                                                      color: colorScheme
                                                          .onSurfaceVariant,
                                                      size: 20.0,
                                                    ),
                                                    onPressed: () =>
                                                        _mostraDialogModifica(
                                                      context,
                                                      sub,
                                                      categorie,
                                                    ),
                                                  ),

                                                  // Pulsante Elimina
                                                  IconButton(
                                                    tooltip: 'Elimina',
                                                    icon: const Icon(
                                                      Icons
                                                          .delete_outline_rounded,
                                                      color: Colors.red,
                                                      size: 20.0,
                                                    ),
                                                    onPressed: () =>
                                                        _confermaEliminazione(
                                                      context,
                                                      sub,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
