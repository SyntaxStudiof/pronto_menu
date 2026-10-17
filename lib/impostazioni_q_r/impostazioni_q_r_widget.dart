import '/auth/firebase_auth/auth_util.dart';
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
    this.embedded = false,
  });

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
  final TextEditingController _tableInputController = TextEditingController(text: '1');

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ImpostazioniQRModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    _tableInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final menuWebUrl =
        'https://prontomenu-6d485.web.app/loaderMenu?ristoranteRef=$currentUserUid';
    final downloadQrUrl =
        'https://api.qrserver.com/v1/create-qr-code/?size=1024x1024&data=${Uri.encodeComponent(menuWebUrl)}';

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: widget.embedded
            ? null
            : AppBar(
          backgroundColor: theme.appBarTheme.backgroundColor ?? theme.cardColor,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_rounded,
              color: theme.appBarTheme.foregroundColor ?? theme.iconTheme.color,
              size: 24.0,
            ),
            onPressed: () async {
              context.pop();
            },
          ),
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
                  Icons.qr_code_2_rounded,
                  color: theme.colorScheme.primary,
                  size: 20.0,
                ),
              ),
              const SizedBox(width: 12.0),
              Text(
                'QR Code Menu',
                style: theme.appBarTheme.titleTextStyle ??
                    theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                      letterSpacing: -0.4,
                    ),
              ),
            ],
          ),
          actions: const [
            SizedBox(width: 48.0),
          ],
          centerTitle: true,
          elevation: 0.0,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1.0),
            child: Container(
              color: theme.dividerColor.withValues(alpha: 0.5),
              height: 1.0,
            ),
          ),
        ),
        body: SafeArea(
          top: true,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth >= 900 || widget.embedded;

              if (isDesktop) {
                final tableUrl =
                    'https://prontomenu-6d485.web.app/loaderMenu?ristoranteRef=$currentUserUid&tavolo=$_selectedTable';
                final downloadTableQrUrl =
                    'https://api.qrserver.com/v1/create-qr-code/?size=1024x1024&data=${Uri.encodeComponent(tableUrl)}';

                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 28.0),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1280.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ═══════════════════════════════════════════════════
                          // CARD SINISTRA: QR GENERALE LOCALE (~520px)
                          // ═══════════════════════════════════════════════════
                          Expanded(
                            flex: 5,
                            child: _buildGeneralQrCard(theme, isDark, menuWebUrl, downloadQrUrl),
                          ),
                          const SizedBox(width: 28.0),

                          // ═══════════════════════════════════════════════════
                          // CARD DESTRA: QR TAVOLO SPECIFICO & KIT SALA (~650px)
                          // ═══════════════════════════════════════════════════
                          Expanded(
                            flex: 6,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _buildTableQrCard(theme, isDark, tableUrl, downloadTableQrUrl),
                                const SizedBox(height: 20.0),
                                _buildDisplayTipsCard(theme, isDark),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              // Layout Mobile standard
              return Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 480.0),
                    child: _buildGeneralQrCard(theme, isDark, menuWebUrl, downloadQrUrl),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildGeneralQrCard(
    ThemeData theme,
    bool isDark,
    String menuWebUrl,
    String downloadQrUrl,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24.0),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.5),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 20.0,
            color: Colors.black.withValues(alpha: 0.04),
            offset: const Offset(0.0, 4.0),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 26.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 46.0,
                height: 46.0,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Icon(
                  Icons.qr_code_2_rounded,
                  color: theme.colorScheme.primary,
                  size: 26.0,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle_rounded, size: 14.0, color: Color(0xFF10B981)),
                    SizedBox(width: 4.0),
                    Text(
                      'Menù Attivo & Online',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18.0),
          Text(
            'QR Code Generale del Menù',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 21.0,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 6.0),
          Text(
            'Il codice principale del tuo ristorante. I clienti lo inquadrano con lo smartphone per consultare il menù ed ordinare.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.hintColor,
              height: 1.4,
              fontSize: 13.0,
            ),
          ),
          const SizedBox(height: 22.0),

          // Frame elegante del QR Code
          Container(
            padding: const EdgeInsets.all(14.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.0),
              border: Border.all(
                color: const Color(0xFFE2E8F0),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  blurRadius: 16.0,
                  color: Colors.black.withValues(alpha: 0.05),
                  offset: const Offset(0.0, 3.0),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: QrImageView(
                data: menuWebUrl,
                version: QrVersions.auto,
                size: 200.0,
                backgroundColor: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 18.0),

          // Box link diretto con pulsante Copia
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.04)
                  : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(
                color: theme.dividerColor.withValues(alpha: 0.6),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.link_rounded, size: 18.0, color: theme.colorScheme.primary),
                const SizedBox(width: 8.0),
                Expanded(
                  child: Text(
                    menuWebUrl,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.0,
                      fontFamily: 'monospace',
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy_rounded, size: 17.0),
                  tooltip: 'Copia Link',
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: menuWebUrl));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Row(
                          children: [
                            Icon(Icons.check_circle_rounded, color: Colors.white, size: 18.0),
                            SizedBox(width: 8.0),
                            Text('Link del menù copiato negli appunti!'),
                          ],
                        ),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: Color(0xFF059669),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 18.0),

          // Bottone Azione Scarica QR
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                await launchURL(downloadQrUrl);
              },
              icon: Icon(
                Icons.download_rounded,
                color: theme.colorScheme.onPrimary,
                size: 18.0,
              ),
              label: Text(
                'Scarica QR Code in Alta Risoluzione (PNG)',
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontSize: 14.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                elevation: 0.0,
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10.0),

          // Bottone Anteprima come Cliente
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                context.pushNamed(
                  HubClienteWidget.routeName,
                  queryParameters: {
                    'ristoranteRef': serializeParam(
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
              icon: Icon(
                Icons.visibility_rounded,
                color: theme.colorScheme.primary,
                size: 18.0,
              ),
              label: Text(
                'Apri Anteprima come Cliente',
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  fontSize: 14.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: theme.colorScheme.primary,
                  width: 1.5,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 13.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableQrCard(
    ThemeData theme,
    bool isDark,
    String tableUrl,
    String downloadTableQrUrl,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24.0),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.5),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 20.0,
            color: Colors.black.withValues(alpha: 0.04),
            offset: const Offset(0.0, 4.0),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 44.0,
                height: 44.0,
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12.0),
                ),
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
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 17.0,
                      ),
                    ),
                    Text(
                      'Pre-imposta il numero del tavolo per comande dirette in cucina',
                      style: TextStyle(
                        fontSize: 12.0,
                        color: theme.hintColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20.0),

          // Selettore numero tavolo interattivo
          Row(
            children: [
              Text(
                'Seleziona Tavolo:',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white70 : const Color(0xFF334155),
                ),
              ),
              const SizedBox(width: 14.0),
              Wrap(
                spacing: 8.0,
                children: [1, 2, 3, 4, 5, 10, 15, 20].map((tNum) {
                  final isSelected = _selectedTable == tNum;
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedTable = tNum;
                        _tableInputController.text = tNum.toString();
                      });
                    },
                    borderRadius: BorderRadius.circular(8.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? theme.colorScheme.primary
                            : (isDark
                                ? Colors.white.withValues(alpha: 0.06)
                                : const Color(0xFFF1F5F9)),
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : (isDark
                                  ? Colors.white.withValues(alpha: 0.1)
                                  : const Color(0xFFE2E8F0)),
                        ),
                      ),
                      child: Text(
                        'T.$tNum',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? theme.colorScheme.onPrimary
                              : (isDark ? Colors.white70 : const Color(0xFF475569)),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          const SizedBox(height: 18.0),

          // Anteprima mini del QR tavolo selezionato
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.03)
                  : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(
                color: theme.dividerColor.withValues(alpha: 0.6),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: QrImageView(
                      data: tableUrl,
                      version: QrVersions.auto,
                      size: 90.0,
                      backgroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 18.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tavolo #$_selectedTable',
                        style: const TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        'I clienti al Tavolo #$_selectedTable non dovranno inserire il numero: il sistema lo assegnerà in automatico all\'ordine.',
                        style: TextStyle(
                          fontSize: 12.0,
                          height: 1.35,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      ElevatedButton.icon(
                        onPressed: () async {
                          await launchURL(downloadTableQrUrl);
                        },
                        icon: const Icon(Icons.download_rounded, size: 16.0),
                        label: Text('Scarica QR Tavolo $_selectedTable'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3B82F6),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
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

  Widget _buildDisplayTipsCard(ThemeData theme, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.5),
        ),
      ),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb_rounded, color: Color(0xFFF59E0B), size: 22.0),
              const SizedBox(width: 10.0),
              Text(
                'Consigli per l\'Esposizione dei QR in Sala',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 15.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12.0),
          _buildTipRow(
            icon: Icons.aspect_ratio_rounded,
            title: 'Formato consigliato',
            desc: 'Stampa in formato A6 (10x15 cm) o A7 per cavalletti da tavolo in plexiglass o legno.',
            isDark: isDark,
          ),
          const SizedBox(height: 10.0),
          _buildTipRow(
            icon: Icons.brightness_high_rounded,
            title: 'Contrasto e illuminazione',
            desc: 'Posiziona il QR code dove l\'illuminazione del tavolo non crea riflessi sul supporto plastificato.',
            isDark: isDark,
          ),
          const SizedBox(height: 10.0),
          _buildTipRow(
            icon: Icons.wifi_rounded,
            title: 'Wi-Fi Locale opzionale',
            desc: 'Se il locale ha poca copertura cellulare, stampa sotto al QR anche la password del Wi-Fi del locale.',
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildTipRow({
    required IconData icon,
    required String title,
    required String desc,
    required bool isDark,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 2.0),
          padding: const EdgeInsets.all(4.0),
          decoration: BoxDecoration(
            color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(6.0),
          ),
          child: Icon(icon, size: 14.0, color: const Color(0xFFF59E0B)),
        ),
        const SizedBox(width: 10.0),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
              ),
              Text(
                desc,
                style: TextStyle(
                  fontSize: 11.5,
                  height: 1.35,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

