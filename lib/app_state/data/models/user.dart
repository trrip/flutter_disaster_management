import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

const FIRST_NAME_KEY = "user";
const LAST_NAME_KEY = "lastName";
const GROUP_KEY = "group";
const EMAIL_KEY = "email";

const List<String> GROUPS = [
  "Individual",
  "Police Service",
  "Fire Service",
  "Emergency Evacuators",
  "Paramedics",
  "Emergency Response Coordinators"
];

enum SEXUAL_PREFERENCE {
  MALE,
  FEMALE,
  OTHERS,
}

class UserModel extends Equatable {
  //personal information
  final String firstName;

  // final SEXUAL_PREFERENCE sexualPref;
  // final int age;
  // final LatLng currentLocation;
  //
  //groups
  final int groups;
  final String email;

  //group//
  // police 1
  // fire 2
  // ambulance 3
  // individual 4
  // e
  // admin 5

  //other information
  // final bool workingStatus ;
  UserModel({
    @required this.firstName,
    @required this.groups,
    @required this.email,
  })  : assert(email != null),
        assert(groups != null);

  @override
  // TODO: implement props
  List<Object> get props => [firstName, email, groups];
}

class User extends UserModel {
  User({
    @required String firstName,
    @required int groups,
    @required String email,
  }) : super(
          firstName: firstName,
          groups: groups,
          email: email,
        );

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
        firstName: json[FIRST_NAME_KEY] ?? "",
        groups: json[GROUP_KEY],
        email: json[EMAIL_KEY]);
  }

  Map<String, dynamic> getJson() {
    return {
      FIRST_NAME_KEY: firstName,
      GROUP_KEY: groups,
      EMAIL_KEY: email,
    };
  }
}
