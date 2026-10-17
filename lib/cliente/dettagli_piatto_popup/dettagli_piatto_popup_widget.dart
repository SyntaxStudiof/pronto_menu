import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:styled_divider/styled_divider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/backend/schema/util/allergeni_data.dart';
import '/services/translation_service.dart';
import '/cliente/ingredienti_helper.dart';
import '/cliente/modal_personalizza_piatto_widget.dart';
import 'dettagli_piatto_popup_model.dart';
export 'dettagli_piatto_popup_model.dart';

class DettagliPiattoPopupWidget extends StatefulWidget {
  const DettagliPiattoPopupWidget({
    super.key,
    required this.piattoSelezionato,
    this.currentLang = 'it',
    this.ingredientiEsauriti,
    this.ristoranteRef,
    this.dispensaAttiva = false,
    this.modifichePiattiAttive = true,
    this.ingredientiManualiAttivi = false,
    this.prezzoAggiuntaManuale = 0.0,
    this.solaConsultazione = false,
    this.mostraFoto = true,
  });

  final PiattiRecord? piattoSelezionato;
  final String currentLang;
  final Set<String>? ingredientiEsauriti;
  final DocumentReference? ristoranteRef;
  final bool dispensaAttiva;
  final bool modifichePiattiAttive;
  final bool ingredientiManualiAttivi;
  final double prezzoAggiuntaManuale;
  final bool solaConsultazione;
  final bool mostraFoto;

  @override
  State<DettagliPiattoPopupWidget> createState() =>
      _DettagliPiattoPopupWidgetState();
}

