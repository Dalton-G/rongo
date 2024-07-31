import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rongo/utils/theme/theme.dart';
import 'package:rongo/widgets/containers.dart';

class HomePageContent extends StatefulWidget {
  const HomePageContent({super.key});

  @override
  State<HomePageContent> createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> {
  @override
  Widget build(BuildContext context) {
    //page dimensions
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        //whatever code is written first is on the bottom most

//background image
        children: [
          Image.asset(
            'lib/images/homepagebackground.png',
          ),

          //white overlay
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: screenHeight * 0.55,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(25),
                  topLeft: Radius.circular(25),
                ),
              ),
            ),
          ),

          //search bar

          Positioned(
            right: screenWidth * 0.07,
            left: screenWidth * 0.07,
            top: screenHeight * 0.05,
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search...',
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                  prefixIcon: Icon(
                    Icons.search,
                    color: AppTheme.mainGreen,
                  ),
                ),
              ),
            ),
          ),

          //green container
          Positioned(
            left: screenWidth * 0.07,
            top: screenHeight * 0.15,
            right: screenWidth * 0.07,
            child: Container(
              height: 180,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                color: AppTheme.mainGreen,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      //three boxes inside

                      //first for vegetables
                      SquareContainer(
                        height: 80,
                        width: 80,
                        backgroundColor: Colors.white,
                        roundedCorner: 25.0,
                        child: Image.asset(
                          'lib/images/tomato.png',
                          fit: BoxFit.contain,
                        ),
                      ),

                      //second for fruits
                      SquareContainer(
                        height: 80,
                        width: 80,
                        backgroundColor: Colors.white,
                        roundedCorner: 25.0,
                        child: Image.asset(
                          'lib/images/avocado.png',
                          fit: BoxFit.contain,
                        ),
                      ),

                      //second for fruits
                      SquareContainer(
                        height: 80,
                        width: 80,
                        backgroundColor: Colors.white,
                        roundedCorner: 25.0,
                        child: Image.asset(
                          'lib/images/food.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),
                  //Text Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(
                        width: 80,
                        child: Text(
                          "9 vegetables best used today",
                          style: AppTheme.whiteSubtitleText,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(
                        width: 80,
                        child: Text(
                          "5 fruits best eaten today",
                          style: AppTheme.whiteSubtitleText,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(
                        width: 80,
                        child: Text(
                          "5 recipes possible",
                          style: AppTheme.whiteSubtitleText,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),

          // Analysis squares (2x2 grid)
          Positioned(
            left: screenWidth * 0.07,
            right: screenWidth * 0.07,
            bottom: screenHeight * 0.05,
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SquareContainer(
                      backgroundColor: AppTheme.lighterGreen,
                      height: 130,
                      width: 130,
                      child: Center(
                        child: Text(
                          "Data 1",
                          textAlign: TextAlign.center,
                        ),
                      ),
                      roundedCorner: 25,
                    ),
                    SquareContainer(
                      backgroundColor: AppTheme.lighterGreen,
                      height: 130,
                      width: 130,
                      child: Center(
                        child: Text(
                          "Data 2",
                          textAlign: TextAlign.center,
                        ),
                      ),
                      roundedCorner: 25,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SquareContainer(
                      backgroundColor: AppTheme.lighterGreen,
                      height: 130,
                      width: 130,
                      child: Center(
                        child: Text(
                          "Data 3",
                          textAlign: TextAlign.center,
                        ),
                      ),
                      roundedCorner: 25,
                    ),
                    SquareContainer(
                      backgroundColor: AppTheme.lighterGreen,
                      height: 130,
                      width: 130,
                      child: Center(
                        child: Text(
                          "Data 4",
                          textAlign: TextAlign.center,
                        ),
                      ),
                      roundedCorner: 25,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
