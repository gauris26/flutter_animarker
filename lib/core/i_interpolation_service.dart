import 'package:flutter/cupertino.dart';

abstract class IInterpolationService<T> {
  IInterpolationService.warmUp() {
    doWarmUp();
  }

  T get begin;
  T get end;

  set begin(T value);
  set end(T value);

  bool get isStopped;

  @protected
  T doInterpolate(double t);

  @protected
  void doSwap(T newValue);

  @protected
  void doWarmUp();
}

//Template Method Patterns
mixin IWarmUp<T> on IInterpolationService<T> {
  void swap(T newValue) {
    doSwap(newValue);
    warmUp();
  }

  void warmUp() {
    doWarmUp();
  }

  T interpolate(double t) {
    if (begin == end) return end;
    if (t == 0.0) return begin;
    if (t == 1.0) return end;

    return doInterpolate(t);
  }
}
