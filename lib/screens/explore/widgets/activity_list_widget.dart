import 'package:Aiya/constants.dart';
import 'package:Aiya/data_models/activity_data.dart';
import 'package:Aiya/data_models/profile_data.dart';
import 'package:Aiya/screens/activity_detail/activity_detail_widget.dart';
import 'package:Aiya/screens/dashboard/dashboard.dart';
import 'package:Aiya/screens/explore/widgets/create_your_own_activity_button.dart';
import 'package:Aiya/screens/profile/widgets/profile_picture_loader.dart';
import 'package:Aiya/services/firestore/firestore_provider.dart';
import 'package:animations/animations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:emojis/emojis.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/components/avatar/gf_avatar.dart';
import 'package:getwidget/components/card/gf_card.dart';
import 'package:getwidget/components/list_tile/gf_list_tile.dart';
import 'package:getwidget/components/shimmer/gf_shimmer.dart';
import 'package:getwidget/getwidget.dart';
import 'package:getwidget/position/gf_position.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ActivityListCard extends StatefulWidget {
  @override
  _ActivityListCardState createState() => _ActivityListCardState();
}

class _ActivityListCardState extends State<ActivityListCard> {
  static final navigatorKey = GlobalKey<NavigatorState>();

  var activityDetail;

  double cardHeight = 200;
  bool isFirstStart =
      true; // check if this is the first time showing this screen since opening the app

