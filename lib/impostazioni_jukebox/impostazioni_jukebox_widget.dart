import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/services/jukebox_service.dart';
import 'impostazioni_jukebox_model.dart';

export 'impostazioni_jukebox_model.dart';

class ImpostazioniJukeboxWidget extends StatefulWidget {
  const ImpostazioniJukeboxWidget({super.key});

  static String routeName = 'ImpostazioniJukebox';
  static String routePath = '/impostazioniJukebox';

  @override
  State<ImpostazioniJukeboxWidget> createState() => _ImpostazioniJukeboxWidgetState();
}

class _ImpostazioniJukeboxWidgetState extends State<ImpostazioniJukeboxWidget> {
  late ImpostazioniJukeboxModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isInitialized = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ImpostazioniJukeboxModel());
    _model.playlistController = TextEditingController();
    _model.playlistFocusNode = FocusNode();

  }

  void _initFields(UsersRecord user) {
    if (_isInitialized) return;
    _model.jukeboxAttivo = user.jukeboxAttivo;
    _model.playlistController?.text = user.spotifyPlaylistId;
    _isInitialized = true;
  }

  Future<void> _salva() async {
    if (currentUserReference == null) return;
    setState(() => _isSaving = true);

    try {
      final inputSpotify = _model.playlistController?.text.trim() ?? '';
      await currentUserReference!.update(createUsersRecordData(
        jukeboxAttivo: _model.jukeboxAttivo,
        spotifyPlaylistId: inputSpotify,
        jukeboxCooldownMinuti: 30,
        jukeboxProvider: 'spotify',
      ));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Theme.of(context).colorScheme.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
            content: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white, size: 20.0),
                SizedBox(width: 10.0),
                Text(
                  'Impostazioni Jukebox salvate con successo!',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
            content: Text('Errore durante il salvataggio: $e'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  bool _isConnectingSpotify = false;

  Future<void> _connettiSpotify() async {
    if (currentUserReference == null) return;
    setState(() => _isConnectingSpotify = true);

    try {
      final sessionId =
          'sp_${DateTime.now().millisecondsSinceEpoch}_${JukeboxService.generateCodeVerifier(8)}';
      final codeVerifier = JukeboxService.generateCodeVerifier(64);

      // Salva la sessione di autorizzazione su Firestore
      await FirebaseFirestore.instance
          .collection('spotify_auth_sessions')
          .doc(sessionId)
          .set({
        'sessionId': sessionId,
        'userId': currentUserUid,
        'codeVerifier': codeVerifier,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Salva anche il codeVerifier nel documento utente
      await currentUserReference!.update({
        'spotify_code_verifier': codeVerifier,
      });

      final authUrl = JukeboxService.createSpotifyAuthUrl(
        state: sessionId,
        codeVerifier: codeVerifier,
      );

      final uri = Uri.parse(authUrl);
      final launched =
          await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        throw Exception('Impossibile aprire il browser per l\'autorizzazione.');
      }

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (dialogCtx) {
            return StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('spotify_auth_sessions')
                  .doc(sessionId)
                  .snapshots(),
              builder: (ctx, snap) {
                final sessionData =
                    snap.data?.data() as Map<String, dynamic>?;
                final status = sessionData?['status'] as String?;

                if (status == 'completed') {
                  WidgetsBinding.instance.addPostFrameCallback((_) async {
                    if (Navigator.of(dialogCtx).canPop()) {
                      Navigator.of(dialogCtx).pop();
                    }
                    final accessToken =
                        sessionData?['accessToken'] as String? ?? '';
                    final refreshToken =
                        sessionData?['refreshToken'] as String? ?? '';
                    final expiresAt = sessionData?['expiresAt'] != null
                        ? (sessionData!['expiresAt'] as Timestamp).toDate()
                        : DateTime.now().add(const Duration(hours: 1));

                    await currentUserReference!.update({
                      'spotify_access_token': accessToken,
                      'spotify_refresh_token': refreshToken,
                      'spotify_token_expires_at': expiresAt,
                    });

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          backgroundColor: Color(0xFF1DB954),
                          behavior: SnackBarBehavior.floating,
                          content: Row(
                            children: [
                              Icon(
                                Icons.check_circle_rounded,
                                color: Colors.white,
                                size: 20.0,
                              ),
                              SizedBox(width: 10.0),
                              Text(
                                'Spotify Connect collegato con successo!',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                  });
                }

                return AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  title: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1DB954).withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.graphic_eq_rounded,
                          color: Color(0xFF1DB954),
                          size: 24.0,
                        ),
                      ),
                      const SizedBox(width: 12.0),
                      const Expanded(
                        child: Text(
                          'Collegamento Spotify',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 8.0),
                      const CircularProgressIndicator(
                        color: Color(0xFF1DB954),
                      ),
                      const SizedBox(height: 20.0),
                      const Text(
                        'Abbiamo aperto Spotify nel tuo browser. Accetta i permessi per completare il collegamento.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14.5, height: 1.35),
                      ),
                      const SizedBox(height: 10.0),
                      Text(
                        'Questa finestra si chiuderà da sola non appena confermi.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12.0,
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(dialogCtx).pop(),
                      child: const Text('Annulla'),
                    ),
                  ],
                );
              },
            );
          },
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Theme.of(context).colorScheme.error,
            content: Text('Errore collegamento Spotify: $e'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isConnectingSpotify = false);
    }
  }

  Future<void> _disconnettiSpotify() async {
    if (currentUserReference == null) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Disconnetti Spotify'),
        content: const Text(
          'Vuoi davvero scollegare il tuo account Spotify? Le richieste dei clienti rimarranno nella lista del menu ma non potranno essere inviate automaticamente al player.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Annulla'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Disconnetti'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await currentUserReference!.update({
        'spotify_access_token': FieldValue.delete(),
        'spotify_refresh_token': FieldValue.delete(),
        'spotify_token_expires_at': FieldValue.delete(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account Spotify disconnesso.'),
          ),
        );
      }
    }
  }

  bool _isTestingPlayer = false;

  Future<void> _testaPlayer(UsersRecord user) async {
    setState(() => _isTestingPlayer = true);
    try {
      final res = await JukeboxService.testSpotifyPlayer(user: user);
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18.0),
            ),
            title: Row(
              children: [
                Icon(
                  res.success
                      ? Icons.check_circle_rounded
                      : Icons.info_outline_rounded,
                  color: res.success ? const Color(0xFF1DB954) : Colors.orange,
                  size: 24.0,
                ),
                const SizedBox(width: 10.0),
                Text(
                  res.success ? 'Player Pronto' : 'Stato Player',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0,
                  ),
                ),
              ],
            ),
            content: Text(
              res.message,
              style: const TextStyle(fontSize: 14.5, height: 1.35),
            ),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: res.success
                      ? const Color(0xFF1DB954)
                      : Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isTestingPlayer = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return StreamBuilder<UsersRecord>(
      stream: UsersRecord.getDocument(currentUserReference!),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          _initFields(snapshot.data!);
        }

        return Scaffold(
          key: scaffoldKey,
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            elevation: 0.0,
            centerTitle: true,
            automaticallyImplyLeading: false,
            backgroundColor: theme.appBarTheme.backgroundColor ?? theme.cardColor,
            leading: FlutterFlowIconButton(
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
                    Icons.music_note_rounded,
                    color: theme.colorScheme.primary,
                    size: 20.0,
                  ),
                ),
                const SizedBox(width: 10.0),
                Text(
                  'Jukebox & Musica',
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
            actions: const [
              SizedBox(width: 48.0),
            ],
          ),
          body: SafeArea(
            top: true,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 650.0),
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
                  children: [
                    // Scheda 1: Attivazione Jukebox
                    Card(
                      elevation: 0.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                        side: BorderSide(
                          color: theme.dividerColor.withValues(alpha: 0.6),
                        ),
                      ),
                      color: theme.cardColor,
                      child: Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 42.0,
                                  height: 42.0,
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  child: Icon(
                                    Icons.queue_music_rounded,
                                    color: theme.colorScheme.primary,
                                    size: 24.0,
                                  ),
                                ),
                                const SizedBox(width: 14.0),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Jukebox per i Clienti',
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 2.0),
                                      Text(
                                        'Consenti ai clienti al tavolo di richiedere brani dalla tua playlist',
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Switch(
                                  value: _model.jukeboxAttivo,
                                  activeTrackColor: theme.colorScheme.primary,
                                  onChanged: (val) {
                                    setState(() {
                                      _model.jukeboxAttivo = val;
                                    });
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 14.0),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.timer_outlined,
                                    size: 16.0,
                                    color: theme.colorScheme.primary,
                                  ),
                                  const SizedBox(width: 8.0),
                                  Expanded(
                                    child: Text(
                                      'Regola attiva: Massimo 1 richiesta ogni 30 minuti per tavolo.',
                                      style: TextStyle(
                                        color: theme.colorScheme.primary,
                                        fontSize: 12.0,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 18.0),

                    // Scheda: Collegamento Spotify Connect
                      Builder(
                        builder: (context) {
                          final isSpotifyConnected = snapshot.data != null &&
                              snapshot.data!.spotifyAccessToken.isNotEmpty;

                          return Card(
                            elevation: 0.0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0),
                              side: BorderSide(
                                color: isSpotifyConnected
                                    ? const Color(0xFF1DB954).withValues(alpha: 0.5)
                                    : theme.dividerColor.withValues(alpha: 0.6),
                                width: isSpotifyConnected ? 1.5 : 1.0,
                              ),
                            ),
                            color: theme.cardColor,
                            child: Padding(
                              padding: const EdgeInsets.all(18.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 42.0,
                                        height: 42.0,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF1DB954)
                                              .withValues(alpha: 0.15),
                                          borderRadius:
                                              BorderRadius.circular(12.0),
                                        ),
                                        child: const Icon(
                                          Icons.graphic_eq_rounded,
                                          color: Color(0xFF1DB954),
                                          size: 24.0,
                                        ),
                                      ),
                                      const SizedBox(width: 14.0),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  'Spotify Connect',
                                                  style: theme
                                                      .textTheme.titleMedium
                                                      ?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(width: 8.0),
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 8.0,
                                                    vertical: 3.0,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: isSpotifyConnected
                                                        ? const Color(0xFF1DB954)
                                                            .withValues(
                                                                alpha: 0.15)
                                                        : theme
                                                            .colorScheme
                                                            .surfaceContainerHighest,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                  ),
                                                  child: Text(
                                                    isSpotifyConnected
                                                        ? 'COLLEGATO'
                                                        : 'OPZIONALE',
                                                    style: TextStyle(
                                                      fontSize: 10.5,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: isSpotifyConnected
                                                          ? const Color(
                                                              0xFF1DB954)
                                                          : theme.hintColor,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 2.0),
                                            Text(
                                              isSpotifyConnected
                                                  ? 'Account autorizzato. Le richieste vengono inviate al tuo player Spotify.'
                                                  : 'Per l\'accodamento automatico via API (richiede Spotify Premium).',
                                              style: theme.textTheme.bodySmall
                                                  ?.copyWith(
                                                color: theme
                                                    .textTheme.bodySmall?.color
                                                    ?.withValues(alpha: 0.8),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16.0),
                                  if (isSpotifyConnected) ...[
                                    Container(
                                      padding: const EdgeInsets.all(12.0),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF1DB954)
                                            .withValues(alpha: 0.08),
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                        border: Border.all(
                                          color: const Color(0xFF1DB954)
                                              .withValues(alpha: 0.25),
                                        ),
                                      ),
                                      child: const Row(
                                        children: [
                                          Icon(
                                            Icons.check_circle_rounded,
                                            color: Color(0xFF1DB954),
                                            size: 18.0,
                                          ),
                                          SizedBox(width: 10.0),
                                          Expanded(
                                            child: Text(
                                              'Account Spotify attivo. Le richieste dei clienti vengono inviate alla coda di riproduzione.',
                                              style: TextStyle(
                                                fontSize: 12.0,
                                                fontWeight: FontWeight.w500,
                                                height: 1.35,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 12.0),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        OutlinedButton.icon(
                                          onPressed: _isTestingPlayer ||
                                                  snapshot.data == null
                                              ? null
                                              : () => _testaPlayer(
                                                  snapshot.data!),
                                          icon: _isTestingPlayer
                                              ? const SizedBox(
                                                  width: 14.0,
                                                  height: 14.0,
                                                  child:
                                                      CircularProgressIndicator(
                                                    strokeWidth: 2.0,
                                                    color: Color(0xFF1DB954),
                                                  ),
                                                )
                                              : const Icon(
                                                  Icons.speaker_group_outlined,
                                                  size: 16.0,
                                                  color: Color(0xFF1DB954),
                                                ),
                                          label: const Text(
                                            'Testa Player',
                                            style: TextStyle(
                                              color: Color(0xFF1DB954),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12.5,
                                            ),
                                          ),
                                          style: OutlinedButton.styleFrom(
                                            side: const BorderSide(
                                              color: Color(0xFF1DB954),
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12.0,
                                              vertical: 8.0,
                                            ),
                                          ),
                                        ),
                                        TextButton.icon(
                                          onPressed: _disconnettiSpotify,
                                          icon: Icon(
                                            Icons.link_off_rounded,
                                            size: 16.0,
                                            color: theme.colorScheme.error,
                                          ),
                                          label: Text(
                                            'Disconnetti',
                                            style: TextStyle(
                                              color: theme.colorScheme.error,
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ] else ...[
                                    SizedBox(
                                      width: double.infinity,
                                      height: 46.0,
                                      child: ElevatedButton.icon(
                                        onPressed: _isConnectingSpotify
                                            ? null
                                            : _connettiSpotify,
                                        icon: _isConnectingSpotify
                                            ? const SizedBox(
                                                width: 18.0,
                                                height: 18.0,
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth: 2.0,
                                                  color: Colors.white,
                                                ),
                                              )
                                            : const Icon(Icons.link_rounded,
                                                size: 20.0),
                                        label: Text(
                                          _isConnectingSpotify
                                              ? 'Connessione in corso...'
                                              : 'Collega Account Spotify (1 Click)',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14.5,
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFF1DB954),
                                          foregroundColor: Colors.white,
                                          elevation: 0.0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 18.0),

                      // Scheda Playlist Spotify
                      Card(
                        elevation: 0.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                          side: BorderSide(
                            color: theme.dividerColor.withValues(alpha: 0.6),
                          ),
                        ),
                        color: theme.cardColor,
                        child: Padding(
                          padding: const EdgeInsets.all(18.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 36.0,
                                    height: 36.0,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1DB954)
                                          .withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    child: const Icon(
                                      Icons.playlist_play_rounded,
                                      color: Color(0xFF1DB954),
                                      size: 22.0,
                                    ),
                                  ),
                                  const SizedBox(width: 12.0),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Playlist Spotify del Locale',
                                          style: theme.textTheme.titleSmall
                                              ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          'Link della playlist da cui i clienti possono scegliere',
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                            color: theme.hintColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16.0),
                              TextFormField(
                                controller: _model.playlistController,
                                focusNode: _model.playlistFocusNode,
                                decoration: InputDecoration(
                                  hintText:
                                      'https://open.spotify.com/playlist/...',
                                  hintStyle:
                                      theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.hintColor,
                                  ),
                                  prefixIcon: const Icon(Icons.link_rounded,
                                      size: 20.0),
                                  suffixIcon: IconButton(
                                    icon: const Icon(Icons.paste_rounded,
                                        size: 20.0),
                                    tooltip: 'Incolla dagli appunti',
                                    onPressed: () async {
                                      final data = await Clipboard.getData(
                                          Clipboard.kTextPlain);
                                      if (data?.text != null) {
                                        _model.playlistController?.text =
                                            data!.text!;
                                        setState(() {});
                                      }
                                    },
                                  ),
                                  filled: true,
                                  fillColor: theme.scaffoldBackgroundColor,
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16.0, vertical: 14.0),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                    borderSide:
                                        BorderSide(color: theme.dividerColor),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                    borderSide:
                                        BorderSide(color: theme.dividerColor),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                    borderSide: BorderSide(
                                        color: theme.colorScheme.primary,
                                        width: 2.0),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    

                    const SizedBox(height: 18.0),

                    // Scheda: Coda Live delle Richieste dei Clienti
                    StreamBuilder<List<JukeboxRequestsRecord>>(
                      stream: queryJukeboxRequestsRecord(
                        queryBuilder: (q) => q
                            .where(
                              'ristoranteRef',
                              isEqualTo: currentUserReference,
                            )
                            .where('status', isEqualTo: 'in_coda'),
                      ),
                      builder: (context, snapshot) {
                        final rawRequests = snapshot.data ?? [];
                        final requests = List<JukeboxRequestsRecord>.from(rawRequests)
                          ..sort((a, b) {
                            final aDate = a.requestedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
                            final bDate = b.requestedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
                            return aDate.compareTo(bDate);
                          });

                        if (requests.isEmpty) {
                          return const SizedBox.shrink();
                        }

                        return Card(
                          elevation: 0.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                            side: BorderSide(
                              color: const Color(0xFF1DB954)
                                  .withValues(alpha: 0.35),
                              width: 1.2,
                            ),
                          ),
                          color: theme.cardColor,
                          child: Padding(
                            padding: const EdgeInsets.all(18.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 36.0,
                                      height: 36.0,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF1DB954)
                                            .withValues(alpha: 0.15),
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                      child: const Icon(
                                        Icons.queue_music_rounded,
                                        color: Color(0xFF1DB954),
                                        size: 20.0,
                                      ),
                                    ),
                                    const SizedBox(width: 12.0),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Coda Richieste Clienti (${requests.length})',
                                            style: theme.textTheme.titleSmall
                                                ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            'Ordine cronologico di riproduzione',
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                              color: theme.hintColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14.0),
                                ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: requests.length,
                                  separatorBuilder: (_, __) =>
                                      const Divider(height: 16.0),
                                  itemBuilder: (context, idx) {
                                    final req = requests[idx];
                                    final isNext = idx == 0;
                                    return Row(
                                      children: [
                                        Container(
                                          width: 28.0,
                                          height: 28.0,
                                          decoration: BoxDecoration(
                                            color: isNext
                                                ? const Color(0xFF1DB954)
                                                : theme.colorScheme
                                                    .surfaceContainerHighest,
                                            shape: BoxShape.circle,
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(
                                            '${idx + 1}',
                                            style: TextStyle(
                                              color: isNext
                                                  ? Colors.white
                                                  : theme.colorScheme.onSurface,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12.0,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12.0),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                req.trackTitle,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 13.5,
                                                ),
                                              ),
                                              Text(
                                                '${req.artistName} • ${isNext ? "PROSSIMA IN RIPRODUZIONE" : "IN CODA"}',
                                                style: TextStyle(
                                                  fontSize: 11.0,
                                                  fontWeight: isNext
                                                      ? FontWeight.bold
                                                      : FontWeight.normal,
                                                  color: isNext
                                                      ? const Color(0xFF1DB954)
                                                      : theme.hintColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.check_circle_outline_rounded,
                                            size: 20.0,
                                          ),
                                          tooltip: 'Segna come riprodotta',
                                          color: theme.hintColor,
                                          onPressed: () async {
                                            await req.reference
                                                .update({'status': 'riprodotta'});
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 28.0),

                    // Bottone Salva
                    SizedBox(
                      width: double.infinity,
                      height: 50.0,
                      child: ElevatedButton.icon(
                        onPressed: _isSaving ? null : _salva,
                        icon: _isSaving
                            ? const SizedBox(
                                width: 20.0,
                                height: 20.0,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.save_rounded, size: 20.0),
                        label: Text(
                          _isSaving ? 'Salvataggio in corso...' : 'Salva Impostazioni Jukebox',
                          style: const TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: Colors.white,
                          elevation: 0.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.0),
                          ),
                        ),
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
  }
}
