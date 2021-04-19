// Project imports:
import 'package:flutter_animarker/infrastructure/anilocation_task_impl.dart';
import 'anilocation_task_description.dart';

import 'i_lat_lng.dart';

typedef LatLngListener = void Function(ILatLng iLatLng);

abstract class IAnilocationTask {
  ILatLng get value;

  bool get isAnimating;

  bool get isDismissed;

  bool get isCompleted;

  bool get isCompletedOrDismissed;

  AnilocationTaskDescription get description;

  factory IAnilocationTask.create(
      {required AnilocationTaskDescription description}) = AnilocationTaskImpl;

  Future<void> push(ILatLng latLng);

  void updateRadius(double latLng);

  void dispose();

  void updateActiveTrip(bool isActiveTrip);

  void updateUseRotation(bool useRotation);
}
