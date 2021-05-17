import 'package:dartz/dartz.dart';
import 'package:disaster_management_ui/app_state/data/datasource/user_remote_data_source.dart';
import 'package:disaster_management_ui/app_state/data/models/user.dart';
import 'package:disaster_management_ui/app_state/domain/repositories/user_repo.dart';
import 'package:disaster_management_ui/app_state/domain/usecases/user_usecase_interface.dart';
import 'package:disaster_management_ui/app_state/user_failures.dart';
import 'package:flutter/foundation.dart';

class LogoutUser implements UserUseCase<bool, NoParams> {
  final UserRepository repository;

  LogoutUser({@required this.repository});

  @override
  Future<Either<Failure, bool>> call(NoParams params) async {
    return await repository.logout();
  }
}
