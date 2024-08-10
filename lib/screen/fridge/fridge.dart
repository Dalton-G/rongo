import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:rongo/firestore.dart';
import 'package:rongo/utils/theme/theme.dart';

import '../../utils/utils.dart';

class FridgePage extends StatefulWidget {
  final Map<String, dynamic>? currentUser;

  const FridgePage({super.key, this.currentUser});

  @override
  State<FridgePage> createState() => _FridgePageState();
}

class _FridgePageState extends State<FridgePage> {
  final FirestoreService firestoreService = FirestoreService();
  Map<String, String> userImages = {};

  @override
  void initState() {
    super.initState();
    if (widget.currentUser != null) {
      _loadUserImages(widget.currentUser!['uid']);
    }
  }

  Future<void> _pickAndUploadImage(String uid, String imageField) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        File imageFile = File(pickedFile.path);
        String fileName = '${uid}_$imageField';
        String? imageUrl =
            await firestoreService.uploadImage(imageFile, uid, fileName);

        if (imageUrl != null) {
          await firestoreService.updateUserImages(uid,
              image1: imageField == 'image1' ? imageUrl : null,
              image2: imageField == 'image2' ? imageUrl : null,
              image3: imageField == 'image3' ? imageUrl : null);
          setState(() {
            userImages[imageField] = imageUrl;
          });
        }
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to upload image: $e'),
        ),
      );
    }
  }

  Future<void> _loadUserImages(String uid) async {
    try {
      Map<String, String> images = await firestoreService.getUserImages(uid);
      setState(() {
        userImages = images;
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  Stream _loadUserInventory(fridgeId) {
    return FirebaseFirestore.instance.collection('fridges').doc(fridgeId).snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final String? currentUserId = widget.currentUser?['uid'];

    return Scaffold(
      body: StreamBuilder(
          stream: _loadUserInventory(widget.currentUser!['fridgeId']),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (!snapshot.hasData) {
              return const Center(child: Text('Fridge DocumentID does not exist'));
            }

            final data = snapshot.data!.data() as Map<String, dynamic>;
            final List inventory = data['inventory'];
          return Stack(
            children: [
              // Fridge background
              Positioned.fill(
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/inventory-tabs',
                        arguments: {
                          'InventoryFilter' : InventoryFilter.total,
                          'fridgeId' : widget.currentUser?['fridgeId'],
                        });
                  },
                  child: Image.asset(
                    'lib/images/fridgebackground.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),


              // Image position 1
              Positioned(
                left: MediaQuery.of(context).size.width * 0.4,
                top: MediaQuery.of(context).size.height * 0.22,
                child: GestureDetector(
                  onTap: () => currentUserId != null
                      ? _pickAndUploadImage(currentUserId, 'image1')
                      : null,
                  child: Container(
                    height: 60,
                    width: 100,
                    child: userImages['image1'] != null &&
                            userImages['image1']!.isNotEmpty
                        ? Image.network(userImages['image1']!)
                        : Image.asset('lib/images/addicon.png'),
                  ),
                ),
              ),

              // Image position 2
              Positioned(
                left: MediaQuery.of(context).size.width * 0.31,
                top: MediaQuery.of(context).size.height * 0.42,
                child: Transform.rotate(
                  angle: -0.3,
                  child: GestureDetector(
                    onTap: () => currentUserId != null
                        ? _pickAndUploadImage(currentUserId, 'image2')
                        : null,
                    child: Container(
                      height: 60,
                      width: 100,
                      child: userImages['image2'] != null &&
                              userImages['image2']!.isNotEmpty
                          ? Image.network(userImages['image2']!)
                          : Image.asset('lib/images/addicon.png'),
                    ),
                  ),
                ),
              ),

              // Image position 3
              Positioned(
                left: MediaQuery.of(context).size.width * 0.48,
                top: MediaQuery.of(context).size.height * 0.53,
                child: Transform.rotate(
                  angle: 0.6,
                  child: GestureDetector(
                    onTap: () => currentUserId != null
                        ? _pickAndUploadImage(currentUserId, 'image3')
                        : null,
                    child: Container(
                      height: 60,
                      width: 100,
                      child: userImages['image3'] != null &&
                              userImages['image3']!.isNotEmpty
                          ? Image.network(userImages['image3']!)
                          : Image.asset('lib/images/addicon.png'),
                    ),
                  ),
                ),
              ),
            ],
          );
        }
      ),
    );
  }
}
