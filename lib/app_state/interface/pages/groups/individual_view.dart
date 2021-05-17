import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:disaster_management_ui/app_state/data/models/user.dart';
import 'package:disaster_management_ui/app_state/interface/widgets/map_ui/leaflet_ui.dart';
import 'package:disaster_management_ui/app_state/interface/widgets/view_components/custom_drawer.dart';
import 'package:disaster_management_ui/app_state/interface/widgets/view_components/register_disaster_button.dart';
import 'package:disaster_management_ui/utilities/remote_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';

class IndividualView extends StatefulWidget {
  final User user;

  const IndividualView({Key key, @required this.user}) : super(key: key);

  @override
  _IndividualViewState createState() => _IndividualViewState();
}

class _IndividualViewState extends State<IndividualView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final databaseRef = FirebaseDatabase.instance.reference();
  List<LatLng> cameraPath = [];
  List<List<double>> navigationPath = [];
  List<Map<String, dynamic>> disasterZone = [];
  LatLng cameraFocus;
  bool navigationMode = false;
  Timer timer;
  List<Marker> otherMarkers = [];

  Marker personMarker;
  int pathHolder = 1;

  CollectionReference writingLocation;
  CollectionReference disastersRef;

  //get and show safe houses only
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Firebase.initializeApp().then((value) {
      disastersRef = FirebaseFirestore.instance.collection('disasters');
      writingLocation = FirebaseFirestore.instance.collection('LiveLocation');
      final database = FirebaseDatabase.instance.reference();

      database.child("hospital_data").onValue.listen((event) {
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
                                    navigateToPoint(LatLng(
                                        double.parse(obj["latitude"]),
                                        double.parse(obj["longitude"])));
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
                      color: Colors.greenAccent,
                    ),
                    onPressed: () {
                      // navigateToPoint(
                      //     LatLng(point.latitude, point.longitude), 1);
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
    });

    personMarker = Marker(
        point: LatLng(53.3268, -6.31289),
        builder: (context) {
          return IconButton(
              icon: Icon(Icons.location_history), onPressed: () {});
        });
  }

  void navigateToPoint(LatLng point) async {
    try {
      var response = await RemoteService().getRoute({
        "lat1": point.longitude,
        "lon1": point.latitude,
        "lat2": personMarker.point.longitude,
        "lon2": personMarker.point.latitude,
        "avoidDisaster": "1",
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

  //show disasters
  Stream<Null> getStream() {
    Duration interval = Duration(milliseconds: 400);
    StreamController<Null> controller;
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
        if ((counter % 16) == 0) {
          updateLocation(this.widget.user,
              [personMarker.point.latitude, personMarker.point.longitude]);
        }
        if (pathHolder == navigationPath.length) {
          setState(() {
            navigationMode = false;
          });
          // timer.cancel();
        }
      }

      controller.add(null); // Ask stream to send counter values as event.
    }

    void startTimer() {
      timer = Timer.periodic(interval, tick);
    }

    void stopTimer() {
      if (timer != null) {
        // controller.close(); // Ask stream to shut down and tell listeners.
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
    // final user = await FirebaseAuth.instance.currentUser();
    String disId;
    for (var x in disasterZone) {
      GeoPoint tempPoint = x["epicentre"]["epicentre"];

      LatLng localPoint = LatLng(tempPoint.latitude, tempPoint.longitude);
      var current = getDistanceBetweenPoints(localPoint, personMarker.point);
      if (current < 0.0035) {
        // GeoPoint point = x["evacuationPoints"]["evacuationFrom"];
        disId = x["id"];
        if (x["individualsInDisaster"]["individualsStatus"][widget.user.email]
            ["markedSafe"]) {
          disastersRef.doc(disId).set({
            "individualsInDisaster": {
              "individualsStatus": {
                widget.user.email: {
                  "location": [
                    personMarker.point.latitude,
                    personMarker.point.longitude
                  ],
                  "markedSafe": false,
                },
              },
              "totalIndividuals":
                  x["individualsInDisaster"]["totalIndividuals"] + 1
            }
          }, SetOptions(merge: true));
        }
      } else {
        disId = x["id"];
        if (!x["individualsInDisaster"]["individualsStatus"][widget.user.email]
            ["markedSafe"]) {
          disastersRef.doc(disId).set({
            "individualsInDisaster": {
              "individualsStatus": {
                widget.user.email: {
                  "location": [
                    personMarker.point.latitude,
                    personMarker.point.longitude
                  ],
                  "markedSafe": true,
                },
              }
            }
          }, SetOptions(merge: true));
        }
      }
    }
// writingLocation
//     .doc(user.email)
//     .set({"group": user.groups, "location": location});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: CustomDrawer(
        user: widget.user,
        parentContext: context,
      ),
      body: Stack(
        children: [
          LeafLetMapUI(
            startPoint: cameraFocus ?? LatLng(53.3268, -6.31289),
            navigationPath: this.navigationPath,
            markers: otherMarkers ?? [],
            disasterZone: this.disasterZone,
            navigationMode: navigationMode,
            personMarker: personMarker,
            navigationStreamController: getStream(),
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
          RaisedButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  navigationMode ? " " : "Evacaution point",
                  maxLines: 2,
                ),
                Icon(Icons.near_me_rounded),
              ],
            ),
            color: Colors.blue,
            onPressed: navigationMode
                ? null
                : () async {
                    LatLng index;
                    double value = 10000000.0;
                    for (var x in disasterZone) {
                      GeoPoint tempPoint = x["epicentre"]["epicentre"];
                      LatLng localPoint =
                          LatLng(tempPoint.latitude, tempPoint.longitude);
                      var current = getDistanceBetweenPoints(
                          localPoint, personMarker.point);
                      if (current < value) {
                        GeoPoint point =
                            x["evacuationPoints"]["evacuationFrom"];
                        index = LatLng(point.latitude, point.longitude);
                      }
                    }
                    if (disasterZone.isNotEmpty) {
                      var temp = disasterZone.first;
                      GeoPoint tempPoint = temp["epicentre"]["epicentre"];
                      print("${tempPoint.latitude} , ${tempPoint.longitude}");
                    }
                    var response = await RemoteService().getRoute({
                      "lat1": index.longitude,
                      "lon1": index.latitude,
                      "lat2": personMarker.point.longitude,
                      "lon2": personMarker.point.latitude,
                      "avoidDisaster": "0",
                      "group": "some",
                    });
                    print(response);
                    this.setState(
                      () {
                        navigationPath =
                            getListOfCoordinates(response["coordinates"]);
                        cameraPath = [];
                        navigationMode = true;
                      },
                    );
                  },
          ),
          navigationMode
              ? RaisedButton(
                  color: Colors.blue,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    children: [
                      Text(
                        "Cancel navigation",
                      ),
                      Icon(Icons.cancel),
                    ],
                  ),
                  onPressed: () async {
                    this.setState(() {
                      navigationMode = false;
                    });
                  })
              : SizedBox(
                  width: 1,
                ),
          RaisedButton(
            color: Colors.blue,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Row(
              children: [
                Text(
                  navigationMode ? " " : "Safe house",
                ),
                Icon(Icons.near_me_rounded),
              ],
            ),
            onPressed: navigationMode
                ? null
                : () async {
                    var response = await RemoteService().evacuateUser({
                      "lat": personMarker.point.longitude,
                      "lon": personMarker.point.latitude
                    });
                    this.setState(
                      () {
                        navigationPath = getListOfCoordinates(
                            response["Dest0"]["route"]["coordinates"]);
                        cameraPath = [];
                        navigationMode = true;
                      },
                    );
                  },
          ),
        ],
      ),
    );
  }

  double getDistanceBetweenPoints(LatLng first, LatLng second) {
    return sqrt(pow((first.latitude - second.latitude), 2) +
        pow((first.longitude - second.longitude), 2));
  }

  List<List<double>> getListOfCoordinates(List<dynamic> list) {
    List<List<double>> tempList = [];
    for (var i in list) {
      List<double> localList = [];
      for (var j in i) {
        localList.insert(0, j);
      }
      tempList.insert(0, localList);
    }
    return tempList;
  }
}
