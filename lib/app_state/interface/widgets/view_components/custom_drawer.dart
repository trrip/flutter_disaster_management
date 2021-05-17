import 'package:disaster_management_ui/app_state/data/models/user.dart';
import 'package:disaster_management_ui/app_state/interface/bloc/bloc.dart';
import 'package:disaster_management_ui/app_state/interface/widgets/map_ui/leftlet_wrapper_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({
    Key key,
    @required this.user,
    @required this.parentContext,
  }) : super(key: key);

  final User user;
  final BuildContext parentContext;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Container(
              child: Row(
                children: [
                  CircleAvatar(
                    child: CircleAvatar(),
                    foregroundColor: Colors.redAccent,
                    radius: 50,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 18.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(this.user.firstName),
                        Container(
                          width: 150,
                          child: Text(
                            GROUPS[this.user.groups],
                            style: TextStyle(
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
          ),
          ListTile(
            title: Text('Logout'),
            onTap: () {
              BlocProvider.of<AppStateBloc>(parentContext).add(
                Logout(),
              );
            },
          ),
        ],
      ),
    );
  }
}
