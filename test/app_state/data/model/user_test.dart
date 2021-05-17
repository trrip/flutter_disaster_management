import 'package:disaster_management_ui/app_state/data/models/user.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final userJson = {
    "user": "demo1",
    "lastName": "user",
    "groups": ["police"],
    "email": "demo@user.com",
  };
  final user_test = User(firstName: "demo1", email: "demo@user.com", groups: 1);

  test('Should be a subclass of UserModel entity ', () async {
    expect(user_test, isA<UserModel>());
  });

  group('Tests for User json input', () {
    test('should return a User object from a json input', () async {
      final result = User.fromJson(userJson);
      expect(result, user_test);
    });

    test('should return a correct json structure from user object', () {
      final result = user_test.getJson();
      expect(result, userJson);
    });
  });
}
