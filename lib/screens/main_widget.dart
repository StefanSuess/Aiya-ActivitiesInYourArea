import 'package:Aiya/constants.dart';
import 'package:Aiya/screens/activity_detail/activity_detail_widget.dart';
import 'package:Aiya/screens/create/create_widget.dart';
import 'package:Aiya/screens/dashboard/dashboard.dart';
import 'package:Aiya/screens/explore/explore_widget.dart';
import 'package:Aiya/screens/profile/profile_widget.dart';
import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

class MainWidget extends StatefulWidget {
  @override
  _MainWidgetState createState() => _MainWidgetState();
}

class _MainWidgetState extends State<MainWidget> {
  bool _isFirstBuild = true;
  int _selectedIndex = 0;
  static final navigatorKey = GlobalKey<NavigatorState>();

  final _widgetsList = {
    constants.exploreRoute: ExploreWidget(),
    constants.createRoute: CreateWidget(),
    constants.dashboardRoute: Dashboard()
  };
  final List<String> _routes = [
    constants.exploreRoute,
    constants.createRoute,
    constants.dashboardRoute,
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // material guidelines recommend no back navigation inside the navigationbar => replace route at the stack
    navigatorKey.currentState.pushReplacementNamed(_routes[index]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        elevation: 15,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.create),
            label: 'Create',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
        ],
        selectedItemColor: Theme.of(context).bottomAppBarColor,
        onTap: _onItemTapped,
      ),
      body: SafeArea(
        child: WillPopScope(
          // make sure the back button takes us back if possible and does not unexpectedly close the app
          onWillPop: () async {
            if (await navigatorKey.currentState.maybePop()) {
              return false;
            }
            return true;
          },
          child: Navigator(
            key: navigatorKey,
            initialRoute: constants.exploreRoute,
            onGenerateRoute: (RouteSettings settings) {
              WidgetBuilder builder;
              // All routes live here!
              switch (settings.name) {
                case constants.exploreRoute:
                  builder = (BuildContext context) => ExploreWidget();
                  // check that setState is not called on the first build because explore widget is the first initial route
                  if (!_isFirstBuild) {
                    _isFirstBuild = false;
                    setState(() {
                      _selectedIndex = 0;
                    });
                  }
                  _isFirstBuild = false;
                  break;
                case constants.createRoute:
                  builder = (BuildContext context) => CreateWidget();
                  if (!_isFirstBuild) {
                    _isFirstBuild = false;
                    setState(() {
                      _selectedIndex = 1;
                    });
                  }
                  _isFirstBuild = false;
                  break;
                case constants.dashboardRoute:
                  builder = (BuildContext context) => Dashboard();
                  if (!_isFirstBuild) {
                    _isFirstBuild = false;
                    setState(() {
                      _selectedIndex = 2;
                    });
                  }
                  _isFirstBuild = false;
                  break;
                case constants.activityDetailRoute:
                  builder = (BuildContext context) =>
                      ActivityDetail(activity: settings.arguments);
                  break;
                default:
                  throw Exception('Invalid route: ${settings.name}');
              }
              return PageRouteBuilder(
                  settings: settings,
                  transitionDuration: Duration(milliseconds: 500),
                  pageBuilder: (BuildContext context,
                      Animation<double> animation,
                      Animation<double> secondaryAnimation) {
                    // if transition to activityDetail then do container transform animation
                    // TODO: implement animation correctly
                    if (settings.name == constants.activityDetailRoute) {
                      return OpenContainer(
                          transitionType: ContainerTransitionType.fadeThrough,
                          tappable: false,
                          transitionDuration: Duration(seconds: 2),
                          closedBuilder: (context, action) =>
                              ActivityDetail(activity: settings.arguments),
                          openBuilder: (context, action) => ExploreWidget());
                    } else if (settings.name == constants.profilePageRoute) {
                      return OpenContainer(
                          transitionType: ContainerTransitionType.fade,
                          closedBuilder: (context, action) =>
                              ActivityDetail(activity: settings.arguments),
                          openBuilder: (context, action) => ProfileWidget());
                    }

                    // return sharedAxisTransition as standard transition
                    return SharedAxisTransition(
                      animation: animation,
                      transitionType: SharedAxisTransitionType.horizontal,
                      secondaryAnimation: secondaryAnimation,
                      child: _widgetsList[settings.name],
                    );
                  });
            },
          ),
        ),
      ),
    );
  }

//body: SafeArea(child: _children[_selectedIndex]),
}
