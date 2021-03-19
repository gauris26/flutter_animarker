import 'package:flutter_animarker/anims/animarker_controller.dart';
import 'package:flutter_animarker/core/i_animarker_controller.dart';
import 'package:flutter_animarker/core/performance_mode.dart';
import 'package:flutter_animarker/helpers/google_map_helper.dart';
import 'package:flutter_animarker/infrastructure/location_dispatcher_impl.dart';
import 'package:flutter_animarker/infrastructure/location_tween_factory.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import '../flutter_map_marker_animation.dart';
import '../helpers/extensions.dart';

///Google Maps widget wrapper for animation activities
@immutable
class Animarker extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Set<Marker> markers;
  final double threshold;
  final PerformanceMode performanceMode;
  final Future<GoogleMapController> controller;
  final OnStopover onStopover;
  final isActiveTrip;
  final Duration rippleDuration;
  final Duration rotationDuration;
  final Color rippleColor;
  final double radius;
  final double zoom;
  final bool useRotation;

  Animarker({
    required this.child,
    required this.controller,
    required this.onStopover,
    this.threshold = 1.5,
    this.isActiveTrip = true,
    this.markers = const <Marker>{},
    this.duration = const Duration(milliseconds: 1000),
    this.performanceMode = PerformanceMode.better,
    this.rippleDuration = const Duration(milliseconds: 2000),
    this.rotationDuration = const Duration(milliseconds: 10000),
    this.radius = 0.5,
    this.zoom = 15.0,
    this.rippleColor = Colors.red,
    this.useRotation = true,
  })  : assert(!markers.any((e) => e.markerId.value.isEmpty), 'Must choose a not empty MarkerId'),
        assert(radius >= 0.0 && radius <= 1.0,
            'Must choose values between 0.0 and 1.0 for radius scale'),
        assert(markers.map((e) => e.markerId.value).toSet().length == markers.length,
            'Must choose a unique MarkerId per Marker item');
//
  @override
  _AnimarkerState createState() => _AnimarkerState();
}

class _AnimarkerState extends State<Animarker> with TickerProviderStateMixin {
  //Animation Controllers
  late IAnimarkerController _animarkerController;

  //Variables
  late Widget child;
  final Map<MarkerId, Marker> _markers = <MarkerId, Marker>{};
  final Map<CircleId, Circle> _circles = <CircleId, Circle>{};
  double _devicePixelRatio = 1.0;

  @override
  void initState() {
    _animarkerController = AnimarkerController(
      vsync: this,
      duration: widget.duration,
      rotationDuration: widget.rotationDuration,
      rippleDuration: widget.rippleDuration,
      rippleColor: widget.rippleColor,
      onMarkerAnimation: locationListener,
      onRippleAnimation: rippleListener,
      locationDispatcher: LocationDispatcherImpl(threshold: widget.threshold),
      locationTweenFactory: LocationTweenFactoryImpl(useRotation: widget.useRotation),
      onStopover: widget.onStopover,
    );

    child = widget.child;

    super.initState();
  }

  @override
  void didUpdateWidget(Animarker oldWidget) {
    //Manage new markers updates after setState had gotten called
    widget.markers
        .difference(_markers.set)
        .forEach((marker) => _animarkerController.pushMarker(marker));

    if (oldWidget.performanceMode != widget.performanceMode) {
      child = widget.child;
    }

    if (oldWidget.isActiveTrip != widget.isActiveTrip) {
      _animarkerController.isActiveTrip = widget.isActiveTrip;
    }

    if (oldWidget.radius != widget.radius || oldWidget.zoom != widget.zoom) {
      widget.controller.then((value) =>
          _animarkerController.updateZoomLevel(_devicePixelRatio, widget.radius, widget.zoom));
    }

    super.didUpdateWidget(oldWidget);
  }


  @override
  void didChangeDependencies() {
    _devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) => widget.performanceMode == PerformanceMode.better ? child : widget.child;


  void locationListener(Marker marker) async {
    //Saving previous marker position
    var tempSet = _markers.set;

    //Update the marker with animation
    _markers[marker.markerId] = marker;

    var controller = await widget.controller;
    await GoogleMapHelper.updateMarkers(controller.mapId, tempSet, _markers.set);
  }

  void rippleListener(Circle circle) async {
    var tempCircles = _circles.set;

    _circles[circle.circleId] = circle;

    var controller = await widget.controller;
    await GoogleMapHelper.updateCircles(controller.mapId, tempCircles, _circles.set);
  }

  @override
  void dispose() async {
    _animarkerController.dispose();
    var controller = await widget.controller;
    controller.dispose();
    super.dispose();
  }
}
