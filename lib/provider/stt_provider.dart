import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SttProvider extends ChangeNotifier {
  final SpeechToText _speechController = SpeechToText();
  bool _speechAvailable = false;
  bool _doneListening = false;
  bool _isListening = false;
  String _speechText = "Listening...";

  SpeechToText get speechController => _speechController;

  bool get speechAvailable => _speechAvailable;

  bool get doneListening => _doneListening;

  bool get isListening => _isListening;

  String get speechText => _speechText;

  Future<void> initialize() async {
    _speechAvailable = await _speechController.initialize(
      onStatus: (val) => {
        if (val == "done") {_doneListening = true, notifyListeners()}
      },
      onError: (val) => {print('onError: $val'), stopListening()},
    );
    print(_speechAvailable);
  }

  startListening() {
    _speechText = 'Listening...';
    _doneListening = false;
    _isListening = true;
    print(_doneListening);
    if (_speechAvailable) {
      _speechController.listen(
        onResult: (val) {
          _speechText = val.recognizedWords;
          print(_speechText);
          notifyListeners();
        },
      );
    }
  }

  stopListening() {
    _doneListening = true;
    _isListening = false;
    _speechController.stop();
  }
}
