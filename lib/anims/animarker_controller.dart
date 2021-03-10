import 'dart:collection';

import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animarker/core/I_location_tween_factory.dart';
import 'package:flutter_animarker/core/i_lat_lng.dart';
import 'package:flutter_animarker/flutter_map_marker_animation.dart';
import 'package:flutter_animarker/helpers/spherical_util.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../helpers/extensions.dart';
import 'angle_tween.dart';

typedef void MarkerListener(Marker marker);
typedef void RippleListener(Circle circle);
typedef Future<void> OnStopover(LatLng latLng);

class AnimarkerController {
  //Animation Controllers
  late final AnimationController _angleAnimController;
  late final AnimationController _locationAnimController;
  late final AnimationController _rippleAnimController;

  //Variables
  final Color rippleColor;
  final Duration duration;
  final TickerProvider vsync;
  final Duration rippleDuration;
  final Duration rotationDuration;
  late final Map<MarkerId, LocationTween> tracker;
  final ILocationTweenFactory locationTweenFactory;
  late final Queue<Marker> _queueMarker = Queue<Marker>();
  final bool activeTrip;
  final double threshold;
  LatLng previous = LatLng(0, 0);

  //Tweens
  //late final LocationTween _locationTween;
  late final AngleTween _angleTween;
  late final Tween<double> radiusTween;
  late final ColorTween colorTween;

  //Animations
  //late final Animation<ILatLng> _locationAnimation;
  late final Animation<double> _angleAnimation;
  late final Animation<double> radiusAnimation;
  late final Animation<Color> colorAnimation;

  //Callbacks
  final MarkerListener onMarkerAnimation;
  final RippleListener onRippleAnimation;
  final OnStopover onStopover;

  AnimarkerController({
    required this.vsync,
    required this.onMarkerAnimation,
    required this.onRippleAnimation,
    required this.locationTweenFactory,
    required this.onStopover,
    this.threshold = 1.5,
    this.activeTrip = true,
    /**TODO**/
    this.duration = const Duration(milliseconds: 1000),
    this.rotationDuration = const Duration(milliseconds: 10000),
    this.rippleColor = Colors.red,
    this.rippleDuration = const Duration(milliseconds: 2000),
  }) {
    init();
  }

  void init() {
    _locationAnimController = AnimationController(vsync: vsync, duration: duration)
      ..addStatusListener((status) async {
        if (status == AnimationStatus.completed && !_locationAnimController.isDismissed) {
          if (_queueMarker.isNotEmpty) {
            await Future.delayed(
                Duration(milliseconds: 500), () => _generate(_queueMarker.removeFirst()));
          }
        }
      });

    _angleAnimController = AnimationController(vsync: vsync, duration: rotationDuration)
        /*..addStatusListener((status) async {
        if (status == AnimationStatus.completed && !_rippleAnimController.isDismissed) {
          if (_queueMarker.isNotEmpty) {
            await Future.delayed(Duration(milliseconds: 500), () => _generate(_queueMarker.removeFirst()));
          }
        }
      })*/
        ;

    _rippleAnimController = AnimationController(vsync: vsync, duration: rippleDuration);
    /*..addListener(rippleListener)*/

    //Tweens Init
    _angleTween = AngleTween(begin: 0, end: 0);

    _angleAnimation = _angleTween
        .animate(CurvedAnimation(curve: Curves.linearToEaseOut, parent: _angleAnimController));

    radiusTween = Tween<double>(begin: 0, end: 160);

    radiusAnimation = radiusTween
        .animate(CurvedAnimation(curve: Curves.easeOutSine, parent: _rippleAnimController))
          ..addStatusListener(_rippleStatusListener);

    colorAnimation =
        ColorTween(begin: rippleColor.withOpacity(0.6), end: rippleColor.withOpacity(0.0))
            .chain(CurveTween(curve: Curves.ease))
            .animate(_rippleAnimController) as Animation<Color>;

    tracker = Map<MarkerId, LocationTween>();
  }

