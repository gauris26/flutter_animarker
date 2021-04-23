// Flutter imports:
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animarker/animation/bearing_tween.dart';
import 'package:flutter_animarker/core/anilocation_task_description.dart';
import 'package:flutter_animarker/helpers/spherical_util.dart';
import 'package:flutter_animarker/infrastructure/interpolators/line_location_interpolator_impl.dart';

// Project imports:
import 'package:flutter_animarker/animation/proxy_location_animation.dart';
import 'package:flutter_animarker/core/i_anilocation_task.dart';
import 'package:flutter_animarker/animation/location_tween.dart';
import 'package:flutter_animarker/helpers/extensions.dart';
import 'package:flutter_animarker/core/i_lat_lng.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'interpolators/polynomial_location_interpolator_impl.dart';

class AnilocationTaskImpl implements IAnilocationTask {
  late final AnimationController _locationCtrller;
  late final AnimationController _rippleCtrller;

  late final LocationTween _locationTween;
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

  @override
  AnilocationTaskDescription description;

  AnilocationTaskImpl({required this.description}) {
    _locationTween = LocationTween(
      interpolator: LineLocationInterpolatorImpl(
        begin: description.begin.copyWith(markerId: description.markerId),
        end: description.end.copyWith(markerId: description.markerId),
      ),
    );

    _isActiveTrip = description.isActiveTrip;
    _useRotation = description.useRotation;

    _locationCtrller = AnimationController(
        vsync: description.vsync, duration: description.duration);

    _bearingTween = BearingTween.from(_locationTween);
    //_bearingCtrller = AnimationController(vsync: description.vsync, duration: description.duration);

    _bearingAnimation = _bearingTween.curvedAnimate(
      controller: _locationCtrller,
      curve: description.curve,
    );

    _rippleCtrller = AnimationController(
      vsync: description.vsync,
      duration: description.rippleDuration,
    )
      ..addStatusListener(_rippleStatusListener)
      ..addListener(_rippleListener);

    _radiusTween = Tween<double>(begin: 0, end: description.rippleRadius);

    _radiusAnimation = _radiusTween.curvedAnimate(
        curve: Curves.linear, controller: _rippleCtrller);

    _colorAnimation = ColorTween(
      begin: description.rippleColor.withOpacity(1.0),
      end: description.rippleColor.withOpacity(0.0),
    ).curvedAnimate(curve: Curves.ease, controller: _rippleCtrller);

    _locationCtrller.addListener(_locationListener);
    _locationCtrller.addStatusListener(_statusListener);

    _locationAnimation = _locationTween.curvedAnimate(
      controller: _locationCtrller,
      curve: description.curve,
    );

    _proxyAnim = ProxyAnimationGeneric<ILatLng>(_locationAnimation);
    if (_locationTween.isRipple) _rippleCtrller.forward(from: 0);
  }

  @override
  Future<void> push(ILatLng latLng) async {
    //debugPrint("Value: ${latLng.toLatLng} isActiveTrip: $_isActiveTrip: Length: ${description.length}");
    if (_isActiveTrip) {
      if (!_isMultipointAnimation) {
        description.push(latLng);
        await _forward();
      } else if (description.length > description.runExpressAfter) {
        _isMultipointAnimation = true;
        description.clear();
        animatePoints(last: latLng);
      }
    }
  }

  ///Entry point to start animation of location positions if is not a running animation
  ///or the animation is completed or dismissed
  Future<void> _forward() async {
    //Start animation
    var canMoveForward = description.isQueueNotEmpty &&
        !isAnimating &&
        _locationCtrller.isCompletedOrDismissed;

    if (canMoveForward) {
      var next = description.next;

      var wasBeginLocationSet = _settingBeginLocation(next);

      if (!wasBeginLocationSet) return;

      _swappingValue(next);

      _isResseting = true;
      await Future.wait([
        _locationCtrller.resetAndForward(),
        //if (_useRotation) _bearingCtrller.resetAndForward(),
        /* if (_locationTween.isRipple && _rippleCtrller.isCompletedOrDismissed && !_rippleCtrller.isAnimating)
          _rippleCtrller.resetAndForward(),*/
      ]);
    }
  }

