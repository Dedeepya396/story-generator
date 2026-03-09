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