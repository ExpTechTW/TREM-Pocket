import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:uuid/uuid.dart';

class InitializationPage extends StatefulWidget {
  const InitializationPage({Key? key}) : super(key: key);

  @override
  _InitializationPage createState() => _InitializationPage();
}

class _InitializationPage extends State<InitializationPage> {
  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Hive.initFlutter();
      await Hive.openBox('config');
      var config=Hive.box('config');
      if(config.get('UUID')==null){
        config.put('UUID', const Uuid().v4());
      }
      print(config.get('UUID'));
    });
    return Scaffold();
  }
}
