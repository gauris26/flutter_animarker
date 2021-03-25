import 'dart:typed_data';

import 'package:flutter_animarker/anims/location_tween.dart';
import 'package:flutter_animarker/core/i_interpolation_service_optimized.dart';
import 'package:flutter_animarker/helpers/spherical_util.dart';

class AngleInterpolatorImpl extends IInterpolationServiceOptimized<double> {
  @override
  late double begin;
  @override
  late double end;
  late Float32x4 shortestAngleFloat32x4;
  late Float32x4 fromFloat32x4;

  AngleInterpolatorImpl({double begin = 0, double end = 0})
      : begin = begin,
        end = end, super.warmUp();

  factory AngleInterpolatorImpl.from(LocationTween tween) => AngleInterpolatorImpl(
        begin: 0,
        end: tween.end - tween.begin,
      );

  @override
  bool get isStopped => begin == end;

  @override
  double doInterpolate(double t) =>
      SphericalUtil.angleLerpOptimized(shortestAngleFloat32x4, fromFloat32x4, t);

  @override
  void doSwap(double newValue) {
    begin = end;
    end = newValue;
  }

  @override
  void doWarmUp() {
    var shortestAngle = SphericalUtil.angleShortestDistance(begin, end);

    if (shortestAngle.abs() < 1e-6) shortestAngle = 0;

    shortestAngleFloat32x4 = Float32x4.splat(shortestAngle);
    fromFloat32x4 = Float32x4.splat(begin);
  }
}
