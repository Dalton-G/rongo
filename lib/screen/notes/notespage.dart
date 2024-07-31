import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:rongo/firestore.dart';
import 'package:rongo/utils/theme/theme.dart';
import 'package:rongo/widgets/button.dart';
import 'package:rongo/widgets/containers.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final FirestoreService firestoreService = FirestoreService();

  //controllers
  final TextEditingController _messageController = TextEditingController();

  //functions
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
              Navigator.of(context).pop;
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              //add the note using function
              firestoreService.addNote(_messageController.text);

              //clear the controller
              _messageController.clear();

              //close the box
              Navigator.pop(context);
            },
            child: Text("Save"),
          ),
        ],
      ),
    );
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

              //description box
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
