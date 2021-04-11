// Package imports:
import 'package:flutter_animarker/animation/bearing_tween.dart';
import 'package:flutter_animarker/infrastructure/interpolators/angle_interpolator_impl.dart';
import 'package:flutter_test/flutter_test.dart';

// Project imports:
//import 'package:flutter_animarker/anims/bearing_tween.dart';

void main() {
  group('Angle Tween Interpolation', () {
    test('''Transform should return begin angle at 0.0 position (t) on timeline,
            either using shortest angle or not''', () {
      var useShortestAngle = Stream<bool>.fromIterable([true, false]);
      var beginAngle = 152.0;
      var endAngle = 345.0;
      var t = 0.0;

      useShortestAngle.listen(
        expectAsync1<void, bool>(
          (value) {
            var interpolator = AngleInterpolatorImpl(
                begin: beginAngle, end: endAngle, findShortestAngle: value);
            var angleTween = BearingTween(interpolator: interpolator);
            var resultBegin = angleTween.transform(t);

            expect(resultBegin, equals(beginAngle));
          },
          count: 2,
        ),
      );
    });

    test(
        'Transform should return end shortest angle at 1.0 position (t) on timeline',
        () {
      var useShortestAngle = Stream<bool>.fromIterable([true, false]);
      var beginAngle = 152.0;
      var endAngle = 345.0;
      var t = 1.0;

      useShortestAngle.listen(
        expectAsync1<void, bool>(
          (value) {
            var interpolator = AngleInterpolatorImpl(
                begin: beginAngle, end: endAngle, findShortestAngle: value);
            var angleTween = BearingTween(interpolator: interpolator);
            var shortestAngle =
                value ? ((endAngle - beginAngle) + 180) % 360 - 180 : endAngle;
            var resultEnd = angleTween.transform(t);

            expect(resultEnd, equals(shortestAngle));
          },
          count: 2,
        ),
      );
    });

    test(
        'Just after constructor initialization [begin-end] angle should keep their values',
        () {
      var useShortestAngle = Stream<bool>.fromIterable([true, false]);
      var beginAngle = 265.0;
      var endAngle = 352.0;

      useShortestAngle.listen(
        expectAsync1<void, bool>(
          (value) {
            var interpolator = AngleInterpolatorImpl(
                begin: beginAngle, end: endAngle, findShortestAngle: value);
            var angleTween = BearingTween(interpolator: interpolator);
            var resultBegin = angleTween.begin;
            var shortestAngle =
                value ? ((endAngle - beginAngle) + 180) % 360 - 180 : endAngle;
            var resultEnd = angleTween.end;

            expect(resultBegin, equals(beginAngle));
            expect(resultEnd, equals(shortestAngle));
          },
          count: 2,
        ),
      );
    });

    test(
        'Ensure that [begin,end] angles have\'nt changed after calling lerp method',
        () {
      var useShortestAngle = Stream<bool>.fromIterable([true, false]);
      var beginAngle = 85.0;
      var endAngle = 196.0;
      var t = 0.68;

      useShortestAngle.listen(
        expectAsync1<void, bool>(
          (value) {
            var interpolator = AngleInterpolatorImpl(
                begin: beginAngle, end: endAngle, findShortestAngle: value);
            var angleTween = BearingTween(interpolator: interpolator);
            angleTween.lerp(t); //Calling lerp method for interpolation
            var resultBegin = angleTween.begin;
            var shortestAngle =
                value ? ((endAngle - beginAngle) + 180) % 360 - 180 : endAngle;
            var resultEnd = angleTween.end;

            expect(resultBegin, equals(beginAngle));
            expect(resultEnd, equals(shortestAngle));
          },
          count: 2,
        ),
      );
    });

    test(
        'If begin and end angles are equal the result should be zero, not matter (t) position on the timeline',
        () {
      var useShortestAngle = Stream<bool>.fromIterable([true, false]);
      var beginAngle = 180.0;
      var endAngle = 180.0;
      var t = 0.5;

      useShortestAngle.listen(
        expectAsync1<void, bool>(
          (value) {
            var interpolator = AngleInterpolatorImpl(
                begin: beginAngle, end: endAngle, findShortestAngle: value);
            var angleTween = BearingTween(interpolator: interpolator);
            var result = angleTween.lerp(t);

            expect(result, isZero);
          },
          count: 2,
        ),
      );
    });

    test(
        'Lerp should return the same begin angle at 0.0 (t) position on the timeline',
        () {
      var useShortestAngle = Stream<bool>.fromIterable([true, false]);
      var beginAngle = 90.0;
      var endAngle = 270.0;
      var t = 0.0;

      useShortestAngle.listen(
        expectAsync1<void, bool>(
          (value) {
            var interpolator = AngleInterpolatorImpl(
                begin: beginAngle, end: endAngle, findShortestAngle: value);
            var angleTween = BearingTween(interpolator: interpolator);
            var result = angleTween.lerp(t);

            expect(result, equals(beginAngle));
          },
          count: 2,
        ),
      );
    });

    test(
        '''lerp(t) should return the shortest angle from begin to end angle at (t) position
            on the timeline, either clockwise ot counterclockwise''', () {
      var useShortestAngle = Stream<bool>.fromIterable([true, false]);
      var beginAngle = 90.0;
      var endAngle = 355.0;
      var t = 1.0;

      useShortestAngle.listen(
        expectAsync1<void, bool>(
          (value) {
            var interpolator = AngleInterpolatorImpl(
                begin: beginAngle, end: endAngle, findShortestAngle: value);
            var angleTween = BearingTween(interpolator: interpolator);
            var result = angleTween.lerp(t);
            var shortestAngle =
                value ? ((endAngle - beginAngle) + 180) % 360 - 180 : endAngle;

            expect(result, equals(shortestAngle));
          },
          count: 2,
        ),
      );
    });

    //
    test(
        '''lerp(t) should return counterclockwise angles if the delta (end-begin) is
             greater than 180 degrees at 1.0 (t) position on the timeline''',
        () {
      var useShortestAngle = Stream<bool>.fromIterable([true, false]);
      var beginAngle = 45.0;
      var endAngle = 270.0;
      var t = 1.0;

      useShortestAngle.listen(
        expectAsync1<void, bool>(
          (value) {
            var interpolator = AngleInterpolatorImpl(
                begin: beginAngle, end: endAngle, findShortestAngle: value);
            var angleTween = BearingTween(interpolator: interpolator);
            var result = angleTween.lerp(t);

            //After 180 degrees of difference the shortest angles are negative of counterclockwise for angles < 360 degrees
            expect(result, value ? isNegative : isPositive);
          },
          count: 2,
        ),
      );
    });

    test('''lerp(t) should return zero when trying to interpolate between angles
            less than 1e-6 (scientific notation)''', () {
      var useShortestAngle = Stream<bool>.fromIterable([true, false]);
      var beginAngle = 0.1;
      var endAngle = 0.0;
      var t = 0.5;

      useShortestAngle.listen(
        expectAsync1<void, bool>(
          (value) {
            var interpolator = AngleInterpolatorImpl(
                begin: beginAngle, end: endAngle, findShortestAngle: value);
            var angleTween = BearingTween(interpolator: interpolator);
            var result = angleTween.lerp(t);

            expect(result, isZero);
          },
          count: 2,
        ),
      );
    });
  });
}
