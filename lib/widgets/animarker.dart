// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter_animarker/core/animarker_controller_description.dart';

// Package imports:
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

// Project imports:
import '../helpers/extensions.dart';
import '../flutter_map_marker_animation.dart';
import 'package:flutter_animarker/helpers/extensions.dart';
import 'package:flutter_animarker/core/performance_mode.dart';
import 'package:flutter_animarker/helpers/google_map_helper.dart';
import 'package:flutter_animarker/core/i_location_dispatcher.dart';
import 'package:flutter_animarker/anims/animarker_controller.dart';
import 'package:flutter_animarker/core/i_animarker_controller.dart';

///Google Maps widget wrapper for animation activities
@immutable
class Animarker extends StatefulWidget {
  final double zoom;
  final Widget child;
  final isActiveTrip;
  final double radius;
  final double threshold;
  final bool useRotation;
  final Color rippleColor;
  final Duration duration;
  final Set<Marker> markers;
  final OnStopover onStopover;
  final Duration rippleDuration;
  final Duration rotationDuration;
  final PerformanceMode performanceMode;
  final Future<GoogleMapController> controller;

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
  })  : assert(radius >= 0.0 && radius <= 1.0, 'Must choose values between 0.0 and 1.0 for radius scale'),
        assert(!markers.isAnyEmpty, 'Must choose a not empty MarkerId'),
        assert(markers.markerIds.length == markers.length, 'Must choose a unique MarkerId per Marker item');

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
      description: AnimarkerControllerDescription(
        vsync: this,
        duration: widget.duration,
        rotationDuration: widget.rotationDuration,
        rippleDuration: widget.rippleDuration,
        rippleColor: widget.rippleColor,
        useRotation: widget.useRotation,
        onMarkerAnimation: locationListener,
        onRippleAnimation: rippleListener,
        dispatcher: ILocationDispatcher.queue(threshold: widget.threshold),
        onStopover: widget.onStopover,
      ),
    );

    child = widget.child;

    super.initState();
  }

  @override
  Widget build(BuildContext context) =>
      widget.performanceMode == PerformanceMode.better ? child : widget.child;

  @override
  void didUpdateWidget(Animarker oldWidget) {
    //Manage new markers updates after setState had gotten called
    widget.markers.difference(_markers.set).forEach((marker) => _animarkerController.pushMarker(marker));

    if (oldWidget.performanceMode != widget.performanceMode) {
      child = widget.child;
    }

    if (oldWidget.isActiveTrip != widget.isActiveTrip) {
      _animarkerController.isActiveTrip = widget.isActiveTrip;
    }

    if (oldWidget.radius != widget.radius || oldWidget.zoom != widget.zoom) {
      widget.controller.then(
          (value) => _animarkerController.updateZoomLevel(_devicePixelRatio, widget.radius, widget.zoom));
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  void didChangeDependencies() {
    _devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    super.didChangeDependencies();
  }

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
