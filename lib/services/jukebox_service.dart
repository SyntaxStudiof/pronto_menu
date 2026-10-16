import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '/backend/backend.dart';

class SpotifyTrack {
  final String id;
  final String title;
  final String artist;
  final String album;
  final String coverUrl;
  final int durationMs;
  final String? previewUrl;
  final String provider;
  final bool isPlaying;

  const SpotifyTrack({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.coverUrl,
    required this.durationMs,
    this.previewUrl,
    this.provider = 'spotify',
    this.isPlaying = false,
  });

  String get formattedDuration {
    final minutes = durationMs ~/ 60000;
    final seconds = ((durationMs % 60000) ~/ 1000).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

class JukeboxService {
  static const String kDefaultSpotifyClientId = '5eaaea0591574f8d921ac68e07958885';
  static const String kSpotifyRedirectUri = 'https://prontomenu-6d485.web.app/spotify-callback';
  static const String _kLastRequestPrefix = 'jukebox_last_request_';

  /// Estrae l'ID pulito di una playlist Spotify da link URL, URI o stringa grezza
  static String extractPlaylistId(String input) {
    final info = extractSpotifyInfo(input);
    return info.$2;
  }

  /// Estrae il tipo ('playlist' o 'album') e l'ID pulito
  static (String, String) extractSpotifyInfo(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return ('playlist', '');

    // Esempio: https://open.spotify.com/album/4vR1jB...
    final albumRegex = RegExp(r'album\/([a-zA-Z0-9_-]+)');
    final albumMatch = albumRegex.firstMatch(trimmed);
    if (albumMatch != null && albumMatch.groupCount >= 1) {
      return ('album', albumMatch.group(1)!);
    }

    // Esempio: https://open.spotify.com/playlist/... o /intl-it/playlist/...
    final urlRegex = RegExp(r'playlist\/([a-zA-Z0-9_-]+)');
    final match = urlRegex.firstMatch(trimmed);
    if (match != null && match.groupCount >= 1) {
      return ('playlist', match.group(1)!);
    }

    // Esempio: spotify:playlist:37i9dQZF1DXcBWIGoYBM5M
    if (trimmed.startsWith('spotify:playlist:')) {
      return (
        'playlist',
        trimmed.replaceFirst('spotify:playlist:', '').split('?').first
      );
    }

    if (trimmed.startsWith('spotify:album:')) {
      return (
        'album',
        trimmed.replaceFirst('spotify:album:', '').split('?').first
      );
    }

    final clean = trimmed.split('?').first;
    return ('playlist', clean);
  }

  /// Verifica se il cliente può effettuare una nuova richiesta o quanto tempo deve ancora attendere
  static Future<Duration> getRemainingCooldown({
    required String ristoranteId,
    int cooldownMinutes = 30,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_kLastRequestPrefix$ristoranteId';
    final lastMs = prefs.getInt(key);

    if (lastMs == null) {
      return Duration.zero;
    }

    final lastRequestTime = DateTime.fromMillisecondsSinceEpoch(lastMs);
    final elapsed = DateTime.now().difference(lastRequestTime);
    final cooldownDuration = Duration(minutes: cooldownMinutes);

    if (elapsed >= cooldownDuration) {
      return Duration.zero;
    }

    return cooldownDuration - elapsed;
  }

  /// Registra l'orario dell'ultima richiesta effettuata dal cliente
  static Future<void> recordRequest({
    required String ristoranteId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_kLastRequestPrefix$ristoranteId';
    await prefs.setInt(key, DateTime.now().millisecondsSinceEpoch);
  }

  /// Estrae i brani da un link pubblico di Apple Music (Playlist o Album)
  static Future<List<SpotifyTrack>> fetchAppleMusicTracks(
      String playlistUrl) async {
    try {
      final cleanUrl = playlistUrl.trim();
      if (!cleanUrl.startsWith('http')) return [];

      final response = await http.get(
        Uri.parse(cleanUrl),
        headers: {
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
          'Accept': 'text/html,application/xhtml+xml',
          'Accept-Language': 'it-IT,it;q=0.9,en-US;q=0.8,en;q=0.7',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        debugPrint('Errore fetch Apple Music: ${response.statusCode}');
        return [];
      }

      final body = response.body;

      // Cerca il tag schema.org JSON-LD
      final ldJsonRegex = RegExp(
        r'<script type="application\/ld\+json"[^>]*>([\s\S]*?)<\/script>',
        caseSensitive: false,
      );
      final matches = ldJsonRegex.allMatches(body);

      for (final match in matches) {
        final jsonStr = match.group(1)?.trim();
        if (jsonStr == null || jsonStr.isEmpty) continue;

        try {
          final data = jsonDecode(jsonStr);
          List<dynamic>? tracksData;

          if (data is Map<String, dynamic>) {
            if (data['track'] is List) {
              tracksData = data['track'] as List<dynamic>;
            }
          } else if (data is List) {
            for (final item in data) {
              if (item is Map && item['track'] is List) {
                tracksData = item['track'] as List<dynamic>;
                break;
              }
            }
          }

          if (tracksData != null && tracksData.isNotEmpty) {
            final List<SpotifyTrack> result = [];
            for (int i = 0; i < tracksData.length; i++) {
              final t = tracksData[i];
              if (t is! Map) continue;

              final title = t['name'] as String? ?? 'Brano sconosciuto';

              String artist = 'Artista';
              if (t['byArtist'] is List && (t['byArtist'] as List).isNotEmpty) {
                artist = (t['byArtist'] as List)
                    .map((a) => a['name']?.toString() ?? '')
                    .where((s) => s.isNotEmpty)
                    .join(', ');
              } else if (t['byArtist'] is Map) {
                artist = t['byArtist']['name'] as String? ?? 'Artista';
              }

              String cover = '';
              if (t['image'] is String) {
                cover = t['image'] as String;
              } else if (t['image'] is Map && t['image']['url'] != null) {
                cover = t['image']['url'] as String;
              }

              int durationMs = 180000;
              final durationStr = t['duration'] as String? ?? '';
              if (durationStr.isNotEmpty) {
                final dMatch = RegExp(r'PT(?:(\d+)M)?(?:(\d+)S)?')
                    .firstMatch(durationStr);
                if (dMatch != null) {
                  final minutes = int.tryParse(dMatch.group(1) ?? '0') ?? 0;
                  final seconds = int.tryParse(dMatch.group(2) ?? '0') ?? 0;
                  durationMs = (minutes * 60 + seconds) * 1000;
                }
              }

              final trackId = t['@id']?.toString() ?? 'apple_$i';

              result.add(
                SpotifyTrack(
                  id: trackId,
                  title: title,
                  artist: artist,
                  album: 'Apple Music',
                  coverUrl: cover.isNotEmpty
                      ? cover
                      : 'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=300',
                  durationMs: durationMs,
                  provider: 'apple_music',
                ),
              );
            }

            if (result.isNotEmpty) {
              return result;
            }
          }
        } catch (e) {
          debugPrint('Errore parsing JSON-LD Apple Music: $e');
        }
      }
    } catch (e) {
      debugPrint('Errore generale fetchAppleMusicTracks: $e');
    }
    return [];
  }

  /// Recupera i brani per il ristorante in base alla piattaforma configurata (Spotify o Apple Music)
  static Future<List<SpotifyTrack>> fetchTracksForRestaurant(
      UsersRecord ristorante) async {
    if (ristorante.jukeboxProvider == 'apple_music') {
      if (ristorante.appleMusicPlaylistUrl.isNotEmpty) {
        final tracks =
            await fetchAppleMusicTracks(ristorante.appleMusicPlaylistUrl);
        if (tracks.isNotEmpty) return tracks;
      }
      return _sampleTracks;
    } else {
      return fetchPlaylistTracks(playlistId: ristorante.spotifyPlaylistId);
    }
  }

  /// Carica i brani reali della playlist Spotify fornita.
  /// 1. Tenta prima l'estrazione diretta dall'embed pubblico di Spotify (funziona per qualsiasi playlist pubblica senza bisogno di chiavi API).
  /// 2. Se presenti Client ID e Secret, tenta la chiamata Web API ufficiale.
  /// 3. In caso di link vuoto o errore, fa fallback sulla selezione demo.
  static Future<List<SpotifyTrack>> fetchPlaylistTracks({
    required String playlistId,
    String? clientId,
    String? clientSecret,
  }) async {
    final (type, cleanId) = extractSpotifyInfo(playlistId);

    if (cleanId.isNotEmpty) {
      // 1. Tenta caricamento diretto da embed pubblico Spotify (senza bisogno di chiavi)
      final embedTracks = await _fetchTracksFromEmbed(id: cleanId, type: type);
      if (embedTracks != null && embedTracks.isNotEmpty) {
        return embedTracks;
      }

      // 2. Se sono configurati Client ID e Secret, tenta tramite Spotify Web API
      if (clientId != null &&
          clientId.trim().isNotEmpty &&
          clientSecret != null &&
          clientSecret.trim().isNotEmpty) {
        try {
          final token = await _getSpotifyAccessToken(
            clientId.trim(),
            clientSecret.trim(),
          );
          if (token != null) {
            final res = await http.get(
              Uri.parse(
                'https://api.spotify.com/v1/playlists/$cleanId/tracks?limit=50',
              ),
              headers: {'Authorization': 'Bearer $token'},
            );
            if (res.statusCode == 200) {
              final data = jsonDecode(res.body);
              final items = data['items'] as List<dynamic>? ?? [];
              final tracks = <SpotifyTrack>[];
              for (final item in items) {
                final track = item['track'];
                if (track != null && track['id'] != null) {
                  final album = track['album'];
                  final images = album?['images'] as List<dynamic>? ?? [];
                  final cover = images.isNotEmpty
                      ? (images.first['url'] as String? ?? '')
                      : '';
                  final artistsList =
                      track['artists'] as List<dynamic>? ?? [];
                  final artistsStr = artistsList
                      .map((a) => a['name'] as String? ?? '')
                      .where((n) => n.isNotEmpty)
                      .join(', ');

                  tracks.add(SpotifyTrack(
                    id: track['id'] as String,
                    title: track['name'] as String? ?? 'Senza titolo',
                    artist: artistsStr.isNotEmpty
                        ? artistsStr
                        : 'Artista sconosciuto',
                    album: album?['name'] as String? ?? '',
                    coverUrl: cover,
                    durationMs: track['duration_ms'] as int? ?? 180000,
                    previewUrl: track['preview_url'] as String?,
                  ));
                }
              }
              if (tracks.isNotEmpty) {
                return tracks;
              }
            }
          }
        } catch (e) {
          debugPrint('Errore caricamento brani Spotify API: $e');
        }
      }
    }

    // Fallback: Playlist dimostrativa (stile bistrot / lounge dinner)
    return _sampleTracks;
  }

  /// Cache in memoria per le copertine dei singoli brani
  static final Map<String, String> _trackCoverCache = {};

  /// Recupera la copertina specifica del singolo brano tramite oEmbed Spotify
  static Future<String> _fetchSingleTrackCover(String trackId, String fallbackCover) async {
    if (trackId.isEmpty || trackId.startsWith('track_') || trackId.startsWith('demo_')) {
      return fallbackCover;
    }
    if (_trackCoverCache.containsKey(trackId)) {
      return _trackCoverCache[trackId]!;
    }
    try {
      final oRes = await http.get(
        Uri.parse('https://open.spotify.com/oembed?url=https://open.spotify.com/track/$trackId'),
      ).timeout(const Duration(seconds: 4));
      if (oRes.statusCode == 200) {
        final oData = jsonDecode(oRes.body);
        final thumb = oData['thumbnail_url'] as String?;
        if (thumb != null && thumb.isNotEmpty) {
          _trackCoverCache[trackId] = thumb;
          return thumb;
        }
      }
    } catch (_) {}
    return fallbackCover;
  }

  /// Estrae i brani dall'embed pubblico di Spotify (senza richiedere credenziali developer)
  static Future<List<SpotifyTrack>?> _fetchTracksFromEmbed({
    required String id,
    String type = 'playlist',
  }) async {
    try {
      final url = Uri.parse('https://open.spotify.com/embed/$type/$id');
      final res = await http.get(
        url,
        headers: {
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
          'Accept-Language': 'it,en;q=0.9',
        },
      ).timeout(const Duration(seconds: 8));

      if (res.statusCode == 200) {
        final html = res.body;
        final match = RegExp(
          r'<script\s+id="__NEXT_DATA__"[^>]*>([\s\S]*?)<\/script>',
        ).firstMatch(html);

        if (match != null) {
          final jsonStr = match.group(1)!;
          final data = jsonDecode(jsonStr);
          final entity =
              data['props']?['pageProps']?['state']?['data']?['entity'];
          if (entity != null) {
            final visualIdentity = entity['visualIdentity'];
            final images = visualIdentity?['image'] as List<dynamic>? ?? [];
            String coverUrl = '';
            if (images.isNotEmpty) {
              coverUrl = images.last['url'] as String? ?? '';
            }

            final rawTrackList = entity['trackList'] as List<dynamic>? ?? [];
            final validItems = rawTrackList.whereType<Map>().toList();

            // Recupera in parallelo le copertine dei singoli brani
            final List<String> individualCovers = await Future.wait(
              validItems.map((item) {
                final uri = item['uri'] as String? ?? '';
                final trackId = uri.startsWith('spotify:track:')
                    ? uri.replaceFirst('spotify:track:', '')
                    : (item['uid'] as String? ?? '');
                return _fetchSingleTrackCover(trackId, coverUrl);
              }),
            );

            final tracks = <SpotifyTrack>[];
            for (int i = 0; i < validItems.length; i++) {
              final item = validItems[i];
              final uri = item['uri'] as String? ?? '';
              final trackId = uri.startsWith('spotify:track:')
                  ? uri.replaceFirst('spotify:track:', '')
                  : (item['uid'] as String? ?? '');
              final title = item['title'] as String? ?? '';
              final artist = item['subtitle'] as String? ?? '';
              final duration = item['duration'] as int? ?? 180000;
              final audioPreview = item['audioPreview'] as Map?;
              final previewUrl = audioPreview?['url'] as String?;
              final trackCover = i < individualCovers.length ? individualCovers[i] : coverUrl;

              if (title.isNotEmpty) {
                tracks.add(SpotifyTrack(
                  id: trackId.isNotEmpty
                      ? trackId
                      : 'track_${tracks.length}',
                  title: title,
                  artist:
                      artist.isNotEmpty ? artist : 'Artista sconosciuto',
                  album: entity['name'] as String? ??
                      entity['title'] as String? ??
                      '',
                  coverUrl: trackCover.isNotEmpty ? trackCover : coverUrl,
                  durationMs: duration,
                  previewUrl: previewUrl,
                ));
              }
            }
            if (tracks.isNotEmpty) {
              return tracks;
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Errore estrazione brani da Spotify embed: $e');
    }
    return null;
  }

  static Future<String?> _getSpotifyAccessToken(String clientId, String clientSecret) async {
    try {
      final credentials = base64Encode(utf8.encode('$clientId:$clientSecret'));
      final response = await http.post(
        Uri.parse('https://accounts.spotify.com/api/token'),
        headers: {
          'Authorization': 'Basic $credentials',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {'grant_type': 'client_credentials'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['access_token'] as String?;
      }
    } catch (_) {}
    return null;
  }

  /// Invia la canzone richiesta a Spotify del locale:
  /// - Se la musica sta suonando: la mette in coda (subito successiva / FIFO).
  /// - Se la musica è ferma / in pausa: avvia la riproduzione immediata del brano.
  /// Genera una stringa casuale (code verifier) per OAuth 2.0 PKCE
  static String generateCodeVerifier([int length = 64]) {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~';
    final random = Random.secure();
    return List.generate(length, (_) => chars[random.nextInt(chars.length)]).join();
  }

  /// Calcola il code challenge da code verifier usando SHA-256 e Base64-URL senza padding
  static String generateCodeChallenge(String verifier) {
    final bytes = ascii.encode(verifier);
    final digest = sha256.convert(bytes);
    return base64UrlEncode(digest.bytes).replaceAll('=', '');
  }

  /// Crea l'URL di autorizzazione Spotify per il ristoratore (PKCE Flow)
  static String createSpotifyAuthUrl({
    required String state,
    required String codeVerifier,
    String? clientId,
  }) {
    final effectiveClientId = (clientId != null && clientId.isNotEmpty)
        ? clientId
        : kDefaultSpotifyClientId;
    final challenge = generateCodeChallenge(codeVerifier);
    final params = {
      'response_type': 'code',
      'client_id': effectiveClientId,
      'scope':
          'user-read-playback-state user-modify-playback-state user-read-currently-playing',
      'redirect_uri': kSpotifyRedirectUri,
      'state': state,
      'code_challenge_method': 'S256',
      'code_challenge': challenge,
    };
    return Uri.https('accounts.spotify.com', '/authorize', params).toString();
  }

  /// Scambia il codice autorizzativo con Access Token e Refresh Token
  static Future<Map<String, dynamic>?> exchangeCodeForTokens({
    required String code,
    required String codeVerifier,
    String? clientId,
  }) async {
    final effectiveClientId = (clientId != null && clientId.isNotEmpty)
        ? clientId
        : kDefaultSpotifyClientId;

    try {
      final res = await http.post(
        Uri.parse('https://accounts.spotify.com/api/token'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'grant_type': 'authorization_code',
          'client_id': effectiveClientId,
          'code': code,
          'redirect_uri': kSpotifyRedirectUri,
          'code_verifier': codeVerifier,
        },
      ).timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        return jsonDecode(res.body) as Map<String, dynamic>;
      } else {
        debugPrint('Errore scambio codice Spotify: ${res.statusCode} ${res.body}');
      }
    } catch (e) {
      debugPrint('Errore exchangeCodeForTokens: $e');
    }
    return null;
  }

  /// Esegue il refresh del token di accesso scaduto tramite refresh_token
  static Future<Map<String, dynamic>?> refreshAccessToken({
    required String refreshToken,
    String? clientId,
  }) async {
    final effectiveClientId = (clientId != null && clientId.isNotEmpty)
        ? clientId
        : kDefaultSpotifyClientId;

    try {
      final res = await http.post(
        Uri.parse('https://accounts.spotify.com/api/token'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'grant_type': 'refresh_token',
          'refresh_token': refreshToken,
          'client_id': effectiveClientId,
        },
      ).timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        return jsonDecode(res.body) as Map<String, dynamic>;
      } else {
        debugPrint('Errore refresh token Spotify: ${res.statusCode} ${res.body}');
      }
    } catch (e) {
      debugPrint('Errore refreshAccessToken: $e');
    }
    return null;
  }

  /// Restituisce un token di accesso valido per il ristorante (rinfrescandolo su Firestore se scaduto)
  static Future<String?> getValidAccessToken(UsersRecord ristorante) async {
    if (ristorante.spotifyAccessToken.isEmpty) return null;

    final expiresAt = ristorante.spotifyTokenExpiresAt;
    final isExpired = expiresAt != null &&
        DateTime.now().isAfter(expiresAt.subtract(const Duration(minutes: 5)));

    if (isExpired && ristorante.spotifyRefreshToken.isNotEmpty) {
      final refreshed = await refreshAccessToken(
        refreshToken: ristorante.spotifyRefreshToken,
        clientId: ristorante.spotifyClientId.isNotEmpty
            ? ristorante.spotifyClientId
            : null,
      );

      if (refreshed != null && refreshed['access_token'] != null) {
        final newAccessToken = refreshed['access_token'] as String;
        final newRefreshToken = refreshed['refresh_token'] as String? ??
            ristorante.spotifyRefreshToken;
        final expiresIn = refreshed['expires_in'] as int? ?? 3600;

        await ristorante.reference.update({
          'spotify_access_token': newAccessToken,
          'spotify_refresh_token': newRefreshToken,
          'spotify_token_expires_at':
              DateTime.now().add(Duration(seconds: expiresIn)),
        });

        return newAccessToken;
      }
    }

    return ristorante.spotifyAccessToken;
  }

  /// Recupera il brano attualmente in riproduzione dal vivo su Spotify del locale
  static Future<SpotifyTrack?> getCurrentlyPlaying(UsersRecord ristorante) async {
    try {
      final token = await getValidAccessToken(ristorante);
      if (token == null || token.isEmpty) return null;

      final res = await http.get(
        Uri.parse('https://api.spotify.com/v1/me/player/currently-playing'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 4));

      if (res.statusCode == 200 && res.body.isNotEmpty) {
        final data = jsonDecode(res.body);
        final item = data['item'];
        final isPlaying = data['is_playing'] as bool? ?? false;
        if (item != null) {
          final album = item['album'];
          final images = album?['images'] as List<dynamic>? ?? [];
          final cover = images.isNotEmpty ? (images.first['url'] as String? ?? '') : '';
          final artistsList = item['artists'] as List<dynamic>? ?? [];
          final artistsStr = artistsList
              .map((a) => a['name'] as String? ?? '')
              .where((n) => n.isNotEmpty)
              .join(', ');

          return SpotifyTrack(
            id: item['id'] as String? ?? '',
            title: item['name'] as String? ?? 'In riproduzione',
            artist: artistsStr.isNotEmpty ? artistsStr : 'Artista',
            album: album?['name'] as String? ?? '',
            coverUrl: cover,
            durationMs: item['duration_ms'] as int? ?? 180000,
            isPlaying: isPlaying,
          );
        }
      }
    } catch (e) {
      debugPrint('Errore getCurrentlyPlaying: $e');
    }
    return null;
  }

  /// Accoda o avvia la riproduzione del brano su Spotify Connect del locale:
  /// - Se la musica sta suonando: la mette in coda (subito successiva / FIFO).
  /// - Se la musica è ferma / in pausa: avvia la riproduzione immediata del brano.
  static Future<bool> enqueueOrPlayTrackOnSpotify({
    required String accessToken,
    required String trackId,
  }) async {
    try {
      final cleanTrackId = trackId.startsWith('spotify:track:')
          ? trackId.replaceFirst('spotify:track:', '')
          : trackId;

      // 1. Controlla lo stato attuale del player
      final playerRes = await http.get(
        Uri.parse('https://api.spotify.com/v1/me/player'),
        headers: {'Authorization': 'Bearer $accessToken'},
      ).timeout(const Duration(seconds: 5));

      if (playerRes.statusCode == 200 && playerRes.body.isNotEmpty) {
        final playerData = jsonDecode(playerRes.body);
        final isPlaying = playerData['is_playing'] as bool? ?? false;

        if (isPlaying) {
          // La musica sta già suonando -> Inserisci in coda Spotify come brano successivo
          final queueRes = await http.post(
            Uri.parse(
              'https://api.spotify.com/v1/me/player/queue?uri=spotify:track:$cleanTrackId',
            ),
            headers: {'Authorization': 'Bearer $accessToken'},
          ).timeout(const Duration(seconds: 5));

          if (queueRes.statusCode == 200 || queueRes.statusCode == 204) {
            debugPrint('Brano accodato con successo su Spotify!');
            return true;
          }
        }
      }

      // 2. Se non suona o 204, controlla i dispositivi disponibili
      String? targetDeviceId;
      try {
        final devicesRes = await http.get(
          Uri.parse('https://api.spotify.com/v1/me/player/devices'),
          headers: {'Authorization': 'Bearer $accessToken'},
        ).timeout(const Duration(seconds: 5));

        if (devicesRes.statusCode == 200 && devicesRes.body.isNotEmpty) {
          final devicesData = jsonDecode(devicesRes.body);
          final devices = devicesData['devices'] as List<dynamic>? ?? [];
          if (devices.isNotEmpty) {
            final activeDevice = devices.firstWhere(
              (d) => d['is_active'] == true,
              orElse: () => devices.first,
            );
            targetDeviceId = activeDevice['id'] as String?;
          }
        }
      } catch (e) {
        debugPrint('Errore recupero dispositivi Spotify: $e');
      }

      // 3. Avvia Play immediato
      final playUri = targetDeviceId != null
          ? Uri.parse(
              'https://api.spotify.com/v1/me/player/play?device_id=$targetDeviceId',
            )
          : Uri.parse('https://api.spotify.com/v1/me/player/play');

      final playRes = await http.put(
        playUri,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'uris': ['spotify:track:$cleanTrackId'],
        }),
      ).timeout(const Duration(seconds: 5));

      if (playRes.statusCode == 200 || playRes.statusCode == 204) {
        debugPrint('Riproduzione avviata con successo su Spotify!');
        return true;
      } else {
        debugPrint('Risposta Spotify Play: ${playRes.statusCode} ${playRes.body}');
      }
    } catch (e) {
      debugPrint('Errore comunicazione Spotify Player: $e');
    }
    return false;
  }

  /// Esegue un test di connessione con il player Spotify del locale
  static Future<({bool success, String message})> testSpotifyPlayer({
    required UsersRecord user,
  }) async {
    final token = await getValidAccessToken(user);
    if (token == null || token.isEmpty) {
      return (
        success: false,
        message: 'Account Spotify non collegato.',
      );
    }

    try {
      final devicesRes = await http.get(
        Uri.parse('https://api.spotify.com/v1/me/player/devices'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 5));

      if (devicesRes.statusCode == 401) {
        return (
          success: false,
          message:
              'Token Spotify scaduto o non valido. Prova a ricollegare l\'account.',
        );
      }

      if (devicesRes.statusCode == 200) {
        final data = jsonDecode(devicesRes.body);
        final devices = data['devices'] as List<dynamic>? ?? [];
        if (devices.isEmpty) {
          return (
            success: false,
            message:
                'Nessun dispositivo Spotify attivo trovato. Apri Spotify su telefono o PC con questo account.',
          );
        }

        final activeDevice = devices.firstWhere(
          (d) => d['is_active'] == true,
          orElse: () => null,
        );

        if (activeDevice != null) {
          return (
            success: true,
            message:
                'Spotify è attivo su "${activeDevice['name']}". Pronto a ricevere richieste!',
          );
        } else {
          final firstDevice = devices.first['name'];
          return (
            success: true,
            message:
                'Dispositivo trovato ("$firstDevice"). È pronto a ricevere e avviare i brani.',
          );
        }
      }

      String detail = devicesRes.body;
      try {
        final parsed = jsonDecode(devicesRes.body);
        if (parsed['error'] != null) {
          if (parsed['error'] is Map && parsed['error']['message'] != null) {
            detail = parsed['error']['message'];
          } else if (parsed['error_description'] != null) {
            detail = parsed['error_description'];
          }
        }
      } catch (_) {}

      return (
        success: false,
        message: 'Risposta Spotify (${devicesRes.statusCode}): $detail',
      );
    } catch (e) {
      return (
        success: false,
        message: 'Errore di connessione: $e',
      );
    }
  }

  /// Tracce dimostrative per test immediato
  static const List<SpotifyTrack> _sampleTracks = [
    SpotifyTrack(
      id: 'demo_1',
      title: 'Fly Me to the Moon',
      artist: 'Frank Sinatra',
      album: 'It Might as Well Be Swing',
      coverUrl: 'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=300',
      durationMs: 147000,
    ),
    SpotifyTrack(
      id: 'demo_2',
      title: 'Feeling Good',
      artist: 'Nina Simone',
      album: 'I Put a Spell on You',
      coverUrl: 'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=300',
      durationMs: 173000,
    ),
    SpotifyTrack(
      id: 'demo_3',
      title: 'Senza Fine',
      artist: 'Gino Paoli',
      album: 'I Grandi Successi',
      coverUrl: 'https://images.unsplash.com/photo-1465847899084-d164df4dedc6?w=300',
      durationMs: 195000,
    ),
    SpotifyTrack(
      id: 'demo_4',
      title: 'Come Fly With Me',
      artist: 'Michael Bublé',
      album: 'Michael Bublé Special Edition',
      coverUrl: 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=300',
      durationMs: 199000,
    ),
    SpotifyTrack(
      id: 'demo_5',
      title: 'Bésame Mucho',
      artist: 'Andrea Bocelli',
      album: 'Amore',
      coverUrl: 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=300',
      durationMs: 242000,
    ),
    SpotifyTrack(
      id: 'demo_6',
      title: 'Just the Two of Us',
      artist: 'Grover Washington, Jr., Bill Withers',
      album: 'Winelight',
      coverUrl: 'https://images.unsplash.com/photo-1518609878373-06d740f60d8b?w=300',
      durationMs: 238000,
    ),
    SpotifyTrack(
      id: 'demo_7',
      title: 'Autumn Leaves',
      artist: 'Miles Davis, Cannonball Adderley',
      album: 'Somethin\' Else',
      coverUrl: 'https://images.unsplash.com/photo-1445985543470-41fdd6ce388d?w=300',
      durationMs: 310000,
    ),
  ];
}
