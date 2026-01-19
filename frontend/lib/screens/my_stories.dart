import 'package:flutter/material.dart';

class MyStoriesPage extends StatelessWidget {
  const MyStoriesPage({super.key});

  // Hardcoded stories
  final List<Map<String, String>> stories = const [
    {
      'title': 'Lion in the Jungle',
      'image': 'assets/images/story3.jpeg',
    },
    {
      'title': 'My Quiet Imagination',
      'image': 'assets/images/story1.jpeg',
    },
    {
      'title': 'Bug Hunt',
      'image': 'assets/images/story2.jpeg',
    },
    {
      'title': 'Animal Friends',
      'image': 'assets/images/story4.jpeg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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

              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(16),
                  ),

                child: SingleChildScrollView(
                    child: 
                    // Wrap(
                    //     spacing: 16, // Horizontal spacing between items
                    //     runSpacing: 20, // Vertical spacing between rows
                    //     alignment: WrapAlignment.spaceEvenly, // Centers the items
                    //     children: stories.map((story) {
                    //     return _SmallStoryBox(
                    //         title: story['title']!,
                    //         imagePath: story['image']!,
                    //     );
                    //     }).toList(),
                    // ),
                    Wrap(
                        spacing: 24,
                        runSpacing: 24,
                        alignment: WrapAlignment.center,
                        children: stories.map((story) {
                            return _SmallStoryBox(
                            title: story['title']!,
                            imagePath: story['image']!,
                            );
                        }).toList(),
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
class _SmallStoryBox extends StatelessWidget {
  final String title;
  final String imagePath;

  const _SmallStoryBox({
    required this.title,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // 🔑 card wraps content
        children: [
          // Story cover (MAIN focus)
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(12),
            ),
            child: Image.asset(
              imagePath,
              width: 140,          // 👈 book width
              height: 200,         // 👈 book height (bigger image)
              fit: BoxFit.cover,   // cover is OK now (no empty space)
              filterQuality: FilterQuality.high,
            ),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.all(8),
            child: SizedBox(
              width: 140, // same as image width
              child: Text(
                title,
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
