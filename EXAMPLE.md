# Google Maps Markers Animation

Sometimes you need more than place a *Marker*📍 at map canvas 🌍, you need to smoothly move through **Google Maps**.

This package will help you to animate *Markers*' position changes and more.

# Example

```dart
//Setting dummies values
const kStartPosition = LatLng(18.488213, -69.959186);
const kSantoDomingo = CameraPosition(target: kStartPosition, zoom: 15);
const kMarkerId = MarkerId('MarkerId1');
const kDuration = Duration(seconds: 2);
const kLocations = [
  kStartPosition,
  LatLng(18.488101, -69.957995),
  LatLng(18.489210, -69.952459),
  LatLng(18.487307, -69.952759)
];

class SimpleMarkerAnimationExample extends StatefulWidget {
  @override
  SimpleMarkerAnimationExampleState createState() => SimpleMarkerAnimationExampleState();
}

class SimpleMarkerAnimationExampleState extends State<SimpleMarkerAnimationExample> {
  final markers = <MarkerId, Marker>{};
  final controller = Completer<GoogleMapController>();
  final stream = Stream.periodic(kDuration, (count) => kLocations[count]).take(kLocations.length);

  @override
  void initState() {
    stream.forEach((value) => newLocationUpdate(value));

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Google Maps Markers Animation Example',
      home: Animarker(
        curve: Curves.ease,
        mapId: controller.future.then<int>((value) => value.mapId), //Grab Google Map Id
        markers: markers.values.toSet(),
        child: GoogleMap(
          mapType: MapType.normal,
          initialCameraPosition: kSantoDomingo,
          onMapCreated: (gController) =>
              controller.complete(gController), //Complete the future GoogleMapController
        ),
      ),
    );
  }

  void newLocationUpdate(LatLng latLng) {
    var marker = Marker(markerId: kMarkerId, position: latLng);
    setState(() => markers[kMarkerId] = marker);
  }
}
```
