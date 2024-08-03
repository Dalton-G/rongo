import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

// Notes
class FirestoreService {
  final CollectionReference notes =
      FirebaseFirestore.instance.collection('notes');

  // Create notes
  Future<void> addNote(
    String message,
    String uid,
    String firstName,
  ) async {
    DocumentReference newNoteRef = notes.doc();

    return newNoteRef.set(
      {
        'notesId': newNoteRef.id,
        'message': message,
        'isCompleted': false,
        'datePosted': Timestamp.now(),
        'uid': uid,
        'firstName': firstName,
        'image1': '',
        'image2': '',
        'image3': '',
      },
    );
  }

  // Read notes
  Stream<QuerySnapshot> getNotesStream() {
    final notesStream =
        notes.orderBy('datePosted', descending: true).snapshots();
    return notesStream;
  }

  // Method to delete a note
  Future<void> deleteNote(String notesId) async {
    // Find the document with the given notesId
    QuerySnapshot snapshot =
        await notes.where('notesId', isEqualTo: notesId).get();

    if (snapshot.docs.isNotEmpty) {
      // Delete the document
      await notes.doc(snapshot.docs.first.id).delete();
    } else {
      throw Exception('Note with notesId $notesId not found');
    }
  }

  // Method to mark a note as completed
  Future<void> completeNote(String notesId) async {
    // Find the document with the given notesId
    QuerySnapshot snapshot =
        await notes.where('notesId', isEqualTo: notesId).get();

    if (snapshot.docs.isNotEmpty) {
      // Update the document
      await notes.doc(snapshot.docs.first.id).update({'isCompleted': true});
    } else {
      throw Exception('Note with notesId $notesId not found');
    }
  }

  // User collection
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');

  // Get users
  Future<List<Map<String, dynamic>>> getUsers() async {
    QuerySnapshot usersSnapshot = await usersCollection.get();
    return usersSnapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }

  // Upload image to Firebase Storage and get URL
  Future<String?> uploadImage(
      File image, String userId, String imageName) async {
    try {
      Reference storageRef =
          _storage.ref().child('user_images/$userId/$imageName');
      UploadTask uploadTask = storageRef.putFile(image);
      TaskSnapshot taskSnapshot = await uploadTask;
      return await taskSnapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  // Update user's image data in Firestore
  Future<void> updateUserImages(String userId,
      {String? image1, String? image2, String? image3}) async {
    Map<String, dynamic> updates = {};
    if (image1 != null) updates['image1'] = image1;
    if (image2 != null) updates['image2'] = image2;
    if (image3 != null) updates['image3'] = image3;

    if (updates.isNotEmpty) {
      // Find the document with the given userId
      QuerySnapshot snapshot =
          await usersCollection.where('uid', isEqualTo: userId).get();

      if (snapshot.docs.isNotEmpty) {
        // Update the document
        await usersCollection.doc(snapshot.docs.first.id).update(updates);
      } else {
        throw Exception('User with uid $userId not found');
      }
    }
  }

  // Get user's image URLs from Firestore
  Future<Map<String, String>> getUserImages(String userId) async {
    // Find the document with the given userId
    QuerySnapshot snapshot =
        await usersCollection.where('uid', isEqualTo: userId).get();

    if (snapshot.docs.isNotEmpty) {
      DocumentSnapshot userDoc = snapshot.docs.first;
      return {
        'image1': userDoc['image1'] ?? '',
        'image2': userDoc['image2'] ?? '',
        'image3': userDoc['image3'] ?? '',
      };
    } else {
      throw Exception('User with uid $userId not found');
    }
  }


  // Inventory Collection
  final CollectionReference inventoryCollection =
  FirebaseFirestore.instance.collection('inventory');

  Future<String?> updateInventoryImages(image) async {

    try {
      Reference storageRef =
      _storage.ref().child('inventory/${DateTime.now().millisecondsSinceEpoch}');
      UploadTask uploadTask = storageRef.putData(image,SettableMetadata(contentType: 'image/jpeg'));
      TaskSnapshot taskSnapshot = await uploadTask;
      return await taskSnapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }




}
