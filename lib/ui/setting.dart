import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';

import '../core/network.dart';

int Start = 0;
var Data = {};

class SetPage extends StatefulWidget {
  const SetPage({Key? key}) : super(key: key);

  @override
  _SetPage createState() => _SetPage();
}

class _SetPage extends State<SetPage> {
  bool _CWB = false;
  bool _KMA = false;
  bool _JMA = false;
  bool _FJDZJ = false;
  bool _NIED = false;
  bool _Palert = false;
  bool _Report = false;
  bool _SCDZJ = false;
  bool _Tsunami = false;
  bool _setVolume = false;
  bool _site = false;
  bool _wave = false;
  List<String> Citys = [];
  List<String> Towns = [];
  List<String> Intensity = [
    "0級",
    "1級",
    "2級",
    "3級",
    "4級",
    "5弱",
    "5強",
    "6弱",
    "6強",
    "7級"
  ];
  String city = "";
  String town = "";
  String intensity = "";

  _Switch(bool value, String Topic) async {
    await Hive.initFlutter();
    await Hive.openBox('config');
    var config = Hive.box('config');
    config.put(Topic, value);
    setState(() {});
    if (value) {
      await FirebaseMessaging.instance.subscribeToTopic(Topic);
    } else {
      await FirebaseMessaging.instance.unsubscribeFromTopic(Topic);
    }
  }

