import 'package:disaster_management_ui/app_state/data/models/user.dart';
import 'package:disaster_management_ui/app_state/user_failures.dart';
import 'package:disaster_management_ui/dependecy_injection/dependency_injection.dart';
import 'package:disaster_management_ui/utilities/remote_service.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class RemoteDao {
  RemoteDao();

  ///
  /// {
  //  "password": "ssshhh",
  //  "email": "jerry@derpmail.jerry",
  //  "deviceToken": "sdkfjsklfjsdfd"
  // }

  Future<Map<String, dynamic>> getUserInformation(
      {@required String email, @required String pass}) async {
    // Response response = await http.post("url", headers: {}, body: {});
    //temp code.
    ///
    ///             email = str(requestDict["email"])
    //             password = str(requestDict["password"])
    //             deviceToken = str(requestDict["deviceToken"])

    var response = await RemoteService().login(
      {
        "email": email,
        "password": pass,
        "deviceToken":
            DependenctInjector<SharedPreferences>().getString("DEVICE_TOKEN")
      },
    );
    if (response["code"] == 800200 || response["code"] == 1) {
      print("hamslkd");
      return response;
    } else {
      throw UserNotFoundError();
    }
  }

  Future<Map<String, dynamic>> registerWithInformation(
      {@required String email,
      @required String pass,
      @required String name,
      @required int group}) async {
    return RemoteService().register(
      {
        "email": email,
        "name": name,
        "password": pass,
        "group": group,
        "deviceToken":
            DependenctInjector<SharedPreferences>().getString("DEVICE_TOKEN")
      },
    );
  }
// Future<void> saveUserInfo(Map<String, dynamic> userJson) async {}
}
