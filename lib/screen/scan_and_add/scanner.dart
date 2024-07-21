import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';

import 'package:rongo/utils/theme/theme.dart';
import 'package:rongo/utils/photo.dart';
import 'package:rongo/widgets/button.dart';
import 'package:rongo/widgets/item_variable_widget.dart';

import '../../utils/utils.dart';

class Scanner extends StatefulWidget {
  const Scanner({super.key});

  @override
  State<Scanner> createState() => _ScannerState();
}

class _ScannerState extends State<Scanner> {
  bool _isLoading = false;
  PhotoPicker photoPicker = PhotoPicker(imagePicker: ImagePicker());
  Map result = {};
  Uint8List? img;
  bool _isFollowUp = false;

  final model = GenerativeModel(
    model: 'gemini-1.5-flash',
    apiKey: "AIzaSyACPCSYzUuIZ96eU6rJDyf_EN551oVxxFU",
  );

  Future<GenerateContentResponse> validateImage(Uint8List image) async {
    setState(() {
      _isLoading = true;
    });
    const prompt =
        'You are helping your mom to buy groceries, you need to recognize the name of item including the brand accurately and the ingredients of the item.'
        'You have been given a photo of the item, read the name carefully and also try to spot the expiry date and ingredient table in the image if provided.'
        'Identify the name as what name it should used when displayed on the rack in the groceries store'
        'Determine the item name in the photo and decide which category are they belong to with the provided choices including Fruits, Vegetables, Meat, Fish, Condiments, Leftovers or others.'
        'All the cooked food shall be considered as leftovers'
        'If the item scanned is not a food, simply return false for the isFood column in the response and leave the column as none'
        'If no ingredient table is found, try to get the ingredients from online resources, make sure the item name matches with the ingredient table, or else just return not visible'
        'Provide your response as a JSON object with the following schema: {"isFood": true or false whether the item is a food, "Item name": name of item, "Categories": categories of item, "Ingredients": the ingredients in the ingredients table, "Expiry date": expiry date identified, return not visible if not found in photo}.'
        'Do not return your result as Markdown.';

    final response = await model.generateContent([
      Content.multi([TextPart(prompt), DataPart('image/jpeg', image)]),
    ]);
    setState(() {
      _isLoading = false;
    });
    return response;
  }

  Future<String?> _onItemFound() async {
    try {
      final image = await photoPicker.takePhoto();
      _isFollowUp = !result.isEmpty;
      final itemFound = await validateImage(image);
      final response =
          itemFound.text!.replaceAll("```json", "").replaceAll("```", "");
      Map tempResponse = json.decode(response);
      var tempResult = _isFollowUp
          ? result.map((key, value) => value == tempResponse[key]
              ? MapEntry(key, value)
              : value == "Not visible"
                  ? MapEntry(key, tempResponse[key])
                  : MapEntry(key, value))
          : tempResponse;

      setState(() {
        img = image;

        result = tempResult;
      });
    } on PhotoPickerException {
      return "error";
    }
    return null;
  }

  List<Widget> generateOutput() {
    List<Widget> variableList = variableIcon.keys
        .map((e) => ItemVariableWidget(
            output: (result[e] is String) ? result[e] : result[e].join(", "),
            title: e))
        .toList();
    variableList = <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(20)),
              child: Container(
                  height: 300,
                  width: double.infinity,
                  child: Image(
                    image: MemoryImage(img!),
                    fit: BoxFit.cover,
                  )),
            ),
          )
        ] +
        variableList +
        [
          const SizedBox(
            height: 75,
          )
        ];
    return variableList;
  }

  Column displayMessages(String text) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
            height: 200,
            width: 200,
            child: Image.asset('lib/images/scanner.png')),
        SizedBox(
          height: 50,
        ),
        Text(
          textAlign: TextAlign.center,
          text,
          style: TextStyle(fontSize: 15),
        ),
        SizedBox(
          height: 130,
        )
      ],
    );
  }

  void addToFridge() {
    showSnackBar("added to fridge", context);
  }

  Future<void> remove() async {
    bool? delete = await showBackDialog(
        "Are you sure you want to clear this item result?", context);
    setState(() {
      if (delete!) {
        result = {};
        showSnackBar("remove", context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Food Scanner"),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: _isLoading
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 100.0),
                              child: const SizedBox(
                                height: 30,
                                width: 30,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: AppTheme.mainGreen,
                                  ),
                                ),
                              ),
                            ),
                          )
                        : result.isEmpty
                            ? displayMessages(
                                "Tap on scan button to see the magic!")
                            : result["isFood"]
                                ? SingleChildScrollView(
                                    child: Column(children: generateOutput()),
                                  )
                                : displayMessages(
                                    "Item scanned is not a food!\nTry again by tapping on the scan button!"),
                  )),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 10.0, bottom: 20),
                child: result.isEmpty
                    ? CustomizedButton(
                        func: _onItemFound,
                        title: "Scan",
                      )
                    : !result["isFood"]
                        ? CustomizedButton(
                            func: _onItemFound,
                            title: "Scan",
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              CustomizedButton(
                                tooltip:
                                    "Scan again to add on details to the item",
                                func: _onItemFound,
                                title: "Scan Again",
                              ),
                              CustomizedButton(
                                tooltip: "Add to fridge",
                                func: addToFridge,
                                isRoundButton: true,
                                icon: Icons.add,
                              ),
                              CustomizedButton(
                                tooltip: "Discard this item",
                                color: Colors.redAccent,
                                func: remove,
                                isRoundButton: true,
                                icon: Icons.delete,
                              )
                            ],
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
