import 'package:flutter/material.dart';
import 'package:flutter_animarker/anims/location_tween.dart';

import 'i_lat_lng.dart';

abstract class ILocationAnimationWrapper {

  ILocationAnimationWrapper(LocationTween locationTween, {required Animation<double> controller});

  ILatLng get begin;
  set begin (ILatLng value);

  ILatLng get end;
  set end (ILatLng value);

  ILatLng get value;

}