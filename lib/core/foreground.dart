import 'dart:async';
import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:perfect_volume_control/perfect_volume_control.dart';

import 'audio.dart';
import 'earthquake.dart';
import 'network.dart';

double TN = 0;

List<String> AudioList = [];
List<String> TimeStamp = [];
final player = AudioPlayer();
bool Lock = false;

PlayAudio(String src) async {
  player.setPlaybackRate(1.2);
  AudioList.add(src);
  play() async {
    Lock = true;

    await player.play(BytesSource(await Audio(AudioList.first)));
    AudioList.removeAt(0);
  }

  Timer.periodic(const Duration(microseconds: 100), (timer) async {
    if (Lock) return;
    if (AudioList.isNotEmpty) {
      play();
    }
  });
  player.onPlayerComplete.listen((event) {
    Lock = false;
  });
}

void onStart(ServiceInstance service) async {
  if (service is AndroidServiceInstance) {
    service.on('start').listen((event) {
      service.setAsForegroundService();
    });
  }

  service.on('stop').listen((event) {
    service.stopSelf();
  });

  if (service is AndroidServiceInstance) {
    service.setForegroundNotificationInfo(
      title: "TREM Pocket",
      content: "執行中 | 默默守護你的安全",
    );
  }

  TIME() async {
    var Now = DateTime.now().millisecondsSinceEpoch;
    var data = jsonDecode(await Get("https://exptech.com.tw/get?Function=NTP"));
    TN = data["Full"] + (DateTime.now().millisecondsSinceEpoch - Now) / 2;
  }

  int Intensity(i) {
    if (i == "5-" || i == "5弱") {
      return 5;
    } else if (i == "5+" || i == "5強") {
      return 6;
    } else if (i == "6-" || i == "6弱") {
      return 7;
    } else if (i == "6+" || i == "6強") {
      return 8;
    } else {
      return int.parse(i.toString().replaceAll("級", ""));
    }
  }

  service.on('data').listen((event) async {
    var data = event;
    await Hive.initFlutter();
    await Hive.openBox('config');
    var config = Hive.box('config');
    var val;
    await TIME();
    var Data = jsonDecode(data!["Data"]);
    if (TimeStamp.contains(Data["TimeStamp"])) return;
    TimeStamp.add(Data["TimeStamp"].toString());
    if (TN - int.parse(Data["TimeStamp"].toString()) > 240000) return;
    if (config.get('setVolume')) {
      PerfectVolumeControl.hideUI = true;
      val = await PerfectVolumeControl.volume;
      await PerfectVolumeControl.setVolume(1);
    }
    if (Data["Function"] == "earthquake" && !config.get('CWB_EEW')) return;
    if (Data["Function"] == "JMA_earthquake" && !config.get('JMA_EEW')) {
      return;
    }
    if (Data["Function"] == "KMA_earthquake" && !config.get('KMA_EEW')) {
      return;
    }
    if (Data["Function"] == "ICL_earthquake" && !config.get('ICL_EEW')) {
      return;
    }
    if (Data["Function"] == "FJDZJ_earthquake" && !config.get('FJDZJ_EEW')) {
      return;
    }
    if (Data["Function"] == "palert" && !config.get('Palert')) return;
    if (Data["Function"] == "report" && !config.get('Report')) return;
    if (Data["Function"] == "NIED_earthquake" && !config.get('NIED_EEW')) {
      return;
    }
    if (Data["Function"] == "TSUNAMI" && !config.get('Tsunami')) return;
    if (Data["Function"].toString().contains("earthquake")) {
      var T = Timer.periodic(const Duration(milliseconds: 500), (timer) async {
        TIME();
      });
      var ans = await Earthquake(Data);
      var s = ans[0];
      var S = s.toString().replaceAll("-", "").replaceAll("+", "");
      if (Intensity(S) < Intensity(config.get("intensity"))) return;
      PlayAudio("audios/EEW.wav");
      PlayAudio("audios/1/$S.wav");
      if (s.toString().contains("+")) {
        PlayAudio("audios/1/intensity-strong.wav");
      } else if (s.toString().contains("-")) {
        PlayAudio("audios/1/intensity-weak.wav");
      } else {
        PlayAudio("audios/1/intensity.wav");
      }
      if (int.parse(s.toString().replaceAll("-", "").replaceAll("+", "")) >=
          4) {
        for (var i = 0; i < 5; i++) {
          PlayAudio("audios/Alert.wav");
        }
      }
      var Wave = 3.5;
      if (config.get('wave')) {
        if (ans[2] >= 50) Wave = 4;
      }
      var a = ((ans[2] - ((TN - Data["Time"]) / 1000) * Wave) / Wave).toInt();
      if (a <= 0) {
        PlayAudio("audios/1/arrive.wav");
      } else if (a <= 99) {
        if (a >= 20) {
          PlayAudio("audios/1/${a.toString().substring(0, 1)}x.wav");
          PlayAudio("audios/1/x${a.toString().substring(1, 2)}.wav");
        } else if (a > 10) {
          PlayAudio("audios/1/x${a.toString().substring(1, 2)}.wav");
        } else {
          PlayAudio("audios/1/$a.wav");
        }
        PlayAudio("audios/1/second.wav");
      }
      var note = 0;
      var count = 0;
      var D;
      D = Timer.periodic(const Duration(milliseconds: 100), (timer) async {
        var value =
            ((ans[2] - ((TN - Data["Time"]) / 1000) * Wave) / Wave).toInt();
        if (value != note) {
          note = value;
          if (value < 100 && value > 0) {
            if (value <= 10) {
              PlayAudio("audios/1/$value.wav");
            } else if (value.toString().substring(1, 2) == "0") {
              PlayAudio("audios/1/${value.toString().substring(0, 1)}x.wav");
              PlayAudio("audios/1/10.wav");
            } else {
              PlayAudio("audios/1/ding.wav");
            }
          } else if (value == 0) {
            PlayAudio("audios/1/arrive.wav");
          } else {
            if (count < 5) {
              PlayAudio("audios/1/ding.wav");
              count++;
            } else {
              if (AudioList.isEmpty && count == 5) {
                player.onPlayerComplete.listen((event) {
                  if (val != null) PerfectVolumeControl.setVolume(val);
                  D.cancel();
                  T.cancel();
                });
              }
            }
          }
        }
      });
    } else if (Data["Function"] == "report") {
      PlayAudio("audios/Report.wav");
    } else if (Data["Function"] == "palert") {
      PlayAudio("audios/palert.wav");
    } else if (Data["Function"] == "TSUNAMI") {
      PlayAudio("audios/Water.wav.wav");
    }
  });
}
