import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:google_generative_ai/google_generative_ai.dart';

import '../../resources/CRUD/fridge.dart';
import '../../utils/theme/theme.dart';
import '../../utils/utils.dart';
import 'modify_quantity.dart';
import '../home/homepage.dart';

class InventoryListview extends StatefulWidget {
  final List? inventory;
  final InventoryFilter? inventoryFilter;
  final String? fridgeId;
  final String? currentCategory;

  const InventoryListview({super.key,this.inventory,this.inventoryFilter,this.fridgeId, this.currentCategory});

  @override
  _InventoryListviewState createState() => _InventoryListviewState();
}

class _InventoryListviewState extends State<InventoryListview> {
  int _counter = 0;
  bool recording = false;
  int editingWidgetIndex = -1;

  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _speechText = 'Press the button and start speaking';
  double _confidence = 1.0;
  bool _showCancelSpeech = false;
  bool _isCancelSpeech = false;
  bool _speechAvailable = false;
  bool _geminiResponse = false;
  List _geminiModificationList = [];

  get inventoryFilter => widget.inventoryFilter;
  get fridgeId => widget.fridgeId;
  get inventory => widget.inventory;
  get currentCategory => widget.currentCategory;

  @override
  void initState() {
    // TODO: implement initState
    _askSpeechPermission();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    List? desiredCategory = [];
    String? nullPrompting;
    bool inventoryListNotEmpty = false;
    bool needAppBar = false;

    DateTime now = DateTime.now();

    switch (inventoryFilter){
      case InventoryFilter.total:
        desiredCategory =
            inventory.where((item) => item['category'] == currentCategory).toList();
        nullPrompting = "Fridge's empty—time to restock!\n A full fridge uses less energy.";
        needAppBar = true;
        break;

      case InventoryFilter.newAdded:
        desiredCategory = inventory
            .where(
                (item) => DateFormat("yM").format(DateTime.parse(item['addedDate'])) == DateFormat("yM").format(now)
            )
            .toList();
        nullPrompting = "Fridge's empty—time to restock!\n A full fridge uses less energy.";
        break;

      case InventoryFilter.expiredSoon:
        for (var item in inventory){
          if (item['expiryDate']!=null) {
            if (DateTime.parse(item['expiryDate']).isAfter(now) &&
                DateTime.parse(item['expiryDate']).isBefore(now.add(const Duration(days: 7)))) {
              desiredCategory.add(item);
            }
          }
        }
        nullPrompting = "No nearly expired food! Your fridge is fresh.";
        break;

      case InventoryFilter.expired:
        for (var item in inventory){
          if (item['expiryDate']!=null) {
            if (DateTime.parse(item['expiryDate']).isBefore(now)) {
              desiredCategory.add(item);
            }
          }
        }
        nullPrompting = "No food wasted? You're a food hero!";
        break;
    }

    return SafeArea(
      child: Scaffold(
          appBar: needAppBar?AppBar(
            title: const Text('your fridge'),
          ):null,

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
                            motion: const DrawerMotion(),
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
                              _showModifyQuantityDialog(context, item, fridgeId,);
                            }),
                            child: Container(
                              decoration: AppTheme.widgetDeco(),
                              padding: const EdgeInsets.all(15),
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
                                  const SizedBox(
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
                                            SizedBox(
                                              width: MediaQuery.of(context).size.width - 230,
                                              child: Text(
                                                item['name'] ?? 'Unknown',
                                                style: const TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w600),
                                              ),
                                            ),
                                            const SizedBox(
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
                    setState(() async {
                      showSnackBar("Press and Hold to use Rongie voice assistant.", context);
                      if (!_speechAvailable) {
                        await _askSpeechPermission();
                      }
                    });
                  }),

                  onLongPress: (() {

                    if (_speechAvailable){
                      setState(() {
                        showSnackBar("Recording.", context);
                        _startListening();
                      });
                    }
                    else{
                      _askSpeechPermission();
                    }
                  }),

                  onLongPressUp: (() async {
                    if (_speechAvailable) {
                      /// Not calling Gemini if Use cancel (swipe up)
                      if (_isCancelSpeech) {
                        setState(() {
                          _isCancelSpeech = false;
                          _showCancelSpeech = false;
                        });
                      }
                      /// Call Gemini
                      else{
                        setState(() async {
                          _isCancelSpeech = false;
                          _showCancelSpeech = false;
                          showSnackBar("Finished Recording.", context);
                          _stopListening();

                          final systemPrompt =
                              ' Given this list of item: $inventory.'
                              ' Then, given this user prompt about what he consumed: $_speechText.'
                              ' You need to match the user prompt given with the list of item, and identify which item in list he has consumed and the quantity he has consumed.'
                              ' Return only the item you think that most relevant, and return only the same json Map (Map in list) format you received with field "name","addedDate","currentQuantity" (Quantity before consumed), and addition field "consumptionQuantity" (Quantity has been consumed by user), and "afterConsumptionQuantity" (Quantity after consumed, min value is 0, negative value not allowed).'
                              ' If there is similar product, return it in List of maps.'
                              ' User might suddenly notice some unconsumed item, therefore adding item quantity is allowed, you have to identify if item are consumed or increase inventory quantity.';
                          var response = await model
                              .generateContent([Content.text(systemPrompt)]);
                          final match = extractJsonContent.firstMatch(response.text!);

                          if (match != null) {
                            final jsonContent = match.group(1)?.trim();
                            final List<dynamic> jsonResponse = jsonDecode(jsonContent!);
                            final List<Map<String, dynamic>> items = jsonResponse.cast<Map<String, dynamic>>();

                            if (items.isNotEmpty) {
                              setState(() {
                                _geminiResponse = true;
                                _geminiModificationList = items;
                              });
                            }
                            else{
                              showSnackBar("The item you mentioned doesn't seems to be exist in your fridge.", context);
                            }
                          } else {
                            print('No JSON content found.');
                            showSnackBar("Rongie don't know what you have said. Please try again..", context);

                          }
                        });
                      }
                    }
                  }),
                  onLongPressMoveUpdate: ((longPressMoveUpdateDetails_) {
                    if(_speechAvailable)
                    {
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
                          if (_isCancelSpeech == false) {
                            setState(() {
                              showSnackBar("Cancel Rongie assistant", context);
                              _isCancelSpeech = true;
                              _showCancelSpeech = false;
                              _stopListening();
                            });

                          }
                      }
                    }
                  }),

