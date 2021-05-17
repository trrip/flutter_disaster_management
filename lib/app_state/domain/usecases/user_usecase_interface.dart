import 'package:dartz/dartz.dart';
import 'package:disaster_management_ui/app_state/user_failures.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

abstract class UserUseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

class NoParams extends Equatable {
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class RemoteUserParams {
  final String emailId;
  final String password;

  RemoteUserParams({@required this.emailId, @required this.password});
}

class LocalUserParams {
  final String emailId;

  LocalUserParams({@required this.emailId});
}
