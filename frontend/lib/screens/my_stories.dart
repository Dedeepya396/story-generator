// // import 'package:flutter/material.dart';
// // import 'story_details_page.dart';
// // import 'navbar.dart';

// // class MyStoriesPage extends StatefulWidget {
// //   const MyStoriesPage({super.key});

// //   @override
// //   State<MyStoriesPage> createState() => _MyStoriesPageState();
// // }

// // class _MyStoriesPageState extends State<MyStoriesPage> with RouteAware {
// //   final List<Map<String, String>> stories = const [
// //     {'title': 'Lion in the Jungle', 'image': 'assets/images/story3.jpeg'},
// //     {'title': 'My Quiet Imagination', 'image': 'assets/images/story1.jpeg'},
// //     {'title': 'Bug Hunt', 'image': 'assets/images/story2.jpeg'},
// //     {'title': 'Animal Friends', 'image': 'assets/images/story4.jpeg'},
// //   ];

// //   String searchQuery = '';
// //   final TextEditingController _searchController = TextEditingController();

// //   @override
// //   void initState() {
// //     super.initState();
// //     // Initialize the controller with empty text
// //     _searchController.text = '';
// //   }

// //   @override
// //   void dispose() {
// //     _searchController.dispose();
// //     super.dispose();
// //   }

// //   // Method to clear search when returning from another page
// //   void _clearSearch() {
// //     setState(() {
// //       searchQuery = '';
// //       _searchController.clear();
// //     });
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     final filteredStories = stories.where((story) {
// //       return story['title']!
// //           .toLowerCase()
// //           .contains(searchQuery.toLowerCase());
// //     }).toList();

// //     return Scaffold(
// //       appBar: Navbar(currentPage: 'home'),
// //       body: Container(
// //         decoration: const BoxDecoration(
// //           image: DecorationImage(
// //             image: AssetImage('assets/images/my_stories_bg.png'),
// //             fit: BoxFit.cover,
// //           ),
// //         ),
// //         child: SafeArea(
// //           child: Column(
// //             children: [
// //               AppBar(
// //                 title: const Text('My Stories'),
// //                 backgroundColor: Colors.transparent,
// //                 elevation: 0,
// //                 foregroundColor: Colors.black,
// //               ),

// //               // ===================== CENTERED CONTENT =====================
// //               Expanded(
// //                 child: Center(
// //                   child: ConstrainedBox(
// //                     constraints: BoxConstraints(
// //                       maxWidth: MediaQuery.of(context).size.width * 0.70,
// //                     ),
// //                     child: Column(
// //                       mainAxisAlignment: MainAxisAlignment.center,
// //                       children: [
// //                         // ===================== SEARCH BAR =====================
// //                         Container(
// //                           margin: const EdgeInsets.only(bottom: 72), // 1 inch gap (72 logical pixels ≈ 1 inch)
// //                           child: TextField(
// //                             controller: _searchController,
// //                             decoration: InputDecoration(
// //                               hintText: 'Search stories...',
// //                               prefixIcon: const Icon(Icons.search),
// //                               suffixIcon: searchQuery.isNotEmpty
// //                                   ? IconButton(
// //                                       icon: const Icon(Icons.clear),
// //                                       onPressed: _clearSearch,
// //                                     )
// //                                   : null,
// //                               filled: true,
// //                               fillColor: Colors.white.withOpacity(0.8),
// //                               border: OutlineInputBorder(
// //                                 borderRadius: BorderRadius.circular(12),
// //                                 borderSide: BorderSide.none,
// //                               ),
// //                               contentPadding: const EdgeInsets.symmetric(
// //                                 horizontal: 16,
// //                                 vertical: 12,
// //                               ),
// //                             ),
// //                             onChanged: (value) {
// //                               setState(() {
// //                                 searchQuery = value;
// //                               });
// //                             },
// //                           ),
// //                         ),

// //                         // ===================== STORIES CONTAINER =====================
// //                         Flexible(
// //                           child: Container(
// //                             padding: const EdgeInsets.all(16),
// //                             decoration: BoxDecoration(
// //                               color: Colors.white.withOpacity(0.6),
// //                               borderRadius: BorderRadius.circular(16),
// //                             ),
// //                             child: SingleChildScrollView(
// //                               child: Wrap(
// //                                 spacing: 24,
// //                                 runSpacing: 24,
// //                                 alignment: WrapAlignment.center,
// //                                 children: filteredStories.map((story) {
// //                                   return GestureDetector(
// //                                     onTap: () async {
// //                                       // Navigate to the detail page
// //                                       await Navigator.push(
// //                                         context,
// //                                         MaterialPageRoute(
// //                                           builder: (_) => StoryDetailPage(
// //                                             title: story['title']!,
// //                                             imagePath: story['image']!,
// //                                           ),
// //                                         ),
// //                                       );
                                      
// //                                       // Clear search when returning from detail page
// //                                       _clearSearch();
// //                                     },
// //                                     child: _SmallStoryBox(
// //                                       title: story['title']!,
// //                                       imagePath: story['image']!,
// //                                     ),
// //                                   );
// //                                 }).toList(),
// //                               ),
// //                             ),
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }

// // class _SmallStoryBox extends StatelessWidget {
// //   final String title;
// //   final String imagePath;

// //   const _SmallStoryBox({
// //     required this.title,
// //     required this.imagePath,
// //   });

// //   @override
// //   Widget build(BuildContext context) {
// //     return Card(
// //       elevation: 4,
// //       shape: RoundedRectangleBorder(
// //         borderRadius: BorderRadius.circular(12),
// //       ),
// //       child: Column(
// //         mainAxisSize: MainAxisSize.min,
// //         children: [
// //           ClipRRect(
// //             borderRadius: const BorderRadius.vertical(
// //               top: Radius.circular(12),
// //             ),
// //             child: Image.asset(
// //               imagePath,
// //               width: 250,
// //               height: 300,
// //               fit: BoxFit.cover,
// //               filterQuality: FilterQuality.high,
// //             ),
// //           ),
// //           Padding(
// //             padding: const EdgeInsets.all(8),
// //             child: SizedBox(
// //               width: 250,
// //               child: Text(
// //                 title,
// //                 maxLines: 2,
// //                 textAlign: TextAlign.center,
// //                 overflow: TextOverflow.ellipsis,
// //                 style: const TextStyle(
// //                   fontSize: 13,
// //                   fontWeight: FontWeight.w600,
// //                 ),
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }

