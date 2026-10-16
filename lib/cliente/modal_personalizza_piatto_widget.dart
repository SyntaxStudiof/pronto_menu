import 'package:flutter/material.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/services/translation_service.dart';

class ModalPersonalizzaPiattoWidget extends StatefulWidget {
  const ModalPersonalizzaPiattoWidget({
    super.key,
    required this.piatto,
    required this.ristoranteRef,
    this.dispensaAttiva = false,
    this.prezzoAggiuntaManuale = 0.0,
    this.currentLang = 'it',
  });

  final PiattiRecord piatto;
  final DocumentReference ristoranteRef;
  final bool dispensaAttiva;
  final double prezzoAggiuntaManuale;
  final String currentLang;

  static Future<void> show({
    required BuildContext context,
    required PiattiRecord piatto,
    required DocumentReference ristoranteRef,
    bool dispensaAttiva = false,
    double prezzoAggiuntaManuale = 0.0,
    String currentLang = 'it',
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: ModalPersonalizzaPiattoWidget(
          piatto: piatto,
          ristoranteRef: ristoranteRef,
          dispensaAttiva: dispensaAttiva,
          prezzoAggiuntaManuale: prezzoAggiuntaManuale,
          currentLang: currentLang,
        ),
      ),
    );
  }

  @override
  State<ModalPersonalizzaPiattoWidget> createState() =>
      _ModalPersonalizzaPiattoWidgetState();
}

