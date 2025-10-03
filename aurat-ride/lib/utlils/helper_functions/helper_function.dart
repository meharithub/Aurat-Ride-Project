import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  // Token management methods
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }
}
