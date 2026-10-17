import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'abbonamento_model.dart';
export 'abbonamento_model.dart';

class AbbonamentoWidget extends StatefulWidget {
  const AbbonamentoWidget({super.key});

  static String routeName = 'Abbonamento';
  static String routePath = '/abbonamento';

  @override
  State<AbbonamentoWidget> createState() => _AbbonamentoWidgetState();
}

class _AbbonamentoWidgetState extends State<AbbonamentoWidget> {
  late AbbonamentoModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AbbonamentoModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  Future<void> _attivaPiano({
    required String tierKey,
    required String tierName,
    required String priceFormatted,
  }) async {
    final theme = Theme.of(context);
    final isAnnual = _model.billingInterval == 'annuale';
    final haUsatoProva = valueOrDefault<bool>(currentUserDocument?.haUsatoProva, false);

    final bool? confermato = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (bContext) => Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24.0),
            topRight: Radius.circular(24.0),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 44.0,
                height: 4.0,
                decoration: BoxDecoration(
                  color: theme.dividerColor.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2.0),
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            Row(
              children: [
                Container(
                  width: 44.0,
                  height: 44.0,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.workspace_premium_rounded,
                    color: theme.colorScheme.primary,
                    size: 26.0,
                  ),
                ),
                const SizedBox(width: 14.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Conferma Sottoscrizione',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '$tierName • Fatturazione ${isAnnual ? 'Annuale' : 'Mensile'}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.hintColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18.0),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(14.0),
                border: Border.all(
                  color: theme.dividerColor.withValues(alpha: 0.5),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Piano selezionato:',
                        style: theme.textTheme.bodyMedium,
                      ),
                      Text(
                        tierName,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Importo:',
                        style: theme.textTheme.bodyMedium,
                      ),
                      Text(
                        priceFormatted,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  if (!haUsatoProva) ...[
                    const Divider(height: 20.0),
                    Row(
                      children: [
                        const Icon(
                          Icons.verified_rounded,
                          color: Color(0xFF2E7D32),
                          size: 16.0,
                        ),
                        const SizedBox(width: 6.0),
                        Expanded(
                          child: Text(
                            '7 giorni di prova gratuita inclusi',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: const Color(0xFF2E7D32),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20.0),
            FFButtonWidget(
              onPressed: () => Navigator.pop(bContext, true),
              text: !haUsatoProva
                  ? 'Inizia la prova gratuita ora'
                  : 'Conferma e Attiva $tierName',
              options: FFButtonOptions(
                height: 50.0,
                color: theme.colorScheme.primary,
                textStyle: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
                elevation: 0.0,
                borderRadius: BorderRadius.circular(14.0),
              ),
            ),
            const SizedBox(height: 10.0),
            TextButton(
              onPressed: () => Navigator.pop(bContext, false),
              child: Text(
                'Annulla',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.hintColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (confermato != true) return;

    // Aggiornamento su Firestore
    await currentUserReference!.update(createUsersRecordData(
      isPremium: true,
      haUsatoProva: true,
      pianoAbbonamento: tierKey,
      intervalloAbbonamento: _model.billingInterval,
    ));

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '🎉 Complimenti! Il piano $tierName è ora attivo per il tuo locale.',
        ),
        backgroundColor: const Color(0xFF2E7D32),
        duration: const Duration(seconds: 4),
      ),
    );

    // Reindirizza alla Home Ristoratore
    context.goNamed(
      HomeRistoratoreWidget.routeName,
      queryParameters: {
        'ristoranteRef': serializeParam(
          currentUserReference,
          ParamType.DocumentReference,
        ),
      }.withoutNulls,
    );
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();
    final theme = Theme.of(context);
    final canPop = Navigator.of(context).canPop();
    final isAnnual = _model.billingInterval == 'annuale';

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          elevation: 0.0,
          leading: canPop
              ? FlutterFlowIconButton(
                  borderColor: Colors.transparent,
                  borderRadius: 24.0,
                  borderWidth: 1.0,
                  buttonSize: 40.0,
                  icon: Icon(
                    Icons.arrow_back_rounded,
                    color: theme.colorScheme.onSurface,
                    size: 24.0,
                  ),
                  onPressed: () async {
                    context.safePop();
                  },
                )
              : null,
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36.0,
                height: 36.0,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.workspace_premium_rounded,
                  color: theme.colorScheme.primary,
                  size: 20.0,
                ),
              ),
              const SizedBox(width: 10.0),
              Text(
                'Piani ProntoMenu',
                style: theme.appBarTheme.titleTextStyle ??
                    theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 19.0,
                      letterSpacing: -0.4,
                      color: theme.colorScheme.onSurface,
                    ),
              ),
            ],
          ),
          actions: [
            if (canPop) const SizedBox(width: 48.0),
          ],
          centerTitle: true,
        ),
        body: SafeArea(
          top: true,
          child: Align(
            alignment: const AlignmentDirectional(0.0, 0.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 880.0),
              child: CustomScrollView(
                controller: _model.columnController,
                slivers: [
                  // 1. Header con Badge, Logo circolare ProntoMenu com'era prima, Titolo e Sottotitolo
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Badge Header
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 6.0),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.star_rounded,
                                  color: theme.colorScheme.primary,
                                  size: 16.0,
                                ),
                                const SizedBox(width: 6.0),
                                Text(
                                  'PIANI PRONTOMENU',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18.0),

                          // Logo 96x96 circolare (com'era prima)
                          Container(
                            width: 96.0,
                            height: 96.0,
                            decoration: BoxDecoration(
                              color: theme.scaffoldBackgroundColor,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: theme.dividerColor,
                                width: 2.0,
                              ),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Image.network(
                              'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/pronto-menu-f0och1/assets/i4ccmvv80eni/IMG_8006.png',
                              width: 96.0,
                              height: 96.0,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Image.asset(
                                'assets/images/IMG_8006.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16.0),

                          Text(
                            'Sblocca il potenziale del tuo locale',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontSize: 24.0,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.6,
                            ),
                          ),
                          const SizedBox(height: 6.0),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 580.0),
                            child: Text(
                              'Gestisci ordini, comande, intrattenimento ai tavoli e menu senza intermediari. Zero commissioni sul venduto.',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.hintColor,
                                fontSize: 14.0,
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 2. Toggle Mensile / Annuale BLOCCATO IN ALTO anche mentre la pagina scorre!
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _StickyBillingToggleDelegate(
                      isAnnual: isAnnual,
                      height: 64.0,
                      child: Container(
                        padding: const EdgeInsets.all(4.0),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(30.0),
                          border: Border.all(
                            color: theme.dividerColor.withValues(alpha: 0.6),
                            width: 1.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 8.0,
                              color: Colors.black.withValues(alpha: 0.04),
                              offset: const Offset(0.0, 2.0),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildIntervalButton(
                              theme: theme,
                              label: 'Mensile',
                              isSelected: !isAnnual,
                              onTap: () {
                                safeSetState(() => _model.billingInterval = 'mensile');
                              },
                            ),
                            _buildIntervalButton(
                              theme: theme,
                              label: 'Annuale',
                              badge: '-20%',
                              isSelected: isAnnual,
                              onTap: () {
                                safeSetState(() => _model.billingInterval = 'annuale');
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // 3. I 3 Piani e Footer di sicurezza
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 32.0),
                      child: Column(
                        children: [
                          // Layout dei 3 Piani
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final isDesktop = constraints.maxWidth >= 760.0;
                              if (isDesktop) {
                                return IntrinsicHeight(
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      Expanded(child: _buildCardPro(theme, isAnnual)),
                                      const SizedBox(width: 16.0),
                                      Expanded(child: _buildCardPlus(theme, isAnnual)),
                                      const SizedBox(width: 16.0),
                                      Expanded(child: _buildCardUltra(theme, isAnnual)),
                                    ],
                                  ),
                                );
                              }

                              // Su mobile / schermi compatti: lista verticale di card
                              return Column(
                                children: [
                                  _buildCardPro(theme, isAnnual),
                                  const SizedBox(height: 20.0),
                                  _buildCardPlus(theme, isAnnual),
                                  const SizedBox(height: 20.0),
                                  _buildCardUltra(theme, isAnnual),
                                ],
                              );
                            },
                          ),

                          const SizedBox(height: 28.0),

                          // Footer di sicurezza e trasparenza
                          Container(
                            constraints: const BoxConstraints(maxWidth: 580.0),
                            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
                            decoration: BoxDecoration(
                              color: theme.cardColor,
                              borderRadius: BorderRadius.circular(16.0),
                              border: Border.all(
                                color: theme.dividerColor.withValues(alpha: 0.5),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.verified_user_outlined,
                                  size: 18.0,
                                  color: theme.hintColor,
                                ),
                                const SizedBox(width: 10.0),
                                Expanded(
                                  child: Text(
                                    'Nessun vincolo contrattuale • Disdici quando vuoi in un click • 0% commissioni sul venduto',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.hintColor,
                                      height: 1.3,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20.0),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIntervalButton({
    required ThemeData theme,
    required String label,
    String? badge,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 9.0),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(26.0),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? theme.colorScheme.onPrimary : theme.hintColor,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 13.5,
              ),
            ),
            if (badge != null) ...[
              const SizedBox(width: 6.0),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.colorScheme.onPrimary.withValues(alpha: 0.25)
                      : const Color(0xFF2E7D32).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    color: isSelected ? theme.colorScheme.onPrimary : const Color(0xFF2E7D32),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ─── CARD 1: PRONTOMENU PRO ─────────────────────────────────────────────
  Widget _buildCardPro(ThemeData theme, bool isAnnual) {
    const accentColor = Color(0xFF0D9488); // Teal
    final price = isAnnual ? '69,90€' : '6,90€';
    final period = isAnnual ? '/ anno' : '/ mese';
    final subtitlePrice = isAnnual ? 'equivale a 5,82€ al mese' : 'fatturato mensilmente';

    return Container(
      padding: const EdgeInsets.all(22.0),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(22.0),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.7),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 16.0,
            color: Colors.black.withValues(alpha: 0.03),
            offset: const Offset(0.0, 4.0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: const Text(
                  'ESSENZIALE',
                  style: TextStyle(
                    color: accentColor,
                    fontSize: 11.0,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14.0),
          Text(
            'ProntoMenu Pro',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 22.0,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            'Il menu digitale completo e conforme per presentare i tuoi piatti.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.hintColor,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 16.0),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                price,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 32.0,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 4.0),
              Text(
                period,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.hintColor,
                ),
              ),
            ],
          ),
          Text(
            subtitlePrice,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.hintColor,
              fontSize: 11.5,
            ),
          ),
          const Divider(height: 28.0),
          _buildCheckItem(theme, 'Menu Digitale QR Code nativo per i tavoli'),
          _buildCheckItem(theme, 'Categorie e sottocategorie illimitate'),
          _buildCheckItem(theme, 'Allergeni completi & preferenze (Senza glutine, lattosio...)'),
          _buildCheckItem(theme, 'Menù testuale con descrizioni dettagliate, ingredienti e prezzi'),
          _buildCheckItem(theme, 'Zero commissioni sul venduto'),
          _buildCheckItem(theme, 'Supporto base e aggiornamenti inclusi'),
          const SizedBox(height: 20.0),
          FFButtonWidget(
            onPressed: () => _attivaPiano(
              tierKey: 'pro',
              tierName: 'ProntoMenu Pro',
              priceFormatted: '$price $period',
            ),
            text: 'Scegli Piano Pro',
            options: FFButtonOptions(
              height: 46.0,
              color: accentColor,
              textStyle: theme.textTheme.titleSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              elevation: 0.0,
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
        ],
      ),
    );
  }

  // ─── CARD 2: PRONTOMENU PLUS (CONSIGLIATO) ──────────────────────────────
  Widget _buildCardPlus(ThemeData theme, bool isAnnual) {
    final price = isAnnual ? '109,90€' : '11,90€';
    final period = isAnnual ? '/ anno' : '/ mese';
    final subtitlePrice = isAnnual ? 'equivale a 9,15€ al mese' : 'fatturato mensilmente';
    final primaryColor = theme.colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(22.0),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(22.0),
        border: Border.all(
          color: primaryColor,
          width: 2.0,
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 20.0,
            color: primaryColor.withValues(alpha: 0.12),
            offset: const Offset(0.0, 6.0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star_rounded, color: Colors.white, size: 14.0),
                    const SizedBox(width: 4.0),
                    Text(
                      'PIÙ POPOLARE',
                      style: TextStyle(
                        color: theme.colorScheme.onPrimary,
                        fontSize: 11.0,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14.0),
          Text(
            'ProntoMenu Plus',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 22.0,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            'Ricezione ordini dal vivo, gestione comande e menù mutaforma dinamici.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.hintColor,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 16.0),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                price,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 32.0,
                  letterSpacing: -0.5,
                  color: primaryColor,
                ),
              ),
              const SizedBox(width: 4.0),
              Text(
                period,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.hintColor,
                ),
              ),
            ],
          ),
          Text(
            subtitlePrice,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.hintColor,
              fontSize: 11.5,
            ),
          ),
          const Divider(height: 28.0),
          _buildCheckItem(theme, 'Tutto ciò che include ProntoMenu Pro', isBold: true),
          _buildCheckItem(theme, 'Ricezione ordini in tempo reale dai tavoli'),
          _buildCheckItem(theme, 'Schermi dedicati Cucina e Cassa per le comande'),
          _buildCheckItem(theme, 'Prenotazioni tavoli gestibili direttamente sull\'app'),
          _buildCheckItem(theme, 'Menù Mutaforma (più menu per orari, eventi e pranzi)'),
          _buildCheckItem(theme, 'Personalizzazione grafica e colore tema del locale'),
          _buildCheckItem(theme, 'Zero commissioni sul venduto'),
          const SizedBox(height: 20.0),
          FFButtonWidget(
            onPressed: () => _attivaPiano(
              tierKey: 'plus',
              tierName: 'ProntoMenu Plus',
              priceFormatted: '$price $period',
            ),
            text: 'Scegli Piano Plus ⭐',
            options: FFButtonOptions(
              height: 46.0,
              color: primaryColor,
              textStyle: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
              elevation: 0.0,
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
        ],
      ),
    );
  }

  // ─── CARD 3: PRONTOMENU ULTRA (TUTTO INCLUSO) ───────────────────────────
  Widget _buildCardUltra(ThemeData theme, bool isAnnual) {
    const accentColor = Color(0xFF7C3AED); // Purple
    final price = isAnnual ? '289,90€' : '29,90€';
    final period = isAnnual ? '/ anno' : '/ mese';
    final subtitlePrice = isAnnual ? 'equivale a 24,15€ al mese' : 'fatturato mensilmente';

    return Container(
      padding: const EdgeInsets.all(22.0),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(22.0),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.6),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 18.0,
            color: accentColor.withValues(alpha: 0.08),
            offset: const Offset(0.0, 4.0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('👑', style: TextStyle(fontSize: 12.0)),
                    SizedBox(width: 4.0),
                    Text(
                      'TUTTO INCLUSO',
                      style: TextStyle(
                        color: accentColor,
                        fontSize: 11.0,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14.0),
          Text(
            'ProntoMenu Ultra',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 22.0,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            'La suite definitiva: intrattenimento clienti ai tavoli, statistiche e supporto prioritario.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.hintColor,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 16.0),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                price,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 32.0,
                  letterSpacing: -0.5,
                  color: accentColor,
                ),
              ),
              const SizedBox(width: 4.0),
              Text(
                period,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.hintColor,
                ),
              ),
            ],
          ),
          Text(
            subtitlePrice,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.hintColor,
              fontSize: 11.5,
            ),
          ),
          const Divider(height: 28.0),
          _buildCheckItem(theme, 'Tutto ciò che include ProntoMenu Plus', isBold: true),
          _buildCheckItem(theme, 'Foto piatti in alta risoluzione sul menù digitale', isBold: true),
          _buildCheckItem(theme, 'Jukebox Digitale per richieste musicali dei clienti'),
          _buildCheckItem(theme, 'Giochi ai tavoli (Tris & Quiz del Gusto multiplayer)'),
          _buildCheckItem(theme, 'Statistiche avanzate e report vendite in tempo reale'),
          _buildCheckItem(theme, 'Cestino di sicurezza e ripristino immediato piatti'),
          _buildCheckItem(theme, 'Assistenza prioritaria dedicata in-app con ticket diretti'),
          _buildCheckItem(theme, 'Zero commissioni sul venduto'),
          const SizedBox(height: 20.0),
          FFButtonWidget(
            onPressed: () => _attivaPiano(
              tierKey: 'ultra',
              tierName: 'ProntoMenu Ultra',
              priceFormatted: '$price $period',
            ),
            text: 'Scegli Piano Ultra 👑',
            options: FFButtonOptions(
              height: 46.0,
              color: accentColor,
              textStyle: theme.textTheme.titleSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              elevation: 0.0,
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckItem(ThemeData theme, String text, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 18.0,
            height: 18.0,
            decoration: const BoxDecoration(
              color: Color(0xFFE8F5E9),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.check_rounded,
              color: Color(0xFF2E7D32),
              size: 13.0,
            ),
          ),
          const SizedBox(width: 10.0),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
                color: isBold ? theme.colorScheme.onSurface : theme.colorScheme.onSurface.withValues(alpha: 0.85),
                fontSize: 12.5,
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StickyBillingToggleDelegate extends SliverPersistentHeaderDelegate {
  _StickyBillingToggleDelegate({
    required this.child,
    required this.height,
    required this.isAnnual,
  });

  final Widget child;
  final double height;
  final bool isAnnual;

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    final theme = Theme.of(context);
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(
            color: overlapsContent
                ? theme.dividerColor.withValues(alpha: 0.18)
                : Colors.transparent,
            width: 1.0,
          ),
        ),
        boxShadow: overlapsContent
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 6.0,
                  offset: const Offset(0.0, 2.0),
                ),
              ]
            : null,
      ),
      alignment: Alignment.center,
      child: child,
    );
  }

  @override
  bool shouldRebuild(covariant _StickyBillingToggleDelegate oldDelegate) {
    return oldDelegate.isAnnual != isAnnual ||
        oldDelegate.height != height ||
        oldDelegate.child != child;
  }
}
