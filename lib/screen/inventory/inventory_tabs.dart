import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../utils/utils.dart';
import '../../utils/theme/theme.dart';
import 'inventory_category.dart';
import 'inventory_listview.dart';

class InventoryTabs extends StatefulWidget {
  final InventoryFilter inventoryFilter;
  final String fridgeId;

  const InventoryTabs({super.key,required this.inventoryFilter,required this.fridgeId});

  @override
  State<InventoryTabs> createState() => _InventoryTabsState();
}

class _InventoryTabsState extends State<InventoryTabs> {
  @override
  Widget build(BuildContext context) {

    return DefaultTabController(
      initialIndex: widget.inventoryFilter.index,
      length: InventoryFilter.values.length,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.transparent,
          leading: Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back),
            ),
          ),
          title: Text("Your fridge", style: AppTheme.blackAppBarText),
          bottom: TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: InventoryFilter.total.displayName),
              Tab(text: InventoryFilter.newAdded.displayName),
              Tab(text: InventoryFilter.expiredSoon.displayName),
              Tab(text: InventoryFilter.expired.displayName),
            ],
          ),
        ),
        body: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('fridges')
              .doc(widget.fridgeId)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (!snapshot.hasData) {
              return const Center(
                  child: Text('Fridge DocumentID does not exist'));
            }

            final data = snapshot.data!.data() as Map<String, dynamic>;
            final List inventory = data['inventory'];

            return TabBarView(
              children: [
                InventoryCategory(
                    inventory: inventory,
                    fridgeId: widget.fridgeId,
                    inventoryFilter: InventoryFilter.total),
                InventoryListview(
                    inventory: inventory,
                    fridgeId: widget.fridgeId,
                    inventoryFilter: InventoryFilter.newAdded),
                InventoryListview(
                    inventory: inventory,
                    fridgeId: widget.fridgeId,
                    inventoryFilter: InventoryFilter.expiredSoon),
                InventoryListview(
                    inventory: inventory,
                    fridgeId: widget.fridgeId,
                    inventoryFilter: InventoryFilter.expired),
              ],
            );
          },
        ),
      ),
    );
  }
}
