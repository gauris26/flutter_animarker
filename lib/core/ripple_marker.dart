// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/painting.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

class RippleMarker extends Marker {
  final bool ripple;

  const RippleMarker({
    required MarkerId markerId,
    this.ripple = true,
    double alpha = 1.0,
    anchor = const Offset(0.5, 1.0),
    bool consumeTapEvents = false,
    bool draggable = false,
    bool flat = false,
    icon = BitmapDescriptor.defaultMarker,
    InfoWindow infoWindow = InfoWindow.noText,
    LatLng position = const LatLng(0.0, 0.0),
    double rotation = 0.0,
    bool visible = true,
    double zIndex = 0.0,
    onTap,
    onDragEnd,
  }) : super(
          markerId: markerId,
          alpha: alpha,
          anchor: anchor,
          draggable: draggable,
          flat: flat,
          icon: icon,
          infoWindow: infoWindow,
          position: position,
          rotation: rotation,
          visible: visible,
          zIndex: zIndex,
          onTap: onTap,
          onDragEnd: onDragEnd,
        );

  @override
  RippleMarker copyWith({
    bool? ripple,
    double? alphaParam,
    Offset? anchorParam,
    bool? consumeTapEventsParam,
    bool? draggableParam,
    bool? flatParam,
    BitmapDescriptor? iconParam,
    InfoWindow? infoWindowParam,
    LatLng? positionParam,
    double? rotationParam,
    bool? visibleParam,
    double? zIndexParam,
    VoidCallback? onTapParam,
    ValueChanged<LatLng>? onDragStartParam,
    ValueChanged<LatLng>? onDragParam,
    ValueChanged<LatLng>? onDragEndParam,
  }) {
    return RippleMarker(
      markerId: markerId ?? this.markerId,
      ripple: ripple ?? this.ripple,
      alpha: alphaParam ?? this.alpha,
      anchor: anchorParam ?? this.anchor,
      draggable: draggableParam ?? this.draggable,
      flat: flatParam ?? this.flat,
      icon: iconParam ?? this.icon,
      infoWindow: infoWindowParam ?? this.infoWindow,
      position: positionParam ?? this.position,
      rotation: rotationParam ?? this.rotation,
      visible: visibleParam ?? this.visible,
      zIndex: zIndexParam ?? this.zIndex,
      onTap: onTapParam ?? this.onTap,
      onDragEnd: onDragEndParam ?? this.onDragEnd,
    );
  }
}
