import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:rongo/provider/Item_provider.dart';

import '../../model/item.dart';
import '../../utils/theme/theme.dart';

class ScannedItemList extends StatefulWidget {
  const ScannedItemList({super.key});

  @override
  State<ScannedItemList> createState() => _ScannedItemListState();
}

class _ScannedItemListState extends State<ScannedItemList> {
  var _selectedIndex = null;

  @override
  Widget build(BuildContext context) {
    return Consumer<ItemProvider>(builder: (context, itemProvider, child) {
      List<Item> itemList = itemProvider.itemList;

      return Scaffold(
        appBar: AppBar(
          title: const Text("Food Scanner"),
        ),
        body: itemList.length > 0
            ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 15),
                child: ListView.builder(
                    itemCount: itemList.length,
                    itemBuilder: (context, index) {
                      Item item = itemList[index];
                      String price =
                          item.price > 0 ? item.price.toString() : "Unknown";
                      String quantity = item.quantity.toString();
                      TextEditingController _priceController =
                          TextEditingController();
                      _priceController.text = item.price.toString();

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 20),
                        child: Slidable(
                          endActionPane: ActionPane(
                            motion: DrawerMotion(),
                            children: [
                              SlidableAction(
                                onPressed: (context) {
                                  itemProvider.removeItem(index);
                                },
                                icon: Icons.delete,
                                foregroundColor: Colors.redAccent,
                                backgroundColor: Colors.transparent,
                              ),
                            ],
                          ),
                          child: Container(
                            decoration: AppTheme.widgetDeco(),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 5.0, vertical: 5),
                              child: ListTile(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15)),
                                // selectedTileColor: AppTheme.mainGreen.withOpacity(0.1),
                                title: Text(item.name),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: index != _selectedIndex
                                      ? Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              width: 150,
                                              height: 30,
                                              child: Padding(
                                                padding: const EdgeInsets.only(top: 5.0),
                                                child: Text("RM $price"),
                                              ),
                                            ),
                                            Text("x $quantity")
                                          ],
                                        )
                                      : Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              width: 150,
                                              height: 30,
                                              child: TextField(
                                                decoration: InputDecoration(
                                                    isDense: true,
                                                    icon: Text("RM")),
                                                onTapOutside: (event) {
                                                  print('onTapOutside');
                                                  FocusManager
                                                      .instance.primaryFocus
                                                      ?.unfocus();
                                                  itemProvider.setPrice(
                                                      index,
                                                      double.parse(
                                                          _priceController
                                                              .text));
                                                },
                                                maxLines: null,
                                                controller: _priceController,
                                                style: TextStyle(
                                                    color: Colors.black87,
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 15),
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                GestureDetector(
                                                  onTap: () {
                                                    itemProvider
                                                        .removeQuantity(index);
                                                  },
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            right: 5.0),
                                                    child: Icon(Icons.remove),
                                                  ),
                                                ),
                                                Container(
                                                    decoration:
                                                        AppTheme.widgetDeco(),
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 8),
                                                    child: Text(quantity)),
                                                GestureDetector(
                                                  onTap: () {
                                                    itemProvider
                                                        .addQuantity(index);
                                                  },
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 5.0),
                                                    child: Icon(Icons.add),
                                                  ),
                                                )
                                              ],
                                            )
                                          ],
                                        ),
                                ),
                                // selected: index == _selectedIndex,
                                onTap: () {
                                  setState(() {
                                    _selectedIndex = index;
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
              )
            : Center(
                child: Text("Nothing to see here.\nAdd some item now!"),
              ),
      );
    });
  }
}
