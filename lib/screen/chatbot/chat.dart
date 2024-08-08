// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:rongo/model/message.dart';
import 'package:rongo/utils/theme/theme.dart';

/*
to-do:
1. write function to pull context from firebase
2. add image select options
*/

class ChatPage extends StatefulWidget {
  final Object? currentUser;
  const ChatPage({super.key, this.currentUser});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  get currentUser => widget.currentUser;
  final date = DateTime.now();
  final TextEditingController _controller = TextEditingController();
  final List<Message> _messages = [];
  final List<Map<String, dynamic>> _inventory = [];
  final model = GenerativeModel(
      model: 'gemini-1.5-flash', apiKey: dotenv.env['GEMINI_API_KEY']!);
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    pullContextFromFirebase();
  }

  Future<void> pullContextFromFirebase() async {
    final db = FirebaseFirestore.instance;
    final docRef = db.collection('fridges').doc(currentUser["fridgeId"]);
    try {
      final docSnapshot = await docRef.get();
      if (docSnapshot.exists) {
        final inventory = docSnapshot.data()!['inventory'] as List<dynamic>;
        final filteredInventory = inventory
            .map((item) => {
                  'name': item['name'],
                  'currentQuantity': item['currentQuantity'],
                  'expiryDate': item['expiryDate'],
                })
            .toList();
        for (final item in filteredInventory) {
          _inventory.add(item);
        }
      } else {
        print("document does not exist");
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  callGeminiModel() async {
    var context =
        "Your name is Rongie. You are a friendly and helpful assistant that is always ready to help users with their cooking needs"
        "Your friend, $currentUser is asking you a question about cooking and recipe, please provide a helpful answer in a short and conversational manner."
        "You are prohibited to reply in a markdown format, and you should not provide any code snippets or programming-related answers."
        "You may use any many emojis as you like to make the conversation more engaging and fun!"
        "Don't use any formatting as it is not supported in this chat interface. Plain text will do"
        "Avoid using any technical jargon or terms that are too complex for a general audience to understand."
        "Avoid using point-form or bullet points. Write in full sentences or short paragraphs."
        "If instruction requires steps, you may format it in a step-by-step manner using numbers, such as 1., 2., 3., etc."
        "The user currently have these items in their inventory $_inventory, so you can suggest recipes based on these items if they asked."
        "You do not have to introduce yourself unless explicitly stated by the user."
        "Answer the user's prompt in the most simple and concise way possible, minimal word count is preferred while maintaining personality"
        "Your timezone is in Malaysia, and today's date is $date";
    try {
      setState(() {
        _messages.add(Message(text: _controller.text, isUser: true));
        _isLoading = true;
      });

      final prompt = context + _controller.text.trim();
      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);

      setState(() {
        _messages.add(Message(text: response.text!, isUser: false));
        _isLoading = false;
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Image.asset("lib/images/rongie.png", height: 40, width: 40),
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.mainGreen,
              borderRadius: BorderRadius.circular(32),
            ),
            child: const Text(
              "I'm Rongie, your cooking assistant! Ask me anything!",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppTheme.backgroundWhite,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final Message message = _messages[index];
                return ListTile(
                  title: Align(
                    alignment: message.isUser
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: message.isUser
                            ? AppTheme.lightGrey
                            : AppTheme.lightOrange,
                        borderRadius: message.isUser
                            ? const BorderRadius.only(
                                topLeft: Radius.circular(15),
                                bottomLeft: Radius.circular(15),
                                bottomRight: Radius.circular(15),
                              )
                            : const BorderRadius.only(
                                topRight: Radius.circular(15),
                                bottomLeft: Radius.circular(15),
                                bottomRight: Radius.circular(15),
                              ),
                      ),
                      child: Text(
                        message.text,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                  color: AppTheme.backgroundWhite,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.30),
                      spreadRadius: 2,
                      blurRadius: 3,
                      offset: const Offset(0, 3),
                    ),
                  ]),
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(10),
                  border: InputBorder.none,
                  fillColor: AppTheme.mainGreen,
                  hintText: "Type a message",
                  prefixIcon: IconButton(
                    color: AppTheme.mainGreen,
                    icon: const Icon(Icons.image),
                    onPressed: () {},
                  ),
                  suffixIcon: _isLoading
                      ? const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: SizedBox(
                            height: 10,
                            width: 10,
                            child: Center(child: CircularProgressIndicator()),
                          ),
                        )
                      : IconButton(
                          color: AppTheme.mainGreen,
                          icon: const Icon(Icons.send),
                          onPressed: () {
                            if (_controller.text.isEmpty) return;
                            callGeminiModel();
                            _controller.clear();
                            FocusScope.of(context).unfocus();
                          },
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
