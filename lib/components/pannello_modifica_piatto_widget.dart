import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/backend/schema/util/allergeni_data.dart';
import '/components/crea_sottocategoria_widget.dart';
import '/components/popup_foto_piatto_widget.dart';
import '/flutter_flow/custom_functions.dart' as functions;
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/services/translation_service.dart';
import '/services/audit_log_service.dart';
import '/components/ingredienti_dispensa_field.dart';

class PannelloModificaPiattoWidget extends StatefulWidget {
  const PannelloModificaPiattoWidget({
    super.key,
    required this.piatto,
    required this.categoriaRef,
    this.ristoranteRef,
    required this.onClose,
    this.onSaved,
  });

  final PiattiRecord piatto;
  final DocumentReference categoriaRef;
  final DocumentReference? ristoranteRef;
  final VoidCallback onClose;
  final ValueChanged<PiattiRecord>? onSaved;

  @override
  State<PannelloModificaPiattoWidget> createState() =>
      _PannelloModificaPiattoWidgetState();
}

class _PannelloModificaPiattoWidgetState
    extends State<PannelloModificaPiattoWidget> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nomePiattoController;
  late TextEditingController _prezzoController;
  late TextEditingController _ingredientiController;
  late TextEditingController _descrizioneController;

  late FocusNode _nomeFocusNode;
  late FocusNode _prezzoFocusNode;
  late FocusNode _ingredientiFocusNode;
  late FocusNode _descrizioneFocusNode;

  FormFieldController<String>? _categoriaController;
  String? _selezionataCategoria;
  FormFieldController<String>? _sottocategoriaController;
  String? _selezionataSottocategoria;
  List<String> _intolleranzeSelezionate = [];
  List<String> _allergeniSelezionati = [];
  String _fotoInMemoria = '';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nomePiattoController = TextEditingController();
    _prezzoController = TextEditingController();
    _ingredientiController = TextEditingController();
    _descrizioneController = TextEditingController();

    _nomeFocusNode = FocusNode();
    _prezzoFocusNode = FocusNode();
    _ingredientiFocusNode = FocusNode();
    _descrizioneFocusNode = FocusNode();

    _popolaDati(widget.piatto);
  }

  @override
  void didUpdateWidget(covariant PannelloModificaPiattoWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.piatto.reference.id != widget.piatto.reference.id) {
      _popolaDati(widget.piatto);
    }
  }

  void _popolaDati(PiattiRecord piatto) {
    _nomePiattoController.text = piatto.nome;
    _prezzoController.text =
        piatto.prezzo > 0 ? piatto.prezzo.toStringAsFixed(2) : '';
    _ingredientiController.text = piatto.ingredienti;
    _descrizioneController.text = piatto.descrizione;
    _fotoInMemoria = piatto.foto;
    FFAppState().fotoInMemoria = piatto.foto;
    _selezionataCategoria = piatto.categoria.isNotEmpty
        ? piatto.categoria
        : widget.categoriaRef.id;
    _categoriaController =
        FormFieldController<String>(_selezionataCategoria);
    _selezionataSottocategoria = piatto.sottocategoriaRef?.id;
    _sottocategoriaController =
        FormFieldController<String>(_selezionataSottocategoria);
    _intolleranzeSelezionate = List<String>.from(piatto.intolleranze);
    _allergeniSelezionati = List<String>.from(piatto.allergeni);
    _isSaving = false;
  }

  @override
  void dispose() {
    _nomePiattoController.dispose();
    _prezzoController.dispose();
    _ingredientiController.dispose();
    _descrizioneController.dispose();
    _nomeFocusNode.dispose();
    _prezzoFocusNode.dispose();
    _ingredientiFocusNode.dispose();
    _descrizioneFocusNode.dispose();
    super.dispose();
  }

  Future<void> _salva() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final nuovaFoto = _fotoInMemoria.trim();

      // Elimina vecchia foto da Firebase Storage se cambiata o rimossa
      if (widget.piatto.foto.isNotEmpty &&
          nuovaFoto != widget.piatto.foto) {
        try {
          await FirebaseStorage.instance
              .refFromURL(widget.piatto.foto)
              .delete();
        } catch (_) {}
      }

      DocumentReference? sottocategoriaRefFinale;
      if (_selezionataSottocategoria != null &&
          _selezionataSottocategoria!.isNotEmpty) {
        sottocategoriaRefFinale = SottocategorieRecord.collection
            .doc(_selezionataSottocategoria);
      }

      final nuovaCategoriaId =
          _selezionataCategoria ?? widget.categoriaRef.id;
      final categoriaCambiata = nuovaCategoriaId != widget.categoriaRef.id;

      final descText = _descrizioneController.text.trim();
      final ingrText = _ingredientiController.text.trim();

      await widget.piatto.reference.update(createPiattiRecordData(
        nome: _nomePiattoController.text.trim(),
        prezzo: functions.formattaPrezzo(_prezzoController.text.trim()),
        categoria: nuovaCategoriaId,
        proprietario: widget.ristoranteRef,
        ingredienti: _ingredientiController.text.trim(),
        descrizione: _descrizioneController.text.trim(),
        foto: nuovaFoto,
        sottocategoriaRef: sottocategoriaRefFinale,
        allergeni: _allergeniSelezionati,
        intolleranze: _intolleranzeSelezionate,
      ));

      final piattoNomeSalvato = _nomePiattoController.text.trim();
      await AuditLogService.logAction(
        ristoranteRef: widget.ristoranteRef,
        azione: "Ha modificato il piatto '$piattoNomeSalvato'",
        dettagli: "Modificato piatto '$piattoNomeSalvato' (Prezzo: ${_prezzoController.text.trim()}€)",
        tipoAzione: 'modifica',
        tipoEntita: 'piatto',
      );

      // Aggiorna le traduzioni in background (descrizione e ingredienti, NO nome)
      if (descText.isNotEmpty || ingrText.isNotEmpty) {
        final piattoRef = widget.piatto.reference;
        TranslationService.generateDishTranslations(
          descrizione: descText,
          ingredienti: ingrText,
        ).then((traduzioni) {
          piattoRef.update({'traduzioni': traduzioni});
        }).catchError((e) {
          debugPrint('Errore aggiornamento traduzioni: $e');
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded,
                    color: Colors.white, size: 20.0),
                const SizedBox(width: 8.0),
                Text(categoriaCambiata
                    ? 'Piatto spostato nella nuova categoria e aggiornato!'
                    : '"${_nomePiattoController.text.trim()}" aggiornato con successo!'),
              ],
            ),
            backgroundColor: const Color(0xFF16A34A),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }

      if (categoriaCambiata) {
        widget.onClose();
      } else {
        final aggiornatoSnapshot = await widget.piatto.reference.get();
        if (aggiornatoSnapshot.exists && mounted) {
          final recordAggiornato = PiattiRecord.fromSnapshot(aggiornatoSnapshot);
          widget.onSaved?.call(recordAggiornato);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Errore durante il salvataggio: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();
    final theme = Theme.of(context);
    final currentFoto = _fotoInMemoria;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.35),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16.0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 14.0),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: theme.dividerColor.withValues(alpha: 0.2),
                  width: 1.0,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Icon(
                    Icons.edit_note_rounded,
                    color: theme.colorScheme.primary,
                    size: 22.0,
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Modifica piatto',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        widget.piatto.nome.isNotEmpty
                            ? widget.piatto.nome
                            : 'Nuovo piatto',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color
                              ?.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Tooltip(
                  message: 'Chiudi pannello',
                  child: IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      color: theme.iconTheme.color?.withValues(alpha: 0.7),
                      size: 22.0,
                    ),
                    onPressed: widget.onClose,
                  ),
                ),
              ],
            ),
          ),

          // Scrollable Form
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Immagine piatto
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12.0),
                          child: InkWell(
                            onTap: () async {
                              await showModalBottomSheet(
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                enableDrag: false,
                                context: context,
                                builder: (context) {
                                  return GestureDetector(
                                    onTap: () {
                                      FocusScope.of(context).unfocus();
                                      FocusManager.instance.primaryFocus
                                          ?.unfocus();
                                    },
                                    child: Padding(
                                      padding:
                                          MediaQuery.viewInsetsOf(context),
                                      child: const PopupFotoPiattoWidget(),
                                    ),
                                  );
                                },
                              );
                              setState(() {
                                _fotoInMemoria = FFAppState().fotoInMemoria;
                              });
                            },
                            child: SizedBox(
                              width: 100.0,
                              height: 100.0,
                              child: currentFoto.isNotEmpty
                                  ? Image.network(
                                      currentFoto,
                                      width: 100.0,
                                      height: 100.0,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) =>
                                          Container(
                                        width: 100.0,
                                        height: 100.0,
                                        color: theme.dividerColor.withValues(alpha: 0.1),
                                        alignment: Alignment.center,
                                        child: Icon(
                                          Icons.restaurant_outlined,
                                          color: theme.iconTheme.color
                                                  ?.withValues(alpha: 0.5) ??
                                              theme.hintColor,
                                          size: 32.0,
                                        ),
                                      ),
                                    )
                                  : Container(
                                      width: 100.0,
                                      height: 100.0,
                                      color: theme.dividerColor.withValues(alpha: 0.08),
                                      alignment: Alignment.center,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.add_a_photo_outlined,
                                            color: theme.iconTheme.color
                                                    ?.withValues(alpha: 0.45) ??
                                                theme.hintColor,
                                            size: 28.0,
                                          ),
                                          const SizedBox(height: 4.0),
                                          Text(
                                            'Nessuna foto',
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                              fontSize: 10.0,
                                              color: theme.hintColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Foto del piatto',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8.0),
                              Wrap(
                                spacing: 8.0,
                                runSpacing: 8.0,
                                children: [
                                  OutlinedButton.icon(
                                    onPressed: () async {
                                      await showModalBottomSheet(
                                        isScrollControlled: true,
                                        backgroundColor: Colors.transparent,
                                        enableDrag: false,
                                        context: context,
                                        builder: (context) {
                                          return GestureDetector(
                                            onTap: () {
                                              FocusScope.of(context).unfocus();
                                              FocusManager.instance.primaryFocus
                                                  ?.unfocus();
                                            },
                                            child: Padding(
                                              padding: MediaQuery.viewInsetsOf(
                                                  context),
                                              child:
                                                  const PopupFotoPiattoWidget(),
                                            ),
                                          );
                                        },
                                      );
                                      setState(() {
                                        _fotoInMemoria =
                                            FFAppState().fotoInMemoria;
                                      });
                                    },
                                    icon: Icon(
                                      currentFoto.isNotEmpty
                                          ? Icons.photo_camera_rounded
                                          : Icons.add_photo_alternate_rounded,
                                      size: 16.0,
                                    ),
                                    label: Text(currentFoto.isNotEmpty
                                        ? 'Cambia foto'
                                        : 'Aggiungi foto'),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12.0, vertical: 8.0),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                    ),
                                  ),
                                  if (currentFoto.isNotEmpty)
                                    OutlinedButton.icon(
                                      onPressed: () async {
                                        final fotoDaRimuovere = _fotoInMemoria;
                                        setState(() {
                                          _fotoInMemoria = '';
                                          FFAppState().fotoInMemoria = '';
                                        });
                                        if (fotoDaRimuovere.isNotEmpty &&
                                            fotoDaRimuovere !=
                                                widget.piatto.foto) {
                                          try {
                                            await FirebaseStorage.instance
                                                .refFromURL(fotoDaRimuovere)
                                                .delete();
                                          } catch (_) {}
                                        }
                                      },
                                      icon: Icon(
                                        Icons.delete_outline_rounded,
                                        size: 16.0,
                                        color: theme.colorScheme.error,
                                      ),
                                      label: Text(
                                        'Elimina foto',
                                        style: TextStyle(
                                          color: theme.colorScheme.error,
                                        ),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor:
                                            theme.colorScheme.error,
                                        side: BorderSide(
                                          color: theme.colorScheme.error
                                              .withValues(alpha: 0.4),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12.0, vertical: 8.0),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
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

                    const SizedBox(height: 18.0),

                    // Nome Piatto & Prezzo in un Row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: TextFormField(
                            controller: _nomePiattoController,
                            focusNode: _nomeFocusNode,
                            decoration: InputDecoration(
                              isDense: true,
                              labelText: 'Nome Piatto *',
                              hintText: 'Es. Margherita',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: theme.dividerColor,
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: theme.colorScheme.primary,
                                  width: 1.5,
                                ),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Inserisci il nome del piatto';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12.0),
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: _prezzoController,
                            focusNode: _prezzoFocusNode,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            decoration: InputDecoration(
                              isDense: true,
                              labelText: 'Prezzo (€)',
                              prefixText: '€ ',
                              hintText: '0.00',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: theme.dividerColor,
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: theme.colorScheme.primary,
                                  width: 1.5,
                                ),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16.0),

                    // Categoria
                    StreamBuilder<List<CategoriesRecord>>(
                      stream: queryCategoriesRecord(
                        queryBuilder: (record) => record.where(
                          'proprietario',
                          isEqualTo: currentUserReference,
                        ),
                      ),
                      builder: (context, catSnapshot) {
                        final categorie = catSnapshot.data ?? [];
                        final opzioni =
                            categorie.map((e) => e.reference.id).toList();
                        final etichette =
                            categorie.map((e) => e.name).toList();

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Categoria *',
                              style: theme.textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6.0),
                            FlutterFlowDropDown<String>(
                              controller: _categoriaController ??=
                                  FormFieldController<String>(
                                      _selezionataCategoria),
                              options: opzioni,
                              optionLabels: etichette,
                              onChanged: (val) {
                                setState(() {
                                  _selezionataCategoria = val;
                                  _selezionataSottocategoria = null;
                                  _sottocategoriaController?.value = null;
                                });
                              },
                              width: double.infinity,
                              height: 44.0,
                              textStyle: theme.textTheme.bodyMedium ??
                                  const TextStyle(),
                              hintText: 'Seleziona categoria',
                              icon: Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: theme.hintColor,
                                size: 22.0,
                              ),
                              fillColor: theme.cardColor,
                              elevation: 2.0,
                              borderColor: theme.dividerColor,
                              borderWidth: 1.0,
                              borderRadius: 10.0,
                              margin: const EdgeInsetsDirectional.fromSTEB(
                                  12.0, 0.0, 12.0, 0.0),
                              hidesUnderline: true,
                            ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 16.0),

                    // Sottocategoria
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sottocategoria (opzionale)',
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6.0),
                        StreamBuilder<List<SottocategorieRecord>>(
                          stream: querySottocategorieRecord(
                            queryBuilder: (record) => record.where(
                              Filter.or(
                                Filter(
                                  'categoria_padre_ref',
                                  isEqualTo: FirebaseFirestore.instance
                                      .collection('categories')
                                      .doc(_selezionataCategoria ??
                                          widget.categoriaRef.id),
                                ),
                                Filter(
                                  'proprietario',
                                  isEqualTo: currentUserReference,
                                ),
                              ),
                            ),
                          ),
                          builder: (context, snapshot) {
                            final sottocategorie = snapshot.data ?? [];
                            return Row(
                              children: [
                                Expanded(
                                  child: FlutterFlowDropDown<String>(
                                    controller: _sottocategoriaController ??=
                                        FormFieldController<String>(
                                            _selezionataSottocategoria),
                                    options: sottocategorie
                                        .map((e) => e.reference.id)
                                        .toList(),
                                    optionLabels: sottocategorie
                                        .map((e) => e.nome)
                                        .toList(),
                                    onChanged: (val) {
                                      setState(() {
                                        _selezionataSottocategoria = val;
                                      });
                                    },
                                    height: 44.0,
                                    textStyle: theme.textTheme.bodyMedium ??
                                        const TextStyle(),
                                    hintText: 'Nessuna sottocategoria',
                                    icon: Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      color: theme.hintColor,
                                      size: 22.0,
                                    ),
                                    fillColor: theme.cardColor,
                                    elevation: 2.0,
                                    borderColor: theme.dividerColor,
                                    borderWidth: 1.0,
                                    borderRadius: 10.0,
                                    margin: const EdgeInsetsDirectional.fromSTEB(
                                        12.0, 0.0, 12.0, 0.0),
                                    hidesUnderline: true,
                                  ),
                                ),
                                const SizedBox(width: 8.0),
                                Tooltip(
                                  message: 'Crea nuova sottocategoria',
                                  child: IconButton(
                                    style: IconButton.styleFrom(
                                      backgroundColor: theme.colorScheme.primary
                                          .withValues(alpha: 0.12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                    ),
                                    icon: Icon(
                                      Icons.add_rounded,
                                      color: theme.colorScheme.primary,
                                    ),
                                    onPressed: () async {
                                      final currentCatRef = FirebaseFirestore
                                          .instance
                                          .collection('categories')
                                          .doc(_selezionataCategoria ??
                                              widget.categoriaRef.id);
                                      final res = await showModalBottomSheet(
                                        isScrollControlled: true,
                                        backgroundColor: Colors.transparent,
                                        enableDrag: false,
                                        context: context,
                                        builder: (context) {
                                          return GestureDetector(
                                            onTap: () {
                                              FocusScope.of(context).unfocus();
                                              FocusManager.instance.primaryFocus
                                                  ?.unfocus();
                                            },
                                            child: Padding(
                                              padding: MediaQuery.viewInsetsOf(
                                                  context),
                                              child: SizedBox(
                                                height:
                                                    MediaQuery.sizeOf(context)
                                                            .height *
                                                        0.22,
                                                child:
                                                    CreaSottocategoriaWidget(
                                                  categoriaRicevuta:
                                                      currentCatRef,
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                      if (res != null &&
                                          res is DocumentReference) {
                                        setState(() {
                                          _selezionataSottocategoria = res.id;
                                          _sottocategoriaController?.value =
                                              res.id;
                                        });
                                      }
                                    },
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 16.0),

                    // Ingredienti
                    IngredientiDispensaField(
                      controller: _ingredientiController,
                      focusNode: _ingredientiFocusNode,
                      ristoranteRef: widget.ristoranteRef,
                      dispensaAttiva: valueOrDefault<bool>(
                          currentUserDocument?.dispensaAttiva, false),
                      labelText: 'Ingredienti',
                      hintText: 'Cerca in dispensa o digita...',
                    ),

                    const SizedBox(height: 16.0),

                    // Descrizione
                    TextFormField(
                      controller: _descrizioneController,
                      focusNode: _descrizioneFocusNode,
                      maxLines: 3,
                      decoration: InputDecoration(
                        isDense: true,
                        labelText: 'Descrizione (opzionale)',
                        hintText: 'Note o dettagli sul piatto...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: theme.dividerColor,
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: theme.colorScheme.primary,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),

                    const SizedBox(height: 18.0),

                    // Filtri Magici Intolleranze
                    Container(
                      padding: const EdgeInsets.all(14.0),
                      decoration: BoxDecoration(
                        color: theme.scaffoldBackgroundColor
                            .withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(
                          color: theme.dividerColor.withValues(alpha: 0.25),
                          width: 1.0,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.auto_awesome,
                                  color: Colors.amber, size: 18.0),
                              const SizedBox(width: 8.0),
                              Text(
                                'Filtri Magici Intolleranze',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13.5,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4.0),
                          Text(
                            'Seleziona le intolleranze o regimi alimentari supportati:',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.hintColor,
                              fontSize: 11.5,
                            ),
                          ),
                          const SizedBox(height: 10.0),
                          Wrap(
                            spacing: 8.0,
                            runSpacing: 8.0,
                            children: AllergeniData.filtriMagici.map((filtro) {
                              final isSelected = _intolleranzeSelezionate
                                  .contains(filtro.id);
                              return FilterChip(
                                label: Text(
                                  '${filtro.emoji}  ${filtro.label}',
                                  style: TextStyle(
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: isSelected
                                        ? Colors.white
                                        : theme.textTheme.bodyMedium?.color,
                                    fontSize: 12.5,
                                  ),
                                ),
                                selected: isSelected,
                                selectedColor: filtro.badgeColor,
                                backgroundColor: theme.cardColor,
                                checkmarkColor: Colors.white,
                                side: BorderSide(
                                  color: isSelected
                                      ? filtro.badgeColor
                                      : theme.dividerColor,
                                  width: 1.0,
                                ),
                                onSelected: (selected) {
                                  setState(() {
                                    if (selected) {
                                      _intolleranzeSelezionate.add(filtro.id);
                                    } else {
                                      _intolleranzeSelezionate
                                          .remove(filtro.id);
                                    }
                                  });
                                },
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16.0),

                    // Allergeni Obbligatori (14)
                    Container(
                      padding: const EdgeInsets.all(14.0),
                      decoration: BoxDecoration(
                        color: theme.scaffoldBackgroundColor
                            .withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(
                          color: theme.dividerColor.withValues(alpha: 0.25),
                          width: 1.0,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.warning_amber_rounded,
                                  color: theme.colorScheme.primary, size: 18.0),
                              const SizedBox(width: 8.0),
                              Text(
                                'Allergeni Presenti (14 Obbligatori)',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13.5,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4.0),
                          Text(
                            'Seleziona gli allergeni contenuti negli ingredienti di questo piatto:',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.hintColor,
                              fontSize: 11.5,
                            ),
                          ),
                          const SizedBox(height: 10.0),
                          Wrap(
                            spacing: 8.0,
                            runSpacing: 8.0,
                            children: AllergeniData.allergeniObbligatori
                                .map((allergene) {
                              final isSelected =
                                  _allergeniSelezionati.contains(allergene.id);
                              return FilterChip(
                                label: Text(
                                  '${allergene.emoji}  ${allergene.label}',
                                  style: TextStyle(
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: isSelected
                                        ? Colors.white
                                        : theme.textTheme.bodyMedium?.color,
                                    fontSize: 12.0,
                                  ),
                                ),
                                selected: isSelected,
                                selectedColor: const Color(0xFFD97706),
                                backgroundColor: theme.cardColor,
                                checkmarkColor: Colors.white,
                                side: BorderSide(
                                  color: isSelected
                                      ? const Color(0xFFD97706)
                                      : theme.dividerColor,
                                  width: 1.0,
                                ),
                                onSelected: (selected) {
                                  setState(() {
                                    if (selected) {
                                      _allergeniSelezionati.add(allergene.id);
                                    } else {
                                      _allergeniSelezionati
                                          .remove(allergene.id);
                                    }
                                  });
                                },
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24.0),

                    // Azioni (Salva & Annulla)
                    Wrap(
                      alignment: WrapAlignment.end,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 12.0,
                      runSpacing: 10.0,
                      children: [
                        OutlinedButton(
                          onPressed: _isSaving ? null : widget.onClose,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18.0, vertical: 12.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          child: const Text('Annulla'),
                        ),
                        ElevatedButton.icon(
                          onPressed: _isSaving ? null : _salva,
                          icon: _isSaving
                              ? const SizedBox(
                                  width: 16.0,
                                  height: 16.0,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.0,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.check_rounded, size: 18.0),
                          label: Text(_isSaving ? 'Salvataggio...' : 'Salva modifiche'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20.0, vertical: 12.0),
                            elevation: 2.0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
