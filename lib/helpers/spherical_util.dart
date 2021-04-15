// Port of SphericalUtil from android-maps-utils (https://github.com/googlemaps/android-maps-utils)
// https://docs.microsoft.com/en-us/bingmaps/articles/bing-maps-tile-system?redirectedfrom=MSDN

import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter_animarker/core/i_lat_lng.dart';
import 'package:flutter_animarker/helpers/extensions.dart';
import 'package:flutter_animarker/models/lat_lng_info.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:vector_math/vector_math.dart';

import 'math_util.dart';

abstract class SphericalUtil {
  static const double earthRadius = 6378137.0;
  static const double maxLatitude = 85.05112878;
  static const double minLatitude = -85.05112878;

  static num computeHeading(ILatLng from, ILatLng to) {
    final fromLat = MathUtil.toRadians(from.latitude);
    final fromLng = MathUtil.toRadians(from.longitude);
    final toLat = MathUtil.toRadians(to.latitude);
    final toLng = MathUtil.toRadians(to.longitude);
    final dLng = toLng - fromLng;
    var x = math.sin(dLng) * math.cos(toLat);
    var y = math.cos(fromLat) * math.sin(toLat) - math.sin(fromLat) * math.cos(toLat) * math.cos(dLng);
    final heading = math.atan2(x, y);

    return (heading.degrees + 360) % 360;
  }

  static double calculateZoomScale(double densityDpi, double zoomLevel, ILatLng target) {
    var dpi = densityDpi * 160;

    var mapwidth = 256.0 * math.pow(2, zoomLevel);
    var clipLatitude = math.min(math.max(target.latitude, minLatitude), maxLatitude);
    var angle = clipLatitude * math.pi / 180;
    var angleRadians = angle.radians;
    var groundResolution = (math.cos(angleRadians) * 2 * math.pi * SphericalUtil.earthRadius) / mapwidth;
    var mapScale = (groundResolution * dpi / 0.0254);

    return 1 / mapScale;
  }

  static double getBearing(ILatLng begin, ILatLng end) {
    var lat = (begin.latitude - end.latitude).abs();
    var lng = (begin.longitude - end.longitude).abs();

    if (begin.latitude < end.latitude && begin.longitude < end.longitude) {
      return MathUtil.toDegrees(math.atan(lng / lat)) as double /*+ 90*/;
    } else if (begin.latitude >= end.latitude && begin.longitude < end.longitude) {
      return ((90 - MathUtil.toDegrees(math.atan(lng / lat))) + 90) /*+ 45*/;
    } else if (begin.latitude >= end.latitude && begin.longitude >= end.longitude) {
      return (MathUtil.toDegrees(math.atan(lng / lat)) + 180) /*- 90*/;
    } else if (begin.latitude < end.latitude && begin.longitude >= end.longitude) {
      return ((90 - MathUtil.toDegrees(math.atan(lng / lat))) + 270) /*+ 90*/;
    }

    return -1;
  }

  /// Returns the LatLng which lies the given fraction of the way between the
  /// origin LatLng and the destination LatLng.
  /// @param from     The LatLng from which to start.
  /// @param to       The LatLng toward which to travel.
  /// @param fraction A fraction of the distance to travel.
  /// @return The interpolated LatLng.
  static ILatLng interpolate(ILatLng from, ILatLng to, num fraction) {
    if (from.isEmpty) return to;

    final fromLat = from.latitude.radians;
    final fromLng = from.longitude.radians;
    final toLat = to.latitude.radians;
    final toLng = to.longitude.radians;
    final cosFromLat = math.cos(fromLat);
    final cosToLat = math.cos(toLat);

    // Computes Spherical interpolation coefficients.
    final angle = computeAngleBetween(from, to);
    final sinAngle = math.sin(angle);

    if (sinAngle < 1E-6) {
      return LatLngInfo(
        from.latitude + fraction * (to.latitude - from.latitude),
        from.longitude + fraction * (to.longitude - from.longitude),
        from.markerId,
      );
    }

    final a = math.sin((1 - fraction) * angle) / sinAngle;
    final b = math.sin(fraction * angle) / sinAngle;

    // Converts from polar to vector and interpolate.
    final x = a * cosFromLat * math.cos(fromLng) + b * cosToLat * math.cos(toLng);
    final y = a * cosFromLat * math.sin(fromLng) + b * cosToLat * math.sin(toLng);
    final z = a * math.sin(fromLat) + b * math.sin(toLat);

    // Converts interpolated vector back to polar.
    final lat = math.atan2(z, math.sqrt(x * x + y * y));
    final lng = math.atan2(y, x);

    return LatLngInfo(
      lat.degrees,
      lng.degrees,
      from.markerId,
      ripple: from.ripple,
    );
  }

