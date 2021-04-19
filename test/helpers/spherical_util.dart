// Package imports:

import 'package:flutter_test/flutter_test.dart';
// Project imports:
import 'package:flutter_animarker/core/i_lat_lng.dart';
import 'package:flutter_animarker/helpers/spherical_util.dart';
import 'package:flutter_animarker/models/lat_lng_info.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

void main() {
  ILatLng x1 = LatLngInfo(18.48817486792756, -69.95916740356776, MarkerId(''));
  ILatLng x2 = LatLngInfo(18.48883880652183, -69.94596808528654, MarkerId(''));
  ILatLng x3 = LatLngInfo(18.48430279636411, -69.94079341600313, MarkerId(''));
  ILatLng x4 = LatLngInfo(18.4658611180733, -69.93044604942473, MarkerId(''));
  ILatLng x5 = LatLngInfo(18.451382274885972, -69.92247245553017, MarkerId(''));
  ILatLng x6 = LatLngInfo(18.447016157112476, -69.92433932762283, MarkerId(''));

  var list = [x1, x2, x3, x4, x5, x6];

  test('Spherical Interpolation: Computational cost of trig functions', () {});

  test('Spherical Interpolation', () {
    var start = DateTime.now().millisecondsSinceEpoch;

    var i = SphericalUtil.interpolate(list[0], list[5], 0.0);
    /*for(int i = 0; i < 10000; i++){
      SphericalUtil.interpolate(list[0], list[5], 0.658789);
    }*/

    var end = DateTime.now().millisecondsSinceEpoch;

    var delta = end - start;

    print('Spherical Interpolation: ${delta / 10000} $i');
  });

  test('Spherical Interpolation Vector', () {
    var start = DateTime.now().millisecondsSinceEpoch;

    var i = SphericalUtil.vectorInterpolate(list[0], list[5], 0.658789);

    var end = DateTime.now().millisecondsSinceEpoch;

    var delta = end - start;

    print('Spherical Interpolation Vector: ${delta / 10000} $i');
  });
}
