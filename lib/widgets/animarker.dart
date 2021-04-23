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
import 'package:flutter_animarker/helpers/google_map_helper.dart';
import 'package:flutter_animarker/animation/animarker_controller.dart';
import 'package:flutter_animarker/core/i_animarker_controller.dart';

///Google Maps widget wrapper for location, angle and ripple animation on map canvas
/// The basic setup for using *Animarker* for Google Maps
///
/// ```dart
/// Animarker(
///   mapId: _controller.future.then<int>((value) => value.mapId),
///   child: GoogleMap(
///     ...
///     onMapCreated: (controller) => _controller.complete(controller),
///     onCameraMove: (ca) => setState(() => zoom = ca.zoom),
///     ...
///   ),
/// )
///  ```
/// New location updates are push it to a First-in, first-out queue (FIFO) that pops
/// the next location in the queue when current running animation ends until clears the queue.
///
/// Since *Location interpolation* requires two polar position [begin (latitude, longitude), end (latitude, longitude)]
/// When first location is push it to queue the animation doesn't start until a second location is pushed [begin, end]
///
/// If both begin and end location are equal it means that marker is stopped
@immutable
class Animarker extends StatefulWidget {
  ///Animation Curve
  ///
  /// ```dart
  /// curve: Curves.bounceOut
  /// ```
  final Curve curve;

  /// Google Maps' zoom: require for scale the ripple radius depending on [zoom]
  /// Preventing, this way, a huge ripple size using a fixed radius when zoom changes
  ///
  /// ```dart
  /// Animarker(
  ///   ...
  ///   zoom: zoom,
  ///   child: GoogleMap(
  ///     onCameraMove: (ca) => setState(() => zoom = ca.zoom),
  ///   ),
  ///   ...
  ///  )
  /// ```
  /// Default value: 15.0
  final double zoom;

  /// Control if should accept new location changes or ends the current trip
  /// ```dart
  ///   isActiveTrip: active
  /// ```
  /// When [isActiveTrip] false skip new location pushing the *Location Queue*
  ///
  /// Default value: true
  final bool isActiveTrip;

  /// The Google Maps Widget as child
  ///
  /// Declare future Completer to capture Google Maps controller on [onMapCreated]
  /// ```dart
  /// final Completer<GoogleMapController> _controller = Completer();
  /// ```
  ///
  /// Get the mapId when future GoogleMapController completes
  /// The mapId is required to place marker and circle at the correct Google Maps instance
  /// ```dart
  /// _controller.future.then<int>((value) => value.mapId),
  /// ```
  /// The basic setup for using *Animarker* for Google Maps
  ///
  /// ```dart
  /// Animarker(
  ///   mapId: _controller.future.then<int>((value) => value.mapId),
  ///   child: GoogleMap(
  ///     ...
  ///     onMapCreated: (controller) => _controller.complete(controller),
  ///     onCameraMove: (ca) => setState(() => zoom = ca.zoom),
  ///     ...
  ///   ),
  /// )
  ///  ```
  /// *Required field*
  ///
  final Widget child;

  /// Control the ripple radius size taking the screen width as constraints
  ///
  /// Value interval [0.0, 1.0], closer to 1.0 circle radius will match the whole screen size
  /// ```dart
  /// rippleRadius: 0.5
  /// ```
  ///
  /// Default value: 0.5
  ///
  /// *Required field*
  ///
  final double rippleRadius;

  /// The color of ripple rings
  ///
  /// ```dart
  ///   rippleColor: Colors.re,
  /// ```
  /// Default value `Colors.red`
  ///
  final Color rippleColor;

