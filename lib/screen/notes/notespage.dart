import 'package:flutter/material.dart';
import 'package:rongo/utils/theme/theme.dart';
import 'package:rongo/widgets/containers.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
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
    );
  }
}
