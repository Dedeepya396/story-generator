import 'package:flutter/material.dart';
import 'story_details_page.dart';

class MyStoriesPage extends StatefulWidget {
  const MyStoriesPage({super.key});

  @override
  State<MyStoriesPage> createState() => _MyStoriesPageState();
}

class _MyStoriesPageState extends State<MyStoriesPage> with RouteAware {
  final List<Map<String, String>> stories = const [
    {'title': 'Lion in the Jungle', 'image': 'assets/images/story3.jpeg'},
    {'title': 'My Quiet Imagination', 'image': 'assets/images/story1.jpeg'},
    {'title': 'Bug Hunt', 'image': 'assets/images/story2.jpeg'},
    {'title': 'Animal Friends', 'image': 'assets/images/story4.jpeg'},
  ];

  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize the controller with empty text
    _searchController.text = '';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Method to clear search when returning from another page
  void _clearSearch() {
    setState(() {
      searchQuery = '';
      _searchController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredStories = stories.where((story) {
      return story['title']!
          .toLowerCase()
          .contains(searchQuery.toLowerCase());
    }).toList();

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

              // ===================== CENTERED CONTENT =====================
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.70,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // ===================== SEARCH BAR =====================
                        Container(
                          margin: const EdgeInsets.only(bottom: 72), // 1 inch gap (72 logical pixels ≈ 1 inch)
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Search stories...',
                              prefixIcon: const Icon(Icons.search),
                              suffixIcon: searchQuery.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear),
                                      onPressed: _clearSearch,
                                    )
                                  : null,
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.8),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            onChanged: (value) {
                              setState(() {
                                searchQuery = value;
                              });
                            },
                          ),
                        ),

                        // ===================== STORIES CONTAINER =====================
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: SingleChildScrollView(
                              child: Wrap(
                                spacing: 24,
                                runSpacing: 24,
                                alignment: WrapAlignment.center,
                                children: filteredStories.map((story) {
                                  return GestureDetector(
                                    onTap: () async {
                                      // Navigate to the detail page
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => StoryDetailPage(
                                            title: story['title']!,
                                            imagePath: story['image']!,
                                          ),
                                        ),
                                      );
                                      
                                      // Clear search when returning from detail page
                                      _clearSearch();
                                    },
                                    child: _SmallStoryBox(
                                      title: story['title']!,
                                      imagePath: story['image']!,
                                    ),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(12),
            ),
            child: Image.asset(
              imagePath,
              width: 250,
              height: 300,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.high,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: SizedBox(
              width: 250,
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