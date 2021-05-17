import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:disaster_management_ui/app_state/data/models/task.dart';
import 'package:disaster_management_ui/app_state/data/models/user.dart';
import 'package:disaster_management_ui/app_state/interface/widgets/map_ui/leaflet_ui.dart';
import 'package:disaster_management_ui/app_state/interface/widgets/view_components/custom_drawer.dart';
import 'package:disaster_management_ui/app_state/interface/widgets/view_components/disaster_information_page.dart';
import 'package:disaster_management_ui/app_state/interface/widgets/view_components/draggable_notification_center.dart';
import 'package:disaster_management_ui/app_state/interface/widgets/view_components/register_disaster_button.dart';
import 'package:disaster_management_ui/utilities/remote_service.dart';
import 'package:disaster_management_ui/utilities/service.dart';
import 'package:disaster_management_ui/utilities/singleton_instances.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';

LatLng RANDOM_POINT = LatLng(53.3268, -6.31289);

class FireView extends StatefulWidget {
  final User user;

  const FireView({Key key, @required this.user}) : super(key: key);

  @override
  _FireViewState createState() => _FireViewState();
}

class _FireViewState extends State<FireView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final databaseRef = FirebaseDatabase.instance.reference();
  List<Task> tasks = [];
  List<List<double>> navigationPath = [];
  List<Map<String, dynamic>> disasterZone = [];
  LatLng cameraFocus;
  StreamController<Null> controller = StreamController<Null>();
  List<Marker> otherMarkers = [];

  CollectionReference writingLocation;

  bool navigationMode = false;
  int pathHolder = 1;

  Marker personMarker;

  @override
  void dispose() {
    // TODO: implement dispose
    controller.close();
    super.dispose();
  }

  Stream<Null> getStream() {
    Duration interval = Duration(milliseconds: 800);
    Timer timer;
    int counter = 0;

    void tick(_) async {
      counter++;

      if (navigationPath.length > 0 &&
          navigationPath.length > pathHolder &&
          navigationMode) {
        var targetPoint = navigationPath[pathHolder];
        var speedPerTick = 0.0001;
        var deltaX = targetPoint[0] - personMarker.point.latitude;
        var deltaY = targetPoint[1] - personMarker.point.longitude;
        var goalDist = sqrt((deltaX * deltaX) + (deltaY * deltaY));
        if (goalDist > speedPerTick) {
          var ratio = speedPerTick / goalDist;
          var xMove = ratio * deltaX;
          var yMove = ratio * deltaY;
          var newXPos = xMove + personMarker.point.latitude;
          var newYPos = yMove + personMarker.point.longitude;
          personMarker.point.longitude = newYPos;
          personMarker.point.latitude = newXPos;
        } else {
          personMarker.point.longitude = targetPoint[1];
          personMarker.point.latitude = targetPoint[0];
          pathHolder += 1;
        }
        if (pathHolder == navigationPath.length) {
          setState(() {
            navigationMode = false;
          });
          //timer.cancel();
        }
      }
      if (counter % 3 == 0) {
        updateLocation(this.widget.user,
            [personMarker.point.latitude, personMarker.point.longitude]);
      }
      controller.add(null); // Ask stream to send counter values as event.
    }

    void startTimer() {
      timer = Timer.periodic(interval, tick);
    }

    void stopTimer() {
      if (timer != null) {
        timer.cancel();
        timer = null;
      }
    }

    controller = StreamController<Null>(
      onListen: startTimer,
      onPause: stopTimer,
      onResume: startTimer,
      // onCancel: stopTimer,
    );

    return controller.stream;
  }

  Future<void> updateLocation(User user, List<double> location) async {
    writingLocation
        .doc(user.email)
        .set({"group": user.groups, "location": location});
  }

  //get and show safe houses only
  @override
  void initState() {
    print("initalizing state");
    super.initState();
    personMarker = Marker(
        point: LatLng(53.3268, -6.31289),
        builder: (context) {
          return IconButton(
              icon: Icon(Icons.location_history), onPressed: () {});
        });
    Firebase.initializeApp().then((value) {
      CollectionReference disastersRef =
          FirebaseFirestore.instance.collection('disasters');
      writingLocation = FirebaseFirestore.instance.collection('LiveLocation');
      disastersRef.snapshots().listen(
        (event) {
          List<Map<String, dynamic>> temp = [];
          List<Marker> safeHouseList = [];
          for (QueryDocumentSnapshot snap in event.docs) {
            var data = snap.data();
            data["id"] = snap.id;
            GeoPoint point = data["evacuationPoints"]["evacuationFrom"];
            safeHouseList.add(
              Marker(
                builder: (context) {
                  return IconButton(
                    icon: Icon(
                      Icons.house_rounded,
                      color: Colors.black,
                    ),
                    onPressed: () {
                      navigateToPoint(
                          LatLng(point.latitude, point.longitude), 1);
                    },
                  );
                },
                point: LatLng(point.latitude, point.longitude),
              ),
            );
            temp.add(data);
          }
          setState(
            () {
              otherMarkers += safeHouseList;
              disasterZone = temp;
            },
          );
        },
      );

      //get and set tasks.
      CollectionReference taskRef =
          FirebaseFirestore.instance.collection('tasks');
      taskRef.snapshots().listen((event) {
        List<Task> temp = [];
        for (QueryDocumentSnapshot snap in event.docs) {
          var data = snap.data();
          Task task = Task.fromJson(data);
          if (task.group == widget.user.groups) {
            temp.add(task);
          }
        }

        // print(temp);
        setState(() {
          // disasterZone = temp;
          tasks = temp;
        });
      });

      databaseRef.child("hospital_data").onValue.listen((event) {
        Map<dynamic, dynamic> temp = event.snapshot.value;
        List<Marker> markerList = [];
        for (var i in temp.keys) {
          var obj = temp[i];
          markerList.add(
            Marker(
              point: LatLng(double.parse(obj["latitude"]),
                  double.parse(obj["longitude"])),
              builder: (context) {
                return IconButton(
                    icon: Icon(
                      Icons.local_hospital_outlined,
                      color: Colors.black,
                    ),
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text(i),
                              actions: [
                                FlatButton(
                                  child: Text("Ok"),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                ),
                                FlatButton(
                                  child: Text("Navigate"),
                                  onPressed: () {
                                    navigateToPoint(
                                        LatLng(double.parse(obj["latitude"]),
                                            double.parse(obj["longitude"])),
                                        1);
                                  },
                                )
                              ],
                            );
                          });
                    });
              },
            ),
          );
        }
        setState(() {
          otherMarkers += markerList;
        });
      });

      // list of police stations
    });
  }

  void navigateToPoint(LatLng point, int avoid) async {
    try {
      var response = await RemoteService().getRoute({
        "lat2": point.longitude,
        "lon2": point.latitude,
        "lat1": personMarker.point.longitude,
        "lon1": personMarker.point.latitude,
        "avoidDisaster": "$avoid",
        "group": "some",
      });
      // print(getListOfCoordinates(response["coordinates"]));

      this.setState(() {
        pathHolder = 1;
        navigationPath = getListOfCoordinates(response["coordinates"]);
        navigationMode = true;
      });
      Navigator.of(context).pop();
    } catch (exception) {
      Navigator.of(context).pop();
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text("There was some issue with the remote service"),
        ),
      );
    }
  }

  List<List<double>> getListOfCoordinates(List<dynamic> list) {
    List<List<double>> tempList = [];
    for (var i in list) {
      List<double> localList = [];
      for (var j in i) {
        localList.insert(0, j);
      }
      tempList.add(localList);
    }
    return tempList;
  }

