import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animarker/core/ripple_marker.dart';
import 'package:flutter_animarker/widgets/animarker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

import 'animarker_robot.dart';

void main() {
  testWidgets('Test Animarker animation after rebuild',
      (WidgetTester tester) async {
    const animarkerKey = Key('Animarker');
    var animarkerRobot = AnimarkerRobot(tester);
    const position = LatLng(18.488141761655367, -69.9591860021479);
    var position2 = LatLng(18.488172286992025, -69.95789854186913);
    var position3 = LatLng(18.488762442871334, -69.95493734402267);
    var position4 = LatLng(18.489169389997496, -69.95311340026335);
    var position5 = LatLng(18.489169389997497, -69.95311340026336);
    //var position6 = LatLng(18.489169389997497, -69.95311340026336);

    var markerId = MarkerId('MarkerId1');
    const _kSantoDomingo = CameraPosition(target: position, zoom: 15);
    var marker = RippleMarker(
      markerId: markerId,
      position: position,
      ripple: true,
    );

    //Animarker 1
    var animarker = await animarkerRobot.newBuild(
        animarkerKey, marker, _kSantoDomingo, false);

    final animarkerElement =
        tester.element<StatefulElement>(find.byKey(animarkerKey));
    final animarkerElementState = animarkerElement.state as AnimarkerState;

    expect(animarkerElementState.widget, equals(animarker));
    expect(animarkerElement.renderObject!.attached, isTrue);
    expect(setEquals(animarkerElementState.widget.markers, <Marker>{marker}),
        isTrue);

    //Animarker 2
    var marker2 = marker.copyWith(positionParam: position2);

    animarkerElement.markNeedsBuild();

    var animarker2 = await animarkerRobot.newBuild(
        animarkerKey, marker2, _kSantoDomingo, false);

    //await tester.pumpAndSettle();
    await tester.pump(animarker2.duration);

    final animarkerElementState2 = animarkerElement.state as AnimarkerState;

    expect(animarkerElementState2.widget, isNot(equals(animarker)));
    expect(animarkerElementState2.widget, equals(animarker2));
    expect(setEquals(animarker2.markers, animarker.markers), isFalse);

    //Animarker 3
    var marker3 = marker.copyWith(positionParam: position3);

    animarkerElement.markNeedsBuild();

    var animarker3 = await animarkerRobot.newBuild(
        animarkerKey, marker3, _kSantoDomingo, false);

    await tester.pump(animarker3.duration);

    final animarkerElementState3 = animarkerElement.state as AnimarkerState;

    expect(animarkerElementState3.widget, isNot(equals(animarker2)));
    expect(animarkerElementState3.widget, equals(animarker3));
    expect(setEquals(animarker3.markers, animarker2.markers), isFalse);

    //Animarker 4
    var marker4 = marker.copyWith(positionParam: position4);

    animarkerElement.markNeedsBuild();

    var animarker4 = await animarkerRobot.newBuild(
        animarkerKey, marker4, _kSantoDomingo, false);

    await tester.pump(animarker4.duration);

    final animarkerElementState4 = animarkerElement.state as AnimarkerState;

    expect(animarkerElementState4.widget, isNot(equals(animarker3)));
    expect(animarkerElementState4.widget, equals(animarker4));
    expect(setEquals(animarker4.markers, animarker3.markers), isFalse);

    //Animarker 5
    var marker5 = marker.copyWith(positionParam: position5);

    animarkerElement.markNeedsBuild();

    var animarker5 = await animarkerRobot.newBuild(
        animarkerKey, marker5, _kSantoDomingo, false);

    await tester.pump(animarker5.duration);

    final animarkerElementState5 = animarkerElement.state as AnimarkerState;

    expect(animarkerElementState5.widget, isNot(equals(animarker4)));
    expect(animarkerElementState5.widget, equals(animarker5));
    expect(setEquals(animarker5.markers, animarker4.markers), isFalse);
  });
}
