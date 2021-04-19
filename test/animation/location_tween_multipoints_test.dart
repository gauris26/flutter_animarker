//https://math.stackexchange.com/questions/654315/how-to-convert-a-dot-product-of-two-vectors-to-the-angle-between-the-vectors

// Dart imports:
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter_animarker/helpers/spherical_util.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_animarker/helpers/extensions.dart';
import 'package:flutter_animarker/core/i_lat_lng.dart';
import 'package:flutter_animarker/models/lat_lng_info.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

void main() {
  group('Location Tween Multipoins', () {
    late List<ILatLng> multipoints;
    late List<double> interpolators;
    late double step;

    setUpAll(() {
      ILatLng x1 =
          LatLngInfo(18.48817486792756, -69.95916740356776, MarkerId(''));
      ILatLng x2 =
          LatLngInfo(18.48883880652183, -69.94596808528654, MarkerId(''));
      ILatLng x3 =
          LatLngInfo(18.48430279636411, -69.94079341600313, MarkerId(''));
      ILatLng x4 =
          LatLngInfo(18.4658611180733, -69.93044604942473, MarkerId(''));
      ILatLng x5 =
          LatLngInfo(18.451382274885972, -69.92247245553017, MarkerId(''));
      ILatLng x6 =
          LatLngInfo(18.447016157112476, -69.92433932762283, MarkerId(''));

      multipoints = [x1, x2, x3, x4, x5, x6];
      step = 1 / (multipoints.length - 1);
      //interpolators = [0.0,0.1457,0.26587,0.3687,0.4789,0.5412,0.67854,0.785645,0.865645,0.97844,1.0];

      interpolators = [0.0, 0.2, 0.4, 0.6, 0.8, 1.0];
    });

    test('Test Piecewise Float32x4', () {
      var preListFloat32x4 = Float32x4List(multipoints.length);

      for (num i = 0, x = 0; x <= 1; x += step, i++) {
        var index = i.toInt();
        var t = x.toDouble();

        var vector = SphericalUtil.latLngtoVector3(multipoints[index]);

        preListFloat32x4[index] = Float32x4(vector.x, vector.y, vector.z, t);
        //[x => vector.x] [y => vector.y] [z => vector.z] [ w => (t) position]
      }

      var lastFloat32x4 = preListFloat32x4.last;

      var results = <ILatLng>[];
      for (var interpolator in interpolators) {
        var vector = SphericalUtil.vectorSlerpOptimized(
          preListFloat32x4,
          lastFloat32x4,
          step,
          interpolator.clamp(0.0, 1.0),
        );

        var xxxx = vector.shuffle(Float32x4.xxxx);
        var yyyy = vector.shuffle(Float32x4.yyyy);

        var sum = xxxx * xxxx + yyyy * yyyy;

        var sqrt = sum.sqrt();

        final lat = atan2(vector.z, sqrt.x);
        final lng = atan2(vector.y, vector.x);

        results.add(ILatLng.point(lat.degrees, lng.degrees));
      }

      for (var i = 0; i < 1; i++) {
        expect(results[i].latitude,
            moreOrLessEquals(multipoints[i].latitude, epsilon: 1e-5));
        expect(results[i].longitude,
            moreOrLessEquals(multipoints[i].longitude, epsilon: 1e-5));
      }
    });
  });
}
