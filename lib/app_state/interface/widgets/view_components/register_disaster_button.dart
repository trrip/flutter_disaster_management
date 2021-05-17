import 'package:disaster_management_ui/utilities/remote_service.dart';
import 'package:flutter/material.dart';

class RegisterDisasterButton extends StatelessWidget {
  const RegisterDisasterButton({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: Colors.red,
        child: Row(
          children: [
            Text(
              "Register disaster  ",
              style: TextStyle(color: Colors.white),
            ),
            Icon(Icons.warning_amber_rounded)
          ],
        ),
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text("Select a disaster type"),
                  content: Container(
                    height: 100,
                    child: Column(
                      children: [
                        DropdownButton(items: [
                          DropdownMenuItem(
                            child: Text("super"),
                            value: "1",
                          ),
                          DropdownMenuItem(
                            child: Text("super"),
                            value: "2",
                          ),
                          DropdownMenuItem(
                            child: Text("super"),
                            value: "3",
                          )
                        ], onChanged: (value) {}),
                        Text("select some disaster"),
                      ],
                    ),
                  ),
                  actions: [
                    //TODO: adding the button functions
                    FlatButton(
                        onPressed: () {
                          // RemoteService(). register a disaster
                        },
                        child: Text("OK")),
                    FlatButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text("Cancel"))
                  ],
                );
              });
        });
  }
}
