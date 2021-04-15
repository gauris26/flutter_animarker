import 'dart:typed_data';

import 'package:flutter_animarker/animation/location_tween.dart';
import 'package:flutter_animarker/core/i_interpolation_service_optimized.dart';
import 'package:flutter_animarker/helpers/spherical_util.dart';

class AngleInterpolatorImpl extends IInterpolationServiceOptimized<double> {
  @override
  late double begin;
  @override
  late double end;
  late Float32x4 shortestAngleFloat32x4;
  late Float32x4 fromFloat32x4;
  final bool findShortestAngle;

  AngleInterpolatorImpl(
      {double begin = 0, double end = 0, this.findShortestAngle = true})
      : begin = begin,
        end = end,
        super.warmUp();

  factory AngleInterpolatorImpl.from(LocationTween tween, {bool findShortestAngle = true}) =>
      AngleInterpolatorImpl(
        begin: 0,
        end: tween.end - tween.begin,
        findShortestAngle: findShortestAngle
      );

  @override
  bool get isStopped => begin == end /*|| _shortestAngle == 0*/;

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

    /*if (findShortestAngle) {
      angle = SphericalUtil.angleShortestDistance(begin, end);
    } else {
      angle = end - begin;
    }*/


    var angle = end - begin;
    print('Warm up: $angle ($begin - $end)');
    if (angle.abs() < 1e-6) angle = 0;

    shortestAngleFloat32x4 = Float32x4.splat(angle);
    fromFloat32x4 = Float32x4.splat(begin);
  }
}
