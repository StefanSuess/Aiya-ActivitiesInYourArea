import 'package:Aiya/services/activities/firestore_provider.dart';
import 'package:emojis/emojis.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Future<void> requestFCMPermission(BuildContext context) async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  // set web tokens for web push via browser
  String token = await messaging.getToken(
    vapidKey:
        "BMDlBGVGTylq0dPExvBFTk00knbHwZoIVF6PZNsW4LqihmFPHQkui1SYEFSmo-yTdxFlR-Ql9j1b6hRd8wbZv0w",
  );

  print('User granted permission: ${settings.authorizationStatus}');
  // get notification Token
  String notificationToken = await FirebaseMessaging.instance.getToken();
  print('notificationToken: $notificationToken');
  // upload token to use later
  Provider.of<FirestoreProvider>(context, listen: false)
      .instance
      .setAdditionalUserData(
          context: context, notificationToken: notificationToken);

  // listen to messages while app is in foreground
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Got a message whilst in the foreground!');
    print('Message data: ${message.data}');

    if (message.notification != null) {
      print('Message also contained a notification: ${message.notification}');
    }

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
          'You have a new notification in the Dashboard! ${Emojis.partyingFace}'),
      action: SnackBarAction(
        onPressed: () => ScaffoldMessenger.of(context).removeCurrentSnackBar(),
        label: 'OK',
      ),
    ));
  });

  //listen to messages while app is in background on IOS and Android
  Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    print("Handling a background message: ${message.messageId}");
  }
}
