import 'package:connectivity/connectivity.dart';
import 'package:disaster_management_ui/app_state/interface/bloc/bloc.dart';
import 'package:disaster_management_ui/app_state/interface/pages/app_home_screen.dart';
import 'package:disaster_management_ui/app_state/interface/pages/groups/ambulance_view.dart';
import 'package:disaster_management_ui/app_state/interface/pages/groups/emergency_coordinator_view.dart';
import 'package:disaster_management_ui/app_state/interface/pages/groups/emergency_evacuator_view.dart';
import 'package:disaster_management_ui/app_state/interface/pages/groups/fire_view.dart';
import 'package:disaster_management_ui/app_state/interface/pages/groups/individual_view.dart';
import 'package:disaster_management_ui/app_state/interface/pages/groups/police_view.dart';
import 'package:disaster_management_ui/app_state/interface/widgets/empty_view.dart';
import 'package:disaster_management_ui/app_state/interface/widgets/loading_view.dart';
import 'package:disaster_management_ui/app_state/interface/widgets/login_widget.dart';
import 'package:disaster_management_ui/app_state/interface/widgets/map_ui/leaflet_ui.dart';
import 'file:///C:/Users/choud/AndroidStudioProjects/disastermanagementclient/lib/app_state/interface/widgets/error_view.dart';
import 'package:disaster_management_ui/dependecy_injection/dependency_injection.dart';
import 'package:disaster_management_ui/utilities/connection_utility.dart';
import 'package:disaster_management_ui/utilities/singleton_instances.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

const double POPUP_HEIGHT = 25;

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

// do something here to check if connected to internet.

class _AppState extends State<App> {
  bool connectionStatus;

  @override
  void initState() {
    Firebase.initializeApp().then((value) async {
      firebaseApp = value;
      SharedPreferences pref = DependenctInjector();
      if (pref.getString("DEVICE_TOKEN") == null) {
        var token = await FirebaseMessaging.instance.getToken();
        print("Instance ID: " + token);
        pref.setString("DEVICE_TOKEN", token);
      }
      //ios only
      await FirebaseMessaging.instance.requestPermission(alert: true);

      FirebaseMessaging.instance.getInitialMessage().then((value) {
        //TODO: when message receive
      });
      FirebaseMessaging.instance.subscribeToTopic("32221").then((value) {
        print("Subscription to 32221 done.");
        //TODO:: set correct subscribe
      });
      FirebaseMessaging.onMessage.listen((RemoteMessage event) {
        // TODO: do certain things depending on the message
        if (event.notification != null) {
          showDialog(
            context: context,
            child: AlertDialog(
              title: Text(event.notification.title),
              content: Text(event.notification.body),
              actions: [
                FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("Ok"),
                ),
              ],
            ),
          );
        } else if (event.from.contains("topic")) {
          showDialog(
            context: context,
            child: AlertDialog(
              title: Text(event.data["title"]),
              content: Text(event.data["body"]),
              actions: [
                FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("Ok"),
                ),
              ],
            ),
          );
        }
      });

      /*
      *
      * {data: {body: this was sent from topic, title: topic title},
      * messageId: 0:1616782636292737%819e7cb6f9fd7ecd,
      * sentTime: 1616782635788, from: /topics/32221, ttl: 2419200}
      *
      * {notification: {android: {},
      * title: Sending push from backend,
      * body: Hey Delaram, what's good :)},
      * data: {},
      * collapseKey: com.trinity.ase.disaster_management,
      * messageId: 0:1616782687125725%819e7cb6819e7cb6,
      * sentTime: 1616782687113,
      *  from: 755542775811,
      * ttl: 2419200}
      *
      * */

      //disaster zone
      // DocumentReference disasterRef =
      //     FirebaseFirestore.instance.collection('pois').doc("");
      //markers listening
    });
    connectionStatus = ConnectionUtility.getInstance().hasConnection;
    ConnectionUtility.getInstance()
        .connectionChangeController
        .stream
        .listen((event) {
      this.setState(() {
        connectionStatus = event;
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: BlocProvider(
            create: (_) => DependenctInjector<AppStateBloc>(),
            child: BlocBuilder<AppStateBloc, AppState>(
              builder: (context, state) {
                if (state is Empty) {
                  BlocProvider.of<AppStateBloc>(context).add(
                    AppStart(),
                  );
                  return LoadingView();
                } else if (state is LoginView) {
                  return LoginScreen(message: state.message);
                } else if (state is Loading) {
                  return LoadingView();
                } else if (state is LoggedIn) {
                  print(state.user.getJson());
                  if (state is IndividualLogin) {
                    return IndividualView(
                      user: state.user,
                    );
                  } else if (state is PoliceLogin) {
                    return PoliceView(
                      user: state.user,
                    );
                  } else if (state is FireLogin) {
                    return FireView(
                      user: state.user,
                    );
                  } else if (state is AmbulanceLogin) {
                    return AmbulanceView(
                      user: state.user,
                    );
                  } else if (state is EmergencyCoordinatorLogin) {
                    return EmergencyCoordinatorView(
                      user: state.user,
                    );
                  } else if (state is EmergencyEvacuatorLogin) {
                    return EmergencyEvacuatorView(
                      user: state.user,
                    );
                  }
                  BlocProvider.of<AppStateBloc>(context).add(
                    Logout(),
                  );
                  return ErrorViewWithText(
                    message: "User Group is wrong ${state.user.groups}",
                  );
                } else if (state is Error) {
                  return ErrorViewWithText(
                    message: state.failure,
                  );
                } else if (state is LoggedOut) {
                  BlocProvider.of<AppStateBloc>(context).add(AppStart());
                }

                print(state);
                return Scaffold(
                  body: Container(
                    child: Text(""),
                  ),
                );
              },
            ),
          ),
        ),
        Material(
          child: Container(
            height: connectionStatus ? 0 : POPUP_HEIGHT,
            color: Colors.red,
            child: Center(child: Text("Internet connection not found")),
          ),
        )
      ],
    );
  }
}
