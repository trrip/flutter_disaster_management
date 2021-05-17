import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:disaster_management_ui/app_state/data/models/task.dart';
import 'package:disaster_management_ui/app_state/interface/pages/sign_up_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

// class Task {
//   final String name, content, title;
//
//   Task({@required this.name, @required this.content, @required this.title});
//
//   factory Task.fromJson(Map<dynamic, dynamic> json) {
//     return Task(
//         name: json["Name"], content: json["content"], title: json["title"]);
//   }
// }

typedef SingleArgStringFunction = void Function(String disaster, Task task);

class NotificationCenter extends StatefulWidget {
  final List<Task> tasks;
  final SingleArgStringFunction callbackHandler;

  const NotificationCenter({
    Key key,
    @required this.tasks,
    @required this.callbackHandler,
  }) : super(key: key);

  @override
  _NotificationCenterState createState() => _NotificationCenterState();
}

class _NotificationCenterState extends State<NotificationCenter> {
  // final databaseRef = FirebaseDatabase.instance.reference();
  CollectionReference tasksRef;
  CollectionReference disasterRef;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Firebase.initializeApp().then((value) {
      tasksRef = FirebaseFirestore.instance.collection('tasks');
      disasterRef = FirebaseFirestore.instance.collection("disasters");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
      decoration: BoxDecoration(
        // backgroundBlendMode: BlendMode.clear,
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.3,
        maxChildSize: 0.9,
        minChildSize: 0.1,
        builder: (context, scrollController) {
          return ListView.builder(
            controller: scrollController,
            itemCount: widget.tasks.length + 1,
            itemBuilder: (BuildContext context, int index) {
              if (index == 0) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.keyboard_arrow_up,
                          size: 35,
                        ),
                        Text(
                          "Tasks",
                          style: TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                );
              }
              Task currentTask = widget.tasks[index - 1];
              return Padding(
                padding: const EdgeInsets.only(
                    left: 8.0, right: 8.0, bottom: 3.0, top: 3.0),
                child: Card(
                  color: currentTask.doneStats == "Active"
                      ? Colors.deepPurple
                      : Colors.lightGreen,
                  elevation: 5.0,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListTile(
                      trailing: currentTask.doneStats == "Active"
                          ? Wrap(children: [
                              (currentTask.group == 2 ||
                                          currentTask.group == 3) &&
                                      currentTask.taskid.contains("2-")
                                  ? Container(
                                      width: 1,
                                    )
                                  : IconButton(
                                      icon: Icon(
                                        Icons.near_me,
                                        color: Colors.white,
                                      ),
                                      onPressed: () {
                                        widget.callbackHandler(
                                            currentTask.disasterId,
                                            currentTask);
                                      },
                                    ),
                              IconButton(
                                icon: Icon(
                                  Icons.check,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  var values = tasksRef.get();
                                  values.then((value) {
                                    for (var i in value.docs) {
                                      var data = i.data();
                                      if (data["uid"] == currentTask.uid) {
                                        data["status"] = "Done";
                                        print(data);
                                        tasksRef.doc(i.id).set(data);
                                        break;
                                      }
                                    }
                                  });
                                  var disasters = disasterRef.get();
                                  disasters.then((value) {
                                    for (var i in value.docs) {
                                      var data = i.data();
                                      if (i.id == currentTask.disasterId) {
                                        if (currentTask.group == 2) {
                                          data["activeEmergencyResponse"]
                                              ["fireService"] = true;
                                          if (currentTask.taskid
                                              .contains("2-")) {
                                            data["firePresent"] = false;
                                          }
                                        } else if (currentTask.group == 1) {
                                          data["activeEmergencyResponse"]
                                              ["police"] = true;
                                        } else if (currentTask.group == 3) {
                                          data["activeEmergencyResponse"]
                                              ["emergencyEvacuator"] = true;
                                          if (currentTask.taskid
                                              .contains("2-")) {
                                            data["evacuationComplete"] = true;
                                          }
                                        }
                                        disasterRef.doc(i.id).set(data);
                                        break;
                                      }
                                    }
                                  });
                                  Navigator.of(context).pop();
                                },
                              ),
                            ])
                          : InkWell(
                              onTap: () {
                                Navigator.of(context).pop();
                              },
                              child: Text(
                                "Done",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                      title: Text(
                        currentTask.title,
                        style: TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        currentTask.content,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
