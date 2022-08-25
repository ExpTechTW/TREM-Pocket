import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';


class EEWPage extends StatefulWidget {
  const EEWPage({Key? key}) : super(key: key);

  @override
  _EEWPage createState() => _EEWPage();
}

class _EEWPage extends State<EEWPage> {
  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {

    });
    return FlutterMap(
      options: MapOptions(
        center: LatLng(23.608428, 120.799168),
        zoom: 7.5,
      ),
      layers: [
        TileLayerOptions(
          urlTemplate:
              "https://api.mapbox.com/styles/v1/mapbox/dark-v10/tiles/{z}/{x}/{y}?access_token=pk.eyJ1IjoibWFwYm94IiwiYSI6ImNpejY4NXVycTA2emYycXBndHRqcmZ3N3gifQ.rJcFIG214AriISLbB6B5aw",
        ),
        CircleLayerOptions(
          circles: [],
        ),
      ],
    );
  }
}
