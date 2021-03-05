

import 'package:flutter_animarker/core/i_lat_lng.dart';

class LatLngInfo implements ILatLng{
  double latitude;
  double longitude;
  String markerId;
  double bearing;
  bool isStopover;
  LatLngInfo(this.latitude, this.longitude, this.markerId, [this.bearing = 0,  this.isStopover = false]);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is LatLngInfo &&
              runtimeType == other.runtimeType &&
              latitude == other.latitude &&
              longitude == other.longitude &&
              markerId == other.markerId &&
              bearing == other.bearing &&
              isStopover == other.isStopover;

  @override
  int get hashCode => latitude.hashCode ^ longitude.hashCode ^ markerId.hashCode ^ bearing.hashCode ^ isStopover.hashCode;

 }