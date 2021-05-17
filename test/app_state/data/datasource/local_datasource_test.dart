import 'package:disaster_management_ui/app_state/data/datasource/user_local_data_source.dart';
import 'package:disaster_management_ui/app_state/data/models/user.dart';
import 'package:disaster_management_ui/app_state/user_failures.dart';
import 'package:disaster_management_ui/dao/user_dao.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockUserDao extends Mock implements UserDao {}

void main() {
  UserLocalDataSource dataSource;
  MockUserDao userDao;
  final user_test = User(firstName: "demo1", email: "demo@user.com", groups: 1);
  setUp(() {
    userDao = MockUserDao();
    dataSource = UserLocalDataSource(userDao: userDao);
  });

  group('Getting user information', () {
    test('Should return a User Dao where there is a user in data source',
        () async {
      when(userDao.getUserInformation("demo@user.com"))
          .thenAnswer((_) async => user_test.getJson());

      final result =
          await dataSource.getUserInformation(email: "demo@user.com");
      verify(userDao.getUserInformation("demo@user.com"));
      expect(result, user_test);
    });

    test('should return error when the user dao does not have have value',
        () async {
      when(userDao.getUserInformation("demo@user.com"))
          .thenAnswer((_) async => null);

      final result = dataSource.getUserInformation;

      expect(() => result(email: "demo@user.com"),
          throwsA(isA<UserNotFoundError>()));
    });
  });
}
