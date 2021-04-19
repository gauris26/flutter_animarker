// Flutter imports:
import 'package:flutter_animarker/infrastructure/i_location_observable.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

// Package imports:

import 'animarker_controller_description.dart';

abstract class IAnimarkerController extends ILocationObservable {
  AnimarkerControllerDescription get description;

  Future<void> pushMarker(Marker marker);

  void updateRadius(double radius);

  void updateActiveTrip(bool activeTrip);

  void updateUseRotation(bool useRotation);

  void dispose();
}
