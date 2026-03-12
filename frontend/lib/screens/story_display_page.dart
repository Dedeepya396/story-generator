import 'dart:convert';
import 'dart:html' as html; // Only for web
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';
import 'navbar.dart';


class StoryDisplayPage extends StatefulWidget {
  final String videoUrl;
  final bool voiceFallback;

  const StoryDisplayPage({
    super.key,
    required this.videoUrl,
    this.voiceFallback = false,
  });
  @override
  State<StoryDisplayPage> createState() => _StoryDisplayPageState();
}

class _StoryDisplayPageState extends State<StoryDisplayPage> {
  VideoPlayerController? _controller;
  bool _loading = true;
  String? _error;

  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration? _duration; // nullable to avoid JS "inSeconds" error
  bool _isScrubbing = false;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.network(widget.videoUrl)
      ..addListener(_videoListener)
      ..setLooping(false)
      ..initialize().then((_) {
        if (!mounted) return;

        setState(() {
          _loading = false;
          _duration = _controller!.value.duration;
        });

        _controller!.play();

        // ⭐ Show popup message if voice fallback occurred
        if (widget.voiceFallback) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Colors.white),
                    const SizedBox(width: 10),
                    const Flexible(
                      child: Text(
                        'Required voice is not available so generated the inbuilt voice',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                backgroundColor: Colors.amber.shade800,
                duration: const Duration(seconds: 4),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          });
        }
      }).catchError((e) {
        setState(() {
          _error = "Error loading video";
          _loading = false;
        });
      });
  }

  void _videoListener() {
    if (!mounted || _isScrubbing) return;
    final controller = _controller;
    if (controller == null) return;
    final value = controller.value;
    if (!value.isInitialized) return;

    setState(() {
      _position = value.position;
      _duration = value.duration; // may be zero, but not a problem
      _isPlaying = value.isPlaying;
    });
  }


  void _togglePlayPause() {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;

    if (controller.value.isPlaying) {
      controller.pause();
    } else {
      controller.play();
    }
  }

  void _seekRelative(int seconds) {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;

    final current = controller.value.position;
    final target = current + Duration(seconds: seconds);

    final total = _duration ?? Duration.zero;
    final safeTarget = target < Duration.zero
        ? Duration.zero
        : (total != Duration.zero && target > total)
            ? total
            : target;

    controller.seekTo(safeTarget);
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Widget _buildProgressBar() {
    final totalSeconds = (_duration?.inSeconds ?? 0).toDouble();
    final safeTotal = totalSeconds <= 0 ? 1.0 : totalSeconds;
    final currentSeconds =
        _position.inSeconds.clamp(0, safeTotal.toInt()).toDouble();

    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: const Color(0xFFFB6F92),
            inactiveTrackColor: const Color(0xFFFFCFE2),
            thumbColor: const Color(0xFFFF8FAB),
            overlayColor: const Color(0x33FF8FAB),
            trackHeight: 4,
          ),
          child: Slider(
            min: 0,
            max: safeTotal,
            value: currentSeconds,
            onChangeStart: (_) => _isScrubbing = true,
            onChanged: (value) {
              setState(() {
                _position = Duration(seconds: value.toInt());
              });
            },
            onChangeEnd: (value) {
              _isScrubbing = false;
              _controller?.seekTo(Duration(seconds: value.toInt()));
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(_position),
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                _formatDuration(_duration ?? Duration.zero),
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          iconSize: 32,
          onPressed: () => _seekRelative(-5),
          icon: const Icon(Icons.replay_5, color: Color(0xFFFB6F92)),
        ),
        const SizedBox(width: 12),
        InkWell(
          onTap: _togglePlayPause,
          borderRadius: BorderRadius.circular(40),
          child: Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFFFF8FAB), Color(0xFFFB6F92)],
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0x33FB6F92),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              _isPlaying ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
              size: 36,
            ),
          ),
        ),
        const SizedBox(width: 12),
        IconButton(
          iconSize: 32,
          onPressed: () => _seekRelative(5),
          icon: const Icon(Icons.forward_5, color: Color(0xFFFB6F92)),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller?.removeListener(_videoListener);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: const Navbar(currentPage: 'home'),
        body: const Center(
          child: CircularProgressIndicator(color: Color(0xFFFB6F92)),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: const Navbar(currentPage: 'home'),
        body: Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            margin: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFFFFF0F6),
              borderRadius: BorderRadius.all(Radius.circular(24)),
            ),
            child: Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFFB00020),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      );
    }

    final controller = _controller;
    final isInitialized = controller != null && controller.value.isInitialized;

    if (!isInitialized) {
      return Scaffold(
        appBar: const Navbar(currentPage: 'home'),
        body: const Center(child: Text('Video could not be loaded.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Your Story Video',
          style: TextStyle(
            color: Color(0xFF49243E),
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: const Color(0xFFFFCFE2),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF49243E)),
      ),
      backgroundColor: const Color(0xFFFFF7FB),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFF7FB), Color(0xFFFFE4F1)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                const Text(
                  'Enjoy Your Magical Story!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF49243E),
                  ),
                ),
                const SizedBox(height: 6),
                const SizedBox(height: 16),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final maxVideoHeight = constraints.maxHeight * 0.6;
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ConstrainedBox(
                            constraints: BoxConstraints(
                              maxHeight: maxVideoHeight,
                              maxWidth: constraints.maxWidth * 0.95,
                            ),
                            child: AspectRatio(
                              aspectRatio: controller.value.aspectRatio,
                              child: ClipRRect(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(24)),
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.black,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color(0x33000000),
                                        blurRadius: 12,
                                        offset: Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: VideoPlayer(controller),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildProgressBar(),
                          const SizedBox(height: 8),
                          _buildControls(),
                          const SizedBox(height: 12),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}