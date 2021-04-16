// Flutter imports:
import 'package:flutter/animation.dart';
import 'package:flutter_animarker/core/i_interpolation_service_optimized.dart';

// Project imports:
import 'package:flutter_animarker/infrastructure/interpolators/angle_interpolator_impl.dart';

import 'location_tween.dart';

/// A tween with a angle values.
class BearingTween extends Tween<double> {
  final IInterpolationServiceOptimized<double> interpolator;

  /// Create a tween that calculate angle bearing/heading from given [begin] and [end] angle positions.
  BearingTween({required this.interpolator});

  factory BearingTween.from(LocationTween tween) =>
      BearingTween(interpolator: AngleInterpolatorImpl.from(tween));

  //Getters
  @override
  double? get begin => interpolator.begin;

  @override
  double get end => interpolator.end;

  @override
  set begin(double? value) => interpolator.begin = value ?? 0;

  @override
  set end(double? value) => interpolator.end = value ?? 0;

  ///Interpolates two angles at the given (t) position at timeline.
  @override
  double lerp(double t) {
    if (interpolator.isStopped) return interpolator.end;

    return interpolator.interpolate(t);
  }

  /// Returns interpolated angles for the current position (t) on timeline.
  @override
  double transform(double t) {
    assert(t >= 0 && t <= 1, 'value must between 0.0 and 1.0');
    if (t == 0.0) return interpolator.begin;
    if (t == 1.0) return interpolator.end;

    return lerp(t);
  }

  @override
  String toString() {
    return 'AngleTween{begin: ${interpolator.begin}, end: ${interpolator.end}}';
  }
}
