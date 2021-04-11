// Flutter imports:
import 'package:flutter/foundation.dart';
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
  final isActiveTrip;
  final Widget child;
  final double radius;
  final double threshold;
  final bool useRotation;
  final Color rippleColor;
  final Future<int> mapId;
  final Duration duration;
  final Set<Marker> markers;
  final OnStopover onStopover;
  final Duration rippleDuration;
  final Duration rotationDuration;
  final PerformanceMode performanceMode;

  Animarker({
    Key? key,
    required this.child,
    required this.onStopover,
    required this.mapId,
    this.zoom = 15.0,
    this.radius = 0.5,
    this.threshold = 1.5,
    this.useRotation = true,
    this.isActiveTrip = true,
    this.rippleColor = Colors.red,
    this.markers = const <Marker>{},
    this.performanceMode = PerformanceMode.better,
    this.duration = const Duration(milliseconds: 1000),
    this.rippleDuration = const Duration(milliseconds: 2000),
    this.rotationDuration = const Duration(milliseconds: 10000),
  })  : assert(radius >= 0.0 && radius <= 1.0, 'Must choose values between 0.0 and 1.0 for radius scale'),
        assert(!markers.isAnyEmpty, 'Must choose a not empty MarkerId'),
        assert(markers.markerIds.length == markers.length, 'Must choose a unique MarkerId per Marker item'),
        super(key: key);

  @override
  AnimarkerState createState() => AnimarkerState();
}

class AnimarkerState extends State<Animarker> with TickerProviderStateMixin {
  //Animation Controllers
  late IAnimarkerController _controller;

  //Variables
  late Widget _child;
  double _devicePxRatio = 1.0;
  final Map<MarkerId, Marker> _markers = <MarkerId, Marker>{};
  final Map<CircleId, Circle> _circles = <CircleId, Circle>{};

  @override
  void initState() {
    _controller = AnimarkerController(
      description: AnimarkerControllerDescription(
        vsync: this,
        duration: widget.duration,
        onStopover: widget.onStopover,
        rippleColor: widget.rippleColor,
        useRotation: widget.useRotation,
        onRippleAnimation: _rippleListener,
        onMarkerAnimation: _locationListener,
        rippleDuration: widget.rippleDuration,
        rotationDuration: widget.rotationDuration,
        dispatcher: ILocationDispatcher.queue(threshold: widget.threshold),
      ),
    );

    _child = widget.child;
    _markers.addAll(keyByMarkerId(widget.markers));
    widget.markers.forEach((marker) => _controller.pushMarker(marker));
    print('Start: ${DateTime.now().millisecondsSinceEpoch}');
    super.initState();
  }

  @override
  Widget build(BuildContext context) => widget.isPerformanceBetter ? _child : widget.child;

  @override
  void didUpdateWidget(Animarker oldWidget) {
    if(!setEquals(oldWidget.markers, widget.markers)){
      //Manage new markers updates after setState had gotten called
      widget.markers.difference(_markers.set).forEach((marker) => _controller.pushMarker(marker));
    }

    if (widget.performanceModeHasChanged(oldWidget)) _child = widget.child;

    if (widget.isActiveTripHasChanged(oldWidget)) _controller.isActiveTrip = widget.isActiveTrip;

    if (widget.radiusOrZoomHasChanged(oldWidget)) {
      _controller.updateZoomLevel(_devicePxRatio, widget.radius, widget.zoom);
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  void didChangeDependencies() {
    _devicePxRatio = MediaQuery.of(context).devicePixelRatio;
    super.didChangeDependencies();
  }

  void _locationListener(Marker marker) async {
    //print('End: ${DateTime.now().millisecondsSinceEpoch}');
    //Saving previous marker position
    var tempSet = _markers.set;

    //Update the marker with animation
    _markers[marker.markerId] = marker;

    await widget.updateMarkers(tempSet, _markers.set);
  }

  void _rippleListener(Circle circle) async {
    var tempCircles = _circles.set;

    _circles[circle.circleId] = circle;

    await widget.updateCircles(tempCircles, _circles.set);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

extension RadiosZoomEx on Animarker {
  bool radiusOrZoomHasChanged(Animarker oldWidget) => oldWidget.radius != radius || oldWidget.zoom != zoom;
  bool performanceModeHasChanged(Animarker oldWidget) => oldWidget.performanceMode != performanceMode;
  bool isActiveTripHasChanged(Animarker oldWidget) => oldWidget.isActiveTrip != isActiveTrip;
  bool get isPerformanceBetter => performanceMode == PerformanceMode.better;
  Future<void> updateCircles(Set<Circle> previous, Set<Circle> current) async {
    var mapId = await this.mapId;
    await GoogleMapHelper.updateCircles(mapId, previous, current);
  }

  Future<void> updateMarkers(Set<Marker> previous, Set<Marker> current) async {
    var mapId = await this.mapId;
    await GoogleMapHelper.updateMarkers(mapId, previous, current);
  }
}
