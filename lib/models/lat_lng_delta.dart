import 'lat_lng_info.dart';

class LatLngDelta {
  final LatLngInfo from;
  final LatLngInfo to;
  double rotation;
  String markerId;

  LatLngDelta({this.from, this.to, this.rotation, this.markerId = ""});
}
