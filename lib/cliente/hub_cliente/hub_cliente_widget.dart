import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

import '/backend/backend.dart';
import '/cliente/giochi/tris_game_widget.dart';
import '/cliente/giochi/quiz_game_widget.dart';
import '/cliente/jukebox_modal/jukebox_modal_widget.dart';
import '/cliente/menu_cliente/menu_cliente_widget.dart';
import '/cliente/menu_disattivati/menu_disattivati_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/services/mutaforma_service.dart';
import '/services/translation_service.dart';
import 'hub_cliente_model.dart';

export 'hub_cliente_model.dart';

class HubClienteWidget extends StatefulWidget {
  const HubClienteWidget({
    super.key,
    required this.ristoranteRef,
    this.isAnteprima = false,
  });

  final DocumentReference? ristoranteRef;
  final bool isAnteprima;

  static String routeName = 'HubCliente';
  static String routePath = '/hubCliente';

  @override
  State<HubClienteWidget> createState() => _HubClienteWidgetState();
}

class _HubClienteWidgetState extends State<HubClienteWidget> {
  late HubClienteModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  String _currentLang = 'it';

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HubClienteModel());

    TranslationService.getSavedLanguage().then((saved) {
      if (mounted && saved != _currentLang) {
        setState(() => _currentLang = saved);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  void _mostraSelettoreLingua(ThemeData theme) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24.0)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40.0,
                  height: 4.0,
                  decoration: BoxDecoration(
                    color: theme.dividerColor.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2.0),
                  ),
                ),
              ),
              const SizedBox(height: 18.0),
              Text(
                'Seleziona la tua lingua / Select language',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 14.0),
              ...TranslationService.supportedLanguages.map((lang) {
                final isSelected = lang.code == _currentLang;
                return ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  tileColor: isSelected
                      ? theme.colorScheme.primary.withValues(alpha: 0.12)
                      : Colors.transparent,
                  leading: Text(
                    lang.flag,
                    style: const TextStyle(fontSize: 26.0),
                  ),
                  title: Text(
                    lang.label,
                    style: TextStyle(
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  trailing: isSelected
                      ? Icon(Icons.check_circle_rounded,
                          color: theme.colorScheme.primary, size: 22.0)
                      : null,
                  onTap: () async {
                    Navigator.pop(ctx);
                    await TranslationService.saveLanguage(lang.code);
                    if (mounted) {
                      setState(() => _currentLang = lang.code);
                    }
                  },
                );
              }),
              const SizedBox(height: 8.0),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return StreamBuilder<UsersRecord>(
      stream: UsersRecord.getDocument(widget.ristoranteRef!),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            body: Center(
              child: SpinKitPulse(
                color: colorScheme.primary,
                size: 50.0,
              ),
            ),
          );
        }

        final userRecord = snapshot.data!;
        final bool mutaformaAttivo = userRecord.menuMutaformaAttivo;
        final List<FasciaMutaforma> fasce =
            MutaformaService.decodeFasce(userRecord.fasceMutaforma);
        final FasciaMutaforma? fasciaAttiva =
            mutaformaAttivo && fasce.isNotEmpty
                ? MutaformaService.getFasciaAttiva(fasce)
                : null;
        final bool mutaformaInPausa =
            mutaformaAttivo && fasce.isNotEmpty && fasciaAttiva == null;
        final FasciaMutaforma? prossimaFascia =
            mutaformaInPausa ? MutaformaService.getProssimaFascia(fasce) : null;

        // Menù disattivati visibili solo se l'impostazione del ristoratore è attiva
        final List<FasciaMutaforma> fasceDisattivate = mutaformaAttivo
            ? fasce.where((f) => f.id != fasciaAttiva?.id).toList()
            : [];
        final bool mostraOpzioneDisattivati =
            mutaformaAttivo &&
            userRecord.mostraMenuDisattivati &&
            fasceDisattivate.isNotEmpty;

        return Scaffold(
          key: scaffoldKey,
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor:
                theme.appBarTheme.backgroundColor ?? theme.cardColor,
            automaticallyImplyLeading: false,
            elevation: 1.0,
            centerTitle: true,
            leadingWidth: context.canPop() ? 134.0 : 92.0,
            leading: Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsetsDirectional.only(start: 8.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (context.canPop())
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                            minWidth: 32.0, minHeight: 32.0),
                        icon: Icon(
                          Icons.arrow_back_rounded,
                          size: 22.0,
                          color: theme.colorScheme.onSurface,
                        ),
                        onPressed: () => context.safePop(),
                      ),
                    InkWell(
                      onTap: () => _mostraSelettoreLingua(theme),
                      borderRadius: BorderRadius.circular(16.0),
                      child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 5.0),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16.0),
                      border: Border.all(
                        color: colorScheme.primary.withValues(alpha: 0.28),
                        width: 1.0,
                      ),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            TranslationService.supportedLanguages
                                .firstWhere((l) => l.code == _currentLang,
                                    orElse: () =>
                                        TranslationService.supportedLanguages.first)
                                .flag,
                            style: const TextStyle(fontSize: 16.0),
                          ),
                          const SizedBox(width: 4.0),
                          Text(
                            _currentLang.toUpperCase(),
                            style: TextStyle(
                              fontSize: 12.0,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                          ),
                          Icon(
                            Icons.arrow_drop_down_rounded,
                            size: 16.0,
                            color: colorScheme.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 34.0,
                  height: 34.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: colorScheme.primary.withValues(alpha: 0.35),
                      width: 1.5,
                    ),
                  ),
                  child: ClipOval(
                    child: Image.network(
                      valueOrDefault<String>(
                        userRecord.photoUrl,
                        'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/pronto-menu-f0och1/assets/i4ccmvv80eni/IMG_8006.png',
                      ),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.restaurant_rounded,
                        color: colorScheme.primary,
                        size: 18.0,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10.0),
                Flexible(
                  child: Text(
                    userRecord.displayName.isNotEmpty
                        ? userRecord.displayName
                        : 'ProntoMenu',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontSize: 18.5,
                      fontWeight: FontWeight.w600,
                      color: theme.appBarTheme.foregroundColor ??
                          colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
            actions: const [
              SizedBox(width: 48.0),
            ],
          ),
          body: SafeArea(
            top: true,
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Scheda Hero Benvenuto del Locale
                  Container(
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(24.0),
                      border: Border.all(
                        color: theme.dividerColor.withValues(alpha: 0.12),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 18.0,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 72.0,
                          height: 72.0,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: colorScheme.primary.withValues(alpha: 0.35),
                              width: 2.0,
                            ),
                          ),
                          child: ClipOval(
                            child: Image.network(
                              valueOrDefault<String>(
                                userRecord.photoUrl,
                                'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/pronto-menu-f0och1/assets/i4ccmvv80eni/IMG_8006.png',
                              ),
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Icon(
                                Icons.restaurant_rounded,
                                color: colorScheme.primary,
                                size: 36.0,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14.0),
                        Text(
                          userRecord.displayName.isNotEmpty
                              ? userRecord.displayName
                              : 'Benvenuto al Ristorante',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 22.0,
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          'Cosa desideri fare oggi?',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.hintColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24.0),

                  // OPZIONE 1: MENÙ
                  _buildHubOptionCard(
                    theme: theme,
                    icon: Icons.restaurant_menu_rounded,
                    iconColor: colorScheme.primary,
                    iconBgColor: colorScheme.primary.withValues(alpha: 0.12),
                    title: 'Menù',
                    subTitleName: mutaformaAttivo && fasciaAttiva != null
                        ? fasciaAttiva.nome
                        : (mutaformaInPausa
                            ? (prossimaFascia != null
                                ? 'In pausa • Prossimo: ${prossimaFascia.nome}'
                                : 'In pausa')
                            : null),
                    subTitleNameColor: mutaformaInPausa
                        ? Colors.orange.shade800
                        : colorScheme.primary,
                    subtitle: fasciaAttiva != null
                        ? 'Disponibile ora per ordinare al tavolo'
                        : (mutaformaInPausa
                            ? 'Consulta il menù in pausa o verifica orari'
                            : 'Esplora i nostri piatti ed effettua l\'ordine'),
                    onTap: () {
                      context.pushNamed(
                        MenuClienteWidget.routeName,
                        queryParameters: {
                          'ristoranteRef': serializeParam(
                            widget.ristoranteRef,
                            ParamType.DocumentReference,
                          ),
                          'isAnteprima': serializeParam(
                            true,
                            ParamType.bool,
                          ),
                        }.withoutNulls,
                      );
                    },
                  ),
                  const SizedBox(height: 16.0),

                  // OPZIONE 2: ALTRI MENÙ / FUORI ORARIO (Se abilitato)
                  if (mostraOpzioneDisattivati) ...[
                    _buildHubOptionCard(
                      theme: theme,
                      icon: Icons.auto_awesome_motion_rounded,
                      iconColor: const Color(0xFF673AB7),
                      iconBgColor:
                          const Color(0xFF673AB7).withValues(alpha: 0.12),
                      title: 'Altri Menù',
                      subtitle:
                          'Consulta le proposte degli altri orari (colazione, pranzo, cena...)',
                      onTap: () {
                        context.pushNamed(
                          MenuDisattivatiWidget.routeName,
                          queryParameters: {
                            'ristoranteRef': serializeParam(
                              widget.ristoranteRef,
                              ParamType.DocumentReference,
                            ),
                            'isAnteprima': serializeParam(
                              true,
                              ParamType.bool,
                            ),
                          }.withoutNulls,
                        );
                      },
                    ),
                    const SizedBox(height: 16.0),
                  ],

                  // OPZIONE 3: JUKEBOX (Se abilitato per il locale)
                  if (userRecord.jukeboxAttivo) ...[
                    _buildHubOptionCard(
                      theme: theme,
                      icon: Icons.music_note_rounded,
                      iconColor: const Color(0xFF1DB954),
                      iconBgColor:
                          const Color(0xFF1DB954).withValues(alpha: 0.12),
                      title: 'Jukebox del Locale',
                      subtitle:
                          'Richiedi la tua canzone preferita e ascoltala dal vivo',
                      onTap: () {
                        JukeboxModalWidget.show(
                          context,
                          ristoranteRef: widget.ristoranteRef!,
                          ristorante: userRecord,
                          currentLang: _currentLang,
                        );
                      },
                    ),
                    const SizedBox(height: 16.0),
                  ],

                  // OPZIONE 4: SALA GIOCHI (TRIS AL TAVOLO)
                  _buildHubOptionCard(
                    theme: theme,
                    icon: Icons.sports_esports_rounded,
                    iconColor: const Color(0xFF8B5CF6),
                    iconBgColor:
                        const Color(0xFF8B5CF6).withValues(alpha: 0.12),
                    title: 'Sala Giochi • Tris al Tavolo',
                    subtitle:
                        'Gioca con chi è al tuo tavolo o sfida gli altri tavoli del ristorante!',
                    onTap: () {
                      context.pushNamed(
                        TrisGameWidget.routeName,
                        queryParameters: {
                          'ristoranteRef': serializeParam(
                            widget.ristoranteRef,
                            ParamType.DocumentReference,
                          ),
                          'tavoloPreimpostato': serializeParam(
                            FFAppState().numeroTavolo,
                            ParamType.String,
                          ),
                        }.withoutNulls,
                      );
                    },
                  ),
                  const SizedBox(height: 16.0),

                  // OPZIONE 5: QUIZ AL TAVOLO
                  _buildHubOptionCard(
                    theme: theme,
                    icon: Icons.lightbulb_rounded,
                    iconColor: const Color(0xFFF59E0B),
                    iconBgColor:
                        const Color(0xFFF59E0B).withValues(alpha: 0.12),
                    title: 'Quiz del Gusto & Curiosità',
                    subtitle:
                        'Rispondi a 5 domande sul cibo o sfida in tempo reale gli altri tavoli!',
                    onTap: () {
                      context.pushNamed(
                        QuizGameWidget.routeName,
                        queryParameters: {
                          'ristoranteRef': serializeParam(
                            widget.ristoranteRef,
                            ParamType.DocumentReference,
                          ),
                          'tavoloPreimpostato': serializeParam(
                            FFAppState().numeroTavolo,
                            ParamType.String,
                          ),
                        }.withoutNulls,
                      );
                    },
                  ),
                  const SizedBox(height: 16.0),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHubOptionCard({
    required ThemeData theme,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    String? subTitleName,
    Color? subTitleNameColor,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20.0),
        child: Container(
          padding: const EdgeInsets.all(18.0),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(20.0),
            border: Border.all(
              color: theme.dividerColor.withValues(alpha: 0.12),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 14.0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 54.0,
                height: 54.0,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(16.0),
                ),
                alignment: Alignment.center,
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 28.0,
                ),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 17.0,
                      ),
                    ),
                    if (subTitleName != null && subTitleName.isNotEmpty) ...[
                      const SizedBox(height: 2.0),
                      Text(
                        subTitleName,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: subTitleNameColor ?? theme.colorScheme.primary,
                        ),
                      ),
                    ],
                    const SizedBox(height: 4.0),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.hintColor,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8.0),
              Icon(
                Icons.chevron_right_rounded,
                color: theme.hintColor,
                size: 24.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
