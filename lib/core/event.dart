import 'dart:convert';

import 'package:alarmplayer/alarmplayer.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'global.dart';

Alarmplayer alarmplayer = Alarmplayer();

void OnData(Map _data, String Sender) async {
  print(_data);
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
    alarmplayer.Alarm(
      url: "assets/audios/note.mp3",
      volume: 1,
    );
    await flutterLocalNotificationsPlugin
        .show(2, '地震檢知', 'test', notificationDetails, payload: '');
  } else if (data["Function"] == "earthquake") {
    alarmplayer.Alarm(
      url: "assets/audios/warn.mp3",
      volume: 1,
    );
    alarmplayer.Alarm(
      url: "assets/audios/alert.mp3",
      volume: 1,
    );
    await flutterLocalNotificationsPlugin
        .show(3, '強震即時警報', '慎防強烈搖晃', notificationDetails, payload: '');
  } else if (data["Function"] == "report") {
    await flutterLocalNotificationsPlugin
        .show(5, '地震報告', 'test', notificationDetails, payload: '');
  } else if (data["Function"] == "palert") {
    await flutterLocalNotificationsPlugin
        .show(4, '近即時震度', 'test', notificationDetails, payload: '');
  }
}
