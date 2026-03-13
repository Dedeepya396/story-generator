// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:typed_data';
// import 'story_display_page.dart';
// import 'navbar.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import '../services/story_serviceFront.dart';
// import '../screens/ai_chatbot_modal.dart';
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
//   void _openChatbot() {
//   showModalBottomSheet(
//     context: context,
//     isScrollControlled: true,
//     backgroundColor: Colors.transparent,
//     builder: (_) {
//       return AIChatbotModal(
//         onInsertStory: (story) {
//           setState(() {
//             _storyController.text = story;
//           });
//         },
//       );
//     },
//   );
// }
//   final TextEditingController _storyController = TextEditingController();
//   final List<Uint8List> _uploadedImageBytes = [];
  
//   // ✅ Changed: Use dropdown value instead of TextEditingController
//   // String _selectedLanguage = 'english';  // Default language
//   String _selectedInputLanguage = 'english';   // Language you write in
//   String _selectedOutputLanguage = 'english';  // Language for video narration
//   String _selectedGender = 'female';           // Narrator voice gender
 
  
//   bool _isPublic = true;
//   List<Map<String, String>> _selectedCharacters = [];

//   // ✅ Language options matching backend
//   final List<Map<String, String>> _languageOptions = [
//     {'code': 'english', 'name': 'English', 'native': 'English'},
//     {'code': 'hindi', 'name': 'Hindi', 'native': 'हिन्दी'},
//     {'code': 'tamil', 'name': 'Tamil', 'native': 'தமிழ்'},
//     {'code': 'telugu', 'name': 'Telugu', 'native': 'తెలుగు'},
//     {'code': 'malayalam', 'name': 'Malayalam', 'native': 'മലയാളം'},
//     {'code': 'kannada', 'name': 'Kannada', 'native': 'ಕನ್ನಡ'},
//     {'code': 'bengali', 'name': 'Bengali', 'native': 'বাংলা'},
//     {'code': 'gujarati', 'name': 'Gujarati', 'native': 'ગુજરાતી'},
//     {'code': 'marathi', 'name': 'Marathi', 'native': 'मराठी'},
//     {'code': 'punjabi', 'name': 'Punjabi', 'native': 'ਪੰਜਾਬੀ'},
//     {'code': 'odia', 'name': 'Odia', 'native': 'ଓଡ଼ିଆ'},
//     {'code': 'assamese', 'name': 'Assamese', 'native': 'অসমীয়া'},
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _selectedCharacters = List.from(widget.selectedCharacters);
//   }

//   @override
//   void dispose() {
//     _storyController.dispose();
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

//   Future<Map<String, dynamic>?> _generateVideoFromBackend(
//     String storyText,
//     String inputLang,
//     String outputLang,
//   ) async {
//     try {
//       final uri = Uri.parse('http://127.0.0.1:8000/videos/generate');
//       print('Sending request to: $uri');
      
