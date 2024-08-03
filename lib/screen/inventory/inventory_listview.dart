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
    desiredCategory =
        inventory.where((item) => item['category'] == currentCategory).toList();

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
            // List<String> months = [
            //   'Jan',
            //   'Feb',
            //   'Mar',
            //   'Apr',
            //   'May',
            //   'Jun',
            //   'Jul',
            //   'Aug',
            //   'Sep',
            //   'Oct',
            //   'Nov',
            //   'Dec'
            // ];
            // List<String> weekdays = [
            //   'Monday',
            //   'Tuesday',
            //   'Wednesday',
            //   'Thursday',
            //   'Friday',
            //   'Saturday',
            //   'Sunday'
            // ];
            // String addDateWeekday = weekdays[addDate.weekday - 1];
            // String expiryDateWeekday = weekdays[expiryDate.weekday - 1];
            // String addDateMonth = months[addDate.month - 1];
            // String expiryDateMonth = months[expiryDate.month - 1];

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
                                    fontSize: 15, fontWeight: FontWeight.w600),
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              Text(
                                'Added: ${DateFormat("d MMM y (E)").format(addDate)}\n'
                                'Expiry: ${DateFormat("d MMM y (E)").format(expiryDate)}',
                                style: const TextStyle(fontSize: 11, height: 2),
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
            // return ListTile(
            //   leading: item['imageDownloadURL'] == null
            //       ? const Icon(Icons.kitchen)
            //       :
            //   SizedBox(
            //     width: 100,
            //     child: ClipRRect(
            //       borderRadius: BorderRadius.circular(10),
            //       child: Image.network(
            //         item['imageDownloadURL'],
            //         fit: BoxFit.cover,
            //       ),
            //     ),
            //   ),
            //   title: Text(item['name'] ?? 'Unknown'),
            //   subtitle: Text(
            //     'Added: ${addDate.year} $addDateMonth ${addDate.day} - $addDateWeekday \n '
            //     'Expiry: ${expiryDate.year} $expiryDateMonth ${expiryDate.day} - $expiryDateWeekday',
            //     style: const TextStyle(fontSize: 12),
            //   ),
            //   trailing: Text(
            //     "x${item['quantity']}",
            //   ),
            //   isThreeLine: true,
            // );
          },
        ));
  }
}
