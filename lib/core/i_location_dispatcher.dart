// Project imports:
import 'package:flutter_animarker/core/i_lat_lng.dart';
import 'package:flutter_animarker/infrastructure/location_dispatcher_impl.dart';

typedef OnMarkerPosition = void Function(ILatLng latLng);

abstract class ILocationDispatcher {
  factory ILocationDispatcher.queue({double threshold}) =
      LocationDispatcherImpl;

  double get threshold;

  bool get isEmpty;

  bool get isNotEmpty;

  ILatLng get popLast;

  int get length;

  List<ILatLng> get values;

  ILatLng get last;

  ILatLng get next;

  ILatLng get peek;

  void push(ILatLng latLng);

  void dispose();

  void clear();
}
