import 'package:flutter/material.dart';
import 'package:trem_pocket/core/http_get.dart';

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
    _i = "?";
    _color = color[0];
  } else {
    int _intensity = data["data"][0]["areaIntensity"];
    _i = _intensity.toString();
    _color = color[_intensity - 1];
  }
  if (_i == "5") _i = "5-";
  if (_i == "6") _i = "5+";
  if (_i == "7") _i = "6-";
  if (_i == "8") _i = "6+";
  if (_i == "9") _i = "7";
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
        _children.add(
          GestureDetector(
            onTap: () {},
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
                                fontSize: 40, color: Colors.white),
                          ),
                        ),
                        Expanded(
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _info["loc"],
                              style: const TextStyle(
                                  fontSize: 25, color: Colors.white),
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
                                fontSize: 35, color: Colors.white),
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
