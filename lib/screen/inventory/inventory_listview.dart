import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../resources/CRUD/fridge.dart';
import '../../utils/theme/theme.dart';
import '../../utils/utils.dart';
import 'edit_quantity.dart';
import '../home/homepage.dart';

class InventoryListview extends StatefulWidget {
  const InventoryListview({super.key});

  @override
  _InventoryListviewState createState() => _InventoryListviewState();
}

class _InventoryListviewState extends State<InventoryListview> {
  int _counter = 0;
  bool recording = false;

  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _speechText = 'Press the button and start speaking';
  double _confidence = 1.0;
  bool _showCancelSpeech = false;
  bool _isCancelSpeech = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }


  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    List inventory = args['inventory'];
    String fridgeId = args['fridgeId'];
    var currentCategory = args['currentCategory'];
    var type = args['type'];
    List? desiredCategory = [];
    String? nullPrompting;
    bool inventoryListNotEmpty = false;

    switch (type){
      case 'total':
        desiredCategory =
            inventory.where((item) => item['category'] == currentCategory).toList();
        nullPrompting = "Fridge's empty—time to restock!\n A full fridge uses less energy.";
        break;

      case 'new':
        desiredCategory = inventory;
        nullPrompting = "Fridge's empty—time to restock!\n A full fridge uses less energy.";
        break;

      case 'soon':
        desiredCategory = inventory;
        nullPrompting = "No nearly expired food! Your fridge is fresh.";
        break;

      case 'expired':
        desiredCategory = inventory;
        nullPrompting = "No food wasted? You're a food hero!";
        break;

    }

    return Scaffold(
        appBar: AppBar(
          title: const Text('Inventory'),
        ),

        body: Stack(children: [
          desiredCategory!.isNotEmpty
              ? ListView.builder(
                  itemCount: desiredCategory!.length + 1,
                  itemBuilder: (context, index) {
                    if (index == (desiredCategory!.length)) {
                      if (inventoryListNotEmpty) {
                        return const AddItemWidget();
                      } else {
                        return AddItemWidgetWithPrompt(
                            nullPrompting: nullPrompting!);
                      }
                    }

                    var item = desiredCategory?[index];
                    DateFormat format = DateFormat("yyyy-MM-dd");
                    DateTime addDate = format.parse(item['addedDate']);
                    DateTime? expiryDate;
                    if (item['expiryDate'] != null) {
                      expiryDate = DateTime.parse(item['expiryDate']);
                    }

                    if (item['currentQuantity'] <= 0) {
                      return const SizedBox(
                        width: 1,
                      );
                    }

                    if (item['currentQuantity'] > 0) {
                      inventoryListNotEmpty = true;
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 10),
                      child: Slidable(
                        endActionPane: ActionPane(
                          motion: DrawerMotion(),
                          children: [
                            SlidableAction(
                              onPressed: (context) {
                                setState(() {
                                  item['currentQuantity'] = 0;
                                  updateInventoryItem(
                                      fridgeId, item['addedDate'], item);
                                  showSnackBar(
                                      "Consumption Updated Successfully. No more ${item['name']}.",
                                      context);
                                });
                              },
                              icon: Icons.delete,
                              foregroundColor: Colors.redAccent,
                              backgroundColor: Colors.transparent,
                            ),
                          ],
                        ),
                        child: GestureDetector(
                          onTap: (() {
                            _showSaveDeleteDialog(context, item, fridgeId,
                                item['currentQuantity'], item['name']);
                          }),
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
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Text(
                                            item['name'] ?? 'Unknown',
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600),
                                          ),
                                          SizedBox(
                                            height: 8,
                                          ),
                                          expiryDate == null?
                                          Text(
                                            'Added: ${DateFormat("d MMM y (E)").format(addDate)}\n'
                                                'Expiry: - ',
                                            style: const TextStyle(
                                                fontSize: 11, height: 2),
                                          ):
                                          Text(
                                            'Added: ${DateFormat("d MMM y (E)").format(addDate)}\n'
                                            'Expiry: ${DateFormat("d MMM y (E)").format(expiryDate)}',
                                            style: const TextStyle(
                                                fontSize: 11, height: 2),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        "x${item['currentQuantity']}",
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                )
              : AddItemWidgetWithPrompt(nullPrompting: nullPrompting!),

          /// Speech Button
          Positioned(
            right: 20,
            bottom: 20,
            child: GestureDetector(
                onTap: (() async {
                  showSnackBar("Press and Hold to use Rongie voice assistant.", context);

                  // showDialog(
                  //   context: context,
                  //   builder: (BuildContext context) {
                  //     return Dialog(
                  //       child: SpeechScreen(),
                  //     );
                  //   },
                  // );
                }),

                onLongPress: (() async {
                  showSnackBar("Recording.", context, durationSeconds: 10);
                  _startListening();
                }),


                onLongPressUp: (() async {
                  if (!_isCancelSpeech){
                    showSnackBar("Finished Recording.", context);
                    _stopListening();

                    //TODO: Call gemini
                    showSnackBar(_speechText, context);

                  }

                  setState(() {
                    _isCancelSpeech = false;
                  });
                }),


                onLongPressMoveUpdate: ((longPressMoveUpdateDetails_) {
                  /// Show Delete location
                  if (longPressMoveUpdateDetails_.localOffsetFromOrigin !=
                      const Offset(0, 0)) {
                    if (_isCancelSpeech != true) {
                      setState(() {
                        _showCancelSpeech = true;
                      });
                    }
                  }

                  /// Cancel Speech to text without calling gemini
                  if (longPressMoveUpdateDetails_.localOffsetFromOrigin <
                      const Offset(100, -180)) {
                    setState(() {
                      if (_isCancelSpeech == false) {
                        showSnackBar("Cancel Rongie assistant", context,
                            durationSeconds: 3);
                      }
                      _isCancelSpeech = true;
                      _showCancelSpeech = false;
                      _stopListening();
                    });
                  }
                }),

                child: Container(
                  decoration: AppTheme.widgetDeco(color: Colors.white),
                  child:
                      const Icon(size: 100, Icons.fiber_manual_record_outlined),
                )),
          ),


          /// Speech Text Display Area
          if (_isListening)
            Positioned(
              bottom: 100,
              width: MediaQuery.of(context).size.width,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Container(
                  decoration: AppTheme.widgetDeco(),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        _speechText,
                        style: const TextStyle(fontSize: 22.0),
                      ),
                      // Text(
                      //   'Confidence: ${(_confidence * 100.0).toStringAsFixed(1)}%',
                      //   style: TextStyle(fontSize: 14.0),
                      // ),
                    ],
                  ),
                ),
              ),
            ),

          if(_showCancelSpeech)
          Positioned(
              bottom: 150,
              right: 55,
              child: Column(
                children: [
                  Icon(Icons.delete_forever),
                  SizedBox(
                    height: 5,
                  ),
                  Icon(Icons.arrow_drop_up_rounded,color: AppTheme.mainGreen.withAlpha(30),),
                  Icon(Icons.arrow_drop_up_rounded,color: AppTheme.mainGreen.withAlpha(60),),
                  Icon(Icons.arrow_drop_up_rounded,color: AppTheme.mainGreen.withAlpha(120),),
                  Icon(Icons.arrow_drop_up_rounded,color: AppTheme.mainGreen.withAlpha(180),),
                  Icon(Icons.arrow_drop_up_rounded,color: AppTheme.mainGreen.withAlpha(250),),
                ],
              ))
        ]));
  }


  void _showSaveDeleteDialog(BuildContext context, item, fridgeId, int currentQuantity, String name) {
    showDialog(
      context: context,
      builder: (BuildContext context) {

        return AlertDialog(
          title: const Text('Modify Quantity'),
          content: CounterWidget(
            onCounterChanged: (int newCounter) {
              setState(() {
                _counter = newCounter;
              });
            }, currentQuantity: currentQuantity, name: name,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                item['currentQuantity'] = _counter;
                updateInventoryItem(fridgeId,item['addedDate'],item);
                item['currentQuantity'] == 0 ?
                showSnackBar("Consumption Updated Successfully. No more ${item['name']}.",context)
                    :showSnackBar("Consumption Updated Successfully. ${item['currentQuantity']} ${item['name']} left.",context);
              },
              child: Text('Save'),
            ),
            // TextButton(
            //   onPressed: () {
            //     Navigator.of(context).pop();
            //     // Add your delete functionality here
            //     print('Delete Item button pressed');
            //   },
            //   child: Text('Delete Item'),
            // ),
          ],
        );
      },
    );
  }

  void _startListening() async {
    bool available = await _speech.initialize(
      onStatus: (val) => print('onStatus: $val'),
      onError: (val) => print('onError: $val'),
    );
    if (available) {
      setState(() => _isListening = true);
      _speech.listen(
        onResult: (val) => setState(() {
          _speechText = val.recognizedWords;
          if (val.hasConfidenceRating && val.confidence > 0) {
            _confidence = val.confidence;
          }
        }),
      );
    }
  }

  void _stopListening() {
    setState(() => _isListening = false);
    _speech.stop();
  }

}

class AddItemWidget extends StatelessWidget {
  const AddItemWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
      const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
      child: GestureDetector(
        onTap: ((){
          Navigator.popUntil(context, ModalRoute.withName('/homepage'));
          Provider.of<IndexProvider>(context, listen: false).setSelectedIndex(3);
        }),
        child: Container(
          decoration: AppTheme.widgetDeco(),
          padding: EdgeInsets.all(15),
          child: const SizedBox(
            height: 80,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_outlined),
                Text("Add new item")
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AddItemWidgetWithPrompt extends StatelessWidget {
  final String nullPrompting;

  const AddItemWidgetWithPrompt({super.key, required this.nullPrompting});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const AddItemWidget(),
        Padding(
          padding: EdgeInsets.only(top: (MediaQuery.of(context).size.height * 0.48) - 135),
          child: Center(child: Text(nullPrompting??"")),
        ),
      ],
    );
  }
}

