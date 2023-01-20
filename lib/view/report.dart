import 'package:flutter/material.dart';

bool finish = false;

class ReportPage extends StatefulWidget {
  const ReportPage({Key? key}) : super(key: key);

  @override
  _ReportPage createState() => _ReportPage();
}

class _ReportPage extends State<ReportPage> {
  List<Widget> station = [];

  @override
  void dispose() {
    super.dispose();
    finish = false;
  }

  @override
  Widget build(BuildContext context) {
    dynamic data = ModalRoute.of(context)?.settings.arguments;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (finish) return;
      finish = true;
      if (data["report"] != null) {
        for (var i = 0; i < data["report"]["intensity"].length; i++) {
          var _station = data["report"]["intensity"][i];
          for (var I = 0; I < _station["station"].length; I++) {
            var __station = _station["station"][I];
            if (__station == null) continue;
            station.add(
              const SizedBox(height: 20),
            );
            station.add(
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
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${__station["stationIntensity"]["\$t"]}${__station["stationIntensity"]["unit"]} | ${_station["areaDesc"].toString().replaceAll("地區", "")} ${__station["stationName"]} | ${__station["stationCode"]}",
                                    style: const TextStyle(
                                        fontSize: 25, color: Colors.white),
                                  ),
                                  const Divider(
                                    height: 10,
                                    thickness: 3,
                                    indent: 5,
                                    endIndent: 5,
                                    color: Colors.grey,
                                  ),
                                  Text(
                                    "測站位置:  ${__station["stationLat"]["\$t"]}°N ${__station["stationLon"]["\$t"]}°E",
                                    style: const TextStyle(
                                        fontSize: 20, color: Colors.white),
                                  ),
                                  Text(
                                    "震央距:  ${__station["distance"]["\$t"]}",
                                    style: const TextStyle(
                                        fontSize: 20, color: Colors.white),
                                  ),
                                  Text(
                                    "反方位角:  ${__station["azimuth"]["\$t"]}°",
                                    style: const TextStyle(
                                        fontSize: 20, color: Colors.white),
                                  ),
                                  Text(
                                    (__station["pga"] != null)
                                        ? "加速度(gal):  東西 ${__station["pga"]["ewComponent"]} | 南北 ${__station["pga"]["nsComponent"]} | 垂直 ${__station["pga"]["vComponent"]}"
                                        : "",
                                    style: const TextStyle(
                                        fontSize: 20, color: Colors.white),
                                  ),
                                  Image.network(
                                    __station["waveImageURI"] ?? "",
                                    errorBuilder: (BuildContext context,
                                        Object exception,
                                        StackTrace? stackTrace) {
                                      return const Text('');
                                    },
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
            );
          }
        }
      }
      if (!mounted) {
        return;
      }
      setState(() {});
    });
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
                    onTap: () {},
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
                                    "地震報告",
                                    style: TextStyle(
                                        fontSize: 25, color: Colors.white),
                                  ),
                                  const Divider(
                                    height: 10,
                                    thickness: 3,
                                    indent: 5,
                                    endIndent: 5,
                                    color: Colors.grey,
                                  ),
                                  Text(
                                    (data["earthquakeNo"] % 1000 == 0)
                                        ? "小區域有感地震"
                                        : data["earthquakeNo"].toString(),
                                    style: const TextStyle(
                                        fontSize: 25, color: Colors.white),
                                  ),
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on_outlined,
                                          color: Colors.white),
                                      Expanded(
                                        child: Text(
                                          data["location"].toString(),
                                          style: const TextStyle(
                                              fontSize: 15,
                                              color: Colors.white),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    "發震時間:  ${data["originTime"]}",
                                    style: const TextStyle(
                                        fontSize: 20, color: Colors.white),
                                  ),
                                  Text(
                                    "震央位置:  ${data["epicenterLat"]}°N ${data["epicenterLon"]}°E",
                                    style: const TextStyle(
                                        fontSize: 20, color: Colors.white),
                                  ),
                                  Text(
                                    "最大震度:  ${data["info"]["intensity"]} ${data["data"][0]["areaName"]} ${data["data"][0]["eqStation"][0]["stationName"]}",
                                    style: const TextStyle(
                                        fontSize: 20, color: Colors.white),
                                  ),
                                  Text(
                                    "芮氏規模:  ML ${data["magnitudeValue"]}",
                                    style: const TextStyle(
                                        fontSize: 20, color: Colors.white),
                                  ),
                                  Text(
                                    "震源深度:  ${data["depth"]} 公里",
                                    style: const TextStyle(
                                        fontSize: 20, color: Colors.white),
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
              const SizedBox(height: 10),
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
                        child: Image.network(
                            "https://www.cwb.gov.tw/Data/earthquake/img/${data["identifier"].toString().replaceAll("CWB-", "")}.png"),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Visibility(
                visible: data["report"] != null,
                child: Material(
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
                          child: Image.network((data["report"] == null)
                              ? ""
                              : data["report"]["link"]["shake_image"]),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Column(children: station.toList())
            ],
          ),
        ),
      ),
    );
  }
}