class _ModalPersonalizzaPiattoWidgetState
    extends State<ModalPersonalizzaPiattoWidget> {
  final textEditingManualController = TextEditingController();
  final searchController = TextEditingController();

  // Ingredienti base rimossi (es. "senza cipolla")
  final Set<String> _ingredientiRimossi = {};

  // Ingredienti aggiunti dalla dispensa: Nome -> Prezzo extra
  final Map<String, double> _ingredientiAggiuntiDispensa = {};

  // Ingredienti aggiunti a mano libera (quando dispensaAttiva è false)
  final List<String> _ingredientiAggiuntiManuali = [];

  String _searchQuery = '';

  @override
  void dispose() {
    textEditingManualController.dispose();
    searchController.dispose();
    super.dispose();
  }

  List<String> get _ingredientiBase {
    if (widget.piatto.ingredienti.trim().isEmpty) return [];
    return widget.piatto.ingredienti
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  /// Calcola il prezzo totale del piatto con tutte le aggiunte selezionate
  double get _totaleCalcolato {
    double tot = widget.piatto.prezzo;
    if (widget.dispensaAttiva) {
      for (final extra in _ingredientiAggiuntiDispensa.values) {
        tot += extra;
      }
    } else {
      tot += _ingredientiAggiuntiManuali.length * widget.prezzoAggiuntaManuale;
    }
    return tot;
  }

  /// Genera il nome completo del piatto con le modifiche
  String _costruisciNomePersonalizzato() {
    final baseNome = widget.piatto.nome.trim();
    final List<String> modifiche = [];

    if (widget.dispensaAttiva) {
      for (final ing in _ingredientiAggiuntiDispensa.keys) {
        modifiche.add('+$ing');
      }
    } else {
      for (final man in _ingredientiAggiuntiManuali) {
        modifiche.add('+$man');
      }
    }
    for (final rim in _ingredientiRimossi) {
      modifiche.add('-$rim');
    }

    if (modifiche.isEmpty) {
      return baseNome;
    }

    return '$baseNome (${modifiche.join(', ')})';
  }

  void _aggiungiManuale() {
    final text = textEditingManualController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      if (!_ingredientiAggiuntiManuali.contains(text)) {
        _ingredientiAggiuntiManuali.add(text);
      }
      textEditingManualController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final nomePersonalizzato = _costruisciNomePersonalizzato();
    final haModifiche = _ingredientiAggiuntiDispensa.isNotEmpty ||
        _ingredientiAggiuntiManuali.isNotEmpty ||
        _ingredientiRimossi.isNotEmpty;

    final totalePiatto = _totaleCalcolato;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.85,
      ),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24.0),
          topRight: Radius.circular(24.0),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Handle di trascinamento ───────────────────────────────
          Center(
            child: Container(
              width: 44.0,
              height: 4.5,
              margin: const EdgeInsets.only(top: 12.0, bottom: 8.0),
              decoration: BoxDecoration(
                color: theme.dividerColor.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),

          // ── Header del Piatto ────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(18.0, 4.0, 16.0, 12.0),
            child: Row(
              children: [
                Container(
                  width: 42.0,
                  height: 42.0,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.tune_rounded,
                    color: colorScheme.primary,
                    size: 22.0,
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        TranslationService.getUi(
                            'personalizza_piatto', widget.currentLang),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        widget.piatto.nome,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10.0, vertical: 5.0),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Text(
                    formatNumber(
                      totalePiatto,
                      formatType: FormatType.decimal,
                      decimalType: DecimalType.commaDecimal,
                      currency: '€',
                    ),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.0,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 4.0),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 22.0),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          Divider(
            height: 1.0,
            thickness: 1.0,
            color: theme.dividerColor.withValues(alpha: 0.2),
          ),

          // ── Corpo Scrollabile ─────────────────────────────────────
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18.0, 14.0, 18.0, 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Sezione 1: Ingredienti Base (Opzione rimozione) ──
                  if (_ingredientiBase.isNotEmpty) ...[
                    Row(
                      children: [
                        Icon(
                          Icons.restaurant_rounded,
                          size: 16.0,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 6.0),
                        Text(
                          TranslationService.getUi(
                              'ingredienti_base', widget.currentLang),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 13.0,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: _ingredientiBase.map((ing) {
                        final isRimosso = _ingredientiRimossi.contains(ing);
                        return InkWell(
                          onTap: () {
                            setState(() {
                              if (isRimosso) {
                                _ingredientiRimossi.remove(ing);
                              } else {
                                _ingredientiRimossi.add(ing);
                              }
                            });
                          },
                          borderRadius: BorderRadius.circular(12.0),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10.0, vertical: 6.0),
                            decoration: BoxDecoration(
                              color: isRimosso
                                  ? colorScheme.error.withValues(alpha: 0.12)
                                  : (isDark
                                      ? Colors.white.withValues(alpha: 0.08)
                                      : Colors.black.withValues(alpha: 0.05)),
                              borderRadius: BorderRadius.circular(12.0),
                              border: Border.all(
                                color: isRimosso
                                    ? colorScheme.error
                                    : theme.dividerColor.withValues(alpha: 0.3),
                                width: isRimosso ? 1.5 : 1.0,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isRimosso
                                      ? Icons.close_rounded
                                      : Icons.check_rounded,
                                  size: 14.0,
                                  color: isRimosso
                                      ? colorScheme.error
                                      : colorScheme.primary,
                                ),
                                const SizedBox(width: 5.0),
                                Text(
                                  isRimosso ? 'Senza $ing' : ing,
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: isRimosso
                                        ? FontWeight.bold
                                        : FontWeight.w500,
                                    color: isRimosso
                                        ? colorScheme.error
                                        : colorScheme.onSurface,
                                    decoration: isRimosso
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20.0),
                  ],

                  // ── Sezione 2: Aggiungi dalla Dispensa (Se la dispensa è ATTIVA) ──
                  if (widget.dispensaAttiva) ...[
                    Row(
                      children: [
                        const Icon(
                          Icons.kitchen_rounded,
                          size: 16.0,
                          color: Color(0xFF16A34A),
                        ),
                        const SizedBox(width: 6.0),
                        Text(
                          TranslationService.getUi(
                              'aggiungi_dalla_dispensa', widget.currentLang),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 13.0,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    StreamBuilder<List<DispensaRecord>>(
                      stream: queryDispensaRecord(
                        queryBuilder: (dispensaRecord) => dispensaRecord
                            .where('proprietario',
                                isEqualTo: widget.ristoranteRef)
                            .where('esaurito', isEqualTo: false),
                      ),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 16.0),
                              child: SizedBox(
                                width: 24.0,
                                height: 24.0,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2.0),
                              ),
                            ),
                          );
                        }

                        final items = snapshot.data!;
                        if (items.isEmpty) {
                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12.0, vertical: 10.0),
                            decoration: BoxDecoration(
                              color: theme.dividerColor.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(10.0),
                              border: Border.all(
                                color:
                                    theme.dividerColor.withValues(alpha: 0.15),
                              ),
                            ),
                            child: Text(
                              TranslationService.getUi(
                                  'nessun_ingrediente_dispensa',
                                  widget.currentLang),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.hintColor,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          );
                        }

                        // Se ci sono più di 6 ingredienti, mostriamo campo di ricerca rapido
                        final filteredItems = _searchQuery.isEmpty
                            ? items
                            : items
                                .where((it) => it.nome
                                    .toLowerCase()
                                    .contains(_searchQuery.toLowerCase()))
                                .toList();

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (items.length > 6) ...[
                              Container(
                                height: 38.0,
                                margin: const EdgeInsets.only(bottom: 10.0),
                                child: TextField(
                                  controller: searchController,
                                  onChanged: (val) {
                                    setState(() {
                                      _searchQuery = val.trim();
                                    });
                                  },
                                  decoration: InputDecoration(
                                    hintText: TranslationService.getUi(
                                        'cerca_ingrediente',
                                        widget.currentLang),
                                    hintStyle: TextStyle(
                                      fontSize: 12.5,
                                      color: theme.hintColor,
                                    ),
                                    prefixIcon: const Icon(
                                      Icons.search_rounded,
                                      size: 18.0,
                                    ),
                                    suffixIcon: _searchQuery.isNotEmpty
                                        ? IconButton(
                                            icon: const Icon(
                                                Icons.clear_rounded,
                                                size: 16.0),
                                            onPressed: () {
                                              setState(() {
                                                searchController.clear();
                                                _searchQuery = '';
                                              });
                                            },
                                          )
                                        : null,
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 8.0, horizontal: 12.0),
                                    filled: true,
                                    fillColor: isDark
                                        ? Colors.white.withValues(alpha: 0.05)
                                        : Colors.black.withValues(alpha: 0.03),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide: BorderSide(
                                        color: theme.dividerColor
                                            .withValues(alpha: 0.2),
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide: BorderSide(
                                        color: theme.dividerColor
                                            .withValues(alpha: 0.2),
                                      ),
                                    ),
                                  ),
                                  style: const TextStyle(fontSize: 13.0),
                                ),
                              ),
                            ],
                            Wrap(
                              spacing: 8.0,
                              runSpacing: 8.0,
                              children: filteredItems.map((ing) {
                                final isSelected =
                                    _ingredientiAggiuntiDispensa.containsKey(ing.nome);
                                return InkWell(
                                  onTap: () {
                                    setState(() {
                                      if (isSelected) {
                                        _ingredientiAggiuntiDispensa
                                            .remove(ing.nome);
                                      } else {
                                        _ingredientiAggiuntiDispensa[ing.nome] =
                                            ing.prezzo;
                                      }
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(12.0),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 11.0, vertical: 7.0),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? const Color(0xFF16A34A)
                                              .withValues(alpha: 0.15)
                                          : (isDark
                                              ? Colors.white
                                                  .withValues(alpha: 0.06)
                                              : Colors.black
                                                  .withValues(alpha: 0.04)),
                                      borderRadius:
                                          BorderRadius.circular(12.0),
                                      border: Border.all(
                                        color: isSelected
                                            ? const Color(0xFF16A34A)
                                            : theme.dividerColor
                                                .withValues(alpha: 0.25),
                                        width: isSelected ? 1.6 : 1.0,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          isSelected
                                              ? Icons.check_circle_rounded
                                              : Icons.add_circle_outline_rounded,
                                          size: 15.0,
                                          color: isSelected
                                              ? const Color(0xFF16A34A)
                                              : theme.hintColor,
                                        ),
                                        const SizedBox(width: 6.0),
                                        Text(
                                          ing.prezzo > 0
                                              ? '+ ${ing.nome} (+€${formatNumber(ing.prezzo, formatType: FormatType.decimal, decimalType: DecimalType.commaDecimal)})'
                                              : '+ ${ing.nome}',
                                          style: TextStyle(
                                            fontSize: 12.5,
                                            fontWeight: isSelected
                                                ? FontWeight.bold
                                                : FontWeight.w500,
                                            color: isSelected
                                                ? const Color(0xFF16A34A)
                                                : colorScheme.onSurface,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 20.0),
                  ],

                  // ── Sezione 3: Scrittura a Mano Libera (Se la dispensa è DISATTIVATA) ──
                  if (!widget.dispensaAttiva) ...[
                    Row(
                      children: [
                        const Icon(
                          Icons.edit_note_rounded,
                          size: 18.0,
                          color: Color(0xFF3B82F6),
                        ),
                        const SizedBox(width: 6.0),
                        Expanded(
                          child: Row(
                            children: [
                              Text(
                                TranslationService.getUi(
                                    'ingrediente_manuale_titolo',
                                    widget.currentLang),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13.0,
                                ),
                              ),
                              if (widget.prezzoAggiuntaManuale > 0) ...[
                                const SizedBox(width: 6.0),
                                Text(
                                  '(+€${formatNumber(widget.prezzoAggiuntaManuale, formatType: FormatType.decimal, decimalType: DecimalType.commaDecimal)} cad.)',
                                  style: TextStyle(
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.w600,
                                    color: colorScheme.primary,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 42.0,
                            child: TextField(
                              controller: textEditingManualController,
                              onSubmitted: (_) => _aggiungiManuale(),
                              decoration: InputDecoration(
                                hintText: TranslationService.getUi(
                                    'ingrediente_manuale_hint',
                                    widget.currentLang),
                                hintStyle: TextStyle(
                                  fontSize: 12.5,
                                  color: theme.hintColor,
                                ),
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 12.0),
                                filled: true,
                                fillColor: isDark
                                    ? Colors.white.withValues(alpha: 0.05)
                                    : Colors.black.withValues(alpha: 0.03),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: BorderSide(
                                    color: theme.dividerColor
                                        .withValues(alpha: 0.2),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: BorderSide(
                                    color: theme.dividerColor
                                        .withValues(alpha: 0.2),
                                  ),
                                ),
                              ),
                              style: const TextStyle(fontSize: 13.0),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        ElevatedButton.icon(
                          onPressed: _aggiungiManuale,
                          icon: const Icon(Icons.add_rounded, size: 16.0),
                          label: Text(
                            TranslationService.getUi(
                                'aggiungi', widget.currentLang),
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3B82F6),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12.0, vertical: 10.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_ingredientiAggiuntiManuali.isNotEmpty) ...[
                      const SizedBox(height: 10.0),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: _ingredientiAggiuntiManuali.map((man) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10.0, vertical: 5.0),
                            decoration: BoxDecoration(
                              color: const Color(0xFF3B82F6)
                                  .withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10.0),
                              border: Border.all(
                                color: const Color(0xFF3B82F6),
                                width: 1.2,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  widget.prezzoAggiuntaManuale > 0
                                      ? '+ $man (+€${formatNumber(widget.prezzoAggiuntaManuale, formatType: FormatType.decimal, decimalType: DecimalType.commaDecimal)})'
                                      : '+ $man',
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2563EB),
                                  ),
                                ),
                                const SizedBox(width: 4.0),
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      _ingredientiAggiuntiManuali.remove(man);
                                    });
                                  },
                                  child: const Icon(
                                    Icons.close_rounded,
                                    size: 15.0,
                                    color: Color(0xFF2563EB),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                    const SizedBox(height: 20.0),
                  ],

                  // ── Sezione 4: Anteprima Modifiche Piatto ─────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: haModifiche
                          ? colorScheme.primary.withValues(alpha: 0.08)
                          : theme.dividerColor.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(
                        color: haModifiche
                            ? colorScheme.primary.withValues(alpha: 0.3)
                            : theme.dividerColor.withValues(alpha: 0.15),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          TranslationService.getUi(
                              'riepilogo_modifiche', widget.currentLang),
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            color: haModifiche
                                ? colorScheme.primary
                                : theme.hintColor,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          haModifiche
                              ? nomePersonalizzato
                              : TranslationService.getUi(
                                  'nessuna_modifica', widget.currentLang),
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: haModifiche
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: haModifiche
                                ? colorScheme.onSurface
                                : theme.hintColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Footer con Pulsante di Aggiunta al Carrello ───────────
          Container(
            padding: const EdgeInsets.fromLTRB(18.0, 12.0, 18.0, 18.0),
            decoration: BoxDecoration(
              color: theme.cardColor,
              border: Border(
                top: BorderSide(
                  color: theme.dividerColor.withValues(alpha: 0.15),
                  width: 1.0,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10.0,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 48.0,
              child: ElevatedButton.icon(
                onPressed: () {
                  final appState = FFAppState();
                  final prezzoFinale = _totaleCalcolato;
                  appState.addToCarrello(widget.piatto.reference);
                  appState.totaleCarrello =
                      appState.totaleCarrello + prezzoFinale;
                  appState.addToCarrelloNomi(nomePersonalizzato);
                  appState.addToCarrelloPrezzi(prezzoFinale);

                  Navigator.of(context).pop();

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.check_circle_rounded,
                              color: Colors.white, size: 20.0),
                          const SizedBox(width: 8.0),
                          Expanded(
                            child: Text(
                              TranslationService.getUi(
                                  'piatto_personalizzato_aggiunto',
                                  widget.currentLang),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      backgroundColor: const Color(0xFF16A34A),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                icon: const Icon(Icons.add_shopping_cart_rounded, size: 20.0),
                label: Text(
                  '${TranslationService.getUi('aggiungi_al_carrello', widget.currentLang)} (${formatNumber(totalePiatto, formatType: FormatType.decimal, decimalType: DecimalType.commaDecimal, currency: '€')})',
                  style: const TextStyle(
                    fontSize: 15.0,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.0),
                  ),
                  elevation: 2.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
