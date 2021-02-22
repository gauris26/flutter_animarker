import 'dart:async';

import 'package:flutter_animarker/models/lat_lng_info.dart';

class LatLngStream {
  final _controller = StreamController<LatLngInfo>();

  Stream<LatLngInfo> get stream => _controller.stream;

  void addLatLng(LatLngInfo latLng) => _controller.sink.add(latLng);

  dispose() {
    _controller.close();
  }
}
