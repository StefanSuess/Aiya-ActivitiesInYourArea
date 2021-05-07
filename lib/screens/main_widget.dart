import 'package:Aiya/constants.dart';
import 'package:Aiya/screens/create/create_widget.dart';
import 'package:Aiya/screens/dashboard/dashboard.dart';
import 'package:Aiya/screens/explore/explore_widget.dart';
import 'package:Aiya/services/cloud_messaging.dart';
import 'package:Aiya/services/firestore/firestore_provider.dart';
import 'package:animations/animations.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'activity_detail/activity_detail_widget.dart';

class MainWidget extends StatefulWidget {
  @override
  _MainWidgetState createState() => _MainWidgetState();
}

class _MainWidgetState extends State<MainWidget> {
  int _selectedIndex = 0;
  static final navigatorKey = GlobalKey<NavigatorState>();

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        // material guidelines recommend no back navigation inside the navigationbar => replace route at the stack
        navigatorKey.currentState.pushReplacementNamed(constants.exploreRoute);
        break;
      case 1:
        navigatorKey.currentState.pushReplacementNamed(constants.createRoute);
        break;
      case 2:
        navigatorKey.currentState
            .pushReplacementNamed(constants.dashboardRoute);
        break;
      default:
        throw Exception('Invalid index: $index');
    }
  }

  @override
  void initState() {
    super.initState();
    requestFCMPermission(context);
    this.initDynamicLinks();
    messageHandler();
  }

  messageHandler() {
    FirebaseMessaging.onMessageOpenedApp.listen((event) async {
      // TODO maybe just send the activity as json in payload instead of just activityId?
      var activity =
          await Provider.of<FirestoreProvider>(context, listen: false)
              .instance
              .getOneActivity('activities/${event.data['activity']}');
      navigatorKey.currentState
          .pushNamed(event.data['screen'], arguments: activity);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        elevation: 15,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.create),
            label: 'Create',
          ),
          BottomNavigationBarItem(
            label: 'Dashboard',
            icon: Icon(Icons.dashboard),
          ),
        ],
        selectedItemColor: Theme.of(context).bottomAppBarColor,
        onTap: _onItemTapped,
      ),
      body: SafeArea(
        child: WillPopScope(
          // make sure the back button takes us back if possible and does not unexpectedly close the app
          onWillPop: () async {
            return await navigatorKey.currentState.maybePop() ? false : true;
          },
          child: Navigator(
            key: navigatorKey,
            onGenerateRoute: (RouteSettings settings) {
              WidgetBuilder builder;
              return PageRouteBuilder(
                settings: settings,
                transitionDuration: Duration(milliseconds: 500),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  return SharedAxisTransition(
                    animation: animation,
                    transitionType: SharedAxisTransitionType.horizontal,
                    secondaryAnimation: secondaryAnimation,
                    child: child,
                  );
                },
                pageBuilder: (context, animation, secondaryAnimation) {
                  // All routes live here!
                  switch (settings.name) {
                    case constants.exploreRoute:
                      return ExploreWidget();
                      break;
                    case constants.createRoute:
                      return CreateWidget(
                        activity: settings.arguments,
                      );
                      break;
                    case constants.dashboardRoute:
                      return Dashboard();
                      break;
                    case constants.activityDetailRoute:
                      return ActivityDetail(activity: settings.arguments);
                      break;
                    case constants.editActivityRoute:
                      // use create widget as edit widget, give widget arguments to signify that it is in "edit state"
                      return CreateWidget(activity: settings.arguments);
                      break;
                    default:
                      return ExploreWidget();
                      break;
                  }
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
