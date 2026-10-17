import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'gestione_dispensa_model.dart';

export 'gestione_dispensa_model.dart';

class GestioneDispensaWidget extends StatefulWidget {
  const GestioneDispensaWidget({
    super.key,
    this.ristoranteRef,
    this.embedded = false,
  });

  final DocumentReference? ristoranteRef;
  final bool embedded;

  static String routeName = 'gestione_dispensa';
  static String routePath = '/gestioneDispensa';

  @override
  State<GestioneDispensaWidget> createState() => _GestioneDispensaWidgetState();
}

class _GestioneDispensaWidgetState extends State<GestioneDispensaWidget> {
  late GestioneDispensaModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => GestioneDispensaModel());
    _model.searchController?.addListener(() {
      safeSetState(() {});
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  DocumentReference get _targetRistoranteRef =>
      widget.ristoranteRef ?? currentUserReference!;

  void _apriDialogIngrediente({DispensaRecord? record}) {
    final isModifica = record != null;
    final nomeController = TextEditingController(text: record?.nome ?? '');
    final quantitaController = TextEditingController(
      text: (record != null && record.quantita > 0)
          ? (record.quantita % 1 == 0
              ? record.quantita.toInt().toString()
              : record.quantita.toString())
          : '',
    );
    final sogliaController = TextEditingController(
      text: (record != null && record.sogliaMinima > 0)
          ? (record.sogliaMinima % 1 == 0
              ? record.sogliaMinima.toInt().toString()
              : record.sogliaMinima.toString())
          : '',
    );
    final prezzoController = TextEditingController(
      text: (record != null && record.prezzo > 0)
          ? (record.prezzo % 1 == 0
              ? record.prezzo.toInt().toString()
              : record.prezzo.toStringAsFixed(2))
          : '',
    );
    String unitaSelezionata = record?.unitaMisura ?? 'kg';
    bool esaurito = record?.esaurito ?? false;
    bool staPerFinire = record?.staPerFinire ?? false;
    bool isSaving = false;
    final formKey = GlobalKey<FormState>();

    const unitaDisponibili = ['kg', 'g', 'l', 'ml', 'pz', 'confezioni', 'barattoli', 'bottiglie'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
        final colorScheme = theme.colorScheme;

        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
              ),
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(sheetContext).size.height * 0.88,
                ),
                padding: const EdgeInsets.only(
                  bottom: 24.0,
                  top: 20.0,
                  left: 20.0,
                  right: 20.0,
                ),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24.0),
                    topRight: Radius.circular(24.0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 20.0,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Maniglia
                      Center(
                        child: Container(
                          width: 40.0,
                          height: 4.0,
                          decoration: BoxDecoration(
                            color: theme.dividerColor.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(2.0),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16.0),

                      // Intestazione
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
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
                                  isModifica ? Icons.edit_rounded : Icons.add_circle_outline_rounded,
                                  color: colorScheme.primary,
                                  size: 20.0,
                                ),
                              ),
                              const SizedBox(width: 10.0),
                              Text(
                                isModifica ? 'Modifica Ingrediente' : 'Nuovo Ingrediente',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.0,
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded),
                            onPressed: () => Navigator.pop(sheetContext),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20.0),

                      // Nome ingrediente
                      TextFormField(
                        controller: nomeController,
                        autofocus: !isModifica,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(
                          labelText: 'Nome ingrediente *',
                          hintText: 'Es. Mozzarella di bufala, Pomodoro, Basilico',
                          prefixIcon: Icon(Icons.restaurant_menu_rounded, color: colorScheme.primary),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14.0)),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Inserisci il nome dell\'ingrediente';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14.0),

                      // Quantità e unità di misura
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: TextFormField(
                              controller: quantitaController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: InputDecoration(
                                labelText: 'Quantità (opzionale)',
                                hintText: 'Es. 5',
                                prefixIcon: Icon(Icons.scale_rounded, color: colorScheme.primary),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14.0)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10.0),
                          Expanded(
                            flex: 2,
                            child: DropdownButtonFormField<String>(
                              initialValue: unitaDisponibili.contains(unitaSelezionata) ? unitaSelezionata : 'kg',
                              decoration: InputDecoration(
                                labelText: 'Unità',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14.0)),
                              ),
                              items: unitaDisponibili
                                  .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                                  .toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setDialogState(() => unitaSelezionata = val);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14.0),

                      // Soglia minima di avviso (opzionale)
                      TextFormField(
                        controller: sogliaController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: 'Soglia minima di scorta (opzionale)',
                          hintText: 'Quantità sotto cui segnalare che sta per finire',
                          prefixIcon: const Icon(Icons.warning_amber_rounded, color: Color(0xFFF59E0B)),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14.0)),
                        ),
                      ),
                      const SizedBox(height: 14.0),

                      // Prezzo aggiunta per il cliente (€ opzionale)
                      TextFormField(
                        controller: prezzoController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: 'Prezzo aggiunta cliente (€ opzionale)',
                          hintText: 'Es. 1.50 (costo se il cliente aggiunge questo ingrediente)',
                          prefixIcon: Icon(Icons.euro_rounded, color: colorScheme.primary),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14.0)),
                        ),
                      ),
                      const SizedBox(height: 16.0),

                      // Switch: In esaurimento
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF59E0B).withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(14.0),
                          border: Border.all(
                            color: const Color(0xFFF59E0B).withValues(alpha: 0.25),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.hourglass_bottom_rounded, color: Color(0xFFF59E0B), size: 22.0),
                            const SizedBox(width: 12.0),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Sta per finire',
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFFD97706),
                                    ),
                                  ),
                                  Text(
                                    'Segnala questo ingrediente in esaurimento nella tua dispensa.',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.hintColor,
                                      fontSize: 11.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: staPerFinire,
                              activeThumbColor: const Color(0xFFF59E0B),
                              activeTrackColor: const Color(0xFFF59E0B).withValues(alpha: 0.5),
                              onChanged: (val) {
                                setDialogState(() {
                                  staPerFinire = val;
                                  if (val) esaurito = false;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10.0),

                      // Switch: Esaurito / Finito
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444).withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(14.0),
                          border: Border.all(
                            color: const Color(0xFFEF4444).withValues(alpha: 0.25),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.block_rounded, color: Color(0xFFEF4444), size: 22.0),
                            const SizedBox(width: 12.0),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Ingrediente finito (Esaurito)',
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFFDC2626),
                                    ),
                                  ),
                                  Text(
                                    'Nel menu cliente i piatti con questo ingrediente lo mostreranno sbarrato.',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.hintColor,
                                      fontSize: 11.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: esaurito,
                              activeThumbColor: const Color(0xFFEF4444),
                              activeTrackColor: const Color(0xFFEF4444).withValues(alpha: 0.5),
                              onChanged: (val) {
                                setDialogState(() {
                                  esaurito = val;
                                  if (val) staPerFinire = false;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22.0),

                      // Pulsante Salva
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 14.0),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.0)),
                          elevation: 0.0,
                        ),
                        onPressed: isSaving ? null : () async {
                          if (!formKey.currentState!.validate()) return;
                          final nome = nomeController.text.trim();
                          if (nome.isEmpty) return;

                          setDialogState(() => isSaving = true);
                          try {
                            final qta = double.tryParse(quantitaController.text.trim()) ?? 0.0;
                            final soglia = double.tryParse(sogliaController.text.trim()) ?? 0.0;
                            final prezzoAggiunta = double.tryParse(
                                    prezzoController.text.trim().replaceAll(',', '.')) ??
                                0.0;

                            // Auto calcola staPerFinire se la quantità è <= soglia e soglia > 0
                            final isCritico = (soglia > 0 && qta > 0 && qta <= soglia) || staPerFinire;

                            if (isModifica) {
                              await record.reference.update(createDispensaRecordData(
                                nome: nome,
                                quantita: qta,
                                unitaMisura: unitaSelezionata,
                                sogliaMinima: soglia,
                                esaurito: esaurito,
                                staPerFinire: isCritico,
                                prezzo: prezzoAggiunta,
                                dataAggiornamento: DateTime.now(),
                              ));
                            } else {
                              await DispensaRecord.collection.add(createDispensaRecordData(
                                nome: nome,
                                quantita: qta,
                                unitaMisura: unitaSelezionata,
                                sogliaMinima: soglia,
                                esaurito: esaurito,
                                staPerFinire: isCritico,
                                prezzo: prezzoAggiunta,
                                proprietario: _targetRistoranteRef,
                                dataAggiornamento: DateTime.now(),
                              ));
                            }

                            if (sheetContext.mounted) {
                              Navigator.pop(sheetContext);
                            }
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  isModifica
                                      ? 'Ingrediente "$nome" aggiornato!'
                                      : 'Ingrediente "$nome" aggiunto alla dispensa!',
                                ),
                                backgroundColor: const Color(0xFF10B981),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          } catch (e) {
                            setDialogState(() => isSaving = false);
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Errore durante il salvataggio: $e'),
                                backgroundColor: colorScheme.error,
                                duration: const Duration(seconds: 4),
                              ),
                            );
                          }
                        },
                        child: isSaving
                            ? const SizedBox(
                                width: 22.0,
                                height: 22.0,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                isModifica ? 'Salva modifiche' : 'Aggiungi alla dispensa',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
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
      },
    );
  }

  void _eliminaIngrediente(DispensaRecord record) async {
    final theme = Theme.of(context);
    final confermato = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminare ingrediente?'),
        content: Text('Vuoi rimuovere "${record.nome}" dalla tua dispensa?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Annulla', style: TextStyle(color: theme.hintColor)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: theme.colorScheme.onError,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Elimina'),
          ),
        ],
      ),
    );

    if (confermato == true) {
      await record.reference.delete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ingrediente "${record.nome}" eliminato.'),
            backgroundColor: theme.colorScheme.error,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: colorScheme.surfaceContainerLowest,
        appBar: widget.embedded
            ? null
            : AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          scrolledUnderElevation: 0.0,
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
                  Icons.kitchen_rounded,
                  color: colorScheme.primary,
                  size: 20.0,
                ),
              ),
              const SizedBox(width: 10.0),
              Text(
                'Gestione dispensa',
                style: theme.appBarTheme.titleTextStyle ??
                    theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 19.0,
                      letterSpacing: -0.4,
                      color: colorScheme.onSurface,
                    ),
              ),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: FlutterFlowIconButton(
                borderColor: Colors.transparent,
                borderRadius: 24.0,
                borderWidth: 1.0,
                buttonSize: 40.0,
                icon: Icon(
                  Icons.add_rounded,
                  color: colorScheme.primary,
                  size: 24.0,
                ),
                onPressed: () => _apriDialogIngrediente(),
              ),
            ),
          ],
          centerTitle: true,
        ),
        body: SafeArea(
          top: true,
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800.0),
              child: StreamBuilder<List<DispensaRecord>>(
                stream: queryDispensaRecord(
                  queryBuilder: (q) => q.where('proprietario', isEqualTo: _targetRistoranteRef),
                ),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.error_outline_rounded,
                                color: colorScheme.error, size: 48.0),
                            const SizedBox(height: 12.0),
                            Text(
                              'Errore nel caricamento della dispensa',
                              style: theme.textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 6.0),
                            Text(
                              '${snapshot.error}',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodySmall
                                  ?.copyWith(color: theme.hintColor),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (!snapshot.hasData) {
                    return Center(
                      child: SizedBox(
                        width: 50.0,
                        height: 50.0,
                        child: SpinKitPulse(
                          color: colorScheme.primary,
                          size: 50.0,
                        ),
                      ),
                    );
                  }

                  final tuttiIngredienti = snapshot.data!;
                  final querySearch = _model.searchController?.text.trim().toLowerCase() ?? '';

                  // Calcolo statistiche
                  final countTotale = tuttiIngredienti.length;
                  final countEsauriti = tuttiIngredienti.where((i) => i.esaurito).length;
                  final countInEsaurimento =
                      tuttiIngredienti.where((i) => !i.esaurito && i.staPerFinire).length;
                  final countDisponibili =
                      tuttiIngredienti.where((i) => !i.esaurito && !i.staPerFinire).length;

                  // Filtraggio
                  final listaFiltrata = tuttiIngredienti.where((item) {
                    // Filtro testo
                    if (querySearch.isNotEmpty &&
                        !item.nome.toLowerCase().contains(querySearch)) {
                      return false;
                    }
                    // Filtro stato
                    switch (_model.filtroStato) {
                      case 'disponibili':
                        return !item.esaurito && !item.staPerFinire;
                      case 'esaurimento':
                        return !item.esaurito && item.staPerFinire;
                      case 'esauriti':
                        return item.esaurito;
                      default:
                        return true;
                    }
                  }).toList()
                    ..sort((a, b) {
                      // Ordina: esauriti prima se nel tab tutti, altrimenti per nome
                      if (a.esaurito != b.esaurito) {
                        return a.esaurito ? -1 : 1;
                      }
                      if (a.staPerFinire != b.staPerFinire) {
                        return a.staPerFinire ? -1 : 1;
                      }
                      return a.nome.toLowerCase().compareTo(b.nome.toLowerCase());
                    });

                  return Column(
                    children: [
                      // Barra statistiche rapide
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 4.0),
                        child: Row(
                          children: [
                            _buildStatCard(
                              context: context,
                              label: 'Totali',
                              count: countTotale,
                              color: colorScheme.primary,
                              icon: Icons.inventory_2_outlined,
                            ),
                            const SizedBox(width: 8.0),
                            _buildStatCard(
                              context: context,
                              label: 'In esaurimento',
                              count: countInEsaurimento,
                              color: const Color(0xFFF59E0B),
                              icon: Icons.hourglass_bottom_rounded,
                            ),
                            const SizedBox(width: 8.0),
                            _buildStatCard(
                              context: context,
                              label: 'Esauriti',
                              count: countEsauriti,
                              color: const Color(0xFFEF4444),
                              icon: Icons.block_rounded,
                            ),
                          ],
                        ),
                      ),

                      // Campo di Ricerca
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: TextField(
                          controller: _model.searchController,
                          focusNode: _model.searchFocusNode,
                          decoration: InputDecoration(
                            hintText: 'Cerca tra gli ingredienti...',
                            prefixIcon: Icon(Icons.search_rounded, color: theme.hintColor),
                            suffixIcon: querySearch.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear_rounded),
                                    onPressed: () {
                                      _model.searchController?.clear();
                                      safeSetState(() {});
                                    },
                                  )
                                : null,
                            filled: true,
                            fillColor: theme.cardColor,
                            contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14.0),
                              borderSide: BorderSide(color: theme.dividerColor.withValues(alpha: 0.15)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14.0),
                              borderSide: BorderSide(color: theme.dividerColor.withValues(alpha: 0.15)),
                            ),
                          ),
                        ),
                      ),

                      // Chip dei filtri
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                        child: Row(
                          children: [
                            _buildFilterChip(
                              context: context,
                              label: 'Tutti ($countTotale)',
                              tag: 'tutti',
                            ),
                            const SizedBox(width: 8.0),
                            _buildFilterChip(
                              context: context,
                              label: 'Disponibili ($countDisponibili)',
                              tag: 'disponibili',
                              activeColor: const Color(0xFF10B981),
                            ),
                            const SizedBox(width: 8.0),
                            _buildFilterChip(
                              context: context,
                              label: 'In esaurimento ($countInEsaurimento)',
                              tag: 'esaurimento',
                              activeColor: const Color(0xFFF59E0B),
                            ),
                            const SizedBox(width: 8.0),
                            _buildFilterChip(
                              context: context,
                              label: 'Esauriti ($countEsauriti)',
                              tag: 'esauriti',
                              activeColor: const Color(0xFFEF4444),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 8.0),

                      // Lista ingredienti o Empty state
                      Expanded(
                        child: tuttiIngredienti.isEmpty
                            ? _buildEmptyStateInitial(context)
                            : listaFiltrata.isEmpty
                                ? _buildEmptyStateNoResults(context, querySearch)
                                : ListView.separated(
                                    padding: const EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 24.0),
                                    itemCount: listaFiltrata.length,
                                    separatorBuilder: (_, __) => const SizedBox(height: 10.0),
                                    itemBuilder: (context, index) {
                                      final item = listaFiltrata[index];
                                      return _buildIngredientCard(context, item);
                                    },
                                  ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required BuildContext context,
    required String label,
    required int count,
    required Color color,
    required IconData icon,
  }) {
    final theme = Theme.of(context);

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(14.0),
          border: Border.all(color: theme.dividerColor.withValues(alpha: 0.15)),
        ),
        child: Row(
          children: [
            Container(
              width: 30.0,
              height: 30.0,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8.0),
              ),
              alignment: Alignment.center,
              child: Icon(icon, color: color, size: 16.0),
            ),
            const SizedBox(width: 6.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$count',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 15.0,
                      color: count > 0 && color != theme.colorScheme.primary ? color : null,
                    ),
                  ),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.hintColor,
                      fontSize: 10.0,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required BuildContext context,
    required String label,
    required String tag,
    Color? activeColor,
  }) {
    final theme = Theme.of(context);
    final isSelected = _model.filtroStato == tag;
    final color = activeColor ?? theme.colorScheme.primary;

    return FilterChip(
      selected: isSelected,
      label: Text(label),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : theme.textTheme.bodyMedium?.color,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        fontSize: 12.5,
      ),
      backgroundColor: theme.cardColor,
      selectedColor: color,
      checkmarkColor: Colors.white,
      showCheckmark: false,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
        side: BorderSide(
          color: isSelected ? color : theme.dividerColor.withValues(alpha: 0.2),
        ),
      ),
      onSelected: (selected) {
        safeSetState(() {
          _model.filtroStato = tag;
        });
      },
    );
  }

  Widget _buildIngredientCard(BuildContext context, DispensaRecord item) {
    final theme = Theme.of(context);
    final isEsaurito = item.esaurito;
    final isCritico = item.staPerFinire && !isEsaurito;

    Color badgeBg;
    Color badgeText;
    String badgeLabel;
    IconData badgeIcon;

    if (isEsaurito) {
      badgeBg = const Color(0xFFEF4444).withValues(alpha: 0.12);
      badgeText = const Color(0xFFDC2626);
      badgeLabel = 'Esaurito';
      badgeIcon = Icons.block_rounded;
    } else if (isCritico) {
      badgeBg = const Color(0xFFF59E0B).withValues(alpha: 0.15);
      badgeText = const Color(0xFFD97706);
      badgeLabel = 'In esaurimento';
      badgeIcon = Icons.warning_amber_rounded;
    } else {
      badgeBg = const Color(0xFF10B981).withValues(alpha: 0.12);
      badgeText = const Color(0xFF059669);
      badgeLabel = 'Disponibile';
      badgeIcon = Icons.check_circle_outline_rounded;
    }

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: isEsaurito
              ? const Color(0xFFEF4444).withValues(alpha: 0.25)
              : isCritico
                  ? const Color(0xFFF59E0B).withValues(alpha: 0.3)
                  : theme.dividerColor.withValues(alpha: 0.15),
          width: isEsaurito || isCritico ? 1.2 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icona Ingrediente
              Container(
                width: 40.0,
                height: 40.0,
                decoration: BoxDecoration(
                  color: isEsaurito
                      ? const Color(0xFFEF4444).withValues(alpha: 0.1)
                      : isCritico
                          ? const Color(0xFFF59E0B).withValues(alpha: 0.1)
                          : theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.restaurant_menu_rounded,
                  color: isEsaurito
                      ? const Color(0xFFEF4444)
                      : isCritico
                          ? const Color(0xFFF59E0B)
                          : theme.colorScheme.primary,
                  size: 20.0,
                ),
              ),
              const SizedBox(width: 12.0),

              // Nome e Scorta
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.nome,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                        decoration: isEsaurito ? TextDecoration.lineThrough : null,
                        decorationColor: const Color(0xFFDC2626),
                        color: isEsaurito ? theme.hintColor : null,
                      ),
                    ),
                    const SizedBox(height: 3.0),
                    Wrap(
                      spacing: 6.0,
                      runSpacing: 4.0,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (item.quantita > 0)
                          Text(
                            'Giacenza: ${item.quantita % 1 == 0 ? item.quantita.toInt() : item.quantita} ${item.unitaMisura}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.hintColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.5),
                          decoration: BoxDecoration(
                            color: badgeBg,
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(badgeIcon, size: 12.0, color: badgeText),
                              const SizedBox(width: 4.0),
                              Text(
                                badgeLabel,
                                style: TextStyle(
                                  color: badgeText,
                                  fontSize: 11.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (item.prezzo > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7.0, vertical: 2.5),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: Text(
                              '+€${item.prezzo % 1 == 0 ? item.prezzo.toInt().toString() : item.prezzo.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontSize: 11.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // Tasto rapido: Segna Esaurito / Disponibile
              IconButton(
                tooltip: isEsaurito ? 'Segna come disponibile' : 'Segna come esaurito (finito)',
                icon: Icon(
                  isEsaurito ? Icons.check_circle_rounded : Icons.block_rounded,
                  color: isEsaurito ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                  size: 24.0,
                ),
                onPressed: () async {
                  final nuovoStato = !isEsaurito;
                  await item.reference.update(createDispensaRecordData(
                    esaurito: nuovoStato,
                    staPerFinire: nuovoStato ? false : item.staPerFinire,
                    dataAggiornamento: DateTime.now(),
                  ));
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          nuovoStato
                              ? '"${item.nome}" segnato come esaurito! Nel menu cliente apparirà sbarrato.'
                              : '"${item.nome}" torna disponibile nel menu.',
                        ),
                        backgroundColor: nuovoStato ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
              ),

              // Menu Altro (Modifica / Elimina)
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert_rounded, color: theme.hintColor),
                onSelected: (val) {
                  if (val == 'modifica') {
                    _apriDialogIngrediente(record: item);
                  } else if (val == 'esaurimento') {
                    item.reference.update(createDispensaRecordData(
                      staPerFinire: !item.staPerFinire,
                      dataAggiornamento: DateTime.now(),
                    ));
                  } else if (val == 'elimina') {
                    _eliminaIngrediente(item);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'modifica',
                    child: Row(
                      children: [
                        Icon(Icons.edit_rounded, size: 18.0, color: theme.colorScheme.primary),
                        const SizedBox(width: 8.0),
                        const Text('Modifica'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'esaurimento',
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded, size: 18.0, color: Color(0xFFF59E0B)),
                        const SizedBox(width: 8.0),
                        Text(item.staPerFinire ? 'Rimuovi avviso scorta' : 'Segna in esaurimento'),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  PopupMenuItem(
                    value: 'elimina',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline_rounded, size: 18.0, color: theme.colorScheme.error),
                        const SizedBox(width: 8.0),
                        Text('Elimina', style: TextStyle(color: theme.colorScheme.error)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyStateInitial(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 440.0),
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(24.0),
            border: Border.all(
              color: theme.dividerColor.withValues(alpha: 0.15),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 16.0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 76.0,
                height: 76.0,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.kitchen_rounded,
                  color: colorScheme.primary,
                  size: 38.0,
                ),
              ),
              const SizedBox(height: 18.0),
              Text(
                'La tua dispensa è vuota',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 8.0),
              Text(
                'Aggiungi gli ingredienti del tuo locale per gestire le giacenze, velocizzare la creazione dei piatti con il completamento automatico e segnalare gli ingredienti finiti.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.hintColor,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 22.0),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.0)),
                  elevation: 0.0,
                ),
                onPressed: () => _apriDialogIngrediente(),
                icon: const Icon(Icons.add_rounded, size: 20.0),
                label: const Text(
                  'Aggiungi primo ingrediente',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyStateNoResults(BuildContext context, String query) {
    final theme = Theme.of(context);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_rounded, size: 48.0, color: theme.hintColor),
            const SizedBox(height: 12.0),
            Text(
              'Nessun ingrediente trovato',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4.0),
            Text(
              'Nessun risultato corrisponde al filtro attuale.',
              style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
            ),
            const SizedBox(height: 16.0),
            OutlinedButton.icon(
              onPressed: () => _apriDialogIngrediente(),
              icon: const Icon(Icons.add_rounded, size: 18.0),
              label: Text('Aggiungi "$query" alla dispensa'),
            ),
          ],
        ),
      ),
    );
  }
}
