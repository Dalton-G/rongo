import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rongo/utils/utils.dart';
import 'package:intl/intl.dart';


import '../../utils/theme/theme.dart';

class InventoryListview extends StatefulWidget {
  const InventoryListview({super.key});

  @override
  _InventoryListviewState createState() => _InventoryListviewState();
}

class _InventoryListviewState extends State<InventoryListview> {

  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    List inventory = args['inventory'];
    var currentCategory = args['currentCategory'];

    List desiredCategory;
    desiredCategory = inventory.where((item) => item['category'] == currentCategory ).toList();


    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory'),
      ),
      body: ListView.builder(
              itemCount: desiredCategory.length,
              itemBuilder: (context, index) {
                var item = desiredCategory[index];
                DateFormat format = DateFormat("yyyy-MM-dd");
                DateTime addDate = format.parse(item['addedDate']);
                DateTime expiryDate = item['expiryDate'];
                // List<String> months = [
                //   'January', 'February', 'March', 'April', 'May', 'June', 'July',
                //   'August', 'September', 'October', 'November', 'December'
                // ];
                List<String> months = [
                  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul',
                  'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
                ];
                List<String> weekdays = [
                  'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
                ];
                String addDateWeekday = weekdays[addDate.weekday - 1];
                String expiryDateWeekday = weekdays[expiryDate.weekday - 1];
                String addDateMonth = months[addDate.month - 1];
                String expiryDateMonth = months[expiryDate.month - 1];


                return ListTile(
                  leading: const Icon(Icons.kitchen),
                  title: Text(item['name'] ?? 'Unknown'),
                  subtitle: Text(
                      'Added: ${addDate.year} $addDateMonth ${addDate.day} - $addDateWeekday \n '
                      'Expiry: ${expiryDate.year} $expiryDateMonth ${expiryDate.day} - $expiryDateWeekday'
                  ,style: TextStyle(fontSize: 12),),
                  trailing: Text("x${item['quantity']}",),
                  isThreeLine: true,

                );
              },
            )
    );
  }
}
