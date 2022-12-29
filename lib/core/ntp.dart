import 'package:trem_pocket/core/http_get.dart';

int check_timestamp = 0;
int local_timestamp = 0;
int server_timestamp = 0;

Future<void> getTime() async {
  var ans = await get("https://exptech.com.tw/api/v1/et/ntp");
  server_timestamp = ans["time"];
  local_timestamp = DateTime.now().millisecondsSinceEpoch;
  check_timestamp = DateTime.now().millisecondsSinceEpoch;
}

Future<int> Now(bool focus) async {
  if (DateTime.now().millisecondsSinceEpoch - check_timestamp > 300000) {
    if (focus) {
      await getTime();
    } else {
      getTime();
    }
  }
  return (DateTime.now().millisecondsSinceEpoch - local_timestamp) +
      server_timestamp;
}
