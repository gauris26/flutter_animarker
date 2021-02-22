# Google Maps Markers Animation

Sometime you need more than place a marker in the maps, you required a smoothly throught **Google Maps** canvas.

Here the main uses of this package to animate the markers changes of position.


# Example

 final Map<MarkerId, Marker> _markers = Map<MarkerId, Marker>();

  MarkerId sourceId = MarkerId("SourcePin");
  MarkerId source2Id = MarkerId("SourcePin2");
  MarkerId source3Id = MarkerId("SourcePin3");

  LatLngInterpolationStream _latLngStream = LatLngInterpolationStream();

  StreamGroup<LatLngDelta> subscriptions = StreamGroup<LatLngDelta>();

  StreamSubscription<Position> positionStream;

    final CameraPosition _kSantoDomingo = CameraPosition(
    target: startPosition,
    zoom: 15,
   );

  @override
  void initState() {

    //Now you use multiple marker at the same time
    //Add all the stream to StreamGroup
    subscriptions.add(_latLngStream.getAnimatedPosition(sourceId.value));
    subscriptions.add(_latLngStream.getAnimatedPosition(source2Id.value));
    subscriptions.add(_latLngStream.getAnimatedPosition(source3Id.value));
    
    subscriptions.stream.listen((LatLngDelta delta) {
      //Update the marker with animation
      setState(() {
        var markerId = MarkerId(delta.markerId);
        Marker sourceMarker = Marker(
          markerId: markerId,
          rotation: delta.rotation,
          position: LatLng(
            delta.from.latitude,
            delta.from.longitude,
          ),
        );
        _markers[markerId] = sourceMarker;

      });
    });
    
    //Using Geolocator Plugin to get location updates
    positionStream = Geolocator.getPositionStream(
      desiredAccuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 10,
    ).listen((Position position) {
      double latitude = position.latitude;
      double longitude = position.longitude;

      //Push new location changes to each marker by location  
      _latLngStream.addLatLng(LatLngInfo(latitude, longitude, sourceId.value)); 
      _latLngStream.addLatLng(LatLngInfo(latitude+0.1, longitude+0.1, source2Id.value));
      _latLngStream.addLatLng(LatLngInfo(latitude+0.2, longitude+0.2, source3Id.value));
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Google Maps Markers Animation Example',
      home: Scaffold(
        body: SafeArea(
          child: GoogleMap(
            mapType: MapType.normal,
            markers: Set<Marker>.of(_markers.values),
            initialCameraPosition: _kSantoDomingo,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
              setState(() {
                Marker sourceMarker = Marker(
                  markerId: sourceId,
                  position: startPosition,
                );

                //Place marker for first time
                _markers[sourceId] = sourceMarker;

                Marker source2Marker = Marker(
                  markerId: source2Id,
                  position: startPosition,
                );
                _markers[source2Id] = source2Marker;


                Marker source3Marker = Marker(
                  markerId: source3Id,
                  position: startPosition,
                );
                _markers[source3Id] = source3Marker;
              });
                
              _latLngStream.addLatLng(startPosition.toLatLngInfo(sourceId.value));
              _latLngStream.addLatLng(startPosition.toLatLngInfo(source2Id.value));
              _latLngStream.addLatLng(startPosition.toLatLngInfo(source3Id.value));
            },
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    subscriptions.close();
    positionStream.cancel();
    super.dispose();
  }
