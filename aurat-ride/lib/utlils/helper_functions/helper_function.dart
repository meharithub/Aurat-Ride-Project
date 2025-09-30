import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HelperFunctions {
  static void navigateTo(context, screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => screen));
  }

  static void navigateReplace(context, screen) {
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => screen));
  }

  static void navigateBack(context) {
    Navigator.of(context).pop();
  }

  static void hideKeyBoard() {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }
}