// import 'package:flutter/material.dart';
// import 'story_display_page.dart';
// import 'navbar.dart';
// import '../services/auth_service.dart';
// import '../services/my_stories_service.dart' as MyStoriesApi;

// class MyStoriesPage extends StatefulWidget {
//   const MyStoriesPage({super.key});

//   @override
//   State<MyStoriesPage> createState() => _MyStoriesPageState();
// }

// class _MyStoriesPageState extends State<MyStoriesPage> {
//   List<Map<String, dynamic>> _stories = [];
//   bool _loading = true;
//   String? _error;
//   String searchQuery = '';
//   final TextEditingController _searchController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     _loadStories();
//   }

//   Future<void> _loadStories() async {
//     setState(() {
//       _loading = true;
//       _error = null;
//     });

//     final user = AuthService.user;
//     final userId = user?['id'] ?? user?['_id'] ?? user?['user_id'];
//     if (userId == null) {
//       setState(() {
//         _error = 'User not logged in';
//         _loading = false;
//       });
//       return;
//     }

//     try {
//       final stories = await MyStoriesApi.StoryService.fetchStoriesByUser(userId);
//       setState(() {
//         _stories = stories;
//       });
//     } catch (e) {
//       setState(() {
//         _error = 'Failed to load stories';
//       });
//     } finally {
//       setState(() {
//         _loading = false;
//       });
//     }
//   }

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }

//   void _clearSearch() {
//     setState(() {
//       searchQuery = '';
//       _searchController.clear();
//     });
//   }

//   // Widget _buildCard(Map<String, dynamic> s) {
//   //   final title = (s['title'] ?? 'Untitled').toString();
//   //   final videoUrl = (s['videoUrl'] ?? '').toString();
//   //   final cover = (videoUrl.isNotEmpty)
//   //       ? Container(
//   //           color: Colors.black12,
//   //           child: const Center(
//   //             child: Icon(Icons.play_circle_fill, size: 64, color: Color(0xFFFB6F92)),
//   //           ),
//   //         )
//   //       : Image.asset('assets/images/story3.jpeg', fit: BoxFit.cover);

