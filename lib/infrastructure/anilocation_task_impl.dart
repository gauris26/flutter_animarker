// Flutter imports:
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animarker/animation/bearing_tween.dart';
import 'package:flutter_animarker/core/anilocation_task_description.dart';
import 'package:flutter_animarker/infrastructure/interpolators/line_location_interpolator_impl.dart';

// Project imports:
import 'package:flutter_animarker/animation/proxy_location_animation.dart';
import 'package:flutter_animarker/core/i_anilocation_task.dart';
import 'package:flutter_animarker/animation/location_tween.dart';
import 'package:flutter_animarker/helpers/extensions.dart';
import 'package:flutter_animarker/core/i_lat_lng.dart';
import 'package:flutter_animarker/helpers/spherical_util.dart';
import 'interpolators/polynomial_location_interpolator_impl.dart';

class AnilocationTaskImpl implements IAnilocationTask {
  late final AnimationController _controller;

  late final LocationTween _locationTween;
  late final BearingTween _bearingTween;

  late final Animation<ILatLng> _locationAnimation;
  late final Animation<double> _bearingAnimation;

  late final ProxyAnimationGeneric<ILatLng> _proxyAnim;

  bool _isResseting = false;

  AnilocationTaskDescription description;

  AnilocationTaskImpl({required this.description}) {
    _locationTween = LocationTween(
      interpolator: LineLocationInterpolatorImpl(
        begin: description.begin.copyWith(markerId: description.markerId),
        end: description.end.copyWith(markerId: description.markerId),
      ),
    );

    _bearingTween = BearingTween.from(_locationTween);

    _controller = AnimationController(
      vsync: description.vsync,
      duration: description.maxDuration,
    );

    _controller.addListener(_locationListener);
    _controller.addStatusListener(_statusListener);

    var bottom = (1 - description.locationInterval).clamp(0.0, 1.0);

    _locationAnimation = _locationTween.animate(
      CurvedAnimation(
        curve: Interval(bottom, 1.0, curve: description.curve),
        parent: _controller,
      ),
    );

    if (description.useRotation) {
      _bearingAnimation = _bearingTween.animate(
        CurvedAnimation(
          curve: Interval(0.0, bottom, curve: Curves.decelerate),
          parent: _controller,
        ),
      );
    } else {
      _bearingAnimation = AlwaysStoppedAnimation(0);
    }

    _proxyAnim = ProxyAnimationGeneric<ILatLng>(_locationAnimation);
  }

  ///Entry point to start animation of location positions if is not a running animation
  ///or the animation is completed or dismissed
  @override
  void forward(ILatLng from) async {
    if (_locationTween.interpolator.isStopped && _locationTween.interpolator.end == from) {
      _locationTween.interpolator.begin = from;
      _bearingTween.interpolator.begin = 0;
      return;
    } else {
      _locationTween.interpolator.swap(from);
      var angle = _locationTween.end - _locationTween.begin;
      _bearingTween.interpolator.swap(angle);
    }

    //Start animation
    if (!from.isEmpty && !isAnimating && _controller.isCompletedOrDismissed) {
      _isResseting = true;
      await _controller.resetAndForward();
    }
  }

  ///Triggered when a location update have been pop from the queue
  @override
  void animateTo(ILatLng next) {
    //If isEmpty (no set) the "begin LatLng" field is ready for animation, delta location required
    if (next.isEmpty) {
      return;
    }

    if (_locationTween.interpolator.isStopped) {
      _locationTween.interpolator.begin = next;
      _bearingTween.interpolator.end = 0;
      return;
    }

    var startBearing = _locationTween.end - _locationTween.begin;
    var endBearing = next - _locationTween.begin;

    //Setting Location
    _locationTween.interpolator.swap(next);

    var startFrom = 1.0 - description.locationInterval;

    var shortestAngle = SphericalUtil.angleShortestDistance(startBearing, endBearing).abs();

    if (shortestAngle > description.angleThreshold) {
      _bearingTween.interpolator.swap(endBearing);

      var angle = _bearingTween.shortestAngleBetween.abs();

      var inverse = (1 / angle.abs());

      startFrom = min(inverse, startFrom);
    }

    _isResseting = true;

    _controller.resetAndForward(from: startFrom);
  }

  @override
  void animatePoints(List<ILatLng> list,
      {ILatLng last = const ILatLng.empty(), Curve curve = Curves.linear}) {
    if (list.isNotEmpty) {
      _controller.removeListener(_locationListener);
      _controller.removeStatusListener(_statusListener);

      var multiPoint = LocationTween(interpolator: PolynomialLocationInterpolator(points: list));

      _locationTween.interpolator.swap(last);

      var newBearing = _locationTween.end - _locationTween.begin;

      _bearingTween.interpolator.swap(newBearing);

      _isResseting = true;

      _proxyAnim.parent = multiPoint.animate(
        CurvedAnimation(curve: Interval(0.0, 1.0, curve: curve), parent: _controller),
      );
      _controller.addListener(_locationListener);
      _controller.addStatusListener(_statusListenerPoints);
    }
  }

  void _locationListener() {
    if (_isResseting) {
      _isResseting = false;
      return;
    }

    debugPrint('${value.bearing}: ${value.toLatLng} isStopover: ${value.isStopover} isRotation: ${_controller.value}');
    if (description.latLngListener != null) {
      description.latLngListener!(value);
    }
  }

  void _statusListener(AnimationStatus status) {
    print(status);
    if (_isResseting) {
      _isResseting = false;
      return;
    }

    if (status.isCompletedOrDismissed && description.onAnimCompleted != null) {
      print('onAnimCompleted');
      description.onAnimCompleted!(this);
    }
  }

  void _statusListenerPoints(AnimationStatus status) async {
    if (status == AnimationStatus.completed) {
      _proxyAnim.parent!.removeStatusListener(_statusListenerPoints);
      _proxyAnim.parent!.removeListener(_locationListener);
      _isResseting = true;
      _proxyAnim.parent = _locationAnimation
        ..addListener(_locationListener)
        ..addStatusListener(_statusListener);
      await _controller.resetAndForward();
    }
  }

  @override
  void dispose() {
    _controller.removeStatusListener(_statusListener);
    _controller.removeListener(_locationListener);
    _controller.dispose();
  }

  @override
  ILatLng get value => _proxyAnim.value.copyWith(bearing: _bearingAnimation.value);

  @override
  bool get isAnimating => _controller.isAnimating;

  @override
  bool get isCompleted => _controller.isCompleted;

  @override
  bool get isDismissed => _controller.isDismissed;
}
