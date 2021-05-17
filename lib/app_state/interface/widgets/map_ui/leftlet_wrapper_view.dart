// import 'package:disaster_management_ui/app_state/data/models/user.dart';
// import 'package:disaster_management_ui/app_state/interface/bloc/app_state_bloc.dart';
// import 'package:disaster_management_ui/app_state/interface/bloc/bloc.dart';
// import 'package:disaster_management_ui/app_state/interface/widgets/map_ui/leaflet_ui.dart';
// import 'package:disaster_management_ui/app_state/interface/widgets/view_components/custom_drawer.dart';
// import 'package:disaster_management_ui/app_state/interface/widgets/view_components/disaster_information_page.dart';
// import 'package:disaster_management_ui/app_state/interface/widgets/view_components/draggable_notification_center.dart';
// import 'package:disaster_management_ui/app_state/interface/widgets/view_components/register_disaster_button.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:latlong/latlong.dart';
//
// class LeafletMapWrapperView extends StatefulWidget {
//   final User user;
//
//   const LeafletMapWrapperView({Key key, @required this.user}) : super(key: key);
//
//   @override
//   _LeafletMapWrapperViewState createState() => _LeafletMapWrapperViewState();
// }
//
// class _LeafletMapWrapperViewState extends State<LeafletMapWrapperView> {
//   final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
//
//   LatLng cameraFocus;
//
//   @override
//   Widget build(BuildContext context) {
//     TextEditingController _searchQueryController = TextEditingController();
//     return Scaffold(
//       key: _scaffoldKey,
//       drawer: CustomDrawer(
//         widget: widget,
//         parentContext: context,
//       ),
//       body: Stack(
//         children: [
//           LeafLetMapUI(
//             startPoint: cameraFocus,
//             navigationPath: this.navigationPath,
//             markers: [],
//             disasterZone: this.disasterZone,
//           ),
//           Positioned(
//             right: 20.0,
//             top: 40.0,
//             child: FloatingActionButton(
//                 mini: true,
//                 child: Icon(Icons.monetization_on),
//                 onPressed: () {
//                   _scaffoldKey.currentState.openDrawer();
//                 }),
//           ),
//           Positioned(
//             left: 20.0,
//             bottom: 90.0,
//             child: RegisterDisasterButton(),
//           ),
//         ],
//       ),
//       floatingActionButton: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: [
//           SizedBox(
//             width: 25,
//           ),
//           Stack(
//             children: [
//               FloatingActionButton(
//                 heroTag: "number 2",
//                 child: Icon(Icons.list),
//                 tooltip: "2",
//                 onPressed: () {
//                   showModalBottomSheet(
//                     backgroundColor: Colors.transparent,
//                     context: context,
//                     isScrollControlled: true,
//                     builder: (context) {
//                       return NotificationCenter(); // do more improvements over this.
//                     },
//                   );
//                 },
//               ),
//               Positioned(
//                 right: 0,
//                 top: 0,
//                 child: Container(
//                   width: 20,
//                   height: 20,
//                   decoration: BoxDecoration(
//                       color: Colors.red,
//                       borderRadius: BorderRadius.all(Radius.circular(10.0))),
//                   child: Center(
//                     child: Text(
//                       "1",
//                       style: TextStyle(color: Colors.white),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           FloatingActionButton(
//               heroTag: "number 1",
//               child: Icon(Icons.add),
//               onPressed: () {
//                 Navigator.of(context)
//                     .push(MaterialPageRoute(builder: (context) {
//                   return DisasterInformationPage();
//                 }));
//               }),
//           FloatingActionButton(
//               heroTag: "number 3",
//               child: Icon(Icons.near_me_rounded),
//               onPressed: () {
//                 this.setState(() {
//                   // startPoint = LatLng(
//                   //   // some point
//                   //   53.36903,
//                   //   -6.25482,
//                   // );
//                 });
//               }),
//           SizedBox(
//             width: 25,
//           ),
//         ],
//       ),
//     );
//   }
// }
