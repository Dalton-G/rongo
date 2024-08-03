import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rongo/utils/utils.dart';
import 'package:intl/intl.dart';

import '../../utils/theme/theme.dart';
import '../home/homepage.dart';

class InventoryListview extends StatefulWidget {
  const InventoryListview({super.key});

  @override
  _InventoryListviewState createState() => _InventoryListviewState();
}

class _InventoryListviewState extends State<InventoryListview> {
  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    List inventory = args['inventory'];
    var currentCategory = args['currentCategory'];
    var type = args['type'];
    List? desiredCategory = [];
    String? nullPrompting;

    switch (type){
      case 'total':
        desiredCategory =
            inventory.where((item) => item['category'] == currentCategory).toList();
        nullPrompting = "Fridge's empty—time to restock! A full fridge uses less energy.";
        break;

      case 'new':
        desiredCategory = inventory;
        nullPrompting = "Fridge's empty—time to restock! A full fridge uses less energy.";
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


            var item = desiredCategory?[index];
            DateFormat format = DateFormat("yyyy-MM-dd");
            DateTime addDate = format.parse(item['addedDate']);
            DateTime expiryDate = item['expiryDate'];



              return Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
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
                              "x${item['quantity']}",
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );



          },
        ):
            Center(child: Text(nullPrompting??""))
    );
  }
}
