import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

abstract class AppStateEventsInterface extends Equatable {
  @override
  List<Object> get props => [];
}

class LoginWithPass extends AppStateEventsInterface {
  final String email;
  final String password;

  LoginWithPass({@required this.email, @required this.password});

  @override
  List<Object> get props => [email, password];
}

class LoginWithoutPassword extends AppStateEventsInterface {
  final String email;

  LoginWithoutPassword({@required this.email});

  @override
  List<Object> get props => [email];
}

class AppStart extends AppStateEventsInterface {}

class Logout extends AppStateEventsInterface {}
