import 'dart:convert';

import 'package:disaster_management_ui/app_state/data/models/user.dart';
import 'package:disaster_management_ui/app_state/interface/widgets/map_ui/leaflet_ui.dart';
import 'package:disaster_management_ui/app_state/interface/widgets/view_components/disaster_information_page.dart';
import 'package:disaster_management_ui/app_state/interface/widgets/view_components/draggable_notification_center.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:latlong/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AppHomeScreen extends StatefulWidget {
  final User user;

  const AppHomeScreen({Key key, @required this.user}) : super(key: key);

  @override
  _AppHomeScreenState createState() => _AppHomeScreenState();
}

class _AppHomeScreenState extends State<AppHomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  String searchQuery = "Search query";
  LatLng startPoint;

  int taskCounter = 0;

  List<CustomMarker> markers;

  List<Map<String, dynamic>> disasterZone;

  List<List<double>> navigationPath = [
    [-6.31289, 53.3268],
    [-6.25482, 53.36903]
  ];

  final databaseRef = FirebaseDatabase.instance.reference();

  // final Future<FirebaseApp> _future = Firebase.initializeApp();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    startPoint = LatLng(
      53.3268,
      -6.31289,
    );
    Firebase.initializeApp().then((value) async {
      var token = await FirebaseMessaging.instance.getToken();
      print("Instance ID: " + token);
      //ios only
      await FirebaseMessaging.instance.requestPermission(alert: true);
      // FirebaseMessaging.instance.getInitialMessage().then((value) {
      //   print("get initial message");
      //
      //   print(value);
      // });
      // FirebaseMessaging.onMessage.listen((RemoteMessage event) {
      //   showDialog(
      //     context: _scaffoldKey.currentContext,
      //     child: AlertDialog(
      //       title: Text(event.notification.title),
      //       content: Text(event.notification.body),
      //       actions: [
      //         FlatButton(
      //           onPressed: () {
      //             Navigator.pop(_scaffoldKey.currentContext);
      //           },
      //           child: Text("Ok"),
      //         ),
      //       ],
      //     ),
      //   );
      // });

      FirebaseFirestore firestore = FirebaseFirestore.instance;
      CollectionReference focusPoint =
          FirebaseFirestore.instance.collection('pois');

      DocumentReference ref = focusPoint.doc("focus_point");
      ref.snapshots().listen((event) {
        GeoPoint point = event.data()["point"];
        print(point.latitude);
      });

      //disaster zone
      // DocumentReference disasterRef =
      //     FirebaseFirestore.instance.collection('pois').doc("");
      //markers listening
    });
    // FirebaseFirestore firestore = FirebaseFirestore.instance;
    // FirebaseApp secondaryApp = Firebase.app('Disaster-Management-System');
    // FirebaseFirestore firestore =
    //     FirebaseFirestore.instanceFor(app: secondaryApp);

    // CollectionReference focusPoint =
    //     FirebaseFirestore.instance.collection('pois');
    // DocumentReference ref = focusPoint.doc("focus_point");
    // ref.snapshots().listen((event) {
    //   print(event.toString());
    // });

    // focusPoint.get().then((QuerySnapshot querySnapshot) => {
    //       querySnapshot.docs.forEach((doc) {
    //         print(doc["focus_point"]);
    //       })
    //     });

    // databaseRef.child
    databaseRef.child("emergency_coordinator").onValue.listen((event) {
      List<Map<String, dynamic>> mainList = [];
      print(event.snapshot.value["disaster"]["circle"]);
      Map<dynamic, dynamic> temp = event.snapshot.value["disaster"]["circle"];
      print(temp.keys);
      for (var i in temp.keys) {
        Map<String, dynamic> j = json.decode(temp[i]);
        print(j);
        mainList.add(j);
      }
      print(mainList);

      // Map<String, dynamic> instance = json.decode(temp);
      // jsonDecode(event.snapshot.value["11-03-2021-14:15:00"]);

      // for (var j in instance["coordinates"]) {
      //   mainList.add(LatLng(j[0], j[1]));
      // }

      setState(() {
        disasterZone = [];
      });

      // LatLng firstValue = LatLng(
      //     event.snapshot.value["focuspoint"]["Lattitude"],
      //     event.snapshot.value["focuspoint"]["Longitude"]);
      // this.setState(() {
      //   startPoint = firstValue;
      // });
    });

    /* CollectionReference tasks = FirebaseFirestore.instance.collection('tasks');
    tasks.snapshots().listen((event) {
      for (var i in event.docs) {
        GeoPoint point = i.data()["point"];
        print(point.latitude);
      }
    });
*/
    databaseRef.child("tasks").onValue.listen(
      (event) {
        print(event.snapshot.value);
        Map<dynamic, dynamic> temp = event.snapshot.value["task"];
        setState(
          () {
            taskCounter = temp.keys.length;
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController _searchQueryController = TextEditingController();
    return Scaffold(
      key: _scaffoldKey,
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Container(
                child: Row(
                  children: [
                    CircleAvatar(
                      child: CircleAvatar(),
                      foregroundColor: Colors.redAccent,
                      radius: 50,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 18.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(this.widget.user.firstName),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
            ),
            ListTile(
              title: Text('Some view 1'),
              onTap: () {
                // Update the state of the app.
                // ...
              },
            ),
            ListTile(
              title: Text('Some view 2'),
              onTap: () {
                // Update the state of the app.
                // ...
              },
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          LeafLetMapUI(
            startPoint: this.startPoint,
            navigationPath: this.navigationPath,
            markers: [],
            disasterZone: [],
            navigationMode: false,
          ),
          Positioned(
            right: 20.0,
            top: 40.0,
            child: FloatingActionButton(
                mini: true,
                child: Icon(Icons.monetization_on),
                onPressed: () {
                  _scaffoldKey.currentState.openDrawer();
                }),
          ),
          Positioned(
            left: 20.0,
            bottom: 90.0,
            child: FlatButton(
                visualDensity: VisualDensity.compact,
                color: Colors.red,
                child: Text(
                  "Register disaster",
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text("Select a disaster type"),
                          content: Text("select some disaster"),
                          actions: [
                            //TODO: adding the button functions
                            FlatButton(onPressed: () {}, child: Text("OK")),
                            FlatButton(onPressed: () {}, child: Text("Cancel"))
                          ],
                        );
                      });
                }),
          ),
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          SizedBox(
            width: 25,
          ),
          Stack(
            children: [
              FloatingActionButton(
                heroTag: "number 2",
                child: Icon(Icons.list),
                tooltip: "2",
                onPressed: () {
                  showModalBottomSheet(
                    backgroundColor: Colors.transparent,
                    context: context,
                    isScrollControlled: true,
                    builder: (context) {
                      return NotificationCenter(); // do more improvements over this.
                    },
                  );
                },
              ),
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.all(Radius.circular(10.0))),
                  child: Center(
                    child: Text(
                      "$taskCounter",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
          FloatingActionButton(
              heroTag: "number 1",
              child: Icon(Icons.add),
              onPressed: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                  return DisasterInformationPage();
                }));
              }),
          FloatingActionButton(
              heroTag: "number 3",
              child: Icon(Icons.near_me_rounded),
              onPressed: () {
                this.setState(() {
                  startPoint = LatLng(
                    // some point
                    53.36903,
                    -6.25482,
                  );
                });
              }),
          SizedBox(
            width: 25,
          ),
        ],
      ),
    );
  }

  void updateSearchQuery(String newQuery) {
    setState(() {
      searchQuery = newQuery;
    });
  }
}

/// This is the stateful widget that the main application instantiates.
