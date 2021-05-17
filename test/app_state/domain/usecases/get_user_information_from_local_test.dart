import 'package:dartz/dartz.dart';
import 'package:disaster_management_ui/app_state/data/models/user.dart';
import 'package:disaster_management_ui/app_state/domain/repositories/user_repo.dart';
import 'package:disaster_management_ui/app_state/domain/usecases/get_user_information_from_local.dart';
import 'package:disaster_management_ui/app_state/domain/usecases/user_usecase_interface.dart';
import 'package:disaster_management_ui/app_state/user_failures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockUserRepo extends Mock implements UserRepository {}

void main() {
  GetLocalInformation localInformation;
  MockUserRepo repo;

  final userJson = {
    "user": "demo1",
    "email": "demo@user.com",
    "group": "police",
  };
  final user_test = User(firstName: "demo1", email: "demo@user.com", groups: 1);

  setUp(() {
    repo = MockUserRepo();
    localInformation = GetLocalInformation(repository: repo);
  });

  test('should get user object from repository', () async {
    when(repo.getUserLocalInformation(email: "demo@user.com"))
        .thenAnswer((_) async => Right(user_test));

    final result =
        await localInformation(LocalUserParams(emailId: "demo@user.com"));

    verifyNever(repo.getUserLocalInformation(email: "demo@user"));
    expect(result, equals(Right(user_test)));
  });
}
