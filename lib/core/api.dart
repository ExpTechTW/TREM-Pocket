import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'http_get.dart';

Future<Map<dynamic, dynamic>> updateChecker() async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  String version = packageInfo.version;
  bool update = false;
  String lastVersion = "";
  String note = "";
  bool beta = false;
  if (packageInfo.version.split(".")[3].toString() != "0") beta = true;
  var data = await get(
      "https://exptech.com.tw/api/v1/file?path=/trem_pocket/info.json&cache=false");
  for (var i = 0; i < data.length; i++) {
    String _version = data[i]["version"];
    if (_version == version) break;
    if (beta) {
      if (_version.split(".")[3].toString() != "0") {
        update = true;
      }
    } else {
      if (_version.split(".")[3].toString() == "0") {
        update = true;
      }
    }
    if (update) {
      lastVersion = _version;
      note = data[i]["note"];
      break;
    }
  }
  return {"update": update, "lastVersion": lastVersion, "note": note};
}

Future<Map<String, dynamic>> parseJsonFromAssets(String assetsPath) async {
  var file=await rootBundle.loadString(assetsPath);
  return jsonDecode(file);
}

Earthquake(json) async{
  double point = sqrt(pow(
          (22.9672860 + double.parse(json["NorthLatitude"].toString()) * -1)
                  .abs() *
              111,
          2) +
      pow(
          (120.2940045 + double.parse(json["EastLongitude"].toString()) * -1)
                  .abs() *
              101,
          2));
  double distance =
      sqrt(pow(int.parse(json["Depth"].toString()), 2) + pow(point, 2));
  var loc=await parseJsonFromAssets("assets/resource/location.json");
  print(loc);
  var ans = PGAcount(double.parse(json["Scale"].toString()), distance, 1);
  return [ans[0], ans[1], distance];
}

PGAcount(Scale, distance, Si) {
  double PGA = double.parse(
      (1.657 * pow(e, (1.533 * Scale)) * pow(distance, -1.607) * Si)
          .toStringAsFixed(3));
  return [
    PGA >= 800
        ? "7"
        : 800 >= PGA && 440 < PGA
            ? "6+"
            : 440 >= PGA && 250 < PGA
                ? "6-"
                : 250 >= PGA && 140 < PGA
                    ? "5+"
                    : 140 >= PGA && 80 < PGA
                        ? "5-"
                        : 80 >= PGA && 25 < PGA
                            ? "4"
                            : 25 >= PGA && 8 < PGA
                                ? "3"
                                : 8 >= PGA && 2.5 < PGA
                                    ? "2"
                                    : 2.5 >= PGA && 0.8 < PGA
                                        ? "1"
                                        : "0",
    PGA
  ];
}
