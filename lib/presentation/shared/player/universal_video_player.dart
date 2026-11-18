import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/tv/tv_key_handler.dart';
import 'player_controls_overlay.dart';
import 'tv_player_controls.dart';

class UniversalVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final String? fallbackUrl;
  final String title;
  final bool isLive;
  final bool isTv;
  final VoidCallback? onNextVideo;
  final VoidCallback? onPreviousVideo;
  final VoidCallback? onBack;
  final void Function(int positionSeconds, int totalDurationSeconds)? onProgressUpdate;

  const UniversalVideoPlayer({
    super.key,
    required this.videoUrl,
    this.fallbackUrl,
    required this.title,
    this.isLive = false,
    this.isTv = false,
    this.onNextVideo,
    this.onPreviousVideo,
    this.onBack,
    this.onProgressUpdate,
  });

  static const String defaultWebFallbackStream =
      'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4';

  @override
  State<UniversalVideoPlayer> createState() => _UniversalVideoPlayerState();
}

class _UniversalVideoPlayerState extends State<UniversalVideoPlayer> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  bool _isFormatError = false;
  bool _isUsingFallback = false;
  String _errorMessage = '';
  String _currentActiveUrl = '';
  bool _showControls = true;
  Timer? _hideControlsTimer;
  DateTime? _lastProgressReport;
  final FocusNode _tvFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _currentActiveUrl = widget.videoUrl;
    // On web, if video is an HLS m3u8 stream and a web fallback is provided,
    // pre-emptively use the web fallback to ensure instant, uninterrupted playback on desktop browsers.
    if (kIsWeb && _currentActiveUrl.toLowerCase().contains('.m3u8')) {
      _currentActiveUrl = widget.fallbackUrl ?? UniversalVideoPlayer.defaultWebFallbackStream;
      _isUsingFallback = true;
    }
    _initializePlayer();
  }

  @override
  void didUpdateWidget(covariant UniversalVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoUrl != widget.videoUrl) {
      _controller?.dispose();
      _currentActiveUrl = widget.videoUrl;
      _isUsingFallback = false;
      if (kIsWeb && _currentActiveUrl.toLowerCase().contains('.m3u8')) {
        _currentActiveUrl = widget.fallbackUrl ?? UniversalVideoPlayer.defaultWebFallbackStream;
        _isUsingFallback = true;
      }
      _initializePlayer();
    }
  }

  @override
  void dispose() {
    _hideControlsTimer?.cancel();
    if (_controller != null && _controller!.value.isInitialized && !widget.isLive) {
      final pos = _controller!.value.position.inSeconds;
      final dur = _controller!.value.duration.inSeconds;
      if (dur > 0) {
        widget.onProgressUpdate?.call(pos, dur);
      }
    }
    _controller?.dispose();
    _tvFocusNode.dispose();
    super.dispose();
  }

  bool _isMediaFormatError(String errorText) {
    final lower = errorText.toLowerCase();
    return lower.contains('media_err_src_not_supported') ||
        lower.contains('format error') ||
        lower.contains('unsuitable') ||
        lower.contains('not supported by your browser') ||
        lower.contains('.m3u8');
  }

  Future<void> _initializePlayer() async {
    setState(() {
      _isInitialized = false;
      _hasError = false;
      _isFormatError = false;
      _errorMessage = '';
    });

    try {
      final uri = Uri.parse(_currentActiveUrl);
      _controller = VideoPlayerController.networkUrl(
        uri,
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: false),
      );

      await _controller!.initialize();
      _controller!.addListener(_playerListener);
      await _controller!.play();

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
        _resetControlsTimer();
        if (widget.isTv) {
          _tvFocusNode.requestFocus();
        }
      }
    } catch (e) {
      debugPrint('Video initialization error: $e');
      final errorStr = e.toString();
      final isFormat = _isMediaFormatError(errorStr);

      // If format is unsupported on Web (e.g. HLS .m3u8 on Chrome/desktop) and we haven't tried fallback
      if (isFormat && !_isUsingFallback) {
        debugPrint('Unsupported format detected. Falling back to web-compatible stream...');
        _fallbackToWebStream();
        return;
      }

      if (mounted) {
        setState(() {
          _hasError = true;
          _isFormatError = isFormat;
          _errorMessage = errorStr;
        });
      }
    }
  }

  void _fallbackToWebStream() {
    _controller?.dispose();
    _currentActiveUrl = widget.fallbackUrl ?? UniversalVideoPlayer.defaultWebFallbackStream;
    _isUsingFallback = true;
    _initializePlayer();
  }

  void _playerListener() {
    if (!mounted || _controller == null) return;
    if (_controller!.value.hasError) {
      final desc = _controller!.value.errorDescription ?? 'Playback error';
      final isFormat = _isMediaFormatError(desc);

      if (isFormat && !_isUsingFallback) {
        _fallbackToWebStream();
        return;
      }

      setState(() {
        _hasError = true;
        _isFormatError = isFormat;
        _errorMessage = desc;
      });
    } else {
      if (_controller!.value.isPlaying && widget.onProgressUpdate != null && !widget.isLive) {
        final now = DateTime.now();
        if (_lastProgressReport == null || now.difference(_lastProgressReport!).inSeconds >= 5) {
          _lastProgressReport = now;
          final pos = _controller!.value.position.inSeconds;
          final dur = _controller!.value.duration.inSeconds;
          if (dur > 0) {
            widget.onProgressUpdate!(pos, dur);
          }
        }
      }
      setState(() {});
    }
  }

  void _togglePlayPause() {
    if (_controller == null || !_isInitialized) return;
    if (_controller!.value.isPlaying) {
      _controller!.pause();
      _showControlsTemporarily();
    } else {
      _controller!.play();
      _resetControlsTimer();
    }
  }

  void _seekBy(Duration duration) {
    if (_controller == null || !_isInitialized || widget.isLive) return;
    final current = _controller!.value.position;
    final total = _controller!.value.duration;
    final target = current + duration;
    if (target < Duration.zero) {
      _controller!.seekTo(Duration.zero);
    } else if (target > total) {
      _controller!.seekTo(total);
    } else {
      _controller!.seekTo(target);
    }
    _showControlsTemporarily();
  }

  void _seekTo(Duration position) {
    if (_controller == null || !_isInitialized || widget.isLive) return;
    _controller!.seekTo(position);
    _resetControlsTimer();
  }

  void _showControlsTemporarily() {
    setState(() => _showControls = true);
    _resetControlsTimer();
  }

  void _toggleControls() {
    setState(() => _showControls = !_showControls);
    if (_showControls) {
      _resetControlsTimer();
    }
  }

  void _resetControlsTimer() {
    _hideControlsTimer?.cancel();
    if (_controller == null || !_controller!.value.isPlaying) return;
    _hideControlsTimer = Timer(const Duration(seconds: 4), () {
      if (mounted && _controller!.value.isPlaying) {
        setState(() => _showControls = false);
      }
    });
  }

  KeyEventResult _handleTvKeyEvent(FocusNode node, KeyEvent event) {
    if (TvKeyHandler.isSelectKey(event) || TvKeyHandler.isPlayPauseKey(event)) {
      _togglePlayPause();
      return KeyEventResult.handled;
    }
    if (TvKeyHandler.isFastForwardKey(event)) {
      _seekBy(const Duration(seconds: 10));
      return KeyEventResult.handled;
    }
    if (TvKeyHandler.isRewindKey(event)) {
      _seekBy(const Duration(seconds: -10));
      return KeyEventResult.handled;
    }
    if (TvKeyHandler.isBackKey(event)) {
      if (widget.onBack != null) {
        widget.onBack!();
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _tvFocusNode,
      autofocus: widget.isTv,
      onKeyEvent: _handleTvKeyEvent,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _toggleControls,
        child: Container(
          color: Colors.black,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Video Surface
              if (_isInitialized && _controller != null)
                Center(
                  child: AspectRatio(
                    aspectRatio: _controller!.value.aspectRatio,
                    child: VideoPlayer(_controller!),
                  ),
                )
              else if (!_hasError)
                // Loading state
                const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        color: AppColors.secondary,
                        strokeWidth: 4,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Buffering stream...',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

              // Error State
              if (_hasError)
                Center(
                  child: Container(
                    margin: const EdgeInsets.all(24),
                    padding: const EdgeInsets.all(22),
                    constraints: const BoxConstraints(maxWidth: 480),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E2E),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _isFormatError ? AppColors.secondary : AppColors.error,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(150),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _isFormatError ? Icons.live_tv_rounded : Icons.error_outline_rounded,
                          color: _isFormatError ? AppColors.secondary : AppColors.error,
                          size: 48,
                        ),
                        const SizedBox(height: 14),
                        Text(
                          _isFormatError
                              ? 'Web Browser Stream Notice'
                              : 'Playback Error',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _isFormatError
                              ? 'Desktop web browsers (Chrome/Edge/Firefox) require special codecs for Apple HLS (.m3u8) live streams.\n\nOn Android TV, Android Mobile & iOS, these channels play natively via ExoPlayer/AVPlayer.'
                              : _errorMessage,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                        ),
                        const SizedBox(height: 20),
                        Wrap(
                          spacing: 12,
                          runSpacing: 10,
                          alignment: WrapAlignment.center,
                          children: [
                            ElevatedButton.icon(
                              onPressed: _fallbackToWebStream,
                              icon: const Icon(Icons.play_circle_fill_rounded),
                              label: const Text('Play Web Preview'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.secondary,
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                            OutlinedButton.icon(
                              onPressed: () {
                                _controller?.dispose();
                                _currentActiveUrl = widget.videoUrl;
                                _isUsingFallback = false;
                                _initializePlayer();
                              },
                              icon: const Icon(Icons.refresh_rounded),
                              label: const Text('Retry Original'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: const BorderSide(color: Colors.white38),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                            if (widget.onBack != null)
                              TextButton(
                                onPressed: widget.onBack,
                                child: const Text('Go Back', style: TextStyle(color: Colors.white70)),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

              // Active Fallback Banner Pill (Subtle on-screen indicator)
              if (_isInitialized && _isUsingFallback)
                Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(180),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.secondary.withAlpha(120)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.ondemand_video_rounded, color: AppColors.secondary, size: 14),
                        SizedBox(width: 6),
                        Text(
                          'Web Preview Stream (HLS active on Android TV)',
                          style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ),

              // Controls Overlay
              if (_isInitialized && _controller != null && _showControls)
                widget.isTv
                    ? TvPlayerControls(
                        controller: _controller!,
                        title: widget.title,
                        isLive: widget.isLive,
                        onPlayPause: _togglePlayPause,
                        onSeekBy: _seekBy,
                        onNext: widget.onNextVideo,
                        onPrevious: widget.onPreviousVideo,
                        onBack: widget.onBack,
                      )
                    : PlayerControlsOverlay(
                        controller: _controller!,
                        title: widget.title,
                        isLive: widget.isLive,
                        onPlayPause: _togglePlayPause,
                        onSeekBy: _seekBy,
                        onSeekTo: _seekTo,
                        onNext: widget.onNextVideo,
                        onBack: widget.onBack,
                      ),
            ],
          ),
        ),
      ),
    );
  }
}
