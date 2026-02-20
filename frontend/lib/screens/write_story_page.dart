import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'story_display_page.dart';
import 'character_selection_page.dart';
import 'navbar.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class WriteStoryPage extends StatefulWidget {
  final List<Map<String, String>> selectedCharacters;
  const WriteStoryPage({
    super.key,
    required this.selectedCharacters,
  });

  @override
  State<WriteStoryPage> createState() => _WriteStoryPageState();
}

class _WriteStoryPageState extends State<WriteStoryPage> {
  final TextEditingController _storyController = TextEditingController();
  final List<Uint8List> _uploadedImageBytes = [];
  
  // ✅ FIX: Remove 'late', initialize with empty list so it's never uninitialized
  List<Map<String, String>> _selectedCharacters = [];

  @override
  void initState() {
    super.initState();
    _selectedCharacters = List.from(widget.selectedCharacters);
  }

  @override
  void dispose() {
    _storyController.dispose();
    super.dispose();
  }

  Future<void> _pickImagesFromDevice() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();
    if (images.isNotEmpty) {
      for (final xfile in images) {
        final bytes = await xfile.readAsBytes();
        setState(() {
          _uploadedImageBytes.add(bytes);
        });
      }
    }
  }

  Future<void> _goToLibrary() async {
    final result = await Navigator.push<List<Map<String, String>>>(
      context,
      MaterialPageRoute(
        builder: (_) => const CharacterSelectionPage(
          isFromWritePage: true,
        ),
      ),
    );

    if (result != null && result.isNotEmpty) {
      setState(() {
        for (final newChar in result) {
          final alreadyAdded =
              _selectedCharacters.any((c) => c['name'] == newChar['name']);
          if (!alreadyAdded) {
            _selectedCharacters.add(newChar);
          }
        }
      });
    }
  }

  Future<String?> _generateVideoFromBackend(String storyText) async {
    try {
      final uri = Uri.parse('http://127.0.0.1:8000/video/generate');

      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'story': storyText}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['video_url']; // Cloudinary URL
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     appBar: Navbar(currentPage: 'home'),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ===== Selected Characters Preview =====
            if (_selectedCharacters.isNotEmpty) ...[
              const Text(
                'Selected Characters',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 90,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedCharacters.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final character = _selectedCharacters[index];
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.asset(
                                character['image']!,
                                width: 56,
                                height: 56,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedCharacters.removeAt(index);
                                  });
                                },
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.close,
                                      size: 14, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          character['name']!,
                          style: const TextStyle(fontSize: 11),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],

            // ===== Add Characters Section =====
            const Text(
              'Add Characters',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                // Option 1: Select from Library
                Expanded(
                  child: GestureDetector(
                    onTap: _goToLibrary,
                    child: Container(
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.photo_library,
                              color: Colors.blue.shade600, size: 28),
                          const SizedBox(height: 6),
                          Text(
                            'Select from Library',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Option 2: Upload from Device
                Expanded(
                  child: GestureDetector(
                    onTap: _pickImagesFromDevice,
                    child: Container(
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.upload_file,
                              color: Colors.green.shade600, size: 28),
                          const SizedBox(height: 6),
                          Text(
                            'Upload Images',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // ===== Uploaded Images Preview =====
            if (_uploadedImageBytes.isNotEmpty) ...[
              const SizedBox(height: 12),
              SizedBox(
                height: 90,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _uploadedImageBytes.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    return Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.memory(
                            _uploadedImageBytes[index],
                            width: 70,
                            height: 70,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 2,
                          right: 2,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _uploadedImageBytes.removeAt(index);
                              });
                            },
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close,
                                  size: 16, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],

            const SizedBox(height: 20),
            const Text(
              'Your Story',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // ===== Story Text Box =====
            Expanded(
              child: TextField(
                controller: _storyController,
                maxLines: null,
                expands: true,
                decoration: InputDecoration(
                  hintText: 'Write your story here...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ===== Submit Button =====
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  final storyText = _storyController.text.trim();
                  if (storyText.isEmpty) return;

                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );

                  final videoUrl = await _generateVideoFromBackend(storyText);

                  Navigator.pop(context); // remove loading dialog

                  if (videoUrl != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StoryDisplayPage(videoUrl: videoUrl),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Failed to generate video")),
                    );
                  }
                },
                child: const Text(
                  'Submit Story',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
