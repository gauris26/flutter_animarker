import 'dart:typed_data';

import 'package:flutter_animarker/animation/location_tween.dart';
import 'package:flutter_animarker/core/i_interpolation_service_optimized.dart';
import 'package:flutter_animarker/helpers/spherical_util.dart';

class AngleInterpolatorImpl extends IInterpolationServiceOptimized<double> {
  @override
  late double begin;

  late double _end;
  late double _shortestAngle;

  @override
  double get end => findShortestAngle ? _shortestAngle : _end;

  @override
  set end(double value) {
    if (findShortestAngle) {
      _shortestAngle = SphericalUtil.angleShortestDistance(begin, value);
      _end = _shortestAngle;
      return;
    }
    _shortestAngle = value;
    _end = value;
  }

  late Float32x4 shortestAngleFloat32x4;
  late Float32x4 fromFloat32x4;
  final bool findShortestAngle;

  AngleInterpolatorImpl(
      {double begin = 0, double end = 0, this.findShortestAngle = true})
      : begin = begin,
        _shortestAngle = findShortestAngle
            ? SphericalUtil.angleShortestDistance(begin, end)
            : end,
        _end = end,
        super.warmUp();

  // TODO: Puede que este causando los flicking con el angulo de inicio en cero
  factory AngleInterpolatorImpl.from(LocationTween tween) =>
      AngleInterpolatorImpl(
        begin: 0,
        end: tween.end - tween.begin,
      );

  @override
  bool get isStopped => begin == end || _shortestAngle == 0;

  @override
  double doInterpolate(double t) => SphericalUtil.angleLerpOptimized(
      shortestAngleFloat32x4, fromFloat32x4, t);

  @override
  void doSwap(double newValue) {
    begin = end;
    end = newValue;
  }

  @override
  void doWarmUp() {
    double angle;

    if (findShortestAngle) {
      angle = SphericalUtil.angleShortestDistance(begin, end);
    } else {
      angle = end - begin;
    }

    if (angle.abs() < 1e-6) angle = 0;

    shortestAngleFloat32x4 = Float32x4.splat(angle);
    fromFloat32x4 = Float32x4.splat(begin);
  }
}
