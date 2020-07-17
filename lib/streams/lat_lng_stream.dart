import 'dart:async';

import 'package:google_maps_flutter/google_maps_flutter.dart' show LatLng;

class LatLngStream {
  final _controller = StreamController<LatLng>();

  Stream<LatLng> get stream => _controller.stream;

  void addLatLng(latLng) => _controller.sink.add(latLng);

  dispose() {
    _controller.close();
  }
}