  @override
  void initState() {
    Start = 0;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.bottom]);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Hive.initFlutter();
      await Hive.openBox('config');
      var config = Hive.box('config');
      if (config.get('CWB_EEW')) {
        _CWB = true;
      }
      if (config.get('JMA_EEW')) {
        _JMA = true;
      }
      if (config.get('SCDZJ_EEW')) {
        _SCDZJ = true;
      }
      if (config.get('KMA_EEW')) {
        _KMA = true;
      }
      if (config.get('FJDZJ_EEW')) {
        _FJDZJ = true;
      }
      if (config.get('Palert')) {
        _Palert = true;
      }
      if (config.get('Report')) {
        _Report = true;
      }
      if (config.get('NIED_EEW')) {
        _NIED = true;
      }
      if (config.get('Tsunami')) {
        _Tsunami = true;
      }
      if (config.get('setVolume')) {
        _setVolume = true;
      }
      if (config.get('site_use')) {
        _site = true;
      }
      if (config.get('wave')) {
        _wave = true;
      }
      if (city == "") {
        city = config.get("city") ?? "臺南市";
        town = config.get("town") ?? "歸仁區";
      } else if (city != config.get("city")) {
        var list = [];
        city = config.get("city") ?? "臺南市";
        Data[city].forEach((key, value) {
          list.add(key);
        });
        town = list[0];
        config.put("town", list[0]);
      } else {
        town = config.get("town");
      }
      intensity = config.get("intensity") ?? "0級";
      if (Start == 0) {
        Start = 1;
        Data = jsonDecode(await Get(
            "https://raw.githubusercontent.com/ExpTechTW/TW-EEW/%E4%B8%BB%E8%A6%81%E7%9A%84-(main)/locations.json"));
        Data.forEach((key, value) {
          Citys.add(key);
        });
      }
      Data.forEach((key, value) {
        if (key == city) {
          Towns = [];
          Data[key].forEach((key, value) {
            Towns.add(key);
          });
        }
      });
      config.put("lat", Data[city][town][1]);
      config.put("long", Data[city][town][2]);
      config.put("site", Data[city][town][3]);
      if (!mounted) {
        return;
      }
      setState(() {});
    });
    return Scaffold(
      body: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                "強震即時警報",
                style: TextStyle(
                  fontSize: 35,
                ),
              ),
            ],
          ),
          Row(
            children: [
              DropdownButton(
                items: Citys.map((country) {
                  return DropdownMenuItem(
                    value: country,
                    child: Text(
                      country,
                      style: const TextStyle(color: Colors.black),
                    ),
                  );
                }).toList(),
                hint: const Text("載入中..."),
                onChanged: (selectValue) async {
                  await Hive.initFlutter();
                  await Hive.openBox('config');
                  var config = Hive.box('config');
                  config.put("city", selectValue);
                },
                value: (Citys.isEmpty) ? null : city,
                elevation: 10,
                style: const TextStyle(fontSize: 25),
                iconSize: 30,
              ),
              DropdownButton(
                items: Towns.map((country) {
                  return DropdownMenuItem(
                    value: country,
                    child: Text(
                      country,
                      style: const TextStyle(color: Colors.black),
                    ),
                  );
                }).toList(),
                hint: const Text("載入中..."),
                onChanged: (selectValue) async {
                  await Hive.initFlutter();
                  await Hive.openBox('config');
                  var config = Hive.box('config');
                  config.put("town", selectValue);
                },
                value: (Towns.isEmpty) ? null : town,
                elevation: 10,
                style: const TextStyle(fontSize: 25),
                iconSize: 30,
              ),
            ],
          ),
          Row(
            children: [
              DropdownButton(
                items: Intensity.map((country) {
                  return DropdownMenuItem(
                    value: country,
                    child: Text(
                      country,
                      style: const TextStyle(color: Colors.black),
                    ),
                  );
                }).toList(),
                hint: const Text("載入中..."),
                onChanged: (selectValue) async {
                  await Hive.initFlutter();
                  await Hive.openBox('config');
                  var config = Hive.box('config');
                  config.put("intensity", selectValue);
                },
                value: (intensity == "") ? null : intensity,
                elevation: 10,
                style: const TextStyle(fontSize: 25),
                iconSize: 30,
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                "接收參數",
                style: TextStyle(
                  fontSize: 35,
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "交通部中央氣象局 CWB",
                style: TextStyle(
                  fontSize: 25,
                ),
              ),
              Expanded(
                  child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CupertinoSwitch(
                      value: _CWB,
                      onChanged: (bool value) =>
                          {_CWB = value, _Switch(value, "CWB_EEW")})
                ],
              ))
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "日本氣象廳 JMA",
                style: TextStyle(
                  fontSize: 25,
                ),
              ),
              Expanded(
                  child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CupertinoSwitch(
                      value: _JMA,
                      onChanged: (bool value) =>
                          {_JMA = value, _Switch(value, "JMA_EEW")})
                ],
              ))
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "防災科研 NIED",
                style: TextStyle(
                  fontSize: 25,
                ),
              ),
              Expanded(
                  child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CupertinoSwitch(
                      value: _NIED,
                      onChanged: (bool value) =>
                          {_NIED = value, _Switch(value, "NIED_EEW")})
                ],
              ))
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "韓國氣象廳 KMA",
                style: TextStyle(
                  fontSize: 25,
                ),
              ),
              Expanded(
                  child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CupertinoSwitch(
                      value: _KMA,
                      onChanged: (bool value) =>
                          {_KMA = value, _Switch(value, "KMA_EEW")})
                ],
              ))
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "福建省地震局 FJDZJ",
                style: TextStyle(
                  fontSize: 25,
                ),
              ),
              Expanded(
                  child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CupertinoSwitch(
                      value: _FJDZJ,
                      onChanged: (bool value) =>
                          {_FJDZJ = value, _Switch(value, "FJDZJ_EEW")})
                ],
              ))
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "四川省地震局 SCDZJ",
                style: TextStyle(
                  fontSize: 25,
                ),
              ),
              Expanded(
                  child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CupertinoSwitch(
                      value: _SCDZJ,
                      onChanged: (bool value) =>
                          {_SCDZJ = value, _Switch(value, "SCDZJ_EEW")})
                ],
              ))
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "地震報告 Report",
                style: TextStyle(
                  fontSize: 25,
                ),
              ),
              Expanded(
                  child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CupertinoSwitch(
                      value: _Report,
                      onChanged: (bool value) =>
                          {_Report = value, _Switch(value, "Report")})
                ],
              ))
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "近即時震度 Palert",
                style: TextStyle(
                  fontSize: 25,
                ),
              ),
              Expanded(
                  child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CupertinoSwitch(
                      value: _Palert,
                      onChanged: (bool value) =>
                          {_Palert = value, _Switch(value, "Palert")})
                ],
              ))
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "海嘯警報 Tsunami",
                style: TextStyle(
                  fontSize: 25,
                ),
              ),
              Expanded(
                  child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CupertinoSwitch(
                      value: _Tsunami,
                      onChanged: (bool value) =>
                          {_Tsunami = value, _Switch(value, "Tsunami")})
                ],
              ))
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "計算場址效應",
                style: TextStyle(
                  fontSize: 25,
                ),
              ),
              Expanded(
                  child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CupertinoSwitch(
                      value: _site,
                      onChanged: (bool value) =>
                          {_site = value, _Switch(value, "site_use")})
                ],
              ))
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "自適應波速",
                style: TextStyle(
                  fontSize: 25,
                ),
              ),
              Expanded(
                  child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CupertinoSwitch(
                      value: _wave,
                      onChanged: (bool value) =>
                          {_wave = value, _Switch(value, "wave")})
                ],
              ))
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                "音效",
                style: TextStyle(
                  fontSize: 35,
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "自動調整音量",
                style: TextStyle(
                  fontSize: 25,
                ),
              ),
              Expanded(
                  child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CupertinoSwitch(
                      value: _setVolume,
                      onChanged: (bool value) =>
                          {_setVolume = value, _Switch(value, "setVolume")})
                ],
              ))
            ],
          ),
        ],
      ),
    );
  }
}
