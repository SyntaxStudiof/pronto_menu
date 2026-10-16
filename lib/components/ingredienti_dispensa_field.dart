import 'package:collection/collection.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';

class IngredientiDispensaField extends StatefulWidget {
  const IngredientiDispensaField({
    super.key,
    required this.controller,
    this.focusNode,
    this.ristoranteRef,
    this.dispensaAttiva = false,
    this.labelText = 'Ingredienti',
    this.hintText = 'Inizia a digitare un ingrediente...',
    this.validator,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final DocumentReference? ristoranteRef;
  final bool dispensaAttiva;
  final String labelText;
  final String hintText;
  final FormFieldValidator<String>? validator;

  @override
  State<IngredientiDispensaField> createState() =>
      _IngredientiDispensaFieldState();
}

class _IngredientiDispensaFieldState extends State<IngredientiDispensaField> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  List<DispensaRecord> _dispensaItems = [];
  bool _modalitaManuale = false;

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(() {
      if (_searchFocusNode.hasFocus) {
        _mostraOverlay();
      } else {
        _rimuoviOverlay();
      }
    });

    _searchController.addListener(() {
      if (_searchFocusNode.hasFocus) {
        _overlayEntry?.markNeedsBuild();
      }
    });

    widget.controller.addListener(_onControllerChange);
  }

  void _onControllerChange() {
    if (mounted) safeSetState(() {});
  }

  @override
  void dispose() {
    _rimuoviOverlay();
    _searchController.dispose();
    _searchFocusNode.dispose();
    widget.controller.removeListener(_onControllerChange);
    super.dispose();
  }

