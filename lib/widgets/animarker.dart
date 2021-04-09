// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter_animarker/core/animarker_controller_description.dart';

// Package imports:
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

// Project imports:
import '../helpers/extensions.dart';
import '../flutter_map_marker_animation.dart';
import 'package:flutter_animarker/helpers/extensions.dart';
import 'package:flutter_animarker/core/performance_mode.dart';
import 'package:flutter_animarker/helpers/google_map_helper.dart';
import 'package:flutter_animarker/core/i_location_dispatcher.dart';
import 'package:flutter_animarker/animation/animarker_controller.dart';
import 'package:flutter_animarker/core/i_animarker_controller.dart';

///Google Maps widget wrapper for animation activities
@immutable
class Animarker extends StatefulWidget {
  final double zoom;
  final Future<int> mapId;
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

  Animarker({
    required this.child,
    required this.onStopover,
    required this.mapId,
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
  late IAnimarkerController _controller;

  //Variables
  late int mapId;
  late Widget child;
  double _devicePxRatio = 1.0;
  final Map<MarkerId, Marker> _markers = <MarkerId, Marker>{};
  final Map<CircleId, Circle> _circles = <CircleId, Circle>{};

  @override
  void initState() {
    _controller = AnimarkerController(
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
    widget.markers.difference(_markers.set).forEach((marker) => _controller.pushMarker(marker));

    if (widget.performanceModeHasChanged(oldWidget)) child = widget.child;

    if (widget.isActiveTripHasChanged(oldWidget)) _controller.isActiveTrip = widget.isActiveTrip;

    if (widget.radiusOrZoomHasChanged(oldWidget)) _controller.updateZoomLevel(_devicePxRatio, widget.radius, widget.zoom);

    super.didUpdateWidget(oldWidget);
  }

  @override
  void didChangeDependencies() {
    _devicePxRatio = MediaQuery.of(context).devicePixelRatio;
    super.didChangeDependencies();
  }

  void locationListener(Marker marker) async {
    //Saving previous marker position
    var tempSet = _markers.set;

    //Update the marker with animation
    _markers[marker.markerId] = marker;

    await widget.updateMarkers(tempSet, _markers.set);
  }

  void rippleListener(Circle circle) async {
    var tempCircles = _circles.set;

    _circles[circle.circleId] = circle;

    await widget.updateCircles(tempCircles, _circles.set);
  }

  @override
  void dispose() async {
    _controller.dispose();
    super.dispose();
  }
}

extension RadiosZoomEx on Animarker {
  bool radiusOrZoomHasChanged(Animarker oldWidget) => oldWidget.radius != radius || oldWidget.zoom != zoom;
  bool performanceModeHasChanged(Animarker oldWidget) => oldWidget.performanceMode != performanceMode;
  bool isActiveTripHasChanged(Animarker oldWidget) => oldWidget.isActiveTrip != isActiveTrip;
  Future<void> updateCircles(Set<Circle> previous, Set< Circle> current) async {
    var mapId = await this.mapId;
    await GoogleMapHelper.updateCircles(mapId, previous, current);
  }
  Future<void> updateMarkers(Set<Marker> previous, Set< Marker> current) async {
    var mapId = await this.mapId;
    await GoogleMapHelper.updateMarkers(mapId, previous, current);
  }
}
