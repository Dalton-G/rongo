import 'package:flutter/services.dart';

class CustomTextEditingFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String newText = "";
    if (newValue.text.isNotEmpty) {
      if (newValue.text.length > oldValue.text.length) {
        var taskList = newValue.text.split("\n");
        int cursor = 0;
        for (int index = 0; index < taskList.length; index++) {
          var bullet = "${index + 1}. ";
          String temp = taskList[index];
          if (!temp.contains(bullet)) {
            temp = '$bullet$temp';
            if (index == taskList.length - 1) {
              cursor = cursor + 3;
            } else {
              cursor = 3;
            }
          }
          newText = "$newText${index == 0 ? "" : "\n"}$temp";
          newValue = TextEditingValue(
              text: newText,
              selection: TextSelection.collapsed(
                  offset: (newValue.selection.end + cursor)));
        }
      }
    }

    return newValue;
  }
}