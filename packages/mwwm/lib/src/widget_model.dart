// Copyright (c) 2019-present,  SurfStudio LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mwwm/mwwm.dart';
import 'package:mwwm/src/utils/composite_subscription.dart';

/// WidgetModel
/// WM is logical representation of widget and his state.
/// `WidgetModelDependencies` - is pack of dependencies for WidgetModel. Offtenly, it is `ErrorHandler`.
/// `Model` - optionally, but recommended, manager for connection with bussines layer
abstract class WidgetModel {
  @protected
  final Model model;

  final ErrorHandler? _errorHandler;

  final _compositeSubscription = CompositeSubscription();

  WidgetModel(
    WidgetModelDependencies baseDependencies, {
    Model? model,
  })  : _errorHandler = baseDependencies.errorHandler,
        model = model ?? const Model([]);

  /// called when widget ready
  void onInit() {}

  /// called when widget ready
  void onLoad() {}

  /// here need to bind
  void onBind() {}

  /// subscribe for interactors
  StreamSubscription<T?> subscribe<T>(
    Stream<T?> stream,
    void Function(T? value) onValue, {
    void Function(Object error, StackTrace stackTrace)? onError,
    bool? cancelOnError,
  }) {
    final subscription = stream.listen(
      (value) {
        try {
          onValue.call(value);
        } on Exception catch (e, s) {
          if (onError == null) rethrow;
          onError.call(e, s);
        }
      },
      cancelOnError: cancelOnError,
    );
    return _compositeSubscription.add<T>(subscription);
  }

  /// subscribe for interactors with default handle error
  StreamSubscription<T?> subscribeHandleError<T>(
    Stream<T> stream,
    void Function(T value) onValue, {
    void Function(Object error, StackTrace stackTrace)? onError,
    bool? cancelOnError,
  }) {
    final subscription = stream.listen(
      (value) {
        try {
          onValue.call(value);
        } on Exception catch (e, s) {
          if (onError == null && _errorHandler == null) rethrow;
          onError?.call(e, s);
          final isSuccessfully = handleError(e, s);
          if (!isSuccessfully && onError == null) rethrow;
        }
      },
      cancelOnError: cancelOnError,
    );
    return _compositeSubscription.add<T>(subscription);
  }

  /// Call a future.
  /// Using Rx wrappers with [subscribe] method is preferable.
  void doFuture<T>(
    Future<T> future, {
    void Function(T value)? onValue,
    void Function(Object error, StackTrace stackTrace)? onError,
    void Function()? onFinally,
  }) async {
    try {
      if (onValue == null) {
        await future;
      } else {
        final result = await future;
        onValue.call(result);
      }
    } on Exception catch (e, s) {
      if (onError == null) rethrow;
      onError(e, s);
    } finally {
      onFinally?.call();
    }
  }

  /// Call a future with default error handling
  void doFutureHandleError<T>(
    Future<T> future, {
    void Function(T value)? onValue,
    void Function(Object error, StackTrace stackTrace)? onError,
    void Function()? onFinally,
  }) async {
    try {
      if (onValue == null) {
        await future;
      } else {
        final result = await future;
        onValue.call(result);
      }
    } on Exception catch (e, s) {
      if (onError == null && _errorHandler == null) rethrow;
      onError?.call(e, s);
      final isSuccessfully = handleError(e, s);
      if (!isSuccessfully && onError == null) rethrow;
    } finally {
      onFinally?.call();
    }
  }

  /// Close streams of WM
  void dispose() {
    _compositeSubscription.dispose();
  }

  /// standard error handling
  @protected
  bool handleError(Object e, StackTrace s) {
    return _errorHandler?.handleError(e, s) ?? false;
  }
}
