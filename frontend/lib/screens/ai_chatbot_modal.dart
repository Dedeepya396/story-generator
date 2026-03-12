import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/ai_chatbot_service.dart';
class AIChatbotModal extends StatefulWidget {
  final Function(String story) onInsertStory;

  const AIChatbotModal({super.key, required this.onInsertStory});

  @override
  State<AIChatbotModal> createState() => _AIChatbotModalState();
}

class _AIChatbotModalState extends State<AIChatbotModal> {

  final TextEditingController _controller = TextEditingController();

  List<Map<String, String>> messages = [
    {
      "role": "assistant",
      "text": "Hi! 👋\n\nI can help you generate a story.\n\nExample prompts:\n• Fantasy story\n• Kids story about animals\n• Horror story\n• Love story\n• Adventure in space"
    }
  ];

  bool loading = false;

Future<void> sendMessage() async {

  final text = _controller.text.trim();

  if (text.isEmpty) return;

  setState(() {
    messages.add({"role": "user", "text": text});
    loading = true;
  });

  _controller.clear();

  final story = await AIStoryService.generateStory(text);

  if (story != null) {

    setState(() {
      messages.add({
        "role": "assistant",
        "text": story
      });
      loading = false;
    });

  } else {

    setState(() {
      loading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Failed to generate story")),
    );
  }
}
  Widget messageBubble(Map<String,String> msg) {

    bool isUser = msg["role"] == "user";

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,

      child: Container(
        margin: const EdgeInsets.symmetric(vertical:6),
        padding: const EdgeInsets.all(14),

        constraints: const BoxConstraints(maxWidth: 300),

        decoration: BoxDecoration(
          color: isUser ? Colors.blue : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(14),
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Text(
              msg["text"]!,
              style: TextStyle(
                color: isUser ? Colors.white : Colors.black,
                fontSize: 14,
              ),
            ),

            if(!isUser)
              Row(
                children: [

                  TextButton.icon(
                    icon: const Icon(Icons.content_copy, size:16),
                    label: const Text("Copy"),
                    onPressed: (){
                      Clipboard.setData(
                        ClipboardData(text: msg["text"]!)
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Story copied")),
                      );
                    },
                  ),

                  TextButton.icon(
                    icon: const Icon(Icons.input, size:16),
                    label: const Text("Insert"),
                    onPressed: (){
                      widget.onInsertStory(msg["text"]!);
                      Navigator.pop(context);
                    },
                  )

                ],
              )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,

      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),

      child: Column(
        children: [

          const SizedBox(height: 12),

          Container(
            width: 60,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          const SizedBox(height: 10),

          const Text(
            "AI Story Assistant ✨",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold
            ),
          ),

          const Divider(),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context,index){

                return messageBubble(messages[index]);

              },
            ),
          ),

          if(loading)
            const Padding(
              padding: EdgeInsets.all(10),
              child: CircularProgressIndicator(),
            ),

          Padding(
            padding: const EdgeInsets.all(12),

            child: Row(
              children: [

                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Ask AI for a story...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width:8),

                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blue),
                  onPressed: sendMessage,
                )

              ],
            ),
          )

        ],
      ),
    );
  }
}