  /// Set the tolerance to skip consecutive Location value in the queue running in the same direction:
  ///
  /// If absolute angle/heading different between
  /// [current,next location]° and [next location, after next location]° is less than [angleThreshold] next location
  /// will get skipped and so on.
  ///
  /// Ex: Let's imagine that the square bracket are location in the queue and dash(-) for 180° and underscore(_) for 189°
  ///
  /// [1]---------[2]---[3]----[4]-------[5]____[6]---[7]____[8]__[9]---[10]
  /// [1]--------------------------------[5]____[6]---[7]_________[9]---[10]
  ///
  /// All the consecutive location in the same direction with angle/heading different/delta less than [angleThreshold]
  /// will get skipped:
  ///
  /// [2],[3],[4] for 180°.
  /// [8] for 189°
  ///
  /// Using [angleThreshold] can prevent unnecessary stops and delay between first location in the queue
  /// and the current user location.
  ///
  /// Set to zero if you don't want to missed any stop.
  ///
  /// ```dart
  ///
  ///   var delta = afterNextAngle - currentAngle;
  ///
  ///   if (delta.abs() < threshold) {
  ///         next.remove();
  ///   }
  ///
  /// Very very small angle (<1e-6) can led to errors.
  ///
  ///   ```
  final double angleThreshold;

  /// Let you enable/disable Marker rotation: The rotation, also known as bearing/heading, are the angle
  /// between two locations and indicate the course or direction from one to another.
  ///
  ///  ```dart
  ///   useRotation: true
  /// ```
  /// *Google Maps' Markers use property `rotation` to change angle position of it. If you're using custom
  /// `[BitmapDescriptor]` remember to set the `anchor` property according you chosen anchor point of you custom icon.
  ///
  final bool useRotation;

  /// First of all, let's explain how the location interpolation is done: since it's required a begin location and
  /// end location to geo-interpolate between them, the animation lasts according to the indicated [duration].
  /// Meanwhile, when animation is running new location updates could be pushed to **Location Queue**, making it
  /// larger and larger and increasing the distance and delay between current animating location and real user one.
  ///
  /// To reduce "traffic congestion" the [runExpressAfter] controls how much the **Location Queue** can grow applying
  /// a multipoint interpolation, instead of a linear interpolation between to points.
  ///
  /// For instance, normal linear interpolation goes from `P1` to `P2` but multipoint interpolation
  /// (using piecewise linear interpolation algorithm) goes over multiple point or nodes at once
  /// (P1,P2,P3,P4,P5,P6...Pn) without any halfway stop just like a express train skipping local stops.
  ///
  /// So, when the **Location Queue**'s length reaches the [runExpressAfter] the Multipoint interpolation
  /// is activated, first clears and reset the queue, just then, "sew" through all the point at once. Finally,
  /// the normal linear interpolation takes control again, until the queue required to be purge again.+
  ///
  /// This behavior is useful the user is moving fast, and many location updates are lagging in the queue
  /// waiting for the running animation to complete. Also, reduce stops making the whole animation smoothly.
  ///
  /// During multipoint interpolation the bearing/heading angle is taken from the first and last position.
  ///
  /// Default value: 10
  final int runExpressAfter;

  /// Save the [mapId] from Google Maps widget related to this Animarker widget.
  /// This value is used underlying for the Native Google Maps Platform
  ///
  /// ```dart
  ///   final Completer<GoogleMapController> _controller = Completer();
  /// ```
  ///
  /// Get the mapId when future GoogleMapController completes
  /// The mapId is required to place marker and circle at the correct Google Maps instance
  /// ```dart
  /// _controller.future.then<int>((value) => value.mapId),
  /// ```
  /// The basic setup for using *Animarker* for *Google Maps*
  ///
  /// ```dart
  /// Animarker(
  ///   mapId: _controller.future.then<int>((value) => value.mapId),
  ///   child: GoogleMap(
  ///     ...
  ///     onMapCreated: (controller) => _controller.complete(controller),
  ///     onCameraMove: (ca) => setState(() => zoom = ca.zoom),
  ///     ...
  ///   ),
  /// )
  ///  ```
  /// *Required field*
  ///
  final Future<int> mapId;

