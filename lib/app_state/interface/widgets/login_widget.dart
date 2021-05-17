import 'package:disaster_management_ui/app_state/interface/bloc/app_state.dart';
import 'package:disaster_management_ui/app_state/interface/bloc/app_state_bloc.dart';
import 'package:disaster_management_ui/app_state/interface/bloc/bloc.dart';
import 'package:disaster_management_ui/app_state/interface/pages/sign_up_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passController = TextEditingController();
  final String message;

  LoginScreen({Key key, this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login"),
      ),
      body: Container(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                    labelText: "Email", hintText: "Enter your email here"),
                maxLines: 1,
              ),
              SizedBox(
                height: 15,
              ),
              TextField(
                obscureText: true,
                controller: passController,
                decoration: InputDecoration(
                    labelText: "Password",
                    hintText: "Enter your password here"),
                maxLines: 1,
              ),
              SizedBox(
                height: 15,
              ),
              Text(
                message ?? "",
                style: TextStyle(color: Colors.red),
              ),
              SizedBox(
                height: 15,
              ),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    FlatButton(
                      textColor: Colors.white,
                      onPressed: () {
                        if (emailController.text.isNotEmpty &&
                            passController.text.isNotEmpty) {
                          BlocProvider.of<AppStateBloc>(context).add(
                            LoginWithPass(
                                email: emailController.text,
                                password: passController.text),
                          );
                        } else {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text("Alert"),
                                  content: Text("There was some issue"),
                                  actions: [
                                    FlatButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text("OK"),
                                    )
                                  ],
                                );
                              });
                        }
                      },
                      child: Text("Login"),
                      color: Colors.green,
                    ),
                    FlatButton(
                      textColor: Colors.white,
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) {
                              return SignUpView();
                            },
                          ),
                        );
                      },
                      child: Text("Sign up"),
                      color: Colors.blueAccent,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
