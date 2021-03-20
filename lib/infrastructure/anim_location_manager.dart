// Flutter imports:
import 'dart:math';

import 'package:flutter/material.dart';

// Package imports:
import 'package:google_maps_flutter/google_maps_flutter.dart';

// Project imports:
import 'package:flutter_animarker/anims/proxy_location_animation.dart';
import 'package:flutter_animarker/core/i_anim_location_manager.dart';
import 'package:flutter_animarker/anims/location_tween.dart';
import 'package:flutter_animarker/helpers/extensions.dart';
import 'package:flutter_animarker/core/i_lat_lng.dart';
import '../flutter_map_marker_animation.dart';
import 'package:flutter_animarker/helpers/spherical_util.dart';

class AnimLocationManagerImpl implements IAnimLocationManager {
  late final AnimationController _controller;

  late final LatLngListener _latLngListener;
  late final OnAnimCompleted _onAnimCompleted;

  late final LocationTween _locationTween;
  late final BearingTween _bearingTween;

  late final Animation<ILatLng> _locationAnimation;
  late final Animation<double> _bearingAnimation;

  late final ProxyAnimationGeneric<ILatLng> _proxyAnim;
  late final MarkerId _markerId;

  bool _isResseting = false;
  double locationInterval = 0;
  double prevBearing = double.infinity;

  final useRotation;
  final Duration duration;
  final Duration rotationDuration;
  final double angleThreshold;

  AnimLocationManagerImpl({
    this.useRotation = true,
    ILatLng begin = const ILatLng.empty(),
    ILatLng end = const ILatLng.empty(),
    Curve curve = Curves.linear,
    this.angleThreshold = 5.5,
    required MarkerId markerId,
    required TickerProvider vsync,
    required OnAnimCompleted onAnimCompleted,
    required LatLngListener latLngListener,
    this.duration = const Duration(milliseconds: 2000),
    this.rotationDuration = const Duration(milliseconds: 5000),
  }) {
    _markerId = markerId;
    _onAnimCompleted = onAnimCompleted;
    _latLngListener = latLngListener;
    _locationTween = LocationTween(
      begin: begin.copyWith(markerId: _markerId),
      end: end.copyWith(markerId: _markerId),
      shouldBearing: useRotation,
    );
    _bearingTween = BearingTween.from(_locationTween);

    var maxDuration = rotationDuration + duration;

    _controller = AnimationController(vsync: vsync, duration: maxDuration);
    _controller.addListener(_locationListener);
    _controller.addStatusListener(_statusListener);

    locationInterval = (duration.inMilliseconds / maxDuration.inMilliseconds).clamp(0.0, 1.0).toDouble();
    var bottom = (1 - locationInterval).clamp(0.0, 1.0);

    _locationAnimation = _locationTween.animate(
      CurvedAnimation(
        curve: Interval(bottom, 1.0, curve: curve),
        parent: _controller,
      ),
    );

    _bearingAnimation = _bearingTween.animate(
      CurvedAnimation(
        curve: Interval(0.0, bottom, curve: Curves.decelerate),
        parent: _controller,
      ),
    );

    _proxyAnim = ProxyAnimationGeneric<ILatLng>(_locationAnimation);
  }

  @override
  ILatLng get begin => _locationTween.begin.copyWith(markerId: _markerId);

  @override
  set begin(ILatLng value) => _locationTween.begin = value.copyWith(markerId: _markerId);

  @override
  ILatLng get end => _locationTween.end.copyWith(markerId: _markerId);

  @override
  set end(ILatLng value) => _locationTween.end = value.copyWith(markerId: _markerId);

  @override
  ILatLng get value => _proxyAnim.value.copyWith(bearing: _bearingAnimation.value);

  @override
  bool get isAnimating => _controller.isAnimating;

  @override
  bool get isCompleted => _controller.isCompleted;

  @override
  bool get isDismissed => _controller.isDismissed;

  ///Entry point to start animation of location positions if is not a running animation
  ///or the animation is completed or dismissed
  @override
  void forward(ILatLng from) async {
    //Start animation
    if (!from.isEmpty && !isAnimating && _controller.isCompletedOrDismissed) {
      if (_locationTween.isStop) _locationTween.end = from;
      _isResseting = true;
      await _controller.resetAndForward();
    }
  }

  ///Triggered when a location update have been pop from the queue
  @override
  void animateTo(ILatLng next) {
    //If isEmpty (no set) the "begin LatLng" field is ready for animation, delta location required
    if (next.isEmpty) {
      _locationTween.begin = next;
      _locationTween.end = next;

      _bearingTween.computeBearing(0);
      return;
    }

    var startBearing = _locationTween.end - _locationTween.begin;
    var endBearing = next - _locationTween.begin;

    //Setting Location
    _locationTween.begin = _locationTween.end;
    _locationTween.end = next;

    var roof = 1.0 - locationInterval;
    var from = roof;

    var a = SphericalUtil.angleShortestDistance(startBearing, endBearing);

    if (a.abs() > angleThreshold) {
      var angle = _bearingTween.computeBearing(endBearing);

      if (_bearingAnimation.value != prevBearing) {
        var inverse = (1 / angle.abs());
        from = min(inverse, roof);

        prevBearing = _bearingAnimation.value;
      } else {
        print('Same bearing!');
      }
    }

    _isResseting = true;

    _controller.resetAndForward(from: from);
  }

  @override
  void animatePoints(
    List<ILatLng> list, {
    ILatLng last = const ILatLng.empty(),
    Curve curve = Curves.linear,
  }) {
    if (list.isNotEmpty) {
      _controller.removeListener(_locationListener);
      _controller.removeStatusListener(_statusListener);

      var locationTween = LocationTween.multipoint(points: list);
      _locationTween.begin = locationTween.end;
      _locationTween.end = last.isEmpty ? locationTween.end : last;

      var newBearing = _locationTween.end - _locationTween.begin;

      _bearingTween.computeBearing(newBearing);
      _isResseting = true;
      _locationTween.reset();

      _proxyAnim.parent = locationTween.animate(
        CurvedAnimation(
          curve: Interval(0.0, 1.0, curve: curve),
          parent: _controller,
        ),
      );

      _controller.addListener(_locationListener);
      _controller.addStatusListener(_statusListenerPoints);
    }
  }

  void _locationListener() => _latLngListener(value);

  void _statusListener(AnimationStatus status) {
    if (_isResseting) {
      _isResseting = false;
      return;
    }

    if (status.isCompletedOrDismissed) _onAnimCompleted(this);
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
}
