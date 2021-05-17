import 'dart:convert';
import 'dart:developer';

import 'package:disaster_management_ui/dependecy_injection/dependency_injection.dart';
import 'package:disaster_management_ui/utilities/service.dart';
import "package:http/http.dart" as http;
import 'package:shared_preferences/shared_preferences.dart';

class RemoteService {
  //Input and output decide later
  Future<Map<String, dynamic>> login(Map<String, dynamic> data) async {
    http.Response response = await http.post(
      ServiceProvider.LOGIN,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(data),
    );
    Map<String, dynamic> responseBody = json.decode(response.body);
    SharedPreferences sharedPreferences = DependenctInjector();
    sharedPreferences.setString("token", responseBody["token"]);
    print(response.body);
    return json.decode(response.body);
  }

  //Input and output decide later
  Future<Map<String, dynamic>> register(Map<String, dynamic> data) async {
    http.Response response = await http.post(
      ServiceProvider.REGISTER,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(data),
    );
    return json.decode(response.body);
  }

  Future<Map<String, dynamic>> getNearestHospital(
      Map<String, dynamic> data) async {
    SharedPreferences sharedPreferences = DependenctInjector();
    data["token"] = sharedPreferences.get("token");
    http.Response response = await http.post(
      ServiceProvider.NEAREST_HOSPITAL,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(data),
    );
    return json.decode(response.body);
  }

  Future<Map<String, dynamic>> registerDisaster(
      Map<String, dynamic> data) async {
    SharedPreferences sharedPreferences = DependenctInjector();
    data["token"] = sharedPreferences.get("token");
    http.Response response = await http.post(
      ServiceProvider.REPORT_INCIDENT,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(data),
    );
    print(response.body);
    return json.decode(response.body);
  }

  Future<Map<String, dynamic>> evacuateUser(Map<String, dynamic> data) async {
    SharedPreferences sharedPreferences = DependenctInjector();
    data["token"] = sharedPreferences.get("token");
    http.Response response = await http.post(
      ServiceProvider.EVACUATE_TO_SAFE_HOUSE,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(data),
    );
    print(response.body);
    return json.decode(response.body);
  }

  //Input and output decide later
  Future<Map<String, dynamic>> getRoute(Map<String, dynamic> data) async {
    SharedPreferences sharedPreferences = DependenctInjector();
    data["token"] = sharedPreferences.get("token");
    http.Response response = await http.post(
      ServiceProvider.GET_ROUTE,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(data),
    );
    print(response.body);
    return json.decode(response.body);
  }
}
