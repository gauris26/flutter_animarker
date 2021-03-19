// Flutter imports:
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

class AnimLocationManagerImpl implements IAnimLocationManager {
  late final AnimationController _controller;
  late final AnimationController _bearingController;

  late final LatLngListener _latLngListener;
  late final OnAnimCompleted _onAnimCompleted;

  late final LocationTween _locationTween;
  late final BearingTween _bearingTween;

  late final Animation<ILatLng> _locationAnimation;
  //late final Animation<double> _bearingAnimation;

  late final ProxyAnimationGeneric<ILatLng> _proxyAnim;
  late final MarkerId _markerId;

  bool _isResseting = false;
  //bool _isRessetingBearing = false;

  final useRotation;
  final Duration duration;
  final Duration rotationDuration;

  AnimLocationManagerImpl({
    this.useRotation = true,
    ILatLng begin = const ILatLng.empty(),
    ILatLng end = const ILatLng.empty(),
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
    _bearingTween = BearingTween.from(_locationTween);

    var totalDuration = duration + rotationDuration;
    _controller = AnimationController(vsync: vsync, duration: totalDuration);
    //_bearingController = AnimationController(vsync: vsync, duration: rotationDuration);


    _locationAnimation = _locationTween.chain(parent).animate(
      CurvedAnimation(curve: Interval(0.0, (duration.inMilliseconds / totalDuration.inMilliseconds).clamp(0.0, 1.0), curve: curve), parent: _controller),
    )
      /*..addListener(_locationListener)*/
      ..addStatusListener(_statusListener);



    /*TODO*/
    _bearingAnimation = _bearingTween.animate(
      CurvedAnimation(curve: Curves.linearToEaseOut, parent: _controller),
    )..addListener(_angleListener)
    ..addStatusListener(_statusBearingListener);

    _proxyAnim = ProxyAnimationGeneric<ILatLng>(_locationAnimation);
  }

  void _locationListener() => _latLngListener(value);

  void _angleListener() => _latLngListener(value);

  void _statusListener(AnimationStatus status) {
    if (_isResseting) {
      _isResseting = false;
      return;
    }

    if (status.isCompletedOrDismissed) _onAnimCompleted(this);
  }

  void _statusBearingListener(AnimationStatus status) {
    /*if (_isRessetingBearing) {
      _isRessetingBearing = false;
      return;
    }*/

    //if (status.isCompletedOrDismissed) _bearingController.resetAndForward();
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

  ///Triggered when a location update have been pop from the queue
  @override
  void animateTo(ILatLng next) {
    //If isEmpty (no set) the "begin LatLng" field is ready for animation, delta location required
    if (next.isEmpty) {
      _locationTween.begin = next;
      _locationTween.end = next;

      _bearingTween.computeBearing(next, next);
      return;
    }

    //Setting Location
    _locationTween.begin = _locationTween.end;
    _locationTween.end = next;

    print('Delta: ${_locationTween.begin.toLatLng}, ${_locationTween.end.toLatLng}');
    _bearingTween.computeBearing(_locationTween.begin, _locationTween.end);

    _isResseting = true;
    _isRessetingBearing = true;
    _controller.resetAndForward();
    _controller.resetAndForward(from: 0);
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
      _proxyAnim.parent = _locationAnimation
        ..addListener(_locationListener)
        ..addStatusListener(_statusListener);
      _controller.resetAndForward();
      _bearingController.resetAndForward();
    }
  }

  @override
  void animatePoints(
    List<ILatLng> list, {
    ILatLng last = const ILatLng.empty(),
    Curve curve = Curves.linear,
  }) {
    if (list.isNotEmpty) {
      _locationAnimation.removeListener(_locationListener);
      _locationAnimation.removeStatusListener(_statusListener);
      _bearingAnimation.removeListener(_angleListener);

      var locationTween = LocationTween.multipoint(points: list);
      _locationTween.begin = locationTween.end;
      _locationTween.end = last.isEmpty ? locationTween.end : last;

      _isResseting = true;
      _locationTween.reset();

      _proxyAnim.parent = locationTween.animate(CurvedAnimation(curve: curve, parent: _controller))
        ..addListener(_locationListener)
        ..addStatusListener(_statusListenerPoints);

      _bearingAnimation.addListener(_angleListener);
    }
  }

  ///Entry point to start animation of location positions if is not a running animation
  ///or the animation is completed or dismissed
  @override
  void play() async {
    //Start animation
    if (!isAnimating && _controller.isCompletedOrDismissed) {
      _isResseting = true;
      _isRessetingBearing = true;
      await _controller.resetAndForward();
      await _bearingController.resetAndForward();
    }
  }

  @override
  void dispose() {
    _controller.removeStatusListener(_statusListener);
    _controller.removeListener(_locationListener);
    _bearingAnimation.removeListener(_angleListener);
    _bearingController.removeStatusListener(_statusBearingListener);
    _bearingController.dispose();
    _controller.dispose();
  }
}
