import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:rongo/utils/theme/theme.dart';

import '../utils/utils.dart';

class ItemVariableWidget extends StatefulWidget {
  final String output;
  final String title;
  final TextEditingController controller;

  const ItemVariableWidget(
      {super.key, required this.output, required this.title, required this.controller});

  @override
  State<ItemVariableWidget> createState() => _ItemVariableWidgetState();
}

class _ItemVariableWidgetState extends State<ItemVariableWidget> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    widget.controller.text = toBeginningOfSentenceCase(widget.output);

    _selectedIndex = InventoryCategories.values.indexWhere((e) => e.name == widget.output);

  }

  void undo() {
    widget.controller.text = widget.output;
    setState(() {

    });
  }

  void selectCat() {
    showModalBottomSheet(
        context: context,
        builder: (context) => StatefulBuilder(
              builder: (BuildContext context,
                      StateSetter setModalState /*You can rename this!*/) =>
                  Container(
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: ListView.builder(

                          itemCount: InventoryCategories.values.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                setState(() {

                                  _selectedIndex = index;
                                  widget.controller.text = InventoryCategories.values[index].name;
                                  print(_selectedIndex);
                                  setModalState(() {});
                                });
                              },
                              child: ListTile(
                                title: Text(
                                  InventoryCategories.values[index].name,
                                  style: TextStyle(
                                    color: index == _selectedIndex
                                        ? AppTheme.mainGreen
                                        : Colors.black,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      )),
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 20, 8, 0),
      child: GestureDetector(
        onTap: widget.title == "Categories"
            ? selectCat
            : widget.title == "Expiry date"
                ? () {
                    showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2050),
                    ).then((value) => setState(() {
                      widget.controller.text = DateFormat("d MMM y").format(
                              DateTime(value!.year, value.month, value.day));
                        }));
                  }
                : () {},
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 17, horizontal: 20),
          decoration: AppTheme.widgetDeco(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                variableIcon[widget.title],
                color: AppTheme.mainGreen,
              ),
              SizedBox(
                width: 20,
              ),
              Flexible(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.title, style: TextStyle(fontSize: 12)),
                    SizedBox(
                      height: 7,
                    ),
                    (widget.title == "Categories" ||
                            widget.title == "Expiry date")
                        ? Container(
                            width: double.infinity,
                            child: Text(
                              widget.controller.text,
                              style: TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15),
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: TextField(
                              onChanged: (text){setState(() {

                              });},
                              onTapOutside: (event) {
                                print('onTapOutside');
                                FocusManager.instance.primaryFocus?.unfocus();
                              },
                              maxLines: null,
                              controller: widget.controller,
                              decoration: null,
                              style: TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15),
                            ),
                          )
                  ],
                ),
              ),
              Visibility(
                visible: widget.controller.text != widget.output,
                child: GestureDetector(
                  onTap: undo,
                    child: Icon(
                  Icons.undo,
                  color: Colors.grey,
                )),
              )
            ],
          ),
        ),
      ),
    );
  }
}
