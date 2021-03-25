//https://math.stackexchange.com/questions/654315/how-to-convert-a-dot-product-of-two-vectors-to-the-angle-between-the-vectors

// Dart imports:
import 'dart:math';
import 'dart:typed_data';

// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:vector_math/vector_math.dart';
import 'package:flutter_animarker/helpers/extensions.dart';

// Project imports:
import 'package:flutter_animarker/core/i_lat_lng.dart';
import 'package:flutter_animarker/helpers/math_util.dart';
import 'package:flutter_animarker/models/lat_lng_info.dart';

void main() {

  ILatLng x1 = LatLngInfo(18.48817486792756, -69.95916740356776, MarkerId(''));
  ILatLng x2 = LatLngInfo(18.48883880652183, -69.94596808528654, MarkerId(''));
  ILatLng x3 = LatLngInfo(18.48430279636411, -69.94079341600313, MarkerId(''));
  ILatLng x4 = LatLngInfo(18.4658611180733, -69.93044604942473, MarkerId(''));
  ILatLng x5 = LatLngInfo(18.451382274885972, -69.92247245553017, MarkerId(''));
  ILatLng x6 = LatLngInfo(18.447016157112476, -69.92433932762283, MarkerId(''));

  var interpolators = [0.0, 0.1457, 0.26587, 0.3687, 0.4789, 0.5412, 0.67854, 0.785645, 0.865645, 0.97844, 1.0];

  var multipoints = [x1, x2, x3, x4, x5, x6];

  var stopAt = interpolators[10];

  test('Test Piecewise', (){

    var xMin = 0.0;
    var xMax = 1.0;

    var ranges = <double>[];
    var results =  <Vector3>[];

    var xStep = (xMax - xMin) / (multipoints.length - 1);

    for (num i = 0, x = xMin; x <= xMax; x += xStep, i++) {

      var index = i.toInt();

      var latLng = multipoints[index];

      var  vector = toVector3(latLng.latitude, latLng.longitude);

      ranges.insert(index, x.toDouble());

      results.insert(index, vector);
    }

    for (var interpolator in interpolators)
    {
      var i = piecewiseLerp(ranges, results, interpolator);

      final lat = atan2(i.z, sqrt(i.x * i.x + i.y * i.y));
      final lng = atan2(i.y, i.x);

      print('No Optimized: (${lat.degrees}, ${lng.degrees}) at $interpolator');

      if(interpolator == stopAt) break;
    }
  });

  test('Test Piecewise Float32x4', (){

    var step = 1 / (multipoints.length - 1);

    var  preListFloat32x4 = Float32x4List(multipoints.length);

    for (num i = 0, x = 0; x <= 1; x += step, i++) {
      var index = i.toDouble();
      var t = x.toDouble();

      var vector = latLngtoVector3(multipoints[index.toInt()]);

      preListFloat32x4[index.toInt()] = Float32x4(vector.x, vector.y, vector.z, t);
      //x => vector x, y => vector y, z => vector z, w => (t) position
    }

    var lastFloat32x4 = preListFloat32x4.last;

    for (var interpolator in interpolators)
    {
      var vector = vectorSlerp(preListFloat32x4, lastFloat32x4, step, interpolator.clamp(0.0, 1.0));

      var xxxx = vector.shuffle(Float32x4.xxxx);
      var yyyy = vector.shuffle(Float32x4.yyyy);

      var sum = xxxx * xxxx + yyyy * yyyy;

      var sqrt = sum.sqrt();

      final lat = atan2(vector.z, sqrt.x);
      final lng = atan2(vector.y, vector.x);

      //LatLng(lat.degrees, lng.degrees);
      print('   Optimized: (${lat.degrees}, ${lng.degrees}) at $interpolator');
      if(interpolator == stopAt) break;
    }

  });


  /*test('Test multiline', () {

    ILatLng x1 = LatLngInfo(18.48817486792756, -69.95916740356776, MarkerId(''));
    ILatLng x2 = LatLngInfo(18.48883880652183, -69.94596808528654, MarkerId(''));
    ILatLng x3 = LatLngInfo(18.48430279636411, -69.94079341600313, MarkerId(''));
    ILatLng x4 = LatLngInfo(18.4658611180733, -69.93044604942473, MarkerId(''));
    ILatLng x5 = LatLngInfo(18.451382274885972, -69.92247245553017, MarkerId(''));
    ILatLng x6 = LatLngInfo(18.447016157112476, -69.92433932762283, MarkerId(''));

    var multipoints = [x1, x2, x3, x4, x5, x6];

    var vectors = [];

    for(var location in multipoints){
      var  vector = toVector3(location.latitude, location.longitude);
      vectors.add(vector.normalized());
    }
  });*/

}

Vector3 latLngtoVector3(ILatLng iLatLng) {
  var latRad = iLatLng.latitude.radians;
  var lonRad = iLatLng.longitude.radians;

  var x = cos(lonRad) * cos(latRad);
  var y = sin(lonRad) * cos(latRad);
  var z = sin(latRad);

  return Vector3(x, y, z);
}

Float32x4 vectorSlerp(
    Float32x4List preList,
    Float32x4 last,
    double step,
    double t,
    ) {
  var matchedRangeStartIndex = (t / step).toInt();

  var length = preList.length - 1;

  if (matchedRangeStartIndex == length) return last;

  var modulus = t >= step ? (t - matchedRangeStartIndex * step) : t;

  var segment = modulus / step;

  return lerpUnclamped(
    preList[matchedRangeStartIndex],
    preList[matchedRangeStartIndex + 1],
    Float32x4.splat(segment),
  );
}

Float32x4 lerpUnclamped(Float32x4 min, Float32x4 max, Float32x4 x) {
  return min + (max - min) * x;
}


Vector3 toVector3(double lat, double lon){
  var latRad = MathUtil.toRadians(lat).toDouble();
  var lonRad = MathUtil.toRadians(lon).toDouble();
  var x = cos(lonRad)*cos(latRad);
  var y = sin(lonRad)*cos(latRad);
  var z = sin(latRad);

  return Vector3(x, y, z);
}

Vector3 slerp(Vector3 p0, Vector3 p1, double t){

  var theta = p0.angleTo(p1);
  var sin1 = sin((1-t)*theta);
  var sin2 = sin(t*theta);
  var sin3 = sin(theta);

  var x1 = p0*sin1;
  var x2 = p1*sin2;

  return ((x1 + x2) / sin3);
}

Vector3 piecewiseLerp(List<double> inputs, List<Vector3> results, double desiredInput)
{
  var n = inputs.length;
  var inputMin = inputs[0];
  var inputMax = inputs[n - 1];

  // Don't support extrapolation:
  if (desiredInput < inputMin) {
    return results[0];
  }
  if (desiredInput >= inputMax) {
    return results[n - 1];
  }

  // Map to values that correspond to the array index progression
  var percent = inverseLerp(inputMin, inputMax, desiredInput);

  var step = 1 / (n - 1);

  var matchedRangeStartIndex = percent ~/ step;

  var matchedRangePct = (percent % step) / step;

  return lerpUnclamped2(results[matchedRangeStartIndex], results[matchedRangeStartIndex + 1], matchedRangePct);
}

Vector3 lerpUnclamped2(Vector3 min, Vector3 max, double x)
{
  return min + (max - min) * x;
}

double inverseLerp(double min, double max, double value)
{
  if (min == max) {
    return min;
  }
  return (value - min) / (max - min);
}
