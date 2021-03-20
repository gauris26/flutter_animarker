// Flutter imports:
import 'package:flutter/animation.dart';
import 'package:flutter_animarker/flutter_map_marker_animation.dart';

// Project imports:
import 'package:flutter_animarker/helpers/spherical_util.dart';

/// A tween with a angle values.
class BearingTween extends Tween<double> {
  //Get a track of previous interpolated angle in the timeline position (t)
  // for preventing the animation swinging back (penduling from origin) to begin every tick
  //double _previousAngle = double.infinity;
  late double _begin;
  late double _end;

  /// Create a tween that calculate angle bearing/heading from given [begin] and [end] angle positions.
  BearingTween({
    double begin = 0,
    double end = 0,
  })  : _begin = begin,
        _end = end;

  factory BearingTween.from(LocationTween tween) => BearingTween(
        begin: 0,
        end: tween.end - tween.begin,
      );

  //Getters
  @override
  double? get begin => _begin;

  @override
  double get end => _end;

  ///Re-compute Hearing/Bearing base on new location
  double computeBearing(double newBearing) {
    if (newBearing == _end) return 0;

    _begin = _end;
    _end = newBearing;

    return SphericalUtil.angleShortestDistance(_begin, _end);
  }

  ///Interpolates two angles at the given animation clock value.
  @override
  double lerp(double t) {
    if (_begin == _end) return 0;

    //if (_previousAngle.isInfinite) _previousAngle = _begin;

    var angle = SphericalUtil.angleLerp(_begin, _end, t);
    //print('Bearing: $angle ($t) -> ($_begin,$_end)');
    //_previousAngle = angle;

    return angle;
  }

  /// Returns interpolated angles for the current position (t) on timeline.
  @override
  double transform(double t) {
    assert(t >= 0 && t <= 1, 'value must between 0.0 and 1.0');
    if (t == 0.0) return _begin;
    if (t == 1.0) return _end;

    return lerp(t);
  }

  @override
  String toString() {
    return 'AngleTween{begin: $_begin, end: $_end}';
  }
}
