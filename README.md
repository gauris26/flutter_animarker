# Google Maps Markers Animation

Sometime you need more than place a marker in the maps, you required a smoothly throught **Google Maps** canvas.

Here the main uses of this package to animate the markers changes of position.

The Google Maps dependencies was removed, since it was only required for the LatLng object, you can use now LatLngInfo wrapper.

You can add multiple markers, and receive particular location updates for each one.

## Screenshots

  ![](arts/marker_animation.gif)

## Example
```dart
    
   LatLngInterpolationStream _latLngStream = LatLngInterpolationStream();

   StreamGroup<LatLngDelta> subscriptions = StreamGroup<LatLngDelta>();

   StreamSubscription<Position> positionStream;

   @override
   void initState() {
      
    //Merge all the Marker Poisition Stream into a single One
    subscriptions.add(_latLngStream.getAnimatedPosition("Marker 1"));
    subscriptions.add(_latLngStream.getAnimatedPosition("Marker 2"));
    subscriptions.add(_latLngStream.getAnimatedPosition("Marker 3"));
    
    subscriptions.stream.listen((LatLngDelta delta) {
      //Update the marker with animation
      setState(() {
        //Get the marker Id for this animation
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

    super.initState();
    }

    //Push new location changes, use your own position values
    void updatePinOnMap() {
        
      _latLngStream.addLatLng(LatLngInfo(latitudeMarker1, longitudeMarker1, "Marker 1"));
      _latLngStream.addLatLng(LatLngInfo(latitudeMarker2, longitudeMarker2, "Marker 2"));
      _latLngStream.addLatLng(LatLngInfo(latitudeMarker3, longitudeMarker3, "Marker 3"));
    }

    @override
    void dispose() {
      subscriptions.close();
      positionStream.cancel();
      super.dispose();
    }
```
## License

```
  BSD-3-Clause License
  
  Copyright 2020  Gauris Javier. All rights 
  reserved.
  
  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions 
  are met:
  
  1. Redistributions of source code must retain the above copyright 
  notice, this list of conditions and the following disclaimer.
  
  2. Redistributions in binary form must reproduce the above copyright
  notice, this list of conditions and the following disclaimer in the 
  documentation and/or other materials provided with the distribution.
  
  3. Neither the name of the copyright holder nor the names of its contributors
  may be used to endorse or promote products derived from this software 
  without specific prior written permission.
  
  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
  THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
  PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR 
  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, 
  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
  OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF 
  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
```