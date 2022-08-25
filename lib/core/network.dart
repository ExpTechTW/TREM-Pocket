import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:loggy/loggy.dart';

Future<Map<String, dynamic>> NetWork(String json) async {
  try {
    Map<String, dynamic> Json = jsonDecode(json);
    if (Json["Function"] == null) {
      Json["Function"] = "TREM-Pocket";
    }
    Log(LogLevel.debug, jsonEncode(Json));
    var response = await http
        .post(Uri.parse("https://exptech.com.tw/post"),
            headers: {"content-type": "application/json"},
            body: utf8.encode(jsonEncode(Json)))
        .timeout(const Duration(seconds: 2));
    String reply = response.body;
    var Data = jsonDecode(reply);
    if (Data["state"] == "Success") {
      Log(LogLevel.debug, reply);
    } else if (Data["state"] == "Warn") {
      Log(LogLevel.warning, reply);
    } else {
      Log(LogLevel.error, reply);
    }
    return Data;
  } on SocketException catch (e) {
    String msg = e.message;
    Log(LogLevel.error, msg);
    return jsonDecode(msg);
  }
}

Future Get(String url) async {
  try {
    var response =
        await http.get(Uri.parse(url)).timeout(const Duration(seconds: 2));
    return response.body;
  } on SocketException catch (e) {
    String msg = e.message;
    Log(LogLevel.error, msg);
    return msg;
  }
}

class Log with NetworkLoggy {
  Log(level, msg) {
    switch (level) {
      case LogLevel.error:
        loggy.error(msg);
        break;
      case LogLevel.warning:
        loggy.warning(msg);
        break;
      case LogLevel.info:
        loggy.info(msg);
        break;
      case LogLevel.debug:
        loggy.debug(msg);
        break;
    }
  }
}
