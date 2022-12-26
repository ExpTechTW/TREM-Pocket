import 'dart:async';

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

