import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ModifyQuantity extends StatefulWidget {
  int currentQuantity;
  String name;

  var onQuantityChanged;

  @override
  _ModifyQuantityState createState() => _ModifyQuantityState();

  ModifyQuantity(
      {super.key,
      required this.currentQuantity,
      required this.name,
      required this.onQuantityChanged});
}

class _ModifyQuantityState extends State<ModifyQuantity> {
  late int _counter;

  @override
  void initState() {
    super.initState();
    _counter =
        widget.currentQuantity; // Initialize _counter with currentQuantity
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
      widget.onQuantityChanged(_counter);
    });
  }

  void _decrementCounter() {
    setState(() {
      if (_counter > 0) _counter--;
      widget.onQuantityChanged(_counter);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
          width: 35,
          height: 20,
          child: IconButton(
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(),
            icon: const Icon(Icons.remove, size: 20,),
            onPressed: _decrementCounter,
          ),
        ),
        Text('$_counter',
            // style: TextStyle(fontSize: 20)
        ),
        Container(
          width: 35,
          height: 20,
          child: IconButton(
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(),
            icon: const Icon(Icons.add, size: 20,),
            onPressed: _incrementCounter,
          ),
        ),
      ],
    );
  }
}
