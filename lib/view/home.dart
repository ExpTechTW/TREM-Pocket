import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as HTTP;
import 'package:trem_pocket/core/global.dart';
import 'package:trem_pocket/core/http_get.dart';

import '../core/api.dart';
import '../core/ntp.dart';

var clock;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePage createState() => _HomePage();
}

class _HomePage extends State<HomePage> {
  String url = 'https://exptech.com.tw/api/v1/trem/rts-image';
  late Widget _pic;
  bool update = false;
  var data = {};
  var eew = {};
  String now = "";
  List eew_info = [];
  bool EEW = false;

  @override
  void dispose() {
    if (clock != null) {
      clock.cancel();
      clock = null;
    }
    update = false;
    super.dispose();
  }

  @override
  void initState() {
    _pic = Image.network(url, errorBuilder:
        (BuildContext context, Object exception, StackTrace? stackTrace) {
      return const Text('');
    });
    super.initState();
  }

  _updateImgWidget() async {
    try {
      Uint8List bytes = await HTTP.readBytes(Uri.parse(url));
      _pic = Image.memory(bytes, gaplessPlayback: true);
    } catch (e) {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      clock ??= Timer.periodic(const Duration(seconds: 1), (timer) async {
        if (update) return;
        update = true;
        await _updateImgWidget();
        update = false;
        var ans = await get("https://exptech.com.tw/api/v1/trem/status");
        if (ans != false) {
          data = ans;
          if (data["eew"] != "" && data["eew"] != eew["ID"] + eew["Version"]) {
            EEW = true;
            eew = eew_data;
            if (eew["TimeStamp"] == null) {
              var eewAns = await get(
                  "https://exptech.com.tw/api/v1/earthquake/eew?type=earthquake");
              if (eewAns != false) eew = eewAns;
            }
            if (eew["TimeStamp"] != null) {
              eew_info = await Earthquake(eew);
            }
          } else {
            EEW = false;
          }
        }
        now = DateTime.fromMillisecondsSinceEpoch(await Now(false))
            .toString()
            .substring(0, 19)
            .replaceAll("-", "/");
        if (!mounted) return;
        setState(() {});
      });
    });
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
                  onTap: () {},
                  child: Container(
                    alignment: const Alignment(0, 0),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: _pic,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Material(
              color: Colors.black,
              child: Ink(
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: const BorderRadius.all(Radius.circular(15)),
                  border: Border.all(width: 3, color: Colors.indigo),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(4),
                  onTap: () {},
                  child: Container(
                    alignment: const Alignment(0, 0),
                    child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(width: double.infinity),
                            Text(
                              "現在時間 | $now",
                              style: const TextStyle(
                                  fontSize: 20, color: Colors.white),
                            ),
                          ],
                        )),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Material(
              color: Colors.black,
              child: Ink(
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: const BorderRadius.all(Radius.circular(15)),
                  border: Border.all(width: 3, color: Colors.green),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(4),
                  onTap: () {},
                  child: Container(
                    alignment: const Alignment(0, 0),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(width: double.infinity),
                          Text(
                            "計測最大加速度 | ${data["max_pga"] ?? "?"} gal",
                            style: const TextStyle(
                                fontSize: 20, color: Colors.white),
                          ),
                          Text(
                            "計測最大震度 | ${int_to_intensity(data["max_intensity"] ?? 0)}",
                            style: const TextStyle(
                                fontSize: 20, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Visibility(
              visible: EEW,
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Material(
                    color: Colors.black,
                    child: Ink(
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(15)),
                        border: Border.all(width: 3, color: Colors.red),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(4),
                        onTap: () {},
                        child: Container(
                          alignment: const Alignment(0, 0),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              children: [
                                const Text(
                                  "所在地預估震度",
                                  style: TextStyle(
                                      fontSize: 25, color: Colors.white),
                                ),
                                Text(
                                  (EEW) ? int_to_intensity(eew_info[0]) : "NA",
                                  style: const TextStyle(
                                      fontSize: 35, color: Colors.white),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Material(
                    color: Colors.black,
                    child: Ink(
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(15)),
                        border: Border.all(width: 3, color: Colors.purple),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(4),
                        onTap: () {},
                        child: Container(
                          alignment: const Alignment(0, 0),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              children: [
                                const Text(
                                  "抵達倒數",
                                  style: TextStyle(
                                      fontSize: 25, color: Colors.white),
                                ),
                                Text(
                                  (EEW)
                                      ? "P ${(eew_info[2] > 0) ? "${eew_info[2]}秒" : "抵達"} | S ${(eew_info[3] > 0) ? "${eew_info[3]}秒" : "抵達"}"
                                      : "NA",
                                  style: const TextStyle(
                                      fontSize: 35, color: Colors.white),
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
          ],
        ),
      ),
    );
  }
}
