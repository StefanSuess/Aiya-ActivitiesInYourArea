import 'package:Aiya/services/activities/firestore_provider.dart';
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
  });

  //listen to messages while app is in background on IOS and Android
  Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    print("Handling a background message: ${message.messageId}");
  }
}
