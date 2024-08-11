import 'package:flutter/material.dart';
import 'package:rongo/model/message.dart';

class ChatProvider extends ChangeNotifier {
  List<Message> _messages = [];

  List<Message> get messages => _messages;

  void addMessage(Message message) {
    _messages.add(message);
    notifyListeners();
  }
}
