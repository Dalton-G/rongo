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
      this.category = "Others"})
      : addedDate = dateTime ?? DateTime.now() {
    expiryDate = expiryDate == "Not visible" ? "Unknown" : expiryDate;
    ingredients = ingredients == "Not visible" ? ["Unknown"] : ingredients;
    allergen = allergen == "Not visible" ? ["Unknown"] : allergen;
  }
}
