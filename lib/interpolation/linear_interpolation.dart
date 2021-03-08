import 'package:flutter_animarker/helpers/spherical_util.dart';
import 'package:flutter_animarker/models/lat_lng_delta.dart';
import 'package:flutter_animarker/models/lat_lng_info.dart';
import 'package:flutter_animarker/streams/lat_lng_stream.dart';

@deprecated
class LinearInterpolation {
  final Duration movementDuration;
  final Duration movementInterval;
  LatLngInfo? previousLatLng;
  LatLngStream _linearLatLngStream;
  LatLngInfo? lastInterpolatedPosition;

  LinearInterpolation({
    this.movementDuration = const Duration(milliseconds: 1000),
    this.movementInterval = const Duration(milliseconds: 20),
}) : _linearLatLngStream = LatLngStream();

  Stream<LatLngDelta> latLngLinearInterpolation() async* {

    double lastBearing = 0;
    int start = 0;

    await for (LatLngInfo pos in _linearLatLngStream.stream) {

      double distance = SphericalUtil.computeDistanceBetween(previousLatLng ?? pos, pos) as double;

      //First marker, required at least two from have a delta position
      if (previousLatLng == null || distance < 5.5) {
        previousLatLng = pos;
        continue;
      }

      //CurveTween curveTween = CurveTween(curve: curve);
      start = DateTime.now().millisecondsSinceEpoch;
      int elapsed = 0;

      while (elapsed.toDouble() / movementDuration.inMilliseconds < 1.0) {
        elapsed = DateTime.now().millisecondsSinceEpoch - start;

        double t = (elapsed.toDouble() / movementDuration.inMilliseconds).clamp(0.0, 1.0);

        LatLngInfo latLng = SphericalUtil.interpolate(previousLatLng, pos, t) as LatLngInfo;

        double rotation = SphericalUtil.getBearing(
            latLng, lastInterpolatedPosition ?? previousLatLng!);

        double diff = SphericalUtil.angleShortestDistance(rotation, lastBearing);

        double distance = SphericalUtil.computeDistanceBetween(
            latLng, lastInterpolatedPosition ?? previousLatLng!) as double;

        //Determine if the marker's has made a significantly movement
        if (diff.isNaN || distance < 1.5) {
          continue;
        }

        yield LatLngDelta(
          from: lastInterpolatedPosition ?? previousLatLng,
          to: latLng,
          markerId: pos.markerId,
          isStopover: elapsed.toDouble() / movementDuration.inMilliseconds >= 1.0,
          rotation: !rotation.isNaN ? rotation : lastBearing,
        );

        lastBearing = !rotation.isNaN ? rotation : lastBearing;

        lastInterpolatedPosition = latLng;

        await Future.delayed(movementInterval);
      }

      previousLatLng = lastInterpolatedPosition;
    }
  }

  void addLatLng(LatLngInfo latLng)  => _linearLatLngStream.addLatLng(latLng);

  void dispose() => _linearLatLngStream.dispose();
}