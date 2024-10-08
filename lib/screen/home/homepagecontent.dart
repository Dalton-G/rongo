import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rongo/utils/theme/theme.dart';
import 'package:rongo/widgets/containers.dart';
import 'package:rongo/widgets/stats.dart';

import '../../routes.dart';
import '../../utils/utils.dart';

class HomePageContent extends StatefulWidget {
  final currentUser;

  const HomePageContent({super.key, this.currentUser});

  @override
  State<HomePageContent> createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> {
  get fridgeId => widget.currentUser['fridgeId'];

  @override
  Widget build(BuildContext context) {
    //page dimensions
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('fridges')
              .doc(fridgeId)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (!snapshot.hasData) {
              return const Center(
                  child: Text('Fridge DocumentID does not exist'));
            }

            final data = snapshot.data!.data() as Map<String, dynamic>;
            final List inventory = data['inventory'];

            int totalInventory = inventory.length;
            int addedThisMonth = 0;
            int expiringSoonCount = 0;
            int expiredCount = 0;
            int vegetableBestConsumeByToday = 0;
            int fruitBestConsumeByToday = 0;
            int MeatBestConsumeByToday = 0;

            DateTime now = DateTime.now();
            int currentMonth = now.month;
            int currentYear = now.year;

            for (var item in inventory) {
              DateTime addedDate = DateTime.parse(item['addedDate']);
              DateTime? expiryDate;

              if (item['expiryDate'] != null && item['currentQuantity'] > 0) {
                expiryDate = DateTime.parse(item['expiryDate']);
                DateTime oneWeekFromNow = now.add(const Duration(days: 7));
                DateTime tomorrow = now.add(const Duration(days: 1));

                // Check if the expiryDate is within the next 24 hours
                if (expiryDate.isAfter(now) && expiryDate.isBefore(tomorrow)) {
                  if (item['category'] == 'Vegetables')
                    vegetableBestConsumeByToday +=
                        item['currentQuantity'] as int;
                  if (item['category'] == 'Fruits')
                    fruitBestConsumeByToday += item['currentQuantity'] as int;
                  if (item['category'] == 'Meat')
                    MeatBestConsumeByToday += item['currentQuantity'] as int;
                }

                // Check if the expiryDate is within the next 7 days
                if (expiryDate.isAfter(now) &&
                    expiryDate.isBefore(oneWeekFromNow)) {
                  expiringSoonCount++;
                }

                // Check if the expiryDate has already passed
                if (expiryDate.isBefore(now)) {
                  expiredCount++;
                }
              }

              // Check if the year and month match the current year and month
              if (addedDate.year == currentYear &&
                  addedDate.month == currentMonth) {
                addedThisMonth++;
              }
            }

            return Stack(
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
                                onTap: () {
                                  Navigator.pushNamed(
                                      context, Routes.inventoryTabs,
                                      arguments: {
                                        'InventoryFilter':
                                            InventoryFilter.expiredSoon,
                                        'fridgeId':
                                            widget.currentUser?['fridgeId'],
                                      });
                                }),

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
                                onTap: () {
                                  Navigator.pushNamed(
                                      context, Routes.inventoryTabs,
                                      arguments: {
                                        'InventoryFilter':
                                            InventoryFilter.expiredSoon,
                                        'fridgeId':
                                            widget.currentUser?['fridgeId'],
                                      });
                                }),

                            //second for fruits
                            SquareContainer(
                                height: 80,
                                width: 80,
                                backgroundColor: Colors.white,
                                roundedCorner: 25.0,
                                child: Image.asset(
                                  'lib/images/homepagemeat.png',
                                  fit: BoxFit.contain,
                                ),
                                onTap: () {
                                  Navigator.pushNamed(
                                      context, Routes.inventoryTabs,
                                      arguments: {
                                        'InventoryFilter':
                                            InventoryFilter.expiredSoon,
                                        'fridgeId':
                                            widget.currentUser?['fridgeId'],
                                      });
                                }),
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
                                "$vegetableBestConsumeByToday vegetables best used today",
                                style: AppTheme.whiteSubtitleText,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            SizedBox(
                              width: 80,
                              child: Text(
                                "$fruitBestConsumeByToday fruits best eaten today",
                                style: AppTheme.whiteSubtitleText,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            SizedBox(
                              width: 80,
                              child: Text(
                                "$MeatBestConsumeByToday meats best consumed today",
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
                  bottom: screenHeight * 0.06,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          GestureDetector(
                            onTap: (() {
                              Navigator.pushNamed(context, Routes.inventoryTabs,
                                  arguments: {
                                    'InventoryFilter': InventoryFilter.total,
                                    'fridgeId': widget.currentUser?['fridgeId'],
                                  });
                            }),
                            child: SquareContainer(
                              withPadding: false,
                              backgroundColor: Colors.white,
                              height: 130,
                              width: 130,
                              roundedCorner: 25,
                              child: Stats(
                                stats: "total",
                                num: totalInventory,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: (() {
                              Navigator.pushNamed(context, Routes.inventoryTabs,
                                  arguments: {
                                    'InventoryFilter': InventoryFilter.newAdded,
                                    'fridgeId': widget.currentUser?['fridgeId'],
                                  });
                            }),
                            child: SquareContainer(
                              withPadding: false,
                              backgroundColor: Colors.white,
                              height: 130,
                              width: 130,
                              roundedCorner: 25,
                              child: Stats(
                                stats: "new",
                                num: addedThisMonth,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          GestureDetector(
                            onTap: (() {
                              Navigator.pushNamed(context, Routes.inventoryTabs,
                                  arguments: {
                                    'InventoryFilter':
                                        InventoryFilter.expiredSoon,
                                    'fridgeId': widget.currentUser?['fridgeId'],
                                  });
                            }),
                            child: SquareContainer(
                              withPadding: false,
                              backgroundColor: Colors.white,
                              height: 130,
                              width: 130,
                              roundedCorner: 25,
                              child: Stats(
                                stats: "soon",
                                num: expiringSoonCount,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: (() {
                              Navigator.pushNamed(context, Routes.inventoryTabs,
                                  arguments: {
                                    'InventoryFilter': InventoryFilter.expired,
                                    'fridgeId': widget.currentUser?['fridgeId'],
                                  });
                            }),
                            child: SquareContainer(
                              withPadding: false,
                              backgroundColor: Colors.white,
                              height: 130,
                              width: 130,
                              roundedCorner: 25,
                              child: Stats(
                                stats: "expired",
                                num: expiredCount,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            );
          }),
    );
  }
}
