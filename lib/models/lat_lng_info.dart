import 'package:flutter_animarker/core/i_lat_lng.dart';

class LatLngInfo implements ILatLng {
  final double latitude;
  final double longitude;
  final String markerId;
  final double bearing;
  final bool isStopover;
  final bool ripple;
  final bool isEmpty;

  const LatLngInfo(this.latitude, this.longitude, this.markerId,
      {this.bearing = 0, this.isStopover = false, this.ripple = false})
      : isEmpty = false;

  const LatLngInfo.empty()
      : bearing = 0,
        isStopover = false,
        latitude = 0,
        longitude = 0,
        markerId = "",
        ripple = false,
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
          isEmpty == other.isEmpty;

  @override
  int get hashCode =>
      latitude.hashCode ^
      longitude.hashCode ^
      markerId.hashCode ^
      bearing.hashCode ^
      isStopover.hashCode ^
      ripple.hashCode ^
      isEmpty.hashCode;

  @override
  String toString() {
    return 'LatLngInfo{latitude: $latitude, longitude: $longitude, markerId: $markerId, bearing: $bearing, isStopover: $isStopover, ripple: $ripple}';
  }

  LatLngInfo copyWith({
    double? latitude,
    double? longitude,
    double? bearing,
    String? markerId,
    bool? isStopover,
    bool? ripple,
    bool? isEmpty,
  }) {
    if ((latitude == null || identical(latitude, this.latitude)) &&
        (longitude == null || identical(longitude, this.longitude)) &&
        (bearing == null || identical(bearing, this.bearing)) &&
        (markerId == null || identical(markerId, this.markerId)) &&
        (isStopover == null || identical(isStopover, this.isStopover)) &&
        (ripple == null || identical(ripple, this.ripple)) &&
        (isEmpty == null || identical(isEmpty, this.isEmpty))) {
      return this;
    }

    return LatLngInfo(
      latitude ?? this.latitude,
      longitude ?? this.longitude,
      markerId ?? this.markerId,
      bearing: bearing ?? this.bearing,
      isStopover: isStopover ?? this.isStopover,
      ripple: ripple ?? this.ripple
    );
  }
}
