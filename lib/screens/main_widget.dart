import 'dart:async';

import 'package:Aiya/constants.dart';
import 'package:Aiya/data_models/activity_data.dart';
import 'package:Aiya/screens/create/create_widget.dart';
import 'package:Aiya/screens/dashboard/dashboard.dart';
import 'package:Aiya/screens/explore/explore_widget.dart';
import 'package:Aiya/screens/intro/intro_widget.dart';
import 'package:Aiya/services/cloud_messaging.dart';
import 'package:Aiya/services/firestore/firestore_provider.dart';
import 'package:animations/animations.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_links/uni_links.dart';

import 'activity_detail/activity_detail_widget.dart';

class MainWidget extends StatefulWidget {
  @override
  _MainWidgetState createState() => _MainWidgetState();
}

class _MainWidgetState extends State<MainWidget> {
  StreamSubscription _sub;
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
    messageHandler();
    showIntroScreen();
    initUniLinks();
    initializeLocalNotifications();
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

  showIntroScreen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('isFirstStart') ?? true == true) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => IntroPage()));
    }
  }

  Future<void> initUniLinks() async {
    String theLink;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      final initialLink = await getInitialLink();
      print('INITIALLINK: ' + initialLink);
      if (initialLink != null) {
        theLink = initialLink;
      }
      // Parse the link and warn the user, if it is not correct,
      // but keep in mind it could be `null`.
    } on Exception {
      // Handle exception by warning the user their action did not succeed
      // return?
    }
    // Attach a listener to the stream
    _sub = linkStream.listen((String link) {
      print('INITIALLINK: ' + link);
      if (link != null) {
        theLink = link;
      }
      //TODO Parse the link and warn the user, if it is not correct
    }, onError: (err) {
      //TODO Handle exception by warning the user their action did not succeed
    });
    // split the string via /
    List<String> substrings = theLink.split('/');
    // take only the last entry for example https://activitiesinyourarea-500ef.web.app/#/create would be "create" at the end
    theLink = substrings.last;
    print(substrings.last);
    switch (theLink) {
      case 'create':
        navigatorKey.currentState.pushReplacementNamed(constants.createRoute);
        break;
      case 'dashboard':
        navigatorKey.currentState
            .pushReplacementNamed(constants.dashboardRoute);
        break;
      case 'explore':
        navigatorKey.currentState.pushReplacementNamed(constants.exploreRoute);
        break;
      default:
        // activity will be like activity=23834 (activityID), split at the "="
        if (theLink.contains('activity')) {
          substrings = theLink.split('=');
          print(substrings.last);
          // get the activity
          Activity activity =
              await Provider.of<FirestoreProvider>(context, listen: false)
                  .instance
                  .getOneActivity('activities/${substrings.last}');
          // push the route
          navigatorKey.currentState.pushReplacementNamed(
              constants.activityDetailRoute,
              arguments: activity);
        }
    }
  }

  @override
  void dispose() {
    super.dispose();
    _sub.cancel();
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
            observers: [HeroController()],
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

  Future initializeLocalNotifications() async {
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
// initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    final IOSInitializationSettings initializationSettingsIOS =
        IOSInitializationSettings(
      onDidReceiveLocalNotification: (id, title, body, payload) => null,
    );
    final MacOSInitializationSettings initializationSettingsMacOS =
        MacOSInitializationSettings();
    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS,
            macOS: initializationSettingsMacOS);
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onSelectNotification: (payload) async {
        var screen = payload.split('=').first;
        var activityID = payload.split('=').last;
        Activity activity =
            await Provider.of<FirestoreProvider>(context, listen: false)
                .instance
                .getOneActivity('activities/$activityID');
        switch (screen) {
          case 'activityDetail':
            navigatorKey.currentState
                .pushNamed(constants.activityDetailRoute, arguments: activity);
            break;
          case 'dashboard':
            navigatorKey.currentState.pushNamed(constants.dashboardRoute);
            break;
          default:
        }
        return null;
      },
    );

    FirebaseMessaging.onMessage.listen((event) async {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails('your channel id', 'your channel name',
              'your channel description',
              importance: Importance.max,
              playSound: true,
              autoCancel: true,
              channelShowBadge: true,
              enableVibration: true,
              onlyAlertOnce: true,
              priority: Priority.max,
              showWhen: true);
      const NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);
      await flutterLocalNotificationsPlugin.show(0, event.notification.title,
          event.notification.body, platformChannelSpecifics,
          payload: '${event.data['screen']}=${event.data['activity']}');
    });
  }
}
