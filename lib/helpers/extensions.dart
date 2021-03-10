import 'package:flutter/material.dart';
import 'package:flutter_animarker/anims/location_tween.dart';
import 'package:flutter_animarker/core/i_lat_lng.dart';
import 'package:flutter_animarker/core/ripple_marker.dart';
import 'package:flutter_animarker/models/lat_lng_info.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

extension GoogleMapLatLng on ILatLng {
  LatLng get toLatLng => LatLng(this.latitude, this.longitude);
}

extension LatLngEx on Marker {
  bool get isRipple {
    if (this is RippleMarker)
      return (this as RippleMarker).ripple;
    else
      return false;
  }

  ILatLng get toLatLngInfo =>
      LatLngInfo(this.position.latitude, this.position.longitude, this.markerId.value,
          ripple: this.isRipple);
}

extension LocationTweenEx on LocationTween {
  Animation<ILatLng> animarker({
    required Animation<double> controller,
    Curve curve: Curves.linear,
    required VoidCallback listener,
  }) =>
      this.animate(CurvedAnimation(curve: curve, parent: controller))..addListener(listener);
}

extension MapToSet on Map<MarkerId, Marker> {
  Set<Marker> get set => this.values.toSet();
}

extension CircleToSet on Map<CircleId, Circle> {
  Set<Circle> get set => this.values.toSet();
}

extension LatLngInfoEx on LatLng {
  LatLngInfo toLatLngInfo(String markerId, [double bearing = 0]) =>
      LatLngInfo(latitude, longitude, markerId, bearing: bearing);
}
