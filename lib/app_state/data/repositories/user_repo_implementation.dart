import 'package:dartz/dartz.dart';
import 'package:disaster_management_ui/app_state/data/datasource/user_local_data_source.dart';
import 'package:disaster_management_ui/app_state/data/datasource/user_remote_data_source.dart';
import 'package:disaster_management_ui/app_state/data/models/user.dart';
import 'package:disaster_management_ui/app_state/domain/repositories/user_repo.dart';
import 'package:disaster_management_ui/app_state/user_failures.dart';
import 'package:flutter/foundation.dart';

class UserRepoImplementation implements UserRepository {
  final UserLocalDataSource localDataSource;
  final UserRemoteDataSource remoteDataSource;

  UserRepoImplementation({
    @required this.remoteDataSource,
    @required this.localDataSource,
  });

  @override
  Future<Either<Failure, User>> getUserLocalInformation({String email}) async {
    try {
      User user;
      user = await localDataSource.getUserInformation(email: email);
      if (user == null) {
        return Left(UserNotFoundError());
      }
      return Right(user);
    } catch (e) {
      return Left(UserNotFoundError());
    }
  }

  @override
  Future<Either<Failure, bool>> logout() async {
    try {
      bool value = await localDataSource.logout();
      return Right(value);
    } catch (error) {
      return Left(CannotLogout());
    }
  }

  @override
  Future<Either<Failure, User>> getUserRemoteInformation(
      {String email, String password}) async {
    try {
      User user;
      user = await remoteDataSource.getUserInformation(
          email: email, password: password);
      if (user == null) {
        return Left(UserNotFoundError());
      }
      await localDataSource.setUserInformation(user: user);
      return Right(user);
    } catch (e) {
      return Left(UserNotFoundError());
    }
  }
}
