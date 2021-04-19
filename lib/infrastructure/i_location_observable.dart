typedef OnLocationChanged = void Function();

class ILocationObservable {
  List<OnLocationChanged> observers = <OnLocationChanged>[];

  void attach({required OnLocationChanged observer}) {
    observers.add(observer);
  }

  void detach(OnLocationChanged observer) {
    observers.remove(observer);
  }

  void notifyObservers() {
    for (var observer in observers) {
      observer.call();
    }
  }
}
