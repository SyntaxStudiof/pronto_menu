import '/auth/firebase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'impostazioni_q_r_model.dart';
export 'impostazioni_q_r_model.dart';

class ImpostazioniQRWidget extends StatefulWidget {
  const ImpostazioniQRWidget({
    super.key,
    this.ristoranteRef,
    this.embedded = false,
  });

  final DocumentReference? ristoranteRef;
  final bool embedded;

  static String routeName = 'ImpostazioniQR';
  static String routePath = '/impostazioniQR';

  @override
  State<ImpostazioniQRWidget> createState() => _ImpostazioniQRWidgetState();
}

class _ImpostazioniQRWidgetState extends State<ImpostazioniQRWidget> {
  late ImpostazioniQRModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedTable = 1;
  late TextEditingController _tableInputController;

  final List<int> _quickTables = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 15, 20];

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ImpostazioniQRModel());
    _tableInputController = TextEditingController(text: '$_selectedTable');

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    _tableInputController.dispose();
    super.dispose();
  }

  void _selectTable(int tNum) {
    if (tNum < 1) tNum = 1;
    safeSetState(() {
      _selectedTable = tNum;
      _tableInputController.text = '$tNum';
    });
  }

  void _copyToClipboard(BuildContext context, String text, String message) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded,
                color: Colors.white, size: 18.0),
            const SizedBox(width: 8.0),
            Expanded(child: Text(message)),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF10B981),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    // Palette fedele al design system della Dashboard
    final bgCanvas = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSecondary =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    final restaurantId = widget.ristoranteRef?.id ?? currentUserUid;
    final menuWebUrl =
        'https://prontomenu-6d485.web.app/loaderMenu?ristoranteRef=$restaurantId';
    final downloadQrUrl =
        'https://api.qrserver.com/v1/create-qr-code/?size=1024x1024&data=${Uri.encodeComponent(menuWebUrl)}';

    final tableUrl =
        'https://prontomenu-6d485.web.app/loaderMenu?ristoranteRef=$restaurantId&tavolo=$_selectedTable';
    final downloadTableQrUrl =
        'https://api.qrserver.com/v1/create-qr-code/?size=1024x1024&data=${Uri.encodeComponent(tableUrl)}';

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: bgCanvas,
        appBar: widget.embedded
            ? null
            : AppBar(
                backgroundColor: bgCanvas,
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
                        Icons.qr_code_2_rounded,
                        color: colorScheme.primary,
                        size: 20.0,
                      ),
                    ),
                    const SizedBox(width: 10.0),
                    Text(
                      'QR Code Menù',
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
                actions: const [
                  SizedBox(width: 48.0),
                ],
              ),
        body: SafeArea(
          top: true,
          child: Align(
            alignment: Alignment.topCenter,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final bool isDesktop =
                    widget.embedded || constraints.maxWidth >= 920;

                return ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isDesktop ? 1240.0 : 680.0,
                  ),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: isDesktop ? 28.0 : 18.0,
                      vertical: 20.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ── Header Titolo & Descrizione ──────────────────────────
                        Padding(
                          padding: const EdgeInsets.only(left: 4.0, bottom: 22.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Codici QR & Menù Digitale',
                                      style: TextStyle(
                                        fontSize: isDesktop ? 22.0 : 19.0,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: -0.5,
                                        color: textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 4.0),
                                    Text(
                                      'Genera, scarica e stampa i QR Code per il tuo locale. I clienti potranno consultare il menù ed ordinare istantaneamente.',
                                      style: TextStyle(
                                        fontSize: 13.5,
                                        color: textSecondary,
                                        height: 1.35,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isDesktop) ...[
                                const SizedBox(width: 16.0),
                                OutlinedButton.icon(
                                  onPressed: () {
                                    context.pushNamed(
                                      HubClienteWidget.routeName,
                                      queryParameters: {
                                        'ristoranteRef': serializeParam(
                                          widget.ristoranteRef ??
                                              currentUserReference,
                                          ParamType.DocumentReference,
                                        ),
                                        'isAnteprima': serializeParam(
                                          true,
                                          ParamType.bool,
                                        ),
                                      }.withoutNulls,
                                    );
                                  },
                                  icon: const Icon(Icons.visibility_rounded,
                                      size: 16.0),
                                  label: const Text('Anteprima Cliente'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: colorScheme.primary,
                                    side: BorderSide(
                                      color: colorScheme.primary
                                          .withValues(alpha: 0.5),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14.0,
                                      vertical: 10.0,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),

                        // ── Layout a 2 Colonne (Desktop) o Colonna Singola (Mobile) ─
                        if (isDesktop)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Colonna Sinistra (~48%): QR Generale Locale
                              Expanded(
                                flex: 48,
                                child: _buildGeneralQrCard(
                                  context: context,
                                  theme: theme,
                                  colorScheme: colorScheme,
                                  isDark: isDark,
                                  textPrimary: textPrimary,
                                  textSecondary: textSecondary,
                                  menuWebUrl: menuWebUrl,
                                  downloadQrUrl: downloadQrUrl,
                                ),
                              ),
                              const SizedBox(width: 24.0),
                              // Colonna Destra (~52%): QR Specifico per Tavolo & Consigli Sala
                              Expanded(
                                flex: 52,
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    _buildTableQrCard(
                                      context: context,
                                      theme: theme,
                                      colorScheme: colorScheme,
                                      isDark: isDark,
                                      textPrimary: textPrimary,
                                      textSecondary: textSecondary,
                                      tableUrl: tableUrl,
                                      downloadTableQrUrl: downloadTableQrUrl,
                                    ),
                                    const SizedBox(height: 20.0),
                                    _buildDisplayTipsCard(
                                      theme: theme,
                                      isDark: isDark,
                                      textPrimary: textPrimary,
                                      textSecondary: textSecondary,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )
                        else ...[
                          // Mobile Layout
                          _buildGeneralQrCard(
                            context: context,
                            theme: theme,
                            colorScheme: colorScheme,
                            isDark: isDark,
                            textPrimary: textPrimary,
                            textSecondary: textSecondary,
                            menuWebUrl: menuWebUrl,
                            downloadQrUrl: downloadQrUrl,
                          ),
                          const SizedBox(height: 20.0),
                          _buildTableQrCard(
                            context: context,
                            theme: theme,
                            colorScheme: colorScheme,
                            isDark: isDark,
                            textPrimary: textPrimary,
                            textSecondary: textSecondary,
                            tableUrl: tableUrl,
                            downloadTableQrUrl: downloadTableQrUrl,
                          ),
                          const SizedBox(height: 20.0),
                          _buildDisplayTipsCard(
                            theme: theme,
                            isDark: isDark,
                            textPrimary: textPrimary,
                            textSecondary: textSecondary,
                          ),
                        ],

                        const SizedBox(height: 40.0),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CARD 1: QR CODE GENERALE LOCALE
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildGeneralQrCard({
    required BuildContext context,
    required ThemeData theme,
    required ColorScheme colorScheme,
    required bool isDark,
    required Color textPrimary,
    required Color textSecondary,
    required String menuWebUrl,
    required String downloadQrUrl,
  }) {
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor =
        isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final inputBg =
        isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: borderColor, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.03),
            blurRadius: 10.0,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(22.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header della Card
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  Icons.qr_code_2_rounded,
                  color: colorScheme.primary,
                  size: 24.0,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.5),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(
                    color: const Color(0xFF10B981).withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6.0,
                      height: 6.0,
                      decoration: const BoxDecoration(
                        color: Color(0xFF10B981),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5.0),
                    const Text(
                      'Menù Attivo & Online',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16.0),

          Text(
            'QR Code Generale del Menù',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.3,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 6.0),
          Text(
            'Il codice principale del tuo ristorante. I clienti lo inquadrano per visualizzare il menù digitale ed effettuare ordini al tavolo o al banco.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.0,
              color: textSecondary,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 20.0),

          // Frame del QR Code
          Center(
            child: Container(
              padding: const EdgeInsets.all(14.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.0),
                border: Border.all(
                  color: const Color(0xFFE2E8F0),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 14.0,
                    color: Colors.black.withValues(alpha: 0.06),
                    offset: const Offset(0.0, 3.0),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: QrImageView(
                  data: menuWebUrl,
                  version: QrVersions.auto,
                  size: 195.0,
                  backgroundColor: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 18.0),

          // Box Link Diretto con Bottone Copia
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: inputBg,
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.link_rounded,
                  size: 18.0,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: Text(
                    menuWebUrl,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.0,
                      fontFamily: 'monospace',
                      color: textSecondary,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy_rounded, size: 16.0),
                  tooltip: 'Copia Link',
                  splashRadius: 18.0,
                  onPressed: () => _copyToClipboard(
                    context,
                    menuWebUrl,
                    'Link del menù copiato negli appunti!',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16.0),

          // Pulsante Scarica PNG
          ElevatedButton.icon(
            onPressed: () async {
              await launchURL(downloadQrUrl);
            },
            icon: const Icon(Icons.download_rounded, size: 18.0),
            label: const Text('Scarica QR Code in Alta Risoluzione (PNG)'),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: Colors.white,
              elevation: 1.0,
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 13.0,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              textStyle: const TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 10.0),

          // Pulsante Anteprima Cliente
          OutlinedButton.icon(
            onPressed: () {
              context.pushNamed(
                HubClienteWidget.routeName,
                queryParameters: {
                  'ristoranteRef': serializeParam(
                    widget.ristoranteRef ?? currentUserReference,
                    ParamType.DocumentReference,
                  ),
                  'isAnteprima': serializeParam(
                    true,
                    ParamType.bool,
                  ),
                }.withoutNulls,
              );
            },
            icon: const Icon(Icons.visibility_rounded, size: 18.0),
            label: const Text('Apri Anteprima come Cliente'),
            style: OutlinedButton.styleFrom(
              foregroundColor: textPrimary,
              side: BorderSide(color: borderColor),
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              textStyle: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CARD 2: QR CODE SPECIFICO PER TAVOLO
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildTableQrCard({
    required BuildContext context,
    required ThemeData theme,
    required ColorScheme colorScheme,
    required bool isDark,
    required Color textPrimary,
    required Color textSecondary,
    required String tableUrl,
    required String downloadTableQrUrl,
  }) {
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor =
        isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final inputBg =
        isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: borderColor, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.03),
            blurRadius: 10.0,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(22.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Card Tavoli
          Row(
            children: [
              Container(
                width: 42.0,
                height: 42.0,
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.table_restaurant_rounded,
                  color: Color(0xFF3B82F6),
                  size: 24.0,
                ),
              ),
              const SizedBox(width: 14.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'QR Code Specifico per Tavolo',
                      style: TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2.0),
                    Text(
                      'Pre-imposta il numero del tavolo per comande dirette in cucina',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18.0),

          // Selettore Rapido & Stepper Numero Tavolo
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Seleziona Tavolo:',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                ),
              ),
              const SizedBox(width: 12.0),
              // Stepper Tavolo [-] [N] [+]
              Container(
                decoration: BoxDecoration(
                  color: inputBg,
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_rounded, size: 16.0),
                      splashRadius: 16.0,
                      padding: const EdgeInsets.all(6.0),
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        if (_selectedTable > 1) {
                          _selectTable(_selectedTable - 1);
                        }
                      },
                    ),
                    Container(
                      width: 42.0,
                      alignment: Alignment.center,
                      child: Text(
                        '#$_selectedTable',
                        style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_rounded, size: 16.0),
                      splashRadius: 16.0,
                      padding: const EdgeInsets.all(6.0),
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        _selectTable(_selectedTable + 1);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12.0),

          // Chips Tavoli Frequenti
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _quickTables.map((tNum) {
                final isSelected = _selectedTable == tNum;
                return Padding(
                  padding: const EdgeInsets.only(right: 6.0),
                  child: InkWell(
                    onTap: () => _selectTable(tNum),
                    borderRadius: BorderRadius.circular(8.0),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 11.0, vertical: 6.0),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? colorScheme.primary
                            : (isDark
                                ? const Color(0xFF0F172A)
                                : const Color(0xFFF1F5F9)),
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(
                          color: isSelected
                              ? colorScheme.primary
                              : borderColor,
                        ),
                      ),
                      child: Text(
                        'T.$tNum',
                        style: TextStyle(
                          fontSize: 12.0,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? Colors.white
                              : (isDark
                                  ? const Color(0xFFCBD5E1)
                                  : const Color(0xFF475569)),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 18.0),

          // Box Anteprima del QR Tavolo Selezionato
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: inputBg,
              borderRadius: BorderRadius.circular(14.0),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: QrImageView(
                      data: tableUrl,
                      version: QrVersions.auto,
                      size: 96.0,
                      backgroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8.0, vertical: 3.0),
                            decoration: BoxDecoration(
                              color: const Color(0xFF3B82F6)
                                  .withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6.0),
                            ),
                            child: Text(
                              'TAVOLO #$_selectedTable',
                              style: const TextStyle(
                                fontSize: 11.0,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF3B82F6),
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6.0),
                      Text(
                        'I clienti al Tavolo #$_selectedTable non dovranno inserire il numero: il sistema lo assegnerà in automatico alle comande.',
                        style: TextStyle(
                          fontSize: 12.5,
                          height: 1.35,
                          color: textSecondary,
                        ),
                      ),
                      const SizedBox(height: 12.0),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: () async {
                              await launchURL(downloadTableQrUrl);
                            },
                            icon: const Icon(Icons.download_rounded, size: 15.0),
                            label: Text('Scarica QR T.$_selectedTable'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF3B82F6),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14.0, vertical: 9.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              textStyle: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8.0),
                          IconButton(
                            icon: const Icon(Icons.copy_rounded, size: 16.0),
                            tooltip: 'Copia Link Tavolo',
                            splashRadius: 18.0,
                            onPressed: () => _copyToClipboard(
                              context,
                              tableUrl,
                              'Link del Tavolo #$_selectedTable copiato!',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CARD 3: CONSIGLI PER L'ESPOSIZIONE DEI QR IN SALA
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildDisplayTipsCard({
    required ThemeData theme,
    required bool isDark,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor =
        isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: borderColor, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.03),
            blurRadius: 10.0,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34.0,
                height: 34.0,
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(9.0),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.lightbulb_rounded,
                  color: Color(0xFFF59E0B),
                  size: 18.0,
                ),
              ),
              const SizedBox(width: 10.0),
              Text(
                'Consigli per l\'Esposizione dei QR in Sala',
                style: TextStyle(
                  fontSize: 15.0,
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14.0),
          _buildTipRow(
            icon: Icons.aspect_ratio_rounded,
            title: 'Formato consigliato',
            desc:
                'Stampa in formato A6 (10x15 cm) o A7 per cavalletti da tavolo in plexiglass, legno o adesivi plastificati.',
            textPrimary: textPrimary,
            textSecondary: textSecondary,
          ),
          const SizedBox(height: 12.0),
          _buildTipRow(
            icon: Icons.brightness_high_rounded,
            title: 'Contrasto e illuminazione',
            desc:
                'Posiziona il QR code dove l\'illuminazione del tavolo è omogenea per evitare riflessi sulle finiture lucide.',
            textPrimary: textPrimary,
            textSecondary: textSecondary,
          ),
          const SizedBox(height: 12.0),
          _buildTipRow(
            icon: Icons.wifi_rounded,
            title: 'Wi-Fi Locale opzionale',
            desc:
                'Se il locale ha poca copertura cellulare, stampa sotto al QR anche il nome della rete e la password Wi-Fi ospiti.',
            textPrimary: textPrimary,
            textSecondary: textSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildTipRow({
    required IconData icon,
    required String title,
    required String desc,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 2.0),
          padding: const EdgeInsets.all(5.0),
          decoration: BoxDecoration(
            color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(6.0),
          ),
          child: const Icon(
            Icons.check_rounded,
            size: 13.0,
            color: Color(0xFFF59E0B),
          ),
        ),
        const SizedBox(width: 10.0),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13.0,
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 1.5),
              Text(
                desc,
                style: TextStyle(
                  fontSize: 12.0,
                  height: 1.35,
                  color: textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
