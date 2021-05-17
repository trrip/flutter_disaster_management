import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:disaster_management_ui/app_state/interface/pages/app_main_page.dart';
import 'package:disaster_management_ui/app_state/interface/widgets/view_components/draggable_notification_center.dart';
import 'package:disaster_management_ui/dependecy_injection/dependency_injection.dart';
import 'file:///C:/Users/choud/AndroidStudioProjects/disaster_management_ui/lib/app_state/interface/widgets/map_ui/leaflet_ui.dart';
import 'file:///C:/Users/choud/AndroidStudioProjects/disaster_management_ui/lib/app_state/interface/widgets/view_components/disaster_information_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:latlong/latlong.dart';

import 'package:disaster_management_ui/dependecy_injection/dependency_injection.dart'
    as di;
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle.dark.copyWith(
        statusBarBrightness:
            Brightness.dark // Dark == white status bar -- for IOS.
        ),
  );
  WidgetsFlutterBinding.ensureInitialized();
  await di.dependencyInit(
      sharedPreferences: await SharedPreferences.getInstance());
  runApp(MyApp());
}

/// This is the main application widget.
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: App(),
    );
  }
}
