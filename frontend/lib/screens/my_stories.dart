import 'package:flutter/material.dart';
import 'story_display_page.dart';
import 'navbar.dart';
import '../services/auth_service.dart';
import '../services/my_stories_service.dart' as MyStoriesApi;
import 'dart:html' as html;
import 'package:http/http.dart' as http;

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


  List<String> _availableGenres = [];
  Set<String> _selectedGenres = {};

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
      // setState(() {
      //   _stories = stories;
      // });
      final genres = <String>{};
      for (final s in stories) {
        final g = (s['genre'] ?? 'General').toString().trim();
        if (g.isNotEmpty) genres.add(g);
      }
      setState(() {
        _stories = stories;
        _availableGenres = genres.toList()..sort();
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

  Future<void> _deleteStory(String storyId, String storyTitle) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Story'),
        content: Text('Are you sure you want to permanently delete "$storyTitle"?\n\nThis will delete the video from Cloudinary as well.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Deleting story...'), duration: Duration(seconds: 1)),
    );

    try {
      final result = await MyStoriesApi.StoryService.deleteStory(storyId);
      if (!mounted) return;

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Story deleted successfully'), duration: Duration(seconds: 2)),
        );
        await _loadStories();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Failed to delete: ${result['message'] ?? 'Unknown error'}')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error: ${e.toString()}')),
      );
    }
  }

  Future<void> _downloadVideo(String videoUrl, String videoTitle) async {
    try {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⏳ Downloading... Please wait'), duration: Duration(seconds: 30)),
      );

      await _downloadVideoWebBlob(videoUrl, videoTitle);
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ Downloaded: $videoTitle.mp4'), duration: const Duration(seconds: 3)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Download failed: ${e.toString()}')),
      );
    }
  }

  Future<void> _downloadVideoWebBlob(String videoUrl, String videoTitle) async {
    try {
      print('🔽 Starting download from: $videoUrl');
      
      final response = await http.get(Uri.parse(videoUrl));
      if (response.statusCode != 200) {
        throw Exception('Failed to download video: ${response.statusCode}');
      }

      final blob = html.Blob([response.bodyBytes], 'video/mp4');
      final blobUrl = html.Url.createObjectUrl(blob);
      
      print('✅ Blob created, URL: $blobUrl');
      
      final anchor = html.AnchorElement(href: blobUrl)
        ..setAttribute('download', '$videoTitle.mp4')
        ..style.display = 'none';
      
      html.document.body!.append(anchor);
      anchor.click();
      
      await Future.delayed(const Duration(milliseconds: 100));
      anchor.remove();
      html.Url.revokeObjectUrl(blobUrl);
      
      print('✅ Download completed for: $videoTitle');
    } catch (e) {
      print('❌ Error downloading video: $e');
      rethrow;
    }
  }

  Widget _buildCard(Map<String, dynamic> s) {
    final title = (s['title'] ?? 'Untitled').toString();
    final videoUrl = (s['videoUrl'] ?? '').toString();
    final coverUrl = (s['coverUrl'] ?? '').toString();
    final storyId = (s['id'] ?? s['_id'] ?? '').toString();
    final storyText = (s['description'] ?? '').toString();

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
            MaterialPageRoute(
              builder: (_) => StoryDisplayPage(
                    videoUrl: videoUrl,
                    storyText: storyText.isNotEmpty ? storyText : null,
                    storyTitle: title,
                    subtitleUrl: s['subtitleUrl'] ?? s['subtitle_url'],
                  ),
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
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    child: cover,
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'download' && videoUrl.isNotEmpty) {
                          _downloadVideo(videoUrl, title);
                        } else if (value == 'delete') {
                          _deleteStory(storyId, title);
                        }
                      },
                      itemBuilder: (BuildContext context) => [
                        PopupMenuItem<String>(
                          value: 'download',
                          enabled: videoUrl.isNotEmpty,
                          child: const Row(
                            children: [
                              Icon(Icons.download, size: 18),
                              SizedBox(width: 10),
                              Text('Download'),
                            ],
                          ),
                        ),
                        PopupMenuItem<String>(
                          value: 'delete',
                          child: const Row(
                            children: [
                              Icon(Icons.delete, size: 18, color: Colors.red),
                              SizedBox(width: 10),
                              Text('Delete', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                      icon: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(6),
                          child: Icon(Icons.more_vert, color: Colors.black87, size: 20),
                        ),
                      ),
                    ),
                  ),
                ],
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
    // final filtered = _stories.where((s) {
    //   final t = (s['title'] ?? '').toString().toLowerCase();
    //   return t.contains(searchQuery.toLowerCase());
    // }).toList();
    // final q = searchQuery.trim().toLowerCase();
    // // support searching by title OR genre. Also allow "genre:xxx" prefix for explicit genre search.
    // final filtered = q.isEmpty
    //     ? _stories
    //     : _stories.where((s) {
    //         final title = (s['title'] ?? '').toString().toLowerCase();
    //         final genre = (s['genre'] ?? '').toString().toLowerCase();

    //         if (q.startsWith('genre:')) {
    //           final genQuery = q.substring('genre:'.length).trim();
    //           return genre.contains(genQuery);
    //         }

    //         return title.contains(q) || genre.contains(q);
    //       }).toList();

    final q = searchQuery.trim().toLowerCase();
    // filter by search query (title OR genre) and by selected genres (multi-select)
    final filtered = _stories.where((s) {
      final title = (s['title'] ?? '').toString().toLowerCase();
      final genre = (s['genre'] ?? 'general').toString().toLowerCase();

      // if user explicitly used "genre:xxx" in search, honor it
      if (q.startsWith('genre:')) {
        final genQuery = q.substring('genre:'.length).trim();
        if (genQuery.isNotEmpty && !genre.contains(genQuery)) return false;
      } else if (q.isNotEmpty) {
        if (!title.contains(q) && !genre.contains(q)) return false;
      }

      // if any genres are selected, only include stories whose genre is in the selection
      if (_selectedGenres.isNotEmpty) {
        return _selectedGenres.map((e) => e.toLowerCase()).contains(genre);
      }

      return true;
    }).toList();

    return Scaffold(
      extendBodyBehindAppBar: true,
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
                          hintText: 'Search stories by title or genre...',
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
                            // Genre filter chips (multi-select)
              if (_availableGenres.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.9),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: _availableGenres.map((g) {
                        final selected = _selectedGenres.contains(g);
                        return FilterChip(
                          label: Text(g),
                          selected: selected,
                          onSelected: (v) {
                            setState(() {
                              if (v) {
                                _selectedGenres.add(g);
                              } else {
                                _selectedGenres.remove(g);
                              }
                            });
                          },
                          selectedColor: Colors.blueAccent.withOpacity(0.7),
                          checkmarkColor: Colors.white,
                        );
                      }).toList(),
                    ),
                  ),
                ),

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