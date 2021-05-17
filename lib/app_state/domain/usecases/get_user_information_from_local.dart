import 'package:dartz/dartz.dart';
import 'package:disaster_management_ui/app_state/data/datasource/user_local_data_source.dart';
import 'package:disaster_management_ui/app_state/data/models/user.dart';
import 'package:disaster_management_ui/app_state/domain/repositories/user_repo.dart';
import 'package:disaster_management_ui/app_state/domain/usecases/user_usecase_interface.dart';
import 'package:disaster_management_ui/app_state/user_failures.dart';
import 'package:flutter/cupertino.dart';

class GetLocalInformation implements UserUseCase<User, LocalUserParams> {
  final UserRepository repository;

  GetLocalInformation({@required this.repository});

  @override
  Future<Either<Failure, User>> call(LocalUserParams params) async {
    return await repository.getUserLocalInformation(email: params.emailId);
  }
}
