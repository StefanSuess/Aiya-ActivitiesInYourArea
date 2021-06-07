import 'package:Aiya/constants.dart';
import 'package:Aiya/data_models/activity_data.dart';
import 'package:Aiya/data_models/profile_data.dart';
import 'package:Aiya/screens/group_chat/group_chat.dart';
import 'package:Aiya/screens/profile/profile_expanded.dart';
import 'package:Aiya/screens/profile/widgets/profile_picture_loader.dart';
import 'package:Aiya/screens/profile/widgets/profile_short.dart';
import 'package:Aiya/services/authentication/auth_provider.dart';
import 'package:Aiya/services/cloud_messaging.dart';
import 'package:Aiya/services/firestore/firestore_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:emojis/emojis.dart';
import 'package:flutter/foundation.dart';
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
  // to give all information to activityedit if needed
  Activity activity;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.all(0),
        children: [
          Stack(
            children: [
              ActivityDetailCard(),
              BackButton(),
            ],
          ),
          covidWarning(),
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
                                return groupChat();
                              } else {
                                return GFCard(
                                  margin: EdgeInsets.all(8),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 0.0, vertical: 8.0),
                                  title: GFListTile(
                                    margin: EdgeInsets.all(0),
                                    padding: EdgeInsets.all(0),
                                    titleText: 'Group Chat',
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

  Widget groupChat() {
    return GFCard(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      padding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 8.0),
      content: Container(
        child: GFAccordion(
          contentPadding: EdgeInsets.fromLTRB(0, 20, 0, 0),
          expandedTitleBackgroundColor: Colors.white,
          margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
          title: 'Group Chat',
          contentChild: ChatScreen(activity: widget.activity),
          showAccordion: true,
        ),
      ),
    );
  }

  Widget ActivityDetailCard() {
    return SingleChildScrollView(
      // TODO why does this work in avoiding overflow during hero animation???
      child: GFCard(
        margin: EdgeInsets.fromLTRB(8, 0, 8, 8),
        padding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 8.0),
        boxFit: BoxFit.cover,
        image: Image(
          image: CachedNetworkImageProvider(
              'https://source.unsplash.com/500x500/?${widget.activity.title}'),
          fit: BoxFit.cover,
          width: MediaQuery.of(context).size.width,
          height: 200,
        ),
        title: GFListTile(
          titleText: widget.activity.title,
          subtitleText: '${widget.activity.location}',
        ),
        content: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
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
                    widget.activity.description.trim(),
                    style: GoogleFonts.roboto(),
                    textAlign: TextAlign.justify,
                  )
                : Container(
                    width: MediaQuery.of(context).size.width,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        widget.activity.description,
                        style: GoogleFonts.roboto(),
                        textAlign: TextAlign.left,
                        softWrap: true,
                      ),
                    ),
                  ),
            ProfileShort(activityOrUserProfile: widget.activity)
          ],
        ),
        buttonBar: GFButtonBar(
          alignment: WrapAlignment.spaceBetween,
          children: <Widget>[
            Column(
              children: [
                joinedButton(),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 4.0),
                  child: Divider(),
                ),
                buttomButtons(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget joinedButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: FutureBuilder(
          // TODO: seems messy :(
          future: Provider.of<AuthProvider>(context).auth.getCurrentUID(),
          builder: (BuildContext context, AsyncSnapshot<String> snapshotUID) {
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
                              text = 'You are the activity creator :)';
                              onPressed = () {};
                              color = Colors.green;
                              break;
                            case 'joinRequested':
                              color = Colors.red;
                              text = '(Join Requested) Revoke Join Request';
                              onPressed = () => Provider.of<FirestoreProvider>(
                                      context,
                                      listen: false)
                                  .instance
                                  .joinDeny(
                                      context: context,
                                      activityUID: widget.activity.documentID);
                              break;
                            case 'joinAccepted':
                              color = Colors.green;
                              text =
                                  '(Join Accepted ${Emojis.partyingFace}) Revoke Join';
                              onPressed = () => Provider.of<FirestoreProvider>(
                                      context,
                                      listen: false)
                                  .instance
                                  .joinRemove(
                                      context: context,
                                      activityUID: widget.activity.documentID);
                              break;
                            default:
                              color = Theme.of(context).accentColor;
                              onPressed = () {
                                Provider.of<FirestoreProvider>(context,
                                        listen: false)
                                    .instance
                                    .joinRequest(
                                        context: context,
                                        activityUID:
                                            widget.activity.documentID);
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
    );
  }

  Widget buttomButtons() {
    return Row(
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
            builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data != null) {
                  return GFIconButton(
                    onPressed:
                        snapshot.data.contains(widget.activity.creatorUID)
                            ? () => deleteActivity()
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
            builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data != null) {
                  return GFIconButton(
                    onPressed:
                        snapshot.data.contains(widget.activity.creatorUID)
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
            Share.share(
              '${widget.activity.title} at ${widget.activity.location} \nmore at https://activitiesinyourarea-500ef.web.app/activity=${widget.activity.documentID}',
            );
          },
          icon: Icon(Icons.share),
          type: GFButtonType.transparent,
        ),
      ],
    );
  }

  deleteActivity() {
    // set up the button
    Widget okButton = GFButton(
      type: GFButtonType.outline,
      color: Colors.red,
      child: Text("DELETE ACTIVITY"),
      onPressed: () {
        Provider.of<FirestoreProvider>(context, listen: false)
            .instance
            .deleteActivity(documentPath: widget.activity.documentID)
            .then(
                (value) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(
                          // TODO: maybe use stream to show that the activity is gone or animation
                          'The activity was deleted ${Emojis.winkingFace}'),
                    )))
            .then((value) => Navigator.pushReplacementNamed(
                context, constants.exploreRoute));
        Navigator.of(context, rootNavigator: true).pop();
      },
    );

    Widget abortButton = GFButton(
      type: GFButtonType.solid,
      color: Theme.of(context).accentColor,
      child: Text("ABORT"),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Delete Activity"),
      content: Text(
          "Do you really want to delete this activity? \nJoined ${widget.activity.joinAccepted.length} user(s) \nWant to join ${widget.activity.joinRequests.length} user(s)"),
      actions: [okButton, abortButton],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Widget covidWarning() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 4),
      child: Card(
        color: Colors.yellowAccent,
        child: InkWell(
          onTap: () => launch(
              'https://www.who.int/emergencies/diseases/novel-coronavirus-2019/question-and-answers-hub/q-a-detail/coronavirus-disease-covid-19#:~:text=symptoms'),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: new RichText(
                text: new TextSpan(
                  // Note: Styles for TextSpans must be explicitly defined.
                  // Child text spans will inherit styles from parent
                  style: new TextStyle(
                    fontSize: 14.0,
                    color: Colors.black,
                  ),
                  children: <TextSpan>[
                    new TextSpan(
                        text:
                            'Please follow the current COVID-19 guidelines when meeting ${Emojis.faceWithMedicalMask} '),
                    new TextSpan(
                        text: 'MORE INFO',
                        style: new TextStyle(
                            decoration: TextDecoration.underline,
                            color: Colors.blue)),
                  ],
                ),
              ),
            ),
          ),
        ),
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
                                    if (kIsWeb) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                              content: Text(
                                                  'This is not supported in the web version ${Emojis.cryingFace}'),
                                              action: SnackBarAction(
                                                onPressed: () =>
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .removeCurrentSnackBar(),
                                                label: 'OK',
                                              )));
                                    } else {
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
                                  }
                                : null,
                        icon: Icon(
                          FontAwesomeIcons.whatsapp,
                        ),
                        type: GFButtonType.transparent,
                      ),
                      GFIconButton(
                        onPressed: snapshot.data.contactOptions.contains('sms')
                            ? () async {
                                var phone = snapshot.data.phoneNumber;
                                var _url = "sms:$phone";
                                await canLaunch(_url)
                                    ? await launch(_url)
                                    : ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
                                            content: Text(
                                                'Something went wrong ${Emojis.cryingFace}'),
                                            action: SnackBarAction(
                                              onPressed: () =>
                                                  ScaffoldMessenger.of(context)
                                                      .removeCurrentSnackBar(),
                                              label: 'OK',
                                            )));
                              }
                            : null,
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
        margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
        contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 0),
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
                // TODO: seems messy :(
                future: Provider.of<AuthProvider>(context).auth.getCurrentUID(),
                builder:
                    (BuildContext context, AsyncSnapshot<String> snapshotUID) {
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
                          if (getJoinState.data != null) {
                            switch (getJoinState.data) {
                              case 'activityCreator':
                              case 'joinAccepted':
                                return FutureBuilder(
                                    future:
                                        Provider.of<FirestoreProvider>(context)
                                            .instance
                                            .getAdditionalUserData(
                                                context: context,
                                                uid: widget.activity
                                                    .joinAccepted[index]),
                                    builder: (BuildContext context,
                                        AsyncSnapshot<UserProfile> snapshot) {
                                      if (snapshot.hasData) {
                                        if (snapshot.data != null) {
                                          return GFListTile(
                                            onTap: () => Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        ProfileExpanded(
                                                          userProfile:
                                                              snapshot.data,
                                                        ))),
                                            margin: EdgeInsets.all(0),
                                            avatar: ProfilePictureLoader(
                                              imageURL: snapshot.data.photoURL,
                                              size: 40,
                                            ),
                                            icon: StreamBuilder(
                                                stream: Provider.of<
                                                            FirestoreProvider>(
                                                        context)
                                                    .instance
                                                    .getAdditionalUserDataAsStream(
                                                        context: context,
                                                        uid: snapshot.data.uid),
                                                builder: (BuildContext context,
                                                    AsyncSnapshot<UserProfile>
                                                        snapshot) {
                                                  if (snapshot.hasError)
                                                    throw snapshot.error
                                                        .toString();
                                                  switch (snapshot
                                                      .connectionState) {
                                                    case ConnectionState.none:
                                                    case ConnectionState
                                                        .waiting:
                                                      return CircularProgressIndicator();
                                                    case ConnectionState.active:
                                                    case ConnectionState.done:
                                                      return Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceEvenly,
                                                        children: [
                                                          GFIconButton(
                                                            onPressed: // get allowed contact options
                                                                snapshot.data
                                                                        .contactOptions
                                                                        .contains(
                                                                            'WhatsApp')
                                                                    ? () async {
                                                                        if (kIsWeb) {
                                                                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                                                              content: Text('This is not supported in the web version ${Emojis.cryingFace}'),
                                                                              action: SnackBarAction(
                                                                                onPressed: () => ScaffoldMessenger.of(context).removeCurrentSnackBar(),
                                                                                label: 'OK',
                                                                              )));
                                                                        } else {
                                                                          var phone = snapshot
                                                                              .data
                                                                              .phoneNumber;
                                                                          var _url =
                                                                              "whatsapp://send?phone=$phone";
                                                                          await canLaunch(_url)
                                                                              ? await launch(_url)
                                                                              : ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                                                                  content: Text('Seems like you don\'t have WhatsApp ${Emojis.cryingFace}'),
                                                                                  action: SnackBarAction(
                                                                                    onPressed: () => ScaffoldMessenger.of(context).removeCurrentSnackBar(),
                                                                                    label: 'OK',
                                                                                  )));
                                                                        }
                                                                      }
                                                                    : null,
                                                            icon: Icon(
                                                              FontAwesomeIcons
                                                                  .whatsapp,
                                                            ),
                                                            type: GFButtonType
                                                                .transparent,
                                                          ),
                                                          GFIconButton(
                                                            onPressed: snapshot
                                                                    .data
                                                                    .contactOptions
                                                                    .contains(
                                                                        'sms')
                                                                ? () async {
                                                                    var phone =
                                                                        snapshot
                                                                            .data
                                                                            .phoneNumber;
                                                                    var _url =
                                                                        "sms:$phone";
                                                                    await canLaunch(
                                                                            _url)
                                                                        ? await launch(
                                                                            _url)
                                                                        : ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                                                            content: Text('Something went wrong ${Emojis.cryingFace}'),
                                                                            action: SnackBarAction(
                                                                              onPressed: () => ScaffoldMessenger.of(context).removeCurrentSnackBar(),
                                                                              label: 'OK',
                                                                            )));
                                                                  }
                                                                : null,
                                                            icon: Icon(
                                                              FontAwesomeIcons
                                                                  .sms,
                                                            ),
                                                            type: GFButtonType
                                                                .transparent,
                                                          ),
                                                          GFIconButton(
                                                            onPressed:
                                                                () async {
                                                              var phone = snapshot
                                                                  .data
                                                                  .phoneNumber;
                                                              var _url =
                                                                  "tel:$phone";
                                                              await canLaunch(
                                                                      _url)
                                                                  ? await launch(
                                                                      _url)
                                                                  : ScaffoldMessenger.of(
                                                                          context)
                                                                      .showSnackBar(SnackBar(
                                                                          content: Text('Something went wrong ${Emojis.cryingFace}'),
                                                                          action: SnackBarAction(
                                                                            onPressed: () =>
                                                                                ScaffoldMessenger.of(context).removeCurrentSnackBar(),
                                                                            label:
                                                                                'OK',
                                                                          )));
                                                            },
                                                            icon: Icon(
                                                              FontAwesomeIcons
                                                                  .phoneAlt,
                                                            ),
                                                            type: GFButtonType
                                                                .transparent,
                                                          ),
                                                        ],
                                                      );
                                                  }
                                                  return Container();
                                                }),
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
                                          );
                                        } else {
                                          return CircularProgressIndicator();
                                        }
                                      }
                                      return Container();
                                    });
                                break;
                              default: // if user is not authenticated or not joined to activity
                                return FutureBuilder(
                                    future:
                                        Provider.of<FirestoreProvider>(context)
                                            .instance
                                            .getAdditionalUserData(
                                                context: context,
                                                uid: widget.activity
                                                    .joinAccepted[index]),
                                    builder: (BuildContext context,
                                        AsyncSnapshot<UserProfile> snapshot) {
                                      if (snapshot.hasData) {
                                        if (snapshot.data != null) {
                                          return GFListTile(
                                            onTap: () => Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        ProfileExpanded(
                                                          userProfile:
                                                              snapshot.data,
                                                        ))),
                                            margin: EdgeInsets.all(0),
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
                                          );
                                        } else {
                                          return CircularProgressIndicator();
                                        }
                                      }
                                      return Container();
                                    });
                                break;
                            }
                          }
                          return joinButtonShimmer();
                        } else {
                          return joinButtonShimmer();
                        }
                      });
                });
          },
        ),
      ),
    );
  }
}