class _DettagliPiattoPopupWidgetState extends State<DettagliPiattoPopupWidget> {
  late DettagliPiattoPopupModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DettagliPiattoPopupModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.7,
      ),
      decoration: BoxDecoration(
        color: theme.cardColor,
      ),
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(16.0, 10.0, 16.0, 10.0),
        child: SingleChildScrollView(
          controller: _model.columnController,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              if (widget.mostraFoto &&
                  widget.piattoSelezionato?.foto != null &&
                  widget.piattoSelezionato!.foto.trim().isNotEmpty) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: Image.network(
                    widget.piattoSelezionato!.foto,
                    width: double.infinity,
                    height: 240.0,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        width: double.infinity,
                        height: 240.0,
                        color: theme.dividerColor.withValues(alpha: 0.08),
                        alignment: Alignment.center,
                        child: SizedBox(
                          width: 32.0,
                          height: 32.0,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: double.infinity,
                      height: 240.0,
                      color: theme.dividerColor.withValues(alpha: 0.08),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.restaurant_outlined,
                        color: theme.hintColor,
                        size: 48.0,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12.0),
              ],
              Text(
                valueOrDefault<String>(
                  widget!.piattoSelezionato?.nome,
                  TranslationService.getUi('piatto_assente', widget.currentLang),
                ),
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall,
              ),
              if (widget!.piattoSelezionato != null &&
                  widget!.piattoSelezionato!.intolleranze.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8.0,
                    runSpacing: 6.0,
                    children: widget!.piattoSelezionato!.intolleranze.map((tag) {
                      final filtro = AllergeniData.getFiltroMagicoById(tag);
                      final label = filtro != null
                          ? '${filtro.emoji} ${TranslationService.getFiltroLabel(filtro.id, widget.currentLang)}'
                          : tag;
                      final color = filtro?.badgeColor ?? theme.colorScheme.primary;
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20.0),
                          border: Border.all(color: color, width: 1.0),
                        ),
                        child: Text(
                          label,
                          style: TextStyle(
                            color: color,
                            fontSize: 12.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              if (widget!.piattoSelezionato?.ingredienti != null &&
                  widget!.piattoSelezionato?.ingredienti != '')
                SizedBox(
                  width: 290.0,
                  child: StyledDivider(
                    thickness: 1.0,
                    color: theme.dividerColor,
                    lineStyle: DividerLineStyle.dashdotted,
                  ),
                ),
              if (widget!.piattoSelezionato?.ingredienti != null &&
                  widget!.piattoSelezionato?.ingredienti != '')
                Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Text(
                      '${TranslationService.getUi('ingredienti', widget.currentLang)}:',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IngredientiHelper.buildIngredientiWidget(
                      ingredientiText: widget.piattoSelezionato != null
                          ? TranslationService.getDishIngredients(
                              widget.piattoSelezionato!, widget.currentLang)
                          : TranslationService.getUi(
                              'ingredienti_assenti', widget.currentLang),
                      ingredientiOriginali:
                          widget.piattoSelezionato?.ingredienti,
                      ingredientiEsauriti:
                          widget.ingredientiEsauriti ?? const {},
                      baseStyle: theme.textTheme.titleMedium?.copyWith(
                        fontSize: 18.0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (IngredientiHelper.haIngredientiEsauriti(
                        widget.piattoSelezionato?.ingredienti ?? '',
                        widget.ingredientiEsauriti ?? const {})) ...[
                      const SizedBox(height: 10.0),
                      Align(
                        alignment: Alignment.center,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12.0, vertical: 6.0),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEF4444)
                                .withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(10.0),
                            border: Border.all(
                              color: const Color(0xFFEF4444)
                                  .withValues(alpha: 0.25),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.info_outline_rounded,
                                size: 15.0,
                                color: Color(0xFFDC2626),
                              ),
                              const SizedBox(width: 7.0),
                              Flexible(
                                child: Text(
                                  TranslationService.getUi(
                                      'nota_ingredienti_esauriti',
                                      widget.currentLang),
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: const Color(0xFFDC2626),
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              if (widget!.piattoSelezionato?.descrizione != null &&
                  widget!.piattoSelezionato?.descrizione != '')
                SizedBox(
                  width: 290.0,
                  child: StyledDivider(
                    thickness: 1.0,
                    color: theme.dividerColor,
                    lineStyle: DividerLineStyle.dashdotted,
                  ),
                ),
              if (widget!.piattoSelezionato?.descrizione != null &&
                  widget!.piattoSelezionato?.descrizione != '')
                Text(
                  widget.piattoSelezionato != null
                      ? TranslationService.getDishDescription(
                          widget.piattoSelezionato!, widget.currentLang)
                      : TranslationService.getUi('descrizione_assente', widget.currentLang),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              // Sezione Allergeni Obbligatori per Legge
              SizedBox(
                width: 290.0,
                child: StyledDivider(
                  thickness: 1.0,
                  color: theme.dividerColor,
                  lineStyle: DividerLineStyle.dashdotted,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.warning_amber_rounded,
                          size: 18.0, color: Colors.orange.shade700),
                      const SizedBox(width: 6.0),
                      Text(
                        '${TranslationService.getUi('allergeni', widget.currentLang)}:',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6.0),
                  if (widget!.piattoSelezionato != null &&
                      widget!.piattoSelezionato!.allergeni.isNotEmpty)
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 6.0,
                      runSpacing: 6.0,
                      children: widget!.piattoSelezionato!.allergeni.map((allId) {
                        final all = AllergeniData.getAllergeneById(allId);
                        final label = all != null
                            ? '${all.emoji} ${TranslationService.getAllergeneLabel(all.id, widget.currentLang)}'
                            : allId;
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 4.0),
                          decoration: BoxDecoration(
                            color: Colors.deepOrange.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12.0),
                            border: Border.all(
                              color: Colors.deepOrange.withValues(alpha: 0.5),
                              width: 1.0,
                            ),
                          ),
                          child: Text(
                            label,
                            style: TextStyle(
                              color: Colors.deepOrange.shade800,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }).toList(),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Text(
                        TranslationService.getUi('nessun_allergene_dichiarato', widget.currentLang),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.hintColor,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                ],
              ),
              if (widget!.piattoSelezionato?.prezzo != null)
                SizedBox(
                  width: 290.0,
                  child: StyledDivider(
                    thickness: 1.0,
                    color: theme.dividerColor,
                    lineStyle: DividerLineStyle.dashdotted,
                  ),
                ),
              if (widget!.piattoSelezionato?.prezzo != null)
                Text(
                  formatNumber(
                    widget!.piattoSelezionato!.prezzo,
                    formatType: FormatType.decimal,
                    decimalType: DecimalType.commaDecimal,
                    currency: '€',
                  ),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              if (widget.piattoSelezionato != null) ...[
                if (!widget.solaConsultazione) ...[
                  const SizedBox(height: 18.0),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 10.0,
                    runSpacing: 8.0,
                    children: [
                      if (widget.modifichePiattiAttive &&
                          widget.ristoranteRef != null)
                        OutlinedButton.icon(
                          onPressed: () async {
                            Navigator.of(context).pop();
                            await ModalPersonalizzaPiattoWidget.show(
                              context: context,
                              piatto: widget.piattoSelezionato!,
                              ristoranteRef: widget.ristoranteRef!,
                              dispensaAttiva: widget.dispensaAttiva,
                              prezzoAggiuntaManuale:
                                  widget.prezzoAggiuntaManuale,
                              currentLang: widget.currentLang,
                            );
                          },
                          icon: Icon(
                            Icons.tune_rounded,
                            size: 18.0,
                            color: theme.colorScheme.primary,
                          ),
                          label: Text(
                            TranslationService.getUi(
                                'personalizza_piatto', widget.currentLang),
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 13.0,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                                color: theme.colorScheme.primary, width: 1.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14.0, vertical: 10.0),
                          ),
                        ),
                      ElevatedButton.icon(
                        onPressed: () {
                          final appState = FFAppState();
                          appState.addToCarrello(
                              widget.piattoSelezionato!.reference);
                          appState.totaleCarrello = appState.totaleCarrello +
                              widget.piattoSelezionato!.prezzo;
                          appState.addToCarrelloNomi(
                              widget.piattoSelezionato!.nome);
                          appState.addToCarrelloPrezzi(
                              widget.piattoSelezionato!.prezzo);

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
                                      '${widget.piattoSelezionato!.nome} aggiunto al carrello!',
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
                        icon: const Icon(Icons.add_shopping_cart_rounded,
                            size: 18.0),
                        label: Text(
                          TranslationService.getUi(
                              'aggiungi_al_carrello', widget.currentLang),
                          style: const TextStyle(
                            fontSize: 13.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 10.0),
                          elevation: 1.0,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}
