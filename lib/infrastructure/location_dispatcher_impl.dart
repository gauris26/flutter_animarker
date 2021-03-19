import 'dart:collection';
import 'package:flutter_animarker/core/i_location_dispatcher.dart';
import 'package:flutter_animarker/helpers/spherical_util.dart';
import 'package:flutter_animarker/models/lat_lng_info.dart';
import 'package:flutter_animarker/core/i_lat_lng.dart';

class LocationDispatcherImpl implements ILocationDispatcher {
  @override
  final threshold;
  final DoubleLinkedQueue<ILatLng> _locationQueue = DoubleLinkedQueue<ILatLng>();

  LocationDispatcherImpl({this.threshold = 1.5});

  @override
  ILatLng get popLast => _locationQueue.removeLast();

  @override
  ILatLng next() {
    if (_locationQueue.isNotEmpty) {
      var entry = _locationQueue.firstEntry()!;

      return _thresholding(entry).remove();
    }

    return LatLngInfo.empty();
  }

  @override
  List<ILatLng> get values => _locationQueue.toList();

  @override
  ILatLng goTo(int index) {
    var location = _locationQueue.elementAt(index);
    _locationQueue.clear();
    return location;
  }

  DoubleLinkedQueueEntry<ILatLng> _thresholding(DoubleLinkedQueueEntry<ILatLng> entry) {
    var current = entry.element;

    var nextEntry = entry.nextEntry();
    var upcomingEntry = nextEntry?.nextEntry();

    var next = nextEntry?.element ?? LatLngInfo.empty();
    var upcoming = upcomingEntry?.element ?? LatLngInfo.empty();

    if (!upcoming.isEmpty) {
      var currentBearing = SphericalUtil.computeHeading(current, next);

      var upComingBearing = SphericalUtil.computeHeading(next, upcoming);

      var delta = upComingBearing - currentBearing;

      if (delta.abs() < threshold) {
        nextEntry!.remove();
      }
    }

    return entry;
  }

  @override
  void push(ILatLng latLng) => _locationQueue.addLast(latLng);

  @override
  bool get isEmpty => _locationQueue.isEmpty;

  @override
  int get length => _locationQueue.length;

  @override
  bool get isNotEmpty => _locationQueue.isNotEmpty;

  @override
  void dispose() => _locationQueue.clear();

  @override
  void clear() => _locationQueue.clear();


}
