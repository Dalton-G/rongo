import 'package:flutter/material.dart';

void dialogPopUp(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            AlertDialog(
              title: Text('Confirm'),
              content: Text('Are you sure you want to proceed?'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: Text('Yes'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: Text('No'),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}

class FridgePage extends StatefulWidget {
  const FridgePage({super.key});

  @override
  State<FridgePage> createState() => _FridgePageState();
}

class _FridgePageState extends State<FridgePage> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          //fridge background
          Positioned.fill(
            child: Image.asset(
              'lib/images/fridgebackground.png',
              fit: BoxFit.cover,
            ),
          ),

          //add icons
          Positioned(
            left: screenWidth * 0.4,
            top: screenHeight * 0.22,
            child: GestureDetector(
              onTap: () => dialogPopUp(context),
              child: Container(
                height: 60,
                width: 100,
                child: Image.asset('lib/images/addicon.png'),
              ),
            ),
          ),

          Positioned(
            left: screenWidth * 0.31,
            top: screenHeight * 0.42,
            child: Transform.rotate(
              angle: -0.3,
              child: GestureDetector(
                onTap: () => dialogPopUp(context),
                child: Container(
                  height: 60,
                  width: 100,
                  child: Image.asset('lib/images/addicon.png'),
                ),
              ),
            ),
          ),

          Positioned(
            left: screenWidth * 0.48,
            top: screenHeight * 0.53,
            child: Transform.rotate(
              angle: 0.6,
              child: GestureDetector(
                onTap: () => dialogPopUp(context),
                child: Container(
                  height: 60,
                  width: 100,
                  child: Image.asset('lib/images/addicon.png'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
