import 'package:flutter_animarker/flutter_map_marker_animation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' show LatLng;

extension GoogleMapLatLng on LatLngInfo {
  LatLng get toLatLng => LatLng(this.latitude, this.longitude);
}

extension LatLngInfoEx on LatLng {
  LatLngInfo toLatLngInfo(String markerId) => LatLngInfo(this.latitude, this.longitude, markerId);
}

