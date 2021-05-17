import 'package:disaster_management_ui/app_state/data/models/user.dart';
import 'package:disaster_management_ui/app_state/user_failures.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

abstract class AppState extends Equatable {
  @override
  List<Object> get props => [];
}

class Empty extends AppState {}

class Loading extends AppState {}

class LoginView extends AppState {
  final String message;

  LoginView({this.message});

  @override
  List<Object> get props => [message];
}

class Error extends AppState {
  // final Failure failure;
  final String failure;

  Error({@required this.failure});

  @override
  List<Object> get props => [failure];
}

class LoggedIn extends AppState {
  final User user;

  LoggedIn({@required this.user});

  @override
  List<Object> get props => [user];
}

class PoliceLogin extends LoggedIn {
  final User user;

  PoliceLogin({@required this.user}) : super(user: user);
}

class AmbulanceLogin extends LoggedIn {
  final User user;

  AmbulanceLogin({@required this.user}) : super(user: user);
}

class IndividualLogin extends LoggedIn {
  final User user;

  IndividualLogin({@required this.user}) : super(user: user);
}

class FireLogin extends LoggedIn {
  final User user;

  FireLogin({@required this.user}) : super(user: user);
}

class EmergencyCoordinatorLogin extends LoggedIn {
  final User user;

  EmergencyCoordinatorLogin({@required this.user}) : super(user: user);
}

class EmergencyEvacuatorLogin extends LoggedIn {
  final User user;

  EmergencyEvacuatorLogin({@required this.user}) : super(user: user);
}

class LoggedOut extends AppState {}