  List<String> get _selectedIngredienti {
    final text = widget.controller.text.trim();
    if (text.isEmpty) return [];
    return text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  void _aggiungiIngrediente(String nome) {
    final pulito = nome.trim();
    if (pulito.isEmpty) return;
    final current = _selectedIngredienti;
    // Evita duplicati identici esatti
    if (!current.any((i) => i.toLowerCase() == pulito.toLowerCase())) {
      current.add(pulito);
      widget.controller.text = current.join(', ');
    }
    _searchController.clear();
    _rimuoviOverlay();
    _searchFocusNode.requestFocus();
  }

  void _rimuoviIngrediente(int index) {
    final current = _selectedIngredienti;
    if (index >= 0 && index < current.length) {
      current.removeAt(index);
      widget.controller.text = current.join(', ');
    }
  }

  void _mostraOverlay() {
    _rimuoviOverlay();
    final overlay = Overlay.of(context);
    _overlayEntry = _creaOverlayEntry();
    overlay.insert(_overlayEntry!);
  }

  void _rimuoviOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  OverlayEntry _creaOverlayEntry() {
    final renderBox = context.findRenderObject() as RenderBox?;
    final size = renderBox?.size ?? Size.zero;

    return OverlayEntry(
      builder: (ctx) {
        final query = _searchController.text.trim().toLowerCase();
        final suggerimenti = _dispensaItems.where((d) {
          final nomeLower = d.nome.toLowerCase();
          // Non suggerire se già selezionato
          final giaSelezionato =
              _selectedIngredienti.any((s) => s.toLowerCase() == nomeLower);
          if (giaSelezionato) return false;
          if (query.isEmpty) return true;
          return nomeLower.contains(query);
        }).toList();

        final esisteEsatto = _dispensaItems
            .any((d) => d.nome.trim().toLowerCase() == query.toLowerCase());

        final theme = Theme.of(context);

        return Positioned(
          width: size.width > 200 ? size.width : 320.0,
          child: CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            offset: const Offset(0.0, 48.0),
            child: Material(
              elevation: 8.0,
              borderRadius: BorderRadius.circular(14.0),
              color: theme.cardColor,
              shadowColor: Colors.black.withValues(alpha: 0.25),
              child: Container(
                constraints: const BoxConstraints(maxHeight: 220.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14.0),
                  border: Border.all(
                    color: theme.dividerColor.withValues(alpha: 0.2),
                  ),
                ),
                child: ListView(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  children: [
                    // Opzione per aggiungere il testo libero inserito se non vuoto e non già in dispensa
                    if (query.isNotEmpty && !esisteEsatto)
                      ListTile(
                        dense: true,
                        leading: Container(
                          padding: const EdgeInsets.all(6.0),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary
                                .withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.add_rounded,
                              size: 16.0, color: theme.colorScheme.primary),
                        ),
                        title: RichText(
                          text: TextSpan(
                            style: theme.textTheme.bodyMedium,
                            children: [
                              const TextSpan(text: 'Usa: "'),
                              TextSpan(
                                text: _searchController.text.trim(),
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const TextSpan(text: '"'),
                            ],
                          ),
                        ),
                        onTap: () {
                          _aggiungiIngrediente(_searchController.text.trim());
                        },
                      ),

                    // Lista dei suggerimenti dalla dispensa
                    if (suggerimenti.isNotEmpty)
                      ...suggerimenti.map((d) {
                        final isEsaurito = d.esaurito;
                        final isCritico = d.staPerFinire && !isEsaurito;

                        return ListTile(
                          dense: true,
                          leading: Icon(
                            isEsaurito
                                ? Icons.block_rounded
                                : isCritico
                                    ? Icons.warning_amber_rounded
                                    : Icons.kitchen_rounded,
                            size: 18.0,
                            color: isEsaurito
                                ? const Color(0xFFEF4444)
                                : isCritico
                                    ? const Color(0xFFF59E0B)
                                    : theme.colorScheme.primary,
                          ),
                          title: Text(
                            d.nome,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              decoration:
                                  isEsaurito ? TextDecoration.lineThrough : null,
                              color: isEsaurito ? theme.hintColor : null,
                            ),
                          ),
                          trailing: isEsaurito
                              ? Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6.0, vertical: 2.0),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEF4444)
                                        .withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(6.0),
                                  ),
                                  child: const Text(
                                    'Esaurito',
                                    style: TextStyle(
                                      color: Color(0xFFDC2626),
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                              : d.quantita > 0
                                  ? Text(
                                      '${d.quantita % 1 == 0 ? d.quantita.toInt() : d.quantita} ${d.unitaMisura}',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: theme.hintColor,
                                        fontSize: 11.0,
                                      ),
                                    )
                                  : null,
                          onTap: () {
                            _aggiungiIngrediente(d.nome);
                          },
                        );
                      }),

                    if (suggerimenti.isEmpty && (query.isEmpty || esisteEsatto))
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(
                          query.isEmpty
                              ? 'Tutti gli ingredienti della dispensa sono già stati inseriti.'
                              : 'Nessun altro ingrediente corrispondente.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: theme.hintColor),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Se la dispensa NON è attiva oppure l'utente ha scelto la modalità manuale testo:
    if (!widget.dispensaAttiva || _modalitaManuale) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: widget.controller,
            focusNode: widget.focusNode,
            autofocus: false,
            decoration: InputDecoration(
              isDense: true,
              labelText: widget.labelText,
              hintText: 'Es. Pomodoro, Mozzarella, Basilico',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              suffixIcon: widget.dispensaAttiva
                  ? IconButton(
                      tooltip: 'Torna ai suggerimenti dalla dispensa',
                      icon: Icon(Icons.auto_awesome_rounded,
                          color: colorScheme.primary, size: 20.0),
                      onPressed: () {
                        setState(() => _modalitaManuale = false);
                      },
                    )
                  : null,
            ),
            style: theme.textTheme.bodyMedium,
            validator: widget.validator,
          ),
          if (widget.dispensaAttiva)
            Padding(
              padding: const EdgeInsets.only(top: 4.0, left: 4.0),
              child: InkWell(
                onTap: () => setState(() => _modalitaManuale = false),
                child: Text(
                  '💡 Passa alla selezione guidata dalla dispensa',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.primary,
                    fontSize: 11.5,
                  ),
                ),
              ),
            ),
        ],
      );
    }

    // Modalità DISPENSA ATTIVA: Autocomplete + Chips
    final targetRef = widget.ristoranteRef ?? currentUserReference;

    return StreamBuilder<List<DispensaRecord>>(
      stream: queryDispensaRecord(
        queryBuilder: (q) => q.where('proprietario', isEqualTo: targetRef),
      ),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          _dispensaItems = snapshot.data!;
        }

        final selezionati = _selectedIngredienti;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header etichetta e switch manuale
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.kitchen_rounded,
                        color: Color(0xFFF97316), size: 16.0),
                    const SizedBox(width: 6.0),
                    Text(
                      widget.labelText,
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 6.0),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6.0, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF97316).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6.0),
                      ),
                      child: const Text(
                        'Dispensa',
                        style: TextStyle(
                          color: Color(0xFFEA580C),
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                InkWell(
                  onTap: () => setState(() => _modalitaManuale = true),
                  child: Text(
                    'Modifica testo libero',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.primary,
                      fontSize: 11.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6.0),

            // Chips degli ingredienti già selezionati
            if (selezionati.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Wrap(
                  spacing: 6.0,
                  runSpacing: 6.0,
                  children: selezionati.asMap().entries.map((entry) {
                    final index = entry.key;
                    final nome = entry.value;

                    // Controlla se è esaurito in dispensa
                    final itemDispensa = _dispensaItems.firstWhereOrNull(
                      (d) => d.nome.trim().toLowerCase() == nome.trim().toLowerCase(),
                    );
                    final isEsaurito = itemDispensa?.esaurito ?? false;

                    return Chip(
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      labelPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                      avatar: isEsaurito
                          ? const Icon(Icons.block_rounded,
                              size: 14.0, color: Color(0xFFEF4444))
                          : null,
                      backgroundColor: isEsaurito
                          ? const Color(0xFFEF4444).withValues(alpha: 0.12)
                          : colorScheme.primary.withValues(alpha: 0.08),
                      side: BorderSide(
                        color: isEsaurito
                            ? const Color(0xFFEF4444).withValues(alpha: 0.3)
                            : colorScheme.primary.withValues(alpha: 0.2),
                      ),
                      label: Text(
                        nome,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          decoration:
                              isEsaurito ? TextDecoration.lineThrough : null,
                          color: isEsaurito
                              ? const Color(0xFFDC2626)
                              : colorScheme.onSurface,
                        ),
                      ),
                      deleteIcon: const Icon(Icons.close_rounded, size: 16.0),
                      onDeleted: () => _rimuoviIngrediente(index),
                    );
                  }).toList(),
                ),
              ),

            // Campo di input con Autocomplete
            CompositedTransformTarget(
              link: _layerLink,
              child: TextFormField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  isDense: true,
                  hintText: widget.hintText,
                  hintStyle: theme.textTheme.bodySmall?.copyWith(
                    color: theme.hintColor,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: colorScheme.primary,
                    size: 20.0,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.check_circle_rounded,
                              color: Color(0xFF10B981), size: 20.0),
                          tooltip: 'Aggiungi',
                          onPressed: () {
                            _aggiungiIngrediente(_searchController.text);
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: theme.dividerColor.withValues(alpha: 0.2),
                    ),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: colorScheme.primary,
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  filled: true,
                  fillColor: theme.cardColor,
                ),
                onFieldSubmitted: (val) {
                  _aggiungiIngrediente(val);
                },
              ),
            ),
            const SizedBox(height: 4.0),

            // Nota di aiuto sotto
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Digita e seleziona gli ingredienti dalla tua dispensa.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.hintColor,
                      fontSize: 11.0,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    context.pushNamed(
                      GestioneDispensaWidget.routeName,
                      queryParameters: {
                        'ristoranteRef': serializeParam(
                          targetRef,
                          ParamType.DocumentReference,
                        ),
                      }.withoutNulls,
                    );
                  },
                  child: const Text(
                    'Gestisci dispensa ↗',
                    style: TextStyle(
                      color: Color(0xFFF97316),
                      fontSize: 11.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
