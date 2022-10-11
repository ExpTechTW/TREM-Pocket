import 'package:flutter/material.dart';

class EEWPage extends StatefulWidget {
  const EEWPage({Key? key}) : super(key: key);

  @override
  _EEWPage createState() => _EEWPage();
}

class _EEWPage extends State<EEWPage> {
  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {});
    return const Scaffold(
      body: Text("123"),
    );
  }
}
