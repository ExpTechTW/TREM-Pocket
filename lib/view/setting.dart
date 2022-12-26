import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:select_dialog/select_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/api.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({Key? key}) : super(key: key);

  @override
  _SettingPage createState() => _SettingPage();
}

class _SettingPage extends State<SettingPage> {
  String token = "";
  bool beta = false;
  String version = "";
  var prefs;

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      prefs = await SharedPreferences.getInstance();
      token = (await FirebaseMessaging.instance.getToken())!;
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      if (packageInfo.version.split(".")[3].toString() != "0") beta = true;
      version = packageInfo.version;
      setState(() {});
    });
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              height: 20,
              width: double.infinity,
            ),
            Material(
              color: Colors.black,
              child: Ink(
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: const BorderRadius.all(Radius.circular(15)),
                  border: Border.all(width: 3, color: Colors.cyanAccent),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    alignment: const Alignment(0, 0),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "接收參數",
                            style: TextStyle(color: Colors.white, fontSize: 30),
                          ),
                          const Divider(
                            height: 10,
                            thickness: 3,
                            indent: 5,
                            endIndent: 5,
                            color: Colors.grey,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "中央氣象局",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 25),
                              ),
                              Row(
                                children: [
                                  const Expanded(
                                    child: Text(
                                      "接收 中央氣象局(CWB) 強震即時警報",
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 20),
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      FlutterSwitch(
                                        width: 50,
                                        height: 30,
                                        toggleSize: 20,
                                        value: prefs?.getBool('accept_eew') ??
                                            false,
                                        borderRadius: 30,
                                        onToggle: (bool value) async {
                                          await prefs.setBool(
                                              'accept_eew', value);
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "近即時震度",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 25),
                              ),
                              Row(
                                children: [
                                  const Expanded(
                                    child: Text(
                                      "接收 P-Alert 近即時震度",
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 20),
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      FlutterSwitch(
                                        width: 50,
                                        height: 30,
                                        toggleSize: 20,
                                        value:
                                            prefs?.getBool('accept_palert') ??
                                                false,
                                        borderRadius: 30,
                                        onToggle: (bool value) async {
                                          await prefs.setBool(
                                              'accept_palert', value);
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "地震報告",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 25),
                              ),
                              Row(
                                children: [
                                  const Expanded(
                                    child: Text(
                                      "接收 中央氣象局(CWB) 地震報告",
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 20),
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      FlutterSwitch(
                                        width: 50,
                                        height: 30,
                                        toggleSize: 20,
                                        value:
                                            prefs?.getBool('accept_report') ??
                                                false,
                                        borderRadius: 30,
                                        onToggle: (bool value) async {
                                          await prefs.setBool(
                                              'accept_report', value);
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "地震檢知",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 25),
                              ),
                              Row(
                                children: [
                                  const Expanded(
                                    child: Text(
                                      "接收 TREM 地震檢知",
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 20),
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      FlutterSwitch(
                                        width: 50,
                                        height: 30,
                                        toggleSize: 20,
                                        value: prefs?.getBool('accept_trem') ??
                                            false,
                                        borderRadius: 30,
                                        onToggle: (bool value) async {
                                          await prefs.setBool(
                                              'accept_trem', value);
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          GestureDetector(
                            onTap: () async {
                              var loc = await parseJsonFromAssets(
                                  "assets/resource/location.json");
                              List<String> loc_list = [];
                              List<String> city_key = loc.keys.toList();
                              for (var i = 0; i < city_key.length; i++) {
                                List<String> town_key =
                                    loc[city_key[i]].keys.toList();
                                for (var I = 0; I < town_key.length; I++) {
                                  loc_list.add("${city_key[i]} ${town_key[I]}");
                                }
                              }
                              SelectDialog.showModal<String>(
                                context,
                                label: "選擇所在地",
                                selectedValue:
                                    prefs?.getString("location") ?? "臺南市 歸仁區",
                                items: loc_list,
                                onChange: (String selected) async {
                                  await prefs.setString("location", selected);
                                },
                              );
                            },
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "所在地",
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 25),
                                      ),
                                      Row(
                                        children: const [
                                          Text(
                                            "計算所在地 預估震度",
                                            style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 20),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    const Icon(Icons.my_location,
                                        color: Colors.white),
                                    Text(
                                      prefs?.getString("location") ?? "臺南市 歸仁區",
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 20),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
