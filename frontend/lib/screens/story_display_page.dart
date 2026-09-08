import 'dart:convert';
import 'dart:html' as html; // Only for web
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';
import 'navbar.dart';
import '../services/story_serviceFront.dart';
import 'quiz_dialog.dart';
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
  // Generic VTT/SRT parser: supports HH:MM:SS.mmm or MM:SS.mmm
  final regex = RegExp(r"((?:\d{2}:)?\d{2}:\d{2}[\.,]\d{3})\s*-->\s*((?:\d{2}:)?\d{2}:\d{2}[\.,]\d{3})");
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
        int hours = 0;
        int minutes = 0;
        int seconds = 0;
        int ms = 0;

        if (parts.length == 3) {
          hours = int.parse(parts[0]);
          minutes = int.parse(parts[1]);
          final secParts = parts[2].split('.');
          seconds = int.parse(secParts[0]);
          ms = int.parse((secParts.length > 1 ? secParts[1] : '0').padRight(3, '0').substring(0, 3));
        } else if (parts.length == 2) {
          minutes = int.parse(parts[0]);
          final secParts = parts[1].split('.');
          seconds = int.parse(secParts[0]);
          ms = int.parse((secParts.length > 1 ? secParts[1] : '0').padRight(3, '0').substring(0, 3));
        }
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
  final String? genre;
  final String? subtitleUrl;
  final List<dynamic>? scenes;
  final List<String>? imageUrls;
  final bool displayFlag;
  final String? coverUrl;
  final String? language;

  const StoryDisplayPage({
    super.key,
    required this.videoUrl,
    this.voiceFallback = false,
    this.storyText,
    this.storyTitle,
    this.genre,
    this.subtitleUrl,
    this.scenes,
    this.imageUrls,
    this.displayFlag = true,
    this.coverUrl,
    this.language,
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

  // Re-voicing state
  bool _revoicing = false;
  String _selectedLanguage = "english";

  // Quiz auto-popup guard: only show once per video completion
  bool _quizShown = false;
  final List<String> _languages = ["english", "hindi", "telugu", "tamil", "malayalam", "kannada", "bengali", "gujarati", "marathi", "punjabi"];

  // Story text variables
  bool _showStoryModal = false;

  late String _currentVideoUrl;
  String? _currentSubtitleUrl;

  Future<void> _revoiceVideo(String lang) async {
    if (_revoicing) return;
    if (widget.scenes == null || widget.imageUrls == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Re-voicing not available for this story.')),
      );
      return;
    }

    setState(() {
      _revoicing = true;
      _selectedLanguage = lang;
    });

    try {
      final response = await http.post(
        Uri.parse('http://localhost:8000/videos/revoice'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'story': widget.storyText ?? "",
          'scenes': widget.scenes,
          'image_urls': widget.imageUrls,
          'target_language': lang,
          'gender': 'female', // Defaulting to female for now
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Re-initialize controller with new video
        final oldController = _controller;
        _controller = VideoPlayerController.network(data['video_url'])
          ..addListener(_videoListener)
          ..setLooping(false)
          ..initialize().then((_) {
            if (!mounted) return;
            setState(() {
              _currentVideoUrl = data['video_url'];
              _currentSubtitleUrl = data['subtitle_url'];
              _loading = false;
              _duration = _controller!.value.duration;
            });
            _controller!.play();
            _loadSubtitles(); // Load new subtitles
            
            // Clean up old controller
            if (oldController != null) {
              oldController.removeListener(_videoListener);
              oldController.dispose();
            }
          });
          
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Re-voiced successfully to $lang!')),
        );

        // Save new version to database
        await StoryService.createStory(
          title: widget.storyTitle ?? 'Untitled',
          description: widget.storyText,
          language: lang,
          genre: widget.genre,
          videoUrl: data['video_url'],
          subtitleUrl: data['subtitle_url'],
          displayFlag: widget.displayFlag,
          coverUrl: widget.coverUrl,
        );
      } else {
        throw Exception('Failed to re-voice: ${response.body}');
      }
    } catch (e) {
      print('Re-voice error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error re-voicing: $e')),
      );
    } finally {
      setState(() {
        _revoicing = false;
      });
    }
  }
  List<Subtitle> _generateFallbackSubtitles() {
    final totalDuration = _duration ?? const Duration(seconds: 15);
    final totalMs = totalDuration.inMilliseconds;
    if (totalMs <= 0) return [];

    List<String> segments = [];

    // 1. Try scenes if available
    if (widget.scenes != null && widget.scenes!.isNotEmpty) {
      for (var scene in widget.scenes!) {
        final text = (scene['translated_text'] ?? scene['text'] ?? '').toString().trim();
        if (text.isNotEmpty) {
          segments.add(text);
        }
      }
    }

    // 2. Otherwise split storyText by punctuation
    if (segments.isEmpty && widget.storyText != null && widget.storyText!.trim().isNotEmpty) {
      final raw = widget.storyText!.trim();
      final splitRegex = RegExp(r'(?<=[.!?\n])\s+');
      final parts = raw.split(splitRegex);
      for (var p in parts) {
        final cleaned = p.trim();
        if (cleaned.isNotEmpty) {
          segments.add(cleaned);
        }
      }
    }

    if (segments.isEmpty) return [];

    final totalChars = segments.fold<int>(0, (sum, item) => sum + item.length);
    if (totalChars == 0) return [];

    List<Subtitle> generated = [];
    int currentStartMs = 0;

    for (int i = 0; i < segments.length; i++) {
      final segText = segments[i];
      final proportion = segText.length / totalChars;
      int segMs = (totalMs * proportion).round();
      if (segMs < 1000) segMs = 1000;

      int endMs = currentStartMs + segMs;
      if (i == segments.length - 1 || endMs > totalMs) {
        endMs = totalMs;
      }

      generated.add(Subtitle(
        start: Duration(milliseconds: currentStartMs),
        end: Duration(milliseconds: endMs),
        text: segText,
      ));

      currentStartMs = endMs;
      if (currentStartMs >= totalMs) break;
    }

    return generated;
  }

  bool _isErrorText(String text) {
    if (text.isEmpty) return false;
    final low = text.toLowerCase();
    return low.contains('error 500') ||
        low.contains('server error') ||
        low.contains("that's an error") ||
        low.contains('please try again later') ||
        low.contains("that's all we know") ||
        low.contains('500 (server error)') ||
        low.contains('http 500');
  }

  Future<List<Subtitle>> _translateSubtitlesIfNeeded(List<Subtitle> subs) async {
    final targetLang = _selectedLanguage.isNotEmpty ? _selectedLanguage : (widget.language ?? 'english');
    if (targetLang.toLowerCase() == 'english' || subs.isEmpty) {
      return subs;
    }

    final hasEnglish = RegExp(r'[a-zA-Z]{3,}');
    bool needsTranslation = false;
    for (var s in subs) {
      if (hasEnglish.hasMatch(s.text)) {
        needsTranslation = true;
        break;
      }
    }

    if (!needsTranslation) return subs;

    List<Subtitle> translatedSubs = [];
    for (var s in subs) {
      if (hasEnglish.hasMatch(s.text)) {
        try {
          final resp = await http.post(
            Uri.parse('http://localhost:8000/subtitles/translate'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'text': s.text,
              'target_language': targetLang,
            }),
          );
          if (resp.statusCode == 200) {
            final data = jsonDecode(resp.body);
            final tText = (data['translated_text'] ?? '').toString();
            if (tText.isNotEmpty && !_isErrorText(tText)) {
              translatedSubs.add(Subtitle(start: s.start, end: s.end, text: tText));
              continue;
            }
          }
        } catch (e) {
          print('Subtitle inline translation error: $e');
        }
      }
      translatedSubs.add(s);
    }
    return translatedSubs;
  }

  Future<void> _loadSubtitles() async {
    try {
      setState(() {
        _subtitlesLoading = true;
        _subtitlesAvailable = false;
      });

      final targetLang = _selectedLanguage.isNotEmpty ? _selectedLanguage : (widget.language ?? 'english');

      List<Subtitle> loaded = [];
      bool alreadyTranslated = false;

      // ── Step 1: Try the pre-translated VTT file from Cloudinary ──────────
      String? subtitleLocation = _currentSubtitleUrl;
      if (subtitleLocation == null || subtitleLocation.isEmpty) {
        subtitleLocation = widget.subtitleUrl;
      }

      if (subtitleLocation != null && subtitleLocation.isNotEmpty) {
        try {
          print('[Subtitles] Fetching VTT from: $subtitleLocation');
          final proxyUrl = Uri.parse(
            'http://localhost:8000/subtitles/fetch?url=${Uri.encodeComponent(subtitleLocation)}'
          );
          final response = await http.get(proxyUrl);
          if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
            final decodedBody = utf8.decode(response.bodyBytes);
            loaded = parseSrt(decodedBody);
            if (loaded.isNotEmpty) {
              final sampleText = loaded.first.text;
              final hasNonAscii = RegExp(r'[^\x00-\x7F]').hasMatch(sampleText);
              final hasEnglishWords = RegExp(r'[a-zA-Z]{3,}').hasMatch(sampleText);
              alreadyTranslated = hasNonAscii || !hasEnglishWords;
              print('[Subtitles] Loaded ${loaded.length} cues from VTT. alreadyTranslated=$alreadyTranslated sample="$sampleText"');
            }
          }
        } catch (e) {
          print('[Subtitles] VTT fetch error: $e');
        }
      }

      // ── Step 2: Fallback — build from pre-translated scenes ──────────────
      if (loaded.isEmpty && widget.scenes != null && widget.scenes!.isNotEmpty) {
        print('[Subtitles] Building from pre-translated scenes...');
        loaded = _generateFallbackSubtitles();
        // Check if scene text is already in target language (non-Latin script check)
        if (loaded.isNotEmpty) {
          final sample = loaded.first.text;
          final hasOnlyLatin = !RegExp(r'[^\x00-\x7F]').hasMatch(sample);
          alreadyTranslated = !hasOnlyLatin; // Non-ASCII chars = already translated
          print('[Subtitles] From scenes: alreadyTranslated=$alreadyTranslated sample="$sample"');
        }
      }

      // ── Step 3: Absolute fallback — split storyText ───────────────────────
      if (loaded.isEmpty) {
        print('[Subtitles] No VTT or scenes — building from storyText...');
        loaded = _generateFallbackSubtitles();
      }

      // ── Step 4: Fast Batch Translate if still in English and target is non-English ──
      if (loaded.isNotEmpty && !alreadyTranslated && targetLang.toLowerCase() != 'english') {
        print('[Subtitles] Fast batch translating ${loaded.length} cues to $targetLang...');
        try {
          final textsToTranslate = loaded.map((s) => s.text).toList();
          final resp = await http.post(
            Uri.parse('http://localhost:8000/subtitles/translate_batch'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'texts': textsToTranslate,
              'target_language': targetLang,
            }),
          );

          if (resp.statusCode == 200) {
            final data = jsonDecode(resp.body);
            final List<dynamic> translatedTexts = data['translated_texts'] ?? [];
            if (translatedTexts.length == loaded.length) {
              List<Subtitle> batchTranslatedSubs = [];
              for (int i = 0; i < loaded.length; i++) {
                final raw = translatedTexts[i].toString();
                final clean = (raw.isNotEmpty && !_isErrorText(raw)) ? raw : loaded[i].text;
                batchTranslatedSubs.add(Subtitle(start: loaded[i].start, end: loaded[i].end, text: clean));
              }
              loaded = batchTranslatedSubs;
              print('[Subtitles] Batch translation completed instantly!');
            }
          }
        } catch (e) {
          print('[Subtitles] Batch translation error: $e');
        }
      }

      setState(() {
        _subtitles = loaded;
        _subtitlesAvailable = _subtitles.isNotEmpty;
        if (_subtitlesAvailable) {
          _showSubtitles = true;
        }
      });

      if (_subtitlesAvailable) {
        _updateSubtitle(_position);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Captions / Subtitles loaded')),
          );
        });
      }
    } catch (e) {
      print('[Subtitles] Load error: $e');
    } finally {
      setState(() {
        _subtitlesLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _currentVideoUrl = widget.videoUrl;
    _currentSubtitleUrl = widget.subtitleUrl;
    if (widget.language != null && widget.language!.isNotEmpty) {
      _selectedLanguage = widget.language!;
    }

    _controller = VideoPlayerController.network(_currentVideoUrl)
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

    // Auto-show quiz when video finishes (if story text is available)
    if (!_quizShown &&
        !value.isPlaying &&
        value.duration.inSeconds > 0 &&
        value.position.inSeconds >= value.duration.inSeconds &&
        widget.storyText != null &&
        widget.storyText!.trim().isNotEmpty) {
      _quizShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          showQuizDialog(
            context,
            widget.storyText!,
            language: _selectedLanguage,
          );
        }
      });
    }
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
          '🎬 Story Time!',
          style: TextStyle(
            color: Color(0xFF49243E),
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white.withOpacity(0.95),
        elevation: 2,
        iconTheme: const IconThemeData(color: Color(0xFF49243E)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pushNamedAndRemoveUntil(
              '/home',
              (route) => false,
            );
          },
        ),
      ),
      backgroundColor: const Color(0xFFFFF7FB),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/story_display_page_background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFFFFE4F1).withOpacity(0.3),
                const Color(0xFFFFF7FB).withOpacity(0.3),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    // const Text(
                    //   '✨ Enjoy Your Story! ✨',
                    //   textAlign: TextAlign.center,
                    //   style: TextStyle(
                    //     fontSize: 24,
                    //     fontWeight: FontWeight.w800,
                    //     color: Color(0xFF49243E),
                    //     letterSpacing: 0.5,
                    //   ),
                    // ),
                    const SizedBox(height: 12),
                    if (widget.storyTitle != null && widget.storyTitle!.isNotEmpty)
                      Text(
                        widget.storyTitle!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFFB6F92),
                        ),
                      ),
                    if (widget.genre != null && widget.genre!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFB6F92).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFFB6F92),
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            widget.genre!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFFB6F92),
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final maxVideoHeight = constraints.maxHeight * 0.65;
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(Radius.circular(28)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFFB6F92).withOpacity(0.4),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxHeight: maxVideoHeight,
                                    maxWidth: constraints.maxWidth * 0.95,
                                  ),
                                  child: AspectRatio(
                                    aspectRatio: controller.value.aspectRatio,
                                    child: ClipRRect(
                                      borderRadius:
                                          const BorderRadius.all(Radius.circular(28)),
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          color: Colors.black,
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
                                                    color: Colors.black87,
                                                    borderRadius: BorderRadius.circular(12),
                                                    border: Border.all(
                                                      color: const Color(0xFFFB6F92),
                                                      width: 2,
                                                    ),
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
                              ),
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      const Color(0xFFFFF7FB).withOpacity(0.95),
                                      const Color(0xFFFFE4F1).withOpacity(0.95),
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                  borderRadius: const BorderRadius.all(Radius.circular(24)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFFB6F92).withOpacity(0.2),
                                      blurRadius: 10,
                                      offset: const Offset(0, -2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    _buildProgressBar(),
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        IconButton(
                                          iconSize: 28,
                                          onPressed: () => _seekRelative(-5),
                                          icon: const Icon(Icons.replay_5,
                                              color: Color(0xFFFB6F92)),
                                          tooltip: '5s Back',
                                        ),
                                        const SizedBox(width: 8),
                                        InkWell(
                                          onTap: _togglePlayPause,
                                          borderRadius: BorderRadius.circular(40),
                                          child: Container(
                                            width: 60,
                                            height: 60,
                                            decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                              gradient: LinearGradient(
                                                colors: [Color(0xFFFF8FAB), Color(0xFFFB6F92)],
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Color(0x44FB6F92),
                                                  blurRadius: 12,
                                                  offset: Offset(0, 4),
                                                ),
                                              ],
                                            ),
                                            child: Icon(
                                              _isPlaying ? Icons.pause : Icons.play_arrow,
                                              color: Colors.white,
                                              size: 32,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        IconButton(
                                          iconSize: 28,
                                          onPressed: () => _seekRelative(5),
                                          icon: const Icon(Icons.forward_5,
                                              color: Color(0xFFFB6F92)),
                                          tooltip: '5s Forward',
                                        ),
                                        const SizedBox(width: 8),
                                        _buildSpeedButton(),
                                        const SizedBox(width: 8),
                                        if (widget.storyText != null && widget.storyText!.isNotEmpty)
                                          IconButton(
                                            iconSize: 24,
                                            onPressed: _showStoryTextModal,
                                            icon: const Icon(Icons.description,
                                                color: Color(0xFFFB6F92)),
                                            tooltip: 'Story Text',
                                          ),
                                        const SizedBox(width: 8),
                                        IconButton(
                                          iconSize: 24,
                                          icon: Icon(
                                            _showSubtitles
                                                ? Icons.closed_caption
                                                : Icons.closed_caption_off,
                                            color: const Color(0xFFFB6F92),
                                          ),
                                          onPressed: () {
                                            if (_subtitlesLoading) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                    content: Text(
                                                        'Subtitles loading...')),
                                              );
                                              return;
                                            }
                                            if (!_subtitlesAvailable) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                    content: Text(
                                                        'No subtitles available')),
                                              );
                                              return;
                                            }
                                            setState(() {
                                              _showSubtitles = !_showSubtitles;
                                            });
                                            if (_showSubtitles) {
                                              _updateSubtitle(_position);
                                            }
                                          },
                                          tooltip: 'Subtitles',
                                        ),
                                        const SizedBox(width: 8),
                                        // Language Re-voicing Dropdown
                                        if (widget.scenes != null)
                                          _revoicing 
                                            ? const SizedBox(
                                                width: 24, 
                                                height: 24, 
                                                child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFFB6F92))
                                              )
                                            : PopupMenuButton<String>(
                                                onSelected: _revoiceVideo,
                                                icon: const Icon(Icons.language, color: Color(0xFFFB6F92)),
                                                tooltip: 'Change Language',
                                                itemBuilder: (context) => _languages.map((l) => PopupMenuItem(
                                                  value: l,
                                                  child: Text(l[0].toUpperCase() + l.substring(1)),
                                                )).toList(),
                                              ),
                                              const SizedBox(width: 8),

// ========================================================
// TAKE QUIZ
// ========================================================

if (widget.storyText != null &&
    widget.storyText!.trim().isNotEmpty)

  ElevatedButton.icon(

    onPressed: () {

      showQuizDialog(
        context,
        widget.storyText!,
        language: _selectedLanguage,
      );

    },

    icon: const Icon(
      Icons.quiz_outlined,
      size: 20,
    ),

    label: const Text(
      "Take Quiz",
    ),

    style: ElevatedButton.styleFrom(

      backgroundColor:
          const Color(0xFFFB6F92),

      foregroundColor:
          Colors.white,

      padding:
          const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 10,
      ),

      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(10),
      ),

      elevation: 2,
    ),
  ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
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
        ),
      ),
    );
  }
}