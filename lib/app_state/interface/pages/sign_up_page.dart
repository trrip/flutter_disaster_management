import 'dart:async';

import 'package:disaster_management_ui/app_state/data/datasource/user_remote_data_source.dart';
import 'package:disaster_management_ui/app_state/data/models/user.dart';
import 'package:disaster_management_ui/dependecy_injection/dependency_injection.dart';
import 'package:disaster_management_ui/utilities/remote_service.dart';
import 'package:disaster_management_ui/utilities/service.dart';
import 'package:flutter/material.dart';

typedef SingleArgBoolFunction = void Function(bool value);

class SignUpView extends StatefulWidget {
  final SingleArgBoolFunction successCallback;

  const SignUpView({Key key, this.successCallback}) : super(key: key);

  @override
  _SignUpViewState createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  String _response = "";
  final TextEditingController _pass = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _name = TextEditingController();

  int selectedValue;

  bool _isLoggingUnderProcess = false;
  bool loading = false;

  @override
  void initState() {
    selectedValue = 0;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    return Scaffold(
      appBar: AppBar(
        title: Text("Sign up"),
      ),
      body: Container(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      enabled: !_isLoggingUnderProcess,
                      autocorrect: false,
                      controller: _email,
                      validator: (value) {
                        if (value.isEmpty) {
                          return "Please enter Email Address";
                        }
                        bool emailValid = RegExp(
                                r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                            .hasMatch(value);

                        if (!emailValid) {
                          return "Enter valid Email";
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: "Email Address",
                        hintText: "Email Address",
                        isDense: false,
                        border: UnderlineInputBorder(),
                        // labelText: "Email id",
                      ),
                    ),
                    TextFormField(
                      enabled: !_isLoggingUnderProcess,
                      autocorrect: false,
                      controller: _pass,
                      validator: (value) {
                        if (value.isNotEmpty && value.length >= 8) {
                          return null;
                        }
                        return "Password must not be empty";
                      },
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: "Password",
                        hintText: "Password",
                        isDense: false,
                        border: UnderlineInputBorder(),
                      ),
                    ),
                    TextFormField(
                      enabled: !_isLoggingUnderProcess,
                      autocorrect: false,
                      controller: _name,
                      validator: (value) {
                        if (value.isNotEmpty && value.length >= 4) {
                          return null;
                        }
                        return "Name must have at least 4 letters";
                      },
                      decoration: InputDecoration(
                        labelText: "Name",
                        hintText: "Name",
                        border: UnderlineInputBorder(),
                      ),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text("Group : "),
                        SizedBox(
                          width: 10,
                        ),
                        DropdownButton<int>(
                            value: selectedValue,
                            items: GROUPS
                                .map((e) => DropdownMenuItem<int>(
                                      child: Text(e),
                                      value: GROUPS.indexOf(e),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedValue = value;
                              });
                            }),
                      ],
                    ),
                    _response != ""
                        ? Text(
                            _response,
                            style: TextStyle(color: Colors.red),
                          )
                        : Center(),
                    SizedBox(
                      height: 40,
                    ),
                    Center(
                      child: Container(
                        child: FlatButton(
                          color: Colors.teal,
                          onPressed: () async {
                            if (_formKey.currentState.validate()) {
                              User user = User(
                                  email: _email.text,
                                  firstName: _name.text,
                                  groups: selectedValue);
                              DependenctInjector<UserRemoteDataSource>()
                                  .registerUser(
                                      user: user, password: _pass.text)
                                  .then(
                                (value) {
                                  if (value) {
                                    Navigator.of(context).pop();
                                  } else {
                                    setState(
                                      () {
                                        _response =
                                            "There was some kind of issue";
                                        _isLoggingUnderProcess = false;
                                      },
                                    );
                                  }
                                },
                              );
                              setState(
                                () {
                                  _isLoggingUnderProcess = true;
                                },
                              );
                            }
                          },
                          child: Container(
                            child: _isLoggingUnderProcess
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text("Signing ...",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14)),
                                      SizedBox(
                                        width: 20,
                                      ),
                                      SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    Colors.white),
                                          )),
                                    ],
                                  )
                                : Text("Sign Up",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 14)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
