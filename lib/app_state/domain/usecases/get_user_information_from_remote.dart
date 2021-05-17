import 'package:dartz/dartz.dart';
import 'package:disaster_management_ui/app_state/data/datasource/user_remote_data_source.dart';
import 'package:disaster_management_ui/app_state/data/models/user.dart';
import 'package:disaster_management_ui/app_state/domain/repositories/user_repo.dart';
import 'package:disaster_management_ui/app_state/domain/usecases/user_usecase_interface.dart';
import 'package:disaster_management_ui/app_state/user_failures.dart';
import 'package:flutter/foundation.dart';

class GetRemoteUserInformation implements UserUseCase<User, RemoteUserParams> {
  final UserRepository repository;

  GetRemoteUserInformation({@required this.repository});

  @override
  Future<Either<Failure, User>> call(RemoteUserParams params) async {
    return await repository.getUserRemoteInformation(
        email: params.emailId, password: params.password);
  }
}
