import 'package:cloud_firestore/cloud_firestore.dart';

//notes
class FirestoreService {
  final CollectionReference notes =
      FirebaseFirestore.instance.collection('notes');

  //create notes
  Future<void> addNote(String message, String uid, String firstName) async {
    DocumentReference newNoteRef = notes.doc();

    return newNoteRef.set(
      {
        'notesId': newNoteRef.id,
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
