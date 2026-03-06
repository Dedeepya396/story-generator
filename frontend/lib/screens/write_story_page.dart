// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:typed_data';
// import 'story_display_page.dart';
// import 'character_selection_page.dart';
// import 'navbar.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import '../services/story_serviceFront.dart';

// class WriteStoryPage extends StatefulWidget {
//   final List<Map<String, String>> selectedCharacters;
//   const WriteStoryPage({
//     super.key,
//     required this.selectedCharacters,
//   });

//   @override
//   State<WriteStoryPage> createState() => _WriteStoryPageState();
// }

// class _WriteStoryPageState extends State<WriteStoryPage> {
//   final TextEditingController _storyController = TextEditingController();
//   final List<Uint8List> _uploadedImageBytes = [];
//   final TextEditingController _languageController = TextEditingController();
//   bool _isPublic = true;

//   // ✅ FIX: Remove 'late', initialize with empty list so it's never uninitialized
//   List<Map<String, String>> _selectedCharacters = [];

//   @override
//   void initState() {
//     super.initState();
//     _selectedCharacters = List.from(widget.selectedCharacters);
//   }

//   @override
//   void dispose() {
//     _storyController.dispose();
//     _languageController.dispose();
//     super.dispose();
//   }

//   Future<void> _pickImagesFromDevice() async {
//     final ImagePicker picker = ImagePicker();
//     final List<XFile> images = await picker.pickMultiImage();
//     if (images.isNotEmpty) {
//       for (final xfile in images) {
//         final bytes = await xfile.readAsBytes();
//         setState(() {
//           _uploadedImageBytes.add(bytes);
//         });
//       }
//     }
//   }

//   Future<void> _goToLibrary() async {
//     final result = await Navigator.push<List<Map<String, String>>>(
//       context,
//       MaterialPageRoute(
//         builder: (_) => const CharacterSelectionPage(
//           isFromWritePage: true,
//         ),
//       ),
//     );

//     if (result != null && result.isNotEmpty) {
//       setState(() {
//         for (final newChar in result) {
//           final alreadyAdded =
//               _selectedCharacters.any((c) => c['name'] == newChar['name']);
//           if (!alreadyAdded) {
//             _selectedCharacters.add(newChar);
//           }
//         }
//       });
//     }
//   }

//   Future<Map<String, String?>?> _generateVideoFromBackend(String storyText, String lang) async {
//     try {
//       final uri = Uri.parse('http://127.0.0.1:8000/video/generate');
//       print(uri);
//       final response = await http.post(
//         uri,
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({'story': storyText, 'language': lang}),
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         return {
//           'video_url': data['video_url'],
//           'cover_url': data['cover_url'],
//         };
//       } else {
//         return null;
//       }
//     } catch (e) {
//       return null;
//     }
//   }

//   Future<Map<String, dynamic>> _submitStory(String? videoUrl, String? coverUrl) async {
//     final storyText = _storyController.text.trim();
//     final language = _languageController.text.trim();

//     if (storyText.isEmpty) {
//       return {'success': false, 'message': 'Please write your story before submitting'};
//     }

//     final title = storyText.isNotEmpty
//         ? (storyText.length > 30 ? storyText.substring(0, 30) : storyText)
//         : 'Untitled';
//     final genre = "General";

//     final res = await StoryService.createStory(
//       title: title,
//       description: storyText,
//       language: language.isEmpty ? null : language,
//       displayFlag: _isPublic,
//       genre: genre,
//       videoUrl: videoUrl,
//       coverUrl: coverUrl,
//     );

//     return res;
//   }
//  // ...existing code...
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//      appBar: Navbar(currentPage: 'home'),
//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [

//             // ===== Selected Characters Preview =====
//             if (_selectedCharacters.isNotEmpty) ...[
//               const Text(
//                 'Selected Characters',
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 10),
//               SizedBox(
//                 height: 90,
//                 child: ListView.separated(
//                   scrollDirection: Axis.horizontal,
//                   itemCount: _selectedCharacters.length,
//                   separatorBuilder: (_, __) => const SizedBox(width: 12),
//                   itemBuilder: (context, index) {
//                     final character = _selectedCharacters[index];
//                     return Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Stack(
//                           children: [
//                             ClipRRect(
//                               borderRadius: BorderRadius.circular(10),
//                               child: Image.asset(
//                                 character['image']!,
//                                 width: 56,
//                                 height: 56,
//                                 fit: BoxFit.cover,
//                               ),
//                             ),
//                             Positioned(
//                               top: 0,
//                               right: 0,
//                               child: GestureDetector(
//                                 onTap: () {
//                                   setState(() {
//                                     _selectedCharacters.removeAt(index);
//                                   });
//                                 },
//                                 child: Container(
//                                   decoration: const BoxDecoration(
//                                     color: Colors.black54,
//                                     shape: BoxShape.circle,
//                                   ),
//                                   child: const Icon(Icons.close,
//                                       size: 14, color: Colors.white),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 4),
//                         Text(
//                           character['name']!,
//                           style: const TextStyle(fontSize: 11),
//                         ),
//                       ],
//                     );
//                   },
//                 ),
//               ),
//               const SizedBox(height: 16),
//             ],

