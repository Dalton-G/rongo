import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rongo/screen/home/dummypages.dart';
import 'package:rongo/screen/home/homepagecontent.dart';
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
    DummyPage1(),
    DummyPage2(),
    Scanner(),
    DummyPage3(),
  ];

  //functions

  @override
  Widget build(BuildContext context) {
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
      body: _pages[_selectedIndex],
    );
  }
}
