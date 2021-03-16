import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animarker/core/I_location_tween_factory.dart';
import 'package:flutter_animarker/core/i_lat_lng.dart';
import 'package:flutter_animarker/core/i_location_dispatcher.dart';
import 'package:flutter_animarker/core/i_anim_location_manager.dart';
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
  late final AnimationController _rippleAnimController;

  //Variables
  final Color rippleColor;
  final Duration duration;
  final TickerProvider vsync;
  final Duration rippleDuration;
  final Duration rotationDuration;
  final ILocationTweenFactory locationTweenFactory;
  final ILocationDispatcher locationDispatcher;
  late bool _isActiveTrip;
  Map<MarkerId, LatLng> previousPositions = {};
  late final Map<MarkerId, IAnimLocationManager> tracker;

  //Tweens
  //late final LocationTween _locationTween;
  late final AngleTween _angleTween;
  late final Tween<double> _radiusTween;

  //Animations
  //late final Animation<ILatLng> _locationAnimation;
  late final Animation<double> _angleAnimation;
  late final Animation<double> radiusAnimation;
  late final Animation<Color> colorAnimation;

  //Callbacks
  final MarkerListener onMarkerAnimation;
  final RippleListener onRippleAnimation;
  final OnStopover onStopover;
  double mapScale = 0.05;
  bool isResseting = false;

  AnimarkerController({
    required this.vsync,
    required this.onMarkerAnimation,
    required this.onRippleAnimation,
    required this.locationTweenFactory,
    required this.locationDispatcher,
    required this.onStopover,
    bool isActiveTrip = true,
    this.duration = const Duration(milliseconds: 1000),
    this.rotationDuration = const Duration(milliseconds: 10000),
    this.rippleColor = Colors.red,
    this.rippleDuration = const Duration(milliseconds: 2000),
  }) : _isActiveTrip = isActiveTrip {
    init();
  }

  void init() {
    _angleAnimController = AnimationController(vsync: vsync, duration: rotationDuration);

    _rippleAnimController = AnimationController(vsync: vsync, duration: rippleDuration);

    //Tweens Init
    _angleTween = AngleTween(begin: 0, end: 0);

    _angleAnimation = _angleTween
        .animate(CurvedAnimation(curve: Curves.linearToEaseOut, parent: _angleAnimController));

    _radiusTween = Tween<double>(begin: 0, end: 1.0);

    radiusAnimation = _radiusTween
        .animate(CurvedAnimation(curve: Curves.easeOutSine, parent: _rippleAnimController))
          ..addStatusListener(_rippleStatusListener);

    colorAnimation =
        ColorTween(begin: rippleColor.withOpacity(0.6), end: rippleColor.withOpacity(0.0))
            .chain(CurveTween(curve: Curves.ease))
            .animate(_rippleAnimController) as Animation<Color>;

    tracker = Map<MarkerId, IAnimLocationManager>();
  }

  set isActiveTrip(bool value) => _isActiveTrip = value;

  void _angleListener(ILatLng location) {
    Marker marker = Marker(
      markerId: location.markerId!,
      rotation: _angleAnimation.value,
      position: location.toLatLng,
    );

    onMarkerAnimation(marker);
  }

  void _rippleStatusListener(AnimationStatus status) async {
    if (_rippleAnimController.isCompleted && !_rippleAnimController.isDismissed) {
      if (locationDispatcher.isNotEmpty) {
        Future.delayed(Duration(milliseconds: 500), () => _rippleAnimController.forward(from: 0));
      }
    }
  }

  void _rippleListener(ILatLng location) {
    var radius = (radiusAnimation.value / 100) / mapScale;

    var opacity = colorAnimation.value.opacity;
    var color = colorAnimation.value.withOpacity((opacity + 0.03).clamp(0.0, 1.0));

    for (int wave = 3; wave >= 0; wave--) {
      var circleId = CircleId("CircleId->$wave");
      Circle circle = Circle(
        circleId: circleId,
        center: location.toLatLng,
        radius: radius * wave,
        fillColor: colorAnimation.value,
        strokeWidth: 1,
        strokeColor: color,
      );

      onRippleAnimation(circle);
    }
  }

  void updateZoomLevel(double density, double radiusScale, double zoomLevel) {
    tracker.forEach((k, v) {
      mapScale = SphericalUtil.calculateZoomScale(density, zoomLevel, v.begin);
    });

    _radiusTween.end = radiusScale.clamp(0.0, 1.0);
    _rippleAnimController.resetAndForward();
  }

  void _locationListener(ILatLng location) async {
    Marker marker = Marker(
      markerId: location.markerId!,
      position: location.toLatLng,
    );

    onMarkerAnimation(marker);

    if (location.isStopover) {
      await onStopover(location.toLatLng);
    }
  }

  void pushMarker(Marker marker) async {
    if (!_isActiveTrip) return;
    if (previousPositions[marker.markerId] == marker.position) return;

    ILatLng position = marker.toLatLngInfo();

    locationDispatcher.push(position);

    tracker[marker.markerId] ??= locationTweenFactory.create(
      vsync: vsync,
      markerId: marker.markerId,
      onAnimCompleted: _animCompleted,
      latLngListener: _latLngListener,
    );

    var animWrapper = tracker[marker.markerId]!;

    //Start animation
    if (!animWrapper.isAnimating && (animWrapper.isDismissed || animWrapper.isCompleted)) {
      animWrapper.resetAndForward();
    }

    previousPositions[marker.markerId] = marker.position;
  }

  void _latLngListener(ILatLng latLng){
    _locationListener(latLng);
    _angleListener(latLng);
    _rippleListener(latLng);
  }

  void _animCompleted(IAnimLocationManager anim) {

    if (locationDispatcher.isNotEmpty) {
      ILatLng next;

      if (_isActiveTrip) {
        next = locationDispatcher.next();
      } else {
        next = locationDispatcher.goTo(locationDispatcher.length - 1);
      }

      _generate(anim, next);
    }
  }

  void _generate(IAnimLocationManager anim, ILatLng marker) {

    if(!marker.isEmpty){
      _angleTween.begin = _angleAnimation.value;
      _angleTween.end = anim.animateTo(marker).bearing;

      _angleAnimController.resetAndForward(from: _angleAnimController.value);
    }

    //If this is last element in the queue
    if(locationDispatcher.isEmpty) _rippleAnimController.reset();
  }

  void dispose() {
    previousPositions.clear();
    tracker.clear();
    locationDispatcher.dispose();
    _angleAnimController.dispose();
    _rippleAnimController.dispose();
  }
}
