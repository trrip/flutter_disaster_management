import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:latlong/latlong.dart';

class TaskModel extends Equatable {
  final String authorFirstName;
  final String authorLastName, title, content;
  final DateTime timeCreated;
  final int group;
  final String disasterId;
  final String doneStats;
  final String uid;
  final String taskid;

  // final LatLng location;

  TaskModel({
    // @required this.location,
    @required this.authorFirstName,
    @required this.authorLastName,
    @required this.title,
    @required this.content,
    @required this.timeCreated,
    @required this.group,
    @required this.disasterId,
    @required this.doneStats,
    @required this.uid,
    @required this.taskid,
  })  : assert(content != null),
        assert(timeCreated != null),
        assert(group != null);

  @override
  // TODO: implement props
  List<Object> get props =>
      [authorFirstName, authorLastName, title, content, group, doneStats];
}

class Task extends TaskModel {
  Task({
    String authorFirstName,
    String authorLastName,
    String title,
    String content,
    int group,
    DateTime timeCreated,
    String disasterId,
    String doneStats,
    String uid,
    String taskId,
    // LatLng location,
  }) : super(
          // location: location,
          authorFirstName: authorFirstName,
          authorLastName: authorLastName,
          title: title,
          content: content,
          group: group,
          timeCreated: timeCreated,
          disasterId: disasterId,
          doneStats: doneStats,
          uid: uid,
          taskid: taskId,
        );

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      authorFirstName: json["authorFirstName"],
      authorLastName: json["authorLastName"],
      content: json["content"],
      title: json["title"],
      disasterId: json["disasterId"],
      group: int.parse(json["groupId"].split("-")[0]),
      doneStats: json["status"],
      uid: json["uid"],
      taskId: json["taskId"],
      // location: LatLng(json["location"][0], json["location"][1]),
      timeCreated: DateTime.fromMicrosecondsSinceEpoch(
        json["createdAt"].seconds,
      ),
    );
  }

  Map<String, dynamic> getJson() {
    return {
      "authorFirstName": authorFirstName,
      "authorLastName": authorLastName,
      "content": content,
      "title": title,
      "groupId": "$group",
      "disasterId": disasterId,
      "status": doneStats,
      "uid": uid,
      "taskId": taskid,

      // "location": [location.latitude, location.longitude],
      "createdAt": timeCreated.toString(),
    };
  }
}
