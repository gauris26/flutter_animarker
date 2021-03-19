// Flutter imports:
import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:google_maps_flutter/google_maps_flutter.dart';

// Project imports:
import 'package:flutter_animarker/core/i_location_tween_factory.dart';
import 'package:flutter_animarker/core/i_anim_location_manager.dart';
import 'package:flutter_animarker/core/i_animarker_controller.dart';
import 'package:flutter_animarker/core/i_animation_mode.dart';
import 'package:flutter_animarker/core/i_lat_lng.dart';
import 'package:flutter_animarker/core/i_location_dispatcher.dart';
import 'package:flutter_animarker/flutter_map_marker_animation.dart';
import 'package:flutter_animarker/helpers/spherical_util.dart';
import 'package:flutter_animarker/infrastructure/animarker_location_listener.dart';
import 'package:flutter_animarker/infrastructure/animarker_ripple_listener.dart';
import '../helpers/extensions.dart';

class AnimarkerController extends IAnimarkerController
    with AnimarkerRippleListenerMixin, AnimarkerLocationListenerMixin {
  //Animation Controllers
  late final AnimationController _rippleAnimController;

  //Final Variables
  final Color rippleColor;
  final Duration duration;
  final int purgeLimit;
  final TickerProvider vsync;
  final Duration rippleDuration;
  final Duration rotationDuration;
  final ILocationTweenFactory locationTweenFactory;
  final ILocationDispatcher locationDispatcher;
  final Map<MarkerId, LatLng> _previousPositions = {};

  //Late Variables
  late bool _isActiveTrip;

  //Late Final Variables
  late final Map<MarkerId, IAnimLocationManager> tracker;
  late final RippleListener _onRippleAnimation;

  //Tweens
  late final Tween<double> _radiusTween;

  //Animations
  late final Animation<double> _radiusAnimation;
  late final Animation<Color?> _colorAnimation;

  //Callbacks
  @override
  final MarkerListener onMarkerAnimation;
  @override
  final OnStopover onStopover;

  //Variables
  double _zoomScale = 0.05;
  bool isResseting = false;

  //Getter
  @override
  double get zoomScale => _zoomScale;
  @override
  double get radiusValue => _radiusAnimation.value;
  @override
  Color get colorValue => _colorAnimation.value!;
  @override
  bool get isQueueEmpty => locationDispatcher.isEmpty;
  @override
  bool get isQueueNotEmpty => locationDispatcher.isNotEmpty;
  @override
  // ignore: unnecessary_getters_setters
  bool get isActiveTrip => _isActiveTrip;

  @override
  // ignore: unnecessary_getters_setters
  RippleListener get onRippleAnimation => _onRippleAnimation;

  @override
  AnimationController get rippleController => _rippleAnimController;

  //Setter
  @override
  // ignore: unnecessary_getters_setters
  set isActiveTrip(bool value) => _isActiveTrip = value;

  @override
  // ignore: unnecessary_getters_setters
  set onRippleAnimation(RippleListener value) => _onRippleAnimation = value;

  AnimarkerController({
    required RippleListener onRippleAnimation,
    required this.vsync,
    required this.onMarkerAnimation,
    required this.locationTweenFactory,
    required this.locationDispatcher,
    required this.onStopover,
    this.purgeLimit = 10,
    this.rippleColor = Colors.red,
    this.duration = const Duration(milliseconds: 1000),
    this.rotationDuration = const Duration(milliseconds: 10000),
    this.rippleDuration = const Duration(milliseconds: 2000),
    bool isActiveTrip = true,
  }) : _isActiveTrip = isActiveTrip {
    _onRippleAnimation = onRippleAnimation;

    _rippleAnimController = AnimationController(vsync: vsync, duration: rippleDuration);

    _radiusTween = Tween<double>(begin: 0, end: 1.0);

    _radiusAnimation = _radiusTween.animate(CurvedAnimation(
      curve: Curves.easeOutSine,
      parent: _rippleAnimController,
    ))
      ..addStatusListener(rippleStatusListener);

    _colorAnimation = ColorTween(
      begin: rippleColor.withOpacity(1.0),
      end: rippleColor.withOpacity(0.0),
    ).animate(CurvedAnimation(curve: Curves.ease, parent: _rippleAnimController));

    tracker = <MarkerId, IAnimLocationManager>{};
  }

  @override
  void updateZoomLevel(double d, double r, double z) {
    tracker.forEach((k, v) {
      _zoomScale = SphericalUtil.calculateZoomScale(d, z, v.begin);
    });

    _radiusTween.end = r.clamp(0.0, 1.0);
    _rippleAnimController.resetAndForward();
  }

  @override
  void pushMarker(Marker marker) {
    if (!_isActiveTrip) return;
    if (_previousPositions[marker.markerId] == marker.position) return;

    locationDispatcher.push(marker.toLatLngInfo());

    // Animation Marker Manager Factory
    tracker[marker.markerId] ??= IAnimLocationManager.create(
      vsync: vsync,
      useRotation: true,
      markerId: marker.markerId,
      curve: Curves.linearToEaseOut,
      onAnimCompleted: _animCompleted,
      latLngListener: _latLngListener,
    );

    tracker[marker.markerId]!.play();

    _previousPositions[marker.markerId] = marker.position;
  }

  void _latLngListener(ILatLng latLng) {
    locationListener(latLng);
    rippleListener(latLng);
  }

  void _animCompleted(IAnimationMode anim) {
    if (locationDispatcher.isNotEmpty) {
/*      if (locationDispatcher.length >= purgeLimit) {
        var lastValue = locationDispatcher.popLast;
        anim.animatePoints(locationDispatcher.values, last: lastValue);

        locationDispatcher.clear();

        return;
      }*/

      ILatLng next;

      if (_isActiveTrip) {
        next = locationDispatcher.next();
      } else {
        next = locationDispatcher.goTo(locationDispatcher.length - 1);
      }

      anim.animateTo(next);
      if (locationDispatcher.isEmpty) _rippleAnimController.reset();
    }
  }

  @override
  void dispose() {
    tracker.forEach((key, value) => value.dispose());
    tracker.clear();
    _radiusAnimation.removeStatusListener(rippleStatusListener);
    _previousPositions.clear();
    locationDispatcher.dispose();
    _rippleAnimController.dispose();
  }
}
