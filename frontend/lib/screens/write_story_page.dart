import 'package:flutter/material.dart';
import 'story_display_page.dart';
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

  @override
  void dispose() {
    _storyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Write Your Story'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Selected Characters',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            // ===== Selected Characters Preview =====
            SizedBox(
              height: 90,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: widget.selectedCharacters.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final character = widget.selectedCharacters[index];
                  return Column(
                    mainAxisSize: MainAxisSize.min, // 👈 important
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

            // SizedBox(
            //   height: 80,
            //   child: ListView.separated(
            //     scrollDirection: Axis.horizontal,
            //     itemCount: widget.selectedCharacters.length,
            //     separatorBuilder: (_, __) => const SizedBox(width: 12),
            //     itemBuilder: (context, index) {
            //       final character = widget.selectedCharacters[index];
            //       return Column(
            //         children: [
            //           ClipRRect(
            //             borderRadius: BorderRadius.circular(10),
            //             child: Image.asset(
            //               character['image']!,
            //               width: 60,
            //               height: 60,
            //               fit: BoxFit.cover,
            //             ),
            //           ),
            //           const SizedBox(height: 4),
            //           Text(
            //             character['name']!,
            //             style: const TextStyle(fontSize: 12),
            //           ),
            //         ],
            //       );
            //     },
            //   ),
            // ),

            const SizedBox(height: 20),

            const Text(
              'Your Story',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            // ===== Story Text Box =====
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
                onPressed: () {
                  // if (_storyController.text.trim().isEmpty) {
                  //   ScaffoldMessenger.of(context).showSnackBar(
                  //     const SnackBar(
                  //       content: Text('Story cannot be empty'),
                  //     ),
                  //   );
                  //   return;
                  // }

                  // // 🔹 For now just show success
                  // ScaffoldMessenger.of(context).showSnackBar(
                  //   const SnackBar(
                  //     content: Text('Story submitted successfully!'),
                  //   ),
                  // );

                  // Navigator.pop(context);
                  // final storyText = _controller.text; // or however you get the story
                  final storyText = _storyController.text;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StoryDisplayPage(storyText: storyText),
                    ),
                  );
                },
                child: const Text(
                  'Submit Story',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
