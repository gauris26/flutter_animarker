class LatLngInfo {
  final double latitude;
  final double longitude;
  String markerId;

  LatLngInfo(this.latitude, this.longitude, [this.markerId = ""]);

  @override
  String toString() {
    return 'LatLngInfo{latitude: $latitude, longitude: $longitude, markerId: $markerId}';
  }

}