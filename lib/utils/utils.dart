import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Map<String, IconData> variableIcon = {
  "Item name": Icons.image_rounded,
  "Categories": Icons.category_rounded,
  "Ingredients": Icons.incomplete_circle_rounded,
  "Expiry date": Icons.timelapse_rounded ,
  "Storage method": Icons.food_bank_rounded,
  "Freshness": Icons.browse_gallery_rounded,
  "Allergens": Icons.sick,
  "Halal" : Icons.restaurant,
};

List cats = ["Fruits", "Vegetables", "Meat", "Fish", "Condiments", "Leftovers", "Others"];

showSnackBar(String message, context) {
  final snackbar = SnackBar(
    content: Text(message),
    duration: Duration(seconds: 1),
  );
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(snackbar);
}

Future<bool?> showBackDialog(String confirmation, context) async {
  bool item = confirmation.contains("item");
  bool? delete = false;
  delete = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Are you sure?'),
        content: Text(
          confirmation,
        ),
        actions: <Widget>[
          TextButton(
            style: TextButton.styleFrom(
              textStyle: Theme.of(context).textTheme.labelLarge,
            ),
            child: const Text('Nevermind'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          TextButton(
            style: TextButton.styleFrom(
              textStyle: Theme.of(context).textTheme.labelLarge,
            ),
            child: Text(item ? 'Discard' : 'Leave'),
            onPressed: () {
              if (confirmation == 'Are you sure you want to leave the app?') {
                SystemNavigator.pop();
              } else if (item) {
                var value = true;
                Navigator.pop(context, value);

              } else {
                Navigator.pop(context);
                Navigator.pop(context);
              }
            },
          ),
        ],
      );
    },

  );
  return delete;


}
