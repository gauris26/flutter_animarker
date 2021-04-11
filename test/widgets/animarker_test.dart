import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animarker/core/performance_mode.dart';
import 'package:flutter_animarker/core/ripple_marker.dart';
import 'package:flutter_animarker/widgets/animarker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

import 'animarker_robot.dart';

void main() {
  testWidgets('MyWidget has a title and message', (WidgetTester tester) async {
    const animarkerKey = Key('Animarker');
    var animarkerRobot = AnimarkerRobot();
    const position = LatLng(18.488141761655367, -69.9591860021479);
    var position2 = LatLng(18.488172286992025, -69.95789854186913);
    var markerId = MarkerId('MarkerId1');
    const _kSantoDomingo = CameraPosition(
      target: position,
      zoom: 15,
    );
    var marker = RippleMarker(
      markerId: markerId,
      position: position,
      ripple: true,
    );

    var marker2 = marker.copyWith(positionParam: position2);

    var markersSet = <Marker>{marker};

    final completer = Completer<GoogleMapController>();
    var animarker = animarkerRobot.getNewAnimarker(animarkerKey, completer, markersSet, _kSantoDomingo);

    debugPrint('Pumping 1');
    await tester.pumpWidget(MaterialApp(home: animarker));

    final animarkerElement = tester.element<StatefulElement>(find.byKey(animarkerKey));
    final animarkerElementState = animarkerElement.state as AnimarkerState;

    expect(animarkerElementState.widget, equals(animarker));
    expect(animarkerElement.renderObject!.attached, isTrue);
    expect(setEquals(animarkerElementState.widget.markers, markersSet), isTrue);

    markersSet = <Marker>{marker2};

    final completer2 = Completer<GoogleMapController>();
    var animarker2 = animarkerRobot.getNewAnimarker(animarkerKey, completer2, markersSet, _kSantoDomingo);

    animarkerElement.markNeedsBuild();

    debugPrint('Pumping 2');
    await tester.pumpWidget(MaterialApp(home: animarker2));
    await tester.pumpAndSettle();

    final animarkerElementState2 = animarkerElement.state as AnimarkerState;

    expect(animarkerElementState2.widget, isNot(equals(animarker)));
    expect(animarkerElementState2.widget, equals(animarker2));
    expect(setEquals(animarker.markers, animarker2.markers), isFalse);

/*    animarkerElement.markNeedsBuild();
    final animarkerElementState2 = animarkerElement.state as AnimarkerState;

    expect(setEquals(animarkerElementState2.widget.markers, markersSet), isTrue);*/

    /*// ignore: invalid_use_of_protected_member
    statefulWrapper.setState(() {
      markersSet = <Marker>{marker2};
    });

    expect(animarker, equals(statefulWrapper.widget));
    expect(animarker.markers.first, equals(marker));
    expect(animarker.markers.length, equals(1));*/
  });
}
