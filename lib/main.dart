import 'package:Aiya/screens/login/login_widget.dart';
import 'package:Aiya/screens/main_widget.dart';
import 'package:Aiya/screens/splash_screen.dart';
import 'package:Aiya/services/CludeStore/cloudstore_provider.dart';
import 'package:Aiya/services/CludeStore/cloudstore_service.dart';
import 'package:Aiya/services/activities/firestore_provider.dart';
import 'package:Aiya/services/activities/firestore_service.dart';
import 'package:Aiya/theme/theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'services/user/auth_provider.dart';
import 'services/user/auth_service.dart';

Future<void> main() async {
  // make sure firebaes is initialized before checking if user is logged in (firebase uses native code)
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // firebase push messaging background handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(MyApp());
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
    if (MediaQuery.of(context).size.width > 800) {
      return onlySupportedOnMobile(context);
    }
    final auth = Provider.of<AuthProvider>(context).auth;

    return StreamBuilder(
      builder: (context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
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

  Widget onlySupportedOnMobile(BuildContext context) {
    return MaterialApp(
        theme: myTheme,
        debugShowCheckedModeBanner: false,
        home: Scaffold(
            backgroundColor: Colors.white,
            body: Stack(
              children: [
                Image.asset(
                  'assets/images/another_dimension.png',
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                ),
                Positioned(
                  top: MediaQuery.of(context).size.height - 50,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: Text(
                          'This app is designed for small screens like mobile phones, but if you really want to use it on a PC you can resize your browser window an reload the website :)',
                          style: GoogleFonts.roboto(fontSize: 16),
                          softWrap: true,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                    top: 50,
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Text(
                          'Seems like your coming from another dimension',
                          style: GoogleFonts.roboto(fontSize: 32),
                          softWrap: true,
                        ),
                      ),
                    ))
              ],
            )));
  }
}
