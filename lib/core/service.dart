import 'dart:convert';

import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:web_socket_channel/io.dart';

ExpTech() async {
  var channel =
      IOWebSocketChannel.connect(Uri.parse('wss://exptech.com.tw/websocket'));
  await Hive.initFlutter();
  await Hive.openBox('config');
  var config = Hive.box('config');
  channel.sink.add(json.encode({
    "APIkey": "https://github.com/ExpTechTW",
    "Function": "earthquakeService",
    "Type": "subscription-v1",
    "FormatVersion": 2,
    "UUID": config.get('UUID')
  }));

  channel.stream.listen((message) async {
    FlutterBackgroundService().invoke("data", json.decode(message));
  });
}
