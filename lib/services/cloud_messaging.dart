import 'package:Aiya/services/activities/firestore_provider.dart';
import 'package:emojis/emojis.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/components/button/gf_button.dart';
import 'package:getwidget/getwidget.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> requestFCMPermission(BuildContext context) async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // if on the web show a short notification
  if (kIsWeb && !await getNotificationsFlag()) {
    showRequestNotificationExplainer(context);
  }

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  switch (settings.authorizationStatus) {
    case AuthorizationStatus.authorized:
      setNotificationsFlag(true);
      break;
    case AuthorizationStatus.denied:
      setNotificationsFlag(false);
      break;
    default:
  }

  // set web tokens for web push via browser
  String token = await messaging.getToken(
    vapidKey:
        "BMDlBGVGTylq0dPExvBFTk00knbHwZoIVF6PZNsW4LqihmFPHQkui1SYEFSmo-yTdxFlR-Ql9j1b6hRd8wbZv0w",
  );

  print('User granted permission: ${settings.authorizationStatus}');
  // get notification Token
  String notificationToken = await FirebaseMessaging.instance.getToken();
  print('notificationToken: $notificationToken');
  // upload token to identify user to device
  Provider.of<FirestoreProvider>(context, listen: false)
      .instance
      .setAdditionalUserData(
          context: context, notificationToken: notificationToken);
}

void showRequestNotificationExplainer(BuildContext context) {
  Widget okButton = GFButton(
    text: 'OK',
    onPressed: () {
      Navigator.of(context, rootNavigator: true).pop();
      requestFCMPermission(context);
    },
    fullWidthButton: true,
  );
  AlertDialog alert = AlertDialog(
    title: Text("Authentication required"),
    content: Text(
        'We would like to send you push notifications if someone requests to join your activity or if someone accepts your join request'),
    actions: [okButton],
  );
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

//listen to messages while app is in background on IOS and Android
Future<void> setBackgroundPushNotificationListener(
    RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
}

setForegroundPushNotificationListener(BuildContext context) {
  // listen to messages while app is in foreground
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Got a message whilst in the foreground!');
    print('Message data: ${message.data}');

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('${message.data} ${Emojis.partyingFace}'),
      action: SnackBarAction(
        onPressed: () => ScaffoldMessenger.of(context).removeCurrentSnackBar(),
        label: 'OK',
      ),
    ));
  });
}

setNotificationsFlag(bool enabled) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setBool('notificationFlag', enabled);
}

Future<bool> getNotificationsFlag() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getBool('notificationFlag') ?? false;
}
