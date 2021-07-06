// Flutter imports:
import 'package:flutter/animation.dart';
import 'package:flutter_animarker/core/i_interpolation_service_optimized.dart';

// Project imports:
import 'package:flutter_animarker/infrastructure/interpolators/angle_interpolator_impl.dart';

import 'location_tween.dart';

/// An angle tween
class BearingTween extends Tween<double> {
  final IInterpolationServiceOptimized<double> _interpolator;

  /// Create a tween that interpolate angle bearing/heading from given [begin],[end] angle.
  BearingTween({required IInterpolationServiceOptimized<double> interpolator}): _interpolator = interpolator;

  /// Create a tween from a existing [LocationTween]
  factory BearingTween.from(LocationTween tween) =>
      BearingTween(interpolator: AngleInterpolatorImpl.from(tween));

  //Getters
  @override
  double? get begin => _interpolator.begin;

  @override
  double get end => _interpolator.end;

  @override
  set begin(double? value) => _interpolator.begin = value ?? 0;

  @override
  set end(double? value) => _interpolator.end = value ?? 0;

  void swap(double angle) => _interpolator.swap(angle);

  ///Interpolates two angles at the given (t) position at timeline.
  @override
  double lerp(double t) {
    if (_interpolator.isStopped) return _interpolator.end;

    return _interpolator.interpolate(t);
  }

  /// Returns interpolated angles for the current position (t) on timeline.
  @override
  double transform(double t) {
    assert(t >= 0 && t <= 1, 'value must between 0.0 and 1.0');
    if (t == 0.0) return _interpolator.begin;
    if (t == 1.0) return _interpolator.end;

    return lerp(t);
  }

  @override
  String toString() {
    return 'AngleTween{begin: ${_interpolator.begin}, end: ${_interpolator.end}}';
  }
}
