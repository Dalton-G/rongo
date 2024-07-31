import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final CollectionReference notes =
      FirebaseFirestore.instance.collection('notes');

  //create notes
  Future<void> addNote(String message) {
    return notes.add(
      {
        'message': message,
        'isCompleted': false,
        'datePosted': Timestamp.now(),
      },
    );
  }
}
