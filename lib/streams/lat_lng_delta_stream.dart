import 'dart:async';

import 'package:flutter_map_marker_animation/models/lat_lng_delta.dart';

class LatLngDeltaStream {
  final _controller = StreamController<LatLngDelta>();

  Stream<LatLngDelta> get stream => _controller.stream;

  void addLatLng(LatLngDelta delta) => _controller.sink.add(delta);

  dispose() {
    _controller.close();
  }
}
