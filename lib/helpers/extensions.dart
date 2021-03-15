import 'package:flutter/material.dart';
import 'package:flutter_animarker/anims/location_tween.dart';
import 'package:flutter_animarker/core/i_lat_lng.dart';
import 'package:flutter_animarker/core/ripple_marker.dart';
import 'package:flutter_animarker/models/lat_lng_info.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

extension GoogleMapLatLng on ILatLng {
  LatLng get toLatLng => LatLng(this.latitude, this.longitude);

  bool get isRipple {
    if (this is RippleMarker)
      return (this as RippleMarker).ripple;
    else
      return false;
  }
}

extension AnimationControllerEx on AnimationController {
  bool get isFinished => this.isCompleted || this.isDismissed;
  TickerFuture resetAndForward({ double? from }) {
    this.reset();
    return this.forward(from: from);
  }
}

extension LatLngEx on Marker {
  bool get isRipple {
    if (this is RippleMarker)
      return (this as RippleMarker).ripple;
    else
      return false;
  }

  ILatLng toLatLngInfo([double bearing = 0]) =>
      LatLngInfo(this.position.latitude, this.position.longitude, this.markerId, bearing: bearing, ripple: this.isRipple);
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
  ILatLng toLatLngInfo(MarkerId markerId, [double bearing = 0]) =>
      LatLngInfo(latitude, longitude, markerId, bearing: bearing);
}
