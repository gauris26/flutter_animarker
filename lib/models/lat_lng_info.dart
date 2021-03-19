import 'package:flutter_animarker/core/i_lat_lng.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

final MarkerId defaultId = MarkerId('');

class LatLngInfo implements ILatLng {
  @override
  final double latitude;
  @override
  final double longitude;
  @override
  final MarkerId? markerId;
  @override
  final double bearing;
  @override
  final bool isStopover;
  @override
  final bool ripple;
  @override
  final bool isEmpty;
  @override
  final double mapScale;

  const LatLngInfo(this.latitude, this.longitude, this.markerId,
      {this.bearing = 0, this.isStopover = false, this.ripple = false, this.mapScale = 0.5})
      : isEmpty = false;

  const LatLngInfo.empty()
      : bearing = 0,
        isStopover = false,
        latitude = 0,
        longitude = 0,
        markerId = null,
        ripple = false,
        mapScale = 0.5,
        isEmpty = true;

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
          ripple == other.ripple &&
          isEmpty == other.isEmpty &&
          mapScale == other.mapScale;

  @override
  int get hashCode =>
      latitude.hashCode ^
      longitude.hashCode ^
      markerId.hashCode ^
      bearing.hashCode ^
      isStopover.hashCode ^
      ripple.hashCode ^
      isEmpty.hashCode ^
      mapScale.hashCode;

  @override
  String toString() {
    return 'LatLngInfo{latitude: $latitude, longitude: $longitude, markerId: $markerId, bearing: $bearing, isStopover: $isStopover, ripple: $ripple, isEmpty: $isEmpty, mapScale: $mapScale}';
  }

  @override
  LatLngInfo copyWith({
    double? latitude,
    double? longitude,
    double? bearing,
    MarkerId? markerId,
    bool? isStopover,
    bool? ripple,
    bool? isEmpty,
    double? mapScale,
  }) {
    if ((latitude == null || identical(latitude, this.latitude)) &&
        (longitude == null || identical(longitude, this.longitude)) &&
        (bearing == null || identical(bearing, this.bearing)) &&
        (markerId == null || identical(markerId, this.markerId)) &&
        (isStopover == null || identical(isStopover, this.isStopover)) &&
        (ripple == null || identical(ripple, this.ripple)) &&
        (isEmpty == null || identical(isEmpty, this.isEmpty)) &&
        (mapScale == null || identical(mapScale, this.mapScale))) {
      return this;
    }

    return LatLngInfo(
      latitude ?? this.latitude,
      longitude ?? this.longitude,
      markerId ?? this.markerId,
      bearing: bearing ?? this.bearing,
      isStopover: isStopover ?? this.isStopover,
      ripple: ripple ?? this.ripple,
      mapScale: mapScale ?? this.mapScale,
    );
  }
}
