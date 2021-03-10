import 'package:flutter/animation.dart';
import 'package:flutter_animarker/core/bearing_heading_mixin.dart';
import 'package:flutter_animarker/core/i_lat_lng.dart';
import 'package:flutter_animarker/helpers/spherical_util.dart';
import 'package:flutter_animarker/models/lat_lng_info.dart';

/// A tween with a location values (latitude, Longitude).
class LocationTween extends Tween<ILatLng> with BearingHeadingMixin {
  ILatLng _previousPosition = LatLngInfo.empty();
  double _previousBearing = 0;
  final bool isBearing;
  ILatLng _begin;
  ILatLng _end;

  /// Create a tween whose [begin] and [end] values location points.
  LocationTween({
    required ILatLng begin,
    required ILatLng end,
    this.isBearing = true,
  })  : _begin = begin,
        _end = end;

  @override
  ILatLng get begin => _begin;

  @override
  set begin(ILatLng? value) => _begin = value!;

  @override
  ILatLng get end => _end;

  @override
  set end(ILatLng? value) => _end = value!;

  ILatLng get previousPosition => _previousPosition.isEmpty ? begin : _previousPosition;

  ///Interpolate two locations with planet spherical calculations at the given animation clock value.
  @override
  ILatLng lerp(double t) {
    if (begin == end) return end;

    var tPosition = SphericalUtil.interpolate(begin, end, t);

    if (isBearing) {
      tPosition = _bearing(tPosition);
    }

    _previousPosition = tPosition; //If it's being interpolated is not a stopover

    return tPosition;
  }

  /// Returns the interpolated value for the current value of the given animation.
  @override
  ILatLng transform(double t) {
    //Setting bearing from previous position to avoid sudden flicking markers
    if (t == 0.0) return begin.copyWith(bearing: _previousBearing);

    //Setting bearing from previous position to avoid sudden flicking markers
    if (t == 1.0) return end.copyWith(bearing: _previousBearing, isStopover: true);

    return lerp(t);
  }

  ///Perform rotation of the marker from the angle between the given positions
  ILatLng _bearing(ILatLng tPosition) {
    //Resetting bearing to make object equal, just for comparison
    var pre = previousPosition.copyWith(bearing: tPosition.bearing);

    double bearing = performBearing(pre, tPosition);

    _previousBearing = bearing;

    return tPosition.copyWith(bearing: bearing);
  }

  void reset() {
    _previousBearing = 0;
    _previousPosition = LatLngInfo.empty();
  }
}
