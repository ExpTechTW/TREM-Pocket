import 'dart:math';

import 'package:hive_flutter/adapters.dart';

Earthquake(json) async {
  await Hive.initFlutter();
  await Hive.openBox('config');
  var config = Hive.box('config');
  double point = sqrt(pow(
          ((config.get("lat") ?? 22.9672860) +
                      double.parse(json["NorthLatitude"].toString()) * -1)
                  .abs() *
              111,
          2) +
      pow(
          ((config.get("long") ?? 120.2940045) +
                      double.parse(json["EastLongitude"].toString()) * -1)
                  .abs() *
              101,
          2));
  double distance =
      sqrt(pow(int.parse(json["Depth"].toString()), 2) + pow(point, 2));
  var ans = PGAcount(double.parse(json["Scale"].toString()), distance,
      (!config.get("site_use")) ? 1 : (config.get("site") ?? 1.751));
  return [ans[0], ans[1], distance];
}

PGAcount(Scale, distance, Si) {
  //if (!config["earthquake.siteEffect"]["value"]) Si = 1;
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
