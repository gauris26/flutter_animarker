// Package imports:
import 'dart:typed_data';

import 'package:flutter_animarker/helpers/spherical_util.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_animarker/core/i_lat_lng.dart';
import 'package:flutter_animarker/animation/location_tween.dart';
import 'package:flutter_animarker/models/lat_lng_info.dart';
import 'package:flutter_animarker/infrastructure/interpolators/line_location_interpolator_impl.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

void main() {
  group('Location Tween Interpolation', () {
    late MarkerId markerId;
    late ILatLng begin;
    late ILatLng end;
    setUpAll(() {
      markerId = MarkerId('MarkerId1');
      begin = LatLngInfo(18.48817486792756, -69.95916740356776, markerId);
      end = LatLngInfo(18.48883880652183, -69.94596808528654, markerId);
    });

    test('Just after constructor initialization [begin, end] angle should keep their values', () {
      var interpolation = LineLocationInterpolatorImpl(begin: begin, end: end);
      var locationTween = LocationTween(interpolator: interpolation);
      var resultBegin = locationTween.begin;
      var resultEnd = locationTween.end;

      expect(resultBegin, equals(begin));
      expect(resultEnd, equals(end));
    });

    test('Ensure that [begin, end] angles have\'nt changed after calling lerp or transform  method', () {
      var t = 0.67854;
      var interpolation = LineLocationInterpolatorImpl(begin: begin, end: end);
      var locationTween = LocationTween(interpolator: interpolation);
      locationTween.lerp(t); //Calling lerp() method for interpolation
      locationTween.transform(t); //Calling transform() method for interpolation
      var resultBegin = locationTween.begin;
      var resultEnd = locationTween.end;

      expect(resultBegin, equals(begin));
      expect(resultEnd, equals(end));
    });

    test('When swap() value the end position should become the begin, and new position the end', () {

      var newPosition = begin.copyWith(latitude: 18.487800925381627, longitude: -69.94350047076894);

      var interpolation = LineLocationInterpolatorImpl(begin: end, end: end);
      var locationTween = LocationTween(interpolator: interpolation);

      locationTween.swap(newPosition);

      expect(locationTween.begin, equals(end));
      expect(locationTween.end, equals(newPosition));
    });

    test('''If begin and end locations are equal the result should be empty,
        no matter (t) position on the timeline''', () {
      var t = 0.5;
      var interpolation = LineLocationInterpolatorImpl(begin: end, end: end);
      var locationTween = LocationTween(interpolator: interpolation);
      var result = locationTween.lerp(t);
      var transformResult = locationTween.transform(t);

      expect(result, equals(end));
      expect(transformResult, equals(result));
    });

    test('lerp(t) should return the same begin location at 0.0 (t) position on the timeline', () {
      var t = 0.0;

      var interpolation = LineLocationInterpolatorImpl(begin: begin, end: end);
      var locationTween = LocationTween(interpolator: interpolation);
      var result = locationTween.lerp(t);

      expect(result, equals(begin));
    });

    test('transform(t) should return the same begin location at 0.0 (t) position on the timeline', () {
      var t = 0.0;

      var interpolation = LineLocationInterpolatorImpl(begin: begin, end: end);
      var locationTween = LocationTween(interpolator: interpolation);
      var result = locationTween.transform(t);

      expect(result, equals(begin));
    });

    test('''lerp(t) should return the same end location at 1.0 (t) 
           position on the timeline when is Stopper''', () {
      var t = 1.0;

      var endStopover = end.copyWith(isStopover: true);
      var interpolation = LineLocationInterpolatorImpl(begin: begin, end: endStopover);
      var locationTween = LocationTween(interpolator: interpolation);
      var result = locationTween.lerp(t);

      expect(result, equals(endStopover));
    });

    test(
        'transform(t) should return the same end location at 1.0 (t) position on the timeline when is Stopper',
        () {
      var t = 1.0;

      var endStopover = end.copyWith(isStopover: true);
      var interpolation = LineLocationInterpolatorImpl(begin: begin, end: endStopover);
      var locationTween = LocationTween(interpolator: interpolation);
      var result = locationTween.transform(t);

      expect(result, equals(endStopover));
    });

    test('''lerp(t) should return the middle point between begin-end
           location at 1.0 (t) position on the timeline''', () {
      var t = 0.5;
      var middleLocation = begin.copyWith(latitude: 18.488506679751602, longitude: -69.95256710663962);

      var interpolation = LineLocationInterpolatorImpl(begin: begin, end: end);
      var locationTween = LocationTween(interpolator: interpolation);
      var result = locationTween.lerp(t);

      expect(result, equals(middleLocation));
    });

    test(
        'transform(t) should return the middle point between begin-end location at 1.0 (t) position on the timeline',
        () {
      var t = 0.5;
      var middleLocation = begin.copyWith(latitude: 18.488506679751602, longitude: -69.95256710663962);

      var interpolation = LineLocationInterpolatorImpl(begin: begin, end: end);
      var locationTween = LocationTween(interpolator: interpolation);
      var result = locationTween.transform(t);

      expect(result, equals(middleLocation));
    });

    test('''lerp(t) should returns same result that source function interpolation
           (SphericalUtil.interpolate) returns, acting as control''', () {
      var t = 0.5;
      var fromVectorNorm = SphericalUtil.toVector3(begin.latitude, begin.longitude).normalized();
      var toVectorNorm = SphericalUtil.toVector3(end.latitude, end.longitude).normalized();
      var float32x4FromVector = Float32x4(fromVectorNorm.x, fromVectorNorm.y, fromVectorNorm.z, 0);
      var float32x4ToVector = Float32x4(toVectorNorm.x, toVectorNorm.y, toVectorNorm.z, 0);

      //
      var float32x4Delta = float32x4ToVector - float32x4FromVector;
      var interpolation = LineLocationInterpolatorImpl(begin: begin, end: end);
      var locationTween = LocationTween(interpolator: interpolation);
      var result = locationTween.lerp(t);
      var control = SphericalUtil.vectorInterpolateOptimized(float32x4Delta, float32x4FromVector, t)
          .copyWith(markerId: markerId);

      expect(result, equals(control));
    });

    test('Location between [begin, end], no inclusive, are not stopover', () {
      var t = Stream<double>.fromIterable([0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 0.99999999]);

      var interpolation = LineLocationInterpolatorImpl(begin: begin, end: end);
      var locationTween = LocationTween(interpolator: interpolation);

      t.listen(expectAsync1<void, double>(
        (t) {
          var result = locationTween.lerp(t);

          expect(result.isStopover, isFalse);
        },
        count: 10,
      ));
    });

    test('Location between begin-end using transform(t), no inclusive, just end position should stopover',
        () {
      var t = Stream<double>.fromIterable([0.0, 1.0]);

      var interpolation = LineLocationInterpolatorImpl(begin: begin, end: end);
      var locationTween = LocationTween(interpolator: interpolation);

      t.listen(expectAsync1<void, double>(
        (t) {
          var result = locationTween.transform(t);

          if (result == end) {
            expect(result.isStopover, isTrue);
          } else if (result == begin) {
            expect(result.isStopover, isFalse);
          } else {
            Evaluation.fail();
          }
        },
        count: 2,
      ));
    });

    test('Test the different swap position ways: [begin-end] properties', () {
      var interpolation = LineLocationInterpolatorImpl(begin: begin, end: end);
      var locationTween = LocationTween(interpolator: interpolation);
      var newPosition = LatLngInfo(18.48430279636411, -69.94079341600313, markerId); //new location updates

      locationTween.begin = locationTween.end;
      locationTween.end = newPosition;

      var newBeginPosition = locationTween.begin;
      var newEndPosition = locationTween.end;

      expect(newBeginPosition, equals(end));
      expect(newEndPosition, equals(newPosition));
    });

    test('Test the different swap position ways: .interpolator.swap()', () {
      var interpolation = LineLocationInterpolatorImpl(begin: begin, end: end);
      var locationTween = LocationTween(interpolator: interpolation);
      var newPosition = LatLngInfo(18.48430279636411, -69.94079341600313, markerId); //new location updates

      locationTween.swap(newPosition);

      var newBeginPosition = locationTween.begin;
      var newEndPosition = locationTween.end;

      expect(newBeginPosition, equals(end));
      expect(newEndPosition, equals(newPosition));
    });

    test('Test the different swap position ways: + operator', () {
      var interpolation = LineLocationInterpolatorImpl(begin: begin, end: end);
      var locationTween = LocationTween(interpolator: interpolation);
      var newPosition = LatLngInfo(18.48430279636411, -69.94079341600313, markerId); //new location updates

      locationTween += newPosition;

      var newBeginPosition = locationTween.begin;
      var newEndPosition = locationTween.end;

      expect(newBeginPosition, equals(end));
      expect(newEndPosition, equals(newPosition));
    });

    test('''The tween begin-end need to be swappable, to be interpolated 
          from the last position to a new one, and so on''', () {
      var t = 0.0;
      var interpolation = LineLocationInterpolatorImpl(begin: begin, end: end);
      var locationTween = LocationTween(interpolator: interpolation);

      var newPosition = LatLngInfo(18.48430279636411, -69.94079341600313, markerId); //new location updates

      locationTween += newPosition;
      locationTween.lerp(t);

      expect(locationTween.begin, end);
      expect(locationTween.end, equals(newPosition));

      var newPosition2 = LatLngInfo(18.4658611180733, -69.93044604942473, markerId); //new location updates

      locationTween += newPosition2;
      locationTween.lerp(t);

      expect(locationTween.begin, equals(newPosition));
      expect(locationTween.end, equals(newPosition2));

      ILatLng newPosition3 = LatLngInfo(18.451382274885972, -69.92247245553017, markerId);

      locationTween += newPosition3;
      locationTween.lerp(t);

      expect(locationTween.begin, equals(newPosition2));
      expect(locationTween.end, equals(newPosition3));

      var result = locationTween.lerp(t);

      locationTween += result;

      locationTween.lerp(t);

      expect(locationTween.begin, newPosition3);
      expect(locationTween.end, equals(result));
    });
  });
}
