import 'dart:typed_data';

import 'package:flutter/services.dart';

Future<Uint8List> Audio(audio) async {
  ByteData bytes = await rootBundle.load(audio);
  return bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes);
}
