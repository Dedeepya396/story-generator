import 'dart:convert';
import 'dart:html' as html; // Only for web
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';
import 'navbar.dart';
class Subtitle {
  final Duration start;
  final Duration end;
  final String text;

  Subtitle({
    required this.start,
    required this.end,
    required this.text,
  });
}

List<Subtitle> parseSrt(String srt) {
  // Generic VTT/SRT parser: finds timestamp lines and collects following text until blank line
  final regex = RegExp(r"(\d{2}:\d{2}:\d{2}[\.,]\d{3})\s*-->\s*(\d{2}:\d{2}:\d{2}[\.,]\d{3})");
  List<Subtitle> subs = [];
  final lines = srt.replaceAll('\r', '').split('\n');
  for (int i = 0; i < lines.length; i++) {
    final line = lines[i].trim();
    final m = regex.firstMatch(line);
    if (m != null) {
      String startRaw = m.group(1)!;
      String endRaw = m.group(2)!;

      Duration parseTime(String t) {
        t = t.replaceAll(',', '.');
        final parts = t.split(':');
        final hours = int.parse(parts[0]);
        final minutes = int.parse(parts[1]);
        final secParts = parts[2].split('.');
        final seconds = int.parse(secParts[0]);
        final ms = int.parse((secParts.length > 1 ? secParts[1] : '0').padRight(3, '0'));
        return Duration(hours: hours, minutes: minutes, seconds: seconds, milliseconds: ms);
      }

      final start = parseTime(startRaw);
      final end = parseTime(endRaw);

      // collect subsequent non-empty lines as subtitle text
      final buffer = StringBuffer();
      int j = i + 1;
      while (j < lines.length && lines[j].trim().isNotEmpty) {
        buffer.write((buffer.isEmpty ? '' : ' ') + lines[j].trim());
        j++;
      }

      subs.add(Subtitle(start: start, end: end, text: buffer.toString()));
    }
  }
  return subs;
}

class StoryDisplayPage extends StatefulWidget {
  final String videoUrl;
  final bool voiceFallback;
  final String? storyText;
  final String? storyTitle;
  final String? subtitleUrl;

