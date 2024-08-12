import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:rongo/model/item.dart';
import 'package:rongo/firestore.dart';

import '../../utils/utils.dart';
CollectionReference fridges = FirebaseFirestore.instance.collection('fridges');

Future<bool> addItemToFridge(Item item, fridgeID) async {

  DocumentReference fridgeDoc = fridges.doc(fridgeID);
  final FirestoreService firestoreService = FirestoreService();

  try {
    //Upload image to firebase
    item.imageDownloadURL =
        await firestoreService.updateInventoryImages(item.image);
    print("fridge.dart Image uploaded");

    DateTime addedDate = item.addedDate;
    DateTime? expiryDate;

    if (item.expiryDate != null) {
      print("item.expiryDate not null: ${item.expiryDate}");
      if (item.expiryDate!.contains('day') ||
          item.expiryDate!.contains('days')) {
        int expiredDayLeft = extractNumber(item.expiryDate!);
        expiryDate = addedDate
            .add(Duration(days: expiredDayLeft)); //Convert Day left to DateTime
        item.expiryDate = expiryDate.toIso8601String();
      } else if (item.expiryDate == 'Unknown') {
        item.expiryDate = null;
      } else {

        List<String> formats = ["yyyy-MM-dd", "dd MMM yyyy", "dd/MM/yyyy"];
        DateTime? expiryDate;

        for (String format in formats) {
          try {
            DateFormat dateFormat = DateFormat(format);
            expiryDate = dateFormat.parse(item.expiryDate!);
            item.expiryDate = expiryDate.toIso8601String();
            break;
          } catch (e) {
            // Continue to the next format if parsing fails
            continue;
          }
        }

        if (expiryDate == null) {
          // If all formats fail, set expiryDate to null
          print('Parsing failed, setting expiryDate to null');
          item.expiryDate = null;
        }
      }
    }

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

Future<List<Map<String, dynamic>>?> getInventoryList(String fridgeID) async {
  try {
    DocumentReference fridgeDoc = fridges.doc(fridgeID);
    DocumentSnapshot snapshot = await fridgeDoc.get();

    if (snapshot.exists) {
      Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;
      List<dynamic>? inventory = data?['inventory'] as List<dynamic>?;

      // Cast to List<Map<String, dynamic>> for easier manipulation
      return inventory?.map((item) => item as Map<String, dynamic>).toList();
    } else {
      print('No such document!');
      return null;
    }
  } catch (e) {
    print('Error retrieving inventory list: $e');
    return null;
  }
}

Future<void> updateInventoryItem(String fridgeID, String addedDate, Map<String, dynamic> updatedItem) async {
  try {
    DocumentReference fridgeDoc = fridges.doc(fridgeID);

    List<Map<String, dynamic>>? inventory = await getInventoryList(fridgeID);

    if (inventory != null) {
      // Find the index of the item to update
      int index = inventory.indexWhere((item) => item['addedDate'] == addedDate);

      if (index != -1) {
        // Update the item at the found index
        inventory[index] = updatedItem;

        // Update the document with the modified list
        await fridgeDoc.update({
          'inventory': inventory,
        });

        print('Item updated successfully!');
      } else {
        print('Item not found in inventory!');
      }
    } else {
      print('Failed to retrieve inventory list!');
    }
  } catch (e) {
    print('Error updating inventory item: $e');
  }
}

