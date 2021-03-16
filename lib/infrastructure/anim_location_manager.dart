import 'package:flutter/material.dart';
import 'package:flutter_animarker/anims/location_tween.dart';
import 'package:flutter_animarker/core/i_anim_location_manager.dart';
import 'package:flutter_animarker/core/i_lat_lng.dart';
import 'package:flutter_animarker/models/lat_lng_info.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_animarker/helpers/extensions.dart';

typedef void LatLngListener(ILatLng iLatLng);

typedef void OnAnimCompleted(IAnimLocationManager anim);

class AnimLocationManagerImpl implements IAnimLocationManager {
  late final AnimationController _controller;
  late final LatLngListener _latLngListener;
  late final OnAnimCompleted _onAnimCompleted;
  late final LocationTween _locationTween;
  late final Animation<ILatLng> _animation;
  late final MarkerId _markerId;
  bool _isResseting = false;
  final Duration duration;
  final useRotation;

  AnimLocationManagerImpl({
    required MarkerId markerId,
    required TickerProvider vsync,
    required OnAnimCompleted onAnimCompleted,
    required LatLngListener latLngListener,
    this.useRotation = true,
    this.duration = const Duration(milliseconds: 1000),
    ILatLng begin = const LatLngInfo.empty(),
    ILatLng end = const LatLngInfo.empty(),
    Curve curve: Curves.linear,
  }) {
    _markerId = markerId;
    _onAnimCompleted = onAnimCompleted;
    _latLngListener = latLngListener;
    _locationTween = LocationTween(begin: begin, end: end, shouldBearing: useRotation);

    _controller = AnimationController(vsync: vsync, duration: duration)
      ..addStatusListener(_statusListener);

    _animation = _locationTween.animate(CurvedAnimation(curve: curve, parent: _controller))
      ..addListener(() => _latLngListener(this.value));
  }

  void _statusListener(AnimationStatus status) {
    if (_isResseting) {
      _isResseting = false;
      return;
    }

    if (status == AnimationStatus.completed || status == AnimationStatus.dismissed)
      _onAnimCompleted(this);
  }

  @override
  ILatLng get begin => _locationTween.begin;

  set begin(ILatLng value) => _locationTween.begin = value;

  @override
  ILatLng get end => _locationTween.end;

  set end(ILatLng value) => _locationTween.end = value;

  @override
  ILatLng get value => _animation.value.copyWith(markerId: _markerId);

  TickerFuture resetAndForward({double? from}) {
    _controller.reset();
    return _controller.forward(from: from);
  }

  ILatLng animateTo(ILatLng next){

    //If is isEmpty (no set) the "begin LatLng" field is ready for animation, delta location required
    if (next.isEmpty) {
      _locationTween.begin = next;
      _locationTween.end = next;
      return _animation.value;
    }

    _locationTween.begin = _locationTween.end;
    _locationTween.end = next;
    _isResseting = true;
    _controller.resetAndForward();

    return _animation.value;
  }

  bool get isAnimating => _controller.isAnimating;

  bool get isCompleted => _controller.isCompleted;

  bool get isDismissed => _controller.isDismissed;

  @override
  void dispose() {
    _controller.removeStatusListener(_statusListener);
    _controller.dispose();
  }
}
