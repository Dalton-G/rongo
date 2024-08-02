import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:rongo/utils/theme/theme.dart';
import 'package:rongo/widgets/containers.dart';
import 'package:rongo/widgets/stats.dart';

class HomePageContent extends StatefulWidget {
  final currentUser;

  const HomePageContent({super.key, this.currentUser});

  @override
  State<HomePageContent> createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> {

  final CollectionReference _fridgesCollection =
  FirebaseFirestore.instance.collection('fridges');

  @override
  Widget build(BuildContext context) {
    //page dimensions
    final Map currentUserMap = Map<String, dynamic>.from((widget.currentUser));

    print(currentUserMap);
    print(widget.currentUser.runtimeType);

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
                  boxShadow: AppTheme.bottomLightShadow),
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

        StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('fridges').doc(currentUserMap['fridgeId']).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return Center(child: Text('Document does not exist'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final List inventory = data['inventory'];
          print(data['inventory']);

          int totalInventory = inventory.length;
          int addedThisMonth = 0;
          int expiringSoonCount = 0;
          int expiredCount = 0;

          DateTime now = DateTime.now();
          int currentMonth = now.month;
          int currentYear = now.year;

          for (var item in inventory) {
            // Convert the addedDate string to a DateTime object
            DateTime addedDate = DateTime.parse(item['addedDate']);

            // Check if the year and month match the current year and month
            if (addedDate.year == currentYear &&
                addedDate.month == currentMonth) {
              addedThisMonth++;
            }

            DateTime? expiryDate;

            try {
              expiryDate = DateTime.parse(item['expiryDate']);
            } catch (e) {
              // If parsing fails, set expiryDate to null
              expiryDate = null;
            }

            if (expiryDate != null) {
              // Check if the expiryDate is within the next 7 days
              DateTime oneWeekFromNow = now.add(Duration(days: 7));
              if (expiryDate.isAfter(now) &&
                  expiryDate.isBefore(oneWeekFromNow)) {
                expiringSoonCount++;
              }

              // Check if the expiryDate has already passed
              if (expiryDate.isBefore(now)) {
                expiredCount++;
              }
            }
          }

          // return Text('Field value: ${data['field_name']}');
          return Positioned(
            left: screenWidth * 0.07,
            right: screenWidth * 0.07,
            bottom: screenHeight * 0.05,
            child:  Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [

                    GestureDetector(
                      onTap:((){
                        Navigator.pushNamed(context, '/inventory-category',arguments: currentUserMap);
                      })
                      ,
                      child: SquareContainer(
                        withPadding: false,
                        backgroundColor: AppTheme.lighterGreen,
                        height: 130,
                        width: 130,
                        roundedCorner: 25,
                        child: Stats(stats: "total", num: totalInventory,),
                      ),
                    ),
                    SquareContainer(
                      withPadding: false,
                      backgroundColor: AppTheme.lighterGreen,
                      height: 130,
                      width: 130,
                      roundedCorner: 25,
                      child: Stats(stats: "new",num: addedThisMonth,),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SquareContainer(
                      withPadding: false,
                      backgroundColor: AppTheme.lighterGreen,
                      height: 130,
                      width: 130,
                      roundedCorner: 25,
                      child: Stats(stats: "soon",num: expiringSoonCount,),
                    ),
                    SquareContainer(
                      withPadding: false,
                      backgroundColor: AppTheme.lighterGreen,
                      height: 130,
                      width: 130,
                      roundedCorner: 25,
                      child: Stats(stats: "expired",num: expiredCount,),
                    ),
                  ],
                ),
              ],
            ),
          );
        }
      )


      // StreamBuilder<Object>(
      //       stream: _fridgesCollection.doc(currentUser['fridgeId']).get(),,
      //       builder: (context, snapshot) {
      //         return Positioned(
      //           left: screenWidth * 0.07,
      //           right: screenWidth * 0.07,
      //           bottom: screenHeight * 0.05,
      //           child: Column(
      //             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      //             children: [
      //               Row(
      //                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      //                 children: [
      //                   GestureDetector(
      //                     onTap:((){
      //                       print("Tapp Data1");
      //                       print("currentUserMap");
      //                       print(currentUserMap);
      //                       Navigator.pushNamed(context, '/inventory-category',arguments: currentUserMap);
      //                     })
      //                     ,
      //                     child: SquareContainer(
      //                       backgroundColor: AppTheme.lighterGreen,
      //                       height: 130,
      //                       width: 130,
      //                       child: Center(
      //                         child: Text(
      //                           "Data 1",
      //                           textAlign: TextAlign.center,
      //                         ),
      //                       ),
      //                       roundedCorner: 25,
      //                     ),
      //                   ),
      //                   SquareContainer(
      //                     backgroundColor: AppTheme.lighterGreen,
      //                     height: 130,
      //                     width: 130,
      //                     child: Center(
      //                       child: Text(
      //                         "Data 2",
      //                         textAlign: TextAlign.center,
      //                       ),
      //                     ),
      //                     roundedCorner: 25,
      //                   ),
      //                 ],
      //               ),
      //               const SizedBox(height: 20),
      //               Row(
      //                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      //                 children: [
      //                   SquareContainer(
      //                     backgroundColor: AppTheme.lighterGreen,
      //                     height: 130,
      //                     width: 130,
      //                     child: Center(
      //                       child: Text(
      //                         "Data 3",
      //                         textAlign: TextAlign.center,
      //                       ),
      //                     ),
      //                     roundedCorner: 25,
      //                   ),
      //                   SquareContainer(
      //                     backgroundColor: AppTheme.lighterGreen,
      //                     height: 130,
      //                     width: 130,
      //                     child: Center(
      //                       child: Text(
      //                         "Data 4",
      //                         textAlign: TextAlign.center,
      //                       ),
      //                     ),
      //                     roundedCorner: 25,
      //                   ),
      //                 ],
      //               ),
      //             ],
      //           ),
      //         );
      //       }
      //     ),
        ],
      ),
    );
  }
}
