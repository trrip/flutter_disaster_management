import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:disaster_management_ui/app_state/data/models/user.dart';
import 'package:disaster_management_ui/dependecy_injection/dependency_injection.dart';
import 'package:disaster_management_ui/utilities/remote_service.dart';
import 'package:disaster_management_ui/utilities/singleton_instances.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';

// import '../widgets/drawer.dart';
//car, bus, firetruck, ambulance, police marker,  hospital marker, roadblock
enum MarkerType {
  BUS,
  FIRE_TRUCK,
  POLICE,
  AMBULANCE,
  CAR,
  HOSPITAL,
  ROAD_BLOCK,
}

const BASE_ZOOM = 14.0;

const NAV_ZOOM = 16.0;

class CustomMarker {
  final MarkerType type;
  final LatLng location;

  CustomMarker({@required this.type, @required this.location});
}

class LeafLetMapUI extends StatefulWidget {
  static const String route = 'polyline';
  final User user;
  final LatLng startPoint;
  final List<List<double>> navigationPath;
  bool navigationMode = false;
  final List<Marker> markers;
  final List<Map<String, dynamic>> disasterZone;
  Stream<Null> navigationStreamController;
  final Marker personMarker;

  // final Function(LatLng) callbackHandler;

  LeafLetMapUI({
    Key key,
    @required this.startPoint,
    @required this.navigationPath,
    @required this.markers,
    @required this.disasterZone,
    @required this.navigationMode,
    @required this.navigationStreamController,
    @required this.personMarker,
    @required this.user,
    // @required this.callbackHandler,
  }) : super(key: key);

  @override
  _LeafLetMapUIState createState() => _LeafLetMapUIState();
}

class _LeafLetMapUIState extends State<LeafLetMapUI> {
  Marker localPerson;
  CollectionReference disastersRef;

  List<LatLng> getPolylines(List<List<double>> values) {
    if (values == null) return [];

    List<LatLng> list = [];
    for (var i in values) {
      list.add(LatLng(i[0], i[1]));
    }
    return list;
  }

  @override
  void initState() {
    super.initState();
    Firebase.initializeApp().then(
      (value) {
        disastersRef = FirebaseFirestore.instance.collection('disasters');
      },
    );
  }

