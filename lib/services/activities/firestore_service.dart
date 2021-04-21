import 'dart:async';

import 'package:Aiya/data_models/activity_data.dart';
import 'package:Aiya/data_models/profile_data.dart';
import 'package:Aiya/services/user/auth_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emojis/emojis.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FirestoreService {
  // get a handle to the firestore instance
  final FirebaseFirestore _firebaseInstance = FirebaseFirestore.instance;

  // upload activity to collection "activities" and show a snackbar accordingly
  Future<void> createActivity(
      {@required String eventTitle,
      @required String eventLocation,
      @required DateTime dateTime,
      @required BuildContext context}) async {
    final UID = await Provider.of<AuthProvider>(context, listen: false)
        .auth
        .getCurrentUID();

    // create activity and save documentID
    var _documentID = await _firebaseInstance.collection('activities').add({
      'creatorUID': UID,
      'location': eventLocation,
      'title': eventTitle,
      'dateTime': dateTime ??= DateTime.now()
    });

    // set documentID as a field as activityID after document is assigned a random ID (after creation)
    await _firebaseInstance
        .doc(_documentID.path)
        .set({
          'activityID': _documentID.path,
        }, SetOptions(merge: true))
        .then((value) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Created Activity ${Emojis.partyingFace}'),
              action: SnackBarAction(
                onPressed: () =>
                    ScaffoldMessenger.of(context).removeCurrentSnackBar(),
                label: 'OK',
              ),
            )))
        .catchError(
            (error) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('$error ${Emojis.crossMark}'),
                action: SnackBarAction(
                  onPressed: () =>
                      ScaffoldMessenger.of(context).removeCurrentSnackBar(),
                  label: 'OK',
                ))));
  }

  Future<void> updateActivity(
      {@required String eventTitle,
      @required String eventLocation,
      @required DateTime dateTime,
      @required String activityUID,
      @required BuildContext context}) async {
    final UID = await Provider.of<AuthProvider>(context, listen: false)
        .auth
        .getCurrentUID();

    // create activity and save documentID
    var _documentID = await _firebaseInstance
        .collection('activities')
        .doc(activityUID)
        .update({
      'creatorUID': UID,
      'location': eventLocation,
      'title': eventTitle,
      'dateTime': dateTime ??= DateTime.now()
    });
  }

  Future<void> joinRequest(
      {@required BuildContext context, @required String activityUID}) async {
    final _userUID = await Provider.of<AuthProvider>(context, listen: false)
        .auth
        .getCurrentUID();
    // get activity data
    var _activityData =
        await _firebaseInstance.collection('activities').doc(activityUID).get();
    // save old join requests if there any
    List<dynamic> _oldJoinRequestsAsDynamic =
        _activityData.data()['joinRequests'] ??= <String>[];
    // convert list from dynamic to string (because firebase gives this back as a dynamic for some reason)
    var _oldJoinRequests = List<String>.from(_oldJoinRequestsAsDynamic);
    // create new list where all new join requests are stored
    // add the one new join request to the list
    _oldJoinRequests.add(_userUID);

    await _firebaseInstance.collection('activities').doc(activityUID).set({
      'joinRequests': _oldJoinRequests,
    }, SetOptions(merge: true));
  }

  /* Future<bool> isJoined(
      {@required String documentID, @required BuildContext context}) async {
    var userUID = await Provider.of<AuthProvider>(context).auth.getCurrentUID();
    var _activityData =
        await _firebaseInstance.collection('activities').doc(documentID).get();
    var _joinRequestsAsDynamic =
        _activityData?.data()['joinAccept'] ??= <String>[];
    var _joinRequests = List<String>.from(_joinRequestsAsDynamic);
    return _joinRequests.contains(userUID) ? true : false;
  }*/

  Stream<String> getJoinState(
      {@required String documentID,
      @required BuildContext context,
      @required String userUID}) async* {
    var querySnapshot =
        _firebaseInstance.collection('activities').doc(documentID).snapshots();

    await for (final entry in querySnapshot) {
      var _joinRequestsAsDynamic = entry?.data()['joinRequests'] ??= <String>[];
      var _joinAcceptedAsDynamic = entry?.data()['joinAccept'] ??= <String>[];
      var _activityCreator = entry.data()['creatorUID'];
      var _joinRequests = List<String>.from(_joinRequestsAsDynamic);
      var _joinAccepted = List<String>.from(_joinRequestsAsDynamic);

      // gives back a string depending on if the user is the creator, has requested to join or has his join request accepted
      if (_joinRequests.contains(userUID)) {
        yield 'joinRequested';
      } else if (_activityCreator == userUID) {
        yield 'activityCreator';
      } else if (_joinAccepted.contains(userUID)) {
        yield 'joinAccepted';
      } else {
        yield '';
      }
    }
  }

  Stream<bool> isJoinedAcceptedAsStream(
      {@required String documentID,
      @required BuildContext context,
      @required String userUID}) async* {
    var querySnapshot =
        _firebaseInstance.collection('activities').doc(documentID).snapshots();

    await for (final entry in querySnapshot) {
      var _joinRequestsAsDynamic = entry?.data()['joinAccept'] ??= <String>[];
      var _activityCreator = entry.data()['creatorUID'];
      var _joinRequests = List<String>.from(_joinRequestsAsDynamic);
      if (_joinRequests.contains(userUID) || _activityCreator == userUID) {
        yield true;
      } else {
        yield false;
      }
    }
  }

  Future<void> joinAccept(
      {@required BuildContext context,
      @required String activityUID,
      @required String userUID}) async {
    // get activity data
    var _activityData =
        await _firebaseInstance.collection('activities').doc(activityUID).get();

    // save old accepted join requests if there are any
    List<dynamic> _oldAcceptedJoinRequestsAsDynamic =
        _activityData.data()['joinAccept'] ??= <String>[];
    // save old join requests if there are any
    List<dynamic> _oldJoinRequestsAsDynamic = _activityData['joinRequests'];

    var _oldJoinRequests = List<String>.from(_oldJoinRequestsAsDynamic);
    var _oldAcceptedJoinRequests =
        List<String>.from(_oldAcceptedJoinRequestsAsDynamic);
    // create new list where all accepted join requests are stored
    var _newAcceptedJoinRequests = <String>[];

    // delete the accepted request from requests
    _oldJoinRequests.remove(userUID);
    // add all the old accepted join requests (without) to the new list
    _newAcceptedJoinRequests.addAll(_oldAcceptedJoinRequests);

    // add the one new join request to the list
    _newAcceptedJoinRequests.add(userUID);

    // TODO: clean this up (no use for two lists)
    // upload new joinRequests without the accepted one
    await _firebaseInstance.collection('activities').doc(activityUID).set({
      'joinRequests': _oldJoinRequests,
    }, SetOptions(merge: true));

    // upload new accepted join requests with the new one
    await _firebaseInstance
        .collection('activities')
        .doc(activityUID)
        .set({
          'joinAccept': _newAcceptedJoinRequests,
        }, SetOptions(merge: true))
        .then((value) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Join Accepted ${Emojis.partyingFace}'),
              action: SnackBarAction(
                onPressed: () =>
                    ScaffoldMessenger.of(context).removeCurrentSnackBar(),
                label: 'OK',
              ),
            )))
        .catchError(
            (error) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('$error ${Emojis.crossMark}'),
                action: SnackBarAction(
                  onPressed: () =>
                      ScaffoldMessenger.of(context).removeCurrentSnackBar(),
                  label: 'OK',
                ))));
  }

  Future<void> joinDeny(
      {@required BuildContext context,
      @required String activityUID,
      String userUID}) async {
    userUID ??= await Provider.of<AuthProvider>(context, listen: false)
        .auth
        .getCurrentUID();
    // get activity data
    var _activityData =
        await _firebaseInstance.collection('activities').doc(activityUID).get();
    // save old join requests if there any
    List<dynamic> _oldJoinRequestsAsDynamic =
        _activityData.data()['joinRequests'] ??= <String>[];
    // convert list from dynamic to string (because firebase gives this back as a dynamic for some reason)
    var _oldJoinRequests = List<String>.from(_oldJoinRequestsAsDynamic);
    // remove one join request from the list
    _oldJoinRequests.remove(userUID);

    await _firebaseInstance.collection('activities').doc(activityUID).set({
      'joinRequests': _oldJoinRequests,
    }, SetOptions(merge: true));
  }

  Future<void> joinRemove(
      {@required BuildContext context,
      @required String activityUID,
      String userUID}) async {
    // get activity data
    var _activityData =
        await _firebaseInstance.collection('activities').doc(activityUID).get();
    // save old join accepted requests if there any
    List<dynamic> _oldJoinRequestsAsDynamic =
        _activityData.data()['joinAccept'] ??= <String>[];
    // convert list from dynamic to string (because firebase gives this back as a dynamic for some reason)
    var _oldJoinRequests = List<String>.from(_oldJoinRequestsAsDynamic);
    // remove one join request from the list
    _oldJoinRequests.remove(userUID);

    await _firebaseInstance.collection('activities').doc(activityUID).set({
      'joinAccept': _oldJoinRequests,
    }, SetOptions(merge: true));
  }

  /* // get activities continuously and gets updates when activities are changed, deleted, created
  Stream<List<Activity>> getAllActivitiesContinuously() async* {
    var querySnapshot = _firebaseInstance.collection('activities').snapshots();
    await for (final event in querySnapshot) {
      final events = event.docs
          .map((e) => Activity(
              title: e.get('title'),
              location: e.get('location'),
              dateTime: e.get('dateTime')))
          .toList();
      yield events;
    }
  }*/

  // gets all activates one time and is not a real stream
  Stream<List<Activity>> getActivitiesOneTime() async* {
    // TODO: make sure that keys exist or implement a fail safe
    List<Activity> activityList;
    var querySnapshot = await _firebaseInstance.collection('activities').get();
    activityList = querySnapshot.docs
        .map((e) => Activity(
            title: e.get('title'),
            location: e.get('location'),
            dateTime: e.get('dateTime'),
            documentID: e.id,
            creatorUID: e.get('creatorUID'),
            joinRequests:
                List<String>.from(e.data()['joinRequests'] ??= <String>[]),
            joinAccepted:
                List<String>.from(e.data()['joinAccept'] ??= <String>[]),
            description: e.data()['description'] ??= ''))
        .toList();
    yield activityList;
  }

  // gets all activities the user has created
  Future<List<Activity>> getMyActivities(BuildContext context) async {
    var UID = await Provider.of<AuthProvider>(context, listen: false)
        .auth
        .getCurrentUID();
    var activityList = <Activity>[];
    var querySnapshot = await _firebaseInstance
        .collection('activities')
        .where('creatorUID', isEqualTo: UID)
        .get();
    activityList = querySnapshot.docs
        .map((e) => Activity(
            title: e.get('title'),
            location: e.get('location'),
            dateTime: e.get('dateTime'),
            documentID: e.id,
            creatorUID: e.get('creatorUID'),
            joinRequests:
                List<String>.from(e.data()['joinRequests'] ??= <String>[]),
            joinAccepted:
                List<String>.from(e.data()['joinAccept'] ??= <String>[]),
            description: e.data()['description'] ??= ''))
        .toList();
    return activityList;
  }

  Future<String> deleteActivity({@required String documentPath}) async {
    await _firebaseInstance
        .collection('activities')
        .doc(documentPath)
        .delete()
        .then((value) {
      return 'Activity deleted';
    }).catchError((error) {
      return ('Something went wrong: $error');
    });
    return '';
  }

  Future<void> setAdditionalUserData(
      {String age,
      String uid,
      List<String> interests,
      String name,
      String tagLine,
      String photoURL,
      String phoneNumber,
      @required BuildContext context}) async {
    var UID;
    if (uid == null || uid == '') {
      UID = await Provider.of<AuthProvider>(context, listen: false)
          .auth
          .getCurrentUID();
    } else {
      UID = uid;
    }

    // TODO: check which values are given and only upload all data once
    // check what fields are given and omit them accordingly
    if (age != null) {
      await _firebaseInstance.collection('users').doc(UID).set({
        'age': age,
      }, SetOptions(merge: true)); // only overwrite values which are given
    }

    if (name != null) {
      await _firebaseInstance.collection('users').doc(UID).set({
        'name': name,
      }, SetOptions(merge: true));
    }

    if (interests != null) {
      await _firebaseInstance.collection('users').doc(UID).set({
        'interests': interests,
      }, SetOptions(merge: true));

      // set tagline
      await _firebaseInstance.collection('users').doc(UID).set({
        'tagLine': 'Interested in ${interests.join(', ')}',
      }, SetOptions(merge: true));
    }

    if (photoURL != null) {
      await _firebaseInstance.collection('users').doc(UID).set({
        'photoURL': photoURL,
      }, SetOptions(merge: true));
    }

    if (phoneNumber != null) {
      await _firebaseInstance.collection('users').doc(UID).set({
        'phoneNumber': phoneNumber,
      }, SetOptions(merge: true));
    }
  }

  Future<UserProfile> getAdditionalUserData(
      {@required BuildContext context, String uid}) async {
    var UID;

    if (uid == null || uid == '') {
      UID = await Provider.of<AuthProvider>(context, listen: false)
          .auth
          .getCurrentUID();
    } else {
      UID = uid;
    }

    var querySnapshot =
        await _firebaseInstance.collection('users').doc(UID).get();
    final map = querySnapshot.data() ??
        {}; //if for some reason no userprofile can be found give an empty one back
    //TODO: maybe indicate that something went wrong

    var userProfile = UserProfile(
        uid: UID,
        photoURL: map['photoURL'] ??= '',
        interests: List<String>.from(map['interests'] ??= <String>[]),
        age: map['age'] ??= '',
        phoneNumber: map['phoneNumber'] ??= '',
        name: map['name'],
        email: map['email'],
        shortDescription: map['tagLine'] ??= '');

    return userProfile;
  }

  Stream<UserProfile> getAdditionalUserDataAsStream(
      {@required BuildContext context, String uid}) async* {
    var UID;

    if (uid == null || uid == '') {
      UID = await Provider.of<AuthProvider>(context, listen: false)
          .auth
          .getCurrentUID();
    } else {
      UID = uid;
    }

    var querySnapshot =
        _firebaseInstance.collection('users').doc(UID).snapshots();

    await for (final entry in querySnapshot) {
      var userProfile = UserProfile(
          name: entry.data()['name'],
          uid: UID,
          shortDescription: entry.data()['tagLine'] ??= '',
          email: entry.data()['email'],
          age: entry.data()['age'] ??= '',
          interests:
              List<String>.from(entry.data()['interests'] ??= <String>[]),
          photoURL: entry.data()['photoURL'] ??= '',
          phoneNumber: entry.data()['phoneNumber'] ??= '');
      yield userProfile;
    }
  }
}