  /// The length of time this geo-animation should last
  ///
  /// Default value: `Duration(milliseconds: 1000)`
  ///
  /// Used for both linear and angle/bearing animations
  ///
  final Duration duration;

  /// Literally, a Set of markers provided to the Animarker widget. All the elements shouldn't be duplicated.
  /// The [MarkerId] should be unique at the set, duplicated `MarkerId`s would led to an error
  /// ```dart
  ///
  /// final Map<MarkerId, Marker> _markers = <MarkerId, Marker>{}
  ///
  /// Animarker(
  ///   markers: <Marker>{
  ///     ..._markers.values.toSet(),
  ///     RippleMarker(
  ///       icon: BitmapDescriptor.defaultMarker,
  ///       markerId: MarkerId('MarkerId1'),
  ///       position: LatLng(0, 0),
  ///       ripple: false,
  ///     ),
  ///     Marker(
  ///       markerId: MarkerId('MarkerId2'),
  ///       position: LatLng(0, 0),
  ///     ),
  ///  },
  ///
  /// ```
  ///
  /// When a Marker has changed a new location update is pushed to the **Location Queue**.
  ///
  final Set<Marker> markers;

  /// Callback called when final state of the animation is reach: Given [P1,P2] locations, when
  /// the animation reach the P2 point the callback is called making a stop (t = 1.0).
  ///
  /// So, if you want to change the Google Maps's Camera o something else when current animation ends
  /// [onStopover] will suit you.
  final OnStopover? onStopover;

  /// The length of time this ripple animation should last
  ///
  /// Default value: `Duration(milliseconds: 2000)`
  ///
  /// Used for both linear and angle/bearing animations
  ///
  /// There is a delay between ripple animation: the half of [rippleDuration]. For a `Duration(milliseconds: 2000)`
  /// the delay will be `Duration(milliseconds: 1000)`.
  ///
  /// ```dart
  ///   rippleDuration = const Duration(milliseconds: 2000),
  /// ```
  final Duration rippleDuration;

  final bool shouldAnimateCamera;

  Animarker({
    Key? key,
    required this.child,
    required this.mapId,
    this.curve = Curves.linear,
    this.onStopover,
    this.zoom = 15.0,
    this.rippleRadius = 0.5,
    this.runExpressAfter = 10,
    this.angleThreshold = 1.5,
    this.useRotation = true,
    this.isActiveTrip = true,
    this.rippleColor = Colors.red,
    this.markers = const <Marker>{},
    this.duration = const Duration(milliseconds: 1000),
    this.rippleDuration = const Duration(milliseconds: 2000),
    this.shouldAnimateCamera = true,
  })  : assert(rippleRadius >= 0.0 && rippleRadius <= 1.0,
            'Must choose values between [0.0, 1.0] for radius scale'),
        assert(!markers.isAnyEmpty, 'Must choose a not empty MarkerId'),
        assert(markers.markerIds.length == markers.length,
            'Must choose a unique MarkerId per Marker'),
        super(key: key);

  @override
  AnimarkerState createState() => AnimarkerState();
}

class AnimarkerState extends State<Animarker> with TickerProviderStateMixin {
  //Animation Controllers
  late IAnimarkerController _controller;

  //Variables
  double _devicePxRatio = 1.0;
  final Map<MarkerId, Marker> _markers = <MarkerId, Marker>{};
  final Map<CircleId, Circle> _circles = <CircleId, Circle>{};
  Set<Marker> _previousMarkers = <Marker>{};
  ILatLng midPoint = ILatLng.empty();
  double _zoomScale = 0.5;

  @override
  void initState() {
    _controller = AnimarkerController(
      description: AnimarkerControllerDescription.animarker(
        widget,
        vsync: this,
        onStopover: _onStopover,
        onRippleAnimation: _rippleListener,
        onMarkerAnimation: _locationListener,
      ),
    );

    _markers.addAll(keyByMarkerId(widget.markers));
    widget.markers
        .forEach((marker) async => await _controller.pushMarker(marker));
    if (widget.markers.isNotEmpty) midPoint = _calculateMidPoint();

    super.initState();
  }

