// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';

/// An animation that is a proxy for another animation.
///
/// A proxy animation is useful because the parent animation can be mutated. For
/// example, one object can create a proxy animation, hand the proxy to another
/// object, and then later change the animation from which the proxy receives
/// its value.
class ProxyAnimationGeneric<T> extends Animation<T>
    with
        AnimationLazyListenerMixin,
        AnimationLocalListenersMixin,
        AnimationLocalStatusListenersMixin {
  /// Creates a proxy animation.
  ///
  /// If the animation argument is omitted, the proxy animation will have the
  /// status [AnimationStatus.dismissed] and a value of 0.0.
  ProxyAnimationGeneric([Animation<T>? animation, T? defaultValue]) {
    _parent = animation;
    if (_parent == null) {
      _status = AnimationStatus.dismissed;
      _value = defaultValue;
    }
  }

  AnimationStatus? _status;
  T? _value;

  /// The animation whose value this animation will proxy.
  ///
  /// This value is mutable. When mutated, the listeners on the proxy animation
  /// will be transparently updated to be listening to the new parent animation.
  Animation<T>? get parent => _parent;
  Animation<T>? _parent;
  set parent(Animation<T>? value) {
    if (value == _parent) return;
    if (_parent != null) {
      _status = _parent!.status;
      _value = _parent!.value;
      if (isListening) didStopListening();
    }
    _parent = value;
    if (_parent != null) {
      if (isListening) didStartListening();
      if (_value != _parent!.value) notifyListeners();
      if (_status != _parent!.status) notifyStatusListeners(_parent!.status);
      _status = null;
      _value = null;
    }
  }

  @override
  void didStartListening() {
    if (_parent != null) {
      _parent!.addListener(notifyListeners);
      _parent!.addStatusListener(notifyStatusListeners);
    }
  }

  @override
  void didStopListening() {
    if (_parent != null) {
      _parent!.removeListener(notifyListeners);
      _parent!.removeStatusListener(notifyStatusListeners);
    }
  }

  @override
  AnimationStatus get status => _parent != null ? _parent!.status : _status!;

  @override
  T get value => _parent != null ? _parent!.value : _value!;

  @override
  String toString() {
    if (parent == null) {
      return '${objectRuntimeType(this, 'ProxyAnimationGeneric')}(null; ${super.toStringDetails()} $value)';
    }
    return '$parent\u27A9${objectRuntimeType(this, 'ProxyAnimationGeneric')}';
  }
}
