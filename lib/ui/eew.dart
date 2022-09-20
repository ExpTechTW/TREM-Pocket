import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../core/network.dart';

double TN = 0;
int Start = 0;
List<CircleMarker> CircleD = [];

class EEWPage extends StatefulWidget {
  const EEWPage({Key? key}) : super(key: key);

  @override
  _EEWPage createState() => _EEWPage();
}

class _EEWPage extends State<EEWPage> {
  TIME() async {
    var Now = DateTime.now().millisecondsSinceEpoch;
    var data = jsonDecode(await Get("https://exptech.com.tw/get?Function=NTP"));
    TN = data["Full"] + (DateTime.now().millisecondsSinceEpoch - Now) / 2;
  }

  @override
  void initState() {
    Start = 0;
    setState(() {});
    super.initState();
  }

  @override
  void dispose() {
    Start = 1;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      var timerT;
      timerT ??= Timer.periodic(const Duration(milliseconds: 1000), (timer) async {
              print(1);
              if (Start == 1) timerT.cancel();
              var data =
              jsonDecode(await Get("https://exptech.com.tw/get?Function=EEWT"));
              await TIME();
              if (TN - data["TimeStamp"] < 240000) {
                CircleD = [];
                CircleD.add(
                  CircleMarker(
                      point: LatLng(
                          double.parse(data["NorthLatitude"].toString()),
                          double.parse(data["EastLongitude"].toString())),
                      color: Colors.blue.withOpacity(0),
                      borderStrokeWidth: 1,
                      radius: ((TN - data["Time"]) / 1000) * 6.5),
                );
                CircleD.add(
                  CircleMarker(
                      point: LatLng(
                          double.parse(data["NorthLatitude"].toString()),
                          double.parse(data["EastLongitude"].toString())),
                      color: Colors.red.withOpacity(0.1),
                      borderStrokeWidth: 1,
                      radius: ((TN - data["Time"]) / 1000) * 3.5),
                );
                setState(() {});
              } else if (CircleD.isNotEmpty) {
                CircleD = [];
                setState(() {});
              }
            });
    });
    return FlutterMap(
      options: MapOptions(
        center: LatLng(23.608428, 120.799168),
        zoom: 7.5,
      ),
      layers: [
        TileLayerOptions(
          urlTemplate:
              "https://api.mapbox.com/styles/v1/mapbox/dark-v10/tiles/{z}/{x}/{y}?access_token=pk.eyJ1IjoibWFwYm94IiwiYSI6ImNpejY4NXVycTA2emYycXBndHRqcmZ3N3gifQ.rJcFIG214AriISLbB6B5aw",
        ),
        CircleLayerOptions(
          circles: CircleD,
        ),
      ],
    );
  }
}
