import 'package:flutter/animation.dart';
import 'package:flutter_animarker/animation/location_tween.dart';
import 'package:flutter_animarker/core/i_anilocation_task.dart';

import 'interpolators/line_location_interpolator_impl.dart';

mixin AnilocationTaskInitializer on IAnilocationTask {
  //late final AnimationController _rippleCtrller;

  //late final BearingTween _bearingTween;
  //late final Tween<double> _radiusTween;

  //late final Animation<ILatLng> _locationAnimation;
  //late final Animation<double> _bearingAnimation;
  //late final Animation<double> _radiusAnimation;
  //late final Animation<Color?> _colorAnimation;

  //late final ProxyAnimationGeneric<ILatLng> _proxyAnim;

  AnimationWrapper animationWrapper() {
    final locationTween = LocationTween(
      interpolator: LineLocationInterpolatorImpl(
        begin: description.begin.copyWith(markerId: description.markerId),
        end: description.end.copyWith(markerId: description.markerId),
      ),
    );

    final locationCtrller = AnimationController(
        vsync: description.vsync, duration: description.duration);

    return AnimationWrapper(locationTween, locationCtrller);
  }
}

class AnimationWrapper {
  final AnimationController locationCtrller;
  final LocationTween locationTween;

  AnimationWrapper(this.locationTween, this.locationCtrller);
}
