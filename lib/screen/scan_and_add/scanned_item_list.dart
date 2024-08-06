import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:provider/provider.dart';
import 'package:rongo/provider/Item_provider.dart';
import 'package:rongo/widgets/button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';


import '../../model/item.dart';
import '../../resources/CRUD/fridge.dart';
import '../../utils/photo.dart';
import '../../utils/theme/theme.dart';
import '../../utils/utils.dart';

class ScannedItemList extends StatefulWidget {
  const ScannedItemList({super.key});

  @override
  State<ScannedItemList> createState() => _ScannedItemListState();
}

class _ScannedItemListState extends State<ScannedItemList> {
  var _selectedIndex = null;
  var _isLoading = false;
  var _isAdding = false;
  var result;

  late var currentUser;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Extract the arguments
    currentUser = ModalRoute.of(context)!.settings.arguments; // Need Fridge ID
  }

  Future<GenerateContentResponse> validateImage(Uint8List image, ItemProvider itemProvider) async {
    setState(() {
      _isLoading = true;
    });
    final itemList = itemProvider.itemList.map((item) => item.name).toList();
    print(itemList.toString());
    final prompt = 'Given the list of item: ${itemList.toString()}'
    'You need to match the entry in the image given, and identify the quantity purchased and the total price of the item with the item name in list'
    'When you return the item name, return the name in the list given instead of the name in receipt'
    'Then, return the output as map like { "isReceipt": true/false, name of item: {"totalPrice": the price, "quantity": the quantity of the item}, ...}';

    final response = await model.generateContent([
      Content.multi([TextPart(prompt), DataPart('image/jpeg', image)]),
    ]);
    print(
        "=========================================================================================");
    print(response.text);
    print(
        "=========================================================================================");

    return response;
  }

  Future<String?> _onItemFound(ItemProvider itemProvider) async {
    try {
      final image = await photoPicker.takePhoto();
      final itemFound = await validateImage(image, itemProvider);
      final response =
          itemFound.text!.replaceAll("```json", "").replaceAll("```", "");
      result = json.decode(response);

      setState(() {
        itemProvider.update(result);
        _isLoading = false;

      });
    } on PhotoPickerException {
      return "error";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ItemProvider>(builder: (context, itemProvider, child) {
      List<Item> itemList = itemProvider.itemList;

      return Scaffold(
        appBar: AppBar(
          title: const Text("Scanned items"),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 20.0),
                child: GestureDetector(
                  onTap: () async {

                  if (!_isAdding) {

                    setState(() {
                      _isAdding = true;
                    });

                    bool successfullyAddToFridge = false;
                    var historyUid = Uuid().v4(); //Receipt ID

                    for (int i = 0; i < itemList.length; i++) {
                      var item = itemList[i];
                      item.historyUid = historyUid;

                      successfullyAddToFridge =
                          await addItemToFridge(item, currentUser['fridgeId']);
                    }
                    if (successfullyAddToFridge) {
                      if (mounted) {
                        setState(() {
                          showSnackBar('Item added successfully!.',context);

                          _isAdding = false;
                          itemList.clear();
                          Navigator.pop(context);
                        });
                      }
                    } else {
                      setState(() {
                        showSnackBar('Failed to add Item, Please Try again.',context);
                        _isAdding = false;
                      });
                    }
                  }
                },
                child: _isAdding
                    ? const CircularProgressIndicator()
                    : const Text(
                        "Save",
                        style:
                            TextStyle(color: AppTheme.mainGreen, fontSize: 17),
                      ),
              ),
              ),
            ],
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.all(20.0),
          child: CustomizedButton(
            isRoundButton: true,
            icon: Icons.receipt_long_rounded,
            func: () {
              _onItemFound(itemProvider);
            },
          ),
        ),
        body: itemList.length > 0
            ? _isLoading? Center(child: CircularProgressIndicator(),):Padding(
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
                                                padding: const EdgeInsets.only(
                                                    top: 5.0),
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
