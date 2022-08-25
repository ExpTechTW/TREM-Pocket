import 'dart:async';
import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:perfect_volume_control/perfect_volume_control.dart';

import 'api.dart';
import 'audio.dart';
import 'earthquake.dart';
import 'network.dart';

double TN = 0;

List<String> AudioList = [];
final player = AudioPlayer();
bool Lock = false;

PlayAudio(String src) async {
  player.setPlaybackRate(1.1);
  PerfectVolumeControl.hideUI = true;
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

  TIME() async {
    var Now = DateTime.now().millisecondsSinceEpoch;
    var data = jsonDecode(await Get("https://exptech.com.tw/get?Function=NTP"));
    TN = data["Full"] + (DateTime.now().millisecondsSinceEpoch - Now) / 2;
  }

  service.on('data').listen((event) async {
    var data = event;
    if (data!["Audio"] != null) {
      time = Unix();
      PerfectVolumeControl.hideUI = true;
      double val = await PerfectVolumeControl.volume;
      //await PerfectVolumeControl.setVolume(1);
      PlayAudio(data["Audio"]);
      var Data = jsonDecode(data["Data"]);
      await TIME();
      var T = Timer.periodic(const Duration(milliseconds: 500), (timer) async {
        TIME();
      });
      var ans = await Earthquake(Data);
      var s = ans[0];
      PlayAudio(
          "audios/1/${s.toString().replaceAll("-", "").replaceAll("+", "")}.wav");
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
      var a = ((ans[2] - ((TN - Data["Time"]) / 1000) * 3.5) / 3.5).toInt();
      if (a <= 99) {
        if (a >= 20) {
          PlayAudio("audios/1/${a.toString().substring(0, 1)}x.wav");
          PlayAudio("audios/1/x${a.toString().substring(1, 2)}.wav");
        } else if (a > 10) {
          PlayAudio("audios/1/10.wav");
          PlayAudio("audios/1/x${a.toString().substring(1, 2)}.wav");
        } else {
          PlayAudio("audios/1/$a.wav");
        }
        PlayAudio("audios/1/second.wav");
      }
      var note = 0;
      var count = 0;
      var D = Timer.periodic(const Duration(milliseconds: 100), (timer) async {
        var value =
            ((ans[2] - ((TN - Data["Time"]) / 1000) * 3.5) / 3.5).toInt();
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
              PerfectVolumeControl.setVolume(val);
            }
          }
        }
      });
    }
    // player.onPlayerComplete.listen((event) {
    //
    // });
  });
}
