import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:rongo/routes.dart';

class FridgePage extends StatefulWidget {
  const FridgePage({super.key});

  @override
  State<FridgePage> createState() => _FridgePageState();
}

class _FridgePageState extends State<FridgePage> {
  final ImagePicker _picker = ImagePicker();

  // State to store the image URLs
  String? _imageUrl1;
  String? _imageUrl2;
  String? _imageUrl3;

  // Function to pick an image from gallery and upload it
  Future<void> _pickImage(int index) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);

      // Upload the image to Firebase Storage and get the download URL
      String downloadUrl = await _uploadImage(imageFile);

      // Update the state with the new image URL
      setState(() {
        if (index == 1) {
          _imageUrl1 = downloadUrl;
        } else if (index == 2) {
          _imageUrl2 = downloadUrl;
        } else if (index == 3) {
          _imageUrl3 = downloadUrl;
        }
      });
    } else {
      print('No image selected.');
    }
  }

  // Function to upload the image to Firebase Storage
  Future<String> _uploadImage(File image) async {
    try {
      FirebaseStorage storage = FirebaseStorage.instance;
      String fileName = DateTime.now().toString();
      Reference ref = storage.ref().child('uploads/$fileName');

      UploadTask uploadTask = ref.putFile(image);
      TaskSnapshot snapshot = await uploadTask;

      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Failed to upload image: $e');
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          // Fridge background
          Positioned.fill(
            child: GestureDetector(
              onTap: () => Navigator.pushNamed(context, Routes.notespage),
              child: Image.asset(
                'lib/images/fridgebackground.png',
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Add icon or image placeholders
          _buildImageContainer(
              screenWidth * 0.4, screenHeight * 0.22, _imageUrl1, 1),
          _buildImageContainer(
              screenWidth * 0.31, screenHeight * 0.42, _imageUrl2, 2, -0.3),
          _buildImageContainer(
              screenWidth * 0.48, screenHeight * 0.53, _imageUrl3, 3, 0.6),
        ],
      ),
    );
  }

  // Helper function to build image containers
  Widget _buildImageContainer(
      double left, double top, String? imageUrl, int index,
      [double angle = 0]) {
    return Positioned(
      left: left,
      top: top,
      child: Transform.rotate(
        angle: angle,
        child: GestureDetector(
          onTap: () => _pickImage(index),
          child: Container(
            height: 60,
            width: 100,
            child: imageUrl == null
                ? Image.asset('lib/images/addicon.png')
                : Image.network(imageUrl, fit: BoxFit.cover),
          ),
        ),
      ),
    );
  }
}