  @override
  Widget build(BuildContext context) => widget.child;

  @override
  void didUpdateWidget(Animarker oldWidget) {
    if (!setEquals(oldWidget.markers, widget.markers)) {
      //Manage new markers updates after setState had gotten called
      widget.markers.difference(_markers.set).forEach((marker) async {
        await _controller.pushMarker(marker);
      });
    }

    if (widget.isActiveTripHasChanged(oldWidget)) {
      _controller.updateActiveTrip(widget.isActiveTrip);
    }

    if (widget.useRotationHasChanged(oldWidget)) {
      _controller.updateUseRotation(widget.useRotation);
    }

/*    if (widget.radiusOrZoomHasChanged(oldWidget) && midPoint.isNotEmpty) {
      _zoomScale = SphericalUtil.calculateZoomScale(
          _devicePxRatio, widget.zoom, midPoint);
      _controller.updateRadius(widget.rippleRadius);
    }*/

    super.didUpdateWidget(oldWidget);
  }

  @override
  void didChangeDependencies() async {
    _devicePxRatio = MediaQuery.of(context).devicePixelRatio;
    _zoomScale =
        SphericalUtil.calculateZoomScale(_devicePxRatio, widget.zoom, midPoint);

    var mapId = await widget.mapId;

    GoogleMapsFlutterPlatform.instance
        .onMarkerTap(mapId: mapId)
        .listen((MarkerTapEvent e) {
      var value = keyByMarkerId(widget.markers)[e.value];
      if (value != null && value.onTap != null) {
        value.onTap!();
      }
    });

    super.didChangeDependencies();
  }

  void _locationListener(Marker marker, bool isStopover) async {
    //Update the marker with animation
    _markers[marker.markerId] = marker;
    var temp = _previousMarkers;
    _previousMarkers = _markers.set;

    await widget.updateMarkers(temp, _markers.set);
  }

  Future<void> _onStopover(LatLng latLng) async {
    if (widget.onStopover != null) {
      await widget.onStopover!(latLng);
    }
    if (widget.shouldAnimateCamera) {
      await _animateCamera();
    }
  }

  ILatLng _calculateMidPoint() {
    var count = _markers.set.length;
    var sumLat = 0.0;
    var sumLng = 0.0;

    widget.markers.forEach((element) {
      sumLat += element.position.latitude;
      sumLng += element.position.longitude;
    });

    return ILatLng.point(sumLat / count, sumLng / count);
  }

  Future<void> _animateCamera() async {
    midPoint = _calculateMidPoint();

    if (midPoint.isNotEmpty) {
      var camera = CameraPosition(
        zoom: widget.zoom,
        tilt: 0,
        target: midPoint.toLatLng,
      );

      await widget.animateCamera(CameraUpdate.newCameraPosition(camera));
    }
  }

  void _rippleListener(Circle circle) async {
    var tempCircles = _circles.set;

    _circles[circle.circleId] =
        circle.copyWith(radiusParam: circle.radius / _zoomScale);

    await widget.updateCircles(tempCircles, _circles.set);
  }

  @override
  void dispose() {
    GoogleMapsFlutterPlatform.instance.dispose(mapId: 0);
    _controller.dispose();
    super.dispose();
  }
}

extension AnimarkerEx on Animarker {
  bool radiusOrZoomHasChanged(Animarker oldWidget) =>
      (oldWidget.rippleRadius != rippleRadius || oldWidget.zoom != zoom) &&
      markers.isNotEmpty;
  bool isActiveTripHasChanged(Animarker oldWidget) =>
      oldWidget.isActiveTrip != isActiveTrip;
  bool useRotationHasChanged(Animarker oldWidget) =>
      oldWidget.useRotation != useRotation;

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
    await GoogleMapsFlutterPlatform.instance
        .animateCamera(cameraUpdate, mapId: mapId);
  }
}
