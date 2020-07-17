import 'package:google_maps_flutter/google_maps_flutter.dart' show LatLng;

class LatLngDelta {
  final LatLng from;
  final LatLng to;
  double rotation;

  LatLngDelta({this.from, this.to, this.rotation});
}
