import 'i_interpolation_service.dart';

abstract class IInterpolationServiceOptimized<T>
    extends IInterpolationService<T> with IWarmUp<T> {
  IInterpolationServiceOptimized.warmUp() : super.warmUp();
}
