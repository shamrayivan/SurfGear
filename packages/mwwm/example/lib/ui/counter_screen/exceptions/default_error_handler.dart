import 'package:flutter/foundation.dart';
import 'package:mwwm/mwwm.dart';

/// Default error handler for [WidgetModelDependencies]
class DefaultErrorHandler implements ErrorHandler {
  @override
  bool handleError(Object e, StackTrace? s) {
    debugPrint(e.toString());
    debugPrint(s.toString());
    return true;
  }
}
