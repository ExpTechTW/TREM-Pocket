import 'package:flutter/material.dart';
import 'package:trem_pocket/core/api.dart';
import 'package:trem_pocket/core/http_get.dart';
import 'package:trem_pocket/view/report.dart';

int start = 0;
List<int> color = [
  0xff808080,
  0xff0165CC,
  0xff01BB02,
  0xffEBC000,
  0xffFF8400,
  0xffE06300,
  0xffFF0000,
  0xffB50000,
  0xff68009E
];
var Data;

class ReportListPage extends StatefulWidget {
  const ReportListPage({Key? key}) : super(key: key);

  @override
  _ReportListPage createState() => _ReportListPage();
}

Map<String, dynamic> info(dynamic data) {
  String _i;
  int _color = 0;
  if (data["data"].length == 0) {
    _i = "--";
    _color = color[0];
  } else {
    int _intensity = data["data"][0]["areaIntensity"];
    _i = int_to_intensity(_intensity);
    _color = color[_intensity - 1];
  }
  return {
    "color": _color,
    "loc": data["location"]
        .toString()
        .substring(data["location"].toString().indexOf("(") + 1,
            data["location"].toString().indexOf(")"))
        .replaceAll("位於", ""),
    "magnitude": double.parse(data["magnitudeValue"].toString()),
    "intensity": _i
  };
}

class _ReportListPage extends State<ReportListPage> {
  late List<Widget> _children = <Widget>[];

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (start == 0) {
        start = 1;
        Data = await get(
            "https://exptech.com.tw/api/v1/earthquake/reports?limit=50");
      }
      List data = Data as List;
      _children = <Widget>[];
      for (var i = 0; i < data.length; i++) {
        var _info = info(data[i]);
        data[i]["info"] = _info;
        _children.add(
          GestureDetector(
            onTap: () async {
              if (_info["intensity"] != "--") {
                if (data[i]["earthquakeNo"] % 1000 != 0) {
                  var ans = await get(
                      "https://exptech.com.tw/api/v1/earthquake/reports/${data[i]["earthquakeNo"]}");
                  if (ans != false) data[i]["report"] = ans;
                }
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ReportPage(),
                      settings: RouteSettings(
                        arguments: data[i],
                      ),
                    ));
              }
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 3, 12, 3),
              child: Container(
                decoration: BoxDecoration(
                  color: Color(_info["color"]),
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                ),
                child: Column(
                  children: [
                    const SizedBox(
                      width: double.infinity,
                    ),
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(15),
                          child: Text(
                            _info["intensity"],
                            style: const TextStyle(
                                fontSize: 45, color: Colors.white),
                          ),
                        ),
                        Expanded(
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${(data[i]["earthquakeNo"] % 1000 != 0) ? "✩ " : ""}${_info["loc"]}",
                              style: const TextStyle(
                                  fontSize: 22, color: Colors.white),
                            ),
                            Text(
                              data[i]["originTime"],
                              style: const TextStyle(
                                  fontSize: 20, color: Colors.white),
                            )
                          ],
                        )),
                        Padding(
                          padding: const EdgeInsets.all(15),
                          child: Text(
                            "M ${_info["magnitude"]}",
                            style: const TextStyle(
                                fontSize: 30, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
        if (!mounted) {
          return;
        }
        setState(() {});
      }
    });
    return Scaffold(
      backgroundColor: Colors.black,
      body: RefreshIndicator(
        child: ListView(
          physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics()),
          children: _children.toList(),
        ),
        onRefresh: () async {
          start = 0;
          _children = <Widget>[];
          setState(() {});
          while (true) {
            if (start == 1) {
              break;
            }
            await Future.delayed(const Duration(milliseconds: 10));
          }
          return;
        },
      ),
    );
  }
}
