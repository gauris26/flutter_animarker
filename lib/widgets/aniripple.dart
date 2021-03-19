// Flutter imports:
import 'package:flutter/material.dart';

typedef OnZoomChanged = void Function(double zoom);

class AniRipple extends StatefulWidget {
  final Duration rippleDuration;
  final Duration rotationDuration;
  final Color rippleColor;
  final double radius;
  final Widget child;
  final double zoom;
  final bool active;

  AniRipple({
    Key? key,
    this.rippleDuration = const Duration(milliseconds: 2000),
    this.rotationDuration = const Duration(milliseconds: 10000),
    this.radius = 0.5,
    this.zoom = 15.0,
    this.rippleColor = Colors.red,
    this.active = true,
    required this.child,
  })   : assert(radius >= 0.0 && radius <= 1.0,
            'Must choose values between 0.0 and 1.0 for radius scale'),
        super(key: key);

  static AniRippleData? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AniRippleData>();

  @override
  _AniRippleState createState() => _AniRippleState();
}

class _AniRippleState extends State<AniRipple> {
  @override
  Widget build(BuildContext context) {
    return AniRippleData(
      zoom: widget.zoom,
      active: widget.active,
      radius: widget.radius,
      rippleColor: widget.rippleColor,
      rippleDuration: widget.rippleDuration,
      rotationDuration: widget.rotationDuration,
      child: widget.child,
    );
  }
}

class AniRippleData extends InheritedWidget {
  final Duration rippleDuration;
  final Duration rotationDuration;
  final Color rippleColor;
  final double radius;
  final double zoom;
  final bool active;

  AniRippleData({
    Key? key,
    this.rippleDuration = const Duration(milliseconds: 2000),
    this.rotationDuration = const Duration(milliseconds: 10000),
    this.radius = 0.5,
    this.zoom = 15.0,
    this.rippleColor = Colors.red,
    this.active = true,
    required Widget child,
  }) : super(key: key, child: child);

  static AniRippleData? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AniRippleData>();
  }

  @override
  bool updateShouldNotify(AniRippleData oldWidget) {
    if (oldWidget.rotationDuration != rotationDuration ||
        oldWidget.rippleDuration != rippleDuration ||
        oldWidget.rippleColor != rippleColor ||
        oldWidget.radius != radius ||
        oldWidget.active != active ||
        oldWidget.zoom != zoom ||
        oldWidget.child != child
    ) return true;

    return false;
  }
}
