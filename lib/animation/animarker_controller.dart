// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter_animarker/core/anilocation_task_description.dart';
import 'package:flutter_animarker/core/animarker_controller_description.dart';

// Package imports:

// Project imports:
import 'package:flutter_animarker/core/i_anilocation_task.dart';
import 'package:flutter_animarker/core/i_animarker_controller.dart';
import 'package:flutter_animarker/core/i_animation_mode.dart';
import 'package:flutter_animarker/core/i_lat_lng.dart';
import 'package:flutter_animarker/helpers/spherical_util.dart';
import 'package:flutter_animarker/infrastructure/animarker_location_listener.dart';
import 'package:flutter_animarker/infrastructure/animarker_ripple_listener.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import '../helpers/extensions.dart';

class AnimarkerController extends IAnimarkerController
    with AnimarkerRippleListenerMixin, AnimarkerLocationListenerMixin {
  @override
  final AnimarkerControllerDescription description;
  //Animation Controllers
  late final AnimationController _rippleAnimController;
  final Map<MarkerId, LatLng> _previousPositions = {};

  //Late Variables
  bool isActiveTrip;

  //Late Final Variables
  late final Map<MarkerId, IAnilocationTask> tracker;

  //Tweens
  late final Tween<double> _radiusTween;

  //Animations
  late final Animation<double> _radiusAnimation;
  late final Animation<Color?> _colorAnimation;

  //Variables
  double _zoomScale = 0.05;
  bool isResseting = false;

  //Getter
  @override
  double get zoomScale => _zoomScale;
  @override
  double get radiusValue => _radiusAnimation.value;
  @override
  Color get colorValue => _colorAnimation.value!;

  @override
  AnimationController get rippleController => _rippleAnimController;

  AnimarkerController({
    required this.description,
    bool isActiveTrip = true,
  }) : isActiveTrip = isActiveTrip {
    _rippleAnimController =
        AnimationController(vsync: description.vsync, duration: description.rippleDuration);

    _radiusTween = Tween<double>(begin: 0, end: 1.0);

    _radiusAnimation = _radiusTween.animate(CurvedAnimation(
      curve: Curves.easeOutSine,
      parent: _rippleAnimController,
    ))
      ..addStatusListener(rippleStatusListener);

    _colorAnimation = ColorTween(
      begin: description.rippleColor.withOpacity(1.0),
      end: description.rippleColor.withOpacity(0.0),
    ).animate(CurvedAnimation(curve: Curves.ease, parent: _rippleAnimController));

    tracker = <MarkerId, IAnilocationTask>{};
  }

  @override
  void updateZoomLevel(double d, double r, double z) {
    _previousPositions.forEach((k, v) {
      _zoomScale = SphericalUtil.calculateZoomScale(d, z, v.toDefaultLatLngInfo);
    });

    _radiusTween.end = r.clamp(0.0, 1.0);
    _rippleAnimController.resetAndForward();
  }

  @override
  void pushMarker(Marker marker) {
    if (!isActiveTrip) return;
    if (_previousPositions[marker.markerId] == marker.position) return;

    // Animation Marker Manager Factory
    tracker[marker.markerId] ??= IAnilocationTask.create(
      description: AnilocationTaskDescription.animarker(
        description: description,
        begin: marker.toLatLngInfo,
        end: marker.toLatLngInfo,
        markerId: marker.markerId,
        onAnimCompleted: _animCompleted,
        latLngListener: _latLngListener,
        curve: Curves.decelerate,
      ),
    );

    ///It makes markers to move at the first item to draw in map, until another location updates is received
    var isQueueEmpty = description.isQueueEmpty;
    description.dispatcher.push(marker.toLatLngInfo);

    if (isQueueEmpty) {
      locationListener(marker.toLatLngInfo);
    }

    //tracker[marker.markerId]!.forward(marker.toLatLngInfo);

    _previousPositions[marker.markerId] = marker.position;
  }

  void _latLngListener(ILatLng latLng) {
    locationListener(latLng);
    rippleListener(latLng);
  }

  void _animCompleted(IAnimationMode anim) {

    if (description.isQueueNotEmpty) {
      /*if (description.dispatcher.length >= description.purgeLimit) {
        var lastValue = description.dispatcher.popLast;
        anim.animatePoints(description.dispatcher.values, last: lastValue);
        description.dispatcher.clear();
        return;
      }*/

      ILatLng next;

      if (isActiveTrip) {
        next = description.dispatcher.next();
      } else {
        next = description.dispatcher.goTo(description.dispatcher.length - 1);
      }

      anim.animateTo(next);

      if (description.isQueueEmpty) _rippleAnimController.reset();
    }
  }

  @override
  void dispose() {
    tracker.forEach((key, value) => value.dispose());
    tracker.clear();
    _radiusAnimation.removeStatusListener(rippleStatusListener);
    _previousPositions.clear();
    description.dispatcher.dispose();
    _rippleAnimController.dispose();
  }
}
