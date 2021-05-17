import 'dart:convert';

import 'package:disaster_management_ui/dependecy_injection/dependency_injection.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserDao {
  final SharedPreferences sharedPreferences;

  UserDao({@required this.sharedPreferences});

  Future<bool> isUserLoggedIn() {
    return sharedPreferences.getString("USER_INFO") == null
        ? Future.value(false)
        : Future.value(true);
  }

  Future<bool> logout() {
    sharedPreferences.setString("USER_INFO", null);
    return Future.value(true);
  }

  Future<Map<String, dynamic>> getUserInformation(String email) async {
    return Future.value(jsonDecode(sharedPreferences.getString("USER_INFO")));
  }

  Future<void> saveUserInfo(Map<String, dynamic> userJson) async {
    sharedPreferences.setString("USER_INFO", jsonEncode(userJson));
  }
}
