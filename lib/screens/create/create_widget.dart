import 'package:Aiya/data_models/activity_data.dart';
import 'package:Aiya/data_models/profile_data.dart';
import 'package:Aiya/screens/create/widgets/description_widget.dart';
import 'package:Aiya/screens/create/widgets/what_widget.dart';
import 'package:Aiya/screens/create/widgets/when_widget.dart';
import 'package:Aiya/screens/create/widgets/where_widget.dart';
import 'package:Aiya/screens/profile/widgets/profile_picture_loader.dart';
import 'package:Aiya/services/cloud_messaging.dart';
import 'package:Aiya/services/firestore/firestore_provider.dart';
import 'package:emojis/emojis.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/colors/gf_color.dart';
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
  String _eventDescription;

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

  void _descriptionCallback(callback) {
    _eventDescription = callback;
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
    await firestoreService
        .createActivity(
            context: context,
            eventTitle: _eventTitle,
            eventLocation: _eventLocation,
            dateTime: _eventDateTime,
            description: _eventDescription)
        .then((value) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Created Activity ${Emojis.partyingFace}'),
            action: SnackBarAction(
              onPressed: () =>
                  ScaffoldMessenger.of(context).removeCurrentSnackBar(),
              label: 'OK',
            ))));
    // request permission for FCM
    requestFCMPermission(context);
  }

  Future<void> _updateActivity() async {
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
    await firestoreService
        .updateActivity(
          context: context,
          eventTitle: _eventTitle,
          eventLocation: _eventLocation,
          eventDescription: _eventDescription,
          dateTime: _eventDateTime,
          activityUID: widget.activity.documentID,
        )
        .then((value) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Updated Activity ${Emojis.partyingFace}'),
            action: SnackBarAction(
              onPressed: () =>
                  ScaffoldMessenger.of(context).removeCurrentSnackBar(),
              label: 'OK',
            ))));
  }

  @override
  Widget build(BuildContext context) {
    // pre populate all values when arguments are already given (edit mode)
    if (widget.activity != null) {
      _eventTitle = widget.activity.title;
      _eventLocation = widget.activity.location;
      _eventDate = widget.activity.dateTime.toDate();
      _eventTime = TimeOfDay.fromDateTime(widget.activity.dateTime.toDate());
      _eventDescription = widget.activity.description;
    }

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
            Padding(
              padding: const EdgeInsets.only(top: 30.0),
              child: DescriptionWidget(
                descriptionCallback: _descriptionCallback,
                title: widget?.activity?.description ?? '',
              ),
            ),
            widget.activity != null ? joinedPeopleList() : Container(),
            Align(
              alignment: Alignment.bottomCenter,
              child: GFButton(
                  fullWidthButton: true,
                  onPressed: () => widget.activity != null
                      ? _updateActivity()
                      : _createActivity(),
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
                      title: Text(
                        snapshot.data.age.isNotEmpty
                            ? '${snapshot.data.name}, ${snapshot.data.age}'
                            : '${snapshot.data.name}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                            color: GFColors.DARK),
                      ),
                      subtitle: Text(
                        snapshot.data.shortDescription,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14.5,
                          color: Colors.black54,
                        ),
                      ),
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
