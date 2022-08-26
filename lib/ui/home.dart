import 'package:flutter/material.dart';
import 'package:trem/core/network.dart';

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

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePage createState() => _HomePage();
}

String _Intensity(int i) {
  if (i == 5) return "5-";
  if (i == 6) return "5+";
  if (i == 7) return "6-";
  if (i == 8) return "6+";
  return i.toString();
}

class _HomePage extends State<HomePage> {
  late List<Widget> _children = <Widget>[];

  @override
  void dispose() {
    start = 0;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (start == 0) {
        start = 1;
        var Data = await NetWork(
            '{"Function": "data","Type": "earthquake","Value":"50"}');
        List data = Data["response"] as List;
        _children = <Widget>[];
        for (var i = 0; i < data.length; i++) {
          var loc = data[i]["location"]
              .toString()
              .substring(data[i]["location"].toString().indexOf("(") + 1,
                  data[i]["location"].toString().indexOf(")"))
              .replaceAll("位於", "");
          _children.add(
            GestureDetector(
              onTap: () {},
              child: Container(
                color: Color(color[data[i]["data"][0]["areaIntensity"] - 1]),
                child: Column(
                  children: [
                    const SizedBox(
                      width: double.infinity,
                    ),
                    Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(15),
                          child: Text(
                            _Intensity(data[i]["data"][0]["areaIntensity"]),
                            style: const TextStyle(
                                fontSize: 40, color: Colors.white),
                          ),
                        ),
                        Expanded(
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              loc,
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
                            "M ${double.parse(data[i]["magnitudeValue"].toString())}",
                            style: const TextStyle(
                                fontSize: 40, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
          setState(() {});
        }
      }
    });
    return Scaffold(
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
          await Future.delayed(const Duration(milliseconds: 100));
          while (true) {
            if (start == 1) {
              break;
            }
            await Future.delayed(const Duration(milliseconds: 100));
          }
          return;
        },
      ),
    );
  }
}
