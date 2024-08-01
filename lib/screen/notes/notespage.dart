import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rongo/firestore.dart';
import 'package:rongo/utils/theme/theme.dart';
import 'package:rongo/widgets/button.dart';
import 'package:intl/intl.dart';
import 'package:rongo/widgets/containers.dart';

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

  // Functions
  void openNoteBox() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: TextField(
          controller: _messageController,
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
              // Add the note using function
              firestoreService.addNote(
                _messageController.text,
                widget.currentUser?['uid'],
                widget.currentUser?['firstName'],
              );

              // Clear the controller
              _messageController.clear();

              // Close the box
              Navigator.pop(context);
            },
            child: Text("Save"),
          ),
        ],
      ),
    );
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

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 35, vertical: 10.0),
                          child: Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: AppTheme.bottomLightShadow,
                            ),
                            child: Column(
                              children: [
                                Text(noteMessage),
                                Text(firstName),
                                Text(datePosted),
                                Text(uid),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
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
