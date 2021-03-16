import 'package:flutter_animarker/anims/location_tween.dart';
import 'package:flutter_animarker/flutter_map_marker_animation.dart';
import 'package:flutter_animarker/helpers/spherical_util.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  group("Location Tween Interpolation", () {
    test('Just after constructor initialization begin-end angle should keep their values', () {
      ILatLng beginLocation = LatLngInfo(18.48817486792756, -69.95916740356776, MarkerId(""));
      ILatLng endLocation = LatLngInfo(18.48883880652183, -69.94596808528654, MarkerId(""));

      LocationTween locationTween = LocationTween(begin: beginLocation, end: endLocation);
      ILatLng resultBegin = locationTween.begin;
      ILatLng resultEnd = locationTween.end;

      expect(resultBegin, equals(beginLocation));
      expect(resultEnd, equals(endLocation));
    });

    test('Ensure that [begin,end] angles have\'nt changed after calling lerp method', () {
      ILatLng beginLocation = LatLngInfo(18.48817486792756, -69.95916740356776, MarkerId(""));
      ILatLng endLocation = LatLngInfo(18.48883880652183, -69.94596808528654, MarkerId(""));
      double t = 0.6;

      LocationTween locationTween = LocationTween(begin: beginLocation, end: endLocation);
      locationTween.lerp(t); //Calling lerp method for interpolation
      ILatLng resultBegin = locationTween.begin;
      ILatLng resultEnd = locationTween.end;

      expect(resultBegin, equals(beginLocation));
      expect(resultEnd, equals(endLocation));
    });

    test(
        'If begin and end locations are equal the result should be empty, not matter (t) position on the timeline',
        () {
      ILatLng beginLocation = LatLngInfo(18.48817486792756, -69.95916740356776, MarkerId(""));
      ILatLng endLocation = LatLngInfo(18.48817486792756, -69.95916740356776, MarkerId(""));
      double t = 0.5;

      LocationTween locationTween = LocationTween(begin: beginLocation, end: endLocation);
      ILatLng result = locationTween.lerp(t);

      expect(result, equals(endLocation));
    });

    test('lerp(t) should return the same begin location at 0.0 (t) position on the timeline', () {
      ILatLng beginLocation = LatLngInfo(18.48817486792756, -69.95916740356776, MarkerId(""));
      ILatLng endLocation = LatLngInfo(18.48883880652183, -69.94596808528654, MarkerId(""));
      double t = 0.0;

      LocationTween locationTween = LocationTween(begin: beginLocation, end: endLocation);
      ILatLng result = locationTween.lerp(t);

      expect(result, equals(beginLocation));
    });

    test(
        'lerp(t) should return the same end location at 1.0 (t) position on the timeline, without rotation deactivated',
        () {
      ILatLng beginLocation = LatLngInfo(18.48817486792756, -69.95916740356776, MarkerId(""));
      ILatLng endLocation = LatLngInfo(18.48883880652183, -69.94596808528654, MarkerId(""));
      double t = 1.0;

      LocationTween locationTween =
          LocationTween(begin: beginLocation, end: endLocation, shouldBearing: false);
      ILatLng result = locationTween.lerp(t);

      expect(result, equals(endLocation));
    });

    test(
        'lerp(t) should return the same end location just the bearing filed updated at 1.0 (t) position on the timeline with rotation activated',
        () {
      ILatLng beginLocation = LatLngInfo(18.48817486792756, -69.95916740356776, MarkerId(""));
      ILatLng endLocation = LatLngInfo(18.48883880652183, -69.94596808528654, MarkerId(""));
      double t = 1.0;

      LocationTween locationTween =
          LocationTween(begin: beginLocation, end: endLocation, shouldBearing: false);
      ILatLng result = locationTween.lerp(t);
      ILatLng updateBearing = endLocation.copyWith(bearing: result.bearing);

      expect(result, equals(updateBearing));
    });

    test(
        'lerp(t) should return the middle point betwwen begin-end location at 1.0 (t) position on the timeline, without rotation deactivated',
        () {
      ILatLng beginLocation = LatLngInfo(18.48817486792756, -69.95916740356776, MarkerId(""));
      ILatLng endLocation = LatLngInfo(18.48883880652183, -69.94596808528654, MarkerId(""));
      ILatLng middleLocation = LatLngInfo(18.48850695153677, -69.95256775721292, MarkerId(""));
      double t = 0.5;

      LocationTween locationTween =
          LocationTween(begin: beginLocation, end: endLocation, shouldBearing: false);
      ILatLng result = locationTween.lerp(t);

      expect(result, equals(middleLocation));
    });

    test(
        'lerp(t) should returns same result that source function interpolation (SphericalUtil.interpolate) returns, acting as control',
        () {
      ILatLng beginLocation = LatLngInfo(18.48817486792756, -69.95916740356776, MarkerId(""));
      ILatLng endLocation = LatLngInfo(18.48883880652183, -69.94596808528654, MarkerId(""));
      double t = 0.5;

      LocationTween locationTween =
          LocationTween(begin: beginLocation, end: endLocation, shouldBearing: false);
      ILatLng result = locationTween.lerp(t);

      ILatLng control = SphericalUtil.interpolate(beginLocation, endLocation, t);

      expect(result, equals(control));
    });

    test('Location between begin-end, no inclusive, are not stopover', () {
      ILatLng beginLocation = LatLngInfo(18.48817486792756, -69.95916740356776, MarkerId(""));
      ILatLng endLocation = LatLngInfo(18.48883880652183, -69.94596808528654, MarkerId(""));
      Stream<double> t = Stream.fromIterable([0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9]);

      LocationTween locationTween =
          LocationTween(begin: beginLocation, end: endLocation, shouldBearing: false);

      t.listen(expectAsync1<void, double>(
        (t) {
          ILatLng result = locationTween.lerp(t);

          expect(result.isStopover, isFalse);
        },
        count: 9,
      ));
    });

    test('Location between begin-end using transform(t), no inclusive, are not stopover', () {
      ILatLng beginLocation = LatLngInfo(18.48817486792756, -69.95916740356776, MarkerId(""));
      ILatLng endLocation = LatLngInfo(18.48883880652183, -69.94596808528654, MarkerId(""));
      Stream<double> t = Stream.fromIterable([0.0, 1.0]);

      LocationTween locationTween =
          LocationTween(begin: beginLocation, end: endLocation, shouldBearing: false);

      t.listen(expectAsync1<void, double>(
        (t) {
          ILatLng result = locationTween.transform(t);

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
      ILatLng beginLocation = LatLngInfo(18.48817486792756, -69.95916740356776, MarkerId(""));
      ILatLng endLocation = LatLngInfo(18.48883880652183, -69.94596808528654, MarkerId(""));
      double t = 1.0;

      LocationTween locationTween = LocationTween(begin: beginLocation, end: endLocation, shouldBearing: false);

      ILatLng newPosition = LatLngInfo(18.48430279636411, -69.94079341600313, MarkerId("")); //new location updates

      locationTween.begin = locationTween.end;
      locationTween.end = newPosition;

      expect(locationTween.begin, endLocation);
      expect(locationTween.end, equals(newPosition));

      ILatLng newPosition2 = LatLngInfo(18.4658611180733, -69.93044604942473, MarkerId("")); //new location updates

      locationTween.begin = locationTween.end;
      locationTween.end = newPosition2;

      expect(locationTween.begin, equals(newPosition));
      expect(locationTween.end, equals(newPosition2));

      ILatLng result = locationTween.lerp(t);

      locationTween.begin = locationTween.end;
      locationTween.end = result;

      expect(locationTween.begin, newPosition2);
      expect(locationTween.end, equals(result));
    });

    test(
        'The tween begin-end need to be swapple, to interpolate from the last position to the new one, and so on',
            () {
          ILatLng beginLocation = LatLngInfo(18.48817486792756, -69.95916740356776, MarkerId(""));
          ILatLng endLocation = LatLngInfo(18.48883880652183, -69.94596808528654, MarkerId(""));
          double t = 1.0;

          LocationTween locationTween = LocationTween(begin: beginLocation, end: endLocation);

          double bearing = locationTween.lerp(t).bearing;
          print(bearing);
          ILatLng newPosition = LatLngInfo(18.48430279636411, -69.94079341600313, MarkerId("")); //new location updates

          locationTween.begin = locationTween.end;
          locationTween.end = newPosition;

          double bearing2 = locationTween.lerp(t).bearing;
          print(bearing2);

          expect(locationTween.begin, endLocation);
          expect(locationTween.end, equals(newPosition));

          ILatLng newPosition2 = LatLngInfo(18.4658611180733, -69.93044604942473, MarkerId("")); //new location updates

          locationTween.begin = locationTween.end;
          locationTween.end = newPosition2;

          double bearing3 = locationTween.lerp(t).bearing;
          print(bearing3);

          expect(locationTween.begin, equals(newPosition));
          expect(locationTween.end, equals(newPosition2));

          ILatLng newPosition3 = LatLngInfo(18.451382274885972, -69.92247245553017, MarkerId(""));

          locationTween.begin = locationTween.end;
          locationTween.end = newPosition3;

          double bearing4 = locationTween.lerp(t).bearing;
          print(bearing4);

          expect(locationTween.begin, equals(newPosition2));
          expect(locationTween.end, equals(newPosition3));

          ILatLng result = locationTween.lerp(t);

          locationTween.begin = locationTween.end;
          locationTween.end = result;

          double bearing5 = locationTween.lerp(t).bearing;
          print(bearing5);

          expect(locationTween.begin, newPosition3);
          expect(locationTween.end, equals(result));
        });
  });
}