  List<Marker> getRoadBlocksForAllDisasters(
      List<Map<String, dynamic>> disasters) {
    if (disasters == null) return [];
    List<Marker> markerList = [];
    for (var i in disasters) {
      for (var j in i["roadblocks"].keys) {
        var temp = i["roadblocks"][j]["location"];
        markerList.add(
          Marker(
            point: LatLng(temp[0], temp[1]),
            builder: (context) {
              return Container(
                child: IconButton(
                  icon: Icon(
                    Icons.block,
                    color:
                        i["roadblocks"][j]["active"] ? Colors.teal : Colors.red,
                  ),
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          if (widget.user.groups != 1) {
                            return AlertDialog(
                              title: Text("Only police can change the status"),
                              actions: [
                                FlatButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text("Ok"),
                                ),
                              ],
                            );
                          }
                          return AlertDialog(
                            title:
                                Text("Change the status of the road block ? "),
                            actions: [
                              FlatButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text("Cancel"),
                              ),
                              // FlatButton(
                              //   onPressed: () async {
                              //     var local = j;
                              //     DocumentReference ref = disastersRef
                              //         .doc(i["id"])
                              //         .collection("roadblocks")
                              //         .doc(local);
                              //     await ref.delete();
                              //
                              //     Navigator.of(context).pop();
                              //   },
                              //   child: Text("Remove"),
                              // ),
                              FlatButton(
                                onPressed: () async {
                                  disastersRef.doc(i["id"]).set({
                                    "roadblocks": {
                                      j: {
                                        "active": !i["roadblocks"][j]["active"]
                                      }
                                    }
                                  }, SetOptions(merge: true));
                                  Navigator.of(context).pop();
                                },
                                child: Text(i["roadblocks"][j]["active"]
                                    ? "Remove"
                                    : "Put"),
                              ),
                            ],
                          );
                        });
                    print("some roadblocks");
                  },
                ),
              );
            },
          ),
        );
      }
    }
    return markerList;
  }

  List<LatLng> getPolygon(List<dynamic> value) {
    if (value == null) return [];

    List<LatLng> list = [];

    for (var i in value) {
      list.add(LatLng(i[0], i[1]));
    }
    // print(list);
    return list;
  }

  @override
  Widget build(BuildContext context) {
    print("0000");
    int resultValue = 1;
    GlobalKey _mapKey = GlobalKey();
    return FlutterMap(
      key: _mapKey,
      options: MapOptions(
        onTap: (point) {
          showDialog(
              context: context,
              builder: (context) {
                return RegisterAlert(
                  dismiss: () {
                    Navigator.of(context).pop();
                  },
                  user: widget.user,
                  personMarker: widget.personMarker,
                  point: point,
                );
              });
        },
        allowPanning: true,
        center: this.widget.navigationMode
            ? widget.personMarker.point
            : widget.personMarker.point,
        zoom: this.widget.navigationMode ? NAV_ZOOM : BASE_ZOOM,
      ),
      layers: [
        TileLayerOptions(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: ['a', 'b', 'c']),
        PolygonLayerOptions(
            polygonCulling: true,
            polygons: this.widget.disasterZone.map((e) {
              // if (e["polygon"] == null) return [];
              var json = jsonDecode(e["polygon"]);
              return Polygon(
                points: getPolygon(json["coordinates"][0]),
                color: Color(0x54007E2D),
              );
            }).toList()),
        PolylineLayerOptions(
          polylines: [
            Polyline(
              points: getPolylines(widget.navigationPath),
              strokeWidth: 4.0,
              color: Color(0xff007E2D),
            ),
          ],
        ),
        MarkerLayerOptions(
          rebuild: widget.navigationStreamController,
          markers: [widget.personMarker] +
              widget.markers +
              getRoadBlocksForAllDisasters(widget.disasterZone),
        ),
      ],
    );
  }

  void getStreamForNavigation() {
    // return
  }
}

class RegisterAlert extends StatefulWidget {
  const RegisterAlert({
    Key key,
    @required this.dismiss,
    @required this.point,
    @required this.user,
    @required this.personMarker,
  }) : super(key: key);

  final Function dismiss;
  final LatLng point;
  final User user;
  final Marker personMarker;

  @override
  _RegisterAlertState createState() => _RegisterAlertState();
}

class _RegisterAlertState extends State<RegisterAlert> {
  int selectedValue = 1;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Select one of the following"),
      content: DropdownButton(
        value: selectedValue,
        onChanged: (value) {
          // resultValue = value;
          setState(() {
            selectedValue = value;
          });
        },
        items: [
          DropdownMenuItem(
            child: Text("Fire"),
            value: 1,
          ),
          DropdownMenuItem(
            child: Text("Shooting"),
            value: 2,
          ),
          DropdownMenuItem(
            child: Text("Flooding"),
            value: 3,
          ),
          DropdownMenuItem(
            child: Text("Bomb"),
            value: 4,
          ),
          DropdownMenuItem(
            child: Text("EarthQuake"),
            value: 5,
          )
        ],
      ),
      actions: [
        FlatButton(
            onPressed: () async {
              var response = await RemoteService().registerDisaster({
                "user": widget.user.email,
                "lat": widget.point.longitude,
                "lon": widget.point.latitude,
                "user_type": selectedValue
              });
              widget.dismiss();
            },
            child: Text("Report a disaster")),
        FlatButton(
          onPressed: () async {
            Navigator.of(context).pop();
            widget.personMarker.point.latitude = widget.point.latitude;
            widget.personMarker.point.longitude = widget.point.longitude;
            // widget.navigationStreamController
          },
          child: Text("Select location"),
        )
      ],
    );
  }
}
