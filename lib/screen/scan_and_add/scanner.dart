import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'package:keyboard_detection/keyboard_detection.dart';
import 'package:provider/provider.dart';
import 'package:rongo/model/item.dart';
import 'package:rongo/provider/Item_provider.dart';
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
  late KeyboardDetectionController _keyboardDetectionController;
  bool _keyboard = false;
  List<TextEditingController> _controller =
      variableIcon.keys.map((key) => TextEditingController()).toList();

  final model = GenerativeModel(
    model: 'gemini-1.5-flash-001',
    apiKey: dotenv.env['GEMINI_API_KEY']!,
  );

  Future<GenerateContentResponse> validateImage(Uint8List image) async {
    setState(() {
      _isLoading = true;
    });
    const prompt =
        'You are helping your mom to buy groceries, you need to recognize the name of item including the brand accurately and the ingredients of the item.'
        'You have been given a photo of the item, read the name carefully and also try to spot the expiry date and ingredient table in the image if provided.'
        'Identify the name as what name it should used when displayed on the rack in the groceries store'
        'Determine the item name in the photo and decide which category are they belong to with the provided choices including Fruits, Vegetables, Meat, Fish, Condiments, Leftovers or Others.'
        'All the cooked food shall be considered as leftovers'
        'If the item scanned is not a food, simply return false for the isFood column in the response and leave the other columns as none'
        'If no ingredient table is found, try to get the ingredients from online resources, make sure the item name matches with the ingredient table, or else just return "Not visible"'
        'If the food is vegetable or fruits, identify how many days can the food be kept to be consumed safely, the return the expected expiry date'
        'Also recommend storage method to keep the food fresh for longer time.'
        'Recommend the possible allergens in the food and whether the food is halal to make sure people eat carefully'
        '**For allergens and halal, if you cannot find the information, use "Unknown" as the value.**'
        'Provide your response as a JSON object with the following keys: {"isFood": bool , "Item name": string, "Categories": string, "Ingredients": List of strings, "Expiry date": string(DD/MM/YYYY) or string(days to keep), "Storage method": string, "Allergens": List of strings, "Halal": String}.'
        'Do not return your result as Markdown.';
    // 'You are helping your mom to buy groceries, you need to recognize the name of item including the brand accurately and the ingredients of the item.'
    // 'You have been given a photo of the item, read the name carefully and also try to spot the expiry date and ingredient table in the image if provided.'
    // 'Identify the name as what name it should used when displayed on the rack in the groceries store'
    // 'Determine the item name in the photo and decide which category are they belong to with the provided choices including Fruits, Vegetables, Meat, Fish, Condiments, Leftovers or others.'
    // 'All the cooked food shall be considered as leftovers'
    // 'If the item scanned is not a food, simply return false for the isFood column in the response and leave the other columns as none'
    // 'If no ingredient table is found, try to get the ingredients from online resources, make sure the item name matches with the ingredient table, or else just return "Not visible"'
    // 'If the food is vegetable or fruits, identify how many days can the food be kept to be consumed safely, so instead of expiry date return the days'
    // 'Also recommend storage method to keep the food fresh for longer time.'
    // 'Recommend the possible allergens in the food and whether the food is halal to make sure people eat carefully'
    //
    // 'Provide your response as a JSON object with the following keys: {"isFood": bool , "Item name": string, "Categories": string, "Ingredients": List of strings, "Expiry date": string(DD/MM/YYYY) or string(days to keep), "Storage method": string, "Allergens": List of strings, "Halal": String}.'
    // 'Do not return not visible for allergens and halal.'
    // 'Do not return your result as Markdown.';

    final response = await model.generateContent([
      Content.multi([TextPart(prompt), DataPart('image/jpeg', image)]),
    ]);
    setState(() {
      _isLoading = false;
    });
    print(
        "=========================================================================================");
    print(response.text);
    print(
        "=========================================================================================");

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
    List variableKeys =
        result.keys.where((element) => element != "isFood").toList();
    List<Widget> variableList = variableKeys
        .map((e) => ItemVariableWidget(
            controller: _controller[variableKeys.indexWhere((key) => key == e)],
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
    setState(() {
      List<String> keys = variableIcon.keys.toList();
      Provider.of<ItemProvider>(context, listen: false).addItem(Item(
          name: result[keys[0]],
          category: result[keys[1]],
          ingredients: result[keys[2]],
          expiryDate: result[keys[3]],
          storageMethod: result[keys[4]],
          allergen: result[keys[5]],
          halal: result[keys[6]]));
      result = {};
    });
    showSnackBar("added to list", context);
  }

  Future<void> remove() async {
    bool? delete = await showBackDialog(
        "Are you sure you want to clear this item result?", context, close: true);
    setState(() {
      if (delete!) {
        result = {};
        showSnackBar("remove", context);
      }
    });
  }

  Future<void> receipt() async {
    bool? move = await showBackDialog("Done scanning all the item?", context,
        yes: "Yes", no: "No", close: true);
    print(move);
    setState(() {
      if (move!) {
        Navigator.pushNamed(context, '/scanned-item-list');
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _keyboardDetectionController = KeyboardDetectionController(
      onChanged: (value) {
        setState(() {
          _keyboard = _keyboardDetectionController.stateAsBool()!;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) {
        if (didPop) {
          return;
        }
        showBackDialog('Discard record and leave?', context, close: true);
      },
      child: KeyboardDetection(
        controller: _keyboardDetectionController,
        child: Scaffold(
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
                                : result["isFood"] == true
                                    ? SingleChildScrollView(
                                        child:
                                            Column(children: generateOutput()),
                                      )
                                    : displayMessages(
                                        "Item scanned is not a food!\nTry again by tapping on the scan button!"),
                      )),
                ),
                Visibility(
                  visible: !_keyboard,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10.0, bottom: 100),
                      child: result.isEmpty
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                CustomizedButton(
                                  func: _onItemFound,
                                  title: "Scan",
                                ),
                                CustomizedButton(
                                  isRoundButton: true,
                                  func: receipt,
                                  icon: Icons.receipt_long_rounded,
                                )
                              ],
                            )
                          : !result["isFood"]
                              ? CustomizedButton(
                                  func: _onItemFound,
                                  title: "Scan",
                                )
                              : Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      CustomizedButton(
                                        width: 150,
                                        tooltip:
                                            "Scan again to add on details to the item",
                                        func: _onItemFound,
                                        title: "Scan Again",
                                      ),
                                      CustomizedButton(
                                        tooltip: "Add to list",
                                        func: addToFridge,
                                        isRoundButton: true,
                                        icon: Icons.add,
                                      ),
                                      CustomizedButton(
                                        tooltip:
                                            "Scan receipt / add list to fridge",
                                        func: receipt,
                                        isRoundButton: true,
                                        icon: Icons.receipt_long_rounded,
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
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
