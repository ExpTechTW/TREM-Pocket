import 'dart:async';
import 'dart:ui';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:intl/intl.dart';
import 'package:perfect_volume_control/perfect_volume_control.dart';
import 'package:trem/core/service.dart';

import 'api.dart';
import 'audio.dart';

void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

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
    print(data);
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
      await player.play(BytesSource(await Audio(data["Audio"])));
      player.onPlayerComplete.listen((event) {
        PerfectVolumeControl.setVolume(val);
      });
    }
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
