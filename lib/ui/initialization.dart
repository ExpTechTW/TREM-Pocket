import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:trem/ui/home.dart';
import 'package:trem/ui/setting.dart';
import 'package:uuid/uuid.dart';

class InitializationPage extends StatefulWidget {
  const InitializationPage({Key? key}) : super(key: key);

  @override
  _InitializationPage createState() => _InitializationPage();
}

class _InitializationPage extends State<InitializationPage> {
  int _currentIndex = 0;
  final pages = [const HomePage(), const SetPage()];

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Hive.initFlutter();
      await Hive.openBox('config');
      var config = Hive.box('config');
      if (config.get('UUID') == null) {
        config.put('UUID', const Uuid().v4());
      }
    });
    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '首頁'),
          // BottomNavigationBarItem(
          //     icon: Icon(Icons.computer_outlined), label: '報告'),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_circle), label: '設定'),
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
