import 'package:flutter/material.dart';
import 'write_story_page.dart';

class CharacterSelectionPage extends StatefulWidget {
  const CharacterSelectionPage({super.key});

  @override
  State<CharacterSelectionPage> createState() =>
      _CharacterSelectionPageState();
}

class _CharacterSelectionPageState extends State<CharacterSelectionPage> {
  // 🔹 Hardcoded characters
  final List<Map<String, String>> characters = [
    {
      'name': 'Lion',
      'image': 'assets/images/characters/lion.png',
    },
    {
      'name': 'Rabbit',
      'image': 'assets/images/characters/rabbit.png',
    },
    {
      'name': 'Elephant',
      'image': 'assets/images/characters/elephant.png',
    },
    {
      'name': 'Turtle',
      'image': 'assets/images/characters/tortoise.png',
    },
    {
      'name': 'Fox',
      'image': 'assets/images/characters/fox.png',
    },
  ];

  final Set<int> selectedIndexes = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Characters'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'Choose characters for your story',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // ===== Character Grid =====
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1,
                ),
                itemCount: characters.length,
                itemBuilder: (context, index) {
                  final character = characters[index];
                  final isSelected = selectedIndexes.contains(index);

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          selectedIndexes.remove(index);
                        } else {
                          selectedIndexes.add(index);
                        }
                      });
                    },
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: isSelected ? 0.55 : 1.0, // 👈 fade effect
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? const Color.fromARGB(255, 118, 118, 117)
                                : const Color.fromARGB(255, 187, 185, 185),
                            width: 3,
                          ),
                        ),
                        child: Column(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(14),
                                ),
                                child: Image.asset(
                                  character['image']!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Text(
                                character['name']!,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // ===== Next Button =====
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  if (selectedIndexes.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please select at least one character'),
                      ),
                    );
                    return;
                  }

                  final selectedCharacters = selectedIndexes
                      .map((i) => characters[i])
                      .toList();

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => WriteStoryPage(
                        selectedCharacters: selectedCharacters,
                      ),
                    ),
                  );
                },
                child: const Text(
                  'Next',
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
