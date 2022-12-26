import 'package:clipboard/clipboard.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:trem_pocket/view/setting.dart';
import 'package:trem_pocket/view/version.dart';
import 'package:url_launcher/url_launcher.dart';

class MePage extends StatefulWidget {
  const MePage({Key? key}) : super(key: key);

  @override
  _MePage createState() => _MePage();
}

class _MePage extends State<MePage> {
  String token = "";
  bool beta = false;
  String version = "";

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
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
                  border: Border.all(
                      width: 3, color: (beta) ? Colors.red : Colors.blue),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(4),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const VersionPage(),
                      ),
                    );
                  },
                  child: Container(
                    alignment: const Alignment(0, 0),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "TREM Pocket",
                                style: TextStyle(
                                    fontSize: 25, color: Colors.white),
                              ),
                              Text(
                                version,
                                style: const TextStyle(
                                    fontSize: 20, color: Colors.white),
                              ),
                              Text(
                                (beta) ? "開發版" : "穩定版",
                                style: const TextStyle(
                                    fontSize: 20, color: Colors.white),
                              ),
                            ],
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Image.asset(
                                  "assets/images/trem.png",
                                  width: 70,
                                  height: 70,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Material(
              color: Colors.black,
              child: Ink(
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: const BorderRadius.all(Radius.circular(15)),
                  border: Border.all(width: 3, color: Colors.blue),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(4),
                  onTap: () {
                    FlutterClipboard.copy(token);
                  },
                  child: Container(
                    alignment: const Alignment(0, 0),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Device ID",
                                  style: TextStyle(
                                      fontSize: 25, color: Colors.white),
                                ),
                                Text(
                                  token,
                                  softWrap: true,
                                  style: const TextStyle(
                                      fontSize: 20, color: Colors.white),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  textAlign: TextAlign.left,
                                ),
                                const Text(
                                  "(點擊複製)",
                                  style: TextStyle(
                                      fontSize: 15, color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Material(
                    color: Colors.black,
                    child: Ink(
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(15)),
                        border: Border.all(width: 3, color: Colors.grey),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(4),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SettingPage(),
                            ),
                          );
                        },
                        child: Container(
                          alignment: const Alignment(0, 0),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              children: const [
                                Icon(
                                  Icons.settings,
                                  color: Colors.grey,
                                  size: 100,
                                ),
                                Text(
                                  "設置",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 30),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Material(
                    color: Colors.black,
                    child: Ink(
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(15)),
                        border:
                            Border.all(width: 3, color: Colors.indigo.shade900),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(4),
                        onTap: () async {
                          await launch("https://discord.gg/5dbHqV8ees");
                        },
                        child: Container(
                          alignment: const Alignment(0, 0),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              children: const [
                                Icon(
                                  Icons.discord_outlined,
                                  color: Colors.deepPurpleAccent,
                                  size: 110,
                                ),
                                Text(
                                  "Discord",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 30),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
