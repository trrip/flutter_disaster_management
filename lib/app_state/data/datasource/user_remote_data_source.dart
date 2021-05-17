import 'package:disaster_management_ui/app_state/data/models/user.dart';
import 'package:disaster_management_ui/app_state/user_failures.dart';
import 'package:disaster_management_ui/dao/remote_dao.dart';
import 'package:disaster_management_ui/dao/user_dao.dart';
import 'package:disaster_management_ui/dependecy_injection/dependency_injection.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

abstract class UserRemoteDataSourceInterface {
  Future<bool> registerUser({@required User user, @required String password});

  Future<User> getUserInformation(
      {@required String email, @required String password});
}

class UserRemoteDataSource implements UserRemoteDataSourceInterface {
  final RemoteDao remoteDao;

  UserRemoteDataSource({@required this.remoteDao});

  @override
  Future<User> getUserInformation(
      {@required String email, @required String password}) async {
    try {
      User user = User.fromJson(
          await remoteDao.getUserInformation(email: email, pass: password));
      print("------- user $user");
      if (user == null) {
        throw UserNotFoundError();
      }
      return user;
    } catch (e) {
      throw UserNotFoundError();
    }
  }

  @override
  Future<bool> registerUser(
      {@required User user, @required String password}) async {
    try {
      Map<String, dynamic> status = await remoteDao.registerWithInformation(
          email: user.email,
          pass: password,
          name: user.firstName,
          group: user.groups);
      if (status["status"] == 800200) {
        // only when the user is there.
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
