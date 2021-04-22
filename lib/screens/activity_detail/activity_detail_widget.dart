import 'package:Aiya/constants.dart';
import 'package:Aiya/data_models/activity_data.dart';
import 'package:Aiya/data_models/profile_data.dart';
import 'package:Aiya/screens/profile/widgets/profile_picture_loader.dart';
import 'package:Aiya/screens/profile/widgets/profile_short.dart';
import 'package:Aiya/services/activities/firestore_provider.dart';
import 'package:Aiya/services/cloud_messaging.dart';
import 'package:Aiya/services/user/auth_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:emojis/emojis.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:getwidget/components/button/gf_button.dart';
import 'package:getwidget/components/button/gf_button_bar.dart';
import 'package:getwidget/components/card/gf_card.dart';
import 'package:getwidget/components/list_tile/gf_list_tile.dart';
import 'package:getwidget/getwidget.dart';
import 'package:getwidget/size/gf_size.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class ActivityDetail extends StatefulWidget {
  final Activity activity;

  ActivityDetail({Key key, @required this.activity}) : super(key: key);

  @override
  _ActivityDetailState createState() => _ActivityDetailState();
}

class _ActivityDetailState extends State<ActivityDetail> {
  final List<String> imageList = [
    'https://cdn.pixabay.com/photo/2017/12/03/18/04/christmas-balls-2995437_960_720.jpg',
    'https://cdn.pixabay.com/photo/2017/12/13/00/23/christmas-3015776_960_720.jpg',
    'https://cdn.pixabay.com/photo/2019/12/19/10/55/christmas-market-4705877_960_720.jpg',
    'https://cdn.pixabay.com/photo/2019/12/20/00/03/road-4707345_960_720.jpg',
    'https://cdn.pixabay.com/photo/2019/12/22/04/18/x-mas-4711785__340.jpg',
    'https://cdn.pixabay.com/photo/2016/11/22/07/09/spruce-1848543__340.jpg'
  ];

