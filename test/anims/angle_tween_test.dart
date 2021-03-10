import 'package:flutter_animarker/anims/angle_tween.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {

  group("Angle Tween Interpolation", () {
    test('Transform should return begin angle at 0.0 position (t) on timeline', () {
      double beginAngle = 152;
      double endAngle = 345;
      double t = 0.0;

      AngleTween angleTween = AngleTween(begin: beginAngle, end: endAngle);
      double resultBegin = angleTween.transform(t);

      expect(resultBegin, equals(beginAngle));
    });

    test('Transform should return end angle at 1.0 position (t) on timeline', () {
      double beginAngle = 152;
      double endAngle = 345;
      double t = 1.0;

      AngleTween angleTween = AngleTween(begin: beginAngle, end: endAngle);
      double resultEnd = angleTween.transform(t);

      expect(resultEnd, equals(endAngle));
    });

    test('Just after constructor initialization begin-end angle should keep their values', () {
      double beginAngle = 265;
      double endAngle = 352;

      AngleTween angleTween = AngleTween(begin: beginAngle, end: endAngle);
      double resultBegin = angleTween.begin;
      double resultEnd = angleTween.end;

      expect(resultBegin, equals(beginAngle));
      expect(resultEnd, equals(endAngle));
    });

    test('Ensure that [begin,end] angles have\'nt changed after calling lerp method', () {
      double beginAngle = 85;
      double endAngle = 196;
      double t = 0.68;

      AngleTween angleTween = AngleTween(begin: beginAngle, end: endAngle);
      angleTween.lerp(t); //Calling lerp method for interpolation
      double resultBegin = angleTween.begin;
      double resultEnd = angleTween.end;

      expect(resultBegin, equals(beginAngle));
      expect(resultEnd, equals(endAngle));
    });

    test(
        'After first lerp calling, the interpolated should be done from the previous angle at previous position (t) on timeline (not begin angle)',
        () {
      double beginAngle = 56;
      double endAngle = 156;
      double t1 = 0.6;
      double t2 = 0.0;
      double t3 = 1.0;

      AngleTween angleTween = AngleTween(begin: beginAngle, end: endAngle);
      double firstInterpolation = angleTween.lerp(t1);
      double secondInterpolation = angleTween.lerp(t2);
      double deltaAngle =
          endAngle - secondInterpolation; //The previous returned angle replace the "begin angle"
      double thirdInterpolation = angleTween.lerp(t3);

      expect(firstInterpolation, equals(secondInterpolation));
      expect(thirdInterpolation, equals(deltaAngle));
    });

    test(
        'If begin and end angles are equal the result should be zero, not matter (t) position on the timeline',
        () {
      double beginAngle = 180;
      double endAngle = 180;
      double t = 0.5;

      AngleTween angleTween = AngleTween(begin: beginAngle, end: endAngle);
      double result = angleTween.lerp(t);

      expect(result, isZero);
    });

    test('Lerp should return the same begin angle at 0.0 (t) position on the timeline', () {
      double beginAngle = 90;
      double endAngle = 270;
      double t = 0.0;

      AngleTween angleTween = AngleTween(begin: beginAngle, end: endAngle);
      double result = angleTween.lerp(t);

      expect(result, equals(beginAngle));
    });

    test(
        'lerp(t) should return the shortest angle to end angle at 1.0 (t) position on the timeline either clockwise ot counterclockwise',
        () {
      double beginAngle = 90;
      double endAngle = 355;
      double t = 1.0;

      AngleTween angleTween = AngleTween(begin: beginAngle, end: endAngle);
      double result = angleTween.lerp(t);

      //The largest angle is 265 degrees
      //The shortest angle is -95 degrees (counterclockwise)
      expect(result, equals(-95));
    });

    test(
        'lerp(t) should return counterclockwise angles if the delta (end-begin) is greater than 180 degrees at 1.0 (t) position on the timeline ',
        () {
      double beginAngle = 45;
      double endAngle = 270;
      double t = 1.0;

      AngleTween angleTween = AngleTween(begin: beginAngle, end: endAngle);
      double result = angleTween.lerp(t);

      //After 180 degrees of difference the shortest angles are negative of counterclockwise for angles < 360 degrees
      expect(result, isNegative);
    });

    test(
        'lerp(t) should return zero when trying to interpolate between angles less than 1e-6 (scientific notation)',
        () {
      double beginAngle = 0.1;
      double endAngle = 0;
      double t = 0.5;

      AngleTween angleTween = AngleTween(begin: beginAngle, end: endAngle);
      double result = angleTween.lerp(t);

      expect(result, isZero);
    });
  });
}
