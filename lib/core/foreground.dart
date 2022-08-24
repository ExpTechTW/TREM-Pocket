import 'dart:async';
import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:intl/intl.dart';
import 'package:perfect_volume_control/perfect_volume_control.dart';
import 'package:trem/core/service.dart';

import 'api.dart';
import 'audio.dart';
import 'earthquake.dart';

List<String> AudioList = [];
final player = AudioPlayer();
bool Lock = false;

PlayAudio(String src) async {
  PerfectVolumeControl.hideUI = true;
  double val = await PerfectVolumeControl.volume;
  await PerfectVolumeControl.setVolume(1);
  AudioList.add(src);
  play() async {
    Lock = true;
    await player.play(BytesSource(await Audio(AudioList.first)));
    AudioList.removeAt(0);
  }

  Timer.periodic(const Duration(microseconds: 1), (timer) async {
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

  service.on('data').listen((event) async {
    var data = event;
    if (data!["Function"] == "NTP") {
      NTP = data["Full"];
      Now = DateTime.now().millisecondsSinceEpoch;
    } else if (data["Function"] == "earthquake") {
      time = Unix();
      PerfectVolumeControl.hideUI = true;
      double val = await PerfectVolumeControl.volume;
      PerfectVolumeControl.setVolume(1);
      await player.play(BytesSource(await Audio("audios/EEW.wav")));
      player.onPlayerComplete.listen((event) {
        PerfectVolumeControl.setVolume(val);
      });
      if (service is AndroidServiceInstance) {
        service.setForegroundNotificationInfo(
          title: "TREM Pocket",
          content: "地震速報",
        );
      }
    }
    if (data["Audio"] != null) {
      time = Unix();
      PerfectVolumeControl.hideUI = true;
      double val = await PerfectVolumeControl.volume;
      await PerfectVolumeControl.setVolume(1);
      PlayAudio(data["Audio"]);
      var Data = jsonDecode(data["Data"]);
      if (Data["Function"] == "earthquake") {
        Earthquake(Data, 1.0);
      }
      player.onPlayerComplete.listen((event) {
        PerfectVolumeControl.setVolume(val);
      });
    }
    // Navigator.push(
    //     context,
    //     MaterialPageRoute(
    //       builder: (context) => const HomePage(),
    //       maintainState: false,
    //       settings: const RouteSettings(
    //         arguments: {},
    //       ),
    //     ));
  });

  Timer.periodic(const Duration(seconds: 1), (timer) async {
    NOW = DateTime.fromMillisecondsSinceEpoch(
        NTP + (DateTime.now().millisecondsSinceEpoch - Now));
    if (service is AndroidServiceInstance && Unix() - time > 15000) {
      service.setForegroundNotificationInfo(
        title: "TREM Pocket",
        content: DateFormat('y/M/d hh:mm:ss').format(NOW),
      );
    }
  });
  ExpTech();
}
