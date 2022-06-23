import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:trem/core/service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeService();
  runApp(const MyApp());
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

void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  if (service is AndroidServiceInstance) {
    service.on('start').listen((event) {
      service.setAsForegroundService();
    });
  }

  service.on('stop').listen((event) {
    service.stopSelf();
  });

  service.on('notify').listen((event) {
    if (service is AndroidServiceInstance) {
      var data=json.decode(json.encode(event));
      service.setForegroundNotificationInfo(
        title: "TREM Pocket",
        content: data.body,
      );
    }
  });

  if (service is AndroidServiceInstance) {
    service.setForegroundNotificationInfo(
      title: "TREM Pocket",
      content: "地震速報 運行中",
    );
  }
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
      service();
    });
    return const MaterialApp(
      home: Scaffold(body: Text("123")),
    );
  }
}
