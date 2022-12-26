import 'dart:convert';

import 'package:alarmplayer/alarmplayer.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trem_pocket/core/api.dart';

import 'global.dart';

Alarmplayer alarmplayer = Alarmplayer();

void OnData(Map _data, String Sender) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var data = jsonDecode(_data["Data"]);
  const AndroidNotificationDetails androidNotificationDetails =
      AndroidNotificationDetails('TREM Pocket', 'earthquake',
          channelDescription: '',
          importance: Importance.max,
          priority: Priority.max,
          ticker: 'ticker');
  const NotificationDetails notificationDetails =
      NotificationDetails(android: androidNotificationDetails);
  if (data["Function"] == "TREM") {
    if (prefs.getBool('accept_trem') ?? false) {
      alarmplayer.Alarm(
        url: "assets/audios/note.mp3",
        volume: 1,
      );
      await flutterLocalNotificationsPlugin.show(
          2, '地震檢知', "${data["Location"]}", notificationDetails,
          payload: '');
    }
  } else if (data["Function"] == "earthquake") {
    if (prefs.getBool('accept_eew') ?? false) {
      var ans = Earthquake(data);
      print(ans);
      // alarmplayer.Alarm(
      //   url: "assets/audios/warn.mp3",
      //   volume: 1,
      // );
      // alarmplayer.Alarm(
      //   url: "assets/audios/alert.mp3",
      //   volume: 1,
      // );
      await flutterLocalNotificationsPlugin
          .show(3, '強震即時警報', '慎防強烈搖晃', notificationDetails, payload: '');
    }
  } else if (data["Function"] == "report") {
    if (prefs.getBool('accept_report') ?? false) {
      String loc = data["Location"]
          .toString()
          .substring(data["Location"].toString().indexOf("(") + 1,
              data["Location"].toString().indexOf(")"))
          .replaceAll("位於", "");
      await flutterLocalNotificationsPlugin.show(
          5, '地震報告', "$loc 發生規模 ${data["Scale"]} 地震", notificationDetails,
          payload: '');
    }
  } else if (data["Function"] == "palert") {
    if (prefs.getBool('accept_palert') ?? false) {
      await flutterLocalNotificationsPlugin.show(4, '近即時震度',
          "最大震度 ${data["Location"]} ${data["Intensity"]}級", notificationDetails,
          payload: '');
    }
  }
}
