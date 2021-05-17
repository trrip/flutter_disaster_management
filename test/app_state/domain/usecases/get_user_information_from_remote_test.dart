import 'package:dartz/dartz.dart';
import 'package:disaster_management_ui/app_state/data/models/user.dart';
import 'package:disaster_management_ui/app_state/domain/repositories/user_repo.dart';
import 'package:disaster_management_ui/app_state/domain/usecases/get_user_information_from_local.dart';
import 'package:disaster_management_ui/app_state/domain/usecases/get_user_information_from_remote.dart';
import 'package:disaster_management_ui/app_state/domain/usecases/user_usecase_interface.dart';
import 'package:disaster_management_ui/app_state/user_failures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockUserRepo extends Mock implements UserRepository {}

void main() {
  GetRemoteUserInformation remoteInformation;
  MockUserRepo repo;

  final userJson = {
    "user": "demo1",
    "email": "demo@user.com",
    "groups": ["police"],
  };
  final user_test = User(firstName: "demo1", email: "demo@user.com", groups: 1);

  setUp(() {
    repo = MockUserRepo();
    remoteInformation = GetRemoteUserInformation(repository: repo);
  });

  test('should get user object from repository', () async {
    when(repo.getUserRemoteInformation(
            email: "demo@user.com", password: "somepass"))
        .thenAnswer((_) async => Right(user_test));

    final result = await remoteInformation(
        RemoteUserParams(emailId: "demo@user.com", password: "somepass"));

    verifyNever(repo.getUserLocalInformation(email: "demo@user"));
    expect(result, equals(Right(user_test)));
  });
}