  const StoryDisplayPage({
    super.key,
    required this.videoUrl,
    this.voiceFallback = false,
    this.storyText,
    this.storyTitle,
    this.subtitleUrl,
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
List<Subtitle> _subtitles = [];
String _currentSubtitle = "";
bool _showSubtitles = false;
bool _subtitlesLoading = false;
bool _subtitlesAvailable = false;
  // Speed control variables
  double _playbackSpeed = 1.0;
  bool _showSpeedMenu = false;
  final List<double> _speedOptions = [0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0];

  // Story text variables
  bool _showStoryModal = false;
Future<void> _loadSubtitles() async {
  try {
    setState(() {
      _subtitlesLoading = true;
      _subtitlesAvailable = false;
    });

    String subtitleLocation;
    if (widget.subtitleUrl != null && widget.subtitleUrl!.isNotEmpty) {
      subtitleLocation = widget.subtitleUrl!;
    } else {
      // Derive .vtt from video URL; remove query params if present
      try {
        final vuri = Uri.parse(widget.videoUrl);
        String path = vuri.path;
        if (path.toLowerCase().endsWith('.mp4')) {
          path = path.substring(0, path.length - 4) + '.vtt';
        } else {
          path = path + '.vtt';
        }
        final derived = vuri.replace(path: path, queryParameters: null);
        subtitleLocation = derived.toString();
      } catch (e) {
        subtitleLocation = widget.videoUrl.replaceAll(RegExp(r"(\?.*)?$"), '')
            .replaceAll('.mp4', '.vtt');
      }
    }

    print('Attempting to load subtitles from: $subtitleLocation');
    final response = await http.get(Uri.parse(subtitleLocation));

    if (response.statusCode == 200 && response.body.isNotEmpty) {
      final parsed = parseSrt(response.body);
      setState(() {
        _subtitles = parsed;
        _subtitlesAvailable = _subtitles.isNotEmpty;
      });
      if (_subtitlesAvailable) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Subtitles loaded')),
          );
        });
      }
    } else {
      print('Subtitle fetch returned ${response.statusCode}');
    }
  } catch (e) {
    print("Subtitle load error: $e");
  } finally {
    setState(() {
      _subtitlesLoading = false;
    });
  }
}
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
        _loadSubtitles();
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
  void _updateSubtitle(Duration position) {
  for (var sub in _subtitles) {
    if (position >= sub.start && position <= sub.end) {
      setState(() {
        _currentSubtitle = sub.text;
      });
      return;
    }
  }

  setState(() {
    _currentSubtitle = "";
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
    _updateSubtitle(value.position);
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

  void _changeSpeed(double speed) {
    final controller = _controller;
    if (controller == null) return;

    setState(() {
      _playbackSpeed = speed;
      _showSpeedMenu = false;
    });

    controller.setPlaybackSpeed(speed);
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

      const SizedBox(width: 12),

      _buildSpeedButton(),

      const SizedBox(width: 12),

      _buildStoryTextButton(),

      const SizedBox(width: 12),

      // ⭐ Subtitle Toggle Button
      IconButton(
        iconSize: 32,
        icon: Icon(
          _showSubtitles ? Icons.closed_caption : Icons.closed_caption_off,
          color: const Color(0xFFFB6F92),
        ),
        onPressed: () {
          if (_subtitlesLoading) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Subtitles are still loading...')),
            );
            return;
          }
          if (!_subtitlesAvailable) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No subtitles available for this video')),
            );
            return;
          }
          setState(() {
            _showSubtitles = !_showSubtitles;
          });
          if (_showSubtitles) {
            // immediately update current subtitle for the current position
            _updateSubtitle(_position);
          }
        },
        tooltip: "Toggle Subtitles",
      ),
    ],
  );
}
  Widget _buildSpeedButton() {
    return PopupMenuButton<double>(
      onSelected: _changeSpeed,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: const Color(0xFFFFF7FB),
      itemBuilder: (BuildContext context) {
        return _speedOptions.map((speed) {
          return PopupMenuItem<double>(
            value: speed,
            child: Row(
              children: [
                Text(
                  '${speed}x',
                  style: TextStyle(
                    color: _playbackSpeed == speed
                        ? const Color(0xFFFB6F92)
                        : const Color(0xFF49243E),
                    fontWeight: _playbackSpeed == speed
                        ? FontWeight.w700
                        : FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
                if (_playbackSpeed == speed)
                  const Padding(
                    padding: EdgeInsets.only(left: 12),
                    child: Icon(
                      Icons.check,
                      color: Color(0xFFFB6F92),
                      size: 20,
                    ),
                  ),
              ],
            ),
          );
        }).toList();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFFB6F92), width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          '${_playbackSpeed}x',
          style: const TextStyle(
            color: Color(0xFFFB6F92),
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildStoryTextButton() {
    if (widget.storyText == null || widget.storyText!.isEmpty) {
      return const SizedBox.shrink();
    }

    return IconButton(
      iconSize: 32,
      onPressed: () {
        setState(() {
          _showStoryModal = true;
        });
        _showStoryTextModal();
      },
      icon: const Icon(Icons.description, color: Color(0xFFFB6F92)),
      tooltip: 'View Story',
    );
  }

  void _showStoryTextModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: Color(0xFFFFF7FB),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.storyTitle ?? 'Story',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF49243E),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Color(0xFF49243E)),
                  ),
                ],
              ),
            ),
            const Divider(color: Color(0xFFFFCFE2), thickness: 1),
            // Story text content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Text(
                  widget.storyText ?? 'No story text available',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF49243E),
                    height: 1.6,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Your Story Video',
          style: TextStyle(
            color: Color(0xFF49243E),
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF49243E)),
        systemOverlayStyle: null,
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
                                  child: Stack(
  alignment: Alignment.bottomCenter,
  children: [
    VideoPlayer(controller),

    if (_showSubtitles && _currentSubtitle.isNotEmpty)
      Positioned(
        bottom: 20,
        left: 20,
        right: 20,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            _currentSubtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
  ],
),
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