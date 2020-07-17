# Google Maps Markers Animation

Sometime you need more than place a marker in the maps, you required a smoothly throught **Google Maps** canvas.

Here the main uses of this package to animate the markers changes of position.


# Example
```dart
    LatLngInterpolationStream _latLngStream = LatLngInterpolationStream();
    StreamSubscription<LatLngDelta> subscription;

    @override
    void initState() {
    	subscription= _latLngStream .getLatLngInterpolation().listen((LatLngDelta delta) {
      LatLng from = delta.from;
      LatLng to = delta.to;
    });

    super.initState();
    }

    void updatePinOnMap() {
      var pinPosition = LatLng(currentLocation.latitude, currentLocation.longitude);

      _latLngStream.addLatLng(pinPosition);
    }

    @override
    void dispose() {
      subscription.cancel();
      _latLngStream.cancel();
     super.dispose();
    }
```
