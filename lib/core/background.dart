import 'dart:async';
import 'dart:ui';

import 'package:android_autostart/android_autostart.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api.dart';
import 'global.dart';
import 'ntp.dart';

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

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  Now(false);
  DartPluginRegistrant.ensureInitialized();
  if (service is AndroidServiceInstance) {
    service.setAsForegroundService();
    service.setForegroundNotificationInfo(
      title: "地震速報接收",
      content: "背景執行中",
    );
  }
  const AndroidNotificationDetails androidNotificationDetails =
      AndroidNotificationDetails('TREM Pocket', 'earthquake',
          channelDescription: '',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          ticker: 'ticker');
  const NotificationDetails notificationDetails =
      NotificationDetails(android: androidNotificationDetails);
  var update = await updateChecker();
  if (update["update"]) {
    await flutterLocalNotificationsPlugin.show(
        1, '新版本!', update["lastVersion"], notificationDetails,
        payload: '');
  }
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if (prefs.getBool('auto_start') ?? false) {
    await prefs.setBool('auto_start', true);
    await AndroidAutostart.navigateAutoStartSetting;
    await flutterLocalNotificationsPlugin
        .show(0, '歡迎!', "請給予應用程式 自啟動 權限", notificationDetails, payload: '');
  }
}