  void _angleListener(MarkerId markerId) {
    ILatLng location = tracker[markerId]!.evaluate(_locationAnimController);

    Marker marker = Marker(
      markerId: markerId,
      rotation: _angleAnimation.value,
      position: location.toLatLng,
    );

    onMarkerAnimation(marker);
  }

  void _rippleStatusListener(AnimationStatus status) {
    if (_rippleAnimController.status == AnimationStatus.completed &&
        !_rippleAnimController.isDismissed) {
      Future.delayed(Duration(milliseconds: 500), () => _rippleAnimController.forward(from: 0));
    }
  }

  void _rippleListener(MarkerId markerId) {
    ILatLng location = tracker[markerId]!.evaluate(_locationAnimController);

    for (int wave = 3; wave >= 0; wave--) {
      var circleId = CircleId("CircleId->$wave");
      Circle circle = Circle(
        circleId: circleId,
        center: location.toLatLng,
        radius: (radiusAnimation.value * wave),
        fillColor: colorAnimation.value,
        strokeWidth: 1,
        strokeColor:
            colorAnimation.value.withOpacity((colorAnimation.value.opacity + 0.03).clamp(0.0, 1.0)),
      );

      onRippleAnimation(circle);
    }
  }

  void _locationUpdates(MarkerId markerId) async {
    ILatLng location = tracker[markerId]!.evaluate(_locationAnimController);

    Marker marker = Marker(
      markerId: markerId,
      position: location.toLatLng,
    );

    onMarkerAnimation(marker);

    /*if(location.isStopover){
      await onStopover(location.toLatLng);
    }*/
  }

  double lastBearing = 0;
  int thresholdCount = 0;
  Future<void> pushMarker(Marker marker) async {
    if (previous == marker.position) return;

    var bearing = SphericalUtil.getBearing(previous.toLatLngInfo(marker.markerId.value),
        marker.position.toLatLngInfo(marker.markerId.value));

    double delta = bearing - lastBearing;

    if (delta.abs() < threshold) {
      if(_queueMarker.isNotEmpty) _queueMarker.removeLast();
    }

    print("Bearing Delta: ${delta} Count: $thresholdCount");
    _queueMarker.addLast(marker);

    lastBearing = bearing;
    previous = marker.position;

    tracker[marker.markerId] ??= locationTweenFactory.create()
      ..animarker(
        controller: _locationAnimController,
        curve: Curves.linearToEaseOut,
        listener: () {
          _locationUpdates(marker.markerId);
          //_angleListener(marker.markerId);
          _rippleListener(marker.markerId);
        },
      );

    if (_locationAnimController.isDismissed || _locationAnimController.isCompleted) {
      _locationAnimController.reset();
      _locationAnimController.forward();
    }
  }

  void _generate(Marker marker) {
    final location = tracker[marker.markerId]!;

    //If is isEmpty (no set) the "begin LatLng" field is ready for animation, delta location required
    if (location.begin.isEmpty) {
      location.begin = marker.toLatLngInfo;
      location.end = marker.toLatLngInfo;
    } else {
      location.begin = location.end;
      location.end = marker.toLatLngInfo;

      _locationAnimController.reset();
      _locationAnimController.forward();

      _angleTween.begin = _angleAnimation.value;
      _angleTween.end = location.evaluate(_locationAnimController).bearing;

      _angleAnimController.reset();
      _angleAnimController.forward(from: _angleAnimController.value);
    }

    //Control when starts/stops ripple
    if (marker.isRipple &&
        (_rippleAnimController.isCompleted || _rippleAnimController.isDismissed)) {
      _rippleAnimController.forward();
    } else if (_rippleAnimController.isAnimating) {
      _rippleAnimController.reset();
    }
  }

  void dispose() {
    _queueMarker.clear();
    tracker.clear();
    _angleAnimController.dispose();
    _locationAnimController.dispose();
    _rippleAnimController.dispose();
  }
}
