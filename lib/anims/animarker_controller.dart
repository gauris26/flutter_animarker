import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animarker/core/I_location_tween_factory.dart';
import 'package:flutter_animarker/core/i_lat_lng.dart';
import 'package:flutter_animarker/core/i_location_dispatcher.dart';
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
  final ILocationDispatcher locationDispatcher;
  late bool _isActiveTrip;
  LatLng previousPosition = LatLng(0, 0);

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
  })  : _isActiveTrip = isActiveTrip {
    init();
  }

  void init() {

    _locationAnimController = AnimationController(vsync: vsync, duration: duration)
      ..addStatusListener((status) {
        if (isResseting) {
          print("Resseting: ${_locationAnimController.status}");
          isResseting = false;
          return;
        }
        if (status == AnimationStatus.completed || _locationAnimController.isDismissed) {
          if (locationDispatcher.isNotEmpty) {
            var next = locationDispatcher.next();
            if (_isActiveTrip) {
              _generate(next);
            } else {
              var last = locationDispatcher.goTo(locationDispatcher.length - 1);
              _generate(last);
            }
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

    tracker = Map<MarkerId, LocationTween>();
  }

  set isActiveTrip(bool value) => _isActiveTrip = value;

  void _angleListener(MarkerId markerId) {
    ILatLng location = tracker[markerId]!.evaluate(_locationAnimController);

    Marker marker = Marker(
      markerId: markerId,
      rotation: _angleAnimation.value,
      position: location.toLatLng,
    );

    onMarkerAnimation(marker);
  }

  void _rippleStatusListener(AnimationStatus status) async {
    if (_rippleAnimController.isCompleted &&
        !_rippleAnimController.isDismissed) {
      Future.delayed(Duration(milliseconds: 500), () => _rippleAnimController.forward(from: 0));
    }
  }

  void updateZoomLevel(double density, double radiusScale, double zoomLevel) {

    tracker.forEach((k, v) {
      mapScale = SphericalUtil.calculateZoomScale(density, zoomLevel, v.begin);
    });

    _radiusTween.end = radiusScale.clamp(0.0, 1.0);
    _rippleAnimController.reset();
    _rippleAnimController.forward();
  }

  void _rippleListener(MarkerId markerId) {

    ILatLng location = tracker[markerId]!.evaluate(_locationAnimController);

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

  void _locationUpdates(MarkerId markerId) async {

    ILatLng location = tracker[markerId]!.evaluate(_locationAnimController);

    Marker marker = Marker(
      markerId: markerId,
      position: location.toLatLng,
    );

    onMarkerAnimation(marker);

    if (location.isStopover) {
      await onStopover(location.toLatLng);
    }
  }

  void pushMarker(Marker marker) async {
    if (!_isActiveTrip) return;
    if(previousPosition == marker.position) return;


    ILatLng position = marker.toLatLngInfo();

    locationDispatcher.push(position);

    tracker[marker.markerId] ??= locationTweenFactory.create()
      ..animarker(
        controller: _locationAnimController,
        curve: Curves.ease,
        listener: () {
          _locationUpdates(marker.markerId);
          _angleListener(marker.markerId);
          _rippleListener(marker.markerId);
        },
      );

    //Start animation
    if (!_locationAnimController.isAnimating &&
        (_locationAnimController.isDismissed || _locationAnimController.isCompleted)
    ) {
      _locationAnimController.resetAndForward();
    }

    previousPosition = marker.position;
  }

  void _generate(ILatLng marker) {
    if (!tracker.containsKey(marker.markerId)) return;

    final location = tracker[marker.markerId]!;

    //If is isEmpty (no set) the "begin LatLng" field is ready for animation, delta location required
    if (location.begin.isEmpty) {
      location.begin = marker;
      location.end = marker;
    } else {
      location.begin = location.end;
      location.end = marker;

      isResseting = true;
      _locationAnimController.resetAndForward();

      _angleTween.begin = _angleAnimation.value;
      _angleTween.end = location.evaluate(_locationAnimController).bearing;

      _angleAnimController.reset();
      _angleAnimController.forward(from: _angleAnimController.value);
    }

    //Control when starts/stops ripple
    /*if (marker.ripple && !_rippleAnimController.isAnimating) {
      _rippleAnimController.forward();
    } else if (_rippleAnimController.isAnimating) {
      _rippleAnimController.reset();
    }*/
  }



  void dispose() {
    previousPosition = LatLng(0, 0);
    tracker.clear();
    locationDispatcher.dispose();
    _angleAnimController.dispose();
    _locationAnimController.dispose();
    _rippleAnimController.dispose();
  }
}
