import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Activity {
  String creatorUID;
  List<String> joinRequests;
  List<String> joinAccepted;
  String title;
  String description;
  String location;
  Timestamp dateTime;
  String picture;
  String documentID;

  Activity(
      {@required String title,
      @required String location,
      @required Timestamp dateTime,
      String picture,
      String description,
      String creatorUID,
      String documentID,
      List<String> joinRequests,
      List<String> joinAccepted}) {
    this.title = title;
    this.location = location;
    this.dateTime = dateTime;
    this.description = description;
    this.picture = picture;
    this.creatorUID = creatorUID;
    this.joinAccepted = joinAccepted; // list of people who joined successfully
    this.joinRequests =
        joinRequests; // list of people who wont to join the activity
    this.documentID =
        documentID; // the id of the document to find and delete it later (its the same as the document name uid)

    //set default text if no description is provided
    this.description ??= '';
    // set default picture if no picture was provided
    this.picture ??= 'https://picsum.photos/300/300';
  }

  static List<Activity> filteredActivityList =
      []; // the list wich event_list_widget reads and explore_searchbar manipulates accordingly

  // in this list all current activities are put
  static List<Activity> activityList = [];
}
