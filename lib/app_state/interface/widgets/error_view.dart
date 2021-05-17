import 'package:flutter/material.dart';

class ErrorViewWithText extends StatelessWidget {
  final String message;

  const ErrorViewWithText({Key key, this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
          child: Text("error : $message"),
        ),
      ),
    );
  }
}