  void _swappingValue(ILatLng from) {
    _locationTween.interpolator.swap(from);

    if (_useRotation) {
      double angle;

      final angleRad = SphericalUtil.computeAngleBetween(
          _locationTween.interpolator.begin, _locationTween.interpolator.end);
      final sinAngle = sin(angleRad);

      if (sinAngle < 1E-6 /*|| description.angleThreshold*/) {
        angle = _bearingTween.interpolator.end;
      } else {
        angle = _locationTween.bearing;
      }

      _bearingTween.interpolator.swap(angle);
    }
  }

  bool _settingBeginLocation(ILatLng from) {
    if (from.isEmpty) return false;

    if (_locationTween.interpolator.isStopped &&
        _locationTween.interpolator.end == from) {
      _locationTween.interpolator.begin = from;

      if (_useRotation) {
        _bearingTween.interpolator.begin = 0;
      }

      return false;
    }

    return true;
  }

  void animatePoints({ILatLng last = const ILatLng.empty()}) {
    if (description.isQueueNotEmpty) {
      _locationCtrller.removeStatusListener(_statusListener);

      var interpolator =
          PolynomialLocationInterpolator(points: description.values);
      var multiPoint = LocationTween(interpolator: interpolator);

      _swappingValue(last);

      _isResseting = true;

      _locationCtrller.addStatusListener(_statusListenerPoints);

      _proxyAnim.parent = multiPoint.curvedAnimate(
        curve: description.curve,
        controller: _locationCtrller,
      );

      _locationCtrller.resetAndForward();
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
      );

      await Future.delayed(Duration(milliseconds: 100));

      if (_locationTween.isRipple && description.onRippleAnimation != null) {
        description.onRippleAnimation!(circle);
      }
    }
  }

  void _rippleStatusListener(AnimationStatus status) async {
    if (!_rippleCtrller.isAnimating &&
        _rippleCtrller.isCompleted &&
        !_rippleCtrller.isDismissed &&
        description.isQueueEmpty) {
      var halfDuration = description.rippleDuration.inMilliseconds ~/ 2;
      //print('_rippleStatusListener');
      await Future.delayed(Duration(milliseconds: halfDuration),
          () async => await _rippleCtrller.forward(from: 0));
    }
  }

  void _locationListener() {
    //debugPrint('${value.toLatLng} (t): ${_locationCtrller.value} isStopover: ${value.isStopover} Length: ${description.length}');
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

      if (_locationTween.isRipple && description.isQueueEmpty) {
        print('_statusListener');
        _rippleCtrller.reset();
      }
    }
  }

  void _statusListenerPoints(AnimationStatus status) async {
    if (status == AnimationStatus.completed) {
      _isMultipointAnimation = false;
      _locationCtrller.removeStatusListener(_statusListenerPoints);
      _proxyAnim.parent = _locationAnimation;
      _locationCtrller.addStatusListener(_statusListener);
      _isResseting = true;
      await _forward();
    }
  }

  @override
  void updateRadius(double radius) {
    if (_locationTween.isRipple) {
      print('updateRadius');
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
  bool get isAnimating => _locationCtrller.isAnimating;

  @override
  bool get isCompleted => _locationCtrller.isCompleted;

  @override
  bool get isDismissed => _locationCtrller.isDismissed;

  @override
  bool get isCompletedOrDismissed => _locationCtrller.isCompletedOrDismissed;

  @override
  void dispose() {
    description.dispose();
    _locationCtrller
      ..removeStatusListener(_statusListener)
      ..removeListener(_locationListener)
      ..dispose();
    _rippleCtrller
      ..removeStatusListener(_rippleStatusListener)
      ..removeListener(_rippleListener)
      ..dispose();
    //_bearingCtrller.dispose();
  }
}
