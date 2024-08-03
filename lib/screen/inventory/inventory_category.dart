import 'package:flutter/material.dart';
import 'package:rongo/routes.dart';
import '../../utils/utils.dart';
import '../../widgets/containers.dart';
import '../home/homepage.dart';
import '../../utils/theme/theme.dart';

class InventoryCategory extends StatefulWidget {
  final currentUser;

  const InventoryCategory({super.key, this.currentUser});

  @override
  State<InventoryCategory> createState() => _InventoryCategoryState();
}

class _InventoryCategoryState extends State<InventoryCategory> {
  late var inventory;

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    List inventory = args['inventory'];
    var type = args['type'];



    return Scaffold(
        appBar: AppBar(
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
        ),
        body: SafeArea(
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
                  padding: EdgeInsets.all(10.0),
                  child: GestureDetector(
                    onTap: (() {
                      Navigator.pushNamed(
                        context,
                        '/inventory-listview',
                        arguments: {
                          'inventory': inventory,
                          'type': type,
                          'currentCategory':
                              InventoryCategories.values[index].name,
                        },
                      );
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
                           style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
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
        ));
  }
}
