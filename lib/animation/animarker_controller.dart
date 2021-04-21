// Flutter imports:
import 'package:flutter_animarker/core/anilocation_task_description.dart';
import 'package:flutter_animarker/core/animarker_controller_description.dart';

// Package imports:

// Project imports:
import 'package:flutter_animarker/core/i_anilocation_task.dart';
import 'package:flutter_animarker/core/i_animarker_controller.dart';
import 'package:flutter_animarker/core/i_lat_lng.dart';
import 'package:flutter_animarker/helpers/extensions.dart';

import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import '../helpers/extensions.dart';

class AnimarkerController extends IAnimarkerController {
  @override
  final AnimarkerControllerDescription description;
  //Late Final Variables
  late final Map<MarkerId, IAnilocationTask> tracker;

  bool _isActiveTrip = true;
  bool _useRotation = true;
  double _radius = 0;

  AnimarkerController({required this.description})
      : tracker = <MarkerId, IAnilocationTask>{} {
    _isActiveTrip = description.isActiveTrip;
    _useRotation = description.useRotation;
    _radius = description.rippleRadius;
  }

  @override
  void updateRadius(double radius) {
    _radius = radius;
  }

  @override
  void updateActiveTrip(bool activeTrip) {
    _isActiveTrip = activeTrip;
  }

  @override
  void updateUseRotation(bool useRotation) {
    _useRotation = useRotation;
  }

  @override
  Future<void> pushMarker(Marker marker) async {
    if (!_isActiveTrip) return;

    // Animation Marker Manager Factory
    tracker[marker.markerId] ??= IAnilocationTask.create(
      description: AnilocationTaskDescription.animarker(
        description: description,
        begin: marker.toLatLngInfo,
        end: marker.toLatLngInfo,
        markerId: marker.markerId,
        onAnimCompleted: _animationCompleted,
        latLngListener: _locationListener,
        curve: description.curve,
      ),
    );

    var task = tracker[marker.markerId]!;

    ///It makes markers to move at the first item to draw in map, until another location updates is received
    if (task.description.isQueueEmpty &&
        !task.isAnimating &&
        task.isCompletedOrDismissed) {
      _locationListener(marker.toLatLngInfo);
    }

    task.updateRadius(_radius);
    task.updateActiveTrip(_isActiveTrip);
    task.updateUseRotation(_useRotation);

    await task.push(marker.toLatLngInfo);
  }

  void _locationListener(ILatLng location) async {
    if (description.onMarkerAnimation != null) {
      description.onMarkerAnimation!(location.fromJson, location.isStopover);
    }

    //Notify if the marker has reached his end position
    if (location.isStopover && description.onStopover != null) {
      await description.onStopover!(location.toLatLng);
    }
  }

  Future<void> _animationCompleted(
      AnilocationTaskDescription description) async {
    /*if (description.dispatcher.length >= description.purgeLimit) {
        var lastValue = description.dispatcher.popLast;
        anim.animatePoints(description.dispatcher.values, last: lastValue);
        description.dispatcher.clear();
        return;
      }*/
  }

  @override
  void dispose() {
    tracker.forEach((key, value) => value.dispose());
    tracker.clear();
  }
}