  static ILatLng vectorInterpolate(ILatLng from, ILatLng to, double t) {
    var min = toVector3(from.latitude, from.longitude).normalized();
    var max = toVector3(to.latitude, to.longitude).normalized();

    var value = min + (max - min) * t;

    return vectorToPolar(value);
  }

  static Vector3 toVector3(double lat, double lng) {
    var latRad = MathUtil.toRadians(lat).toDouble();
    var lonRad = MathUtil.toRadians(lng).toDouble();
    var x = math.cos(lonRad) * math.cos(latRad);
    var y = math.sin(lonRad) * math.cos(latRad);
    var z = math.sin(latRad);

    return Vector3(x, y, z);
  }

  static Vector3 latLngtoVector3(ILatLng iLatLng) {
    var latRad = iLatLng.latitude.radians;
    var lonRad = iLatLng.longitude.radians;

    var x = math.cos(lonRad) * math.cos(latRad);
    var y = math.sin(lonRad) * math.cos(latRad);
    var z = math.sin(latRad);

    return Vector3(x, y, z);
  }

  static ILatLng vectorToPolar(Vector3 i) {
    final lat = math.atan2(i.z, math.sqrt(i.x * i.x + i.y * i.y));
    final lng = math.atan2(i.y, i.x);

    return LatLngInfo(lat.degrees, lng.degrees, MarkerId(''));
  }

  static ILatLng vectorToPolarOptimized(Float32x4 vector) {
    var xxxx = vector.shuffle(Float32x4.xxxx);
    var yyyy = vector.shuffle(Float32x4.yyyy);

    var powerX = xxxx * xxxx;
    var powerY = yyyy * yyyy;

    var sum = powerX + powerY;

    var sqrt = sum.sqrt();

    final lat = math.atan2(vector.z, sqrt.x);
    final lng = math.atan2(vector.y, vector.x);

    return LatLngInfo(lat.degrees, lng.degrees, MarkerId(''));
  }

  static Float32x4 vectorSlerpOptimized(Float32x4List preList, Float32x4 last, double step, double t) {
    var matchedRangeStartIndex = t ~/ step;

    var length = preList.length - 1;

    if (matchedRangeStartIndex == length) return last;

    var modulus = t >= step ? (t - matchedRangeStartIndex * step) : t;

    var segment = modulus / step;

    return lerpUnclampedOptimized(
      preList[matchedRangeStartIndex],
      preList[matchedRangeStartIndex + 1],
      Float32x4.splat(segment),
    );
  }

  static Float32x4 lerpUnclampedOptimized(Float32x4 min, Float32x4 max, Float32x4 x) {
    return min + (max - min) * x;
  }

