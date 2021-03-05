import 'package:flutter/animation.dart';
import 'package:flutter_animarker/helpers/spherical_util.dart';

/// A tween with a angle values.
class AngleTween extends Tween<double> {
  double _previousAngle = double.nan;

  /// Create a tween between given [begin] and [end] angle positions.
  AngleTween({double begin = 0, double end = 0}) : super(begin: begin, end: end);

  ///Interpolates two angles at the given animation clock value.
  @override
  double lerp(double t) {
    assert(begin != null, "Must selected a begin angle");
    assert(end != null, "Must selected a end angle");

    if (begin == end) return end;

    if (_previousAngle.isNaN) _previousAngle = begin;

    double angle = SphericalUtil.angleLerp(_previousAngle, end, t);

    _previousAngle = angle;

    return angle;
  }

  /// Returns the interpolated angles for the current value of the given animation.
  @override
  double transform(double t) {
    if (t == 0.0) return _previousAngle.isNaN ? begin : _previousAngle;
    if (t == 1.0) return _previousAngle.isNaN ? end : _previousAngle;

    return lerp(t);
  }
}
