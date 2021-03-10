import 'package:flutter_animarker/anims/animarker_controller.dart';
import 'package:flutter_animarker/core/performance_mode.dart';
import 'package:flutter_animarker/helpers/google_map_helper.dart';
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
  final Duration rippleDuration;
  final Duration rotationDuration;
  final Set<Marker> markers;
  final Color rippleColor;
  final PerformanceMode performanceMode;
  final Future<GoogleMapController> controller;
  final bool useMarkerRotation;
  final OnStopover onStopover;

  Animarker({
    required this.child,
    required this.controller,
    required this.onStopover,
    this.markers = const <Marker>{},
    this.duration = const Duration(milliseconds: 800),
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
  late final AnimarkerController _animarkerController;

  //Variables
  late Widget child;
  Map<MarkerId, Marker> _markers = Map<MarkerId, Marker>();
  Map<CircleId, Circle> _circles = Map<CircleId, Circle>();

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
      locationTweenFactory: LocationTweenFactoryImpl(useRotation: widget.useMarkerRotation),
      onStopover: widget.onStopover,
    );

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
    widget.markers.difference(_markers.set).forEach((marker) async => await _animarkerController.pushMarker(marker));

    if (oldWidget.performanceMode != widget.performanceMode) {
      child = widget.child;
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return widget.performanceMode == PerformanceMode.better ? child : widget.child;
  }

  void locationListener(Marker marker) async {
    //Saving previous marker position
    var tempSet = _markers.set;

    //Update the marker with animation
    _markers[marker.markerId] = marker;

    var controller = await widget.controller;
    await GoogleMapHelper.updateMarkers(controller.mapId, tempSet, _markers.set);
  }

  void rippleListener(Circle circle) {

    var tempCircles = _circles.set;

    _circles[circle.circleId] = circle;

    widget.controller.then((controller) async {
      await GoogleMapHelper.updateCircles(controller.mapId, tempCircles, _circles.set);
    });
  }

  @override
  void dispose() async {
    _animarkerController.dispose();
    GoogleMapController controller = await widget.controller;
    controller.dispose();
    super.dispose();
  }
}
