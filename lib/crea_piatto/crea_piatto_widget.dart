import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/components/crea_sottocategoria_widget.dart';
import '/components/popup_foto_piatto_widget.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import '/flutter_flow/custom_functions.dart' as functions;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';
import '/backend/schema/util/allergeni_data.dart';
import '/services/translation_service.dart';
import '/services/audit_log_service.dart';
import '/components/ingredienti_dispensa_field.dart';
import 'crea_piatto_model.dart';
export 'crea_piatto_model.dart';

/// per creare nuovi piatti
class CreaPiattoWidget extends StatefulWidget {
  const CreaPiattoWidget({
    super.key,
    this.categoriaSelezionata,
    this.piattoDaModificare,
    bool? isModifica,
    this.ristoranteRef,
  }) : this.isModifica = isModifica ?? false;

  final DocumentReference? categoriaSelezionata;
  final PiattiRecord? piattoDaModificare;
  final bool isModifica;
  final DocumentReference? ristoranteRef;

  static String routeName = 'CreaPiatto';
  static String routePath = '/creaPiatto';

  @override
  State<CreaPiattoWidget> createState() => _CreaPiattoWidgetState();
}

class _CreaPiattoWidgetState extends State<CreaPiattoWidget> {
  late CreaPiattoModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CreaPiattoModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      if (widget.isModifica && widget.piattoDaModificare != null) {
        FFAppState().fotoInMemoria = widget.piattoDaModificare!.foto;
        _model.intolleranzeSelezionate =
            List<String>.from(widget.piattoDaModificare!.intolleranze);
        _model.allergeniSelezionati =
            List<String>.from(widget.piattoDaModificare!.allergeni);
        safeSetState(() {});
      } else {
        FFAppState().fotoInMemoria = '';
        _model.intolleranzeSelezionate = [];
        _model.allergeniSelezionati = [];
        safeSetState(() {});
      }
    });

    _model.nomePiattoTextController ??=
        TextEditingController(text: widget.piattoDaModificare?.nome);
    _model.nomePiattoFocusNode ??= FocusNode();

    _model.prezzoTextController ??= TextEditingController(
        text: widget.piattoDaModificare?.prezzo?.toString());
    _model.prezzoFocusNode ??= FocusNode();

    _model.ingredientiTextController ??=
        TextEditingController(text: widget.piattoDaModificare?.ingredienti);
    _model.ingredientiFocusNode ??= FocusNode();

    _model.descrizioneTextController ??=
        TextEditingController(text: widget.piattoDaModificare?.descrizione);
    _model.descrizioneFocusNode ??= FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();
    final theme = Theme.of(context);

    return StreamBuilder<List<SottocategorieRecord>>(
      stream: querySottocategorieRecord(),
      builder: (context, snapshot) {
        // Customize what your widget looks like when it's loading.
        if (!snapshot.hasData) {
          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            body: Center(
              child: SizedBox(
                width: 50.0,
                height: 50.0,
                child: SpinKitPulse(
                  color: theme.colorScheme.primary,
                  size: 50.0,
                ),
              ),
            ),
          );
        }
        List<SottocategorieRecord> creaPiattoSottocategorieRecordList =
            snapshot.data!;

        return GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Scaffold(
            key: scaffoldKey,
            backgroundColor: theme.scaffoldBackgroundColor,
            appBar: AppBar(
              backgroundColor: theme.appBarTheme.backgroundColor ?? theme.cardColor,
              automaticallyImplyLeading: false,
              leading: FlutterFlowIconButton(
                borderColor: Colors.transparent,
                borderRadius: 30.0,
                borderWidth: 1.0,
                buttonSize: 40.0,
                icon: Icon(
                  Icons.arrow_back_rounded,
                  color: theme.appBarTheme.foregroundColor ?? theme.iconTheme.color,
                  size: 24.0,
                ),
                onPressed: () async {
                  context.pop();
                },
              ),
              title: Text(
                'Crea piatto',
                style: theme.appBarTheme.titleTextStyle ??
                    theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 22.0,
                    ),
              ),
              actions: const [],
              centerTitle: true,
              elevation: theme.appBarTheme.elevation ?? 2.0,
            ),
            body: SafeArea(
              top: true,
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(20.0, 20.0, 20.0, 20.0),
                child: SingleChildScrollView(
                  controller: _model.columnController,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Stack(
                        children: [
                          Align(
                            alignment: const AlignmentDirectional(0.0, 0.0),
                            child: CircularPercentIndicator(
                              percent: 1.0,
                              radius: 122.5,
                              lineWidth: 40.0,
                              animation: true,
                              animateFromLastPercent: true,
                              progressColor: theme.colorScheme.primary,
                              backgroundColor: theme.dividerColor,
                              center: Text(
                                '50%',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          InkWell(
                            splashColor: Colors.transparent,
                            focusColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            highlightColor: Colors.transparent,
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
                                      padding: MediaQuery.viewInsetsOf(context),
                                      child: const PopupFotoPiattoWidget(),
                                    ),
                                  );
                                },
                              ).then((value) => safeSetState(() {}));
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12.0),
                              child: FFAppState().fotoInMemoria.isNotEmpty
                                  ? Image.network(
                                      FFAppState().fotoInMemoria,
                                      width: double.infinity,
                                      height: 250.0,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              Container(
                                        width: double.infinity,
                                        height: 250.0,
                                        color: theme.dividerColor
                                            .withValues(alpha: 0.1),
                                        alignment: Alignment.center,
                                        child: Icon(
                                          Icons.restaurant_outlined,
                                          color: theme.iconTheme.color
                                                  ?.withValues(alpha: 0.5) ??
                                              theme.hintColor,
                                          size: 48.0,
                                        ),
                                      ),
                                    )
                                  : Container(
                                      width: double.infinity,
                                      height: 250.0,
                                      color: theme.dividerColor
                                          .withValues(alpha: 0.08),
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
                                            size: 44.0,
                                          ),
                                          const SizedBox(height: 8.0),
                                          Text(
                                            'Nessuna immagine del piatto',
                                            style: theme.textTheme.bodyMedium
                                                ?.copyWith(
                                              color: theme.hintColor,
                                            ),
                                          ),
                                          const SizedBox(height: 4.0),
                                          Text(
                                            'Tocca per caricare una foto',
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                              fontSize: 11.0,
                                              color: theme.hintColor
                                                  .withValues(alpha: 0.8),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                      Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 12.0,
                        runSpacing: 8.0,
                        children: [
                          FFButtonWidget(
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
                                      padding:
                                          MediaQuery.viewInsetsOf(context),
                                      child: const PopupFotoPiattoWidget(),
                                    ),
                                  );
                                },
                              ).then((value) => safeSetState(() {}));
                            },
                            text: FFAppState().fotoInMemoria.isNotEmpty
                                ? 'Cambia immagine'
                                : 'Carica immagine',
                            icon: const Icon(
                              Icons.photo_camera,
                              size: 15.0,
                            ),
                            options: FFButtonOptions(
                              width: 160.0,
                              height: 40.0,
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  16.0, 0.0, 16.0, 0.0),
                              iconPadding: const EdgeInsetsDirectional.fromSTEB(
                                  0.0, 0.0, 0.0, 0.0),
                              iconColor: theme.colorScheme.onPrimary,
                              color: theme.colorScheme.primary,
                              textStyle: theme.textTheme.titleSmall?.copyWith(
                                color: theme.colorScheme.onPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                              elevation: 2.0,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          if (FFAppState().fotoInMemoria.isNotEmpty)
                            OutlinedButton.icon(
                              onPressed: () {
                                safeSetState(() {
                                  FFAppState().fotoInMemoria = '';
                                });
                              },
                              icon: Icon(
                                Icons.delete_outline_rounded,
                                size: 16.0,
                                color: theme.colorScheme.error,
                              ),
                              label: Text(
                                'Elimina foto',
                                style:
                                    TextStyle(color: theme.colorScheme.error),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: theme.colorScheme.error,
                                side: BorderSide(
                                  color: theme.colorScheme.error
                                      .withValues(alpha: 0.4),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14.0, vertical: 10.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                            ),
                        ],
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              StreamBuilder<List<SottocategorieRecord>>(
                                stream: querySottocategorieRecord(
                                  queryBuilder: (sottocategorieRecord) =>
                                      sottocategorieRecord.where(Filter.or(
                                    Filter(
                                      'categoria_padre_ref',
                                      isEqualTo: widget.categoriaSelezionata,
                                    ),
                                    Filter(
                                      'proprietario',
                                      isEqualTo: currentUserReference,
                                    ),
                                  )),
                                ),
                                builder: (context, snapshot) {
                                  // Customize what your widget looks like when it's loading.
                                  if (!snapshot.hasData) {
                                    return Center(
                                      child: SizedBox(
                                        width: 50.0,
                                        height: 50.0,
                                        child: SpinKitPulse(
                                          color: theme.colorScheme.primary,
                                          size: 50.0,
                                        ),
                                      ),
                                    );
                                  }
                                  List<SottocategorieRecord>
                                      selezionaSottocategoriaSottocategorieRecordList =
                                      snapshot.data!;

                                  return FlutterFlowDropDown<String>(
                                    controller: _model
                                            .selezionaSottocategoriaValueController ??=
                                        FormFieldController<String>(
                                      _model.selezionaSottocategoriaValue ??=
                                          widget.piattoDaModificare
                                              ?.sottocategoriaRef?.id,
                                    ),
                                    options: List<String>.from(
                                        selezionaSottocategoriaSottocategorieRecordList
                                            .map((e) => e.reference.id)
                                            .toList()),
                                    optionLabels:
                                        selezionaSottocategoriaSottocategorieRecordList
                                            .map((e) => e.nome)
                                            .toList(),
                                    onChanged: (val) => safeSetState(() =>
                                        _model.selezionaSottocategoriaValue =
                                            val),
                                    width: 200.0,
                                    height: 40.0,
                                    textStyle: theme.textTheme.bodyMedium ??
                                        const TextStyle(),
                                    hintText: 'Seleziona o crea...',
                                    icon: Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      color: theme.hintColor,
                                      size: 24.0,
                                    ),
                                    fillColor: theme.cardColor,
                                    elevation: 2.0,
                                    borderColor: theme.dividerColor,
                                    borderWidth: 1.0,
                                    borderRadius: 8.0,
                                    margin: const EdgeInsetsDirectional.fromSTEB(
                                        12.0, 0.0, 12.0, 0.0),
                                    hidesUnderline: true,
                                    isOverButton: false,
                                    isSearchable: false,
                                    isMultiSelect: false,
                                  );
                                },
                              ),
                              Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    10.0, 0.0, 0.0, 0.0),
                                child: InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
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
                                            padding: MediaQuery.viewInsetsOf(
                                                context),
                                            child: SizedBox(
                                              height: MediaQuery.sizeOf(context)
                                                      .height *
                                                  0.2,
                                              child: CreaSottocategoriaWidget(
                                                categoriaRicevuta: widget
                                                    .categoriaSelezionata!,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ).then((value) => safeSetState(
                                        () => _model.risultatoPopup = value));

                                    safeSetState(() {
                                      _model
                                          .selezionaSottocategoriaValueController
                                          ?.value = _model.risultatoPopup!.id;
                                      _model.selezionaSottocategoriaValue =
                                          _model.risultatoPopup!.id;
                                    });

                                    safeSetState(() {});
                                  },
                                  child: Icon(
                                    Icons.add_sharp,
                                    color: theme.colorScheme.primary,
                                    size: 24.0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            'Crea le sottocategorie cliccando sul tasto +!',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 10.0,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        width: 200.0,
                        child: TextFormField(
                          controller: _model.nomePiattoTextController,
                          focusNode: _model.nomePiattoFocusNode,
                          autofocus: false,
                          enabled: true,
                          obscureText: false,
                          decoration: InputDecoration(
                            isDense: true,
                            labelText: 'Nome Piatto',
                            labelStyle: theme.textTheme.labelMedium,
                            hintText: 'Nome Piatto',
                            hintStyle: theme.textTheme.labelMedium?.copyWith(
                              color: theme.hintColor,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: theme.dividerColor,
                                width: 1.0,
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
                            errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: theme.colorScheme.error,
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: theme.colorScheme.error,
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            filled: true,
                            fillColor: theme.cardColor,
                          ),
                          style: theme.textTheme.bodyMedium,
                          cursorColor: theme.colorScheme.primary,
                          enableInteractiveSelection: true,
                          validator: _model.nomePiattoTextControllerValidator
                              .asValidator(context),
                        ),
                      ),
                      SizedBox(
                        width: 200.0,
                        child: TextFormField(
                          controller: _model.prezzoTextController,
                          focusNode: _model.prezzoFocusNode,
                          autofocus: false,
                          enabled: true,
                          obscureText: false,
                          decoration: InputDecoration(
                            isDense: true,
                            labelText: 'Prezzo',
                            labelStyle: theme.textTheme.labelMedium,
                            hintText: 'Prezzo',
                            hintStyle: theme.textTheme.labelMedium?.copyWith(
                              color: theme.hintColor,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: theme.dividerColor,
                                width: 1.0,
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
                            errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: theme.colorScheme.error,
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: theme.colorScheme.error,
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            filled: true,
                            fillColor: theme.cardColor,
                          ),
                          style: theme.textTheme.bodyMedium,
                          cursorColor: theme.colorScheme.primary,
                          enableInteractiveSelection: true,
                          validator: _model.prezzoTextControllerValidator
                              .asValidator(context),
                        ),
                      ),
                      SizedBox(
                        width: valueOrDefault<bool>(
                                currentUserDocument?.dispensaAttiva, false)
                            ? 280.0
                            : 200.0,
                        child: IngredientiDispensaField(
                          controller: _model.ingredientiTextController!,
                          focusNode: _model.ingredientiFocusNode,
                          ristoranteRef: widget.ristoranteRef,
                          dispensaAttiva: valueOrDefault<bool>(
                              currentUserDocument?.dispensaAttiva, false),
                          labelText: 'Ingredienti',
                          hintText: 'Cerca in dispensa...',
                          validator: _model.ingredientiTextControllerValidator
                              .asValidator(context),
                        ),
                      ),
                      SizedBox(
                        width: 200.0,
                        child: TextFormField(
                          controller: _model.descrizioneTextController,
                          focusNode: _model.descrizioneFocusNode,
                          autofocus: false,
                          enabled: true,
                          obscureText: false,
                          decoration: InputDecoration(
                            isDense: true,
                            labelText: 'Descrizione',
                            labelStyle: theme.textTheme.labelMedium,
                            hintText: 'Descrizione',
                            hintStyle: theme.textTheme.labelMedium?.copyWith(
                              color: theme.hintColor,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: theme.dividerColor,
                                width: 1.0,
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
                            errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: theme.colorScheme.error,
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: theme.colorScheme.error,
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            filled: true,
                            fillColor: theme.cardColor,
                          ),
                          style: theme.textTheme.bodyMedium,
                          maxLines: 4,
                          cursorColor: theme.colorScheme.primary,
                          enableInteractiveSelection: true,
                          validator: _model.descrizioneTextControllerValidator
                              .asValidator(context),
                        ),
                      ),
                      // Filtri Magici delle intolleranze
                      Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(maxWidth: 500.0),
                        padding: const EdgeInsets.all(14.0),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(14.0),
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
                                const Icon(Icons.auto_awesome, color: Colors.amber, size: 20.0),
                                const SizedBox(width: 8.0),
                                Text(
                                  'Filtri Magici Intolleranze',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4.0),
                            Text(
                              'Seleziona le intolleranze o regimi alimentari supportati per consentire il filtraggio magico.',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.hintColor,
                                fontSize: 11.5,
                              ),
                            ),
                            const SizedBox(height: 12.0),
                            Wrap(
                              spacing: 8.0,
                              runSpacing: 8.0,
                              children: AllergeniData.filtriMagici.map((filtro) {
                                final isSelected =
                                    _model.intolleranzeSelezionate.contains(filtro.id);
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
                                      fontSize: 13.0,
                                    ),
                                  ),
                                  selected: isSelected,
                                  selectedColor: filtro.badgeColor,
                                  checkmarkColor: Colors.white,
                                  backgroundColor: theme.scaffoldBackgroundColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                    side: BorderSide(
                                      color: isSelected
                                          ? filtro.badgeColor
                                          : theme.dividerColor,
                                    ),
                                  ),
                                  onSelected: (selected) {
                                    safeSetState(() {
                                      if (selected) {
                                        if (!_model.intolleranzeSelezionate
                                            .contains(filtro.id)) {
                                          _model.intolleranzeSelezionate
                                              .add(filtro.id);
                                        }
                                      } else {
                                        _model.intolleranzeSelezionate
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
                      // Allergeni Obbligatori per Legge (14 Allergeni UE)
                      Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(maxWidth: 500.0),
                        padding: const EdgeInsets.all(14.0),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(14.0),
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
                                const Icon(Icons.warning_amber_rounded,
                                    color: Colors.orange, size: 20.0),
                                const SizedBox(width: 8.0),
                                Expanded(
                                  child: Text(
                                    'Allergeni Obbligatori (14 Allergeni UE)',
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4.0),
                            Text(
                              'Seleziona gli allergeni presenti ai sensi del Regolamento UE 1169/2011.',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.hintColor,
                                fontSize: 11.5,
                              ),
                            ),
                            const SizedBox(height: 12.0),
                            Wrap(
                              spacing: 6.0,
                              runSpacing: 6.0,
                              children:
                                  AllergeniData.allergeniObbligatori.map((all) {
                                final isSelected =
                                    _model.allergeniSelezionati.contains(all.id);
                                return FilterChip(
                                  label: Text(
                                    '${all.emoji} ${all.label}',
                                    style: TextStyle(
                                      fontSize: 12.0,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: isSelected
                                          ? Colors.white
                                          : theme.textTheme.bodyMedium?.color,
                                    ),
                                  ),
                                  selected: isSelected,
                                  selectedColor: Colors.deepOrange.shade600,
                                  checkmarkColor: Colors.white,
                                  backgroundColor: theme.scaffoldBackgroundColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18.0),
                                    side: BorderSide(
                                      color: isSelected
                                          ? Colors.deepOrange.shade600
                                          : theme.dividerColor,
                                    ),
                                  ),
                                  onSelected: (selected) {
                                    safeSetState(() {
                                      if (selected) {
                                        if (!_model.allergeniSelezionati
                                            .contains(all.id)) {
                                          _model.allergeniSelezionati
                                              .add(all.id);
                                        }
                                      } else {
                                        _model.allergeniSelezionati
                                            .remove(all.id);
                                      }
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                      FFButtonWidget(
                        onPressed: () async {
                          _model.sottoCategoriaTrovata =
                              await querySottocategorieRecordOnce(
                            queryBuilder: (sottocategorieRecord) =>
                                sottocategorieRecord.where(
                              'nome',
                              isEqualTo: _model.selezionaSottocategoriaValue,
                            ),
                            singleRecord: true,
                          ).then((s) => s.firstOrNull);
                          final descText = _model.descrizioneTextController.text.trim();
                          final ingrText = _model.ingredientiTextController.text.trim();

                          if (widget.isModifica) {
                            if (widget.piattoDaModificare?.foto != null &&
                                widget.piattoDaModificare!.foto.isNotEmpty &&
                                widget.piattoDaModificare!.foto !=
                                    FFAppState().fotoInMemoria) {
                              try {
                                await FirebaseStorage.instance
                                    .refFromURL(widget.piattoDaModificare!.foto)
                                    .delete();
                              } catch (_) {}
                            }

                            final piattoRef = widget.piattoDaModificare!.reference;
                            await piattoRef.update(createPiattiRecordData(
                              nome: _model.nomePiattoTextController.text,
                              prezzo: functions.formattaPrezzo(
                                  _model.prezzoTextController.text),
                              categoria: widget.categoriaSelezionata?.id,
                              proprietario: widget.ristoranteRef,
                              ingredienti:
                                  _model.ingredientiTextController.text,
                              descrizione:
                                  _model.descrizioneTextController.text,
                              foto: FFAppState().fotoInMemoria,
                              sottocategoriaRef:
                                  creaPiattoSottocategorieRecordList
                                      .where((e) =>
                                          e.reference.id ==
                                          _model.selezionaSottocategoriaValue)
                                      .toList()
                                      .firstOrNull
                                      ?.reference,
                              allergeni: _model.allergeniSelezionati,
                              intolleranze: _model.intolleranzeSelezionate,
                            ));

                            // Traduzione automatica in background (descrizione e ingredienti, NO nome)
                            if (descText.isNotEmpty || ingrText.isNotEmpty) {
                              TranslationService.generateDishTranslations(
                                descrizione: descText,
                                ingredienti: ingrText,
                              ).then((traduzioni) {
                                piattoRef.update({'traduzioni': traduzioni});
                              }).catchError((e) {
                                debugPrint('Errore aggiornamento traduzioni: $e');
                              });
                            }

                            await AuditLogService.logAction(
                              ristoranteRef: widget.ristoranteRef,
                              azione: "Ha modificato il piatto '${_model.nomePiattoTextController.text}'",
                              dettagli: "Modificato piatto '${_model.nomePiattoTextController.text}' (Prezzo: ${_model.prezzoTextController.text}€)",
                              tipoAzione: 'modifica',
                              tipoEntita: 'piatto',
                            );
                          } else {
                            final newDoc = PiattiRecord.collection.doc();
                            await newDoc.set(createPiattiRecordData(
                              nome: _model.nomePiattoTextController.text,
                              categoria: widget.categoriaSelezionata?.id,
                              proprietario: widget.ristoranteRef,
                              prezzo: functions.formattaPrezzo(
                                  _model.prezzoTextController.text),
                              ingredienti:
                                  _model.ingredientiTextController.text,
                              descrizione:
                                  _model.descrizioneTextController.text,
                              foto: FFAppState().fotoInMemoria,
                              isCestinato: false,
                              sottocategoriaRef:
                                  creaPiattoSottocategorieRecordList
                                      .where((e) =>
                                          e.reference.id ==
                                          _model
                                              .selezionaSottocategoriaValue)
                                      .toList()
                                      .firstOrNull
                                      ?.reference,
                              allergeni: _model.allergeniSelezionati,
                              intolleranze: _model.intolleranzeSelezionate,
                            ));

                            // Traduzione automatica in background (descrizione e ingredienti, NO nome)
                            if (descText.isNotEmpty || ingrText.isNotEmpty) {
                              TranslationService.generateDishTranslations(
                                descrizione: descText,
                                ingredienti: ingrText,
                              ).then((traduzioni) {
                                newDoc.update({'traduzioni': traduzioni});
                              }).catchError((e) {
                                debugPrint('Errore generazione traduzioni: $e');
                              });
                            }

                            await AuditLogService.logAction(
                              ristoranteRef: widget.ristoranteRef,
                              azione: "Ha creato il piatto '${_model.nomePiattoTextController.text}'",
                              dettagli: "Creato nuovo piatto '${_model.nomePiattoTextController.text}' (Prezzo: ${_model.prezzoTextController.text}€)",
                              tipoAzione: 'creazione',
                              tipoEntita: 'piatto',
                            );

                            safeSetState(() {});
                          }

                          context.safePop();

                          safeSetState(() {});
                        },
                        text: 'Salva',
                        options: FFButtonOptions(
                          width: 160.0,
                          height: 40.0,
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              16.0, 0.0, 16.0, 0.0),
                          iconPadding: const EdgeInsetsDirectional.fromSTEB(
                              0.0, 0.0, 0.0, 0.0),
                          color: theme.colorScheme.primary,
                          textStyle: theme.textTheme.titleSmall?.copyWith(
                            color: theme.colorScheme.onPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                          elevation: 2.0,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ].divide(const SizedBox(height: 16.0)),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
