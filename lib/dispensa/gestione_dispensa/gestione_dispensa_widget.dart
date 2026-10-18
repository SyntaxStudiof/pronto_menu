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

  Future<void> _apriDialogIngrediente({DispensaRecord? record}) async {
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
    bool disponibileComeAggiunta = record?.disponibileComeAggiunta ?? false;
    bool tutteLeCategorie = record?.tutteLeCategorie ?? true;
    List<String> categorieCompatibili =
        List<String>.from(record?.categorieCompatibili ?? []);
    bool isSaving = false;
    final formKey = GlobalKey<FormState>();

    const unitaDisponibili = [
      'kg',
      'g',
      'l',
      'ml',
      'pz',
      'confezioni',
      'barattoli',
      'bottiglie'
    ];

    // Carica la lista delle categorie del menu del ristorante
    List<CategoriesRecord> categoriesList = [];
    try {
      categoriesList = await queryCategoriesRecordOnce(
        queryBuilder: (q) => q
            .where('proprietario', isEqualTo: _targetRistoranteRef)
            .orderBy('ordine_categoria'),
      );
    } catch (_) {
      try {
        categoriesList = await queryCategoriesRecordOnce(
          queryBuilder: (q) =>
              q.where('proprietario', isEqualTo: _targetRistoranteRef),
        );
      } catch (_) {}
    }

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
        final colorScheme = theme.colorScheme;
        final isDark = theme.brightness == Brightness.dark;

        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: 620.0,
                    maxHeight: MediaQuery.of(sheetContext).size.height * 0.90,
                  ),
                  child: Container(
                    padding: const EdgeInsets.only(
                      bottom: 24.0,
                      top: 20.0,
                      left: 20.0,
                      right: 20.0,
                    ),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24.0),
                        topRight: Radius.circular(24.0),
                      ),
                      border: Border.all(
                        color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                        width: 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.15),
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
                                  color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
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
                                        isModifica
                                            ? Icons.edit_rounded
                                            : Icons.add_circle_outline_rounded,
                                        color: colorScheme.primary,
                                        size: 20.0,
                                      ),
                                    ),
                                    const SizedBox(width: 10.0),
                                    Text(
                                      isModifica
                                          ? 'Modifica Ingrediente'
                                          : 'Nuovo Ingrediente',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18.0,
                                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                                      ),
                                    ),
                                  ],
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.close_rounded,
                                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                  ),
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
                              style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A)),
                              decoration: InputDecoration(
                                labelText: 'Nome ingrediente *',
                                labelStyle: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                                hintText: 'Es. Mozzarella di bufala, Salsiccia, Farina',
                                hintStyle: TextStyle(color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
                                prefixIcon: Icon(Icons.restaurant_menu_rounded, color: colorScheme.primary),
                                filled: true,
                                fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14.0),
                                  borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14.0),
                                  borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14.0),
                                  borderSide: BorderSide(color: colorScheme.primary, width: 1.8),
                                ),
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
                                    style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A)),
                                    decoration: InputDecoration(
                                      labelText: 'Quantità (opzionale)',
                                      labelStyle: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                                      hintText: 'Es. 5',
                                      hintStyle: TextStyle(color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
                                      prefixIcon: Icon(Icons.scale_rounded, color: colorScheme.primary),
                                      filled: true,
                                      fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(14.0),
                                        borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(14.0),
                                        borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(14.0),
                                        borderSide: BorderSide(color: colorScheme.primary, width: 1.8),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10.0),
                                Expanded(
                                  flex: 2,
                                  child: DropdownButtonFormField<String>(
                                    dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                                    style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A)),
                                    initialValue: unitaDisponibili.contains(unitaSelezionata)
                                        ? unitaSelezionata
                                        : 'kg',
                                    decoration: InputDecoration(
                                      labelText: 'Unità',
                                      labelStyle: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                                      filled: true,
                                      fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(14.0),
                                        borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(14.0),
                                        borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(14.0),
                                        borderSide: BorderSide(color: colorScheme.primary, width: 1.8),
                                      ),
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
                              style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A)),
                              decoration: InputDecoration(
                                labelText: 'Soglia minima di scorta (opzionale)',
                                labelStyle: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                                hintText: 'Quantità sotto cui segnalare che sta per finire',
                                hintStyle: TextStyle(color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
                                prefixIcon: const Icon(Icons.warning_amber_rounded, color: Color(0xFFF59E0B)),
                                filled: true,
                                fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14.0),
                                  borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14.0),
                                  borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14.0),
                                  borderSide: BorderSide(color: colorScheme.primary, width: 1.8),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16.0),

                            // ── SEZIONE: DISPONIBILITÀ COME AGGIUNTA NEL MENÙ ──
                            Container(
                              padding: const EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                color: disponibileComeAggiunta
                                    ? colorScheme.primary.withValues(alpha: isDark ? 0.12 : 0.05)
                                    : (isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC)),
                                borderRadius: BorderRadius.circular(16.0),
                                border: Border.all(
                                  color: disponibileComeAggiunta
                                      ? colorScheme.primary.withValues(alpha: 0.35)
                                      : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                                  width: disponibileComeAggiunta ? 1.5 : 1.0,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 38.0,
                                        height: 38.0,
                                        decoration: BoxDecoration(
                                          color: (disponibileComeAggiunta
                                                  ? colorScheme.primary
                                                  : (isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)))
                                              .withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(10.0),
                                        ),
                                        alignment: Alignment.center,
                                        child: Icon(
                                          Icons.add_shopping_cart_rounded,
                                          color: disponibileComeAggiunta
                                              ? colorScheme.primary
                                              : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                                          size: 20.0,
                                        ),
                                      ),
                                      const SizedBox(width: 12.0),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Disponibile come Aggiunta nel Menù',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14.5,
                                                color: disponibileComeAggiunta
                                                    ? colorScheme.primary
                                                    : (isDark ? Colors.white : const Color(0xFF0F172A)),
                                              ),
                                            ),
                                            const SizedBox(height: 2.0),
                                            Text(
                                              'Permetti ai clienti di aggiungere questo ingrediente ai piatti ordinabili.',
                                              style: TextStyle(
                                                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                                fontSize: 11.5,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Switch(
                                        value: disponibileComeAggiunta,
                                        activeThumbColor: colorScheme.primary,
                                        onChanged: (val) {
                                          setDialogState(() {
                                            disponibileComeAggiunta = val;
                                          });
                                        },
                                      ),
                                    ],
                                  ),

                                  if (disponibileComeAggiunta) ...[
                                    const SizedBox(height: 14.0),
                                    Divider(
                                      height: 1.0,
                                      color: colorScheme.primary.withValues(alpha: 0.2),
                                    ),
                                    const SizedBox(height: 14.0),

                                    // Prezzo aggiunta cliente
                                    TextFormField(
                                      controller: prezzoController,
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                      style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A)),
                                      decoration: InputDecoration(
                                        labelText: 'Prezzo aggiunta per il cliente (€)',
                                        labelStyle: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                                        hintText: 'Es. 1.50 (lascia vuoto o 0.00 se gratuita)',
                                        hintStyle: TextStyle(color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
                                        prefixIcon: Icon(Icons.euro_rounded, color: colorScheme.primary),
                                        filled: true,
                                        fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12.0),
                                          borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12.0),
                                          borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12.0),
                                          borderSide: BorderSide(color: colorScheme.primary, width: 1.8),
                                        ),
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
                                      ),
                                    ),
                                    const SizedBox(height: 16.0),

                                    // Selezione categorie compatibili
                                    Text(
                                      'In quali categorie di piatti è aggiungibile?',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13.0,
                                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                                      ),
                                    ),
                                    const SizedBox(height: 8.0),

                                    // Switch: Tutto il menu vs Categorie specifiche
                                    Row(
                                      children: [
                                        Expanded(
                                          child: InkWell(
                                            onTap: () {
                                              setDialogState(() {
                                                tutteLeCategorie = true;
                                              });
                                            },
                                            borderRadius: BorderRadius.circular(10.0),
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(vertical: 9.0, horizontal: 8.0),
                                              decoration: BoxDecoration(
                                                color: tutteLeCategorie
                                                    ? colorScheme.primary
                                                    : (isDark ? const Color(0xFF1E293B) : Colors.white),
                                                borderRadius: BorderRadius.circular(10.0),
                                                border: Border.all(
                                                  color: tutteLeCategorie
                                                      ? colorScheme.primary
                                                      : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                                                ),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  'Tutto il Menù',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 12.5,
                                                    color: tutteLeCategorie
                                                        ? Colors.white
                                                        : (isDark ? Colors.white : const Color(0xFF0F172A)),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8.0),
                                        Expanded(
                                          child: InkWell(
                                            onTap: () {
                                              setDialogState(() {
                                                tutteLeCategorie = false;
                                              });
                                            },
                                            borderRadius: BorderRadius.circular(10.0),
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(vertical: 9.0, horizontal: 8.0),
                                              decoration: BoxDecoration(
                                                color: !tutteLeCategorie
                                                    ? colorScheme.primary
                                                    : (isDark ? const Color(0xFF1E293B) : Colors.white),
                                                borderRadius: BorderRadius.circular(10.0),
                                                border: Border.all(
                                                  color: !tutteLeCategorie
                                                      ? colorScheme.primary
                                                      : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                                                ),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  'Categorie Specifiche',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 12.5,
                                                    color: !tutteLeCategorie
                                                        ? Colors.white
                                                        : (isDark ? Colors.white : const Color(0xFF0F172A)),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    if (!tutteLeCategorie) ...[
                                      const SizedBox(height: 12.0),
                                      if (categoriesList.isEmpty)
                                        Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                                          child: Text(
                                            'Nessuna categoria trovata nel tuo menù.',
                                            style: TextStyle(
                                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                              fontStyle: FontStyle.italic,
                                              fontSize: 12.0,
                                            ),
                                          ),
                                        )
                                      else ...[
                                        Text(
                                          'Seleziona le categorie compatibili:',
                                          style: TextStyle(
                                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                            fontSize: 11.5,
                                          ),
                                        ),
                                        const SizedBox(height: 8.0),
                                        Wrap(
                                          spacing: 8.0,
                                          runSpacing: 8.0,
                                          children: categoriesList.map((cat) {
                                            final isSelected = categorieCompatibili.contains(cat.reference.id) ||
                                                categorieCompatibili.contains(cat.name);
                                            return FilterChip(
                                              selected: isSelected,
                                              label: Text(cat.name),
                                              avatar: Icon(
                                                isSelected ? Icons.check_circle_rounded : Icons.category_rounded,
                                                size: 15.0,
                                                color: isSelected ? colorScheme.primary : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                                              ),
                                              backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                                              selectedColor: colorScheme.primary.withValues(alpha: 0.18),
                                              checkmarkColor: colorScheme.primary,
                                              labelStyle: TextStyle(
                                                fontSize: 12.0,
                                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                                color: isSelected ? colorScheme.primary : (isDark ? Colors.white : const Color(0xFF0F172A)),
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10.0),
                                                side: BorderSide(
                                                  color: isSelected
                                                      ? colorScheme.primary
                                                      : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                                                ),
                                              ),
                                              onSelected: (selected) {
                                                setDialogState(() {
                                                  if (selected) {
                                                    if (!categorieCompatibili.contains(cat.reference.id)) {
                                                      categorieCompatibili.add(cat.reference.id);
                                                    }
                                                    if (!categorieCompatibili.contains(cat.name)) {
                                                      categorieCompatibili.add(cat.name);
                                                    }
                                                  } else {
                                                    categorieCompatibili.remove(cat.reference.id);
                                                    categorieCompatibili.remove(cat.name);
                                                  }
                                                });
                                              },
                                            );
                                          }).toList(),
                                        ),
                                        if (categorieCompatibili.isEmpty)
                                          const Padding(
                                            padding: EdgeInsets.only(top: 8.0),
                                            child: Row(
                                              children: [
                                                Icon(Icons.info_outline_rounded, size: 14.0, color: Color(0xFFF59E0B)),
                                                SizedBox(width: 4.0),
                                                Text(
                                                  'Seleziona almeno una categoria per quest\'ingrediente.',
                                                  style: TextStyle(
                                                    fontSize: 11.0,
                                                    color: Color(0xFFD97706),
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                      ],
                                    ],
                                  ] else ...[
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.inventory_2_outlined,
                                            size: 14.0,
                                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                          ),
                                          const SizedBox(width: 6.0),
                                          Expanded(
                                            child: Text(
                                              'Uso interno magazzino / cucina (non apparirà come aggiunta per i clienti).',
                                              style: TextStyle(
                                                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                                fontSize: 11.5,
                                                fontStyle: FontStyle.italic,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(height: 14.0),

                            // Switch: In esaurimento
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF59E0B).withValues(alpha: isDark ? 0.12 : 0.08),
                                borderRadius: BorderRadius.circular(14.0),
                                border: Border.all(
                                  color: const Color(0xFFF59E0B).withValues(alpha: 0.30),
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
                                        const Text(
                                          'Sta per finire',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14.0,
                                            color: Color(0xFFFBBF24),
                                          ),
                                        ),
                                        Text(
                                          'Segnala questo ingrediente in esaurimento nella tua dispensa.',
                                          style: TextStyle(
                                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
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
                                color: const Color(0xFFEF4444).withValues(alpha: isDark ? 0.12 : 0.08),
                                borderRadius: BorderRadius.circular(14.0),
                                border: Border.all(
                                  color: const Color(0xFFEF4444).withValues(alpha: 0.30),
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
                                        const Text(
                                          'Ingrediente finito (Esaurito)',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14.0,
                                            color: Color(0xFFF87171),
                                          ),
                                        ),
                                        Text(
                                          'Nel menu cliente i piatti con questo ingrediente lo mostreranno sbarrato.',
                                          style: TextStyle(
                                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
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
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14.0),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.0)),
                                elevation: 0.0,
                              ),
                              onPressed: isSaving
                                  ? null
                                  : () async {
                                      if (!formKey.currentState!.validate()) {
                                        return;
                                      }
                                      final nome = nomeController.text.trim();
                                      if (nome.isEmpty) return;

                                      setDialogState(() => isSaving = true);
                                      try {
                                        final qta = double.tryParse(
                                                quantitaController.text
                                                    .trim()) ??
                                            0.0;
                                        final soglia = double.tryParse(
                                                sogliaController.text.trim()) ??
                                            0.0;
                                        final prezzoAggiunta =
                                            disponibileComeAggiunta
                                                ? (double.tryParse(
                                                        prezzoController.text
                                                            .trim()
                                                            .replaceAll(
                                                                ',', '.')) ??
                                                    0.0)
                                                : 0.0;

                                        final bool isTutteLeCat =
                                            !disponibileComeAggiunta ||
                                                tutteLeCategorie;
                                        final List<String> catsToSave =
                                            isTutteLeCat
                                                ? []
                                                : categorieCompatibili;

                                        // Auto calcola staPerFinire se la quantità è <= soglia e soglia > 0
                                        final isCritico = (soglia > 0 &&
                                                qta > 0 &&
                                                qta <= soglia) ||
                                            staPerFinire;

                                        if (isModifica) {
                                          await record.reference.update(
                                              createDispensaRecordData(
                                            nome: nome,
                                            quantita: qta,
                                            unitaMisura: unitaSelezionata,
                                            sogliaMinima: soglia,
                                            esaurito: esaurito,
                                            staPerFinire: isCritico,
                                            prezzo: prezzoAggiunta,
                                            disponibileComeAggiunta:
                                                disponibileComeAggiunta,
                                            tutteLeCategorie: isTutteLeCat,
                                            categorieCompatibili: catsToSave,
                                            dataAggiornamento: DateTime.now(),
                                          ));
                                        } else {
                                          await DispensaRecord.collection.add(
                                              createDispensaRecordData(
                                            nome: nome,
                                            quantita: qta,
                                            unitaMisura: unitaSelezionata,
                                            sogliaMinima: soglia,
                                            esaurito: esaurito,
                                            staPerFinire: isCritico,
                                            prezzo: prezzoAggiunta,
                                            disponibileComeAggiunta:
                                                disponibileComeAggiunta,
                                            tutteLeCategorie: isTutteLeCat,
                                            categorieCompatibili: catsToSave,
                                            proprietario: _targetRistoranteRef,
                                            dataAggiornamento: DateTime.now(),
                                          ));
                                        }

                                        if (sheetContext.mounted) {
                                          Navigator.pop(sheetContext);
                                        }
                                        if (!mounted) return;
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              isModifica
                                                  ? 'Ingrediente "$nome" aggiornato!'
                                                  : 'Ingrediente "$nome" aggiunto alla dispensa!',
                                            ),
                                            backgroundColor:
                                                const Color(0xFF10B981),
                                            duration:
                                                const Duration(seconds: 2),
                                          ),
                                        );
                                      } catch (e) {
                                        setDialogState(() => isSaving = false);
                                        if (!context.mounted) return;
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                'Errore durante il salvataggio: $e'),
                                            backgroundColor: colorScheme.error,
                                            duration:
                                                const Duration(seconds: 4),
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
    final isDark = theme.brightness == Brightness.dark;

    final confermato = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
          side: BorderSide(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          ),
        ),
        title: Text(
          'Eliminare ingrediente?',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
        content: Text(
          'Vuoi rimuovere "${record.nome}" dalla tua dispensa?',
          style: TextStyle(
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Annulla',
              style: TextStyle(
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: theme.colorScheme.onError,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
              elevation: 0,
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
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = colorScheme.primary;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
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
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
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
                        color: primaryColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.kitchen_rounded,
                        color: primaryColor,
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
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
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
                        color: primaryColor,
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
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17.0,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 6.0),
                        Text(
                          '${snapshot.error}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                            fontSize: 12.5,
                          ),
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
                      color: primaryColor,
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

              return LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = widget.embedded || constraints.maxWidth >= 760;
                  final horizontalPadding = isWide ? 28.0 : 16.0;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 1. CARDS KPI STATISTICHE RAPIDE
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          isWide ? 20.0 : 12.0,
                          horizontalPadding,
                          isWide ? 16.0 : 10.0,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildKpiCard(
                                title: 'Totali',
                                value: '$countTotale',
                                icon: Icons.inventory_2_outlined,
                                color: primaryColor,
                                bgColor: primaryColor.withValues(alpha: 0.12),
                                isDark: isDark,
                                isSelected: _model.filtroStato == 'tutti',
                                onTap: () => safeSetState(() {
                                  _model.filtroStato = 'tutti';
                                }),
                              ),
                            ),
                            SizedBox(width: isWide ? 14.0 : 8.0),
                            Expanded(
                              child: _buildKpiCard(
                                title: 'Disponibili',
                                value: '$countDisponibili',
                                icon: Icons.check_circle_rounded,
                                color: const Color(0xFF10B981),
                                bgColor: const Color(0xFF10B981).withValues(alpha: 0.12),
                                isDark: isDark,
                                isSelected: _model.filtroStato == 'disponibili',
                                onTap: () => safeSetState(() {
                                  _model.filtroStato =
                                      _model.filtroStato == 'disponibili' ? 'tutti' : 'disponibili';
                                }),
                              ),
                            ),
                            SizedBox(width: isWide ? 14.0 : 8.0),
                            Expanded(
                              child: _buildKpiCard(
                                title: 'In esaurimento',
                                value: '$countInEsaurimento',
                                icon: Icons.hourglass_bottom_rounded,
                                color: const Color(0xFFF59E0B),
                                bgColor: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                                isDark: isDark,
                                isSelected: _model.filtroStato == 'esaurimento',
                                onTap: () => safeSetState(() {
                                  _model.filtroStato =
                                      _model.filtroStato == 'esaurimento' ? 'tutti' : 'esaurimento';
                                }),
                              ),
                            ),
                            SizedBox(width: isWide ? 14.0 : 8.0),
                            Expanded(
                              child: _buildKpiCard(
                                title: 'Esauriti',
                                value: '$countEsauriti',
                                icon: Icons.block_rounded,
                                color: const Color(0xFFEF4444),
                                bgColor: const Color(0xFFEF4444).withValues(alpha: 0.12),
                                isDark: isDark,
                                isSelected: _model.filtroStato == 'esauriti',
                                onTap: () => safeSetState(() {
                                  _model.filtroStato =
                                      _model.filtroStato == 'esauriti' ? 'tutti' : 'esauriti';
                                }),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // 2. BARRA STRUMENTI: RICERCA, FILTRI CHIP & AGGIUNGI INGREDIENTE
                      if (isWide)
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                          child: Row(
                            children: [
                              // Campo Ricerca
                              Expanded(
                                flex: 3,
                                child: SizedBox(
                                  height: 42.0,
                                  child: TextField(
                                    controller: _model.searchController,
                                    focusNode: _model.searchFocusNode,
                                    style: TextStyle(
                                      fontSize: 13.5,
                                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'Cerca tra gli ingredienti...',
                                      hintStyle: TextStyle(
                                        fontSize: 13.0,
                                        color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                                      ),
                                      prefixIcon: Icon(
                                        Icons.search_rounded,
                                        size: 19.0,
                                        color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                                      ),
                                      suffixIcon: querySearch.isNotEmpty
                                          ? IconButton(
                                              icon: const Icon(Icons.clear_rounded, size: 16.0),
                                              onPressed: () {
                                                _model.searchController?.clear();
                                                safeSetState(() {});
                                              },
                                            )
                                          : null,
                                      filled: true,
                                      fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                                      contentPadding: EdgeInsets.zero,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10.0),
                                        borderSide: BorderSide(
                                          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10.0),
                                        borderSide: BorderSide(
                                          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10.0),
                                        borderSide: BorderSide(
                                          color: primaryColor,
                                          width: 1.5,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14.0),

                              // Filtri Chip Rapidi
                              _buildFilterChip('Tutti ($countTotale)', 'tutti', primaryColor, isDark),
                              const SizedBox(width: 8.0),
                              _buildFilterChip('Disponibili ($countDisponibili)', 'disponibili', const Color(0xFF10B981), isDark),
                              const SizedBox(width: 8.0),
                              _buildFilterChip('In esaurimento ($countInEsaurimento)', 'esaurimento', const Color(0xFFF59E0B), isDark),
                              const SizedBox(width: 8.0),
                              _buildFilterChip('Esauriti ($countEsauriti)', 'esauriti', const Color(0xFFEF4444), isDark),

                              const Spacer(),

                              // Bottone Aggiungi Ingrediente
                              ElevatedButton.icon(
                                onPressed: () => _apriDialogIngrediente(),
                                icon: const Icon(Icons.add_rounded, size: 18.0),
                                label: const Text(
                                  'Nuovo Ingrediente',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.0),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12.0),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                                  elevation: 0,
                                ),
                              ),
                            ],
                          ),
                        )
                      else ...[
                        // Mobile: Campo ricerca
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 4.0),
                          child: SizedBox(
                            height: 42.0,
                            child: TextField(
                              controller: _model.searchController,
                              focusNode: _model.searchFocusNode,
                              style: TextStyle(
                                fontSize: 13.5,
                                color: isDark ? Colors.white : const Color(0xFF0F172A),
                              ),
                              decoration: InputDecoration(
                                hintText: 'Cerca tra gli ingredienti...',
                                hintStyle: TextStyle(
                                  fontSize: 13.0,
                                  color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                                ),
                                prefixIcon: Icon(
                                  Icons.search_rounded,
                                  size: 19.0,
                                  color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                                ),
                                suffixIcon: querySearch.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.clear_rounded, size: 16.0),
                                        onPressed: () {
                                          _model.searchController?.clear();
                                          safeSetState(() {});
                                        },
                                      )
                                    : null,
                                filled: true,
                                fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                                contentPadding: EdgeInsets.zero,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: BorderSide(
                                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: BorderSide(
                                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: BorderSide(
                                    color: primaryColor,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Mobile: Chip filtri orizzontali
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 4.0),
                          child: Row(
                            children: [
                              _buildFilterChip('Tutti ($countTotale)', 'tutti', primaryColor, isDark),
                              const SizedBox(width: 8.0),
                              _buildFilterChip('Disponibili ($countDisponibili)', 'disponibili', const Color(0xFF10B981), isDark),
                              const SizedBox(width: 8.0),
                              _buildFilterChip('In esaurimento ($countInEsaurimento)', 'esaurimento', const Color(0xFFF59E0B), isDark),
                              const SizedBox(width: 8.0),
                              _buildFilterChip('Esauriti ($countEsauriti)', 'esauriti', const Color(0xFFEF4444), isDark),
                            ],
                          ),
                        ),
                      ],

                      SizedBox(height: isWide ? 14.0 : 8.0),

                      // 3. GRIGLIA O LISTA INGREDIENTI
                      Expanded(
                        child: tuttiIngredienti.isEmpty
                            ? _buildEmptyStateInitial(context, isDark, primaryColor)
                            : listaFiltrata.isEmpty
                                ? _buildEmptyStateNoResults(context, querySearch, isDark, primaryColor)
                                : isWide
                                    ? GridView.builder(
                                        padding: EdgeInsets.fromLTRB(
                                          horizontalPadding,
                                          4.0,
                                          horizontalPadding,
                                          28.0,
                                        ),
                                        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                                          maxCrossAxisExtent: 480.0,
                                          mainAxisExtent: 110.0,
                                          crossAxisSpacing: 14.0,
                                          mainAxisSpacing: 14.0,
                                        ),
                                        itemCount: listaFiltrata.length,
                                        itemBuilder: (context, index) {
                                          final item = listaFiltrata[index];
                                          return _buildIngredientCard(context, item, isDark, primaryColor);
                                        },
                                      )
                                    : ListView.separated(
                                        padding: EdgeInsets.fromLTRB(
                                          horizontalPadding,
                                          4.0,
                                          horizontalPadding,
                                          24.0,
                                        ),
                                        itemCount: listaFiltrata.length,
                                        separatorBuilder: (_, __) => const SizedBox(height: 10.0),
                                        itemBuilder: (context, index) {
                                          final item = listaFiltrata[index];
                                          return _buildIngredientCard(context, item, isDark, primaryColor);
                                        },
                                      ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color bgColor,
    required bool isDark,
    required bool isSelected,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(14.0),
          border: Border.all(
            color: isSelected
                ? color
                : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected ? color.withValues(alpha: 0.16) : Colors.black.withValues(alpha: 0.02),
              blurRadius: 8.0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 38.0,
              height: 38.0,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Icon(icon, color: color, size: 20.0),
            ),
            const SizedBox(width: 10.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 2.0),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
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

  Widget _buildFilterChip(
    String label,
    String value,
    Color activeColor,
    bool isDark,
  ) {
    final isSelected = _model.filtroStato == value;
    return InkWell(
      onTap: () {
        safeSetState(() {
          _model.filtroStato = isSelected && value != 'tutti' ? 'tutti' : value;
        });
      },
      borderRadius: BorderRadius.circular(20.0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor
              : (isDark ? const Color(0xFF1E293B) : Colors.white),
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(
            color: isSelected
                ? activeColor
                : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
            width: 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: activeColor.withValues(alpha: 0.25),
                    blurRadius: 6.0,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            fontSize: 12.0,
          ),
        ),
      ),
    );
  }

  Widget _buildIngredientCard(
    BuildContext context,
    DispensaRecord item,
    bool isDark,
    Color primaryColor,
  ) {
    final theme = Theme.of(context);
    final isEsaurito = item.esaurito;
    final isCritico = item.staPerFinire && !isEsaurito;

    Color badgeBg;
    Color badgeBorder;
    Color badgeText;
    String badgeLabel;
    IconData badgeIcon;

    if (isEsaurito) {
      badgeBg = const Color(0xFFEF4444).withValues(alpha: 0.12);
      badgeBorder = const Color(0xFFEF4444).withValues(alpha: 0.35);
      badgeText = isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626);
      badgeLabel = 'Esaurito';
      badgeIcon = Icons.block_rounded;
    } else if (isCritico) {
      badgeBg = const Color(0xFFF59E0B).withValues(alpha: 0.15);
      badgeBorder = const Color(0xFFF59E0B).withValues(alpha: 0.35);
      badgeText = isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706);
      badgeLabel = 'In esaurimento';
      badgeIcon = Icons.warning_amber_rounded;
    } else {
      badgeBg = const Color(0xFF10B981).withValues(alpha: 0.12);
      badgeBorder = const Color(0xFF10B981).withValues(alpha: 0.35);
      badgeText = isDark ? const Color(0xFF34D399) : const Color(0xFF059669);
      badgeLabel = 'Disponibile';
      badgeIcon = Icons.check_circle_outline_rounded;
    }

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(
          color: isEsaurito
              ? const Color(0xFFEF4444).withValues(alpha: 0.35)
              : isCritico
                  ? const Color(0xFFF59E0B).withValues(alpha: 0.40)
                  : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
          width: isEsaurito || isCritico ? 1.2 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
            blurRadius: 8.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icona Ingrediente
          Container(
            width: 42.0,
            height: 42.0,
            decoration: BoxDecoration(
              color: isEsaurito
                  ? const Color(0xFFEF4444).withValues(alpha: 0.12)
                  : isCritico
                      ? const Color(0xFFF59E0B).withValues(alpha: 0.12)
                      : primaryColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12.0),
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.restaurant_menu_rounded,
              color: isEsaurito
                  ? const Color(0xFFEF4444)
                  : isCritico
                      ? const Color(0xFFF59E0B)
                      : primaryColor,
              size: 20.0,
            ),
          ),
          const SizedBox(width: 12.0),

          // Nome e Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item.nome,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15.0,
                    letterSpacing: -0.2,
                    decoration: isEsaurito ? TextDecoration.lineThrough : null,
                    decorationColor: const Color(0xFFEF4444),
                    color: isEsaurito
                        ? (isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8))
                        : (isDark ? Colors.white : const Color(0xFF0F172A)),
                  ),
                ),
                const SizedBox(height: 5.0),
                Wrap(
                  spacing: 6.0,
                  runSpacing: 4.0,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (item.quantita > 0)
                      Text(
                        'Giacenza: ${item.quantita % 1 == 0 ? item.quantita.toInt() : item.quantita} ${item.unitaMisura}',
                        style: TextStyle(
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                          fontSize: 11.5,
                        ),
                      ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7.0, vertical: 2.0),
                      decoration: BoxDecoration(
                        color: badgeBg,
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(color: badgeBorder, width: 0.8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(badgeIcon, size: 11.0, color: badgeText),
                          const SizedBox(width: 3.5),
                          Text(
                            badgeLabel,
                            style: TextStyle(
                              color: badgeText,
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (item.disponibileComeAggiunta) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7.0, vertical: 2.0),
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10.0),
                          border: Border.all(
                            color: primaryColor.withValues(alpha: 0.30),
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.add_shopping_cart_rounded, size: 10.5, color: primaryColor),
                            const SizedBox(width: 3.5),
                            Text(
                              item.prezzo > 0
                                  ? 'Aggiunta (+€${item.prezzo % 1 == 0 ? item.prezzo.toInt().toString() : item.prezzo.toStringAsFixed(2)})'
                                  : 'Aggiunta (gratis)',
                              style: TextStyle(
                                color: primaryColor,
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (!item.tutteLeCategorie && item.categorieCompatibili.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(10.0),
                            border: Border.all(
                              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                              width: 0.8,
                            ),
                          ),
                          child: Text(
                            'Cat. specifiche',
                            style: TextStyle(
                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                              fontSize: 10.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ] else ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6.5, vertical: 2.0),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(10.0),
                          border: Border.all(
                            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.inventory_2_outlined,
                              size: 10.5,
                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                            ),
                            const SizedBox(width: 3.0),
                            Text(
                              'Solo magazzino',
                              style: TextStyle(
                                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                fontSize: 10.0,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
              size: 22.0,
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
            icon: Icon(
              Icons.more_vert_rounded,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
              side: BorderSide(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              ),
            ),
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
                    Icon(Icons.edit_rounded, size: 18.0, color: primaryColor),
                    const SizedBox(width: 8.0),
                    Text(
                      'Modifica',
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'esaurimento',
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, size: 18.0, color: Color(0xFFF59E0B)),
                    const SizedBox(width: 8.0),
                    Text(
                      item.staPerFinire ? 'Rimuovi avviso scorta' : 'Segna in esaurimento',
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              ),
              const PopupMenuDivider(
                height: 1.0,
              ),
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
    );
  }

  Widget _buildEmptyStateInitial(BuildContext context, bool isDark, Color primaryColor) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 440.0),
          padding: const EdgeInsets.all(28.0),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(20.0),
            border: Border.all(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
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
                  color: primaryColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.kitchen_rounded,
                  color: primaryColor,
                  size: 38.0,
                ),
              ),
              const SizedBox(height: 18.0),
              Text(
                'La tua dispensa è vuota',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                  letterSpacing: -0.3,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8.0),
              Text(
                'Aggiungi gli ingredienti del tuo locale per gestire le giacenze, velocizzare la creazione dei piatti con il completamento automatico e segnalare gli ingredienti finiti.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  fontSize: 13.5,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 22.0),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
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

  Widget _buildEmptyStateNoResults(BuildContext context, String query, bool isDark, Color primaryColor) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 48.0,
              color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
            ),
            const SizedBox(height: 12.0),
            Text(
              'Nessun ingrediente trovato',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17.0,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 4.0),
            Text(
              'Nessun risultato corrisponde al filtro attuale.',
              style: TextStyle(
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                fontSize: 13.0,
              ),
            ),
            const SizedBox(height: 16.0),
            OutlinedButton.icon(
              onPressed: () => _apriDialogIngrediente(),
              icon: const Icon(Icons.add_rounded, size: 18.0),
              label: Text('Aggiungi "$query" alla dispensa'),
              style: OutlinedButton.styleFrom(
                foregroundColor: primaryColor,
                side: BorderSide(color: primaryColor.withValues(alpha: 0.5)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
