import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:trem_pocket/core/event.dart';
import 'package:trem_pocket/view/init.dart';

import 'core/background.dart';
import 'core/global.dart';

@pragma('vm:entry-point')
Future<void> _BackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  OnData(message.data, "Background");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  await messaging.requestPermission(
    alert: true,
    announcement: true,
    badge: true,
    carPlay: true,
    criticalAlert: true,
    provisional: true,
    sound: true,
  );
  FirebaseMessaging.onBackgroundMessage(_BackgroundHandler);
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    OnData(message.data, "Main");
  });
  initializeService();
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('ic_launcher');
  const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid, iOS: null, macOS: null);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  FirebaseMessaging.instance.subscribeToTopic("App");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'TREM Pocket',
      home: InitPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
