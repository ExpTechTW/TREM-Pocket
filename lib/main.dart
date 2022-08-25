import 'dart:async';

import 'package:clipboard/clipboard.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_loggy/flutter_loggy.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:loggy/loggy.dart';
import 'package:trem/core/api.dart';
import 'package:trem/ui/initialization.dart';

import 'core/foreground.dart';

Future<void> _BackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  FlutterBackgroundService().invoke("data", message.data);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Loggy.initLoggy(
    logPrinter: StreamPrinter(
      const PrettyDeveloperPrinter(),
    ),
    logOptions: const LogOptions(
      LogLevel.all,
      stackTraceLevel: LogLevel.error,
    ),
  );
  await Firebase.initializeApp();
  await initializeService();
  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    announcement: true,
    badge: true,
    carPlay: true,
    criticalAlert: true,
    provisional: true,
    sound: true,
  );
  FirebaseMessaging.onBackgroundMessage(_BackgroundHandler);
  FirebaseMessaging.onMessage.listen((event) {
    FlutterBackgroundService().invoke("data", event.data);
  });
  FirebaseToken = (await FirebaseMessaging.instance.getToken())!;
  logInfo('FirebaseToken: $FirebaseToken');
  FlutterClipboard.copy(FirebaseToken);
  await Hive.initFlutter();
  await Hive.openBox('config');
  var config = Hive.box('config');
  if (config.get('init') == null) {
    config.put('init', true);
    config.put('CWB_EEW', true);
    config.put('ICL_EEW', true);
    config.put('JMA_EEW', true);
    config.put('Palert', true);
    config.put('Report', true);
    config.put('NIED_EEW', true);
    config.put('KMA_EEW', true);
    config.put('FJDZJ_EEW', true);
    config.put('Tsunami', true);
    config.put('setVolume', true);
    config.put('site_use', true);
    config.put('wave', true);
    config.put('intensity', "0級");
    await FirebaseMessaging.instance.subscribeToTopic("CWB_EEW");
    await FirebaseMessaging.instance.subscribeToTopic("ICL_EEW");
    await FirebaseMessaging.instance.subscribeToTopic("JMA_EEW");
    await FirebaseMessaging.instance.subscribeToTopic("Palert");
    await FirebaseMessaging.instance.subscribeToTopic("Report");
    await FirebaseMessaging.instance.subscribeToTopic("NIED_EEW");
    await FirebaseMessaging.instance.subscribeToTopic("KMA_EEW");
    await FirebaseMessaging.instance.subscribeToTopic("FJDZJ_EEW");
    await FirebaseMessaging.instance.subscribeToTopic("Tsunami");
  }
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      FlutterBackgroundService().invoke("start");
    });
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: InitializationPage(),
    );
  }
}

Future<void> initializeService() async {
  final service = FlutterBackgroundService();
  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      isForegroundMode: true,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
  );
  service.startService();
}

bool onIosBackground(ServiceInstance service) {
  return true;
}
