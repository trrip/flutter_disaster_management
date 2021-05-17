import 'package:dartz/dartz.dart';
import 'package:disaster_management_ui/app_state/data/models/user.dart';
import 'package:disaster_management_ui/app_state/user_failures.dart';
import 'package:flutter/foundation.dart';
import "../usecases/user_usecase_interface.dart";

abstract class UserRepository {
  Future<Either<Failure, User>> getUserLocalInformation(
      {@required String email});

  Future<Either<Failure, bool>> logout();

  Future<Either<Failure, User>> getUserRemoteInformation({
    @required String email,
    @required String password,
  });
}
