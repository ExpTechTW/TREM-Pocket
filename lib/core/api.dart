import 'package:audioplayers/audioplayers.dart';

final player = AudioPlayer();
int time = 0;
int NTP = 0;
int Now = 0;
DateTime NOW = DateTime.now();

int Unix() {
  return NOW.millisecondsSinceEpoch;
}
