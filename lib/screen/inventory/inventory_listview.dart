import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../resources/CRUD/fridge.dart';
import '../../utils/theme/theme.dart';
import '../../utils/utils.dart';
import 'edit_quantity.dart';
import '../home/homepage.dart';

class InventoryListview extends StatefulWidget {
  const InventoryListview({super.key});

  @override
  _InventoryListviewState createState() => _InventoryListviewState();
}

class _InventoryListviewState extends State<InventoryListview> {
  int _counter = 0;

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    List inventory = args['inventory'];
    String fridgeId = args['fridgeId'];
    var currentCategory = args['currentCategory'];
    var type = args['type'];
    List? desiredCategory = [];
    String? nullPrompting;
    bool inventoryListNotEmpty = false;

    switch (type){
      case 'total':
        desiredCategory =
            inventory.where((item) => item['category'] == currentCategory).toList();
        nullPrompting = "Fridge's empty—time to restock!\n A full fridge uses less energy.";
        break;

      case 'new':
        desiredCategory = inventory;
        nullPrompting = "Fridge's empty—time to restock!\n A full fridge uses less energy.";
        break;

      case 'soon':
        desiredCategory = inventory;
        nullPrompting = "No nearly expired food! Your fridge is fresh.";
        break;

      case 'expired':
        desiredCategory = inventory;
        nullPrompting = "No food wasted? You're a food hero!";
        break;

    }

    return Scaffold(
        appBar: AppBar(
          title: const Text('Inventory'),
        ),

        //TODO: Handle if desiredCategory? is null
        body: desiredCategory!.isNotEmpty? ListView.builder(
          itemCount: desiredCategory!.length + 1,
          itemBuilder: (context, index) {

            if (index == (desiredCategory!.length) ) {

              if(inventoryListNotEmpty){
                return const AddItemWidget();
              }
              else{
                return AddItemWidgetWithPrompt(nullPrompting: nullPrompting!);
              }
            }

            var item = desiredCategory?[index];
            DateFormat format = DateFormat("yyyy-MM-dd");
            DateTime addDate = format.parse(item['addedDate']);
            DateTime expiryDate = DateTime.parse(item['expiryDate']);

            if ( item['currentQuantity'] <= 0 ) {
              return const SizedBox(width: 1,);
            }

            if ( item['currentQuantity'] > 0 ){
              inventoryListNotEmpty = true;
            }

            return Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
                child: Slidable(
                  endActionPane: ActionPane(
                    motion: DrawerMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (context) {
                          setState(() {
                            item['currentQuantity'] = 0;
                            updateInventoryItem(fridgeId,item['addedDate'],item);
                            showSnackBar("Consumption Updated Successfully. No more ${item['name']}.",context);
                          });
                        },
                        icon: Icons.delete,
                        foregroundColor: Colors.redAccent,
                        backgroundColor: Colors.transparent,
                      ),
                    ],
                  ),
                  child: GestureDetector(
                    onTap: ((){_showSaveDeleteDialog(context,item,fridgeId,item['currentQuantity'], item['name']);}),
                    child: Container(
                      decoration: AppTheme.widgetDeco(),
                      padding: EdgeInsets.all(15),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 100,
                            height: 80,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: item['imageDownloadURL'] == null
                                  ? Image.asset("lib/images/avocado.png")
                                  : Image.network(
                                item['imageDownloadURL'],
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 15,
                          ),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['name'] ?? 'Unknown',
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    SizedBox(
                                      height: 8,
                                    ),
                                    Text(
                                      'Added: ${DateFormat("d MMM y (E)").format(
                                          addDate)}\n'
                                          'Expiry: ${DateFormat("d MMM y (E)")
                                          .format(expiryDate)}',
                                      style: const TextStyle(
                                          fontSize: 11, height: 2),
                                    ),
                                  ],
                                ),
                                Text(
                                  "x${item['currentQuantity']}",
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
              },
        ):

        AddItemWidgetWithPrompt(nullPrompting: nullPrompting!)
    );
  }
  void _showSaveDeleteDialog(BuildContext context, item, fridgeId, int currentQuantity, String name) {
    showDialog(
      context: context,
      builder: (BuildContext context) {

        return AlertDialog(
          title: const Text('Modify Quantity'),
          content: CounterWidget(
            onCounterChanged: (int newCounter) {
              setState(() {
                _counter = newCounter;
              });
            }, currentQuantity: currentQuantity, name: name,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                item['currentQuantity'] = _counter;
                updateInventoryItem(fridgeId,item['addedDate'],item);
                print('Save button pressed');
                item['currentQuantity'] == 0 ?
                showSnackBar("Consumption Updated Successfully. No more ${item['name']}.",context)
                    :showSnackBar("Consumption Updated Successfully. ${item['currentQuantity']} ${item['name']} left.",context);
              },
              child: Text('Save'),
            ),
            // TextButton(
            //   onPressed: () {
            //     Navigator.of(context).pop();
            //     // Add your delete functionality here
            //     print('Delete Item button pressed');
            //   },
            //   child: Text('Delete Item'),
            // ),
          ],
        );
      },
    );
  }}

class AddItemWidget extends StatelessWidget {
  const AddItemWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
      const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
      child: GestureDetector(
        onTap: ((){
          Navigator.popUntil(context, ModalRoute.withName('/homepage'));
          Provider.of<IndexProvider>(context, listen: false).setSelectedIndex(3);
        }),
        child: Container(
          decoration: AppTheme.widgetDeco(),
          padding: EdgeInsets.all(15),
          child: const SizedBox(
            height: 80,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_outlined),
                Text("Add new item")
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AddItemWidgetWithPrompt extends StatelessWidget {
  final String nullPrompting;

  const AddItemWidgetWithPrompt({super.key, required this.nullPrompting});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const AddItemWidget(),
        Padding(
          padding: EdgeInsets.only(top: (MediaQuery.of(context).size.height * 0.48) - 135),
          child: Center(child: Text(nullPrompting??"")),
        ),
      ],
    );
  }
}

