import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomePageContent extends StatefulWidget {
  const HomePageContent({super.key});

  @override
  State<HomePageContent> createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Image.asset('lib/images/homepagebackground.png'),
    );
  }
}
