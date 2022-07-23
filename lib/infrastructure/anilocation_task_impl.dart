// Flutter imports:
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animarker/animation/bearing_tween.dart';
import 'package:flutter_animarker/core/anilocation_task_description.dart';
import 'package:flutter_animarker/helpers/spherical_util.dart';
import 'package:flutter_animarker/infrastructure/anilocation_task_initializer_mixin.dart';

// Project imports:
import 'package:flutter_animarker/animation/proxy_location_animation.dart';
import 'package:flutter_animarker/core/i_anilocation_task.dart';
import 'package:flutter_animarker/animation/location_tween.dart';
import 'package:flutter_animarker/helpers/extensions.dart';
import 'package:flutter_animarker/core/i_lat_lng.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'interpolators/polynomial_location_interpolator_impl.dart';

/// Hold the logic for interpolate each given marker per its MarkerId
/// Every AnilocationTask control the animation of a unique Marker reference
/// this way, the package can support multiple Marker simultaneously
class AnilocationTaskImpl extends IAnilocationTask
    with AnilocationTaskInitializer {
  //late final AnimationController _locationCtrller;
  //late final LocationTween _locationTween;
  late final AnimationController _rippleCtrller;

  late final BearingTween _bearingTween;
  late final Tween<double> _radiusTween;

  late final Animation<ILatLng> _locationAnimation;
  late final Animation<double> _bearingAnimation;
  late final Animation<double> _radiusAnimation;
  late final Animation<Color?> _colorAnimation;

  late final ProxyAnimationGeneric<ILatLng> _proxyAnim;

  bool _isResseting = false;
  bool _isActiveTrip = true;
  bool _useRotation = true;
  bool _isMultipointAnimation = false;
  DateTime rippleTimeCount = DateTime.now();

  late final AnimationWrapper wrapper;

  @override
  AnilocationTaskDescription description;

  AnilocationTaskImpl({required this.description})
      : super(description: description) {
    wrapper = animationWrapper();

    _isActiveTrip = description.isActiveTrip;
    _useRotation = description.useRotation;

    //Bearing
    _bearingTween = BearingTween.from(wrapper.locationTween);

    _bearingAnimation = _bearingTween.curvedAnimate(
        controller: wrapper.locationCtrller, curve: description.curve);

    wrapper.locationCtrller.addListener(_locationListener);
    wrapper.locationCtrller.addStatusListener(_statusListener);

    _locationAnimation = wrapper.locationTween.curvedAnimate(
      controller: wrapper.locationCtrller,
      curve: description.curve,
    );

    _proxyAnim = ProxyAnimationGeneric<ILatLng>(_locationAnimation);

    //Ripple
    _rippleCtrller = AnimationController(
        vsync: description.vsync, duration: description.rippleDuration)
      ..addStatusListener(_rippleStatusListener)
      ..addListener(_rippleListener);

    _radiusTween = Tween<double>(begin: 0, end: description.rippleRadius);

    _radiusAnimation = _radiusTween.curvedAnimate(
        curve: Curves.linear, controller: _rippleCtrller);

    _colorAnimation = ColorTween(
      begin: description.rippleColor.withOpacity(1.0),
      end: description.rippleColor.withOpacity(0.0),
    ).curvedAnimate(curve: Curves.ease, controller: _rippleCtrller);
  }

  @override
  Future<void> push(ILatLng latLng) async {
    if (!_isActiveTrip) return;

    if (!_isMultipointAnimation) {
      description.push(latLng);
      await _forward(); //Linear interpolation
    } else if (description.length > description.runExpressAfter) {
      _isMultipointAnimation = true;
      description.clear();
      animatePoints(last: latLng); //Multipoints interpolation
    }
  }

  /// Entry point to start animation of location positions if is not a running animation
  /// or the animation is completed or dismissed
  Future<void> _forward() async {
    //Start animation
    var canMoveForward = description.isQueueNotEmpty &&
        !isAnimating &&
        wrapper.locationCtrller.isCompletedOrDismissed;

    if (canMoveForward) {
      var next = description.next;

      var wasBeginLocationSet = _settingBeginLocation(next);

      if (!wasBeginLocationSet) return;

      _swappingPosition(next);

      rippleTimeCount = DateTime.now();

      _isResseting = true;
      await Future.wait([
        wrapper.locationCtrller.resetAndForward(),
        _rippleCtrller.resetAndForward(),
      ]);
    }
  }

  /// Move the old [_locationTween].[end] to [_locationTween].[begin] position,
  /// and the [from] position to [_locationTween].[end] .
  ///
  /// Move the old [_bearingTween].[end] to [_bearingTween].[begin] position,
  /// and the bearing angle from [_locationTween] position to [_locationTween].[end] .
  ///
  ///  When [_locationTween].[begin] to [_locationTween].[end] are equal or very similar
  ///  can produce unreal angle result, to prevent this the method set the same [_bearingTween].[end]
  ///  and skip the previous angle result.
  ///
  /// This produce a stable angle interpolation
  void _swappingPosition(ILatLng from) {
    wrapper.locationTween.swap(from);

    if (_useRotation) {
      double angle;

      final angleRad = SphericalUtil.computeAngleBetween(
          wrapper.locationTween.begin, wrapper.locationTween.end);
      final sinAngle = sin(angleRad);

      if (sinAngle < 1E-6 /*|| description.angleThreshold*/) {
        angle = _bearingTween.end;
      } else {
        angle = wrapper.locationTween.bearing;
      }

      _bearingTween.swap(angle);
    }
  }

  /// Set the [_locationTween].[begin] initially
  bool _settingBeginLocation(ILatLng from) {
    if (from.isEmpty) return false;

    if (wrapper.locationTween.isStopped && wrapper.locationTween.end == from) {
      wrapper.locationTween.begin = from;

      if (_useRotation) {
        _bearingTween.begin = 0;
      }

      return false;
    }

    return true;
  }

  /// Multipoint animation allow to interpolation "sewing" through all position in the
  /// Location Queue at once.
  void animatePoints({ILatLng last = const ILatLng.empty()}) {
    if (description.isQueueNotEmpty) {
      wrapper.locationCtrller.removeStatusListener(_statusListener);

      var interpolator =
          PolynomialLocationInterpolator(points: description.values);
      var multiPoint = LocationTween(interpolator: interpolator);

      _swappingPosition(last);

      _isResseting = true;

      wrapper.locationCtrller.addStatusListener(_statusListenerPoints);

      _proxyAnim.parent = multiPoint.curvedAnimate(
        curve: description.curve,
        controller: wrapper.locationCtrller,
      );

      wrapper.locationCtrller.resetAndForward();
    }
  }

  void _rippleListener() async {
    var radius = (_radiusAnimation.value / 100);
    var color = _colorAnimation.value!;

    for (var wave = 3; wave >= 0; wave--) {
      var circleId = CircleId('CircleId->$wave');
      var circle = Circle(
        circleId: circleId,
        center: value.toLatLng,
        radius: radius * wave,
        fillColor: color,
        strokeWidth: 1,
        strokeColor: color,
      ).clone();

      if (wrapper.locationTween.isRipple &&
          description.onRippleAnimation != null) {
        description.onRippleAnimation!(circle);
      }
    }
  }

  void _rippleStatusListener(AnimationStatus status) async {
    // Determine when the Marker is idle setting a timeout
    if (DateTime.now().difference(rippleTimeCount) >
        description.rippleIdleAfter) return;

    var canRipple = !_rippleCtrller.isAnimating &&
        _rippleCtrller.isCompleted &&
        !_rippleCtrller.isDismissed &&
        description.isQueueEmpty;

    if (canRipple) {
      var halfDuration = Duration(
          milliseconds: description.rippleDuration.inMilliseconds ~/ 2);
      await Future.delayed(
          halfDuration, () async => await _rippleCtrller.forward(from: 0));
    }
  }

  void _locationListener() {
    if (description.latLngListener != null) {
      description.latLngListener!(value);
    }
  }

  void _statusListener(AnimationStatus status) async {
    if (_isResseting) {
      _isResseting = false;
      return;
    }

    if (status.isCompletedOrDismissed) {
      if (description.onAnimCompleted != null) {
        await _forward();
        description.onAnimCompleted!(description);
      }
    }
  }

  void _statusListenerPoints(AnimationStatus status) async {
    if (status == AnimationStatus.completed) {
      _isMultipointAnimation = false;
      wrapper.locationCtrller.removeStatusListener(_statusListenerPoints);
      _proxyAnim.parent = _locationAnimation;
      wrapper.locationCtrller.addStatusListener(_statusListener);
      _isResseting = true;
      await _forward();
    }
  }

  @override
  void updateRadius(double radius) {
    if (wrapper.locationTween.isRipple) {
      _radiusTween.end = radius;
    }
  }

  @override
  void updateActiveTrip(bool isActiveTrip) {
    _isActiveTrip = isActiveTrip;

    if (!_isActiveTrip) {
      var last = description.last;
      description.clear();
      description.push(last);
      _forward();
    }
  }

  @override
  void updateUseRotation(bool useRotation) {
    _useRotation = useRotation;
  }

  @override
  ILatLng get value =>
      _proxyAnim.value.copyWith(bearing: _bearingAnimation.value);

  @override
  bool get isAnimating => wrapper.locationCtrller.isAnimating;

  @override
  bool get isCompleted => wrapper.locationCtrller.isCompleted;

  @override
  bool get isDismissed => wrapper.locationCtrller.isDismissed;

  @override
  bool get isCompletedOrDismissed =>
      wrapper.locationCtrller.isCompletedOrDismissed;

  @override
  void dispose() {
    description.dispose();
    wrapper.locationCtrller
      ..removeStatusListener(_statusListener)
      ..removeListener(_locationListener)
      ..dispose();
    _rippleCtrller
      ..removeStatusListener(_rippleStatusListener)
      ..removeListener(_rippleListener)
      ..dispose();
  }
}
