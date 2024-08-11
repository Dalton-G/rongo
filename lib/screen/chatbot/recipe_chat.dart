// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:provider/provider.dart';
import 'package:rongo/model/message.dart';
import 'package:rongo/model/recipe.dart';
import 'package:rongo/provider/recipe_chat_provider.dart';
import 'package:rongo/utils/theme/theme.dart';
import 'package:speech_to_text/speech_to_text.dart';

class RecipeChatPage extends StatefulWidget {
  final Object? currentUser;
  final Recipe recipe;
  const RecipeChatPage({super.key, this.currentUser, required this.recipe});

  @override
  State<RecipeChatPage> createState() => _RecipeChatPageState();
}

class _RecipeChatPageState extends State<RecipeChatPage> {
  get currentUser => widget.currentUser;
  get recipe => widget.recipe;
  final date = DateTime.now();
  final speech = SpeechToText();
  final TextEditingController _controller = TextEditingController();
  final model = GenerativeModel(
      model: 'gemini-1.5-flash', apiKey: dotenv.env['GEMINI_API_KEY']!);
  bool _isLoading = false;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1), () {
      initialResponse(recipe, context);
    });
  }

  Future<void> initialResponse(Recipe recipe, BuildContext context) async {
    String foodName = recipe.name;

    final chatProvider =
        Provider.of<RecipeChatProvider>(context, listen: false);
    final messages = chatProvider.messages;

    final messageExists = messages.any((message) =>
        message.text ==
        "I see that you're currently cooking $foodName! Do you have any questions regarding that? Or are you seeking assistance with something else?");
    if (!messageExists) {
      chatProvider.addMessage(Message(
          text:
              "I see that you're currently cooking $foodName! Do you have any questions regarding that? Or are you seeking assistance with something else?",
          isUser: false));
    }
  }

  Future<void> _startListening() async {
    await speech.initialize();
    speech.listen(
      onResult: (result) {
        if (result.recognizedWords.isNotEmpty) {
          _controller.text = result.recognizedWords;
        }
      },
    );
    setState(() {
      _isListening = true;
    });
  }

  callGeminiModel(BuildContext buildContext) async {
    String context = """
        Your name is Rongie. You are a friendly and helpful assistant that is always ready to help users with their cooking needs
        Your friend, $currentUser is asking you a question about a recipe, please provide a helpful answer in a short and conversational manner.
        Full Context of the recipe:
        * name : ${recipe.name},
        * description: ${recipe.description},
        * cookingTime: ${recipe.cookingTime},
        * tags: ${recipe.tags},
        * ingredients: ${recipe.ingredients},
        * steps: ${recipe.instructions}
        * nutritions: ${recipe.nutritions},
        * allergens: ${recipe.allergens},
        You are prohibited to reply in a markdown format, and you should not provide any code snippets or programming-related answers.
        You may use any many emojis as you like to make the conversation more engaging and fun!
        Don't use any formatting as it is not supported in this chat interface. Plain text will do
        Avoid using any technical jargon or terms that are too complex for a general audience to understand.
        Avoid using point-form or bullet points. Write in full sentences or short paragraphs.
        If instruction requires steps, you may format it in a step-by-step manner using numbers, such as 1., 2., 3., etc.
        You do not have to introduce yourself unless explicitly stated by the user."
        Answer the user's prompt in the most simple and concise way possible, minimal word count is preferred while maintaining personality.
        Your timezone is in Malaysia, and today's date is $date.
        """;
    try {
      setState(() {
        Provider.of<RecipeChatProvider>(buildContext, listen: false)
            .addMessage(Message(text: _controller.text, isUser: true));
        _isLoading = true;
      });

      final prompt = context + _controller.text.trim();
      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);

      setState(() {
        Provider.of<RecipeChatProvider>(buildContext, listen: false)
            .addMessage(Message(text: response.text!, isUser: false));
        _isLoading = false;
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final recipeChatProvider = Provider.of<RecipeChatProvider>(context);

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
              itemCount: recipeChatProvider.messages.length,
              itemBuilder: (context, index) {
                final Message message = recipeChatProvider.messages[index];
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
                    icon: const Icon(Icons.mic),
                    onPressed: () async {
                      if (!_isListening) {
                        await _startListening();
                      } else {
                        await speech.stop();
                      }
                      setState(() {
                        _isListening = !_isListening;
                      });
                    },
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
                            callGeminiModel(context);
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
