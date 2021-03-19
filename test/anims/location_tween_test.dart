import 'package:flutter_animarker/anims/location_tween.dart';
import 'package:flutter_animarker/flutter_map_marker_animation.dart';
import 'package:flutter_animarker/helpers/spherical_util.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/*double lerp(List<double> xs, List<double> ys, double x) {
  int index = binarySearch<double>(xs, x);

  if (index >= 0) return ys[index];

  index = ~index;

  if (index == 0) return ys[0];

  if (index == ys.length) return ys[ys.length - 1];

  return lerpLinear(xs[index - 1], xs[index], ys[index - 1], ys[index], x);
}

double lerpSimple(double a, double b, double t) => a = (b - 1) * t;

double lerpLinear(double x0, double x1, double y0, double y1, double x) {
  double d = x1 - x0;
  if (d == 0) return (y0 + y1) / 2;
  return y0 + (x - x0) * (y1 - y0) / d;
}*/

void main() {

  group('Location Tween Interpolation', () {

    test('Multi-point lerping LocationTween', () {

      var t = 0.5;
      ILatLng p1 = LatLngInfo(18.48817486792756 , - 69.95916740356776,  MarkerId(''));
      ILatLng p2 = LatLngInfo(18.48883880652183 , -69.94596808528654 ,   MarkerId(''));
      ILatLng p3 = LatLngInfo(18.48430279636411 , -69.94079341600313 ,   MarkerId(''));
      ILatLng p4 = LatLngInfo(18.4658611180733  , -69.93044604942473 ,   MarkerId(''));
      ILatLng p5 = LatLngInfo(18.451382274885972, -69.92247245553017 ,   MarkerId(''));
      ILatLng p6 = LatLngInfo(18.447016157112476, -69.92433932762283 ,   MarkerId(''));

      var locationTween = LocationTween.multipoint(points: [p1, p2, p3, p4, p5, p6]);

      print(locationTween.lerp(t));
    });

    test('Just after constructor initialization begin-end angle should keep their values', () {
      ILatLng beginLocation = LatLngInfo(18.48817486792756, -69.95916740356776, MarkerId(''));
      ILatLng endLocation = LatLngInfo(18.48883880652183, -69.94596808528654, MarkerId(''));

      var locationTween = LocationTween(begin: beginLocation, end: endLocation);
      var resultBegin = locationTween.begin;
      var resultEnd = locationTween.end;

      expect(resultBegin, equals(beginLocation));
      expect(resultEnd, equals(endLocation));
    });

    test('Ensure that [begin,end] angles have\'nt changed after calling lerp method', () {
      ILatLng beginLocation = LatLngInfo(18.48817486792756, -69.95916740356776, MarkerId(''));
      ILatLng endLocation = LatLngInfo(18.48883880652183, -69.94596808528654, MarkerId(''));
      var t = 0.6;

      var locationTween = LocationTween(begin: beginLocation, end: endLocation);
      locationTween.lerp(t); //Calling lerp method for interpolation
      var resultBegin = locationTween.begin;
      var resultEnd = locationTween.end;

      expect(resultBegin, equals(beginLocation));
      expect(resultEnd, equals(endLocation));
    });

    test(
        'If begin and end locations are equal the result should be empty, not matter (t) position on the timeline',
        () {
      ILatLng beginLocation = LatLngInfo(18.48817486792756, -69.95916740356776, MarkerId(''));
      ILatLng endLocation = LatLngInfo(18.48817486792756, -69.95916740356776, MarkerId(''));
      var t = 0.5;

      var locationTween = LocationTween(begin: beginLocation, end: endLocation);
      var result = locationTween.lerp(t);

      expect(result, equals(endLocation));
    });

    test('lerp(t) should return the same begin location at 0.0 (t) position on the timeline', () {
      ILatLng beginLocation = LatLngInfo(18.48817486792756, -69.95916740356776, MarkerId(''));
      ILatLng endLocation = LatLngInfo(18.48883880652183, -69.94596808528654, MarkerId(''));
      var t = 0.0;

      var locationTween = LocationTween(begin: beginLocation, end: endLocation);
      var result = locationTween.lerp(t);

      expect(result, equals(beginLocation));
    });

    test(
        'lerp(t) should return the same end location at 1.0 (t) position on the timeline, without rotation deactivated',
        () {
      ILatLng beginLocation = LatLngInfo(18.48817486792756, -69.95916740356776, MarkerId(''));
      ILatLng endLocation = LatLngInfo(18.48883880652183, -69.94596808528654, MarkerId(''));
      var t = 1.0;

      var locationTween =
          LocationTween(begin: beginLocation, end: endLocation, shouldBearing: false);
      var result = locationTween.lerp(t);

      expect(result, equals(endLocation));
    });

    test(
        'lerp(t) should return the same end location just the bearing filed updated at 1.0 (t) position on the timeline with rotation activated',
        () {
      ILatLng beginLocation = LatLngInfo(18.48817486792756, -69.95916740356776, MarkerId(''));
      ILatLng endLocation = LatLngInfo(18.48883880652183, -69.94596808528654, MarkerId(''));
      var t = 1.0;

      var locationTween =
          LocationTween(begin: beginLocation, end: endLocation, shouldBearing: false);
      var result = locationTween.lerp(t);
      var updateBearing = endLocation.copyWith(bearing: result.bearing);

      expect(result, equals(updateBearing));
    });

    test(
        'lerp(t) should return the middle point betwwen begin-end location at 1.0 (t) position on the timeline, without rotation deactivated',
        () {
      ILatLng beginLocation = LatLngInfo(18.48817486792756, -69.95916740356776, MarkerId(''));
      ILatLng endLocation = LatLngInfo(18.48883880652183, -69.94596808528654, MarkerId(''));
      ILatLng middleLocation = LatLngInfo(18.48850695153677, -69.95256775721292, MarkerId(''));
      var t = 0.5;

      var locationTween =
          LocationTween(begin: beginLocation, end: endLocation, shouldBearing: false);
      var result = locationTween.lerp(t);

      expect(result, equals(middleLocation));
    });

    test(
        'lerp(t) should returns same result that source function interpolation (SphericalUtil.interpolate) returns, acting as control',
        () {
      ILatLng beginLocation = LatLngInfo(18.48817486792756, -69.95916740356776, MarkerId(''));
      ILatLng endLocation = LatLngInfo(18.48883880652183, -69.94596808528654, MarkerId(''));
      var t = 0.5;

      var locationTween =
          LocationTween(begin: beginLocation, end: endLocation, shouldBearing: false);
      var result = locationTween.lerp(t);

      var control = SphericalUtil.interpolate(beginLocation, endLocation, t);

      expect(result, equals(control));
    });

    test('Location between begin-end, no inclusive, are not stopover', () {
      ILatLng beginLocation = LatLngInfo(18.48817486792756, -69.95916740356776, MarkerId(''));
      ILatLng endLocation = LatLngInfo(18.48883880652183, -69.94596808528654, MarkerId(''));
      var t = Stream<double>.fromIterable([0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9]);

      var locationTween =
          LocationTween(begin: beginLocation, end: endLocation, shouldBearing: false);

      t.listen(expectAsync1<void, double>(
        (t) {
          var result = locationTween.lerp(t);

          expect(result.isStopover, isFalse);
        },
        count: 9,
      ));
    });

    test('Location between begin-end using transform(t), no inclusive, are not stopover', () {
      ILatLng beginLocation = LatLngInfo(18.48817486792756, -69.95916740356776, MarkerId(''));
      ILatLng endLocation = LatLngInfo(18.48883880652183, -69.94596808528654, MarkerId(''));
      var t = Stream<double>.fromIterable([0.0, 1.0]);

      var locationTween =
          LocationTween(begin: beginLocation, end: endLocation, shouldBearing: false);

      t.listen(expectAsync1<void, double>(
        (t) {
          var result = locationTween.transform(t);

          if (result == endLocation) {
            expect(result.isStopover, isTrue);
          } else if (result == beginLocation) {
            expect(result.isStopover, isFalse);
          } else {
            Evaluation.fail();
          }
        },
        count: 2,
      ));
    });

    test(
        'The tween begin-end need to be swapple, to interpolate from the last position to the new one, and so on, without rotation',
        () {
      ILatLng beginLocation = LatLngInfo(18.48817486792756, -69.95916740356776, MarkerId(''));
      ILatLng endLocation = LatLngInfo(18.48883880652183, -69.94596808528654, MarkerId(''));
      var t = 1.0;

      var locationTween =
          LocationTween(begin: beginLocation, end: endLocation, shouldBearing: false);

      ILatLng newPosition =
          LatLngInfo(18.48430279636411, -69.94079341600313, MarkerId('')); //new location updates

      locationTween.begin = locationTween.end;
      locationTween.end = newPosition;

      expect(locationTween.begin, endLocation);
      expect(locationTween.end, equals(newPosition));

      ILatLng newPosition2 =
          LatLngInfo(18.4658611180733, -69.93044604942473, MarkerId('')); //new location updates

      locationTween.begin = locationTween.end;
      locationTween.end = newPosition2;

      expect(locationTween.begin, equals(newPosition));
      expect(locationTween.end, equals(newPosition2));

      var result = locationTween.lerp(t);

      locationTween.begin = locationTween.end;
      locationTween.end = result;

      expect(locationTween.begin, newPosition2);
      expect(locationTween.end, equals(result));
    });

    test(
        'The tween begin-end need to be swapple, to interpolate from the last position to the new one, and so on',
        () {
      ILatLng beginLocation = LatLngInfo(18.48817486792756, -69.95916740356776, MarkerId(''));
      ILatLng endLocation = LatLngInfo(18.48883880652183, -69.94596808528654, MarkerId(''));
      var t = 1.0;

      var locationTween = LocationTween(begin: beginLocation, end: endLocation);

      var bearing = locationTween.lerp(t).bearing;
      print(bearing);
      ILatLng newPosition =
          LatLngInfo(18.48430279636411, -69.94079341600313, MarkerId('')); //new location updates

      locationTween.begin = locationTween.end;
      locationTween.end = newPosition;

      var bearing2 = locationTween.lerp(t).bearing;
      print(bearing2);

      expect(locationTween.begin, endLocation);
      expect(locationTween.end, equals(newPosition));

      ILatLng newPosition2 =
          LatLngInfo(18.4658611180733, -69.93044604942473, MarkerId('')); //new location updates

      locationTween.begin = locationTween.end;
      locationTween.end = newPosition2;

      var bearing3 = locationTween.lerp(t).bearing;
      print(bearing3);

      expect(locationTween.begin, equals(newPosition));
      expect(locationTween.end, equals(newPosition2));

      ILatLng newPosition3 = LatLngInfo(18.451382274885972, -69.92247245553017, MarkerId(''));

      locationTween.begin = locationTween.end;
      locationTween.end = newPosition3;

      var bearing4 = locationTween.lerp(t).bearing;
      print(bearing4);

      expect(locationTween.begin, equals(newPosition2));
      expect(locationTween.end, equals(newPosition3));

      var result = locationTween.lerp(t);

      locationTween.begin = locationTween.end;
      locationTween.end = result;

      var bearing5 = locationTween.lerp(t).bearing;
      print(bearing5);

      expect(locationTween.begin, newPosition3);
      expect(locationTween.end, equals(result));
    });
  });
}
