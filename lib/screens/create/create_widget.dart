import 'package:Aiya/screens/create/widgets/what_widget.dart';
import 'package:Aiya/screens/create/widgets/when_widget.dart';
import 'package:Aiya/screens/create/widgets/where_widget.dart';
import 'package:Aiya/services/activities/firestore_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emojis/emojis.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/components/button/gf_button.dart';
import 'package:provider/provider.dart';

class CreateWidget extends StatefulWidget {
  @override
  _CreateWidgetState createState() => _CreateWidgetState();
}

class _CreateWidgetState extends State<CreateWidget> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  //VARIABLES
  String _eventTitle;
  String _eventLocation;
  DateTime _eventDate;
  TimeOfDay _eventTime;

  // CALLBACKS
  void _dateCallback(callback) {
    _eventDate = callback;
  }

  void _timeCallback(callback) {
    _eventTime = callback;
  }

  void _titleCallback(callback) {
    _eventTitle = callback;
  }

  void _locationCallback(callback) {
    _eventLocation = callback;
  }

  // FUNCTIONS
  Future<void> _createActivity() async {
    //check if all fields have values
    if (_eventTitle == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('You forgot to enter WHAT ${Emojis.questionMark}'),
      ));
      return;
    } else if (_eventTime == null || _eventDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('You forgot to enter WHEN ${Emojis.timerClock}'),
      ));
      return;
    } else if (_eventLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('You forgot to enter WHERE ${Emojis.ringedPlanet}'),
      ));
      return;
    }

    // create DateTime from TimeOfDay and DateTime
    var _eventDateTime = DateTime(_eventDate.year, _eventDate.month,
        _eventDate.day, _eventTime.hour, _eventTime.minute);

    // create a handle for the "activities" collection
    var firestoreService =
        Provider.of<FirestoreProvider>(context, listen: false).instance;
    await firestoreService.createActivity(
      context: context,
      eventTitle: _eventTitle,
      eventLocation: _eventLocation,
      dateTime: _eventDateTime,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          shrinkWrap: true,
          children: [
            WhatWidget(
              titleCallback: _titleCallback,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 30.0),
              child: WhenWidget(
                dateCallback: _dateCallback,
                timeCallback: _timeCallback,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 30.0),
              child: WhereWidget(
                locationCallback: _locationCallback,
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: GFButton(
                  fullWidthButton: true,
                  onPressed: () => _createActivity(),
                  text: 'Create Activity'),
            )
          ],
        ));
  }
}
