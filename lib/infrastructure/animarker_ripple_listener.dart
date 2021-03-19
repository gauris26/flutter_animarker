// Flutter imports:
import 'package:flutter/animation.dart';

// Package imports:
import 'package:google_maps_flutter/google_maps_flutter.dart';

// Project imports:
import 'package:flutter_animarker/core/i_animarker_controller.dart';
import 'package:flutter_animarker/core/i_lat_lng.dart';
import 'package:flutter_animarker/helpers/extensions.dart';

mixin AnimarkerRippleListenerMixin on IAnimarkerController {

  void rippleListener(ILatLng location) {
    var radius = (radiusValue / 100) / zoomScale;

    for (var wave = 3; wave >= 0; wave--) {
      var circleId = CircleId('CircleId->$wave');
      var circle = Circle(
        circleId: circleId,
        center: location.toLatLng,
        radius: radius * wave,
        fillColor: colorValue,
        strokeWidth: 1,
        strokeColor: colorValue,
      );

      onRippleAnimation(circle);
    }
  }

  void rippleStatusListener(AnimationStatus status) async {
    if (rippleController.isCompleted && !rippleController.isDismissed) {
      if (isQueueNotEmpty) {
        Future.delayed(Duration(milliseconds: 500), () async => await rippleController.forward(from: 0));
      }
    }
  }
}