  // to give all information to activityedit if needed
  Activity activity;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.all(0),
        shrinkWrap: true,
        children: [
          Stack(
            children: [
              ActivityDetailCard(),
              BackButton(),
            ],
          ),
          FutureBuilder(
              future: Provider.of<FirestoreProvider>(context)
                  .instance
                  .getAdditionalUserData(context: context),
              builder:
                  (BuildContext context, AsyncSnapshot<UserProfile> snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data != null) {
                    return StreamBuilder(
                        stream: Provider.of<FirestoreProvider>(context)
                            .instance
                            .getJoinState(
                              documentID: widget.activity.documentID,
                              context: context,
                              userUID: snapshot.data.uid,
                            ),
                        builder: (BuildContext context,
                            AsyncSnapshot<String> getJoinState) {
                          if (getJoinState.connectionState ==
                                  ConnectionState.active ||
                              getJoinState.connectionState ==
                                  ConnectionState.done ||
                              getJoinState.connectionState ==
                                  ConnectionState.waiting) {
                            if (getJoinState.data != null) {
                              if (getJoinState.data == 'joinAccepted' ||
                                  getJoinState.data == 'activityCreator') {
                                return contactButtons();
                              } else {
                                return GFCard(
                                  margin: EdgeInsets.all(8),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 0.0, vertical: 8.0),
                                  title: GFListTile(
                                    margin: EdgeInsets.all(0),
                                    padding: EdgeInsets.all(0),
                                    titleText: 'Contact Options',
                                    subtitleText:
                                        'Activity creator must first accepted your request',
                                  ),
                                );
                              }
                            }
                            return joinButtonShimmer();
                          } else {
                            return joinButtonShimmer();
                          }
                        });
                  } else {
                    return CircularProgressIndicator();
                  }
                }
                return Container();
              }),
          JoinedUsers(),
        ],
      ),
    );
  }

  Widget ActivityDetailCard() {
    return GFCard(
      margin: EdgeInsets.all(8),
      padding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0),
      boxFit: BoxFit.cover,
      image: Image(
        image: CachedNetworkImageProvider(
            'https://source.unsplash.com/500x500/?${widget.activity.title}'),
        fit: BoxFit.cover,
        width: double.infinity,
        height: 200,
      ),
      title: GFListTile(
        padding: EdgeInsets.all(0),
        titleText: widget.activity.title,
      ),
      content: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                '${Emojis.worldMap} ${widget.activity.location}',
                style: GoogleFonts.roboto(
                    fontSize: 16, fontWeight: FontWeight.w400),
              ),
              Text(
                '${Emojis.timerClock} ${DateFormat('kk:mm').format(widget.activity.dateTime.toDate())}',
                style: GoogleFonts.roboto(
                    fontSize: 16, fontWeight: FontWeight.w400),
              ),
              Text(
                '${Emojis.calendar} ${DateFormat('dd-MM').format(widget.activity.dateTime.toDate())}',
                style: GoogleFonts.roboto(
                    fontSize: 16, fontWeight: FontWeight.w400),
              ),
            ],
          ),
          widget.activity.description
                  .isEmpty // remove padding when no description is given
              ? Text(
                  widget.activity.description,
                  style: GoogleFonts.roboto(),
                  textAlign: TextAlign.start,
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    widget.activity.description,
                    style: GoogleFonts.roboto(),
                    textAlign: TextAlign.start,
                  ),
                ),
          ProfileShort(activityOrUserProfile: widget.activity)
        ],
      ),
      buttonBar: GFButtonBar(
        children: <Widget>[
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: FutureBuilder(
                    // TODO: seems messy :(
                    future:
                        Provider.of<AuthProvider>(context).auth.getCurrentUID(),
                    builder: (BuildContext context,
                        AsyncSnapshot<String> snapshotUID) {
                      if (snapshotUID.hasData) {
                        if (snapshotUID.data != null) {
                          return StreamBuilder(
                              // set onPressed and button text depending on if the user has already joined the activity
                              stream: Provider.of<FirestoreProvider>(context)
                                  .instance
                                  .getJoinState(
                                    documentID: widget.activity.documentID,
                                    context: context,
                                    userUID: snapshotUID.data,
                                  ),
                              builder: (BuildContext context,
                                  AsyncSnapshot<String> getJoinState) {
                                if (getJoinState.connectionState ==
                                        ConnectionState.active ||
                                    getJoinState.connectionState ==
                                        ConnectionState.done ||
                                    getJoinState.connectionState ==
                                        ConnectionState.waiting) {
                                  var text = 'Loading ...';
                                  var onPressed = () {};
                                  var color = Theme.of(context).accentColor;
                                  if (getJoinState.data != null) {
                                    switch (getJoinState.data) {
                                      case 'activityCreator':
                                        text =
                                            'You are the activity creator :)';
                                        onPressed = () {};
                                        color = Colors.green;
                                        break;
                                      case 'joinRequested':
                                        color = Colors.red;
                                        text =
                                            '(Join Requested) Revoke Join Request';
                                        onPressed = () =>
                                            Provider.of<FirestoreProvider>(
                                                    context,
                                                    listen: false)
                                                .instance
                                                .joinDeny(
                                                    context: context,
                                                    activityUID: widget
                                                        .activity.documentID);
                                        break;
                                      case 'joinAccepted':
                                        color = Colors.green;
                                        text =
                                            '(Join Accepted ${Emojis.partyingFace}) Revoke Join';
                                        onPressed = () =>
                                            Provider.of<FirestoreProvider>(
                                                    context,
                                                    listen: false)
                                                .instance
                                                .joinRemove(
                                                    context: context,
                                                    activityUID: widget
                                                        .activity.documentID);
                                        break;
                                      default:
                                        color = Theme.of(context).accentColor;
                                        onPressed = () {
                                          Provider.of<FirestoreProvider>(
                                                  context,
                                                  listen: false)
                                              .instance
                                              .joinRequest(
                                                  context: context,
                                                  activityUID: widget
                                                      .activity.documentID);
                                          // request permission for FCM
                                          requestFCMPermission(context);
                                        };
                                        text = 'Request To Join';
                                        break;
                                    }
                                    return GFButton(
                                      padding: EdgeInsets.all(0),
                                      onPressed: onPressed,
                                      text: text,
                                      size: GFSize.LARGE,
                                      color: color,
                                      fullWidthButton: true,
                                    );
                                  }
                                  return joinButtonShimmer();
                                } else {
                                  return joinButtonShimmer();
                                }
                              });
                        } else {
                          return joinButtonShimmer();
                        }
                      }
                      return joinButtonShimmer();
                    }),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                child: Divider(),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GFIconButton(
                    onPressed: null,
                    icon: Icon(Icons.flag),
                    type: GFButtonType.transparent,
                  ),
                  FutureBuilder(
                      future: Provider.of<AuthProvider>(context, listen: false)
                          .auth
                          .getCurrentUID(),
                      builder: (BuildContext context,
                          AsyncSnapshot<String> snapshot) {
                        if (snapshot.hasData) {
                          if (snapshot.data != null) {
                            return GFIconButton(
                              onPressed: snapshot.data
                                      .contains(widget.activity.creatorUID)
                                  ? () async =>
                                      await Provider.of<FirestoreProvider>(
                                              context,
                                              listen: false)
                                          .instance
                                          .deleteActivity(
                                              documentPath:
                                                  widget.activity.documentID)
                                          .then((value) =>
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(SnackBar(
                                                content: Text(
                                                    // TODO: maybe use stream to show that the activity is gone or animation
                                                    'The activity was deleted ${Emojis.winkingFace}'),
                                              )))
                                          .then((value) =>
                                              Navigator.pushReplacementNamed(
                                                  context,
                                                  constants.exploreRoute))
                                  : null,
                              icon: Icon(Icons.delete),
                              type: GFButtonType.transparent,
                            );
                          } else {
                            return joinButtonShimmer();
                          }
                        }
                        return GFIconButton(
                          onPressed: null,
                          icon: Icon(Icons.delete),
                          type: GFButtonType.transparent,
                        );
                      }),
                  FutureBuilder(
                      future: Provider.of<AuthProvider>(context, listen: false)
                          .auth
                          .getCurrentUID(),
                      builder: (BuildContext context,
                          AsyncSnapshot<String> snapshot) {
                        if (snapshot.hasData) {
                          if (snapshot.data != null) {
                            return GFIconButton(
                              onPressed: snapshot.data
                                      .contains(widget.activity.creatorUID)
                                  ? () => Navigator.of(context).pushNamed(
                                      constants.editActivityRoute,
                                      arguments: widget.activity)
                                  : null,
                              icon: Icon(Icons.edit),
                              type: GFButtonType.transparent,
                            );
                          } else {
                            return joinButtonShimmer();
                          }
                        }
                        return GFIconButton(
                          onPressed: null,
                          icon: Icon(Icons.delete),
                          type: GFButtonType.transparent,
                        );
                      }),
                  GFIconButton(
                    onPressed: () {
                      Share.share('Hey you should look at this!',
                          subject: 'Hey you should look at this!');
                    },
                    icon: Icon(Icons.share),
                    type: GFButtonType.transparent,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget contactButtons() {
    return GFCard(
        margin: EdgeInsets.all(8),
        padding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 8.0),
        title: GFListTile(
          margin: EdgeInsets.all(0),
          padding: EdgeInsets.all(0),
          titleText: 'Contact Options',
        ),
        content: StreamBuilder(
            stream: Provider.of<FirestoreProvider>(context)
                .instance
                .getAdditionalUserDataAsStream(
                    context: context, uid: widget.activity.creatorUID),
            builder:
                (BuildContext context, AsyncSnapshot<UserProfile> snapshot) {
              if (snapshot.hasError) throw snapshot.error.toString();
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.waiting:
                  return CircularProgressIndicator();
                case ConnectionState.active:
                case ConnectionState.done:
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GFIconButton(
                        onPressed: // get allowed contact options
                            snapshot.data.contactOptions.contains('WhatsApp')
                                ? () async {
                                    var phone = snapshot.data.phoneNumber;
                                    var _url = "whatsapp://send?phone=$phone";
                                    await canLaunch(_url)
                                        ? await launch(_url)
                                        : ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                                content: Text(
                                                    'Seems like you don\'t have WhatsApp ${Emojis.cryingFace}'),
                                                action: SnackBarAction(
                                                  onPressed: () =>
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .removeCurrentSnackBar(),
                                                  label: 'OK',
                                                )));
                                  }
                                : null,
                        icon: Icon(
                          FontAwesomeIcons.whatsapp,
                        ),
                        type: GFButtonType.transparent,
                      ),
                      GFIconButton(
                        onPressed: () async {
                          var phone = snapshot.data.phoneNumber;
                          var _url = "sms:$phone";
                          await canLaunch(_url)
                              ? await launch(_url)
                              : ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'Something went wrong ${Emojis.cryingFace}'),
                                      action: SnackBarAction(
                                        onPressed: () =>
                                            ScaffoldMessenger.of(context)
                                                .removeCurrentSnackBar(),
                                        label: 'OK',
                                      )));
                        },
                        icon: Icon(
                          FontAwesomeIcons.sms,
                        ),
                        type: GFButtonType.transparent,
                      ),
                      GFIconButton(
                        onPressed: () async {
                          var phone = snapshot.data.phoneNumber;
                          var _url = "tel:$phone";
                          await canLaunch(_url)
                              ? await launch(_url)
                              : ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'Something went wrong ${Emojis.cryingFace}'),
                                      action: SnackBarAction(
                                        onPressed: () =>
                                            ScaffoldMessenger.of(context)
                                                .removeCurrentSnackBar(),
                                        label: 'OK',
                                      )));
                        },
                        icon: Icon(
                          FontAwesomeIcons.phoneAlt,
                        ),
                        type: GFButtonType.transparent,
                      ),
                    ],
                  );
              }
              return Container();
            }));
    return null; // unreachable}, ),
  }

  Widget joinButtonShimmer() {
    return GFButton(
        padding: EdgeInsets.all(0),
        onPressed: () {},
        size: GFSize.LARGE,
        text: 'loading ...',
        fullWidthButton: true,
        color: Colors.white);
  }

  Widget JoinedUsers() {
    return GFCard(
      margin: EdgeInsets.all(8),
      padding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 8.0),
      title: GFListTile(
        margin: EdgeInsets.all(0),
        padding: EdgeInsets.all(0),
      ),
      content: GFAccordion(
        expandedTitleBackgroundColor: Colors.white,
        title: widget.activity.joinAccepted.isEmpty
            ? 'Be the first to join ${Emojis.smilingFace}'
            : '${widget.activity.joinAccepted.length.toString()} other(s) also joined',
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
                builder: (BuildContext context,
                    AsyncSnapshot<UserProfile> snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data != null) {
                      return GFListTile(
                        avatar: ProfilePictureLoader(
                          imageURL: snapshot.data.photoURL,
                          size: 40,
                        ),
                        title: Text(
                          '${snapshot.data.name}, ${snapshot.data.age}',
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
                      );
                    } else {
                      return CircularProgressIndicator();
                    }
                  }
                  return Container();
                });
          },
        ),
      ),
    );
  }

  Widget SimilarActivities() {
    return GFCard(
      padding: EdgeInsets.all(0),
      title: GFListTile(
        padding: EdgeInsets.all(0),
        titleText: 'Similar activities',
      ),
      content: GFCarousel(
        items: imageList.map(
          (url) {
            return Container(
              margin: EdgeInsets.all(8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                child: Image.network(url, fit: BoxFit.cover, width: 1000.0),
              ),
            );
          },
        ).toList(),
        onPageChanged: (index) {
          setState(() {
            index;
          });
        },
      ),
    );
  }
}
