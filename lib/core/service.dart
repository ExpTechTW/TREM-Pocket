import 'dart:convert';

import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/status.dart' as status;

service() async {
  var channel = IOWebSocketChannel.connect(Uri.parse('wss://exptech.mywire.org:1015'));
  channel.sink.add(json.encode({
    "APIkey": "https://github.com/ExpTechTW"
  }));
  channel.stream.listen((message) {
    print(message);
    FlutterBackgroundService().invoke("notify",{
      "body":"1"
    });
  });
}