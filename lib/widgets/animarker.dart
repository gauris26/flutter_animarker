import 'package:flutter_animarker/core/performance_mode.dart';
import 'package:flutter_animarker/helpers/google_map_helper.dart';
import 'package:flutter_animarker/models/lat_lng_info.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import '../anims/location_tween.dart';
import '../anims/angle_tween.dart';
import '../core/i_lat_lng.dart';
import '../flutter_map_marker_animation.dart';
import '../helpers/extensiones.dart';

///Google Maps widget wrappper for animation activities
@immutable
class Animarker extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration rippleDuration;
  final Duration rotationDuration;
  final Set<Marker> markers;
  final Color rippleColor;
  final PerformanceMode performanceMode;
  final Future<GoogleMapController> controller;
  final bool useMarkerRotation;

  Animarker({
    required this.child,
    required this.controller,
    this.markers = const <Marker>{},
    this.duration = const Duration(milliseconds: 1000),
    this.rippleDuration = const Duration(milliseconds: 2000),
    this.rotationDuration = const Duration(milliseconds: 10000),
    this.performanceMode = PerformanceMode.better,
    this.rippleColor = Colors.red,
    this.useMarkerRotation = true,
  })  : assert(!markers.any((e) => e.markerId.value.isEmpty), "Must choose a not empty MarkerId"),
        assert(markers.map((e) => e.markerId.value).toSet().length == markers.length,
            "Must choose a unique MarkerId per Marker item");
//
  @override
  _AnimarkerState createState() => _AnimarkerState();
}

class _AnimarkerState extends State<Animarker> with TickerProviderStateMixin {
  //Animation Controllers
  late final AnimationController _angleAnimController;
  late final AnimationController _locationAnimController;
  late final AnimationController _rippleAnimController;

  //Tweens
  late final LocationTween _locationTween;
  late final Tween<double> radiusTween;
  late final ColorTween colorTween;
  late final AngleTween _angleTween;

  //Animations
  late final Animation<ILatLng> _locationAnimation;
  late final Animation<double> radiusAnimation;
  late final Animation<Color> colorAnimation;
  late final Animation<double> _angleAnimation;

  //Variables
  late Widget child;
  Map<MarkerId, Marker> _markers = Map<MarkerId, Marker>();
  Map<CircleId, Circle> _circles = Map<CircleId, Circle>();

  @override
  void initState() {
    _locationAnimController = AnimationController(vsync: this, duration: widget.duration);

    _rippleAnimController = AnimationController(vsync: this, duration: widget.rippleDuration);

    _angleAnimController = AnimationController(vsync: this, duration: widget.rotationDuration);

    //Tweens Init
    _angleTween = AngleTween(begin: 0, end: 0);

    _locationTween = LocationTween(begin: EmptyLatLng(), end: EmptyLatLng(), useRotation: widget.useMarkerRotation);

    radiusTween = Tween<double>(begin: 0, end: 160);

    _locationAnimation = _locationTween
        .animate(CurvedAnimation(curve: Curves.linearToEaseOut, parent: _locationAnimController))
          ..addListener(locationListener);

    _angleAnimation = _angleTween
        .animate(CurvedAnimation(curve: Curves.linearToEaseOut, parent: _angleAnimController))
      ..addListener(angleListener);

    radiusAnimation = radiusTween
        .animate(CurvedAnimation(curve: Curves.easeOutSine, parent: _rippleAnimController))
          ..addStatusListener(_rippleStatusListener)
          ..addListener(rippleListener);

    colorAnimation = ColorTween(
            begin: widget.rippleColor.withOpacity(0.6), end: widget.rippleColor.withOpacity(0.0))
        .chain(CurveTween(curve: Curves.ease))
        .animate(_rippleAnimController) as Animation<Color>;

    //Create markers running for first time
    if (_markers.isEmpty && _markers.length != widget.markers.length) {
      widget.controller.then((controller) {
        GoogleMapHelper.updateMarkers(controller.mapId, _markers.set, widget.markers);
        _markers = keyByMarkerId(widget.markers);
      });
    }

    child = widget.child;

    super.initState();
  }

