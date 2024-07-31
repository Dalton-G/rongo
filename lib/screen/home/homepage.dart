import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rongo/screen/fridge/fridge.dart';
import 'package:rongo/screen/home/homepagecontent.dart';
import 'package:rongo/screen/notes/notespage.dart';
import 'package:rongo/screen/recipe/recipe_homepage.dart';
import 'package:rongo/screen/scan_and_add/scanner.dart';
import 'package:rongo/utils/theme/theme.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //declarations
  int _selectedIndex = 0;
  String firstName = "Suzanne";

  //pages for navbar
  final List<Widget> _pages = [
    HomePageContent(),
    FridgePage(),
    NotesPage(),
    Scanner(),
    RecipeHomePage(),
  ];

  //functions

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    //page content
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Image.asset(
            'lib/images/profilephoto.png',
            width: 80,
            height: 80,
          ),
        ),
        title: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Welcome back,", style: AppTheme.blackAppBarText),
              Text(" Dalton", style: AppTheme.greenAppBarText),
            ],
          ),
        ),
        actions: [
          //settings button
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.settings_rounded,
              color: Colors.grey[900],
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          //content
          Positioned.fill(
            child: _pages[_selectedIndex],
          ),

          //bottom nav bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
                height: 60,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(25),
                    topLeft: Radius.circular(25),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: Offset(0, -4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(Icons.home_rounded, 0),
                    _buildNavItem(Icons.kitchen_rounded, 1),
                    _buildNavItem(Icons.sticky_note_2_rounded, 2),
                    _buildNavItem(Icons.qr_code_rounded, 3),
                    _buildNavItem(Icons.dinner_dining_rounded, 4),
                  ],
                )),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.mainGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Icon(
          icon,
          color: isSelected ? Colors.white : AppTheme.mainGreen,
        ),
      ),
    );
  }
}
