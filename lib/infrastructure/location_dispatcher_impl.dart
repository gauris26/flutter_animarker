// Dart imports:
import 'dart:collection';

// Project imports:
import 'package:flutter_animarker/core/i_lat_lng.dart';
import 'package:flutter_animarker/core/i_location_dispatcher.dart';
import 'package:flutter_animarker/infrastructure/thresholding_location_mixin.dart';

/// Keep the track queue of new location changes pushed
class LocationDispatcherImpl extends ILocationDispatcher with ThresholdingLocation{
  @override
  final threshold;
  final DoubleLinkedQueue<ILatLng> _locationQueue = DoubleLinkedQueue<ILatLng>();

  LocationDispatcherImpl({this.threshold = 1.5});

  @override
  ILatLng get popLast => _locationQueue.removeLast();

  @override
  ILatLng get next {
    if (_locationQueue.isNotEmpty) {
      var entry = _locationQueue.firstEntry()!;

      return thresholding(entry).remove();
    }

    return ILatLng.empty();
  }

  @override
  ILatLng get peek {
    if (_locationQueue.isNotEmpty) {
      return _locationQueue.first;
    }

    return ILatLng.empty();
  }

  @override
  ILatLng get last {
    if (_locationQueue.isNotEmpty) {
      return _locationQueue.last;
    }

    return ILatLng.empty();
  }

  @override
  void push(ILatLng latLng)  => _locationQueue.addLast(latLng);

  @override
  void dispose() => _locationQueue.clear();

  @override
  void clear() => _locationQueue.clear();

  @override
  bool get isEmpty => _locationQueue.isEmpty;

  @override
  int get length => _locationQueue.length;

  @override
  bool get isNotEmpty => _locationQueue.isNotEmpty;

  @override
  List<ILatLng> get values => List<ILatLng>.unmodifiable(_locationQueue.toList(growable: true));
}
