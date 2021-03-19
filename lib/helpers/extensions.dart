import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animarker/anims/location_tween.dart';
import 'package:flutter_animarker/core/i_lat_lng.dart';
import 'package:flutter_animarker/core/ripple_marker.dart';
import 'package:flutter_animarker/helpers/math_util.dart';
import 'package:flutter_animarker/models/lat_lng_info.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:vector_math/vector_math.dart';

extension DoubleEx on double {
  double get radians => MathUtil.toRadians(this).toDouble();
  double get degrees => MathUtil.toDegrees(this).toDouble();
}

extension AnimationStatusEx on AnimationStatus {
  bool get isCompletedOrDismissed => this == AnimationStatus.completed || this == AnimationStatus.dismissed;
}
extension GoogleMapLatLng on ILatLng {
  LatLng get toLatLng => LatLng(latitude, longitude);

  bool get isRipple {
    if (this is RippleMarker) {
      return (this as RippleMarker).ripple;
    } else {
      return false;
    }
  }

  Vector3 get vector {

    var latRad = latitude*degrees2Radians ;
    var lonRad = longitude*degrees2Radians;

    //Polar to vector
    var x = cos(lonRad)*cos(latRad);
    var y = sin(lonRad)*cos(latRad);
    var z = sin(latRad);

    return Vector3(x, y, z);
  }
}

extension AnimationControllerEx on AnimationController {
  bool get isCompletedOrDismissed => isCompleted || isDismissed;

  TickerFuture resetAndForward({ double? from }) {
    reset();
    return forward(from: from);
  }
}

extension LatLngEx on Marker {
  bool get isRipple {
    if (this is RippleMarker) {
      return (this as RippleMarker).ripple;
    } else {
      return false;
    }
  }

  ILatLng toLatLngInfo([double bearing = 0]) =>
      LatLngInfo(position.latitude, position.longitude, markerId, bearing: bearing, ripple: isRipple);
}

extension LocationTweenEx on LocationTween {
  Animation<ILatLng> animarker({
    required Animation<double> controller,
    Curve curve = Curves.linear,
    required VoidCallback listener,
  }) =>
      animate(CurvedAnimation(curve: curve, parent: controller))..addListener(listener);
}

extension MapToSet on Map<MarkerId, Marker> {
  Set<Marker> get set => values.toSet();
}

extension CircleToSet on Map<CircleId, Circle> {
  Set<Circle> get set => values.toSet();
}

extension LatLngInfoEx on LatLng {
  ILatLng toLatLngInfo(MarkerId markerId, [double bearing = 0]) =>
      LatLngInfo(latitude, longitude, markerId, bearing: bearing);

  Vector3 get vector {

    var latRad = latitude*degrees2Radians ;
    var lonRad = longitude*degrees2Radians;

    //Polar to vector
    var x = cos(lonRad)*cos(latRad);
    var y = sin(lonRad)*cos(latRad);
    var z = sin(latRad);

    return Vector3(x, y, z);
  }
}

extension TweenEx<K extends Object, T extends Tween<K>> on T {
  Animation<K> anim8({required Animation<double> parent, Curve curve = Curves.linear, }) => animate(CurvedAnimation(curve: curve, parent: parent));
}
