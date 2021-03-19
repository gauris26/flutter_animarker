// Project imports:
import 'package:flutter_animarker/core/i_lat_lng.dart';
import 'package:flutter_animarker/infrastructure/location_dispatcher_impl.dart';

typedef OnNewMarkerPosition = void Function(ILatLng latLng);

abstract class ILocationDispatcher {

  double get threshold;

  bool get isEmpty;

  bool get isNotEmpty;

  ILatLng get popLast;

  int get length;

  List<ILatLng> get values;

  factory ILocationDispatcher.queue({double threshold}) = LocationDispatcherImpl;

  ILatLng next();

  void push(ILatLng latLng);

  void dispose();

  void clear();

  ILatLng goTo(int index);
}