                  child: Container(
                    decoration: AppTheme.widgetDeco(color: Colors.white),
                    child:
                        const Icon(size: 80, Icons.fiber_manual_record_outlined),
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

            /// Show cancel speech garbage bin
            if(_showCancelSpeech)
            Positioned(
                bottom: 150,
                right: 55,
                child: Column(
                  children: [
                    const Icon(Icons.delete_forever),
                    const SizedBox(
                      height: 5,
                    ),
                    Icon(Icons.arrow_drop_up_rounded,color: AppTheme.mainGreen.withAlpha(30),),
                    Icon(Icons.arrow_drop_up_rounded,color: AppTheme.mainGreen.withAlpha(60),),
                    Icon(Icons.arrow_drop_up_rounded,color: AppTheme.mainGreen.withAlpha(120),),
                    Icon(Icons.arrow_drop_up_rounded,color: AppTheme.mainGreen.withAlpha(180),),
                    Icon(Icons.arrow_drop_up_rounded,color: AppTheme.mainGreen.withAlpha(250),),
                  ],
                  )),

            /// Display dialog for user to confirm gemini modification
            if (_geminiResponse && _geminiModificationList.isNotEmpty)
              AlertDialog(
                title: const Text('Confirm Gemini modification'),
                content: SizedBox(
                  width: double.maxFinite,
                  child: ListView.builder(
                    itemCount: _geminiModificationList.length,
                    // number of items in the list
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: ((){
                          setState(() {
                            editingWidgetIndex = index;
                          });
                        }),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text("${_geminiModificationList[index]['name']} : "),
                            Text("${_geminiModificationList[index]['currentQuantity']}"),
                            const Icon(Icons.arrow_forward,),
                            editingWidgetIndex == index?
                            ModifyQuantity(
                              currentQuantity: _geminiModificationList[index]
                                      ['afterConsumptionQuantity'],
                              name: _geminiModificationList[index]['name'],
                              onQuantityChanged: (int newCounter) {
                                setState(() {
                                  _geminiModificationList[index]
                                      ['afterConsumptionQuantity'] = newCounter;
                                });
                              },
                            ):
                            Text("${_geminiModificationList[index]
                                ['afterConsumptionQuantity']}"),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      setState(() async {
                        // Close Dialog
                        _geminiResponse = false;
                        for (var geminiItem in _geminiModificationList) {
                          int index = inventory.indexWhere((item) =>
                              item['addedDate'] == geminiItem['addedDate']);
                          inventory[index]['currentQuantity'] = geminiItem['afterConsumptionQuantity'];
                          await updateInventoryItem(fridgeId, geminiItem['addedDate'],
                              inventory[index]);
                        }
                        showSnackBar("Consumption Updated Successfully.",context);
                      });
                    },
                    child: const Text('Save'),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        // Close Dialog
                        _geminiResponse = false;
                        showSnackBar("Canceled Update Consumption.",context);
                      });
                    },
                    child: const Text('Cancel'),
                  ),
                ],
              ),
          ])),
    );
  }

  void _showModifyQuantityDialog(BuildContext context, item, fridgeId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {

        return AlertDialog(
          title: const Text('Modify Quantity'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("How many ${item['name']} left after comsumed."),
              const SizedBox(
                height: 30,
              ),
              ModifyQuantity(
                onQuantityChanged: (int newQuantity) {
                  setState(() {
                    _counter = newQuantity;
                  });
                }, currentQuantity: item['currentQuantity'], name: item['name'],
              ),
            ],
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
              child: const Text('Save'),
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

  Future<void> _askSpeechPermission() async {
    if (!_speechAvailable){
      _speechAvailable = await _speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
      );
    }
  }

  void _startListening() {

    if (_speechAvailable) {
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
      padding: const EdgeInsets.only(bottom: 40),
      child: Padding(
        padding:
        const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
        child: GestureDetector(
          onTap: ((){
            Navigator.popUntil(context, ModalRoute.withName('/homepage'));
            Provider.of<IndexProvider>(context, listen: false).setSelectedIndex(3);
          }),
          child: Container(
            decoration: AppTheme.widgetDeco(),
            padding: const EdgeInsets.all(15),
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

