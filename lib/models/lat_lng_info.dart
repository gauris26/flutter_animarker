import 'package:flutter_animarker/core/i_lat_lng.dart';

class LatLngInfo implements ILatLng{
  double latitude;
  double longitude;
  String markerId;
  double bearing;
  bool isStopover;
  bool ripple;

  LatLngInfo(this.latitude, this.longitude, this.markerId, {this.bearing = 0,  this.isStopover = false, this.ripple = false});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is LatLngInfo &&
              runtimeType == other.runtimeType &&
              latitude == other.latitude &&
              longitude == other.longitude &&
              markerId == other.markerId &&
              bearing == other.bearing &&
              isStopover == other.isStopover &&
  ripple == other.ripple;

  @override
  int get hashCode => latitude.hashCode ^ longitude.hashCode ^ markerId.hashCode ^ bearing.hashCode ^ isStopover.hashCode ^ ripple.hashCode;

  @override
  String toString() {
    return 'LatLngInfo{latitude: $latitude, longitude: $longitude, markerId: $markerId, bearing: $bearing, isStopover: $isStopover, ripple: $ripple}';
  }


}

class EmptyLatLng implements LatLngInfo {
  @override
  double bearing = 0;

  @override
  bool isStopover = false;

  @override
  double latitude = 0;

  @override
  double longitude = 0;

  @override
  String markerId = "";

  @override
  bool ripple = false;
}