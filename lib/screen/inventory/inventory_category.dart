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
  late var currentUser;


  @override
  Widget build(BuildContext context) {

    currentUser = ModalRoute.of(context)!.settings.arguments; // Need Fridge ID
    print("HI2222");
    print(currentUser);
    print(currentUser.runtimeType);


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
          title: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Your fridge", style: AppTheme.blackAppBarText),
              ],
            ),
          ),
        ),
        body: SafeArea(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // Number of columns
              childAspectRatio: 1.0, // Aspect ratio of the items
            ),
            itemCount: InventoryCategories.values.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.all(16.0),
                child: GestureDetector(
                  onTap: (() {
                    Navigator.pushNamed(
                      context,
                      '/inventory-listview',
                      arguments: {
                        'currentUser': currentUser,
                        'currentCategory':
                            InventoryCategories.values[index].name,
                      },
                    );
                  }),
                  child: SquareContainer(
                    backgroundColor: AppTheme.lighterGreen,
                    height: 130,
                    width: 130,
                    roundedCorner: 25,
                    child: Center(
                      child: Text(
                        InventoryCategories.values[index].name,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ));
  }
}
