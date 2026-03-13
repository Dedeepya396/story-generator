import 'package:flutter/material.dart';
import '../services/public_stories_service.dart';
import 'story_display_page.dart';

class AllStoriesPage extends StatefulWidget {
  const AllStoriesPage({super.key});

  @override
  State<AllStoriesPage> createState() => _AllStoriesPageState();
}

class _AllStoriesPageState extends State<AllStoriesPage> {
  List<Map<String, dynamic>> stories = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadStories();
  }

  Future<void> loadStories() async {
    final s = await PublicStoriesService.fetchPublicStories();
    setState(() {
      stories = s;
      loading = false;
    });
  }

  Widget storyCard(Map<String, dynamic> s) {
    final title = (s['title'] ?? 'Untitled').toString();
    final videoUrl = (s['videoUrl'] ?? '').toString();
    final coverUrl = (s['coverUrl'] ?? '').toString();
    final storyText = (s['description'] ?? '').toString();

    return GestureDetector(
      onTap: () {
        if (videoUrl.isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => StoryDisplayPage(
                videoUrl: videoUrl,
                storyText: storyText.isNotEmpty ? storyText : null,
                storyTitle: title,
                subtitleUrl: s['subtitleUrl'] ?? s['subtitle_url'],
              ),
            ),
          );
        }
      },
      child: Card(
        elevation: 3,
        child: Column(
          children: [
            Expanded(
              child: coverUrl.isNotEmpty
                  ? Image.network(coverUrl, fit: BoxFit.cover)
                  : Image.asset('assets/images/story3.jpeg', fit: BoxFit.cover),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                title,
                maxLines: 2,
                textAlign: TextAlign.center,
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(title: const Text("All Stories")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 300,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                childAspectRatio: 1.15,
              ),
              itemCount: stories.length,
              itemBuilder: (context, index) => storyCard(stories[index]),
            ),
    );
  }
}