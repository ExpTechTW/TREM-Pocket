import 'package:flutter/material.dart';
import 'package:flutter_loggy/flutter_loggy.dart';

class LogPage extends StatelessWidget {
  const LogPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: const LoggyStreamWidget(),
      backgroundColor: Colors.black12,
    );
  }
}