  @override
  void dispose() {
    // set firststart to true when widget is disposed
    isFirstStart = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Provider.of<FirestoreProvider>(context, listen: false)
          .instance
          .getActivitiesOneTime(),
      builder: (BuildContext context, AsyncSnapshot<List<Activity>> snapshot) {
        if (snapshot.hasError) {
          return Text(snapshot.error.toString());
        }
        if (snapshot.connectionState == ConnectionState.done ||
            snapshot.connectionState == ConnectionState.active) {
          // TODO: make this more secure (what if snapshot has no data yet?)
          Activity.activityList = List.from(snapshot.data);
          // populate the filtered list with entries if this is the first start of the app
          if (isFirstStart && snapshot.data.isNotEmpty) {
            isFirstStart = false;
            Activity.filteredActivityList = List.from(Activity.activityList);
            activityDetail = Activity.filteredActivityList[0];
          }

          if (MediaQuery.of(context).size.width < 600) {
            return ActivityDetailSmallScreen();
          } else {
            return ActivityDetailMediumScreen();
          }
        }
        if (MediaQuery.of(context).size.width < 600) {
          // do not load shimmer animation on web if the screen is bigger
          return loadingShimmer();
        } else {
          return Container();
        }
      },
    );
  }

  // shimmer loading widget
  Widget loadingShimmer() {
    return Expanded(
      child: ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        itemBuilder: (_, __) => GFShimmer(
          child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 32.0),
                    child: Container(
                      width: 200,
                      height: 16,
                      color: Colors.white,
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 8, left: 32, bottom: 12.0),
                    child: Container(
                      width: 130,
                      height: 12,
                      color: Colors.white,
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 200,
                    color: Colors.white,
                  ),
                ],
              )),
        ),
        itemCount: 3,
      ),
    );
  }

  // show the number of joined people of an activity
  Widget joinedPeople({@required int length, @required Activity activity}) {
    var _avatarSize = 50.0;
    var _paintedLastItem = false;
    return FutureBuilder(
        future: Provider.of<FirestoreProvider>(context)
            .instance
            .getAdditionalUserData(context: context, uid: activity.creatorUID),
        builder: (BuildContext context, AsyncSnapshot<UserProfile> snapshot) {
          if (snapshot.hasError) throw (snapshot.error);
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Container();
            case ConnectionState.active:
            case ConnectionState.done:
              return LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  return Container(
                      height: _avatarSize,
                      child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          shrinkWrap: true,
                          itemCount: length + 1,
                          itemBuilder: (context, index) {
                            // show picture of activity creator by comparing activity uid to current uid
                            if (index == 0) {
                              return ProfilePictureLoader(
                                imageURL: snapshot.data.photoURL,
                                size: _avatarSize,
                              );
                              // align all other avatars
                            } else if (index <
                                ((constraints.maxWidth) -
                                        (_avatarSize * 0.75 * 2)) /
                                    (_avatarSize * 0.75)) {
                              return Align(
                                widthFactor: 0.4,
                                child: FutureBuilder(
                                    future:
                                        Provider.of<FirestoreProvider>(context)
                                            .instance
                                            .getAdditionalUserData(
                                                context: context,
                                                uid: activity
                                                    .joinAccepted[index - 1]),
                                    builder: (BuildContext context,
                                        AsyncSnapshot<UserProfile> snapshot) {
                                      if (snapshot.hasData) {
                                        if (snapshot.data != null) {
                                          return ProfilePictureLoader(
                                            imageURL: snapshot.data.photoURL,
                                            size: 50,
                                          );
                                        } else {
                                          return CircularProgressIndicator();
                                        }
                                      }
                                      return Container();
                                    }),
                              );
                              // show the remaining number of people one time and then return container
                            } else {
                              if (!_paintedLastItem) {
                                _paintedLastItem = true;
                                var remainingPeople = length - index;
                                return Align(
                                  widthFactor: 0.75,
                                  child: GFAvatar(
                                    backgroundColor:
                                        Theme.of(context).accentColor,
                                    child: Text(
                                      '+$remainingPeople',
                                      style: GoogleFonts.roboto(
                                          color: Colors.white),
                                    ),
                                  ),
                                );
                              }
                            }
                            return Container();
                          }));
                },
              );
          }
          return Container(); // unreachable}, ),
        });
  }

  Widget ActivityDetailMediumScreen() {
    return Expanded(
      child: Row(
        children: [
          ActivityDetailSmallScreen(),
          DetailWidget(),
        ],
      ),
    );
  }

  Widget DetailWidget() {
    return Flexible(
      flex: 2,
      child: Navigator(
        key: navigatorKey,
        initialRoute: constants.exploreRoute,
        onGenerateRoute: (RouteSettings settings) {
          WidgetBuilder builder;
          switch (settings.name) {
            case constants.exploreRoute:
              builder = (BuildContext context) => Dashboard();
              break;
            default:
              throw Exception('Invalid route: ${settings.name}');
          }
          return PageRouteBuilder(
              settings: settings,
              pageBuilder: (BuildContext context, Animation<double> animation,
                  Animation<double> secondaryAnimation) {
                return SharedAxisTransition(
                  animation: animation,
                  transitionType: SharedAxisTransitionType.horizontal,
                  secondaryAnimation: secondaryAnimation,
                  child: ActivityDetail(
                    activity: activityDetail,
                  ),
                );
              });
        },
      ),
    );
  }

  void changeActivityDetail(int index) {
    navigatorKey.currentState.pushNamed(constants.exploreRoute);

    activityDetail = Activity.filteredActivityList[index];
  }

  Widget ActivityDetailSmallScreen() {
    return Expanded(
      child: ListView.builder(
          itemCount: Activity.filteredActivityList.length + 1,
          itemBuilder: (context, index) {
            // show a "create your own activity" button at the end of the list
            if (index == Activity.filteredActivityList.length) {
              return Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: CreateYourOwnActivityButton());
            }
            return InkWell(
              onTap: () => MediaQuery.of(context).size.width < 600
                  ? Navigator.of(context).pushNamed(
                      constants.activityDetailRoute,
                      arguments: Activity.filteredActivityList[index])
                  : changeActivityDetail(index),
              child: GFCard(
                margin: EdgeInsets.all(8),
                padding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 4.0),
                boxFit: BoxFit.cover,
                titlePosition: GFPosition.start,
                image: MediaQuery.of(context).size.width < 600
                    ? Image(
                        image: CachedNetworkImageProvider(
                            'https://source.unsplash.com/500x500/?${Activity.filteredActivityList[index].title}'),
                        fit: BoxFit.cover,
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.width / 3,
                      )
                    : Image(
                        image: CachedNetworkImageProvider(
                            'https://source.unsplash.com/500x500/?${Activity.filteredActivityList[index].title}'),
                        fit: BoxFit.cover,
                        width: 0,
                        height: 0,
                      ),
                title: GFListTile(
                  padding: EdgeInsets.all(0),
                  titleText: Activity.filteredActivityList[index].title,
                  subtitleText: Activity.filteredActivityList[index].location,
                ),
                content: Padding(
                  // no idea why this works
                  padding: const EdgeInsets.only(left: 4.0, right: 16.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                          child: joinedPeople(
                              activity: Activity.filteredActivityList[index],
                              length: Activity.filteredActivityList[index]
                                      .joinAccepted?.length ??
                                  0 + 1)),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Text(
                            '${Emojis.timerClock} ${DateFormat('kk:mm').format(Activity.filteredActivityList[index].dateTime.toDate())}',
                            style: GoogleFonts.roboto(
                                fontSize: 16, fontWeight: FontWeight.w400),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              '${Emojis.calendar} ${DateFormat('dd-MM').format(Activity.filteredActivityList[index].dateTime.toDate())}',
                              style: GoogleFonts.roboto(
                                  fontSize: 16, fontWeight: FontWeight.w400),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            );
          }),
    );
  }
}
