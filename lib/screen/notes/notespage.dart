import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:rongo/firestore.dart';
import 'package:rongo/utils/text_formatter.dart';
import 'package:rongo/utils/theme/theme.dart';
import 'package:rongo/widgets/button.dart';
import 'package:intl/intl.dart';
import 'package:rongo/widgets/containers.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:collection/collection.dart';

import '../../utils/utils.dart';

class NotesPage extends StatefulWidget {
  final Map<String, dynamic>? currentUser;

  const NotesPage({Key? key, this.currentUser}) : super(key: key);

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final FirestoreService firestoreService = FirestoreService();

  // Controllers
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _listController = TextEditingController();
  final SpeechToText _speechController = SpeechToText();
  bool _speechAvailable = false;
  bool _doneListening = false;
  String _speechText = 'Listening...';
  bool _isLoading = false;
  late StateSetter _setState;
  late StateSetter _setListeningState;

  // Functions
  void openNoteBox() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Label
              Text('Note:', style: AppTheme.greenAppBarText),
              SizedBox(height: 8),
              // TextField
              TextField(
                controller: _messageController,
                maxLines: null,
                minLines: 5,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                decoration: InputDecoration(
                  hintText: 'Enter your note here...',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              firestoreService.addNote(
                _messageController.text,
                widget.currentUser?['uid'],
                widget.currentUser?['firstName'],
              );

              _messageController.clear();
              Navigator.pop(context);
            },
            child: Text("Save"),
          ),
        ],
      ),
    );
  }

  void openGroceriesBox() {
    _listController.text = "1. ";
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
        _setState = setState;
        return AlertDialog(
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Label
                Text('Grocery items:', style: AppTheme.greenAppBarText),
                // TextField
                Stack(children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: TextField(
                      inputFormatters: [CustomTextEditingFormatter()],
                      controller: _listController,
                      maxLines: null,
                      minLines: 5,
                      keyboardType: TextInputType.multiline,
                      textInputAction: TextInputAction.newline,
                      decoration: InputDecoration(
                        hintText: 'Enter your item here...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  Positioned(
                      right: 0,
                      bottom: 0,
                      child: _isLoading
                          ? Padding(
                              padding: const EdgeInsets.all(13.0),
                              child: SizedBox(
                                  height: 15,
                                  width: 15,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  )),
                            )
                          : IconButton(
                              onPressed: () {
                                if (_speechAvailable) {
                                  _startListening();
                                } else {
                                  _askSpeechPermission();
                                }
                              },
                              icon: Icon(Icons.mic))),
                ]),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _listController.text = "";
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                firestoreService.addNote(
                  _listController.text,
                  widget.currentUser?['uid'],
                  widget.currentUser?['firstName'],
                );

                _messageController.clear();
                Navigator.pop(context);
              },
              child: Text("Save"),
            ),
          ],
        );
      }),
    );
  }

  Future<void> _askSpeechPermission() async {
    if (!_speechAvailable) {
      _speechAvailable = await _speechController.initialize(
        onStatus: (val) => {
          if (val == "done")
            {
              _setListeningState(() {
                _doneListening = true;
              })
            }
        },
        onError: (val) => print('onError: $val'),
      );
    }
  }

  void _startListening() {
    _doneListening = false;
    if (_speechAvailable) {
      _speechController.listen(
        onResult: (val) {
          _setListeningState(() {
            _speechText = val.recognizedWords;
          });
        },
      );
    }
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            _setListeningState = setState;
            return AlertDialog(
              content: Text(_speechText),
              actions: [
                if (_doneListening) ...[
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _speechController.stop();
                        Navigator.pop(context);
                        _speechText = 'Listening...';
                      });
                    },
                    child: Text("Cancel"),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _speechController.stop();
                        Navigator.pop(context);
                        _compileList();
                        _speechText = 'Listening...';
                      });
                    },
                    child: Text("Done"),
                  ),
                ],
              ],
            );
          },
        );
      },
    );
  }

  Future<String?> _compileList() async {
    try {
      _setState(() {
        _isLoading = true;
      });

      final prompt =
          'Given this prompt: $_speechText, compile a groceries item list with quantities in numeric form. Extract both the item and numeric quantity from the text. The response should be in JSON format like this: { "response": [{"item": "mangoes", "quantity": 3}] }. Do not include markdown formatting.';

      var response = await model.generateContent([Content.text(prompt)]);
      print(
          "=========================================================================================");
      print(response.text);
      print(
          "=========================================================================================");
      var result =
          response.text!.replaceAll("```json", "").replaceAll("```", "");
      Map<String, dynamic> map = json.decode(result);
      List<dynamic> items = map["response"];

      // Format items with numbering
      String formattedList = items.asMap().entries.map((entry) {
        int index = entry.key + 1;
        var item = entry.value;
        return "$index. ${item['quantity']} ${item['item']}";
      }).join("\n");

      setState(() {
        _listController.text = formattedList;
        _isLoading = false;
      });
    } catch (exc) {
      print(exc);
      _setState(() {
        _isLoading = false;
      });
    }
    return null;
  }

  String formatTimestamp(Timestamp timestamp) {
    DateTime date = timestamp.toDate();
    return DateFormat('yyyy-MM-dd HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Stack(
        children: [
          Column(
            children: [
              const SizedBox(height: 20),

              // Description box
              Center(
                child: Container(
                  height: 100,
                  width: screenWidth * 0.8,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: AppTheme.bottomLightShadow,
                  ),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                        child: SquareContainer(
                          backgroundColor: Colors.transparent,
                          roundedCorner: 0,
                          height: 60,
                          width: 60,
                          child: Image.asset('lib/images/notepad.png'),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          "Scared of forgetting the shopping list when you're out? Put in your reminders here!",
                          style: TextStyle(height: 1.2),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // StreamBuilder to display notes
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: firestoreService.getNotesStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(child: Text('No notes available.'));
                    }

                    final notes = snapshot.data!.docs;

                    return ListView.builder(
                      itemCount: notes.length,
                      itemBuilder: (context, index) {
                        final note = notes[index];
                        final noteMessage = note['message'];
                        final firstName = note['firstName'];
                        final Timestamp timestamp = note['datePosted'];
                        final String datePosted = formatTimestamp(timestamp);
                        final uid = note['uid'];
                        final notesId = note['notesId'];
                        final bool isCompleted = note['isCompleted'];

                        final backgroundColor = isCompleted
                            ? Colors.grey[300]
                            : (uid == widget.currentUser?['uid']
                                ? Colors.white
                                : Colors.yellow[100]);

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 35, vertical: 10.0),
                          child: Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: backgroundColor,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: AppTheme.bottomLightShadow,
                            ),
                            child: Row(
                              children: [
                                // Note details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(noteMessage,
                                          style: TextStyle(fontSize: 16)),
                                      SizedBox(height: 8),
                                      Text(firstName,
                                          style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold)),
                                      SizedBox(height: 4),
                                      Text(datePosted,
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Color.fromARGB(
                                                  255, 159, 159, 159))),
                                    ],
                                  ),
                                ),
                                // Actions
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.check_rounded,
                                          color: isCompleted
                                              ? Color.fromARGB(
                                                  255, 101, 101, 101)
                                              : AppTheme.mainGreen),
                                      onPressed: isCompleted
                                          ? null
                                          : () async {
                                              await firestoreService
                                                  .completeNote(notesId);
                                            },
                                    ),
                                    IconButton(
                                      icon:
                                          Icon(Icons.delete, color: Colors.red),
                                      onPressed: () async {
                                        await firestoreService
                                            .deleteNote(notesId);
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 60),
            ],
          ),
          Positioned(
            right: screenHeight * 0.03,
            bottom: screenHeight * 0.21,
            child: CustomizedButton(
              isRoundButton: true,
              color: AppTheme.mainGreen,
              icon: Icons.mic_none_rounded,
              func: openGroceriesBox,
            ),
          ),
          Positioned(
            right: screenHeight * 0.03,
            bottom: screenHeight * 0.12,
            child: RoundButton(
              color: Colors.white,
              iconColor: AppTheme.mainGreen,
              icon: Icons.add_rounded,
              func: openNoteBox,
            ),
          ),
        ],
      ),
    );
  }
}
