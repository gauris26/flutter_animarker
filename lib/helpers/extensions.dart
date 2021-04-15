// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:vector_math/vector_math.dart';

// Project imports:
import 'package:flutter_animarker/core/i_lat_lng.dart';
import 'package:flutter_animarker/core/ripple_marker.dart';
import 'package:flutter_animarker/helpers/math_util.dart';
import 'package:flutter_animarker/helpers/spherical_util.dart';
import 'package:flutter_animarker/models/lat_lng_info.dart';

extension DoubleEx on double {
  double get radians => MathUtil.toRadians(this).toDouble();
  double get degrees => MathUtil.toDegrees(this).toDouble();
}

extension MarkerEx on Set<Marker> {
  Set<String> get markerIds => map<String>((e) => e.markerId.value).toSet();
  bool get isAnyEmpty => any((e) => e.markerId.value.isEmpty);
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
    var latRad = latitude * degrees2Radians;
    var lonRad = longitude * degrees2Radians;

    //Polar to vector
    var x = cos(lonRad) * cos(latRad);
    var y = sin(lonRad) * cos(latRad);
    var z = sin(latRad);

    return Vector3(x, y, z);
  }
}

extension Vector3Ex on Vector3 {
  ILatLng get toPolar => SphericalUtil.vectorToPolar(this);
}

extension AnimationControllerEx on AnimationController {
  bool get isCompletedOrDismissed => isCompleted || isDismissed;

  TickerFuture resetAndForward({double? from}) {
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

  ILatLng get toLatLngInfo => LatLngInfo.marker(this, ripple: isRipple);
}

extension TweenEx<T> on Tween<T> {
  Animation<T> animating({
    Curve curve = Curves.linear,
    required Animation<double> controller,
    required VoidCallback listener,
    required AnimationStatusListener statusListener,
  }) =>
      animate(CurvedAnimation(curve: curve, parent: controller))
        ..addListener(listener)
        ..addStatusListener(statusListener);

  Animation<T> curvedAnimate({
    Curve curve = Curves.linear,
    required Animation<double> controller,
  }) =>
      animate(CurvedAnimation(curve:  curve, parent: controller));

  Animation<T> intervalAnimate({
    Curve curve = Curves.linear,
    required double begin,
    required double end,
    required Animation<double> controller,
  }) =>
      animate(CurvedAnimation(curve: Interval(begin, end, curve: curve), parent: controller));
}

extension MapToSet on Map<MarkerId, Marker> {
  Set<Marker> get set => values.toSet();
}

extension CircleToSet on Map<CircleId, Circle> {
  Set<Circle> get set => values.toSet();
}

extension LatLngInfoEx on LatLng {
  ILatLng toLatLngInfo(MarkerId markerId, [double bearing = 0]) =>
      LatLngInfo.position(this, markerId, bearing: bearing);

  ILatLng get toDefaultLatLngInfo => LatLngInfo.position(this, MarkerId(''));

  Vector3 get vector {
    var latRad = latitude * degrees2Radians;
    var lonRad = longitude * degrees2Radians;

    //Polar to vector
    var x = cos(lonRad) * cos(latRad);
    var y = sin(lonRad) * cos(latRad);
    var z = sin(latRad);

    return Vector3(x, y, z);
  }
}
