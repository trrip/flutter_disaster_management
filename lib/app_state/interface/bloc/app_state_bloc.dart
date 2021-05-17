import 'dart:math';

import 'package:disaster_management_ui/app_state/data/models/user.dart';
import 'package:disaster_management_ui/app_state/domain/repositories/user_repo.dart';
import 'package:disaster_management_ui/app_state/domain/usecases/get_user_information_from_local.dart';
import 'package:disaster_management_ui/app_state/domain/usecases/get_user_information_from_remote.dart';
import 'package:disaster_management_ui/app_state/domain/usecases/logout.dart';
import 'package:disaster_management_ui/app_state/domain/usecases/user_usecase_interface.dart';
import 'package:disaster_management_ui/app_state/interface/bloc/app_state.dart';
import 'package:disaster_management_ui/app_state/interface/bloc/app_state_events.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppStateBloc extends Bloc<AppStateEventsInterface, AppState> {
  final GetRemoteUserInformation getRemoteUserInformation;
  final GetLocalInformation getLocalInformation;
  final LogoutUser logout;

  AppStateBloc({
    @required GetRemoteUserInformation getRemoteUserInformation,
    @required GetLocalInformation getLocalInformation,
    @required LogoutUser logout,
  })  : assert(getLocalInformation != null),
        assert(getRemoteUserInformation != null),
        assert(logout != null),
        getRemoteUserInformation = getRemoteUserInformation,
        getLocalInformation = getLocalInformation,
        logout = logout,
        super(Empty());

  AppState get initialState => Empty();

  @override
  Stream<AppState> mapEventToState(AppStateEventsInterface event) async* {
    yield Loading();
    if (event is AppStart) {
      //TODO:: have to change this and not ask email for local calling
      final response =
          await getLocalInformation.call(LocalUserParams(emailId: ""));
      yield response.fold((failure) {
        return LoginView();
      }, (data) {
        return getCorrectGroupView(data);
      });
    } else if (event is LoginWithPass) {
      final response = await getRemoteUserInformation.call(
          RemoteUserParams(emailId: event.email, password: event.password));
      yield response.fold((failure) {
        return LoginView(message: "something went wrong with logging in");
      }, (data) {
        /*
        *   "Individual",
            "Police Service",
            "Fire Service",
            "Emergency Evacuators",
            "Paramedics",
            "Emergency Response Coordinators"
        * */
        print(data.getJson());
        return getCorrectGroupView(data);
      });
    } else if (event is LoginWithoutPassword) {
      final response =
          await getLocalInformation.call(LocalUserParams(emailId: event.email));
      yield response.fold((failure) {
        return Error(failure: "message");
      }, (data) {
        return LoggedIn(user: data);
      });
    } else if (event is Logout) {
      await logout.call(NoParams());
      yield LoggedOut();
    }

    // TODO: implement mapEventToState
  }

  AppState getCorrectGroupView(User user) {
    if (user.groups == 0) {
      return IndividualLogin(user: user);
    } else if (user.groups == 1) {
      return PoliceLogin(user: user);
    } else if (user.groups == 2) {
      // return IndividualLogin(user: user);
      // return PoliceLogin(user: user);
      return FireLogin(user: user);
    } else if (user.groups == 3) {
      return EmergencyEvacuatorLogin(user: user);
    } else if (user.groups == 4) {
      return AmbulanceLogin(user: user);
    } else if (user.groups == 5) {
      return EmergencyCoordinatorLogin(user: user);
    }
    return LoggedIn(user: user);
  }
}
