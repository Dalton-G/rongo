import 'dart:typed_data';

class Item {
  String uid;
  String name;
  int quantity;
  double price;
  String expiryDate;
  DateTime addedDate;
  String dictionaryUid;
  String historyUid;
  List<dynamic> allergen;
  String halal;
  String category;
  List<dynamic> ingredients;
  String storageMethod;
  Uint8List? image;
  String? imageDownloadURL;

  Item(
      {this.uid = "",
      required this.name,
      this.quantity = 1,
      this.price = 0,
      this.expiryDate = "Unknown",
      DateTime? dateTime,
      this.dictionaryUid = "",
      this.historyUid = "",
      this.allergen = const ["Unknown"],
      this.halal = "Unknown",
      this.ingredients = const ["Unknown"],
      this.storageMethod = "Unknown",
      this.category = "Others",
      this.image})
      : addedDate = dateTime ?? DateTime.now() {
    expiryDate = expiryDate == "Not visible" ? "Unknown" : expiryDate;
    ingredients = ingredients == "Not visible" ? ["Unknown"] : ingredients;
    allergen = allergen == "Not visible" ? ["Unknown"] : allergen;
  }

  Map<String, dynamic> toMap() {
    return {
      // 'uid': uid,
      'name': name,
      'purchaseQuantity': quantity,
      'currentQuantity': quantity,
      'netPrice': price/quantity,
      'totalPrice': price,
      'expiryDate': expiryDate,
      'addedDate': addedDate.toIso8601String(),
      // 'dictionaryUid': dictionaryUid,
      'historyUid': historyUid,
      'allergen': allergen,
      'halal': halal,
      'category': category,
      'ingredients': ingredients,
      'storageMethod': storageMethod,
      'imageDownloadURL':imageDownloadURL,
    };
  }

}
