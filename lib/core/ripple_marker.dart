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
      alpha: alpha ?? this.alpha,
      anchor: anchor ?? this.anchor,
      draggable: draggable ?? this.draggable,
      flat: flat ?? this.flat,
      icon: icon ?? this.icon,
      infoWindow: infoWindow ?? this.infoWindow,
      position: position ?? this.position,
      rotation: rotation ?? this.rotation,
      visible: visible ?? this.visible,
      zIndex: zIndex ?? this.zIndex,
      onTap: onTap ?? this.onTap,
      onDragEnd: onDragEnd ?? this.onDragEnd,
    );
  }
}
