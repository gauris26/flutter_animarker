// Flutter imports:
import 'package:flutter/animation.dart';

// Project imports:
import 'package:flutter_animarker/core/i_lat_lng.dart';

abstract class IAnimationMode {
  void animatePoints(List<ILatLng> list, {ILatLng last, Curve curve});
}
