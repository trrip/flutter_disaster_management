import 'package:flutter/material.dart';

class DisasterInformationPage extends StatelessWidget {
  final String information;

  const DisasterInformationPage({Key key, @required this.information})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Disaster information page"),
      ),
      body: Center(
        child: Text("This is the demo information page"),
      ),
    );
  }
}