//   //   return GestureDetector(
//   //     onTap: () {
//   //       if (videoUrl.isNotEmpty) {
//   //         Navigator.push(
//   //           context,
//   //           MaterialPageRoute(builder: (_) => StoryDisplayPage(videoUrl: videoUrl)),
//   //         );
//   //       } else {
//   //         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No video available for this story')));
//   //       }
//   //     },
//   //     child: Card(
//   //       elevation: 3,
//   //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//   //       child: Column(
//   //         crossAxisAlignment: CrossAxisAlignment.stretch,
//   //         children: [
//   //           Expanded(
//   //             child: ClipRRect(
//   //               borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
//   //               child: cover,
//   //             ),
//   //           ),
//   //           Padding(
//   //             padding: const EdgeInsets.all(8.0),
//   //             child: Text(
//   //               title,
//   //               maxLines: 2,
//   //               overflow: TextOverflow.ellipsis,
//   //               textAlign: TextAlign.center,
//   //               style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
//   //             ),
//   //           ),
//   //         ],
//   //       ),
//   //     ),
//   //   );
//   // }

//   // ...existing code...
//   Widget _buildCard(Map<String, dynamic> s) {
//     final title = (s['title'] ?? 'Untitled').toString();
//     final videoUrl = (s['videoUrl'] ?? '').toString();

//     // Always show a cover image (no play icon). Clicking navigates to display page.
//     final cover = Image.asset(
//       'assets/images/story3.jpeg',
//       fit: BoxFit.cover,
//       width: double.infinity,
//       height: double.infinity,
//     );