  static Vector3 vectorSlerp(List<double> inputs, List<Vector3> results, double desiredInput) {
    var n = inputs.length;
    var inputMin = inputs[0];
    var inputMax = inputs[n - 1];

    // Don't support extrapolation:
    if (desiredInput < inputMin) return results[0];
    if (desiredInput >= inputMax) return results[n - 1];

    // Map to values that correspond to the array index progression
    var percent = inverseLerp(inputMin, inputMax, desiredInput);
    var step = 1 / (n - 1);
    var matchedRangeStartIndex = percent ~/ step;
    var matchedRangePct = (percent % step) / step;

    return lerpUnclamped(
      results[matchedRangeStartIndex],
      results[matchedRangeStartIndex + 1],
      matchedRangePct,
    );
  }

  static double inverseLerp(double min, double max, double value) {
    if (min == max) return min;
    return (value - min) / (max - min);
  }

  static Float32x4 inverseLerpOptimized(
      Float32x4 min, Float32x4 max, Float32x4 delta, bool isEqualValue, Float32x4 value) {
    if (isEqualValue) return min;
    return (value - min) / delta;
  }

  static Vector3 lerpUnclamped(Vector3 min, Vector3 max, double x) {
    return min + (max - min) * x;
  }

  static num distanceRadians(num lat1, num lng1, num lat2, num lng2) =>
      MathUtil.arcHav(MathUtil.havDistance(lat1, lat2, lng1 - lng2));

  static num computeAngleBetween(ILatLng from, ILatLng to) => distanceRadians(
        from.latitude.radians,
        from.longitude.radians,
        to.latitude.radians,
        to.longitude.radians,
      );

  static double angleLerp(double from, double to, double t) {
    var shortestAngle = angleShortestDistance(from, to);

    var result = from + shortestAngle * t;

    //1e-6: the smallest value that is not stringified in scientific notation.
    //Prevent unwanted result [1e-6, -1e-6]
    if (result < 1e-6 && result > -1e-6) return 0;

    return result;
  }

  static double angleLerpOptimized(Float32x4 angle, Float32x4 from, double t) {
    var multiplier = Float32x4.splat(t);

    var result = from + angle * multiplier;

    return result.x;
  }

  static double angleShortestDistance(double from, double to) {
    return ((to - from) + 180) % 360 - 180;
  }

  static num computeDistanceBetween(ILatLng from, ILatLng to) => computeAngleBetween(from, to) * earthRadius;

  static double bearingBetweenLocations(LatLngInfo latLngFrom, LatLngInfo latLngTo) {
    var lat1 = latLngTo.latitude * math.pi / 180;
    var long1 = latLngTo.longitude * math.pi / 180;
    var lat2 = latLngFrom.latitude * math.pi / 180;
    var long2 = latLngFrom.longitude * math.pi / 180;

    var dLon = (long2 - long1);

    var y = math.sin(dLon) * math.cos(lat2);
    var x = math.cos(lat1) * math.sin(lat2) - math.sin(lat1) * math.cos(lat2) * math.cos(dLon);

    var brng = math.atan2(y, x);

    brng = (brng.degrees + 360) % 360;

    return brng;
  }

  static double latRad(lat) {
    var sin = math.sin(lat * math.pi / 180);
    var radX2 = math.log((1 + sin) / (1 - sin)) / 2;
    return math.max(math.min(radX2, math.pi), -math.pi) / 2;
  }

  static double zoom(mapPx, worldPx, fraction) {
    return math.log(mapPx / worldPx / fraction) / math.ln2;
  }

  static ILatLng vectorInterpolateOptimized(Float32x4 delta, Float32x4 min, double t) {
    var multiplier = Float32x4.splat(t);

    var value = min + delta * multiplier;

    var xxxx = value.shuffle(Float32x4.xxxx);
    var yyyy = value.shuffle(Float32x4.yyyy);

    var powerX = xxxx * xxxx;
    var powerY = yyyy * yyyy;

    var sum = powerX + powerY;

    var sqrt = sum.sqrt();

    final lat = math.atan2(value.z, sqrt.x);
    final lng = math.atan2(yyyy.y, xxxx.x);

    return ILatLng.point(lat.degrees, lng.degrees);
  }
}
