import 'package:flutter_animarker/flutter_map_marker_animation.dart';
import 'package:flutter_animarker/core/i_lat_lng.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'
    show CameraPosition, CameraUpdate, LatLng;

extension GoogleMapLatLng on ILatLng {
  LatLng get toLatLng => LatLng(this.latitude, this.longitude);
}

extension LatLngInfoEx on LatLng {
  LatLngInfo toLatLngInfo(String markerId, [double bearing = 0]) => LatLngInfo(latitude, longitude, markerId, bearing);

  CameraUpdate get cameraPosition => CameraUpdate.newCameraPosition(
        CameraPosition(
          zoom: 15,
          tilt: 0,
          bearing: 30,
          target: LatLng(latitude, longitude),
        ),
      );
}
