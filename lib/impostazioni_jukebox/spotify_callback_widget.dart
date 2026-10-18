import 'package:flutter/material.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/services/jukebox_service.dart';

class SpotifyCallbackWidget extends StatefulWidget {
  const SpotifyCallbackWidget({
    super.key,
    this.code,
    this.state,
    this.error,
  });

  final String? code;
  final String? state;
  final String? error;

  static String routeName = 'SpotifyCallback';
  static String routePath = '/spotify-callback';

  @override
  State<SpotifyCallbackWidget> createState() => _SpotifyCallbackWidgetState();
}

class _SpotifyCallbackWidgetState extends State<SpotifyCallbackWidget> {
  bool _isLoading = true;
  bool _isSuccess = false;
  String _statusMessage = 'Elaborazione del collegamento con Spotify in corso...';
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _processCallback();
    });
  }

  Future<void> _processCallback() async {
    if (widget.error != null && widget.error!.isNotEmpty) {
      setState(() {
        _isLoading = false;
        _isSuccess = false;
        _errorMessage = 'Autorizzazione rifiutata da Spotify: ${widget.error}';
      });
      return;
    }

    final code = widget.code;
    final sessionId = widget.state;

    if (code == null || code.isEmpty || sessionId == null || sessionId.isEmpty) {
      setState(() {
        _isLoading = false;
        _isSuccess = false;
        _errorMessage = 'Parametri di autorizzazione mancanti o non validi.';
      });
      return;
    }

    try {
      // 1. Recupera la sessione creata dall'app
      final sessionDoc = await FirebaseFirestore.instance
          .collection('spotify_auth_sessions')
          .doc(sessionId)
          .get();

      if (!sessionDoc.exists) {
        setState(() {
          _isLoading = false;
          _isSuccess = false;
          _errorMessage =
              'Sessione di autorizzazione non trovata o scaduta. Riprova dalle Impostazioni Jukebox.';
        });
        return;
      }

      final data = sessionDoc.data() ?? {};
      final codeVerifier = data['codeVerifier'] as String?;
      final userId = data['userId'] as String?;

      if (codeVerifier == null || codeVerifier.isEmpty) {
        setState(() {
          _isLoading = false;
          _isSuccess = false;
          _errorMessage = 'Verificatore PKCE non valido. Riprova.';
        });
        return;
      }

      // 2. Scambia il code con i token reali
      setState(() {
        _statusMessage = 'Connessione a Spotify Web API...';
      });

      final tokens = await JukeboxService.exchangeCodeForTokens(
        code: code,
        codeVerifier: codeVerifier,
      );

      if (tokens == null || tokens['access_token'] == null) {
        setState(() {
          _isLoading = false;
          _isSuccess = false;
          _errorMessage =
              'Impossibile scambiare il codice di autorizzazione. Verifica il Client ID nel Developer Dashboard.';
        });
        return;
      }

      final accessToken = tokens['access_token'] as String;
      final newRefreshToken = (tokens['refresh_token'] as String? ?? '').trim();
      final expiresIn = tokens['expires_in'] as int? ?? 3600;
      final expiryDate = DateTime.now().add(Duration(seconds: expiresIn));

      String finalRefreshToken = newRefreshToken;
      if (finalRefreshToken.isEmpty && userId != null && userId.isNotEmpty) {
        try {
          final userSnap = await FirebaseFirestore.instance.collection('users').doc(userId).get();
          final userData = userSnap.data();
          final existingRefreshToken = (userData?['spotify_refresh_token'] as String? ?? '').trim();
          if (existingRefreshToken.isNotEmpty) {
            finalRefreshToken = existingRefreshToken;
          }
        } catch (_) {}
      }

      // 3. Notifica la sessione Firestore affinché l'app aperta su mobile/desktop rilevi subito il successo
      final sessionUpdate = <String, dynamic>{
        'status': 'completed',
        'accessToken': accessToken,
        'expiresAt': expiryDate,
        'expiresIn': expiresIn,
      };
      if (finalRefreshToken.isNotEmpty) {
        sessionUpdate['refreshToken'] = finalRefreshToken;
      }

      await FirebaseFirestore.instance
          .collection('spotify_auth_sessions')
          .doc(sessionId)
          .update(sessionUpdate);

      // 4. Se presente lo userId, aggiorna anche direttamente il documento utente
      if (userId != null && userId.isNotEmpty) {
        try {
          final userUpdate = <String, dynamic>{
            'spotify_access_token': accessToken,
            'spotify_token_expires_at': expiryDate,
          };
          if (finalRefreshToken.isNotEmpty) {
            userUpdate['spotify_refresh_token'] = finalRefreshToken;
          }
          await FirebaseFirestore.instance.collection('users').doc(userId).update(userUpdate);
        } catch (e) {
          debugPrint('Aggiornamento diretto utente non riuscito (gestito dall\'app): $e');
        }
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
          _isSuccess = true;
          _statusMessage = 'Account Spotify collegato con successo!';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isSuccess = false;
          _errorMessage = 'Si è verificato un errore: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0.0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: theme.appBarTheme.backgroundColor ?? theme.cardColor,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36.0,
              height: 36.0,
              decoration: BoxDecoration(
                color: const Color(0xFF1DB954).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10.0),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.music_note_rounded,
                color: Color(0xFF1DB954),
                size: 20.0,
              ),
            ),
            const SizedBox(width: 10.0),
            Text(
              'Spotify Jukebox',
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
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520.0),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
              child: Card(
                elevation: 0.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24.0),
                  side: BorderSide(
                    color: theme.dividerColor.withValues(alpha: 0.6),
                  ),
                ),
                color: theme.cardColor,
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_isLoading) ...[
                        const SizedBox(
                          width: 56.0,
                          height: 56.0,
                          child: CircularProgressIndicator(
                            strokeWidth: 3.5,
                            color: Color(0xFF1DB954),
                          ),
                        ),
                        const SizedBox(height: 24.0),
                        Text(
                          'Collegamento in corso...',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10.0),
                        Text(
                          _statusMessage,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.hintColor,
                          ),
                        ),
                      ] else if (_isSuccess) ...[
                        Container(
                          width: 72.0,
                          height: 72.0,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1DB954).withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.check_circle_rounded,
                            color: Color(0xFF1DB954),
                            size: 46.0,
                          ),
                        ),
                        const SizedBox(height: 20.0),
                        Text(
                          'Account Spotify Collegato!',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1DB954),
                          ),
                        ),
                        const SizedBox(height: 12.0),
                        Text(
                          'Il tuo Spotify Connect è pronto. Quando un cliente richiede una canzone dal Jukebox, questa verrà inserita nella coda di riproduzione del tuo locale.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 28.0),
                        SizedBox(
                          width: double.infinity,
                          height: 48.0,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1DB954),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                            ),
                            icon: const Icon(Icons.arrow_back_rounded, size: 20.0),
                            label: const Text(
                              'Torna all\'app ProntoMenu',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            onPressed: () {
                              if (context.canPop()) {
                                context.pop();
                              } else {
                                context.goNamed('SmistamentoLogin');
                              }
                            },
                          ),
                        ),
                      ] else ...[
                        Container(
                          width: 72.0,
                          height: 72.0,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.error.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.error_outline_rounded,
                            color: theme.colorScheme.error,
                            size: 44.0,
                          ),
                        ),
                        const SizedBox(height: 20.0),
                        Text(
                          'Collegamento non riuscito',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.error,
                          ),
                        ),
                        const SizedBox(height: 12.0),
                        Text(
                          _errorMessage ?? 'Si è verificato un errore imprevisto.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.hintColor,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 28.0),
                        SizedBox(
                          width: double.infinity,
                          height: 48.0,
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                            ),
                            icon: const Icon(Icons.arrow_back_rounded, size: 20.0),
                            label: const Text(
                              'Ritorna alle impostazioni',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            onPressed: () {
                              if (context.canPop()) {
                                context.pop();
                              } else {
                                context.goNamed('SmistamentoLogin');
                              }
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
