import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import 'package:flutter/material.dart';

class GestioneSottocategorieModal extends StatefulWidget {
  const GestioneSottocategorieModal({
    super.key,
    required this.categoriaRef,
  });

  final DocumentReference categoriaRef;

  @override
  State<GestioneSottocategorieModal> createState() =>
      _GestioneSottocategorieModalState();
}

class _GestioneSottocategorieModalState
    extends State<GestioneSottocategorieModal> {
  final TextEditingController _creaController = TextEditingController();
  final FocusNode _creaFocusNode = FocusNode();
  bool _isCreating = false;

  @override
  void dispose() {
    _creaController.dispose();
    _creaFocusNode.dispose();
    super.dispose();
  }

  Future<void> _creaSottocategoria() async {
    final nome = _creaController.text.trim();
    if (nome.isEmpty) return;

    setState(() {
      _isCreating = true;
    });

    try {
      final docRef = SottocategorieRecord.collection.doc();
      await docRef.set(createSottocategorieRecordData(
        nome: nome,
        categoriaPadreRef: widget.categoriaRef,
        proprietario: currentUserReference,
      ));
      _creaController.clear();
      _creaFocusNode.unfocus();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore durante la creazione: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCreating = false;
        });
      }
    }
  }

  Future<void> _modificaSottocategoria(
      SottocategorieRecord sottocategoria) async {
    final textController =
        TextEditingController(text: sottocategoria.nome);
    final formKey = GlobalKey<FormState>();
    final theme = Theme.of(context);

    final confermato = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          backgroundColor: theme.cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          title: Text(
            'Modifica Sottocategoria',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: textController,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Nome Sottocategoria',
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: theme.dividerColor.withValues(alpha: 0.2),
                  ),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: theme.colorScheme.primary,
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              style: theme.textTheme.bodyMedium,
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Inserisci un nome valido';
                }
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx, false),
              child: const Text('Annulla'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  Navigator.pop(dialogCtx, true);
                }
              },
              child: const Text('Salva'),
            ),
          ],
        );
      },
    );

    if (confermato == true) {
      final nuovoNome = textController.text.trim();
      if (nuovoNome.isNotEmpty && nuovoNome != sottocategoria.nome) {
        await sottocategoria.reference.update(
          createSottocategorieRecordData(nome: nuovoNome),
        );
      }
    }
  }

  Future<void> _eliminaSottocategoria(
      SottocategorieRecord sottocategoria) async {
    final theme = Theme.of(context);

    final confermato = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          backgroundColor: theme.cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          title: Text(
            'Elimina Sottocategoria',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.error,
            ),
          ),
          content: Text(
            'Sei sicuro di voler eliminare "${sottocategoria.nome}"?\n\nI piatti associati NON verranno cancellati, ma rimarranno semplicemente senza sottocategoria.',
            style: theme.textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx, false),
              child: const Text('Annulla'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
                foregroundColor: theme.colorScheme.onError,
              ),
              onPressed: () => Navigator.pop(dialogCtx, true),
              child: const Text('Sì, elimina'),
            ),
          ],
        );
      },
    );

    if (confermato == true) {
      try {
        final snapshotPiatti = await queryPiattiRecordOnce(
          queryBuilder: (query) => query.where(
            'sottocategoria_ref',
            isEqualTo: sottocategoria.reference,
          ),
        );

        final batch = FirebaseFirestore.instance.batch();
        for (final piatto in snapshotPiatti) {
          batch.update(piatto.reference, {
            'sottocategoria_ref': FieldValue.delete(),
          });
        }
        await batch.commit();

        await sottocategoria.reference.delete();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Sottocategoria "${sottocategoria.nome}" eliminata. I piatti associati rimangono disponibili.',
              ),
              backgroundColor: const Color(0xFF16A34A),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Errore durante l\'eliminazione: $e'),
              backgroundColor: theme.colorScheme.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.75,
      ),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24.0),
          topRight: Radius.circular(24.0),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Barra trascinamento superiore
              Center(
                child: Container(
                  width: 40.0,
                  height: 4.0,
                  margin: const EdgeInsets.only(bottom: 16.0),
                  decoration: BoxDecoration(
                    color: theme.dividerColor.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),

              // Titolo e chiudi
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36.0,
                        height: 36.0,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Icon(
                          Icons.folder_special_rounded,
                          color: theme.colorScheme.primary,
                          size: 20.0,
                        ),
                      ),
                      const SizedBox(width: 10.0),
                      Text(
                        'Sottocategorie',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.close_rounded,
                      size: 22.0,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12.0),

              // Campo creazione nuova sottocategoria
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _creaController,
                      focusNode: _creaFocusNode,
                      decoration: InputDecoration(
                        hintText: 'Nuova sottocategoria (es. Pizze Bianche)...',
                        hintStyle: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.hintColor,
                          fontSize: 13.0,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14.0, vertical: 10.0),
                        filled: true,
                        fillColor: theme.scaffoldBackgroundColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide(
                            color: theme.dividerColor.withValues(alpha: 0.15),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide(
                            color: theme.dividerColor.withValues(alpha: 0.15),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide(
                            color: theme.colorScheme.primary,
                            width: 1.5,
                          ),
                        ),
                      ),
                      style: theme.textTheme.bodyMedium?.copyWith(fontSize: 13.5),
                      onFieldSubmitted: (_) => _creaSottocategoria(),
                    ),
                  ),
                  const SizedBox(width: 10.0),
                  ElevatedButton(
                    onPressed: _isCreating ? null : _creaSottocategoria,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 12.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    child: _isCreating
                        ? const SizedBox(
                            width: 16.0,
                            height: 16.0,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.0,
                            ),
                          )
                        : const Icon(
                            Icons.add,
                            size: 20.0,
                          ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),

              // Lista Sottocategorie con StreamBuilder
              Flexible(
                child: StreamBuilder<List<SottocategorieRecord>>(
                  stream: querySottocategorieRecord(
                    queryBuilder: (query) => query
                        .where(
                          'categoria_padre_ref',
                          isEqualTo: widget.categoriaRef,
                        )
                        .where(
                          'proprietario',
                          isEqualTo: currentUserReference,
                        ),
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState ==
                            ConnectionState.waiting &&
                        !snapshot.hasData) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24.0),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    final sottocategorie = snapshot.data ?? [];

                    if (sottocategorie.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(24.0),
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.folder_open_rounded,
                              size: 40.0,
                              color: theme.dividerColor.withValues(alpha: 0.5),
                            ),
                            const SizedBox(height: 10.0),
                            Text(
                              'Nessuna sottocategoria presente',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.textTheme.bodySmall?.color,
                              ),
                            ),
                            const SizedBox(height: 4.0),
                            Text(
                              'Aggiungine una digitando sopra e premendo +',
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.separated(
                      shrinkWrap: true,
                      itemCount: sottocategorie.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 8.0),
                      itemBuilder: (context, index) {
                        final item = sottocategorie[index];
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14.0, vertical: 10.0),
                          decoration: BoxDecoration(
                            color: theme.scaffoldBackgroundColor,
                            borderRadius: BorderRadius.circular(12.0),
                            border: Border.all(
                              color: theme.dividerColor.withValues(alpha: 0.15),
                              width: 1.0,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.subdirectory_arrow_right_rounded,
                                size: 18.0,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 10.0),
                              Expanded(
                                child: Text(
                                  item.nome,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              // Modifica
                              IconButton(
                                icon: const Icon(
                                  Icons.edit_outlined,
                                  size: 18.0,
                                ),
                                tooltip: 'Modifica nome',
                                onPressed: () =>
                                    _modificaSottocategoria(item),
                              ),
                              // Elimina
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline_rounded,
                                  size: 18.0,
                                ),
                                color: theme.colorScheme.error,
                                tooltip: 'Elimina sottocategoria',
                                onPressed: () =>
                                    _eliminaSottocategoria(item),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
