import 'package:cloud_firestore/cloud_firestore.dart';

//notes
class FirestoreService {
  final CollectionReference notes =
      FirebaseFirestore.instance.collection('notes');

  //create notes
  Future<void> addNote(String message, String uid, String firstName) {
    return notes.add(
      {
        'message': message,
        'isCompleted': false,
        'datePosted': Timestamp.now(),
        'uid': uid,
        'firstName': firstName,
      },
    );
  }

  //read notes
  Stream<QuerySnapshot> getNotesStream() {
    final notesStream =
        notes.orderBy('datePosted', descending: true).snapshots();
    return notesStream;
  }

//user collection
  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');

  //get users
  Future<List<Map<String, dynamic>>> getUsers() async {
    QuerySnapshot usersSnapshot = await usersCollection.get();
    return usersSnapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }
}
