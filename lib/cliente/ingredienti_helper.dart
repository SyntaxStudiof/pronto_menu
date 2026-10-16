import 'package:flutter/material.dart';

class IngredientiHelper {
  /// Controlla se un ingrediente fa parte dell'elenco di ingredienti esauriti
  static bool isEsaurito(String ingrediente, Set<String> esauriti) {
    if (esauriti.isEmpty) return false;
    final pulito = ingrediente.trim().toLowerCase();
    if (pulito.isEmpty) return false;

    // Controllo corrispondenza diretta
    if (esauriti.contains(pulito)) return true;

    // Controllo corrispondenza per sottostringa (es. "mozzarella" in "mozzarella di bufala")
    for (final es in esauriti) {
      if (es.isEmpty) continue;
      if (pulito == es || pulito.contains(es) || (es.length > 3 && es.contains(pulito))) {
        return true;
      }
    }
    return false;
  }

  /// Verifica se il piatto contiene almeno un ingrediente esaurito
  static bool haIngredientiEsauriti(
    String ingredientiText,
    Set<String> esauriti, {
    String? ingredientiOriginali,
  }) {
    if (esauriti.isEmpty) return false;

    // Controllo primario sugli ingredienti originali (in lingua madre / italiano)
    if (ingredientiOriginali != null && ingredientiOriginali.trim().isNotEmpty) {
      final partiOrig = ingredientiOriginali.split(',');
      for (final p in partiOrig) {
        if (isEsaurito(p, esauriti)) return true;
      }
    }

    if (ingredientiText.trim().isEmpty) return false;
    final parti = ingredientiText.split(',');
    for (final p in parti) {
      if (isEsaurito(p, esauriti)) return true;
    }
    return false;
  }

  /// Costruisce il testo degli ingredienti con barratura (line-through) su quelli esauriti.
  /// Supporta sia la lingua originale che le versioni tradotte in lingua straniera
  /// grazie al parametro [ingredientiOriginali].
  static Widget buildIngredientiWidget({
    required String ingredientiText,
    String? ingredientiOriginali,
    required Set<String> ingredientiEsauriti,
    required TextStyle? baseStyle,
    TextStyle? strikethroughStyle,
    int? maxLines,
    TextAlign textAlign = TextAlign.start,
    TextOverflow? overflow,
    bool softWrap = true,
  }) {
    if (ingredientiText.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    final effectiveOverflow =
        overflow ?? (maxLines != null ? TextOverflow.ellipsis : TextOverflow.clip);

    if (ingredientiEsauriti.isEmpty) {
      return Text(
        ingredientiText,
        style: baseStyle,
        maxLines: maxLines,
        textAlign: textAlign,
        overflow: effectiveOverflow,
        softWrap: softWrap,
      );
    }

    final parti = ingredientiText.split(',');
    final partiOriginali = (ingredientiOriginali != null && ingredientiOriginali.trim().isNotEmpty)
        ? ingredientiOriginali.split(',')
        : null;

    final spans = <InlineSpan>[];

    final defaultStrikethrough = (strikethroughStyle ?? baseStyle)?.copyWith(
      decoration: TextDecoration.lineThrough,
      decorationColor: const Color(0xFFDC2626),
      decorationThickness: 2.0,
      color: const Color(0xFFDC2626).withValues(alpha: 0.8),
    );

    for (int i = 0; i < parti.length; i++) {
      final pezzo = parti[i].trim();
      if (pezzo.isEmpty) continue;

      bool esaurito = isEsaurito(pezzo, ingredientiEsauriti);

      // Se non corrisponde direttamente (es. lingua diversa dall'italiano),
      // verifichiamo l'ingrediente corrispondente nella lingua originale
      if (!esaurito && partiOriginali != null) {
        if (partiOriginali.length == parti.length) {
          esaurito = isEsaurito(partiOriginali[i].trim(), ingredientiEsauriti);
        } else if (i < partiOriginali.length && isEsaurito(partiOriginali[i].trim(), ingredientiEsauriti)) {
          esaurito = true;
        } else {
          // Ricerca euristica per corrispondenza
          for (final orig in partiOriginali) {
            if (isEsaurito(orig.trim(), ingredientiEsauriti)) {
              final origClean = orig.trim().toLowerCase();
              final pezzoClean = pezzo.toLowerCase();
              if (origClean.contains(pezzoClean) || pezzoClean.contains(origClean)) {
                esaurito = true;
                break;
              }
            }
          }
        }
      }

      spans.add(
        TextSpan(
          text: pezzo,
          style: esaurito ? defaultStrikethrough : baseStyle,
        ),
      );

      if (i < parti.length - 1) {
        spans.add(
          TextSpan(
            text: ', ',
            style: baseStyle,
          ),
        );
      }
    }

    return Text.rich(
      TextSpan(children: spans),
      maxLines: maxLines,
      textAlign: textAlign,
      overflow: effectiveOverflow,
      softWrap: softWrap,
    );
  }
}
