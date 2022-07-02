import 'dart:math';

import 'package:trem/core/api.dart';

Earthquake(json, S) {
  print(json["NorthLatitude"]);
  double point = sqrt(pow(
          (Lat + double.parse(json["NorthLatitude"].toString()) * -1).abs() * 111, 2) +
      pow((Long + double.parse(json["EastLongitude"].toString()) * -1).abs() * 101, 2));
  double distance = sqrt(pow(int.parse(json["Depth"].toString()), 2) + pow(point, 2));
  return PGAcount(double.parse(json["Scale"].toString()), distance, S);
}

PGAcount(Scale, distance, Si) {
  double S = Si ?? 1.0;
  if (!config["earthquake.siteEffect"]["value"]) S = 1;
  double PGA = double.parse(
      (1.657 * pow(e, (1.533 * Scale)) * pow(distance, -1.607) * S)
          .toStringAsFixed(3));
  print(PGA);
  return PGA >= 800
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
                                      : "0";
}
