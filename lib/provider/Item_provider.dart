import 'package:flutter/cupertino.dart';

import '../model/item.dart';

class ItemProvider with ChangeNotifier{
  List<Item> _itemList = [];

  List<Item> get itemList  => _itemList;

  void addItem(Item item){
    _itemList.add(item);
  }

  void removeItem(int index){
    _itemList.removeAt(index);
    notifyListeners();
  }

  void addQuantity(int index){
    itemList[index].quantity += 1;
    notifyListeners();
  }

  void removeQuantity(int index){
    if(itemList[index].quantity > 1){
      itemList[index].quantity -= 1;
      notifyListeners();
    }
  }

  void setPrice(int index, double price){
    itemList[index].price = price;
    notifyListeners();
  }

}