//       final response = await http.post(
//         uri,
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({
//           'story': storyText,
//           'input_language': inputLang,
//           'output_language': outputLang,
//           'gender': _selectedGender,
//         }),
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         return {
//           'video_url': data['video_path'] ?? data['video_url'],
//           'cover_url': data['cover_image'] ?? data['cover_url'],
//           'title': data['title'] ?? 'Untitled',
//           'genre': data['genre'] ?? 'General',
//           'voice_fallback': data['voice_fallback'] ?? false,
//         };
//       } else {
//         print('Error response: ${response.body}');
//         return null;
//       }
//     } catch (e) {
//       print('Exception in _generateVideoFromBackend: $e');
//       return null;
//     }
//   }


//   Future<Map<String, dynamic>> _submitStory(String? videoUrl, String? coverUrl, String? storyTitle, String? storyGenre) async {
//     final storyText = _storyController.text.trim();

//     if (storyText.isEmpty) {
//       return {'success': false, 'message': 'Please write your story before submitting'};
//     }

//     final String titleToSend = (storyTitle != null && storyTitle.trim().isNotEmpty)
//         ? storyTitle.trim()
//         : (storyText.isNotEmpty ? (storyText.length > 30 ? storyText.substring(0, 30) : storyText) : 'Untitled');

//     final String genreToSend = (storyGenre != null && storyGenre.trim().isNotEmpty) ? storyGenre.trim() : 'General';


//     final res = await StoryService.createStory(
//       title: titleToSend,
//       description: storyText,
//       language: _selectedOutputLanguage,  // ✅ Use selected language
//       displayFlag: _isPublic,
//       genre: genreToSend,
//       videoUrl: videoUrl,
//       coverUrl: coverUrl,
//     );

//     return res;
//   }

//    String _getPlaceholderText() {
//     final placeholders = {
//       'english': 'Once upon a time...',
//       'hindi': 'एक समय की बात है...',
//       'tamil': 'ஒரு காலத்தில்...',
//       'telugu': 'ఒకప్పుడు...',
//       'malayalam': 'ഒരു കാലത്ത്...',
//       'kannada': 'ಒಂದು ಕಾಲದಲ್ಲಿ...',
//       'bengali': 'এক সময়...',
//       'gujarati': 'એક વખત...',
//       'marathi': 'एकदा...',
//       'punjabi': 'ਇੱਕ ਵਾਰ...',
//       'odia': 'ଏକଥର...',
//       'assamese': 'এবাৰ...',
//     };
//     return placeholders[_selectedInputLanguage] ?? 'Write your story here...';
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: Navbar(currentPage: 'home'),
//       body: SingleChildScrollView(  // ⭐ Added ScrollView
//         child: Padding(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // ===== Selected Characters Preview =====
//               if (_selectedCharacters.isNotEmpty) ...[
//                 const Text(
//                   'Selected Characters',
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 10),
//                 SizedBox(
//                   height: 90,
//                   child: ListView.separated(
//                     scrollDirection: Axis.horizontal,
//                     itemCount: _selectedCharacters.length,
//                     separatorBuilder: (_, __) => const SizedBox(width: 12),
//                     itemBuilder: (context, index) {
//                       final character = _selectedCharacters[index];
//                       return Column(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Stack(
//                             children: [
//                               ClipRRect(
//                                 borderRadius: BorderRadius.circular(10),
//                                 child: Image.asset(
//                                   character['image']!,
//                                   width: 56,
//                                   height: 56,
//                                   fit: BoxFit.cover,
//                                 ),
//                               ),
//                               Positioned(
//                                 top: 0,
//                                 right: 0,
//                                 child: GestureDetector(
//                                   onTap: () {
//                                     setState(() {
//                                       _selectedCharacters.removeAt(index);
//                                     });
//                                   },
//                                   child: Container(
//                                     decoration: const BoxDecoration(
//                                       color: Colors.black54,
//                                       shape: BoxShape.circle,
//                                     ),
//                                     child: const Icon(Icons.close,
//                                         size: 14, color: Colors.white),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 4),
//                           Text(
//                             character['name']!,
//                             style: const TextStyle(fontSize: 11),
//                           ),
//                         ],
//                       );
//                     },
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//               ],

//               // ===== Add Characters Section =====
//               const Text(
//                 'Add Characters',
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 12),

//               const SizedBox(height: 20),

//               // ⭐ NEW: Language Selection Card
//               Card(
//                 elevation: 3,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.all(16),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: [
//                           Icon(Icons.language, color: Colors.blue.shade700, size: 24),
//                           const SizedBox(width: 8),
//                           const Text(
//                             'Language Settings',
//                             style: TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 16),

//                       // ⭐ Input Language Dropdown
//                       const Text(
//                         'Story Input Language',
//                         style: TextStyle(
//                           fontSize: 14,
//                           fontWeight: FontWeight.w600,
//                           color: Colors.black87,
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       Container(
//                         padding: const EdgeInsets.symmetric(horizontal: 12),
//                         decoration: BoxDecoration(
//                           color: Colors.blue.shade50,
//                           borderRadius: BorderRadius.circular(10),
//                           border: Border.all(color: Colors.blue.shade200),
//                         ),
//                         child: DropdownButtonHideUnderline(
//                           child: DropdownButton<String>(
//                             value: _selectedInputLanguage,
//                             isExpanded: true,
//                             icon: const Icon(Icons.keyboard_arrow_down, color: Colors.blue),
//                             style: const TextStyle(
//                               fontSize: 15,
//                               color: Colors.black87,
//                             ),
//                             items: _languageOptions.map((lang) {
//                               return DropdownMenuItem<String>(
//                                 value: lang['code'],
//                                 child: Row(
//                                   children: [
//                                     const Icon(Icons.edit, size: 18, color: Colors.blue),
//                                     const SizedBox(width: 10),
//                                     Text('${lang['name']} (${lang['native']})'),
//                                   ],
//                                 ),
//                               );
//                             }).toList(),
//                             onChanged: (String? newValue) {
//                               setState(() {
//                                 _selectedInputLanguage = newValue ?? 'english';
//                               });
//                             },
//                           ),
//                         ),
//                       ),
                      
//                       const SizedBox(height: 16),

//                       // ⭐ Output Language Dropdown
//                       const Text(
//                         'Video Audio Language',
//                         style: TextStyle(
//                           fontSize: 14,
//                           fontWeight: FontWeight.w600,
//                           color: Colors.black87,
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       Container(
//                         padding: const EdgeInsets.symmetric(horizontal: 12),
//                         decoration: BoxDecoration(
//                           color: Colors.green.shade50,
//                           borderRadius: BorderRadius.circular(10),
//                           border: Border.all(color: Colors.green.shade200),
//                         ),
//                         child: DropdownButtonHideUnderline(
//                           child: DropdownButton<String>(
//                             value: _selectedOutputLanguage,
//                             isExpanded: true,
//                             icon: const Icon(Icons.keyboard_arrow_down, color: Colors.green),
//                             style: const TextStyle(
//                               fontSize: 15,
//                               color: Colors.black87,
//                             ),
//                             items: _languageOptions.map((lang) {
//                               return DropdownMenuItem<String>(
//                                 value: lang['code'],
//                                 child: Row(
//                                   children: [
//                                     const Icon(Icons.volume_up, size: 18, color: Colors.green),
//                                     const SizedBox(width: 10),
//                                     Text('${lang['name']} (${lang['native']})'),
//                                   ],
//                                 ),
//                               );
//                             }).toList(),
//                             onChanged: (String? newValue) {
//                               setState(() {
//                                 _selectedOutputLanguage = newValue ?? 'english';
//                               });
//                             },
//                           ),
//                         ),
//                       ),

//                       const SizedBox(height: 16),
                      
//                       // ⭐ Narrator Gender Selection
//                       const Text(
//                         'Narrator Voice',
//                         style: TextStyle(
//                           fontSize: 14,
//                           fontWeight: FontWeight.w600,
//                           color: Colors.black87,
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       Row(
//                         children: [
//                           Expanded(
//                             child: ChoiceChip(
//                               label: const Center(child: Text('Female Voice')),
//                               selected: _selectedGender == 'female',
//                               onSelected: (selected) {
//                                 if (selected) setState(() => _selectedGender = 'female');
//                               },
//                               selectedColor: Colors.pink.shade100,
//                               avatar: Icon(Icons.face_retouching_natural, 
//                                 color: _selectedGender == 'female' ? Colors.pink : Colors.grey),
//                             ),
//                           ),
//                           const SizedBox(width: 8),
//                           Expanded(
//                             child: ChoiceChip(
//                               label: const Center(child: Text('Male Voice')),
//                               selected: _selectedGender == 'male',
//                               onSelected: (selected) {
//                                 if (selected) setState(() => _selectedGender = 'male');
//                               },
//                               selectedColor: Colors.blue.shade100,
//                               avatar: Icon(Icons.face, 
//                                 color: _selectedGender == 'male' ? Colors.blue : Colors.grey),
//                             ),
//                           ),
//                         ],
//                       ),

//                       // ⭐ Info Box
//                       const SizedBox(height: 12),
//                       Container(
//                         padding: const EdgeInsets.all(12),
//                         decoration: BoxDecoration(
//                           color: Colors.amber.shade50,
//                           borderRadius: BorderRadius.circular(8),
//                           border: Border.all(color: Colors.amber.shade200),
//                         ),
//                         child: Row(
//                           children: [
//                             Icon(Icons.info_outline, color: Colors.amber.shade800, size: 20),
//                             const SizedBox(width: 8),
//                             Expanded(
//                               child: Text(
//                                 'Write in ${_languageOptions.firstWhere((l) => l['code'] == _selectedInputLanguage)['name']}, '
//                                 'hear in ${_languageOptions.firstWhere((l) => l['code'] == _selectedOutputLanguage)['name']} '
//                                 '(${_selectedGender == 'female' ? 'Female' : 'Male'} voice)',
//                                 style: TextStyle(
//                                   fontSize: 12,
//                                   color: Colors.amber.shade900,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 20),

//               // ===== Public/Private Toggle =====
//               SwitchListTile(
//                 title: const Text('Make Story Public'),
//                 subtitle: const Text('Others can see this story'),
//                 value: _isPublic,
//                 activeColor: Colors.blue,
//                 onChanged: (val) {
//                   setState(() {
//                     _isPublic = val;
//                   });
//                 },
//               ),

//               const SizedBox(height: 20),

//               // ===== Story Text Box =====
//               // const Text(
//               //   'Your Story',
//               //   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               // ),
//                 Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [

//                   const Text(
//                     'Your Story',
//                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                   ),

//                   ElevatedButton.icon(
//                     onPressed: _openChatbot,
//                     icon: const Icon(Icons.auto_awesome),
//                     label: const Text("AI Story"),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.deepPurple,
//                       foregroundColor: Colors.white,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                     ),
//                   ),

//                 ],
//               ),
//               const SizedBox(height: 10),

//               // ⭐ Changed: Fixed height instead of Expanded
//               Container(
//                 height: 300,  // Fixed height
//                 decoration: BoxDecoration(
//                   border: Border.all(color: Colors.grey.shade300),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: TextField(
//                   controller: _storyController,
//                   maxLines: null,
//                   expands: true,
//                   textAlignVertical: TextAlignVertical.top,
//                   decoration: InputDecoration(
//                     hintText: _getPlaceholderText(),  // ⭐ Dynamic placeholder
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: BorderSide.none,
//                     ),
//                     filled: true,
//                     fillColor: Colors.grey.shade50,
//                     contentPadding: const EdgeInsets.all(16),
//                   ),
//                 ),
//               ),
              
//               const SizedBox(height: 20),

//               // ===== Submit Button =====
//               SizedBox(
//                 width: double.infinity,
//                 height: 55,
//                 child: ElevatedButton.icon(
//                   onPressed: () async {
//                     final storyText = _storyController.text.trim();
//                     if (storyText.isEmpty) {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(
//                           content: Text('Please write a story first!'),
//                           backgroundColor: Colors.orange,
//                         ),
//                       );
//                       return;
//                     }

//                     // Show loading dialog
//                     showDialog(
//                       context: context,
//                       barrierDismissible: false,
//                       builder: (_) => Center(
//                         child: Container(
//                           padding: const EdgeInsets.all(24),
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(16),
//                           ),
//                           child: Column(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               const CircularProgressIndicator(),
//                               const SizedBox(height: 20),
//                               Text(
//                                 'Generating Video',
//                                 style: const TextStyle(
//                                   fontSize: 18,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                               const SizedBox(height: 8),
//                               Text(
//                                 'Input: ${_languageOptions.firstWhere((l) => l['code'] == _selectedInputLanguage)['name']}',
//                                 style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
//                               ),
//                               Text(
//                                 'Audio: ${_languageOptions.firstWhere((l) => l['code'] == _selectedOutputLanguage)['name']} (${_selectedGender.toUpperCase()})',
//                                 style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
//                               ),
//                               const SizedBox(height: 8),
//                               Text(
//                                 'This may take 3-5 minutes...',
//                                 style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     );

//                     // ⭐ Generate video with BOTH languages
//                     final videoResults = await _generateVideoFromBackend(
//                       storyText,
//                       _selectedInputLanguage,   // What language you wrote in
//                       _selectedOutputLanguage,  // What language for audio
//                     );

//                     Navigator.pop(context); // Remove loading dialog

//                     if (videoResults == null || videoResults['video_url'] == null) {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(
//                           content: Text("Failed to generate video"),
//                           backgroundColor: Colors.red,
//                         ),
//                       );
//                       return;
//                     }

//                     final videoUrl = videoResults['video_url'];
//                     final coverUrl = videoResults['cover_url'];
//                     final title = videoResults['title'] ?? 'Untitled';
//                     final genre = videoResults['genre'] ?? 'General';
//                     final voiceFallback = videoResults['voice_fallback'] ?? false;

//                     // Submit story to database
//                     final res = await _submitStory(videoUrl, coverUrl, title, genre);

//                     if (res['success'] == true) {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => StoryDisplayPage(
//                             videoUrl: videoUrl,
//                             voiceFallback: voiceFallback,
//                             storyText: _storyController.text,
//                             storyTitle: title,
//                           ),
//                         ),
//                       );
//                     } else {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(
//                           content: Text(res['message'] ?? 'Failed to create story'),
//                           backgroundColor: Colors.red,
//                         ),
//                       );
//                     }
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.blue,
//                     foregroundColor: Colors.white,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     elevation: 3,
//                   ),
//                   icon: const Icon(Icons.send, size: 24),
//                   label: const Text(
//                     'Generate & Submit Story',
//                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                   ),
//                 ),
//               ),
              
//               const SizedBox(height: 20),  // Bottom padding
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'story_display_page.dart';
import 'navbar.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/story_serviceFront.dart';
import '../screens/ai_chatbot_modal.dart';

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
  void _openChatbot() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return AIChatbotModal(
          onInsertStory: (story) {
            setState(() {
              _storyController.text = story;
            });
          },
        );
      },
    );
  }

  final TextEditingController _storyController = TextEditingController();
  final List<Uint8List> _uploadedImageBytes = [];

  String _selectedInputLanguage = 'english';
  String _selectedOutputLanguage = 'english';
  String _selectedGender = 'female';

  bool _isPublic = true;
  List<Map<String, String>> _selectedCharacters = [];

  final List<Map<String, String>> _languageOptions = [
    {'code': 'english', 'name': 'English', 'native': 'English'},
    {'code': 'hindi', 'name': 'Hindi', 'native': 'हिन्दी'},
    {'code': 'tamil', 'name': 'Tamil', 'native': 'தமிழ்'},
    {'code': 'telugu', 'name': 'Telugu', 'native': 'తెలుగు'},
    {'code': 'malayalam', 'name': 'Malayalam', 'native': 'മലയാളം'},
    {'code': 'kannada', 'name': 'Kannada', 'native': 'ಕನ್ನಡ'},
    {'code': 'bengali', 'name': 'Bengali', 'native': 'বাংলা'},
    {'code': 'gujarati', 'name': 'Gujarati', 'native': 'ગુજરાતી'},
    {'code': 'marathi', 'name': 'Marathi', 'native': 'मराठी'},
    {'code': 'punjabi', 'name': 'Punjabi', 'native': 'ਪੰਜਾਬੀ'},
    {'code': 'odia', 'name': 'Odia', 'native': 'ଓଡ଼ିଆ'},
    {'code': 'assamese', 'name': 'Assamese', 'native': 'অসমীয়া'},
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

  Future<Map<String, dynamic>?> _generateVideoFromBackend(
    String storyText,
    String inputLang,
    String outputLang,
  ) async {
    try {
      final uri = Uri.parse('http://127.0.0.1:8000/videos/generate');
      print('Sending request to: $uri');

      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'story': storyText,
          'input_language': inputLang,
          'output_language': outputLang,
          'gender': _selectedGender,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'video_url': data['video_path'] ?? data['video_url'],
          'cover_url': data['cover_image'] ?? data['cover_url'],
          'title': data['title'] ?? 'Untitled',
          'genre': data['genre'] ?? 'General',
          'voice_fallback': data['voice_fallback'] ?? false,
          'subtitle_url': data['subtitle_url'] ?? data['subtitleUrl'] ?? null,
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

    Future<Map<String, dynamic>> _submitStory(
      String? videoUrl, String? coverUrl, String? storyTitle, String? storyGenre, String? subtitleUrl) async {
    final storyText = _storyController.text.trim();

    if (storyText.isEmpty) {
      return {'success': false, 'message': 'Please write your story before submitting'};
    }

    final String titleToSend = (storyTitle != null && storyTitle.trim().isNotEmpty)
        ? storyTitle.trim()
        : (storyText.isNotEmpty
            ? (storyText.length > 30 ? storyText.substring(0, 30) : storyText)
            : 'Untitled');

    final String genreToSend =
        (storyGenre != null && storyGenre.trim().isNotEmpty) ? storyGenre.trim() : 'General';

    final res = await StoryService.createStory(
      title: titleToSend,
      description: storyText,
      language: _selectedOutputLanguage,
      displayFlag: _isPublic,
      genre: genreToSend,
      videoUrl: videoUrl,
      coverUrl: coverUrl,
      subtitleUrl: subtitleUrl,
    );

    return res;
  }

  String _getPlaceholderText() {
    final placeholders = {
      'english': 'Once upon a time...',
      'hindi': 'एक समय की बात है...',
      'tamil': 'ஒரு காலத்தில்...',
      'telugu': 'ఒకప్పుడు...',
      'malayalam': 'ഒരു കാലത്ത്...',
      'kannada': 'ಒಂದು ಕಾಲದಲ್ಲಿ...',
      'bengali': 'এক সময়...',
      'gujarati': 'એક વખત...',
      'marathi': 'एकदा...',
      'punjabi': 'ਇੱਕ ਵਾਰ...',
      'odia': 'ଏକଥର...',
      'assamese': 'এবাৰ...',
    };
    return placeholders[_selectedInputLanguage] ?? 'Write your story here...';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: Navbar(currentPage: 'home'),
      // ── Outer scroll + grey page background ──────────────────────────────
      // backgroundColor: Colors.grey.shade100,
      // body: SingleChildScrollView(
      //   child: Padding(
      //     padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
      //     child: Center(
      //       child: ConstrainedBox(
      //         // ── Max-width container (card) ─────────────────────────────
      //         constraints: const BoxConstraints(maxWidth: 1000),
      //         child: Container(
      //           decoration: BoxDecoration(
      //             color: Colors.white,
      //             borderRadius: BorderRadius.circular(20),
      //             boxShadow: [
      //               BoxShadow(
      //                 color: Colors.black.withOpacity(0.07),
      //                 blurRadius: 20,
      //                 offset: const Offset(0, 4),
      //               ),
      //             ],
      //           ),
      //           padding: const EdgeInsets.all(28),
      //           child: Column(
       backgroundColor: Colors.transparent,
       body: Stack(
        children: [
          // Full-screen background image
          Positioned.fill(
            child: Image.asset(
              'images/bg.png', // <-- put your image here
              fit: BoxFit.cover,
            ),
          ),
          // Optional dark overlay to improve text contrast
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.25)),
          ),
          // Main scrollable content
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
              child: Center(
                child: ConstrainedBox(
                  // ── Max-width container (card) ─────────────────────────────
                  constraints: const BoxConstraints(maxWidth: 1000),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.65),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.07),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Page title ─────────────────────────────────────────
                        const Text(
                          'Write a Story',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                    const SizedBox(height: 6),
                    Text(
                      'Craft your story and turn it into a video',
                      style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                    ),
                    const Divider(height: 32),

                    // ===== Selected Characters Preview =====
                    if (_selectedCharacters.isNotEmpty) ...[
                      const Text(
                        'Selected Characters',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),

                    // ===== Language Selection Card =====
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey.shade200),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.language, color: Colors.blue.shade700, size: 22),
                                const SizedBox(width: 8),
                                const Text(
                                  'Language Settings',
                                  style: TextStyle(
                                      fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Input Language
                            const Text(
                              'Story Input Language',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.blue.shade200),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedInputLanguage,
                                  isExpanded: true,
                                  icon: const Icon(Icons.keyboard_arrow_down,
                                      color: Colors.blue),
                                  style: const TextStyle(
                                      fontSize: 14, color: Colors.black87),
                                  items: _languageOptions.map((lang) {
                                    return DropdownMenuItem<String>(
                                      value: lang['code'],
                                      child: Row(
                                        children: [
                                          const Icon(Icons.edit,
                                              size: 16, color: Colors.blue),
                                          const SizedBox(width: 10),
                                          Text(
                                              '${lang['name']} (${lang['native']})'),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      _selectedInputLanguage =
                                          newValue ?? 'english';
                                    });
                                  },
                                ),
                              ),
                            ),

                            const SizedBox(height: 14),

                            // Output Language
                            const Text(
                              'Video Audio Language',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.green.shade200),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedOutputLanguage,
                                  isExpanded: true,
                                  icon: const Icon(Icons.keyboard_arrow_down,
                                      color: Colors.green),
                                  style: const TextStyle(
                                      fontSize: 14, color: Colors.black87),
                                  items: _languageOptions.map((lang) {
                                    return DropdownMenuItem<String>(
                                      value: lang['code'],
                                      child: Row(
                                        children: [
                                          const Icon(Icons.volume_up,
                                              size: 16, color: Colors.green),
                                          const SizedBox(width: 10),
                                          Text(
                                              '${lang['name']} (${lang['native']})'),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      _selectedOutputLanguage =
                                          newValue ?? 'english';
                                    });
                                  },
                                ),
                              ),
                            ),

                            const SizedBox(height: 14),

                            // Narrator Gender
                            const Text(
                              'Narrator Voice',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: ChoiceChip(
                                    label: const Center(
                                        child: Text('Female Voice')),
                                    selected: _selectedGender == 'female',
                                    onSelected: (selected) {
                                      if (selected)
                                        setState(
                                            () => _selectedGender = 'female');
                                    },
                                    selectedColor: Colors.pink.shade100,
                                    avatar: Icon(
                                        Icons.face_retouching_natural,
                                        color: _selectedGender == 'female'
                                            ? Colors.pink
                                            : Colors.grey),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ChoiceChip(
                                    label:
                                        const Center(child: Text('Male Voice')),
                                    selected: _selectedGender == 'male',
                                    onSelected: (selected) {
                                      if (selected)
                                        setState(
                                            () => _selectedGender = 'male');
                                    },
                                    selectedColor: Colors.blue.shade100,
                                    avatar: Icon(Icons.face,
                                        color: _selectedGender == 'male'
                                            ? Colors.blue
                                            : Colors.grey),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            // Info box
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.amber.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border:
                                    Border.all(color: Colors.amber.shade200),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.info_outline,
                                      color: Colors.amber.shade800, size: 18),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Write in ${_languageOptions.firstWhere((l) => l['code'] == _selectedInputLanguage)['name']}, '
                                      'hear in ${_languageOptions.firstWhere((l) => l['code'] == _selectedOutputLanguage)['name']} '
                                      '(${_selectedGender == 'female' ? 'Female' : 'Male'} voice)',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.amber.shade900),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ===== Public/Private Toggle =====
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: SwitchListTile(
                        title: const Text('Make Story Public'),
                        subtitle: const Text('Others can see this story'),
                        value: _isPublic,
                        activeColor: Colors.blue,
                        onChanged: (val) {
                          setState(() {
                            _isPublic = val;
                          });
                        },
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ===== Story Text Box =====
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Your Story',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        ElevatedButton.icon(
                          onPressed: _openChatbot,
                          icon: const Icon(Icons.auto_awesome, size: 16),
                          label: const Text("AI Story"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    Container(
                      height: 300,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: _storyController,
                        maxLines: null,
                        expands: true,
                        textAlignVertical: TextAlignVertical.top,
                        decoration: InputDecoration(
                          hintText: _getPlaceholderText(),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          contentPadding: const EdgeInsets.all(16),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ===== Submit Button =====
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final storyText = _storyController.text.trim();
                          if (storyText.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please write a story first!'),
                                backgroundColor: Colors.orange,
                              ),
                            );
                            return;
                          }

                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (_) => Center(
                              child: Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const CircularProgressIndicator(),
                                    const SizedBox(height: 20),
                                    const Text(
                                      'Generating Video',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Input: ${_languageOptions.firstWhere((l) => l['code'] == _selectedInputLanguage)['name']}',
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey.shade700),
                                    ),
                                    Text(
                                      'Audio: ${_languageOptions.firstWhere((l) => l['code'] == _selectedOutputLanguage)['name']} (${_selectedGender.toUpperCase()})',
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey.shade700),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'This may take 3-5 minutes...',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade500),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );

                          final videoResults = await _generateVideoFromBackend(
                            storyText,
                            _selectedInputLanguage,
                            _selectedOutputLanguage,
                          );

                          Navigator.pop(context);

                          if (videoResults == null ||
                              videoResults['video_url'] == null) {
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
                          final title = videoResults['title'] ?? 'Untitled';
                          final genre = videoResults['genre'] ?? 'General';
                          final voiceFallback =
                              videoResults['voice_fallback'] ?? false;
                          final subtitleUrl = videoResults['subtitle_url'];

                          final res = await _submitStory(
                              videoUrl, coverUrl, title, genre, subtitleUrl);

                          if (res['success'] == true) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => StoryDisplayPage(
                                  videoUrl: videoUrl,
                                  voiceFallback: voiceFallback,
                                  storyText: _storyController.text,
                                  storyTitle: title,
                                  subtitleUrl: subtitleUrl,
                                ),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(res['message'] ??
                                    'Failed to create story'),
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
                          elevation: 3,
                        ),
                        icon: const Icon(Icons.send, size: 22),
                        label: const Text(
                          'Generate & Submit Story',
                          style: TextStyle(
                              fontSize: 17, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),

//                     const SizedBox(height: 8),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
const SizedBox(height: 8),
                  ],          // Column children
                ),            // Column
              ),              // Container
            ),                // ConstrainedBox
          ),                  // Center
        ),                    // Padding
      ),                      // SingleChildScrollView
      ],                      // Stack children  ← YOU ARE MISSING THIS
    ),                        // Stack
    );                        // Scaffold
  }
}