import 'package:Aiya/data_models/activity_data.dart';
import 'package:Aiya/data_models/profile_data.dart';
import 'package:Aiya/screens/create/widgets/what_widget.dart';
import 'package:Aiya/screens/create/widgets/when_widget.dart';
import 'package:Aiya/screens/create/widgets/where_widget.dart';
import 'package:Aiya/screens/profile/widgets/profile_picture_loader.dart';
import 'package:Aiya/services/activities/firestore_provider.dart';
import 'package:emojis/emojis.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/components/accordian/gf_accordian.dart';
import 'package:getwidget/components/button/gf_button.dart';
import 'package:getwidget/components/button/gf_icon_button.dart';
import 'package:getwidget/components/list_tile/gf_list_tile.dart';
import 'package:provider/provider.dart';

class CreateWidget extends StatefulWidget {
  final Activity activity;

  // if given an activity will pre populate all the fields if possible
  CreateWidget({Key key, this.activity}) : super(key: key);

  @override
  _CreateWidgetState createState() => _CreateWidgetState();
}

class _CreateWidgetState extends State<CreateWidget> {
  List<UserProfile> joinedUsers = [];

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
              title: widget?.activity?.title ?? null,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 30.0),
              child: WhenWidget(
                  dateCallback: _dateCallback,
                  timeCallback: _timeCallback,
                  dateTime: widget?.activity?.dateTime?.toDate() ?? null),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 30.0),
              child: WhereWidget(
                locationCallback: _locationCallback,
                where: widget?.activity?.location ?? null,
              ),
            ),
            widget.activity != null ? joinedPeopleList() : Container(),
            Align(
              alignment: Alignment.bottomCenter,
              child: GFButton(
                  fullWidthButton: true,
                  onPressed: () => _createActivity(),
                  text: widget.activity != null
                      ? 'Update Activity'
                      : 'Create Activity'),
            )
          ],
        ));
  }

  Widget joinedPeopleList() {
    return GFAccordion(
      expandedTitleBackgroundColor: Colors.white,
      title: 'Joined users',
      contentChild: ListView.builder(
        physics: ScrollPhysics(),
        shrinkWrap: true,
        itemCount: widget.activity.joinAccepted.length,
        itemBuilder: (BuildContext context, int index) {
          return FutureBuilder(
              future: Provider.of<FirestoreProvider>(context)
                  .instance
                  .getAdditionalUserData(
                      context: context,
                      uid: widget.activity.joinAccepted[index]),
              builder:
                  (BuildContext context, AsyncSnapshot<UserProfile> snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data != null) {
                    return GFListTile(
                      avatar: ProfilePictureLoader(
                        imageURL: snapshot.data.photoURL,
                        size: 40,
                      ),
                      titleText: '${snapshot.data.name}, ${snapshot.data.age}',
                      subtitleText: snapshot.data.shortDescription,
                      icon: GFIconButton(
                        size: 40.0,
                        onPressed: () {
                          Provider.of<FirestoreProvider>(context, listen: false)
                              .instance
                              .joinRemove(
                                  userUID: widget.activity.joinAccepted[index],
                                  context: context,
                                  activityUID: widget.activity.documentID);

                          setState(() {
                            widget.activity.joinAccepted.removeWhere(
                                (element) =>
                                    element ==
                                    widget.activity.joinAccepted[index]);
                          });
                        },
                        color: Colors.white,
                        icon: Icon(
                          Icons.delete,
                          color: Theme.of(context).errorColor,
                        ),
                      ),
                    );
                  } else {
                    return CircularProgressIndicator();
                  }
                }
                return Container();
              });
        },
      ),
    );
  }
}
