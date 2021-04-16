// Flutter imports:
import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animarker/core/i_interpolation_service_optimized.dart';

// Project imports:
import 'package:flutter_animarker/core/i_lat_lng.dart';
import 'package:flutter_animarker/helpers/spherical_util.dart';

/// A tween with a location values (latitude, Longitude).
class LocationTween extends Tween<ILatLng> {
  final IInterpolationServiceOptimized<ILatLng> interpolator;

  LocationTween({required this.interpolator});

  @override
  ILatLng get begin => interpolator.begin;

  @override
  set begin(ILatLng? value) => interpolator.begin = value ?? ILatLng.empty();

  @override
  ILatLng get end => interpolator.end;

  bool get isRipple => interpolator.end.ripple && interpolator.end.ripple;

  @override
  set end(ILatLng? value) => interpolator.end = value ?? ILatLng.empty();

  /// Interpolate two locations with planet spherical calculations at the given animation clock value.
  @override
  ILatLng lerp(double t) {
    if (interpolator.isStopped) return end;

    return interpolator.interpolate(t).copyWith(
          markerId: end.markerId,
          isStopover: t == 1.0,
          markerJson: begin.markerJson,
        );
  }

  /// Returns the interpolated value for the current value of the given animation.
  @override
  ILatLng transform(double t) {
    //Setting bearing from previous position to avoid sudden flicking markers
    if (t == 0.0) return begin;

    //Setting bearing from previous position to avoid sudden flicking markers
    if (t == 1.0) return end.copyWith(isStopover: true);

    return lerp(t);
  }

  double get bearing => SphericalUtil.computeHeading(begin, end).toDouble();

  LocationTween operator +(ILatLng end) {
    interpolator.swap(end);
    return this;
  }
}