//show disasters

  @override
  Widget build(BuildContext context) {
    // TextEditingController _searchQueryController = TextEditingController();
    return Scaffold(
      key: _scaffoldKey,
      drawer: CustomDrawer(
        user: widget.user,
        parentContext: context,
      ),
      body: Stack(
        children: [
          LeafLetMapUI(
            startPoint: cameraFocus ?? RANDOM_POINT,
            navigationPath: navigationPath,
            markers: otherMarkers,
            disasterZone: this.disasterZone,
            navigationMode: false,
            navigationStreamController: getStream(),
            personMarker: personMarker,
            user: widget.user,
          ),
          Positioned(
            right: 20.0,
            top: 40.0,
            child: FloatingActionButton(
              mini: true,
              child: Icon(Icons.info_outline),
              onPressed: () {
                _scaffoldKey.currentState.openDrawer();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          RaisedButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "Tasks (${tasks.length})",
              ),
              color: Colors.blue,
              onPressed: () {
                showModalBottomSheet(
                  backgroundColor: Colors.transparent,
                  context: context,
                  isScrollControlled: true,
                  builder: (context) {
                    return NotificationCenter(
                      tasks: tasks,
                      callbackHandler: (disaster, task) async {
                        if (task.taskid.split("-")[0] == "2") {
                          // var response = await RemoteService()
                          //     .getNearestHospital({
                          //   "lat": personMarker.point.latitude,
                          //   "lon": personMarker.point.longitude
                          // });
                          // print("hello");
                          // this.setState(() {
                          //   pathHolder = 1;
                          //   navigationPath =
                          //       getListOfCoordinates(response["coordinates"]);
                          //   navigationMode = true;
                          // });
                          // FirebaseFirestore.instance.collection("")
                          Navigator.of(context).pop();
                        } else {
                          for (var i in disasterZone) {
                            if (i["id"] == disaster) {
                              GeoPoint point = i["epicentre"]["epicentre"];
                              navigateToPoint(
                                  LatLng(point.latitude, point.longitude), 0);
                            }
                          }
                        }
                      },
                    );
                  },
                );
              }),
          // RaisedButton(
          //   color: Colors.blue,
          //   shape:
          //       RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          //   child: Text(
          //     "Disaster information",
          //   ),
          //   onPressed: () async {
          //     Navigator.of(context).push(
          //       MaterialPageRoute(
          //         builder: (context) {
          //           // some information here
          //           return DisasterInformationPage();
          //         },
          //       ),
          //     );
          //   },
          // ),
        ],
      ),
    );
  }
}
