import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter_animarker/core/i_interpolation_service_optimized.dart';
import 'package:flutter_animarker/core/i_lat_lng.dart';
import 'package:flutter_animarker/helpers/spherical_util.dart';

class PolynomialLocationInterpolator<T extends ILatLng>
    extends IInterpolationServiceOptimized<T> {
  @override
  late T begin;

  @override
  late T end;

  final List<ILatLng> points;
  double _step = 0;
  late Float32x4List _preListFloat32x4;
  late Float32x4 _lastFloat32x4;

  PolynomialLocationInterpolator({required this.points}) : super.warmUp() {
    if (points.isNotEmpty) {
      begin = points.first as T;
      end = points.last as T;
    } else {
      begin = ILatLng.empty() as T;
      end = ILatLng.empty() as T;
    }
  }

  /*@override
  T interpolate(double t) {
    var vector = SphericalUtil.vectorSlerp(_ranges, _results, t);

    return SphericalUtil.vectorToPolar(vector) as T;
  }*/

  /*@override
  T interpolate(double t) {

    var vector = SphericalUtil.vectorSlerpOptimized(_preListFloat32x4, _lastFloat32x4, _step, t);
    var latLng = SphericalUtil.vectorToPolarOptimized(vector);
    print(latLng);
    return latLng as T;
  }*/

  @override
  bool get isStopped => _isEmptyOrOnlyHasOneElementOrHasTwoEqualElements;

  bool get _isEmptyOrOnlyHasOneElementOrHasTwoEqualElements =>
      points.isEmpty ||
      points.length == 1 ||
      (points.length == 2 && begin == end);

  @override
  T doInterpolate(double t) {
    var vector = SphericalUtil.vectorSlerpOptimized(
        _preListFloat32x4, _lastFloat32x4, _step, t);
    var latLng = SphericalUtil.vectorToPolarOptimized(vector);
    //debugPrint('($t): [${latLng.latitude},${latLng.longitude}]');
    return latLng as T;
  }

  @protected
  @override
  void doSwap(T newValue) {}

  @protected
  @override
  void doWarmUp() {
    _step = 1 / (points.length - 1);

    _preListFloat32x4 = Float32x4List(points.length);

    for (num i = 0, x = 0; i < points.length; x += _step, i++) {
      var index = i.toDouble();
      var t = x.toDouble();

      var vector = SphericalUtil.latLngtoVector3(points[index.toInt()]);

      _preListFloat32x4[index.toInt()] =
          Float32x4(vector.x, vector.y, vector.z, t);
      //x => vector x | y => vector y | z => vector z | w => (t) position
    }

    _lastFloat32x4 = _preListFloat32x4.last;

    var first = _preListFloat32x4.first;
    var last = _preListFloat32x4.last;
    begin = SphericalUtil.vectorToPolarOptimized(first) as T;
    end = SphericalUtil.vectorToPolarOptimized(last) as T;
  }
}
