import 'package:flutter/animation.dart';
import 'package:flutter_animarker/core/i_lat_lng.dart';
import 'package:flutter_animarker/helpers/spherical_util.dart';

/// A tween with a location values (latitude, Longitude).
class LocationTween extends Tween<ILatLng> {
  ILatLng _previousValue = EmptyLatLng();
  double _previousBearing = 0;
  final bool useRotation;
  final double threshold;
  /// Create a tween whose [begin] and [end] values location points.
  LocationTween({ILatLng begin, ILatLng end, this.useRotation = true, this.threshold = 10})
      : assert(begin != null, "Must selected a begin position"),
        assert(end != null, "Must selected a end position"),
        super(begin: begin, end: end);

  ///Interpolate two locations with planet spherical calculations at the given animation clock value.
  @override
  ILatLng lerp(double t) {
    assert(begin != null, "Must selected a begin position");
    assert(end != null, "Must selected a end position");

    if(begin == end) return end;

    var interposition = SphericalUtil.interpolate(begin, end, t);

    if(useRotation) _performBearing(interposition);

    _previousValue = interposition;

    //If it's being interpolated is not a stopover
    interposition.isStopover = false;

    return interposition;
  }

  /// Returns the interpolated value for the current value of the given animation.
  @override
  ILatLng transform(double t) {
    //Setting bearing from previous position to avoid sudden flicking markers
    if (t == 0.0) {
      begin.bearing = _previousBearing;
      begin.isStopover = true;
      return begin;
    }

    //Setting bearing from previous position to avoid sudden flicking markers
    if (t == 1.0) {
      end.bearing = _previousBearing;
      end.isStopover = false;
      return end;
    }

    return lerp(t);
  }

  ///Perfom rotation of the marker from the angle between the given positions
  void _performBearing(ILatLng interposition) {

    double bearing = SphericalUtil.getBearing(_previousValue ?? begin, interposition);

    if (bearing.isNaN || _previousBearing == bearing) bearing = _previousBearing;

    interposition.bearing = bearing;

    _previousBearing = bearing;
  }

  void reset(){
    _previousBearing = 0;
    _previousBearing = null;
  }
}