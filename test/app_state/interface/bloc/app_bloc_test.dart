import 'package:dartz/dartz.dart';
import 'package:disaster_management_ui/app_state/data/models/user.dart';
import 'package:disaster_management_ui/app_state/domain/usecases/get_user_information_from_local.dart';
import 'package:disaster_management_ui/app_state/domain/usecases/get_user_information_from_remote.dart';
import 'package:disaster_management_ui/app_state/domain/usecases/user_usecase_interface.dart';
import 'package:disaster_management_ui/app_state/interface/bloc/bloc.dart';
import 'package:disaster_management_ui/app_state/user_failures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockGetLocalInformation extends Mock implements GetLocalInformation {}

class MockGetRemoteUserInformation extends Mock
    implements GetRemoteUserInformation {}

void main() {
  final userJson = {
    "firstName": "demo1",
    "lastName": "user",
    "email": "demo@user.com",
    "groups": ["police"],
  };
  final user_test = User(firstName: "demo1", email: "demo@user.com", groups: 1);

  AppStateBloc bloc;

  MockGetLocalInformation localInformation;
  MockGetRemoteUserInformation remoteUserInformation;
  setUp(() {
    localInformation = MockGetLocalInformation();
    remoteUserInformation = MockGetRemoteUserInformation();
    bloc = AppStateBloc(
      getRemoteUserInformation: remoteUserInformation,
      getLocalInformation: localInformation,
    );
  });

  group('local Information group', () {
    test('Should get a user object with just email', () async {
      when(localInformation(any)).thenAnswer((_) async => Right(user_test));
      expectLater(
          bloc,
          emitsInOrder([
            Loading(),
            LoggedIn(user: user_test),
          ]));
      bloc.add(LoginWithoutPassword(email: "user@demo.com"));

      await untilCalled(localInformation(any));
      verifyNever(localInformation(LocalUserParams(emailId: "user@demo")));
    });

    test('Should get a error object with just email', () async {
      when(localInformation(any))
          .thenAnswer((_) async => Left(UserNotFoundError()));

      expectLater(
          bloc,
          emitsInOrder([
            Loading(),
            Error(failure: "message"),
          ]));

      bloc.add(LoginWithoutPassword(email: "user@demo.com"));

      await untilCalled(localInformation(any));
      verifyNever(localInformation(LocalUserParams(emailId: "user@demo")));
    });
  });

  group('Remote Information group', () {
    test('Should get a error object with just email', () async {
      when(remoteUserInformation(any))
          .thenAnswer((_) async => Right(user_test));
      expectLater(
          bloc,
          emitsInOrder([
            Loading(),
            LoggedIn(user: user_test),
          ]));
      bloc.add(LoginWithPass(email: "user@demo.com", password: "somepass"));

      await untilCalled(remoteUserInformation(any));
      verifyNever(remoteUserInformation(
          RemoteUserParams(emailId: "user@demo", password: "somepass")));
    });

    test('Should get a user object with just email', () async {
      when(remoteUserInformation(any))
          .thenAnswer((_) async => Left(UserNotFoundError()));
      expectLater(
          bloc,
          emitsInOrder([
            Loading(),
            Error(failure: "message"),
          ]));
      bloc.add(LoginWithPass(email: "user@demo.com", password: "somepass"));

      await untilCalled(remoteUserInformation(any));
      verifyNever(remoteUserInformation(
          RemoteUserParams(emailId: "user@demo", password: "somepass")));
    });
  });

  test('initial state should be Empty()', () {
    expect(bloc.state, Empty());
  });
}
