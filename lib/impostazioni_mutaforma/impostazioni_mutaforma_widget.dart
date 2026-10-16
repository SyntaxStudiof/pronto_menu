import 'package:flutter/material.dart';

import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/services/mutaforma_service.dart';
import 'impostazioni_mutaforma_model.dart';

export 'impostazioni_mutaforma_model.dart';

class ImpostazioniMutaformaWidget extends StatefulWidget {
  const ImpostazioniMutaformaWidget({super.key});

  static String routeName = 'impostazioniMutaforma';
  static String routePath = '/impostazioniMutaforma';

  @override
  State<ImpostazioniMutaformaWidget> createState() =>
      _ImpostazioniMutaformaWidgetState();
}

class _ImpostazioniMutaformaWidgetState
    extends State<ImpostazioniMutaformaWidget> {
  late ImpostazioniMutaformaModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ImpostazioniMutaformaModel());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  void _apriEditorFascia(
    BuildContext context, {
    FasciaMutaforma? fasciaEsistente,
    required List<FasciaMutaforma> tutteFasce,
    required List<CategoriesRecord> tutteCategorie,
  }) {
    final theme = Theme.of(context);
    final isModifica = fasciaEsistente != null;

    final nomeController =
        TextEditingController(text: fasciaEsistente?.nome ?? '');
    String orarioInizio = fasciaEsistente?.orarioInizio ?? '12:00';
    String orarioFine = fasciaEsistente?.orarioFine ?? '15:00';
    List<int> giorniSelezionati = fasciaEsistente != null
        ? List<int>.from(fasciaEsistente.giorni)
        : [1, 2, 3, 4, 5, 6, 7];
    Set<String> categorieSelezionate = fasciaEsistente != null
        ? Set<String>.from(fasciaEsistente.categoriaIds)
        : tutteCategorie.map((c) => c.reference.id).toSet();

    final suggerimenti = [
      'Colazione',
      'Pranzo',
      'Aperitivo',
      'Cena',
      'After Dinner',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            return Container(
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24.0),
                  topRight: Radius.circular(24.0),
                ),
              ),
              padding: EdgeInsets.only(
                left: 20.0,
                right: 20.0,
                top: 16.0,
                bottom: MediaQuery.of(modalContext).viewInsets.bottom + 24.0,
              ),
              child: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Handle bar
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
                      const SizedBox(height: 18.0),

                      // Header
                      Row(
                        children: [
                          Container(
                            width: 36.0,
                            height: 36.0,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary
                                  .withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              isModifica
                                  ? Icons.edit_rounded
                                  : Icons.add_rounded,
                              color: theme.colorScheme.primary,
                              size: 20.0,
                            ),
                          ),
                          const SizedBox(width: 12.0),
                          Text(
                            isModifica
                                ? 'Modifica Menù / Fascia'
                                : 'Nuovo Menù Mutaforma',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20.0),

                      // Nome del Menù
                      Text(
                        'Nome Menù',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      TextFormField(
                        controller: nomeController,
                        decoration: InputDecoration(
                          hintText: 'Es. Menù Pranzo, Colazioni, Aperitivo...',
                          filled: true,
                          fillColor: theme.cardColor,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 14.0),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide(
                              color: theme.dividerColor.withValues(alpha: 0.2),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide(
                              color: theme.dividerColor.withValues(alpha: 0.2),
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
                      ),
                      const SizedBox(height: 8.0),

                      // Suggerimenti rapidi
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 6.0,
                        children: suggerimenti.map((sug) {
                          return InkWell(
                            onTap: () {
                              nomeController.text = sug;
                              setModalState(() {});
                            },
                            borderRadius: BorderRadius.circular(16.0),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10.0, vertical: 5.0),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary
                                    .withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(16.0),
                              ),
                              child: Text(
                                sug,
                                style: TextStyle(
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20.0),

                      // Orari Inizio e Fine
                      Text(
                        'Orario di Validità',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTimeButton(
                              context: modalContext,
                              theme: theme,
                              label: 'Dalle ore',
                              timeStr: orarioInizio,
                              onTimePicked: (newTime) {
                                setModalState(() {
                                  orarioInizio = newTime;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 12.0),
                          Expanded(
                            child: _buildTimeButton(
                              context: modalContext,
                              theme: theme,
                              label: 'Alle ore',
                              timeStr: orarioFine,
                              onTimePicked: (newTime) {
                                setModalState(() {
                                  orarioFine = newTime;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20.0),

                      // Giorni della Settimana
                      Text(
                        'Giorni Attivi',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildDayChip(1, 'L', giorniSelezionati, theme, () {
                            setModalState(() => _toggleDay(1, giorniSelezionati));
                          }),
                          _buildDayChip(2, 'M', giorniSelezionati, theme, () {
                            setModalState(() => _toggleDay(2, giorniSelezionati));
                          }),
                          _buildDayChip(3, 'M', giorniSelezionati, theme, () {
                            setModalState(() => _toggleDay(3, giorniSelezionati));
                          }),
                          _buildDayChip(4, 'G', giorniSelezionati, theme, () {
                            setModalState(() => _toggleDay(4, giorniSelezionati));
                          }),
                          _buildDayChip(5, 'V', giorniSelezionati, theme, () {
                            setModalState(() => _toggleDay(5, giorniSelezionati));
                          }),
                          _buildDayChip(6, 'S', giorniSelezionati, theme, () {
                            setModalState(() => _toggleDay(6, giorniSelezionati));
                          }),
                          _buildDayChip(7, 'D', giorniSelezionati, theme, () {
                            setModalState(() => _toggleDay(7, giorniSelezionati));
                          }),
                        ],
                      ),
                      const SizedBox(height: 22.0),

                      // Categorie Associate
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Categorie da mostrare (${categorieSelezionate.length}/${tutteCategorie.length})',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              setModalState(() {
                                if (categorieSelezionate.length ==
                                    tutteCategorie.length) {
                                  categorieSelezionate.clear();
                                } else {
                                  categorieSelezionate = tutteCategorie
                                      .map((c) => c.reference.id)
                                      .toSet();
                                }
                              });
                            },
                            child: Text(
                              categorieSelezionate.length == tutteCategorie.length
                                  ? 'Deseleziona tutte'
                                  : 'Seleziona tutte',
                              style: TextStyle(
                                fontSize: 13.0,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6.0),

                      if (tutteCategorie.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Text(
                            'Nessuna categoria creata nel menu.',
                            style: TextStyle(color: theme.hintColor),
                          ),
                        )
                      else
                        Container(
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            borderRadius: BorderRadius.circular(14.0),
                            border: Border.all(
                              color: theme.dividerColor.withValues(alpha: 0.15),
                            ),
                          ),
                          child: Column(
                            children: tutteCategorie.map((cat) {
                              final catId = cat.reference.id;
                              final isSelected =
                                  categorieSelezionate.contains(catId);
                              return CheckboxListTile(
                                value: isSelected,
                                activeColor: theme.colorScheme.primary,
                                checkColor: theme.colorScheme.onPrimary,
                                title: Text(
                                  cat.name,
                                  style: TextStyle(
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                    fontSize: 14.5,
                                  ),
                                ),
                                dense: true,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                onChanged: (val) {
                                  setModalState(() {
                                    if (val == true) {
                                      categorieSelezionate.add(catId);
                                    } else {
                                      categorieSelezionate.remove(catId);
                                    }
                                  });
                                },
                              );
                            }).toList(),
                          ),
                        ),
                      const SizedBox(height: 26.0),

                      // Tasto Salva
                      SizedBox(
                        width: double.infinity,
                        height: 50.0,
                        child: ElevatedButton(
                          onPressed: () async {
                            final nome = nomeController.text.trim();
                            if (nome.isEmpty) {
                              ScaffoldMessenger.of(modalContext).showSnackBar(
                                const SnackBar(
                                  content: Text('Inserisci un nome per questo menù'),
                                  backgroundColor: Colors.redAccent,
                                ),
                              );
                              return;
                            }
                            if (giorniSelezionati.isEmpty) {
                              ScaffoldMessenger.of(modalContext).showSnackBar(
                                const SnackBar(
                                  content: Text('Seleziona almeno un giorno attivo'),
                                  backgroundColor: Colors.redAccent,
                                ),
                              );
                              return;
                            }

                            final nuovaFascia = FasciaMutaforma(
                              id: fasciaEsistente?.id ??
                                  DateTime.now()
                                      .millisecondsSinceEpoch
                                      .toString(),
                              nome: nome,
                              orarioInizio: orarioInizio,
                              orarioFine: orarioFine,
                              giorni: giorniSelezionati,
                              categoriaIds: categorieSelezionate.toList(),
                            );

                            final listaAggiornata =
                                List<FasciaMutaforma>.from(tutteFasce);
                            if (isModifica) {
                              final idx = listaAggiornata
                                  .indexWhere((f) => f.id == fasciaEsistente.id);
                              if (idx != -1) {
                                listaAggiornata[idx] = nuovaFascia;
                              }
                            } else {
                              listaAggiornata.add(nuovaFascia);
                            }

                            if (currentUserReference != null) {
                              await MutaformaService.salvaFasce(
                                userRef: currentUserReference!,
                                fasce: listaAggiornata,
                              );
                            }

                            if (modalContext.mounted) {
                              Navigator.pop(modalContext);
                            }
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(isModifica
                                      ? 'Menù aggiornato con successo'
                                      : 'Nuovo menù creato con successo'),
                                  backgroundColor: theme.colorScheme.primary,
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                            elevation: 0.0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14.0),
                            ),
                          ),
                          child: Text(
                            isModifica ? 'Salva Modifiche' : 'Crea Menù',
                            style: const TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _toggleDay(int day, List<int> list) {
    if (list.contains(day)) {
      if (list.length > 1) {
        list.remove(day);
      }
    } else {
      list.add(day);
      list.sort();
    }
  }

  Widget _buildTimeButton({
    required BuildContext context,
    required ThemeData theme,
    required String label,
    required String timeStr,
    required Function(String) onTimePicked,
  }) {
    return InkWell(
      onTap: () async {
        final parts = timeStr.split(':');
        final initTime = TimeOfDay(
          hour: parts.isNotEmpty ? (int.tryParse(parts[0]) ?? 12) : 12,
          minute: parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0,
        );

        final picked = await showTimePicker(
          context: context,
          initialTime: initTime,
          builder: (context, child) {
            return MediaQuery(
              data:
                  MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
              child: child!,
            );
          },
        );

        if (picked != null) {
          final h = picked.hour.toString().padLeft(2, '0');
          final m = picked.minute.toString().padLeft(2, '0');
          onTimePicked('$h:$m');
        }
      },
      borderRadius: BorderRadius.circular(12.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: theme.dividerColor.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12.0,
                color: theme.hintColor,
              ),
            ),
            const SizedBox(height: 4.0),
            Row(
              children: [
                Icon(
                  Icons.access_time_rounded,
                  size: 18.0,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8.0),
                Text(
                  timeStr,
                  style: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayChip(
    int day,
    String label,
    List<int> selectedDays,
    ThemeData theme,
    VoidCallback onTap,
  ) {
    final isSelected = selectedDays.contains(day);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.0),
      child: Container(
        width: 38.0,
        height: 38.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected
              ? theme.colorScheme.primary
              : theme.cardColor,
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.dividerColor.withValues(alpha: 0.25),
            width: 1.0,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13.0,
            color: isSelected
                ? theme.colorScheme.onPrimary
                : theme.textTheme.bodyMedium?.color,
          ),
        ),
      ),
    );
  }

  Future<void> _confermaEliminazione(
    BuildContext context,
    FasciaMutaforma fascia,
    List<FasciaMutaforma> tutteFasce,
  ) async {
    final theme = Theme.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          title: Row(
            children: [
              Icon(Icons.delete_outline_rounded,
                  color: theme.colorScheme.error, size: 24.0),
              const SizedBox(width: 10.0),
              const Text('Elimina Menù'),
            ],
          ),
          content: Text(
            'Sei sicuro di voler eliminare "${fascia.nome}"? Le categorie assegnate rimarranno comunque nel tuo menu.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Annulla'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
                foregroundColor: Colors.white,
                elevation: 0.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              child: const Text('Elimina'),
            ),
          ],
        );
      },
    );

    if (confirm == true && currentUserReference != null) {
      final nuovaLista =
          tutteFasce.where((f) => f.id != fascia.id).toList();
      await MutaformaService.salvaFasce(
        userRef: currentUserReference!,
        fasce: nuovaLista,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Menù eliminato'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return StreamBuilder<UsersRecord>(
      stream: UsersRecord.getDocument(currentUserReference!),
      builder: (context, userSnapshot) {
        if (!userSnapshot.hasData) {
          return Scaffold(
            backgroundColor: colorScheme.surfaceContainerLowest,
            body: Center(
              child: CircularProgressIndicator(
                color: colorScheme.primary,
              ),
            ),
          );
        }

        final userRecord = userSnapshot.data!;
        final bool mutaformaAttivo = userRecord.menuMutaformaAttivo;
        final List<FasciaMutaforma> fasce =
            MutaformaService.decodeFasce(userRecord.fasceMutaforma);

        return StreamBuilder<List<CategoriesRecord>>(
          stream: queryCategoriesRecord(
            queryBuilder: (q) => q
                .where('proprietario', isEqualTo: currentUserReference)
                .orderBy('ordine_categoria'),
          ),
          builder: (context, catSnapshot) {
            final tutteCategorie = catSnapshot.data ?? [];

            return Scaffold(
              key: scaffoldKey,
              backgroundColor: colorScheme.surfaceContainerLowest,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0.0,
                scrolledUnderElevation: 0.0,
                centerTitle: true,
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
                        Icons.auto_awesome_rounded,
                        color: colorScheme.primary,
                        size: 20.0,
                      ),
                    ),
                    const SizedBox(width: 10.0),
                    Text(
                      'Menù Mutaforma',
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
                  FlutterFlowIconButton(
                    borderColor: Colors.transparent,
                    borderRadius: 24.0,
                    borderWidth: 1.0,
                    buttonSize: 40.0,
                    icon: Icon(
                      Icons.add_rounded,
                      color: colorScheme.primary,
                      size: 26.0,
                    ),
                    onPressed: () {
                      _apriEditorFascia(
                        context,
                        fasciaEsistente: null,
                        tutteFasce: fasce,
                        tutteCategorie: tutteCategorie,
                      );
                    },
                  ),
                ],
              ),
              body: SafeArea(
                top: false,
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18.0, vertical: 14.0),
                  children: [
                    // Banner esplicativo
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(16.0),
                        border: Border.all(
                          color: colorScheme.primary.withValues(alpha: 0.18),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.auto_awesome_rounded,
                            color: colorScheme.primary,
                            size: 24.0,
                          ),
                          const SizedBox(width: 12.0),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Menù Intelligente ad Orari',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15.0,
                                    color: colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(height: 4.0),
                                Text(
                                  'Crea fasce orarie a mano libera (es. Colazione, Pranzo, Aperitivo, Cena). Durante ciascun orario, i clienti vedranno solo le categorie assegnate. Negli orari non coperti, il servizio risulterà in pausa.',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    height: 1.4,
                                    color: colorScheme.onSurface
                                        .withValues(alpha: 0.8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18.0),

                    // Card Switch Attivazione Principale
                    Container(
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(16.0),
                        border: Border.all(
                          color: theme.dividerColor.withValues(alpha: 0.15),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 12.0),
                      child: Row(
                        children: [
                          Container(
                            width: 40.0,
                            height: 40.0,
                            decoration: BoxDecoration(
                              color: mutaformaAttivo
                                  ? colorScheme.primary
                                      .withValues(alpha: 0.15)
                                  : theme.dividerColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.schedule_rounded,
                              color: mutaformaAttivo
                                  ? colorScheme.primary
                                  : theme.hintColor,
                              size: 22.0,
                            ),
                          ),
                          const SizedBox(width: 14.0),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Attiva Menù Mutaforma',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15.5,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 2.0),
                                Text(
                                  mutaformaAttivo
                                      ? 'Funzionalità attiva: il menu si adatta all\'orario'
                                      : 'Disattivato: i clienti vedono tutte le categorie',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    color: theme.hintColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: mutaformaAttivo,
                            activeThumbColor: colorScheme.primary,
                            onChanged: (val) async {
                              await MutaformaService.toggleMutaforma(
                                userRef: currentUserReference!,
                                attivo: val,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24.0),

                    // Titolo Sezione Fasce
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'I TUOI MENÙ PROGRAMMATI (${fasce.length})',
                          style: TextStyle(
                            fontSize: 12.0,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.6,
                            color: theme.hintColor,
                          ),
                        ),
                        if (fasce.isNotEmpty)
                          TextButton.icon(
                            onPressed: () {
                              _apriEditorFascia(
                                context,
                                fasciaEsistente: null,
                                tutteFasce: fasce,
                                tutteCategorie: tutteCategorie,
                              );
                            },
                            icon: const Icon(Icons.add_rounded, size: 18.0),
                            label: const Text('Aggiungi'),
                            style: TextButton.styleFrom(
                              foregroundColor: colorScheme.primary,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8.0),

                    // Lista delle Fasce Orarie
                    if (fasce.isEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 36.0),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(18.0),
                          border: Border.all(
                            color: theme.dividerColor.withValues(alpha: 0.15),
                          ),
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 64.0,
                              height: 64.0,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: colorScheme.primary
                                    .withValues(alpha: 0.1),
                              ),
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.hourglass_empty_rounded,
                                size: 32.0,
                                color: colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 16.0),
                            Text(
                              'Nessun menù configurato',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6.0),
                            Text(
                              'Aggiungi la tua prima fascia oraria (ad esempio "Pranzo dalle 12:00 alle 15:00") e assegna le relative categorie.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13.0,
                                color: theme.hintColor,
                              ),
                            ),
                            const SizedBox(height: 18.0),
                            ElevatedButton.icon(
                              onPressed: () {
                                _apriEditorFascia(
                                  context,
                                  fasciaEsistente: null,
                                  tutteFasce: fasce,
                                  tutteCategorie: tutteCategorie,
                                );
                              },
                              icon: const Icon(Icons.add_rounded, size: 18.0),
                              label: const Text('Crea Primo Menù'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colorScheme.primary,
                                foregroundColor: colorScheme.onPrimary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      ...fasce.map((f) {
                        final bool isAttivaOra = f.isAttivaOra();
                        final nomiCategorie = tutteCategorie
                            .where((c) => f.categoriaIds.contains(c.reference.id))
                            .map((c) => c.name)
                            .toList();

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12.0),
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            borderRadius: BorderRadius.circular(16.0),
                            border: Border.all(
                              color: isAttivaOra
                                  ? colorScheme.primary
                                  : theme.dividerColor.withValues(alpha: 0.15),
                              width: isAttivaOra ? 1.5 : 1.0,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 8.0,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Top row: Nome + Status badge
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Text(
                                            f.nome,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16.5,
                                            ),
                                          ),
                                          const SizedBox(width: 8.0),
                                          if (isAttivaOra)
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 8.0,
                                                  vertical: 3.0),
                                              decoration: BoxDecoration(
                                                color: Colors.green
                                                    .withValues(alpha: 0.15),
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: const [
                                                  Text(
                                                    '● ',
                                                    style: TextStyle(
                                                      color: Colors.green,
                                                      fontSize: 11.0,
                                                    ),
                                                  ),
                                                  Text(
                                                    'ATTIVO ORA',
                                                    style: TextStyle(
                                                      fontSize: 10.5,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.green,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),

                                    // Azioni Modifica / Elimina
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit_rounded,
                                              size: 20.0),
                                          color: theme.hintColor,
                                          tooltip: 'Modifica',
                                          onPressed: () {
                                            _apriEditorFascia(
                                              context,
                                              fasciaEsistente: f,
                                              tutteFasce: fasce,
                                              tutteCategorie: tutteCategorie,
                                            );
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                              Icons.delete_outline_rounded,
                                              size: 20.0),
                                          color: colorScheme.error,
                                          tooltip: 'Elimina',
                                          onPressed: () {
                                            _confermaEliminazione(
                                                context, f, fasce);
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8.0),

                                // Dettagli: Orario e Giorni
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10.0, vertical: 4.0),
                                      decoration: BoxDecoration(
                                        color: colorScheme.primary
                                            .withValues(alpha: 0.08),
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.access_time_rounded,
                                            size: 14.0,
                                            color: colorScheme.primary,
                                          ),
                                          const SizedBox(width: 5.0),
                                          Text(
                                            '${f.orarioInizio} - ${f.orarioFine}',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13.0,
                                              color: colorScheme.primary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8.0),
                                    Text(
                                      f.getGiorniLabel(),
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        color: theme.hintColor,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10.0),

                                // Categorie incluse
                                Text(
                                  nomiCategorie.isEmpty
                                      ? 'Nessuna categoria assegnata'
                                      : 'Categorie visibili: ${nomiCategorie.join(', ')}',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    color: colorScheme.onSurface
                                        .withValues(alpha: 0.75),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
