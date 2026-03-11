// // import 'package:flutter/material.dart';
// // import 'navbar.dart'; // Import the navbar widget

// // class HomePage extends StatelessWidget {
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       // ====== Body ======
// //       appBar: Navbar(currentPage: 'home'),
// //       body: Container(
// //               height: double.infinity,
// //               width: double.infinity,
// //               decoration: BoxDecoration(
// //                 image: DecorationImage(
// //                   image: AssetImage('assets/images/home.png'),
// //                   fit: BoxFit.cover,
// //                 ),
// //               ),
// //               child: Stack(
// //                 children: [
// //                   Container(
// //                     color: Colors.black.withOpacity(0.6),
// //                   ),
// //                   Padding(
// //                     padding: const EdgeInsets.symmetric(horizontal: 50),
// //                     child: Column(
// //                       children: [
// //                         // ===== Navigation Buttons =====
// //                         Padding(
// //                           padding: const EdgeInsets.only(top: 20, bottom: 40),
// //                           child: Row(
// //                             mainAxisAlignment: MainAxisAlignment.center,
// //                           ),
// //                         ),
// //                         Spacer(),
// //                         // ===== Hero Text =====
// //                         Text(
// //                           'Welcome to TinyTales',
// //                           style: TextStyle(
// //                               fontSize: 60,
// //                               fontWeight: FontWeight.bold,
// //                               color: Colors.white),
// //                           textAlign: TextAlign.center,
// //                         ),
// //                         SizedBox(height: 20),
// //                         Text(
// //                           'Generate and enjoy some light hearted tales for little ones!',
// //                           style:
// //                               TextStyle(fontSize: 20, color: Colors.white70),
// //                           textAlign: TextAlign.center,
// //                         ),
// //                         Spacer(),
// //                       ],
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //       ),
// //     );
// //   }
// // }

// // // ===== Feature Card Widget =====
// // class FeatureCard extends StatelessWidget {
// //   final IconData icon;
// //   final String title;
// //   final String description;

// //   FeatureCard(
// //       {required this.icon, required this.title, required this.description});

// //   @override
// //   Widget build(BuildContext context) {
// //     return Container(
// //       width: 400,
// //       height: 350,
// //       padding: EdgeInsets.all(20),
// //       decoration: BoxDecoration(
// //         color: Colors.white,
// //         borderRadius: BorderRadius.circular(15),
// //         boxShadow: [
// //           BoxShadow(
// //               color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))
// //         ],
// //       ),
// //       child: Column(
// //         children: [
// //           Icon(icon, size: 50, color: Colors.blue),
// //           SizedBox(height: 20),
// //           Text(
// //             title,
// //             style: TextStyle(
// //                 fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue),
// //             textAlign: TextAlign.center,
// //           ),
// //           SizedBox(height: 10),
// //           Text(
// //             description,
// //             style: TextStyle(fontSize: 16, color: Colors.grey[700]),
// //             textAlign: TextAlign.center,
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }

// import 'package:flutter/material.dart';
// import 'navbar.dart';
// import '../services/public_stories_service.dart';
// import 'story_display_page.dart';

// class HomePage extends StatefulWidget {
//   const HomePage({super.key});

//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   List<Map<String, dynamic>> _publicStories = [];
//   bool _loading = true;
//   String? _error;

//   @override
//   void initState() {
//     super.initState();
//     _loadPublicStories();
//   }

//   Future<void> _loadPublicStories() async {
//     setState(() {
//       _loading = true;
//       _error = null;
//     });
//     try {
//       final stories = await PublicStoriesService.fetchPublicStories();
//       setState(() => _publicStories = stories);
//     } catch (e) {
//       setState(() => _error = 'Failed to load stories');
//     } finally {
//       setState(() => _loading = false);
//     }
//   }

//   Widget _storyCard(Map<String, dynamic> s) {
//     final title = (s['title'] ?? 'Untitled').toString();
//     final videoUrl = (s['videoUrl'] ?? '').toString();
//     final coverUrl = (s['coverUrl'] ?? '').toString();

//     final cover = (coverUrl.isNotEmpty)
//         ? Image.network(coverUrl, fit: BoxFit.cover, width: double.infinity, height: double.infinity, errorBuilder: (_, __, ___) {
//             return Image.asset('assets/images/story_placeholder.png', fit: BoxFit.cover);
//           })
//         : Image.asset('assets/images/story_placeholder.png', fit: BoxFit.cover);

//     return GestureDetector(
//       onTap: () {
//         if (videoUrl.isNotEmpty) {
//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (_) => StoryDisplayPage(videoUrl: videoUrl)),
//           );
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No video available for this story')));
//         }
//       },
//       child: Card(
//         elevation: 4,
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

