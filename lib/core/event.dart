import 'dart:convert';

import 'package:alarmplayer/alarmplayer.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trem_pocket/core/api.dart';

import 'global.dart';
import 'ntp.dart';

Alarmplayer alarmplayer = Alarmplayer();
int trem_id = 0;
int eew_id = 0;

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
  if (data["time"] != null || data["timestamp"] != null) {
    data["UTC+8"] =
        DateTime.fromMillisecondsSinceEpoch(data["time"] ?? data["timestamp"])
            .toString()
            .substring(5, 16);
  }
  data["now"] = await Now(false);
  data["Now"] = DateTime.fromMillisecondsSinceEpoch(data["now"])
      .toString()
      .substring(11, 16);
  data["delay"] = double.parse(
      ((await Now(false) - data["timestamp"]) / 1000).toStringAsFixed(1));
  if (data["type"] == "trem-eew") {
    if (prefs.getBool('accept_trem') ?? false) {
      if (data["id"] != trem_id) {
        trem_id = data["id"];
        if (prefs.getBool('audio_trem') ?? false) {
          if (data["delay"] < 240) {
            alarmplayer.Alarm(
              url: "assets/audios/note.mp3",
              volume: 1,
            );
          }
        }
      }
      await flutterLocalNotificationsPlugin.show(
          2,
          '地震檢知 第${data["number"]}報 | ${data["UTC+8"]}',
          "${data["location"]}",
          notificationDetails,
          payload: '');
    }
  } else if (data["type"] == "eew-cwb") {
    eew_data = data;
    if (prefs.getBool('accept_eew') ?? false) {
      var ans = await Earthquake(data);
      if (data["id"] != eew_id) {
        eew_id = data["id"];
        if (prefs.getBool('audio_eew') ?? false) {
          if (data["delay"] < 240) {
            alarmplayer.Alarm(
              url: "assets/audios/warn.mp3",
              volume: 1,
            );
          }
        }
        if ((prefs.getBool('audio_intensity') ?? false) && ans[0] >= 4) {
          if (data["delay"] < 240) {
            alarmplayer.Alarm(
              url: "assets/audios/alert.mp3",
              volume: 1,
            );
          }
        }
      }
      int num = (ans[2] as double).truncate();
      String Num = (num <= 0) ? "抵達 (預警盲區)" : "$num秒 後抵達";
      String intensity = (ans[0] <= 4 || ans[0] == 9)
          ? "${ans[0]}級".replaceAll("9", "7")
          : int_to_intensity(ans[0])
              .toString()
              .replaceAll("+", "強")
              .replaceAll("-", "弱");
      await flutterLocalNotificationsPlugin.show(
          3,
          '強震即時警報 第${data["number"]}報 | ${data["UTC+8"]}',
          "$intensity 地震 $Num",
          notificationDetails,
          payload: '');
    }
  } else if (data["type"] == "report") {
    if (data["location"].toString().contains("TREM") &&
        !(prefs.getBool('accept_report') ?? false)) return;
    String loc = data["location"]
        .toString()
        .substring(data["location"].toString().indexOf("(") + 1,
            data["location"].toString().indexOf(")"))
        .replaceAll("位於", "");
    await flutterLocalNotificationsPlugin.show(5, '地震報告 | ${data["UTC+8"]}',
        "$loc 發生規模 ${data["scale"]} 地震", notificationDetails,
        payload: '');
  } else if (data["type"] == "palert-app") {
    if (prefs.getBool('accept_palert') ?? false) {
      await flutterLocalNotificationsPlugin.show(4, '近即時震度 | ${data["UTC+8"]}',
          "最大震度 ${data["location"]} ${data["intensity"]}級", notificationDetails,
          payload: '');
    }
  }
}
