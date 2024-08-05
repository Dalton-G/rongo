import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rongo/screen/fridge/fridge.dart';
import 'package:rongo/screen/home/homepagecontent.dart';
import 'package:rongo/screen/notes/notespage.dart';
import 'package:rongo/screen/recipe/recipe_homepage.dart';
import 'package:rongo/screen/scan_and_add/scanner.dart';
import 'package:rongo/utils/theme/theme.dart';
import 'package:rongo/firestore.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class IndexProvider with ChangeNotifier {
  int _selectedIndex = 0;

  int get selectedIndex => _selectedIndex;

  void setSelectedIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }
}

class _HomePageState extends State<HomePage> {
  //declarations
  // int _selectedIndex = 0;
  String firstName = "Suzanne";
  List<Map<String, dynamic>> users = [];
  Map<String, dynamic>? currentUser;

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  void fetchUsers() async {
    users = await FirestoreService().getUsers();
    setState(() {
      if (users.isNotEmpty) {
        currentUser = users[0];
      }
    });
  }

  void showUserDropdown(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text('Select User'),
          children: users.map((user) {
            return SimpleDialogOption(
              onPressed: () {
                setState(() {
                  currentUser = user;
                });
                Navigator.pop(context);
              },
              child: Text(user['firstName']),
            );
          }).toList(),
        );
      },
    );
  }

  // Method to generate pages based on the current state
  List<Widget> _getPages() {
    if (currentUser == null) {
      return [
        const Center(
            child:
                CircularProgressIndicator()), // Placeholder while fetching user
        const Center(
            child:
                CircularProgressIndicator()), // Placeholder while fetching user
        const Center(
            child:
                CircularProgressIndicator()), // Placeholder while fetching user
        const Center(
            child:
                CircularProgressIndicator()), // Scanner(currentUser: currentUser!) -> Placeholder while fetching user
        const Center(
            child:
                CircularProgressIndicator()), // Placeholder while fetching user
      ];
    }

    return [
      HomePageContent(currentUser: currentUser!),
      FridgePage(currentUser: currentUser!),
      NotesPage(currentUser: currentUser!),
      Scanner(currentUser: currentUser!),
      RecipeHomePage(currentUser: currentUser!),
    ];
  }

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
              if (currentUser != null)
                Text(" ${currentUser!['firstName']}",
                    style: AppTheme.greenAppBarText),
            ],
          ),
        ),
        actions: [
          //settings button
          IconButton(
            onPressed: () {
              showUserDropdown(context);
            },
            icon: Icon(
              Icons.settings_rounded,
              color: Colors.grey[900],
            ),
          ),
        ],
      ),
      body: Consumer<IndexProvider>(builder: (context, counter, child) {
        return Stack(
          children: [
            //content
            Positioned.fill(
              child: _getPages()[
                  Provider.of<IndexProvider>(context).selectedIndex],
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
                      boxShadow: AppTheme.topLightShadow),
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
        );
      }),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    bool isSelected =
        Provider.of<IndexProvider>(context).selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          // _selectedIndex = index;
          Provider.of<IndexProvider>(context, listen: false)
              .setSelectedIndex(index);
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
