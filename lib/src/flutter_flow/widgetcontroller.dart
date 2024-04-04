import 'package:flutter/foundation.dart';

class WidgetController<T> extends ValueNotifier<T?> {
  WidgetController(this.initialValue) : super(initialValue);

  final T? initialValue;

  void reset() => value = initialValue;
  void update() => notifyListeners();
}
