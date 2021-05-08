import 'package:Aiya/constants.dart';
import 'package:Aiya/data_models/activity_data.dart';
import 'package:Aiya/data_models/profile_data.dart';
import 'package:Aiya/screens/explore/widgets/create_your_own_activity_button.dart';
import 'package:Aiya/screens/profile/profile_expanded.dart';
import 'package:Aiya/screens/profile/profile_widget.dart';
import 'package:Aiya/screens/profile/widgets/profile_picture_loader.dart';
import 'package:Aiya/services/authentication/auth_provider.dart';
import 'package:Aiya/services/firestore/firestore_provider.dart';
import 'package:emojis/emojis.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> with TickerProviderStateMixin {
  TabController tabController;
  List<Activity> _eventListCreated;
  List<Activity> _eventListJoined;
  List<Activity> _eventListNotifications;
  bool _isFirstStartCreated = true;
  bool _isFirstStart = true;
  bool _isFirstStartJoinedActivties = true;
  bool _isFirstStartMyActivties = true;
  var activityList;
  var requestList;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  void deleteActivity(documentPath) {
    Provider.of<FirestoreProvider>(context, listen: false)
        .instance
        .deleteActivity(documentPath: documentPath)
        .then((value) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Deleted Activity ${Emojis.partyingFace}'),
      ));
    }).catchError((_) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Something went wrong ${Emojis.cryingFace}'),
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        profileHeader(),
        GFSegmentTabs(
          height: 35,
          border: Border.all(color: Colors.blue),
          tabController: tabController,
          width: MediaQuery.of(context).size.width,
          length: 3,
          tabs: <Widget>[
            FittedBox(
              fit: BoxFit.fitWidth,
              child: Text(
                'Requests',
                style: GoogleFonts.roboto(fontSize: 16),
              ),
            ),
            FittedBox(
              fit: BoxFit.fitWidth,
              child: Text(
                'Created',
                style: GoogleFonts.roboto(fontSize: 16),
              ),
            ),
            FittedBox(
              fit: BoxFit.fitWidth,
              child: Text(
                'Joined',
                style: GoogleFonts.roboto(fontSize: 16),
              ),
            ),
          ],
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: GFTabBarView(controller: tabController, children: <Widget>[
              Notifications(),
              _createdActivities(),
              _joinedActivities(),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _createdActivities() {
    return FutureBuilder(
        future: Provider.of<FirestoreProvider>(context)
            .instance
            .getMyActivities(context),
        builder:
            (BuildContext context, AsyncSnapshot<List<Activity>> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: GFLoader(),
              );
            case ConnectionState.done:
            case ConnectionState.active:
              if (snapshot.data == null || snapshot.data.isEmpty) {
                return Align(
                  alignment: Alignment.topCenter,
                  child: Column(
                    children: [
                      Text(
                        'You have no activities created ${Emojis.slightlyFrowningFace}',
                        style: GoogleFonts.roboto(),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: CreateYourOwnActivityButton(),
                      )
                    ],
                  ),
                );
              }
              if (_isFirstStartCreated) {
                _eventListCreated = List.from(snapshot.data);
                _isFirstStartCreated = false;
              }
              return SizedBox(
                width: MediaQuery.of(context).size.width / 2,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _eventListCreated.length,
                  itemBuilder: (BuildContext context, int index) {
                    return InkWell(
                      onTap: () => Navigator.of(context).pushNamed(
                          constants.activityDetailRoute,
                          arguments: _eventListCreated[index]),
                      child: Card(
                          child: Column(
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                            GFListTile(
                              titleText: _eventListCreated[index].title,
                              subtitleText: _eventListCreated[index].location,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  bottom: 14.0, left: 32, right: 32),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Text(
                                      '${Emojis.alarmClock} ${DateFormat('kk:mm').format(_eventListCreated[index].dateTime.toDate())}'),
                                  Text(
                                      '${Emojis.calendar} ${DateFormat('dd-MM').format(_eventListCreated[index].dateTime.toDate())}'),
                                ],
                              ),
                            ),
                          ])),
                    );
                  },
                ),
              );
          }
          return Container(); // unreachable}, ),
        });
  }

  Widget _joinedActivities() {
    return FutureBuilder(
        future: Provider.of<FirestoreProvider>(context)
            .instance
            .getJoinedActivities(context),
        builder:
            (BuildContext context, AsyncSnapshot<List<Activity>> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: GFLoader(),
              );
            case ConnectionState.done:
            case ConnectionState.active:
              if (snapshot.data == null || snapshot.data.isEmpty) {
                return Align(
                  alignment: Alignment.topCenter,
                  child: Text(
                    'You joined no activities ${Emojis.slightlyFrowningFace}',
                    style: GoogleFonts.roboto(),
                  ),
                );
              }
              if (_isFirstStartJoinedActivties) {
                _eventListJoined = List.from(snapshot.data);
                _isFirstStart = false;
              }
              return SizedBox(
                width: MediaQuery.of(context).size.width / 2,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _eventListJoined.length,
                  itemBuilder: (BuildContext context, int index) {
                    return InkWell(
                      onTap: () => Navigator.of(context).pushNamed(
                          constants.activityDetailRoute,
                          arguments: _eventListJoined[index]),
                      child: Card(
                          child: Column(
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                            GFListTile(
                              titleText: _eventListJoined[index].title,
                              subtitleText: _eventListJoined[index].location,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  bottom: 14.0, left: 32, right: 32),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Text(
                                      '${Emojis.alarmClock} ${DateFormat('kk:mm').format(_eventListJoined[index].dateTime.toDate())}'),
                                  Text(
                                      '${Emojis.calendar} ${DateFormat('dd-MM').format(_eventListJoined[index].dateTime.toDate())}'),
                                ],
                              ),
                            ),
                          ])),
                    );
                  },
                ),
              );
          }
          return Container(); // unreachable}, ),
        });
  }

  Widget profileHeader() {
    return FutureBuilder<UserProfile>(
        future: Provider.of<AuthProvider>(context)
            .auth
            .getUserProfile(context: context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            return profileHeaderShimmer();
          }
          if (snapshot.hasData) {
            return GFListTile(
              avatar: Hero(
                tag: 'avatarPicture',
                child: ProfilePictureLoader(
                  imageURL: snapshot?.data?.photoURL ?? '',
                  size: 50,
                  cacheKeySet: 'ProfilePicture',
                ),
              ),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (BuildContext context) {
                  return Scaffold(body: ProfileWidget());
                }));
              },
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
              icon: Icon(
                Icons.edit,
                color: Theme.of(context).accentColor,
                size: 30,
              ),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting ||
              snapshot.connectionState == ConnectionState.active) {
            profileHeaderShimmer();
          }
          return profileHeaderShimmer();
        });
  }

  // build notifications timeline
  Widget Notifications() {
    return FutureBuilder(
        future: Provider.of<FirestoreProvider>(context)
            .instance
            .getMyActivities(context),
        builder:
            (BuildContext context, AsyncSnapshot<List<Activity>> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: GFLoader(),
              );
            case ConnectionState.done:
            case ConnectionState.active:
              if (_isFirstStart && snapshot.data != null) {
                _eventListNotifications = List.from(snapshot.data);
                _isFirstStart = false;
              }
              if (_isFirstStartMyActivties && snapshot.data != null) {
                activityList = <Activity>[];
                requestList = <String>[];
                for (var activity in _eventListNotifications) {
                  for (var entry in activity.joinRequests) {
                    activityList.add(activity);
                    requestList.add(entry);
                  }
                  _isFirstStartMyActivties = false;
                }
              }

              if (requestList == null || requestList.isEmpty) {
                return Align(
                    alignment: Alignment.topCenter,
                    child: Text('You don\'t have any requests :('));
              }
              return SizedBox(
                width: MediaQuery.of(context).size.width / 2,
                child: ListView.separated(
                    itemCount: activityList?.length,
                    itemBuilder: (BuildContext context, int index) {
                      return FutureBuilder(
                          future: Provider.of<FirestoreProvider>(context)
                              .instance
                              .getAdditionalUserData(
                                  context: context, uid: requestList[index]),
                          builder: (BuildContext context,
                              AsyncSnapshot<UserProfile> snapshot) {
                            if (snapshot.hasData) {
                              if (snapshot.data != null) {
                                return Column(
                                  children: [
                                    RichText(
                                      text: TextSpan(
                                          text: 'Someone wants to join ',
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: Colors.black),
                                          children: <TextSpan>[
                                            TextSpan(
                                                text:
                                                    '"${activityList[index].title}"',
                                                style: GoogleFonts.roboto(
                                                    fontSize: 18.0,
                                                    fontWeight:
                                                        FontWeight.w800)),
                                          ]),
                                    ),
                                    GFListTile(
                                      onTap: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ProfileExpanded(
                                                    userProfile: snapshot.data,
                                                  ))),
                                      margin: EdgeInsets.all(0),
                                      icon: Row(
                                        children: [
                                          GFIconButton(
                                              type: GFButtonType.outline,
                                              icon: Icon(
                                                Icons.thumb_up,
                                                color: Colors.green,
                                              ),
                                              onPressed: () => Provider.of<
                                                          FirestoreProvider>(
                                                      context,
                                                      listen: false)
                                                  .instance
                                                  .joinAccept(
                                                      context: context,
                                                      activityUID:
                                                          activityList[index]
                                                              .documentID,
                                                      userUID:
                                                          snapshot.data.uid)
                                                  .then((value) async =>
                                                      setState(() {
                                                        activityList
                                                            .removeAt(index);
                                                      }))),
                                          Container(
                                            width: 20,
                                          ),
                                          GFIconButton(
                                              type: GFButtonType.outline,
                                              icon: Icon(
                                                Icons.thumb_down,
                                                color: Colors.red,
                                              ),
                                              onPressed: () =>
                                                  Provider.of<FirestoreProvider>(
                                                          context,
                                                          listen: false)
                                                      .instance
                                                      .joinDeny(
                                                          context: context,
                                                          activityUID:
                                                              activityList[
                                                                      index]
                                                                  .documentID,
                                                          userUID:
                                                              snapshot.data.uid)
                                                      .then((value) async {
                                                    setState(() {
                                                      activityList
                                                          .removeAt(index);
                                                    });
                                                  }).then((value) =>
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                                  SnackBar(
                                                            content: Text(
                                                                'Denied request :('),
                                                            action:
                                                                SnackBarAction(
                                                              onPressed: () {
                                                                ScaffoldMessenger.of(
                                                                        context)
                                                                    .removeCurrentSnackBar();
                                                              },
                                                              label: 'OK',
                                                            ),
                                                          ))))
                                        ],
                                      ),
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
                                    ),
                                  ],
                                );
                              } else {
                                return CircularProgressIndicator();
                              }
                            }
                            return Container();
                          });
                    },
                    separatorBuilder: (BuildContext context, int index) =>
                        Divider()),
              );
          }
          return Container(); // unreachable}, ),
        });
  }

  Widget profileHeaderShimmer() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GFShimmer(
          child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GFAvatar(
              size: 50,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.only(top: 18.0),
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.2,
                      height: 10,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.5,
                    height: 8,
                    color: Colors.white,
                  ),
                ],
              ),
            )
          ],
        ),
      )),
    );
  }
}
