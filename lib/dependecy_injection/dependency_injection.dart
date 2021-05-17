import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:disaster_management_ui/app_state/data/datasource/user_local_data_source.dart';
import 'package:disaster_management_ui/app_state/data/datasource/user_remote_data_source.dart';
import 'package:disaster_management_ui/app_state/data/repositories/user_repo_implementation.dart';
import 'package:disaster_management_ui/app_state/domain/repositories/user_repo.dart';
import 'package:disaster_management_ui/app_state/domain/usecases/get_user_information_from_local.dart';
import 'package:disaster_management_ui/app_state/domain/usecases/get_user_information_from_remote.dart';
import 'package:disaster_management_ui/app_state/domain/usecases/logout.dart';
import 'package:disaster_management_ui/app_state/interface/bloc/bloc.dart';
import 'package:disaster_management_ui/dao/remote_dao.dart';
import 'package:disaster_management_ui/dao/user_dao.dart';
import 'package:disaster_management_ui/utilities/connection_utility.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

final DependenctInjector = GetIt.instance;

Future<void> dependencyInit(
    {@required SharedPreferences sharedPreferences}) async {
  DependenctInjector.registerFactory(
    () => AppStateBloc(
      getRemoteUserInformation: DependenctInjector(),
      getLocalInformation: DependenctInjector(),
      logout: DependenctInjector(),
    ),
  );
  DependenctInjector.registerLazySingleton(
    () => GetRemoteUserInformation(
      repository: DependenctInjector(),
    ),
  );
  DependenctInjector.registerLazySingleton(
    () => LogoutUser(
      repository: DependenctInjector(),
    ),
  );
  DependenctInjector.registerLazySingleton(
    () => GetLocalInformation(
      repository: DependenctInjector(),
    ),
  );
  DependenctInjector.registerLazySingleton<UserRepository>(
    () => UserRepoImplementation(
      remoteDataSource: DependenctInjector(),
      localDataSource: DependenctInjector(),
    ),
  );
  DependenctInjector.registerLazySingleton(
      () => UserLocalDataSource(userDao: DependenctInjector()));
  DependenctInjector.registerLazySingleton(
      () => UserRemoteDataSource(remoteDao: DependenctInjector()));
  DependenctInjector.registerLazySingleton(() => RemoteDao());
  DependenctInjector.registerLazySingleton(
      () => UserDao(sharedPreferences: sharedPreferences));

  DependenctInjector.registerSingleton<SharedPreferences>(sharedPreferences);

  //start connection utility
  ConnectionUtility connectionStatus = ConnectionUtility.getInstance();
  connectionStatus.initialize();
}
