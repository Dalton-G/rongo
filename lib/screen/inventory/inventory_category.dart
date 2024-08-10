import 'package:flutter/material.dart';
import '../../utils/theme/theme.dart';
import '../../utils/utils.dart';
import 'inventory_listview.dart';

class InventoryCategory extends StatelessWidget {
  final List? inventory;
  final InventoryFilter? inventoryFilter;
  final String? fridgeId;

  const InventoryCategory({super.key,this.inventory,this.inventoryFilter,this.fridgeId});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Number of columns
            childAspectRatio: 1, // Aspect ratio of the items
          ),
          itemCount: InventoryCategories.values.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.all(10.0),
              child: GestureDetector(
                onTap: (() {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => InventoryListview(
                                inventory: inventory,
                                fridgeId: fridgeId,
                                inventoryFilter: InventoryFilter.total,
                                currentCategory:
                                    InventoryCategories.values[index].name,
                              )));
                }),
                child: Container(
                  decoration: AppTheme.widgetDeco(),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 15.0),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: Image.asset(
                            "lib/images/${InventoryCategories.values[index].name.toLowerCase()}.png",
                            height: 80,
                          ),
                        ),
                        Text(
                          InventoryCategories.values[index].name,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
