abstract class  ILatLng {
  double latitude = 0;
  double longitude = 0;
  double bearing = 0;
  String markerId = "";
  bool isStopover = false;
}


class EmptyLatLng implements ILatLng {
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
}