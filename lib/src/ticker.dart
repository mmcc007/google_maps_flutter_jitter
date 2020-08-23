import 'dart:async';

class Ticker {
  Stream<int> tick(int steps, int interval) {
    return Stream.periodic(Duration(milliseconds: interval), (x) => x)
        .take((steps));
  }
}
