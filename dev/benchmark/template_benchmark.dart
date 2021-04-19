import 'dart:typed_data';
import 'dart:math' as math;
import 'package:vector_math/vector_math.dart';
import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:flutter_animarker/helpers/math_util.dart';

LatLng x1 = LatLng(18.48817486792756, -69.95916740356776);
LatLng x2 = LatLng(18.48883880652183, -69.94596808528654);
LatLng x3 = LatLng(18.48430279636411, -69.94079341600313);
LatLng x4 = LatLng(18.4658611180733, -69.93044604942473);
LatLng x5 = LatLng(18.451382274885972, -69.92247245553017);
LatLng x6 = LatLng(18.447016157112476, -69.92433932762283);

// Create a new benchmark by extending BenchmarkBase
class TemplateBenchmark extends BenchmarkBase {
  TemplateBenchmark() : super('Template');
  late final double step;

  final List<LatLng> points = [x1, x2, x3, x4, x5, x6];
  double _step = 0;
  late final Float32x4List _preListFloat32x4;
  late final Float32x4 stepFloat32x4;
  late final Float32x4 lastFloat32x4;
  late final bool isEqualValue;

  static void main() {
    TemplateBenchmark().report();
  }

  // The benchmark code.
  @override
  void run() {
    for (var i = 0.0; i <= 1.0; i += step) {
      var vector = vectorSlerp(
          _preListFloat32x4, lastFloat32x4, _step, i.clamp(0.0, 1.0));

      var xxxx = vector.shuffle(Float32x4.xxxx);
      var yyyy = vector.shuffle(Float32x4.yyyy);

      var sum = xxxx * xxxx + yyyy * yyyy;

      var sqrt = sum.sqrt();

      final lat = math.atan2(vector.z, sqrt.x);
      final lng = math.atan2(vector.y, vector.x);

      LatLng(lat.degrees, lng.degrees);
    }
  }

  // Not measured setup code executed prior to the benchmark runs.
  @override
  void setup() {
    step = 1 / 10000;

    _step = 1 / (points.length - 1);

    _preListFloat32x4 = Float32x4List(points.length);

    for (num i = 0, x = 0; x <= 1; x += _step, i++) {
      var index = i.toInt();
      var t = x.toDouble();

      var vector = latLngtoVector3(points[index.toInt()]);

      _preListFloat32x4[index] = Float32x4(vector.x, vector.y, vector.z, t);
      //x => vector x, y => vector y, z => vector z, w => (t) position
    }
    lastFloat32x4 = _preListFloat32x4.last;
  }

  // Not measured teardown code executed after the benchmark runs.
  @override
  void teardown() {}
}

// ignore: always_declare_return_types
main() {
  // Run TemplateBenchmark
  TemplateBenchmark.main();
}

/// vectorSlerp
Float32x4 vectorSlerp(
    Float32x4List preList, Float32x4 last, double step, double t) {
  // ignore: division_optimization
  var matchedRangeStartIndex = (t / step).toInt();
  //var matchedRangeStartIndex = t ~/ step;
  //var matchedRangeStartIndex = (t / step).truncate();
  //var matchedRangeStartIndex = (Float32x4.splat(t) / Float32x4.splat(step)).x.truncate();

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

class LatLng {
  final double latitude;
  final double longitude;
  LatLng(this.latitude, this.longitude);

  @override
  String toString() {
    return 'LatLng{latitude: $latitude, longitude: $longitude}';
  }
}

Float32x4 latLngtoFloat32x4(Vector3 vector3) =>
    Float32x4(vector3.x, vector3.y, vector3.z, 0);

Vector3 latLngtoVector3(LatLng iLatLng) {
  var latRad = iLatLng.latitude.radians;
  var lonRad = iLatLng.longitude.radians;

  var x = math.cos(lonRad) * math.cos(latRad);
  var y = math.sin(lonRad) * math.cos(latRad);
  var z = math.sin(latRad);

  return Vector3(x, y, z);
}

extension DoubleEx on double {
  double get radians => MathUtil.toRadians(this).toDouble();
  double get degrees => MathUtil.toDegrees(this).toDouble();
}

Float32x4 inverseLerp(Float32x4 min, Float32x4 max, Float32x4 delta,
    bool isEqualValue, Float32x4 value) {
  var mask = min.equal(max);
  if (mask.flagX && mask.flagY && mask.flagZ) return min;
  return (value - min) / delta;
}

Float32x4 lerpUnclamped(Float32x4 min, Float32x4 max, Float32x4 x) {
  return min + (max - min) * x;
}
