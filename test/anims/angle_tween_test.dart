import 'package:flutter_animarker/anims/angle_tween.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Angle Tween Interpolation', () {
    test('Transform should return begin angle at 0.0 position (t) on timeline', () {
      var beginAngle = 152.0;
      var endAngle = 345.0;
      var t = 0.0;

      var angleTween = AngleTween(begin: beginAngle, end: endAngle);
      var resultBegin = angleTween.transform(t);

      expect(resultBegin, equals(beginAngle));
    });

    test('Transform should return end angle at 1.0 position (t) on timeline', () {
      var beginAngle = 152.0;
      var endAngle = 345.0;
      var t = 1.0;

      var angleTween = AngleTween(begin: beginAngle, end: endAngle);
      var resultEnd = angleTween.transform(t);

      expect(resultEnd, equals(endAngle));
    });

    test('Just after constructor initialization begin-end angle should keep their values', () {
      var beginAngle = 265.0;
      var endAngle = 352.0;

      var angleTween = AngleTween(begin: beginAngle, end: endAngle);
      var resultBegin = angleTween.begin;
      var resultEnd = angleTween.end;

      expect(resultBegin, equals(beginAngle));
      expect(resultEnd, equals(endAngle));
    });

    test('Ensure that [begin,end] angles have\'nt changed after calling lerp method', () {
      var beginAngle = 85.0;
      var endAngle = 196.0;
      var t = 0.68;

      var angleTween = AngleTween(begin: beginAngle, end: endAngle);
      angleTween.lerp(t); //Calling lerp method for interpolation
      var resultBegin = angleTween.begin;
      var resultEnd = angleTween.end;

      expect(resultBegin, equals(beginAngle));
      expect(resultEnd, equals(endAngle));
    });

    test(
        'After first lerp calling, the interpolated should be done from the previous angle at previous position (t) on timeline (not begin angle)',
        () {
      var beginAngle = 56.0;
      var endAngle = 156.0;
      var t1 = 0.6;
      var t2 = 0.0;
      var t3 = 1.0;

      var angleTween = AngleTween(begin: beginAngle, end: endAngle);
      var firstInterpolation = angleTween.lerp(t1);
      var secondInterpolation = angleTween.lerp(t2);
      //The previous returned angle replace the "begin angle"
      var deltaAngle = endAngle - secondInterpolation;
      var thirdInterpolation = angleTween.lerp(t3);

      expect(firstInterpolation, equals(secondInterpolation));
      expect(thirdInterpolation, equals(deltaAngle));
    });

    test(
        'If begin and end angles are equal the result should be zero, not matter (t) position on the timeline',
        () {
      var beginAngle = 180.0;
      var endAngle = 180.0;
      var t = 0.5;

      var angleTween = AngleTween(begin: beginAngle, end: endAngle);
      var result = angleTween.lerp(t);

      expect(result, isZero);
    });

    test('Lerp should return the same begin angle at 0.0 (t) position on the timeline', () {
      var beginAngle = 90.0;
      var endAngle = 270.0;
      var t = 0.0;

      var angleTween = AngleTween(begin: beginAngle, end: endAngle);
      var result = angleTween.lerp(t);

      expect(result, equals(beginAngle));
    });

    test(
        'lerp(t) should return the shortest angle to end angle at 1.0 (t) position on the timeline either clockwise ot counterclockwise',
        () {
      var beginAngle = 90.0;
      var endAngle = 355.0;
      var t = 1.0;

      var angleTween = AngleTween(begin: beginAngle, end: endAngle);
      var result = angleTween.lerp(t);

      //The largest angle is 265 degrees
      //The shortest angle is -95 degrees (counterclockwise)
      expect(result, equals(-95));
    });

    test(
        'lerp(t) should return counterclockwise angles if the delta (end-begin) is greater than 180 degrees at 1.0 (t) position on the timeline ',
        () {
      var beginAngle = 45.0;
      var endAngle = 270.0;
      var t = 1.0;

      var angleTween = AngleTween(begin: beginAngle, end: endAngle);
      var result = angleTween.lerp(t);

      //After 180 degrees of difference the shortest angles are negative of counterclockwise for angles < 360 degrees
      expect(result, isNegative);
    });

    test(
        'lerp(t) should return zero when trying to interpolate between angles less than 1e-6 (scientific notation)',
        () {
      var beginAngle = 0.1;
      var endAngle = 0.0;
      var t = 0.5;

      var angleTween = AngleTween(begin: beginAngle, end: endAngle);
      var result = angleTween.lerp(t);

      expect(result, isZero);
    });
  });
}
