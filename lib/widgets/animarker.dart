// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animarker/core/animarker_controller_description.dart';
import 'package:flutter_animarker/helpers/spherical_util.dart';

// Package imports:
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

// Project imports:
import '../helpers/extensions.dart';
import '../flutter_map_marker_animation.dart';
import 'package:flutter_animarker/helpers/extensions.dart';
import 'package:flutter_animarker/core/performance_mode.dart';
import 'package:flutter_animarker/helpers/google_map_helper.dart';
import 'package:flutter_animarker/animation/animarker_controller.dart';
import 'package:flutter_animarker/core/i_animarker_controller.dart';

///Google Maps widget wrapper for animation activities
@immutable
class Animarker extends StatefulWidget {
  final Curve curve;
  final double zoom;
  final isActiveTrip;
  final Widget child;
  final double rippleRadius;
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
    this.curve = Curves.linear,
    this.zoom = 15.0,
    this.rippleRadius = 0.5,
    this.threshold = 1.5,
    this.useRotation = true,
    this.isActiveTrip = true,
    this.rippleColor = Colors.red,
    this.markers = const <Marker>{},
    this.performanceMode = PerformanceMode.better,
    this.duration = const Duration(milliseconds: 1000),
    this.rippleDuration = const Duration(milliseconds: 2000),
    this.rotationDuration = const Duration(milliseconds: 10000),
  })  : assert(rippleRadius >= 0.0 && rippleRadius <= 1.0, 'Must choose values between 0.0 and 1.0 for radius scale'),
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
  Set<Marker> _previousMarkers = <Marker>{};
  ILatLng midPoint = ILatLng.empty();
  double _zoomScale = 0.5;

  @override
  void initState() {
    _controller = AnimarkerController(
      isActiveTrip: widget.isActiveTrip,
      description: AnimarkerControllerDescription(
        vsync: this,
        curve: widget.curve,
        duration: widget.duration,
        rippleRadius: widget.rippleRadius,
        onStopover: widget.onStopover,
        rippleColor: widget.rippleColor,
        useRotation: widget.useRotation,
        onRippleAnimation: _rippleListener,
        onMarkerAnimation: _locationListener,
        rippleDuration: widget.rippleDuration,
        rotationDuration: widget.rotationDuration,
      ),
    );

    _child = widget.child;
    _markers.addAll(keyByMarkerId(widget.markers));
    widget.markers.forEach((marker) async => await _controller.pushMarker(marker));
    midPoint = _calculateMidPoint();
    super.initState();
  }

  @override
  Widget build(BuildContext context) => widget.isPerformanceBetter ? _child : widget.child;

  @override
  void didUpdateWidget(Animarker oldWidget) {
    if (!setEquals(oldWidget.markers, widget.markers)) {
      //Manage new markers updates after setState had gotten called
      widget.markers.difference(_markers.set).forEach((marker) async{
        await _controller.pushMarker(marker);
      });
    }

    if (widget.performanceModeHasChanged(oldWidget)) _child = widget.child;

    if (widget.isActiveTripHasChanged(oldWidget)) _controller.isActiveTrip = widget.isActiveTrip;

    if (widget.radiusOrZoomHasChanged(oldWidget) && widget.markers.isNotEmpty && midPoint.isNotEmpty) {
      _zoomScale = SphericalUtil.calculateZoomScale(_devicePxRatio, widget.zoom, midPoint);
      _controller.updateRadius(widget.rippleRadius);
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  void didChangeDependencies() {
    _devicePxRatio = MediaQuery.of(context).devicePixelRatio;
    _zoomScale = SphericalUtil.calculateZoomScale(_devicePxRatio, widget.zoom, midPoint);
    super.didChangeDependencies();
  }

  void _locationListener(Marker marker, bool isStopover) async {
    //Update the marker with animation
    var w = widget.markers.where((element) => element.markerId == marker.markerId).first;
    _markers[marker.markerId] = marker.copyWith(iconParam: w.icon);
    var temp = _previousMarkers;
    _previousMarkers = _markers.set;

    await widget.updateMarkers(temp, _markers.set);

    if(isStopover) await animateCamera();
  }

  ILatLng _calculateMidPoint(){
    var count = _markers.set.length;
    var sumLat = 0.0;
    var sumLng = 0.0;

    widget.markers.forEach((element) {
      sumLat += element.position.latitude;
      sumLng += element.position.longitude;
    });

    return ILatLng.point(sumLat/count, sumLng/count);
  }
  Future<void> animateCamera() async {
    midPoint = _calculateMidPoint();

    if(midPoint.isNotEmpty){

      var camera = CameraPosition(
        zoom: widget.zoom,
        tilt: 0,
        bearing: 30,
        target: midPoint.toLatLng,
      );

      await widget.animateCamera(CameraUpdate.newCameraPosition(camera));
    }
  }

  void _rippleListener(Circle circle) async {

    var tempCircles = _circles.set;

    _circles[circle.circleId] = circle.copyWith(radiusParam: circle.radius / _zoomScale);

    await widget.updateCircles(tempCircles, _circles.set);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

extension AnimarkerEx on Animarker {
  bool radiusOrZoomHasChanged(Animarker oldWidget) => oldWidget.rippleRadius != rippleRadius || oldWidget.zoom != zoom;
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

  Future<void> animateCamera(CameraUpdate cameraUpdate) async {
    var mapId = await this.mapId;
    await GoogleMapsFlutterPlatform.instance.animateCamera(cameraUpdate, mapId: mapId);
  }
}
