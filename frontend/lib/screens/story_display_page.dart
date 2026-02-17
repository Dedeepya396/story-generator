import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:html' as html; // Only for web!
import 'navbar.dart';

class StoryDisplayPage extends StatefulWidget {
  final String storyText;

  const StoryDisplayPage({super.key, required this.storyText});

  @override
  State<StoryDisplayPage> createState() => _StoryDisplayPageState();
}

class _StoryDisplayPageState extends State<StoryDisplayPage> {
  VideoPlayerController? _controller;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _generateAndLoadVideo();
  }

  Future<void> _generateAndLoadVideo() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final uri = Uri.parse('http://127.0.0.1:8000/video/generate');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'story': widget.storyText}),
      );

      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        // Create a Blob and Object URL for the video
        final blob = html.Blob([bytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);

        _controller = VideoPlayerController.network(url)
          ..initialize().then((_) {
            setState(() {});
            _controller!.play();
          });
      } else {
        setState(() {
          _error = 'Failed to generate video. (${response.statusCode})';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        appBar: Navbar(currentPage: 'home'),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Scaffold(
        body: Center(child: Text(_error!)),
      );
    }
    if (_controller != null && _controller!.value.isInitialized) {
      return Scaffold(
        appBar: AppBar(title: const Text('Your Story Video')),
        body: Center(
          child: AspectRatio(
            aspectRatio: _controller!.value.aspectRatio,
            child: VideoPlayer(_controller!),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            setState(() {
              _controller!.value.isPlaying
                  ? _controller!.pause()
                  : _controller!.play();
            });
          },
          child: Icon(
            _controller!.value.isPlaying ? Icons.pause : Icons.play_arrow,
          ),
        ),
      );
    }
    return const Scaffold(
      body: Center(child: Text('Video could not be loaded.')),
    );
  }
}