//     return GestureDetector(
//       onTap: () {
//         if (videoUrl.isNotEmpty) {
//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (_) => StoryDisplayPage(videoUrl: videoUrl)),
//           );
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('No video available for this story')),
//           );
//         }
//       },
//       child: Card(
//         elevation: 3,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             Expanded(
//               child: ClipRRect(
//                 borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
//                 child: cover,
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Text(
//                 title,
//                 maxLines: 2,
//                 overflow: TextOverflow.ellipsis,
//                 textAlign: TextAlign.center,
//                 style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// // ...existing code...
//   @override
//   Widget build(BuildContext context) {
//     final filtered = _stories.where((s) {
//       final t = (s['title'] ?? '').toString().toLowerCase();
//       return t.contains(searchQuery.toLowerCase());
//     }).toList();

//     return Scaffold(
//       appBar: Navbar(currentPage: 'home'),
//       body: Container(
//         decoration: const BoxDecoration(
//           image: DecorationImage(
//             image: AssetImage('assets/images/my_stories_bg.png'),
//             fit: BoxFit.cover,
//           ),
//         ),
//         child: SafeArea(
//           child: Column(
//             children: [
//               AppBar(
//                 title: const Text('My Stories'),
//                 backgroundColor: Colors.transparent,
//                 elevation: 0,
//                 foregroundColor: Colors.black,
//               ),
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
//                 child: TextField(
//                   controller: _searchController,
//                   decoration: InputDecoration(
//                     hintText: 'Search stories...',
//                     prefixIcon: const Icon(Icons.search),
//                     suffixIcon: searchQuery.isNotEmpty
//                         ? IconButton(icon: const Icon(Icons.clear), onPressed: _clearSearch)
//                         : null,
//                     filled: true,
//                     fillColor: Colors.white.withOpacity(0.8),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: BorderSide.none,
//                     ),
//                     contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                   ),
//                   onChanged: (v) => setState(() => searchQuery = v),
//                 ),
//               ),
//               Expanded(
//                 child: _loading
//                     ? const Center(child: CircularProgressIndicator())
//                     : _error != null
//                         ? Center(child: Text(_error!))
//                         : _stories.isEmpty
//                             ? RefreshIndicator(
//                                 onRefresh: _loadStories,
//                                 child: ListView(
//                                   children: const [
//                                     SizedBox(height: 120),
//                                     Center(child: Text('No stories yet. Pull down to refresh.')),
//                                   ],
//                                 ),
//                               )
//                             : RefreshIndicator(
//                                 onRefresh: _loadStories,
//                                 child: Center(
//                                   child: ConstrainedBox(
//                                     constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.70),
//                                     child: Container(
//                                     padding: const EdgeInsets.all(16),
//                                     decoration: BoxDecoration(
//                                       color: Colors.white.withOpacity(0.6),
//                                       borderRadius: BorderRadius.circular(16),
//                                     ),
//                                     child: GridView.builder(
//                                     // child: GridView.builder(
//                                       padding: const EdgeInsets.all(12),
//                                       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                                         crossAxisCount: 2,
//                                         childAspectRatio: 0.75,
//                                         crossAxisSpacing: 24,
//                                         mainAxisSpacing: 24,
//                                       ),
//                                       itemCount: filtered.length,
//                                       itemBuilder: (context, idx) => _buildCard(filtered[idx]),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }



import 'package:flutter/material.dart';
import 'story_display_page.dart';
import 'navbar.dart';
import '../services/auth_service.dart';
import '../services/my_stories_service.dart' as MyStoriesApi;

class MyStoriesPage extends StatefulWidget {
  const MyStoriesPage({super.key});

  @override
  State<MyStoriesPage> createState() => _MyStoriesPageState();
}

class _MyStoriesPageState extends State<MyStoriesPage> {
  List<Map<String, dynamic>> _stories = [];
  bool _loading = true;
  String? _error;
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadStories();
  }

  Future<void> _loadStories() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final user = AuthService.user;
    final userId = user?['id'] ?? user?['_id'] ?? user?['user_id'];
    if (userId == null) {
      setState(() {
        _error = 'User not logged in';
        _loading = false;
      });
      return;
    }

    try {
      final stories = await MyStoriesApi.StoryService.fetchStoriesByUser(userId);
      setState(() {
        _stories = stories;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load stories';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearSearch() {
    setState(() {
      searchQuery = '';
      _searchController.clear();
    });
  }

  Widget _buildCard(Map<String, dynamic> s) {
    final title = (s['title'] ?? 'Untitled').toString();
    final videoUrl = (s['videoUrl'] ?? '').toString();
    final coverUrl = (s['coverUrl'] ?? '').toString();

    Widget cover;
    if (coverUrl.isNotEmpty) {
      cover = Image.network(
        coverUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(child: CircularProgressIndicator());
        },
        errorBuilder: (context, error, stackTrace) => Image.asset(
          'assets/images/story3.jpeg',
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
      );
    } else {
      cover = Image.asset(
        'assets/images/story3.jpeg',
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }

    return GestureDetector(
      onTap: () {
        if (videoUrl.isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => StoryDisplayPage(videoUrl: videoUrl)),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No video available for this story')),
          );
        }
      },
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _stories.where((s) {
      final t = (s['title'] ?? '').toString().toLowerCase();
      return t.contains(searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: Navbar(currentPage: 'home'),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/my_stories_bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              AppBar(
                title: const Text('My Stories'),
                backgroundColor: Colors.transparent,
                elevation: 0,
                foregroundColor: Colors.black,
              ),


              // center the search field and constrain its width to match content container
              Center(
               child: ConstrainedBox(
                 constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.70,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                    child: SizedBox(
                      height: 48, // adjust height if needed
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search stories...',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: searchQuery.isNotEmpty
                              ? IconButton(icon: const Icon(Icons.clear), onPressed: _clearSearch)
                              : null,
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        onChanged: (v) => setState(() => searchQuery = v),
                      ),
                    ),
                  ),
                ),
              ),
 // ...existing code...
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _error != null
                        ? Center(child: Text(_error!))
                        : _stories.isEmpty
                            ? RefreshIndicator(
                                onRefresh: _loadStories,
                                child: ListView(
                                  children: const [
                                    SizedBox(height: 120),
                                    Center(child: Text('No stories yet. Pull down to refresh.')),
                                  ],
                                ),
                              )
                            : RefreshIndicator(
                                onRefresh: _loadStories,
                                child: Center(
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.70),
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.6),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: GridView.builder(
                                        padding: const EdgeInsets.all(12),
                                        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                                          maxCrossAxisExtent: 300,
                                          childAspectRatio: 1.15,
                                          crossAxisSpacing: 24,
                                          mainAxisSpacing: 24,
                                        ),
                                        itemCount: filtered.length,
                                        itemBuilder: (context, idx) => _buildCard(filtered[idx]),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}