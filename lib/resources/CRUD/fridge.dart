import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:rongo/model/item.dart';
import 'package:rongo/firestore.dart';

Future<bool> addItemToFridge(Item item, fridgeID) async {

  CollectionReference fridges = FirebaseFirestore.instance.collection('fridges');
  DocumentReference fridgeDoc = fridges.doc(fridgeID);
  final FirestoreService firestoreService = FirestoreService();

  try {
    //Upload image to firebase
    item.imageDownloadURL = await firestoreService.updateInventoryImages(item.image);

    // Append the item map to the 'inventory' list in the document
    await fridgeDoc.update({
      'inventory': FieldValue.arrayUnion([item.toMap()]),
    });
    print('Item added successfully!');
    return true;

  } catch (e) {
    // If the 'inventory' list does not exist, create it and then add the item
    if (e is FirebaseException && e.code == 'not-found') {
      try {
        await fridgeDoc.set({
          'inventory': [item.toMap()],
        });
        print('Item added successfully!');
        return true;
      } catch (e) {
        print('Error adding item: $e');
        return false;
      }
    } else {
      print('Error adding item: $e');
      return false;
    }
  }
}
