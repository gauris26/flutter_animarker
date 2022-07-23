// Package imports:
import 'package:flutter_animarker/animation/bearing_tween.dart';
import 'package:flutter_animarker/infrastructure/interpolators/angle_interpolator_impl.dart';
import 'package:flutter_test/flutter_test.dart';

// Project imports:

void main() {
  group('Angle Tween Interpolation', () {
    test('Transform should return begin angle at 0.0 position (t) on timeline',
        () {
      var beginAngle = 152.0;
      var endAngle = 345.0;
      var t = 0.0;

      var interpolator =
          AngleInterpolatorImpl(begin: beginAngle, end: endAngle);
      var angleTween = BearingTween(interpolator: interpolator);
      var resultBegin = angleTween.transform(t);

      expect(resultBegin, equals(beginAngle));
    });

    test('lerp should return begin angle at 0.0 position (t) on timeline', () {
      var beginAngle = 152.0;
      var endAngle = 345.0;
      var t = 0.0;

      var interpolator =
          AngleInterpolatorImpl(begin: beginAngle, end: endAngle);
      var angleTween = BearingTween(interpolator: interpolator);
      var resultBegin = angleTween.lerp(t);

      expect(resultBegin, equals(beginAngle));
    });

    test('Transform should return end angle at 1.0 position (t) on timeline',
        () {
      var beginAngle = 152.0;
      var endAngle = 345.0;
      var t = 1.0;

      var interpolator =
          AngleInterpolatorImpl(begin: beginAngle, end: endAngle);
      var angleTween = BearingTween(interpolator: interpolator);
      var resultEnd = angleTween.transform(t);

      expect(resultEnd, equals(endAngle));
    });

    test('lerp should return end angle at 1.0 position (t) on timeline', () {
      var beginAngle = 152.0;
      var endAngle = 345.0;
      var t = 1.0;

      var interpolator =
          AngleInterpolatorImpl(begin: beginAngle, end: endAngle);
      var angleTween = BearingTween(interpolator: interpolator);
      var resultEnd = angleTween.lerp(t);

      expect(resultEnd, equals(endAngle));
    });

    test(
        'lerp and transform should return the same value at any position (t) on timeline',
        () {
      var beginAngle = 152.0;
      var endAngle = 345.0;
      var t = 0.4879954788;

      var interpolator =
          AngleInterpolatorImpl(begin: beginAngle, end: endAngle);
      var angleTween = BearingTween(interpolator: interpolator);
      var lerpEnd = angleTween.lerp(t);
      var transformEnd = angleTween.transform(t);

      expect(lerpEnd, equals(transformEnd));
    });

    test(
        'When swap() value the end position should become the begin, and new position the end',
        () {
      var beginAngle = 152.0;
      var endAngle = 345.0;
      var newAngle = 58.0;

      var interpolator =
          AngleInterpolatorImpl(begin: beginAngle, end: endAngle);
      var angleTween = BearingTween(interpolator: interpolator);

      angleTween.swap(newAngle);

      expect(angleTween.begin, equals(endAngle));
      expect(angleTween.end, equals(newAngle));
    });

    test(
        'Just after constructor initialization [begin-end] angle should keep their values',
        () {
      var beginAngle = 265.0;
      var endAngle = 352.0;

      var interpolator =
          AngleInterpolatorImpl(begin: beginAngle, end: endAngle);
      var angleTween = BearingTween(interpolator: interpolator);
      var resultBegin = angleTween.begin;
      var resultEnd = angleTween.end;

      expect(resultBegin, equals(beginAngle));
      expect(resultEnd, equals(endAngle));
    });

    test(
        'Ensure that [begin,end] angles have\'nt changed after calling lerp method',
        () {
      var beginAngle = 85.0;
      var endAngle = 196.0;
      var t = 0.68;

      var interpolator =
          AngleInterpolatorImpl(begin: beginAngle, end: endAngle);
      var angleTween = BearingTween(interpolator: interpolator);
      angleTween.lerp(t); //Calling lerp method for interpolation
      var resultBegin = angleTween.begin;
      var resultEnd = angleTween.end;

      expect(resultBegin, equals(beginAngle));
      expect(resultEnd, equals(endAngle));
    });

    test(
        'If [begin,end] angles are equal the result should the end angle, not matter (t) position on the timeline',
        () {
      var beginAngle = 165.0;
      var endAngle = 165.0;
      var t = 0.5;

      var interpolator =
          AngleInterpolatorImpl(begin: beginAngle, end: endAngle);
      var angleTween = BearingTween(interpolator: interpolator);
      var result = angleTween.lerp(t);

      expect(result, endAngle);
    });

    test(
        'Lerp should return the same begin angle at 0.0 (t) position on the timeline',
        () {
      var beginAngle = 90.0;
      var endAngle = 270.0;
      var t = 0.0;

      var interpolator =
          AngleInterpolatorImpl(begin: beginAngle, end: endAngle);
      var angleTween = BearingTween(interpolator: interpolator);
      var result = angleTween.lerp(t);

      expect(result, equals(beginAngle));
    });

    test(
        '''lerp(t) should return the shortest angle from begin to end angle at (t) position
            on the timeline, either clockwise ot counterclockwise''', () {
      var beginAngle = 90.0;
      var endAngle = 355.0;
      var t = 1.0;

      var interpolator =
          AngleInterpolatorImpl(begin: beginAngle, end: endAngle);
      var angleTween = BearingTween(interpolator: interpolator);
      var result = angleTween.lerp(t);

      expect(result, equals(endAngle));
    });

    test('''lerp(t) should return zero when trying to interpolate between
            small angles less than 1e-6 (scientific notation)''', () {
      var beginAngle = 0.00000001;
      var endAngle = 0.000000003;
      var t = 0.5;

      var interpolator =
          AngleInterpolatorImpl(begin: beginAngle, end: endAngle);
      var angleTween = BearingTween(interpolator: interpolator);
      var result = angleTween.lerp(t);

      expect(result, isZero);
    });
  });
}
