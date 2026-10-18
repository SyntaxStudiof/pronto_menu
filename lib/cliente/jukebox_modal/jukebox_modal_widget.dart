import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '/backend/backend.dart';
import '/services/jukebox_service.dart';
import '/services/translation_service.dart';

class JukeboxModalWidget extends StatefulWidget {
  const JukeboxModalWidget({
    super.key,
    required this.ristoranteRef,
    required this.ristorante,
    this.currentLang = 'it',
  });

  final DocumentReference ristoranteRef;
  final UsersRecord ristorante;
  final String currentLang;

  static Future<void> show(
    BuildContext context, {
    required DocumentReference ristoranteRef,
    required UsersRecord ristorante,
    String currentLang = 'it',
  }) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => JukeboxModalWidget(
        ristoranteRef: ristoranteRef,
        ristorante: ristorante,
        currentLang: currentLang,
      ),
    );
  }

  @override
  State<JukeboxModalWidget> createState() => _JukeboxModalWidgetState();
}

class _JukeboxModalWidgetState extends State<JukeboxModalWidget>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  Timer? _countdownTimer;
  Timer? _nowPlayingPollTimer;
  Duration _remainingCooldown = Duration.zero;

  late AnimationController _vinylController;
  late AnimationController _armController;
  late Animation<double> _armAnimation;

  int _selectedTab = 0; // 0: In Riproduzione & Coda, 1: Richiedi Brano
  bool _isLoadingTracks = true;
  bool _isSubmitting = false;
  bool _isMusicPlaying = false;
  String? _errorMessage;
  List<SpotifyTrack> _allTracks = [];
  List<SpotifyTrack> _filteredTracks = [];
  SpotifyTrack? _liveCurrentlyPlaying;

  @override
  void initState() {
    super.initState();

    // Controller per la rotazione continua a 33 giri del vinile
    _vinylController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    );

    // Controller per l'animazione del braccio di lettura del giradischi (spostamento sul disco)
    _armController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    );

    _armAnimation = CurvedAnimation(
      parent: _armController,
      curve: Curves.easeInOutCubic,
    );

    _checkCooldown();
    _startCooldownTimer();
    _loadTracks();
    _fetchLiveNowPlaying();

    // Polling periodico per verificare lo stato di riproduzione reale
    _nowPlayingPollTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (mounted) _fetchLiveNowPlaying();
    });

    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _vinylController.dispose();
    _armController.dispose();
    _countdownTimer?.cancel();
    _nowPlayingPollTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _setPlayback(bool playing) {
    if (_isMusicPlaying == playing) return;
    setState(() {
      _isMusicPlaying = playing;
      if (_isMusicPlaying) {
        _armController.forward();
        _vinylController.repeat();
      } else {
        _armController.reverse();
        _vinylController.stop();
      }
    });
  }

  void _startCooldownTimer() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingCooldown > Duration.zero) {
        setState(() {
          _remainingCooldown -= const Duration(seconds: 1);
          if (_remainingCooldown < Duration.zero) {
            _remainingCooldown = Duration.zero;
          }
        });
      }
    });
  }

  Future<void> _checkCooldown() async {
    final cooldown = await JukeboxService.getRemainingCooldown(
      ristoranteId: widget.ristoranteRef.id,
      cooldownMinutes: widget.ristorante.jukeboxCooldownMinuti > 0
          ? widget.ristorante.jukeboxCooldownMinuti
          : 30,
    );
    if (mounted) {
      setState(() {
        _remainingCooldown = cooldown;
      });
    }
  }

  Future<void> _fetchLiveNowPlaying() async {
    try {
      final fresh = await UsersRecord.getDocumentOnce(widget.ristoranteRef);
      final current = await JukeboxService.getCurrentlyPlaying(fresh);
      if (mounted) {
        setState(() {
          _liveCurrentlyPlaying = current;
          if (current != null && current.isPlaying) {
            _setPlayback(true);
          } else {
            _setPlayback(false);
          }
        });
      }
    } catch (_) {}
  }

  Future<void> _loadTracks() async {
    setState(() {
      _isLoadingTracks = true;
      _errorMessage = null;
    });

    try {
      final freshRistorante =
          await UsersRecord.getDocumentOnce(widget.ristoranteRef);
      final tracks =
          await JukeboxService.fetchTracksForRestaurant(freshRistorante);

      if (mounted) {
        setState(() {
          _allTracks = tracks;
          _filteredTracks = tracks;
          _isLoadingTracks = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingTracks = false;
          _errorMessage = TranslationService.getUi(
            'impossibile_caricare_playlist',
            widget.currentLang,
          );
        });
      }
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredTracks = _allTracks;
      } else {
        _filteredTracks = _allTracks.where((track) {
          return track.title.toLowerCase().contains(query) ||
              track.artist.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  String _formatDuration(Duration duration) {
    final m = duration.inMinutes;
    final s = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Future<void> _requestTrack(SpotifyTrack track) async {
    if (_remainingCooldown > Duration.zero) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${TranslationService.getUi('attendi_ancora', widget.currentLang)} ${_formatDuration(_remainingCooldown)} ${TranslationService.getUi('prima_di_richiedere', widget.currentLang)}',
          ),
          backgroundColor: Colors.orange.shade800,
        ),
      );
      return;
    }

    // Deduplicazione: verifica se il brano è già in coda
    try {
      final existingDocs = await JukeboxRequestsRecord.collection
          .where('ristoranteRef', isEqualTo: widget.ristoranteRef)
          .where('trackId', isEqualTo: track.id)
          .where('status', isEqualTo: 'in_coda')
          .get();

      if (existingDocs.docs.isNotEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.amber.shade900,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              content: Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.white,
                    size: 22.0,
                  ),
                  const SizedBox(width: 10.0),
                  Expanded(
                    child: Text(
                      '"${track.title}" ${TranslationService.getUi('gia_in_coda', widget.currentLang)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return;
      }
    } catch (_) {}

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
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
                Icons.music_note_rounded,
                color: Color(0xFF1DB954),
                size: 22.0,
              ),
            ),
            const SizedBox(width: 10.0),
            Expanded(
              child: Text(
                TranslationService.getUi(
                  'richiedi_canzone_titolo',
                  widget.currentLang,
                ),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17.0,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              TranslationService.getUi(
                'vuoi_mettere_in_coda',
                widget.currentLang,
              ),
              style: TextStyle(color: Theme.of(context).hintColor),
            ),
            const SizedBox(height: 8.0),
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: track.coverUrl.isNotEmpty
                      ? Image.network(
                          track.coverUrl,
                          width: 44.0,
                          height: 44.0,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          width: 44.0,
                          height: 44.0,
                          color: Colors.grey.shade300,
                          child: const Icon(Icons.music_note_rounded),
                        ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        track.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14.5,
                        ),
                      ),
                      Text(
                        track.artist,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.0,
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14.0),
            Container(
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: const Color(0xFF1DB954).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    size: 16.0,
                    color: Color(0xFF1DB954),
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: Text(
                      TranslationService.getUi(
                        'potrai_richiedere_tra_30',
                        widget.currentLang,
                      ),
                      style: const TextStyle(fontSize: 11.5, height: 1.3),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(
              TranslationService.getUi('annulla', widget.currentLang),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1DB954),
              foregroundColor: Colors.white,
              elevation: 0.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
            child: Text(
              TranslationService.getUi(
                'conferma_richiesta',
                widget.currentLang,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      // 1. Registra su Firestore
      await JukeboxRequestsRecord.collection.add(
        createJukeboxRequestsRecordData(
          ristoranteRef: widget.ristoranteRef,
          trackId: track.id,
          trackTitle: track.title,
          artistName: track.artist,
          albumArtUrl: track.coverUrl,
          durationMs: track.durationMs,
          requestedAt: DateTime.now(),
          status: 'in_coda',
        ),
      );

      // 2. Se Spotify del locale è collegato, invia subito a Spotify Connect
      final freshRistorante =
          await UsersRecord.getDocumentOnce(widget.ristoranteRef);
      final validToken =
          await JukeboxService.getValidAccessToken(freshRistorante);
      if (validToken != null && validToken.isNotEmpty) {
        if (!track.id.startsWith('demo_')) {
          await JukeboxService.enqueueOrPlayTrackOnSpotify(
            accessToken: validToken,
            trackId: track.id,
            ristorante: freshRistorante,
          );
        }
      }

      // 3. Imposta cooldown di 30 minuti
      await JukeboxService.recordRequest(ristoranteId: widget.ristoranteRef.id);

      final cooldownMinutes = widget.ristorante.jukeboxCooldownMinuti > 0
          ? widget.ristorante.jukeboxCooldownMinuti
          : 30;

      if (mounted) {
        setState(() {
          _remainingCooldown = Duration(minutes: cooldownMinutes);
          _isSubmitting = false;
          _selectedTab = 0; // Torna subito alla vista "In Onda & Coda"
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF1DB954),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            content: Row(
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  color: Colors.white,
                  size: 22.0,
                ),
                const SizedBox(width: 10.0),
                Expanded(
                  child: Text(
                    '🎶 ${TranslationService.getUi('richiesta_inviata', widget.currentLang)} "${track.title}" ${TranslationService.getUi('in_coda', widget.currentLang).toLowerCase()}.',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${TranslationService.getUi('errore_invio_richiesta', widget.currentLang)} $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasCooldown = _remainingCooldown > Duration.zero;

    return Container(
      height: MediaQuery.of(context).size.height * 0.90,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24.0),
          topRight: Radius.circular(24.0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20.0,
            offset: const Offset(0.0, -4.0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Handle bar
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12.0, bottom: 8.0),
              width: 44.0,
              height: 4.5,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(3.0),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 4.0),
            child: Row(
              children: [
                Container(
                  width: 40.0,
                  height: 40.0,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1DB954).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.album_rounded,
                    color: Color(0xFF1DB954),
                    size: 24.0,
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        TranslationService.getUi('jukebox_locale', widget.currentLang),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0,
                        ),
                      ),
                      Text(
                        TranslationService.getUi('musica_diffusione', widget.currentLang),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  color: theme.colorScheme.onSurfaceVariant,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          // Selettore Tab Moderno (In Onda & Coda VS Scegli un Brano)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Container(
              height: 44.0,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(14.0),
              ),
              padding: const EdgeInsets.all(4.0),
              child: Row(
                children: [
                  // Tab 0: In Onda & Coda
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _selectedTab = 0),
                      borderRadius: BorderRadius.circular(11.0),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: _selectedTab == 0
                              ? theme.cardColor
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(11.0),
                          boxShadow: _selectedTab == 0
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.08),
                                    blurRadius: 4.0,
                                    offset: const Offset(0, 1),
                                  ),
                                ]
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.radio_rounded,
                              size: 17.0,
                              color: _selectedTab == 0
                                  ? const Color(0xFF1DB954)
                                  : theme.hintColor,
                            ),
                            const SizedBox(width: 6.0),
                            Text(
                              TranslationService.getUi('in_onda_coda', widget.currentLang),
                              style: TextStyle(
                                fontSize: 13.0,
                                fontWeight: _selectedTab == 0
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: _selectedTab == 0
                                    ? theme.colorScheme.onSurface
                                    : theme.hintColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Tab 1: Scegli un Brano
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _selectedTab = 1),
                      borderRadius: BorderRadius.circular(11.0),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: _selectedTab == 1
                              ? theme.cardColor
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(11.0),
                          boxShadow: _selectedTab == 1
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.08),
                                    blurRadius: 4.0,
                                    offset: const Offset(0, 1),
                                  ),
                                ]
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.queue_music_rounded,
                              size: 17.0,
                              color: _selectedTab == 1
                                  ? const Color(0xFF1DB954)
                                  : theme.hintColor,
                            ),
                            const SizedBox(width: 6.0),
                            Text(
                              TranslationService.getUi('scegli_brano', widget.currentLang),
                              style: TextStyle(
                                fontSize: 13.0,
                                fontWeight: _selectedTab == 1
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: _selectedTab == 1
                                    ? theme.colorScheme.onSurface
                                    : theme.hintColor,
                              ),
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

          const Divider(height: 1.0, thickness: 1.0),

          // Corpo del Tab Selezionato
          Expanded(
            child: _selectedTab == 0
                ? _buildNowPlayingAndQueueTab(theme)
                : _buildBrowseTracksTab(theme, hasCooldown),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // TAB 0: ORA IN ONDA (VINILE ROTANTE RETRO) & CODA RICHIESTE CLIENTI
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildNowPlayingAndQueueTab(ThemeData theme) {
    return StreamBuilder<List<JukeboxRequestsRecord>>(
      stream: queryJukeboxRequestsRecord(
        queryBuilder: (q) => q
            .where('ristoranteRef', isEqualTo: widget.ristoranteRef)
            .where('status', isEqualTo: 'in_coda'),
      ),
      builder: (context, snapshot) {
        final rawRequests = snapshot.data ?? [];
        final queuedRequests = List<JukeboxRequestsRecord>.from(rawRequests)
          ..sort((a, b) {
            final aDate = a.requestedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
            final bDate = b.requestedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
            return aDate.compareTo(bDate);
          });

        // Determina la canzone da mostrare sul disco in vinile:
        String currentTitle = TranslationService.getUi(
          'nessun_brano_in_riproduzione',
          widget.currentLang,
        );
        String currentArtist = TranslationService.getUi(
          'giradischi_pronto',
          widget.currentLang,
        );
        String currentCover = '';

        if (_liveCurrentlyPlaying != null) {
          currentTitle = _liveCurrentlyPlaying!.title;
          currentArtist = _liveCurrentlyPlaying!.artist;
          currentCover = _liveCurrentlyPlaying!.coverUrl;
        } else if (queuedRequests.isNotEmpty) {
          final topReq = queuedRequests.first;
          currentTitle = topReq.trackTitle;
          currentArtist = topReq.artistName;
          currentCover = topReq.albumArtUrl;
        } else if (_allTracks.isNotEmpty) {
          final top = _allTracks.first;
          currentTitle = top.title;
          currentArtist = top.artist;
          currentCover = top.coverUrl;
        }

        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          children: [
            // ── SEZIONE GIRADISCHI RETRO ──────────────────────────────────
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.cardColor,
                    theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(22.0),
                border: Border.all(
                  color: theme.dividerColor.withValues(alpha: 0.5),
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 12.0,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
              child: Column(
                children: [
                  // Badge di stato: IN ONDA ORA (Verde) vs MUSICA IN PAUSA (Grigio)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 6.0),
                    decoration: BoxDecoration(
                      color: _isMusicPlaying
                          ? const Color(0xFF1DB954).withValues(alpha: 0.12)
                          : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(20.0),
                      border: Border.all(
                        color: _isMusicPlaying
                            ? const Color(0xFF1DB954).withValues(alpha: 0.4)
                            : theme.dividerColor,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8.0,
                          height: 8.0,
                          decoration: BoxDecoration(
                            color: _isMusicPlaying
                                ? const Color(0xFF1DB954)
                                : theme.hintColor.withValues(alpha: 0.6),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        Text(
                          _isMusicPlaying
                              ? TranslationService.getUi('in_onda_ora', widget.currentLang)
                              : TranslationService.getUi('musica_in_pausa', widget.currentLang),
                          style: TextStyle(
                            color: _isMusicPlaying
                                ? const Color(0xFF1DB954)
                                : theme.hintColor,
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18.0),

                  // Disco in Vinile con Braccio di Lettura Animato (controllato da Spotify)
                  Center(
                    child: SizedBox(
                      width: 220.0,
                      height: 190.0,
                      child: Stack(
                        alignment: Alignment.center,
                        clipBehavior: Clip.none,
                        children: [
                          // Piatto e Disco in Vinile (Ruota SOLO se _isMusicPlaying == true)
                          Positioned(
                            left: 10.0,
                            child: RotationTransition(
                              turns: _vinylController,
                              child: _buildRetroVinylRecord(currentCover),
                            ),
                          ),

                          // Braccio di lettura animato (si sposta sul disco se suona, altrimenti sta fuori)
                          Positioned(
                            top: -6.0,
                            right: 2.0,
                            child: _buildToneArm(),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 14.0),

                  // Titolo e Artista del Brano
                  Text(
                    _isMusicPlaying
                        ? currentTitle
                        : (_liveCurrentlyPlaying != null
                            ? currentTitle
                            : TranslationService.getUi('nessun_brano_in_riproduzione', widget.currentLang)),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17.5,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    _isMusicPlaying
                        ? currentArtist
                        : (_liveCurrentlyPlaying != null
                            ? '$currentArtist • ${TranslationService.getUi('in_pausa', widget.currentLang)}'
                            : TranslationService.getUi('in_attesa_locale', widget.currentLang)),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.0,
                      color: theme.hintColor,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22.0),

            // ── SEZIONE CODA DELLE RICHIESTE DEI CLIENTI ────────────────────
            Row(
              children: [
                Container(
                  width: 32.0,
                  height: 32.0,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Icon(
                    Icons.format_list_numbered_rounded,
                    color: theme.colorScheme.primary,
                    size: 18.0,
                  ),
                ),
                const SizedBox(width: 10.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${TranslationService.getUi('canzoni_in_coda_tavoli', widget.currentLang)} (${queuedRequests.length})',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15.0,
                        ),
                      ),
                      Text(
                        TranslationService.getUi('ordine_richiesta', widget.currentLang),
                        style: TextStyle(
                          fontSize: 11.5,
                          color: theme.hintColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12.0),

            if (queuedRequests.isEmpty)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 28.0, horizontal: 16.0),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(
                    color: theme.dividerColor.withValues(alpha: 0.4),
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.queue_music_rounded,
                      size: 40.0,
                      color: theme.hintColor.withValues(alpha: 0.4),
                    ),
                    const SizedBox(height: 10.0),
                    Text(
                      TranslationService.getUi('nessuna_canzone_coda', widget.currentLang),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.0,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      TranslationService.getUi('sii_il_primo', widget.currentLang),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12.0,
                        color: theme.hintColor,
                      ),
                    ),
                  ],
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: queuedRequests.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8.0),
                itemBuilder: (context, idx) {
                  final req = queuedRequests[idx];
                  final isNext = idx == 0;

                  return Container(
                    padding: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(14.0),
                      border: Border.all(
                        color: isNext
                            ? const Color(0xFF1DB954).withValues(alpha: 0.5)
                            : theme.dividerColor.withValues(alpha: 0.4),
                        width: isNext ? 1.5 : 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Numero d'ordine badge
                        Container(
                          width: 28.0,
                          height: 28.0,
                          decoration: BoxDecoration(
                            color: isNext
                                ? const Color(0xFF1DB954)
                                : theme.colorScheme.surfaceContainerHighest,
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
                        const SizedBox(width: 10.0),

                        // Mini copertina
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Container(
                            width: 44.0,
                            height: 44.0,
                            color: const Color(0xFF1DB954).withValues(alpha: 0.1),
                            child: req.albumArtUrl.isNotEmpty
                                ? Image.network(
                                    req.albumArtUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(
                                      Icons.music_note_rounded,
                                      color: Color(0xFF1DB954),
                                    ),
                                  )
                                : const Icon(
                                    Icons.music_note_rounded,
                                    color: Color(0xFF1DB954),
                                  ),
                          ),
                        ),
                        const SizedBox(width: 12.0),

                        // Testi
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                              const SizedBox(height: 2.0),
                              Text(
                                '${req.artistName} • ${isNext ? TranslationService.getUi('prossima_in_riproduzione', widget.currentLang) : TranslationService.getUi('in_coda', widget.currentLang).toUpperCase()}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
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
                      ],
                    ),
                  );
                },
              ),

            const SizedBox(height: 20.0),

            // Pulsante per passare alla playlist e richiedere
            SizedBox(
              width: double.infinity,
              height: 50.0,
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() => _selectedTab = 1);
                },
                icon: const Icon(Icons.add_circle_outline_rounded, size: 20.0),
                label: Text(
                  TranslationService.getUi('sfoglia_playlist_richiedi', widget.currentLang),
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1DB954),
                  foregroundColor: Colors.white,
                  elevation: 0.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.0),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20.0),
          ],
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // WIDGET DISCO IN VINILE RETRO
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildRetroVinylRecord(String coverUrl) {
    const double vinylSize = 170.0;
    const double labelSize = 72.0;

    return Container(
      width: vinylSize,
      height: vinylSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 16.0,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: CustomPaint(
        painter: VinylPainter(
          grooveColor: Colors.white.withValues(alpha: 0.07),
        ),
        child: Center(
          child: Container(
            width: labelSize,
            height: labelSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.grey.shade800,
                width: 2.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 4.0,
                ),
              ],
            ),
            child: ClipOval(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Copertina dell'album al centro del vinile
                  coverUrl.isNotEmpty
                      ? Image.network(
                          coverUrl,
                          width: labelSize,
                          height: labelSize,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildFallbackLabel(),
                        )
                      : _buildFallbackLabel(),

                  // Foro centrale del vinile con anello argentato (Spindle hole)
                  Container(
                    width: 14.0,
                    height: 14.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black,
                      border: Border.all(
                        color: Colors.grey.shade400,
                        width: 2.0,
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

  Widget _buildFallbackLabel() {
    return Container(
      color: const Color(0xFF1DB954),
      alignment: Alignment.center,
      child: const Icon(
        Icons.music_note_rounded,
        color: Colors.white,
        size: 30.0,
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // BRACCIO DI LETTURA ANIMATO (TONEARM DEL GIRADISCHI RETRÒ)
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildToneArm() {
    return AnimatedBuilder(
      animation: _armAnimation,
      builder: (context, child) {
        // Quando a riposo (0.0): il braccio è sul supporto a destra fuori dal vinile (-0.16 rad)
        // Quando suona (1.0): il braccio ruota verso sinistra posizionandosi sopra i solchi del vinile (+0.50 rad)
        final angle = -0.16 + (_armAnimation.value * 0.66);

        return SizedBox(
          width: 70.0,
          height: 120.0,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Supporto di riposo fisso (Arm Rest Clip) dove il braccio alloggia quando non suona
              Positioned(
                top: 76.0,
                right: 4.0,
                child: Container(
                  width: 14.0,
                  height: 10.0,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade800,
                    borderRadius: BorderRadius.circular(3.0),
                    border: Border.all(color: Colors.grey.shade600, width: 1.0),
                  ),
                ),
              ),

              // Asta e testina che ruotano attorno al perno in alto a destra
              Transform(
                alignment: const Alignment(0.66, -0.80),
                transform: Matrix4.rotationZ(angle),
                child: Stack(
                  children: [
                    // Asta del braccio cromata
                    Positioned(
                      top: 14.0,
                      right: 10.0,
                      child: Container(
                        width: 4.0,
                        height: 78.0,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.grey.shade300,
                              Colors.grey.shade500,
                              Colors.grey.shade200,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(2.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.35),
                              blurRadius: 3.0,
                              offset: const Offset(-1, 2),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Cartuccia / Testina vintage dorata con stylus
                    Positioned(
                      top: 86.0,
                      right: 6.0,
                      child: Transform.rotate(
                        angle: 0.15,
                        child: Container(
                          width: 12.0,
                          height: 20.0,
                          decoration: BoxDecoration(
                            color: const Color(0xFFD4AF37), // Oro vintage retrò
                            borderRadius: BorderRadius.circular(3.0),
                            border: Border.all(
                              color: const Color(0xFFF3E5AB),
                              width: 1.0,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.45),
                                blurRadius: 4.0,
                                offset: const Offset(-1, 2),
                              ),
                            ],
                          ),
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              width: 2.5,
                              height: 5.0,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(1.0),
                                  bottomRight: Radius.circular(1.0),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Perno girevole in alto a destra (Gimbal Pivot)
              Positioned(
                top: 0.0,
                right: 0.0,
                child: Container(
                  width: 24.0,
                  height: 24.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.grey.shade200,
                        Colors.grey.shade600,
                        Colors.grey.shade900,
                      ],
                    ),
                    border: Border.all(
                      color: Colors.grey.shade400,
                      width: 2.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.4),
                        blurRadius: 4.0,
                        offset: const Offset(1, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Container(
                      width: 8.0,
                      height: 8.0,
                      decoration: BoxDecoration(
                        color: _isMusicPlaying ? const Color(0xFF1DB954) : Colors.grey.shade400,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // TAB 1: SFOGLIA LA PLAYLIST & RICERCA BRANI
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildBrowseTracksTab(ThemeData theme, bool hasCooldown) {
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        // Cooldown Status Banner
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(
              horizontal: 14.0,
              vertical: 10.0,
            ),
            decoration: BoxDecoration(
              color: hasCooldown
                  ? (isDark ? const Color(0xFF451A03) : const Color(0xFFFEF3C7))
                  : (isDark ? const Color(0xFF064E3B) : const Color(0xFFD1FAE5)),
              borderRadius: BorderRadius.circular(14.0),
              border: Border.all(
                color: hasCooldown
                    ? const Color(0xFFF59E0B).withValues(alpha: 0.4)
                    : const Color(0xFF10B981).withValues(alpha: 0.4),
                width: 1.2,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7.0),
                  decoration: BoxDecoration(
                    color: hasCooldown
                        ? const Color(0xFFF59E0B).withValues(alpha: 0.2)
                        : const Color(0xFF10B981).withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    hasCooldown
                        ? Icons.hourglass_top_rounded
                        : Icons.check_circle_rounded,
                    color: hasCooldown
                        ? const Color(0xFFD97706)
                        : const Color(0xFF059669),
                    size: 20.0,
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hasCooldown
                            ? '${TranslationService.getUi('prossima_richiesta_tra', widget.currentLang)} ${_formatDuration(_remainingCooldown)}'
                            : TranslationService.getUi('puoi_richiedere_ora', widget.currentLang),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13.5,
                          color: hasCooldown
                              ? (isDark
                                  ? const Color(0xFFFDE68A)
                                  : const Color(0xFF92400E))
                              : (isDark
                                  ? const Color(0xFFA7F3D0)
                                  : const Color(0xFF065F46)),
                        ),
                      ),
                      const SizedBox(height: 2.0),
                      Text(
                        TranslationService.getUi('regola_antispam', widget.currentLang),
                        style: TextStyle(
                          fontSize: 11.5,
                          color: hasCooldown
                              ? (isDark
                                  ? const Color(0xFFFCD34D)
                                  : const Color(0xFFB45309))
                              : (isDark
                                  ? const Color(0xFF6EE7B7)
                                  : const Color(0xFF047857)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Barra di Ricerca
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: TranslationService.getUi('cerca_per_titolo_artista', widget.currentLang),
              hintStyle: TextStyle(
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                fontSize: 13.5,
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: theme.colorScheme.onSurfaceVariant,
                size: 20.0,
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 18.0),
                      onPressed: () {
                        _searchController.clear();
                      },
                    )
                  : null,
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.5),
              contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),

        // Lista brani
        Expanded(
          child: _buildTrackListBody(theme, hasCooldown),
        ),
      ],
    );
  }

  Widget _buildTrackListBody(ThemeData theme, bool hasCooldown) {
    if (_isLoadingTracks) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SpinKitPulse(
              color: Color(0xFF1DB954),
              size: 48.0,
            ),
            const SizedBox(height: 16.0),
            Text(
              TranslationService.getUi('caricamento_playlist', widget.currentLang),
              style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 14.0,
              ),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline_rounded,
                color: theme.colorScheme.error,
                size: 40.0,
              ),
              const SizedBox(height: 12.0),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16.0),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh_rounded, size: 18.0),
                label: Text(TranslationService.getUi('riprova', widget.currentLang)),
                onPressed: _loadTracks,
              ),
            ],
          ),
        ),
      );
    }

    if (_filteredTracks.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.music_off_rounded,
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                size: 48.0,
              ),
              const SizedBox(height: 12.0),
              Text(
                TranslationService.getUi('nessun_brano_trovato', widget.currentLang),
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4.0),
              Text(
                TranslationService.getUi('prova_altro_titolo', widget.currentLang),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      itemCount: _filteredTracks.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10.0),
      itemBuilder: (context, index) {
        final track = _filteredTracks[index];
        return _buildTrackCard(theme, track, hasCooldown);
      },
    );
  }

  Widget _buildTrackCard(ThemeData theme, SpotifyTrack track, bool hasCooldown) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.4),
          width: 1.0,
        ),
      ),
      padding: const EdgeInsets.all(10.0),
      child: Row(
        children: [
          // Copertina Album
          ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: Container(
              width: 50.0,
              height: 50.0,
              color: const Color(0xFF1DB954).withValues(alpha: 0.1),
              child: track.coverUrl.isNotEmpty
                  ? Image.network(
                      track.coverUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Center(
                        child: Icon(
                          Icons.music_note_rounded,
                          color: Color(0xFF1DB954),
                          size: 24.0,
                        ),
                      ),
                    )
                  : const Center(
                      child: Icon(
                        Icons.music_note_rounded,
                        color: Color(0xFF1DB954),
                        size: 24.0,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12.0),

          // Informazioni Brano
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  track.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.0,
                  ),
                ),
                const SizedBox(height: 3.0),
                Text(
                  '${track.artist} • ${track.formattedDuration}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 12.0,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8.0),

          // Pulsante Richiedi
          hasCooldown
              ? Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10.0,
                    vertical: 7.0,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.timer_outlined,
                        size: 13.0,
                        color: theme.colorScheme.onSurfaceVariant
                            .withValues(alpha: 0.6),
                      ),
                      const SizedBox(width: 4.0),
                      Text(
                        _formatDuration(_remainingCooldown),
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurfaceVariant
                            .withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                )
              : ElevatedButton(
                  onPressed: _isSubmitting ? null : () => _requestTrack(track),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1DB954),
                    foregroundColor: Colors.white,
                    elevation: 0.0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14.0,
                      vertical: 8.0,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.queue_music_rounded, size: 16.0),
                      const SizedBox(width: 6.0),
                      Text(TranslationService.getUi('richiedi', widget.currentLang)),
                    ],
                  ),
                ),
        ],
      ),
    );
  }
}

/// Disegna le scanalature (grooves) e i riflessi satinati del disco in vinile retrò
class VinylPainter extends CustomPainter {
  final Color grooveColor;
  VinylPainter({required this.grooveColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Base del vinile nero satinato con gradiente radiale
    final vinylPaint = Paint()
      ..shader = RadialGradient(
        colors: const [
          Color(0xFF282828),
          Color(0xFF121212),
          Color(0xFF090909),
          Color(0xFF171717),
          Color(0xFF050505),
        ],
        stops: const [0.0, 0.45, 0.7, 0.85, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, vinylPaint);

    // Riflesso satinato a due fasci tipico dei dischi in vinile
    final sheenPaint = Paint()
      ..shader = SweepGradient(
        colors: [
          Colors.white.withValues(alpha: 0.0),
          Colors.white.withValues(alpha: 0.09),
          Colors.white.withValues(alpha: 0.0),
          Colors.white.withValues(alpha: 0.0),
          Colors.white.withValues(alpha: 0.09),
          Colors.white.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.25, 0.4, 0.6, 0.75, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius - 2, sheenPaint);

    // Scanalature concentriche incise (solchi del disco)
    final groovePaint = Paint()
      ..color = grooveColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.75;

    canvas.drawCircle(center, radius * 0.94, groovePaint);
    canvas.drawCircle(center, radius * 0.88, groovePaint);
    canvas.drawCircle(center, radius * 0.82, groovePaint);
    canvas.drawCircle(center, radius * 0.76, groovePaint);
    canvas.drawCircle(center, radius * 0.70, groovePaint);
    canvas.drawCircle(center, radius * 0.64, groovePaint);
    canvas.drawCircle(center, radius * 0.58, groovePaint);
    canvas.drawCircle(center, radius * 0.52, groovePaint);
    canvas.drawCircle(center, radius * 0.46, groovePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