  @override
  void didUpdateWidget(Animarker oldWidget) {

    //Manage new markers updates after setState had gotten called
    widget.markers.difference(_markers.set).forEach((marker) {
      //If is EmptyLatLng the "begin LatLng" field is first not assigned for animation
      if (_locationTween.begin is EmptyLatLng) {
        _locationTween.begin = marker.toLatLngInfo;
        _locationTween.end = marker.toLatLngInfo;

        _locationTween.begin = marker.toLatLngInfo;
        _locationTween.end = marker.toLatLngInfo;
      } else {
        _locationTween.begin = _locationTween.end;
        _locationTween.end = marker.toLatLngInfo;

        _locationAnimController.reset();
        _locationAnimController.forward(from: _locationAnimController.value);

        _angleTween.begin = _angleAnimation.value;
        _angleTween.end = _locationAnimation.value.bearing;

        _angleAnimController.reset();
        _angleAnimController.forward(from: _angleAnimController.value);
      }
    });

    if (oldWidget.performanceMode != widget.performanceMode) {
      child = widget.child;
    }

    if(widget.markers.any((e) => e is RippleMarker && e.ripple)){
      if(_rippleAnimController.isCompleted || _rippleAnimController.isDismissed) _rippleAnimController.forward();
    } else {
      if(_rippleAnimController.isAnimating) {
          _rippleAnimController.reset();
        }
      }

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return widget.performanceMode == PerformanceMode.better ? child : widget.child;
  }

  void _rippleStatusListener(AnimationStatus status) {
    if (_rippleAnimController.status == AnimationStatus.completed &&
        !_rippleAnimController.isDismissed) {
      Future.delayed(Duration(milliseconds: 400), () => _rippleAnimController.forward(from: 0));
    }
  }

  void locationListener() {

    MarkerId markerId = MarkerId(_locationAnimation.value.markerId);

    Marker marker = Marker(
      markerId: markerId,
      position: _locationAnimation.value.toLatLng,
    );

    //Saving previous marker position
    var tempSet = _markers.set;

    //Update the marker with animation
    _markers[markerId] = marker;

    widget.controller.then((controller) async {
      await GoogleMapHelper.updateMarkers(controller.mapId, tempSet, _markers.set);
    });
  }

  void angleListener() {
    MarkerId markerId = MarkerId(_locationAnimation.value.markerId);

    Marker marker = Marker(
      markerId: markerId,
      rotation: _angleAnimation.value,
      position: _locationAnimation.value.toLatLng,
    );

    //Saving previous marker position
    var tempSet = _markers.set;

    //Update the marker with animation
    _markers[markerId] = marker;

    widget.controller.then((controller) async {
      await GoogleMapHelper.updateMarkers(controller.mapId, tempSet, _markers.set);
    });
  }

  void rippleListener() {

    for (int wave = 3; wave >= 0; wave--) {
      var circleId = CircleId("CircleId->$wave");
      Circle circle = Circle(
        circleId: circleId,
        center: _locationAnimation.value.toLatLng,
        radius: (radiusAnimation.value * wave) /** zoom*/,
        fillColor: colorAnimation.value,
        strokeWidth: 1,
        strokeColor:colorAnimation.value.withOpacity((colorAnimation.value.opacity+0.03).clamp(0.0, 1.0)),
      );

      var tempCircles = _circles.set;

      _circles[circleId] = circle;

      widget.controller.then((controller) async {
        await GoogleMapHelper.updateCircles(controller.mapId, tempCircles, _circles.set);
      });
    }
  }

  @override
  void dispose() async {
    _locationAnimController.dispose();
    _rippleAnimController.dispose();
    _angleAnimController.dispose();
    GoogleMapController controller = await widget.controller;
    controller.dispose();
    super.dispose();
  }
}
