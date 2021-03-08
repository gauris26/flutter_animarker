import 'package:flutter/animation.dart';
import 'package:flutter_animarker/helpers/spherical_util.dart';

/// A tween with a angle values.
class AngleTween extends Tween<double> {
  //Get a track of previous interpolated angle in the timeline position (t)
  // for preventing the animation swinging back (penduling from origin) to begin every tick
  double _previousAngle = double.nan;
  double _begin;
  double _end;
  /// Create a tween between given [begin] and [end] angle positions.
  AngleTween({double begin = 0, double end = 0}) : _begin = begin, _end = end;

  //Getters
  double get begin => _begin;

  double get end => _end;

  //Setters
  //Reset previous angle every begin assignment
  set begin(double? angle) {
    //Reset previous value every begin assignment
    _previousAngle = double.nan;
    _begin = angle!;
  }

  //Reset previous value every begin assignment
  set end(double? angle) => _end = angle!;

  ///Interpolates two angles at the given animation clock value.
  @override
  double lerp(double t) {

    if (_begin == _end) return 0;

    if (_previousAngle.isNaN) _previousAngle = _begin;

    double angle = SphericalUtil.angleLerp(_previousAngle, _end, t);

    _previousAngle = angle;

    return angle;
  }

  /// Returns interpolated angles for the current position (t) on timeline.
  @override
  double transform(double t) {
    assert(t >= 0 && t <= 1, "value must between 0.0 and 1.0");
    if (t == 0.0) return _previousAngle.isNaN ? _begin : _previousAngle;
    if (t == 1.0) return _previousAngle.isNaN ? _end: _previousAngle;

    return lerp(t);
  }

  @override
  String toString() {
    return 'AngleTween{begin: $_begin, end: $_end}';
  }
}
