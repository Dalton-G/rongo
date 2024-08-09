import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CounterWidget extends StatefulWidget {
  int currentQuantity;
  String name;

  var onCounterChanged;

  @override
  _CounterWidgetState createState() => _CounterWidgetState();

  CounterWidget(
      {super.key,
      required this.currentQuantity,
      required this.name,
      required this.onCounterChanged});
}

class _CounterWidgetState extends State<CounterWidget> {
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
      widget.onCounterChanged(_counter);
    });
  }

  void _decrementCounter() {
    setState(() {
      if (_counter > 0) _counter--;
      widget.onCounterChanged(_counter);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("How many ${widget.name} left after comsumed."),
        const SizedBox(
          height: 30,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.remove),
              onPressed: _decrementCounter,
            ),
            Text('$_counter', style: TextStyle(fontSize: 20)),
            IconButton(
              icon: Icon(Icons.add),
              onPressed: _incrementCounter,
            ),
          ],
        ),
      ],
    );
  }
}

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
      children: <Widget>[
        IconButton(
          icon: Icon(Icons.remove),
          onPressed: _decrementCounter,
        ),
        Text('$_counter',
            // style: TextStyle(fontSize: 20)
        ),
        IconButton(
          icon: Icon(Icons.add),
          onPressed: _incrementCounter,
        ),
      ],
    );
  }
}