//   @override
//   Widget build(BuildContext context) {
//     final width = MediaQuery.of(context).size.width * 0.8;

//     return Scaffold(
//       appBar: Navbar(currentPage: 'home'),
//       body: Container(
//         width: double.infinity,
//         decoration: const BoxDecoration(
//           image: DecorationImage(
//             image: AssetImage('assets/images/home.png'),
//             fit: BoxFit.cover,
//           ),
//         ),
//         child: SafeArea(
//           child: Column(
//             children: [
//               const SizedBox(height: 24),
//               const Text(
//                 'Welcome to TinyTales',
//                 style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 8),
//               const Text(
//                 'Generate and enjoy some light hearted tales for little ones!',
//                 style: TextStyle(fontSize: 18, color: Colors.white70),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 20),

//               // Stories section - constrained to 80% width, scrollable if exceeds height
//               Expanded(
//                 child: Center(
//                   child: ConstrainedBox(
//                     constraints: BoxConstraints(maxWidth: width),
//                     child: Container(
//                       padding: const EdgeInsets.all(12),
//                       decoration: BoxDecoration(
//                         color: Colors.white.withOpacity(0.8),
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: _loading
//                           ? const Center(child: CircularProgressIndicator())
//                           : _error != null
//                               ? Center(child: Text(_error!))
//                               : _publicStories.isEmpty
//                                   ? RefreshIndicator(
//                                       onRefresh: _loadPublicStories,
//                                       child: ListView(
//                                         physics: const AlwaysScrollableScrollPhysics(),
//                                         children: const [
//                                           SizedBox(height: 80),
//                                           Center(child: Text('No public stories yet.')),
//                                         ],
//                                       ),
//                                     )
//                                   : RefreshIndicator(
//                                       onRefresh: _loadPublicStories,
//                                       child: GridView.builder(
//                                         padding: const EdgeInsets.all(12),
//                                         gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
//                                           maxCrossAxisExtent: 300,
//                                           childAspectRatio: 0.72,
//                                           crossAxisSpacing: 12,
//                                           mainAxisSpacing: 12,
//                                         ),
//                                         itemCount: _publicStories.length,
//                                         itemBuilder: (context, index) => _storyCard(_publicStories[index]),
//                                       ),
//                                     ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'navbar.dart';
import '../services/public_stories_service.dart';
import 'story_display_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> _publicStories = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPublicStories();
  }

  Future<void> _loadPublicStories() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final stories = await PublicStoriesService.fetchPublicStories();
      setState(() => _publicStories = stories);
    } catch (e) {
      setState(() => _error = 'Failed to load stories');
    } finally {
      setState(() => _loading = false);
    }
  }

  Widget _storyCard(Map<String, dynamic> s) {
    final title = (s['title'] ?? 'Untitled').toString();
    final videoUrl = (s['videoUrl'] ?? '').toString();
    final coverUrl = (s['coverUrl'] ?? '').toString();

    final cover = (coverUrl.isNotEmpty)
        ? Image.network(
            coverUrl,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const Center(child: CircularProgressIndicator());
            },
            errorBuilder: (context, error, stackTrace) =>
                Image.asset('assets/images/story3.jpeg', fit: BoxFit.cover),
          )
        : Image.asset('assets/images/story3.jpeg', fit: BoxFit.cover);

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
    // use same centered box style as my_stories (constrained width, translucent white)
    final boxMaxWidth = MediaQuery.of(context).size.width * 0.70;

    return Scaffold(
      appBar: Navbar(currentPage: 'home'),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/home.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              const Text(
                'Welcome to TinyTales',
                style: TextStyle(fontSize: 38, fontWeight: FontWeight.bold, color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Explore public stories below',
                style: TextStyle(fontSize: 26, color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // main centered box (same style as my_stories)
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: boxMaxWidth),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: _loading
                          ? const Center(child: CircularProgressIndicator())
                          : _error != null
                              ? Center(child: Text(_error!))
                              : _publicStories.isEmpty
                                  ? RefreshIndicator(
                                      onRefresh: _loadPublicStories,
                                      child: ListView(
                                        physics: const AlwaysScrollableScrollPhysics(),
                                        children: const [
                                          SizedBox(height: 80),
                                          Center(child: Text('No public stories yet.')),
                                        ],
                                      ),
                                    )
                                  : RefreshIndicator(
                                      onRefresh: _loadPublicStories,
                                      child: GridView.builder(
                                        padding: const EdgeInsets.all(12),
                                        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                                          maxCrossAxisExtent: 300,
                                          childAspectRatio: 1.15,
                                          crossAxisSpacing: 24,
                                          mainAxisSpacing: 24,
                                        ),
                                        itemCount: _publicStories.length,
                                        itemBuilder: (context, index) => _storyCard(_publicStories[index]),
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