import 'package:flutter/material.dart';
import 'navbar.dart';
import '../services/public_stories_service.dart';
import 'story_display_page.dart';
import 'all_stories_page.dart';

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
      setState(() {
        _publicStories = stories;
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

  Widget _storyCard(Map<String, dynamic> s) {
    final title = (s['title'] ?? 'Untitled').toString();
    final videoUrl = (s['videoUrl'] ?? '').toString();
    final coverUrl = (s['coverUrl'] ?? '').toString();

    final cover = coverUrl.isNotEmpty
        ? Image.network(
            coverUrl,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
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
            MaterialPageRoute(
              builder: (_) => StoryDisplayPage(videoUrl: videoUrl),
            ),
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
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
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
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

@override
Widget build(BuildContext context) {
  final boxMaxWidth = MediaQuery.of(context).size.width * 0.70;
  final previewStories = _publicStories.take(4).toList();

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
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 120),

              const Text(
                'Welcome to TinyTales',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 10),

              const Text(
                'Explore public stories below',
                style: TextStyle(fontSize: 24, color: Colors.white70),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 30),

              Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: boxMaxWidth),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: _loading
                        ? const Center(child: CircularProgressIndicator())
                        : _error != null
                            ? Center(child: Text(_error!))
                            : Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [

                                  /// STORIES GRID
                                  GridView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    padding: const EdgeInsets.all(12),
                                    gridDelegate:
                                        const SliverGridDelegateWithMaxCrossAxisExtent(
                                      maxCrossAxisExtent: 300,
                                      childAspectRatio: 1.15,
                                      crossAxisSpacing: 24,
                                      mainAxisSpacing: 24,
                                    ),
                                    itemCount: previewStories.length,
                                    itemBuilder: (context, index) =>
                                        _storyCard(previewStories[index]),
                                  ),

                                  const SizedBox(height: 10),

                                  /// SEE MORE
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const AllStoriesPage(),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 30, vertical: 12),
                                    ),
                                    child: const Text(
                                      "See More",
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ],
                              ),
                  ),
                ),
              ),

              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
    ),
  );
}
}