//             // ===== Add Characters Section =====
//             const Text(
//               'Add Characters',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 12),

//             Row(
//               children: [
//                 // Option 1: Select from Library
//                 Expanded(
//                   child: GestureDetector(
//                     onTap: _goToLibrary,
//                     child: Container(
//                       height: 80,
//                       decoration: BoxDecoration(
//                         color: Colors.blue.shade50,
//                         borderRadius: BorderRadius.circular(12),
//                         border: Border.all(color: Colors.blue.shade200),
//                       ),
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Icon(Icons.photo_library,
//                               color: Colors.blue.shade600, size: 28),
//                           const SizedBox(height: 6),
//                           Text(
//                             'Select from Library',
//                             style: TextStyle(
//                               fontSize: 12,
//                               fontWeight: FontWeight.w600,
//                               color: Colors.blue.shade700,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 12),

//                 // Option 2: Upload from Device
//                 Expanded(
//                   child: GestureDetector(
//                     onTap: _pickImagesFromDevice,
//                     child: Container(
//                       height: 80,
//                       decoration: BoxDecoration(
//                         color: Colors.green.shade50,
//                         borderRadius: BorderRadius.circular(12),
//                         border: Border.all(color: Colors.green.shade200),
//                       ),
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Icon(Icons.upload_file,
//                               color: Colors.green.shade600, size: 28),
//                           const SizedBox(height: 6),
//                           Text(
//                             'Upload Images',
//                             style: TextStyle(
//                               fontSize: 12,
//                               fontWeight: FontWeight.w600,
//                               color: Colors.green.shade700,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),

//             // ===== Uploaded Images Preview =====
//             if (_uploadedImageBytes.isNotEmpty) ...[
//               const SizedBox(height: 12),
//               SizedBox(
//                 height: 90,
//                 child: ListView.separated(
//                   scrollDirection: Axis.horizontal,
//                   itemCount: _uploadedImageBytes.length,
//                   separatorBuilder: (_, __) => const SizedBox(width: 10),
//                   itemBuilder: (context, index) {
//                     return Stack(
//                       children: [
//                         ClipRRect(
//                           borderRadius: BorderRadius.circular(10),
//                           child: Image.memory(
//                             _uploadedImageBytes[index],
//                             width: 70,
//                             height: 70,
//                             fit: BoxFit.cover,
//                           ),
//                         ),
//                         Positioned(
//                           top: 2,
//                           right: 2,
//                           child: GestureDetector(
//                             onTap: () {
//                               setState(() {
//                                 _uploadedImageBytes.removeAt(index);
//                               });
//                             },
//                             child: Container(
//                               decoration: const BoxDecoration(
//                                 color: Colors.black54,
//                                 shape: BoxShape.circle,
//                               ),
//                               child: const Icon(Icons.close,
//                                   size: 16, color: Colors.white),
//                             ),
//                           ),
//                         ),
//                       ],
//                     );
//                   },
//                 ),
//               ),
//             ],

//             const SizedBox(height: 20),
//             const Text(
//               'Language',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 10),
//             TextField(
//               controller: _languageController,
//               decoration: InputDecoration(
//                 hintText: 'Enter language (e.g., English, Hindi)',
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 filled: true,
//                 fillColor: Colors.grey.shade100,
//               ),
//             ),
          
            
//               SwitchListTile(
//                 title: const Text('Public'),
//                 // subtitle: const Text(_isPublic ? 'Public (visible to others)' : 'Private (only you)'),
//                 value: _isPublic,
//                 onChanged: (val) {
//                   setState(() {
//                     _isPublic = val;
//                   });
//                 },
//               ),

//             const SizedBox(height: 20),
//             const Text(
//               'Your Story',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 10),

//             // ===== Story Text Box =====
//             Expanded(
//               child: TextField(
//                 controller: _storyController,
//                 maxLines: null,
//                 expands: true,
//                 decoration: InputDecoration(
//                   hintText: 'Write your story here...',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   filled: true,
//                   fillColor: Colors.grey.shade100,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20),

//             // ===== Submit Button =====
//             SizedBox(
//               width: double.infinity,
//               height: 50,
//               child: ElevatedButton(
//                 onPressed: () async {
//                   final storyText = _storyController.text.trim();
//                   if (storyText.isEmpty) return;
//                   showDialog(
//                     context: context,
//                     barrierDismissible: false,
//                     builder: (_) => const Center(
//                       child: CircularProgressIndicator(),
//                     ),
//                   );

//                   final videoResults = await _generateVideoFromBackend(storyText, _languageController.text.trim());

//                   Navigator.pop(context); // remove loading dialog

//                   if(videoResults == null || videoResults['video_url'] == null){
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(content: Text("Failed to generate video")),
//                     );
//                     return;
//                   }

//                   final videoUrl = videoResults['video_url'];
//                   final coverUrl = videoResults['cover_url'];

//                   final res = await _submitStory(videoUrl, coverUrl);

//                   if(res['success'] == true){
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => StoryDisplayPage(videoUrl: videoUrl!),
//                       ),
//                     );
//                   } else {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(content: Text(res['message'] ?? 'Failed to create story')),
//                     );
//                   }
//                   // if (videoUrl != null) {
//                   //   Navigator.push(
//                   //     context,
//                   //     MaterialPageRoute(
//                   //       builder: (context) => StoryDisplayPage(videoUrl: videoUrl),
//                   //     ),
//                   //   );
//                   // } else {
//                   //   ScaffoldMessenger.of(context).showSnackBar(
//                   //     const SnackBar(content: Text("Failed to generate video")),
//                   //   );
//                   // }
//                 },
//                 child: const Text(
//                   'Submit Story',
//                   style: TextStyle(fontSize: 18),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'story_display_page.dart';
import 'character_selection_page.dart';
import 'navbar.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/story_serviceFront.dart';

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
  
  // ✅ Changed: Use dropdown value instead of TextEditingController
  String _selectedLanguage = 'english';  // Default language
  
  bool _isPublic = true;
  List<Map<String, String>> _selectedCharacters = [];

  // ✅ Language options matching backend
  final List<Map<String, String>> _languageOptions = [
    {'code': 'english', 'name': 'English'},
    {'code': 'hindi', 'name': 'Hindi (हिन्दी)'},
    {'code': 'tamil', 'name': 'Tamil (தமிழ்)'},
    {'code': 'telugu', 'name': 'Telugu (తెలుగు)'},
    {'code': 'malayalam', 'name': 'Malayalam (മലയാളം)'},
    {'code': 'kannada', 'name': 'Kannada (ಕನ್ನಡ)'},
    {'code': 'bengali', 'name': 'Bengali (বাংলা)'},
    {'code': 'gujarati', 'name': 'Gujarati (ગુજરાતી)'},
    {'code': 'marathi', 'name': 'Marathi (मराठी)'},
    {'code': 'punjabi', 'name': 'Punjabi (ਪੰਜਾਬੀ)'},
    {'code': 'odia', 'name': 'Odia (ଓଡ଼ିଆ)'},
    {'code': 'assamese', 'name': 'Assamese (অসমীয়া)'},
  ];

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

  Future<Map<String, String?>?> _generateVideoFromBackend(String storyText, String lang) async {
    try {
      final uri = Uri.parse('http://127.0.0.1:8000/video/generate');
      print('Sending request to: $uri');
      print('Language: $lang');
      
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'story': storyText, 'language': lang}),
      );

      print('Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Video URL: ${data['video_url']}');
        print('Cover URL: ${data['cover_url']}');
        return {
          'video_url': data['video_url'],
          'cover_url': data['cover_url'],
        };
      } else {
        print('Error response: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Exception in _generateVideoFromBackend: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> _submitStory(String? videoUrl, String? coverUrl) async {
    final storyText = _storyController.text.trim();

    if (storyText.isEmpty) {
      return {'success': false, 'message': 'Please write your story before submitting'};
    }

    final title = storyText.isNotEmpty
        ? (storyText.length > 30 ? storyText.substring(0, 30) : storyText)
        : 'Untitled';
    final genre = "General";

    final res = await StoryService.createStory(
      title: title,
      description: storyText,
      language: _selectedLanguage,  // ✅ Use selected language
      displayFlag: _isPublic,
      genre: genre,
      videoUrl: videoUrl,
      coverUrl: coverUrl,
    );

    return res;
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

            // ✅ NEW: Language Dropdown Selector
            const Text(
              'Select Target Language',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedLanguage,
                  isExpanded: true,
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.blue),
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                  items: _languageOptions.map((lang) {
                    return DropdownMenuItem<String>(
                      value: lang['code'],
                      child: Row(
                        children: [
                          const Icon(Icons.language, size: 20, color: Colors.blue),
                          const SizedBox(width: 10),
                          Text(lang['name']!),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedLanguage = newValue ?? 'english';
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ===== Public/Private Toggle =====
            SwitchListTile(
              title: const Text('Public'),
              value: _isPublic,
              onChanged: (val) {
                setState(() {
                  _isPublic = val;
                });
              },
            ),

            const SizedBox(height: 20),

            // ===== Story Text Box =====
            const Text(
              'Your Story',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

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
                  if (storyText.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please write a story first!')),
                    );
                    return;
                  }

                  // Show loading dialog
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) => Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'Generating video in $_selectedLanguage...',
                                  style: const TextStyle(fontSize: 16),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'This may take a few minutes',
                                  style: TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );

                  // ✅ Generate video with selected language
                  final videoResults = await _generateVideoFromBackend(
                    storyText,
                    _selectedLanguage,  // Use dropdown value
                  );

                  Navigator.pop(context); // Remove loading dialog

                  if (videoResults == null || videoResults['video_url'] == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Failed to generate video"),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  final videoUrl = videoResults['video_url'];
                  final coverUrl = videoResults['cover_url'];

                  // Submit story to database
                  final res = await _submitStory(videoUrl, coverUrl);

                  if (res['success'] == true) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StoryDisplayPage(videoUrl: videoUrl!),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(res['message'] ?? 'Failed to create story'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Submit Story',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
