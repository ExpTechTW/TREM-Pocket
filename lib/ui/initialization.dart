import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:trem/ui/eew.dart';
import 'package:trem/ui/report.dart';
import 'package:uuid/uuid.dart';

import 'home.dart';

class InitializationPage extends StatefulWidget {
  const InitializationPage({Key? key}) : super(key: key);

  @override
  _InitializationPage createState() => _InitializationPage();
}

class _InitializationPage extends State<InitializationPage> {
  int _currentIndex = 0;
  final pages = [const HomePage(), const EEWPage(), const ReportPage()];

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Hive.initFlutter();
      await Hive.openBox('config');
      var config = Hive.box('config');
      if (config.get('UUID') == null) {
        config.put('UUID', const Uuid().v4());
      }
      print(config.get('UUID'));
    });
    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '首頁'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: '警報'),
          //BottomNavigationBarItem(icon: Icon(Icons.chat), label: '發佈'),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_circle), label: '報告'),
        ],
        currentIndex: _currentIndex,
        fixedColor: Colors.black,
        onTap: _onItemClick,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
    );
  }

  void _onItemClick(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
}
