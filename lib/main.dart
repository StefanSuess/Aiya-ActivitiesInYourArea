import 'dart:ui';

import 'package:Aiya/screens/login/login_widget.dart';
import 'package:Aiya/screens/main_widget.dart';
import 'package:Aiya/screens/splash_screen.dart';
import 'package:Aiya/services/authentication/auth_provider.dart';
import 'package:Aiya/services/authentication/auth_service.dart';
import 'package:Aiya/services/cloudstore/cloudstore_provider.dart';
import 'package:Aiya/services/cloudstore/cloudstore_service.dart';
import 'package:Aiya/services/firestore/firestore_provider.dart';
import 'package:Aiya/services/firestore/firestore_service.dart';
import 'package:Aiya/theme/theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  // make sure firebaes is initialized before checking if user is logged in (firebase uses native code)
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // firebase push messaging background handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  initializeLocalNotifications();
  runApp(MyApp());
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
  final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
      macOS: initializationSettingsMacOS);
  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onSelectNotification: (payload) => null,
  );

  FirebaseMessaging.onMessage.listen((event) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
            'your channel id', 'your channel name', 'your channel description',
            importance: Importance.max,
            priority: Priority.high,
            showWhen: false);
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(0, event.notification.title,
        event.notification.body, platformChannelSpecifics,
        payload: 'item x');
  });
}

// firebase messaging background handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Set default `_initialized` and `_error` state to false
  bool _initialized = false;
  bool _error = false;

  @override
  void initState() {
    // make sure firebase is ready
    initializeFlutterFire();
    super.initState();
  }

  // Define an async function to initialize FlutterFire
  void initializeFlutterFire() async {
    try {
      // Wait for Firebase to initialize and set `_initialized` state to true
      await Firebase.initializeApp();
      setState(() {
        _initialized = true;
      });
    } catch (e) {
      // Set `_error` state to true if Firebase initialization fails
      setState(() {
        _error = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show error message if initialization failed
    if (_error) {
      print('Something went wrong');
      //return SomethingWentWrong(); // TODO show an error screen?
    }

    // Show a loader until FlutterFire is initialized
    if (!_initialized) {
      return MaterialApp(
          theme: ThemeData(
            primarySwatch: Colors.blue,
            bottomAppBarColor: Colors.blueAccent,
            primaryColor: Colors.blue,
            brightness: Brightness.light,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          debugShowCheckedModeBanner: false,
          home: SplashScreen());
    }
    return mainWrapper();
  }

  Widget mainWrapper() {
    // This needs to wrap the entire app to check if user is logged in at any point in time
    return MultiProvider(
      providers: [
        Provider<AuthProvider>(
            create: (_) => AuthProvider(
                  auth: AuthService(),
                )),
        Provider<FirestoreProvider>(
            create: (_) => FirestoreProvider(
                  instance: FirestoreService(),
                )),
        Provider<CloudStoreProvider>(
            create: (_) => CloudStoreProvider(
                  storage: CloudStoreService(),
                )),
      ],
      builder: (context, child) {
        return MaterialApp(
            theme: myTheme,
            debugShowCheckedModeBanner: false,
            home: HomeController());
      },
    );
  }
}

// check if user is logged in, if not show LoginPage else show the MainWidget
class HomeController extends StatelessWidget {
  const HomeController({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context).auth;
    return StreamBuilder(
      builder: (context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.connectionState == ConnectionState.active ||
            snapshot.connectionState == ConnectionState.waiting) {
          final signedIn = snapshot.hasData;
          return signedIn ? MainWidget() : LoginPage();
        }
        return MaterialApp(
            theme: myTheme,
            debugShowCheckedModeBanner: false,
            home: SplashScreen());
      },
      stream: auth.onAuthStateChanged,
    );
  }
}
