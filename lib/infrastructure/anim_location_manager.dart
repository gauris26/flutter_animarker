import 'package:flutter/material.dart';
import 'package:flutter_animarker/anims/proxy_location_animation.dart';
import 'package:flutter_animarker/core/i_lat_lng.dart';
import 'package:flutter_animarker/helpers/extensions.dart';
import 'package:flutter_animarker/models/lat_lng_info.dart';
import 'package:flutter_animarker/anims/location_tween.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_animarker/core/i_anim_location_manager.dart';
import 'package:flutter_animarker/core/i_animation_mode.dart';

import '../flutter_map_marker_animation.dart';

typedef LatLngListener = void Function(ILatLng iLatLng);

typedef OnAnimCompleted = void Function(IAnimationMode anim);

class AnimLocationManagerImpl implements IAnimLocationManager {
  late final AnimationController _controller;
  late final AnimationController _angleController;

  late final LatLngListener _latLngListener;
  late final OnAnimCompleted _onAnimCompleted;

  late final LocationTween _locationTween;
  late final AngleTween _angleTween;

  late final Animation<ILatLng> _animation;
  late final Animation<double> _angleAnimation;

  late final ProxyAnimationGeneric<ILatLng> _proxyAnim;
  late final MarkerId _markerId;

  bool _isResseting = false;

  final useRotation;
  final Duration duration;
  final Duration rotationDuration;

  AnimLocationManagerImpl({
    this.useRotation = true,
    ILatLng begin = const LatLngInfo.empty(),
    ILatLng end = const LatLngInfo.empty(),
    Curve curve = Curves.linear,
    required MarkerId markerId,
    required TickerProvider vsync,
    required OnAnimCompleted onAnimCompleted,
    required LatLngListener latLngListener,
    this.duration = const Duration(milliseconds: 2000),
    this.rotationDuration = const Duration(milliseconds: 10000),
  }) {
    _markerId = markerId;
    _onAnimCompleted = onAnimCompleted;
    _latLngListener = latLngListener;
    _locationTween = LocationTween(
      begin: begin.copyWith(markerId: _markerId),
      end: end.copyWith(markerId: _markerId),
      shouldBearing: useRotation,
    );

    _controller = AnimationController(vsync: vsync, duration: duration);
    _angleController = AnimationController(vsync: vsync, duration: rotationDuration);

    _animation = _locationTween.animate(
      CurvedAnimation(curve: curve, parent: _controller),
    )
      ..addListener(_locationListener)
      ..addStatusListener(_statusListener);

    _angleTween = AngleTween(begin: 0, end: 0);

    _angleAnimation = _angleTween.animate(
      CurvedAnimation(curve: Curves.linearToEaseOut, parent: _angleController),
    )..addListener(_locationListener);

    _proxyAnim = ProxyAnimationGeneric<ILatLng>(_animation);
  }

  void _locationListener() => _latLngListener(value.copyWith(bearing: _angleAnimation.value));

  void _statusListener(AnimationStatus status) {
    if (_isResseting) {
      _isResseting = false;
      return;
    }

    if (status.isCompletedOrDismissed) _onAnimCompleted(this);
  }

  @override
  ILatLng get begin => _locationTween.begin;

  @override
  set begin(ILatLng value) => _locationTween.begin = value.copyWith(markerId: _markerId);

  @override
  ILatLng get end => _locationTween.end;

  @override
  set end(ILatLng value) => _locationTween.end = value.copyWith(markerId: _markerId);

  @override
  ILatLng get value => _proxyAnim.value;

  @override
  void animateTo(ILatLng next) {
    //If isEmpty (no set) the "begin LatLng" field is ready for animation, delta location required
    if (next.isEmpty) {
      _locationTween.begin = next;
      _locationTween.end = next;
    }

    //Setting Location
    _locationTween.begin = _locationTween.end;
    _locationTween.end = next;
    _isResseting = true;
    _controller.resetAndForward();

    _angleTween.begin = _angleAnimation.value;
    _angleTween.end =   _animation.value.bearing;

    _angleController.resetAndForward(from: _angleController.value);
  }

  @override
  bool get isAnimating => _controller.isAnimating;

  @override
  bool get isCompleted => _controller.isCompleted;

  @override
  bool get isDismissed => _controller.isDismissed;

  void _statusListenerPoints(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _proxyAnim.parent!.removeStatusListener(_statusListenerPoints);
      _proxyAnim.parent!.removeListener(_locationListener);
      _isResseting = true;
      _controller.reset();
      _proxyAnim.parent = _animation
        ..addListener(_locationListener)
        ..addStatusListener(_statusListener);
      _controller.resetAndForward();
      _angleController.resetAndForward();
    }
  }

  @override
  void animatePoints(
    List<ILatLng> list, {
    ILatLng last = const LatLngInfo.empty(),
    Curve curve = Curves.linear,
  }) {
    if (list.isNotEmpty) {
      _animation.removeListener(_locationListener);
      _animation.removeStatusListener(_statusListener);
      _angleAnimation.removeListener(_locationListener);

      var locationTween = LocationTween.multipoint(points: list);
      _locationTween.begin = locationTween.end;
      _locationTween.end = last.isEmpty ? locationTween.end : last;
      _isResseting = true;
      _locationTween.reset();

      _proxyAnim.parent = locationTween.animate(CurvedAnimation(curve: curve, parent: _controller))
        ..addListener(_locationListener)
        ..addStatusListener(_statusListenerPoints);

      _angleAnimation.addListener(_locationListener);
    }
  }

  @override
  void dispose() {
    _controller.removeStatusListener(_statusListener);
    _controller.removeListener(_locationListener);
    _angleAnimation.removeListener(_locationListener);
    _angleController.dispose();
    _controller.dispose();
  }

  @override
  void play() {
    //Start animation
    if (!isAnimating && _controller.isCompletedOrDismissed) {
      _controller.resetAndForward();
      _angleController.resetAndForward();
    }
  }
}
