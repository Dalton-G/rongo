import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rongo/utils/photo.dart';

Map<String, IconData> variableIcon = {
  "Item name": Icons.image_rounded,
  "Categories": Icons.category_rounded,
  "Ingredients": Icons.incomplete_circle_rounded,
  "Expiry date": Icons.timelapse_rounded,
  "Storage method": Icons.food_bank_rounded,
  "Allergens": Icons.sick,
  "Halal": Icons.restaurant,
};

enum cats { Fruits, Vegetables, Meat, Fish, Condiments, Leftovers, Others }

final model = GenerativeModel(
  model: 'gemini-1.5-flash-001',
  apiKey: dotenv.env['GEMINI_API_KEY']!,
);

final PhotoPicker photoPicker = PhotoPicker(imagePicker: ImagePicker());

showSnackBar(String message, context) {
  final snackbar = SnackBar(
    content: Text(message),
    duration: Duration(seconds: 1),
  );
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(snackbar);
}

Future<bool> showBackDialog(String confirmation, context, {yes = "Leave", no = "Nevermind", close = true}) async {
  Completer<bool> completer = Completer<bool>();

  showDialog(
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
            child: Text(no),
            onPressed: () {
              Navigator.pop(context);
              completer.complete(false);
            },
          ),
          TextButton(
            style: TextButton.styleFrom(
              textStyle: Theme.of(context).textTheme.labelLarge,
            ),
            child: Text(yes),
            onPressed: () {
              if (confirmation == 'Are you sure you want to leave the app?') {
                SystemNavigator.pop();
              } else if (close) {
                Navigator.pop(context);
                completer.complete(true);
              } else {
                Navigator.pop(context);
                completer.complete(false);
              }
            },
          ),
        ],
      );
    },
  );

  return completer.future;
}
