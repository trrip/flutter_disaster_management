import 'package:disaster_management_ui/app_state/data/datasource/user_local_data_source.dart';
import 'package:disaster_management_ui/app_state/data/datasource/user_remote_data_source.dart';
import 'package:disaster_management_ui/app_state/data/models/user.dart';
import 'package:disaster_management_ui/app_state/user_failures.dart';
import 'package:disaster_management_ui/dao/remote_dao.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockRemoteDao extends Mock implements RemoteDao {}

void main() {
  UserRemoteDataSource dataSource;
  MockRemoteDao remoteDao;

  final user_test = User(firstName: "demo1", email: "demo@user.com", groups: 1);

  setUp(() {
    remoteDao = MockRemoteDao();
    dataSource = UserRemoteDataSource(remoteDao: remoteDao);
  });

  group('Getting user information', () {
    test('Should return a User object where there is a user in data source',
        () async {
      when(remoteDao.getUserInformation(
              email: "demo@user.com", pass: "somepass"))
          .thenAnswer((_) async => user_test.getJson());

      final result = await dataSource.getUserInformation(
          email: "demo@user.com", password: "somepass");
      verify(remoteDao.getUserInformation(
          email: "demo@user.com", pass: "somepass"));

      expect(result, user_test);
    });

    test(
        'should return error when the user email does not have have user in data source',
        () async {
      when(remoteDao.getUserInformation(
              email: "demo@user.com", pass: "somepass"))
          .thenAnswer((_) async => null);

      final result = dataSource.getUserInformation;

      expect(() => result(email: "demo@user.com", password: "someNotPass"),
          throwsA(isA<UserNotFoundError>()));
    });
    test(
        'should return error when the user pass does not have have user in data source',
        () async {
      when(remoteDao.getUserInformation(
          email: "demo@user.com", pass: "somepass"));

      final result = dataSource.getUserInformation;

      expect(
        () => result(email: "demo@us2er.com", password: "somepass"),
        throwsA(
          isA<UserNotFoundError>(),
        ),
      );
    });
  });
}
