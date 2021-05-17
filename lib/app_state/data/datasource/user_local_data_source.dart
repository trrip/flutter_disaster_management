import 'package:disaster_management_ui/app_state/data/models/user.dart';
import 'package:disaster_management_ui/app_state/user_failures.dart';
import 'package:disaster_management_ui/dao/user_dao.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class UserLocalDataSourceInterface {
  Future<User> getUserInformation({@required String email});

  Future<bool> isUserLoggedIn();

  Future<bool> setUserInformation({@required User user});
}

class UserLocalDataSource implements UserLocalDataSourceInterface {
  final UserDao userDao;

  UserLocalDataSource({@required this.userDao});
  
  @override
  Future<User> getUserInformation({@required String email}) async {
    // TODO: implement getUserInformation
    try {
      User user = User.fromJson(await this.userDao.getUserInformation(email));
      if (user == null) {
        throw UserNotFoundError();
      }
      return user;
    } catch (e) {
      throw UserNotFoundError();
    }
  }

  Future<bool> logout() async {
    try {
      return await this.userDao.logout();
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> setUserInformation({@required User user}) async {
    try {
      await this.userDao.saveUserInfo(user.getJson());
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> isUserLoggedIn() {
    return this.userDao.isUserLoggedIn();
  }
}
