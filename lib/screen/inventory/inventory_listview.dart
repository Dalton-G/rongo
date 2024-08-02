import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rongo/utils/utils.dart';

import '../../utils/theme/theme.dart';

class InventoryListview extends StatefulWidget {
  const InventoryListview({super.key});

  @override
  _InventoryListviewState createState() => _InventoryListviewState();
}

class _InventoryListviewState extends State<InventoryListview> {

  final CollectionReference _fridgesCollection =
      FirebaseFirestore.instance.collection('fridges');


  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    var currentUser = args['currentUser'];
    var currentCategory = args['currentCategory'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: _fridgesCollection.doc(currentUser['fridgeId']).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('No data found'));
          } else {
            var inventory = snapshot.data!['inventory'] as List;

            List desiredCategory;
            desiredCategory = inventory.where((item) => item['category'] == currentCategory ).toList();

            return ListView.builder(
              itemCount: desiredCategory.length,
              itemBuilder: (context, index) {
                var item = desiredCategory[index];
                return ListTile(
                  leading: const Icon(Icons.kitchen), // Example leading icon
                  title: Text(item['category'] ?? 'Unknown'),
                  subtitle: Text('Added: ${item['addedDate']}'),
                );
              },
            );
          }
        },
      ),
    );
  }
}
