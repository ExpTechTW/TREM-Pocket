import 'package:audioplayers/audioplayers.dart';

final player = AudioPlayer();
int time = 0;
int NTP = 0;
int Now = 0;
double Lat = 25.0421407;
double Long = 121.5198716;
DateTime NOW = DateTime.now();
String FirebaseToken = "";
Map config = {
  "earthquake.siteEffect": {"value": true}
};

int Unix() {
  return NOW.millisecondsSinceEpoch;
}
