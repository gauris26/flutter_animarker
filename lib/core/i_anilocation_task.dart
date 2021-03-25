// Project imports:
import 'package:flutter_animarker/infrastructure/anilocation_task_impl.dart';
import 'anilocation_task_description.dart';
import 'i_animation_mode.dart';
import 'i_lat_lng.dart';

typedef LatLngListener = void Function(ILatLng iLatLng);

typedef OnAnimCompleted = void Function(IAnimationMode anim);

abstract class IAnilocationTask implements IAnimationMode {
  ILatLng get value;

  bool get isAnimating;

  bool get isDismissed;

  bool get isCompleted;

  factory IAnilocationTask.create({required  AnilocationTaskDescription description}) = AnilocationTaskImpl;

  void dispose();

  void forward(ILatLng from);
}
