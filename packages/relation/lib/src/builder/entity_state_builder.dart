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

import 'package:flutter/widgets.dart';
import 'package:relation/src/relation/state/entity_state.dart';

typedef DataWidgetBuilder<T> = Widget Function(BuildContext context, T? data);

typedef ErrorWidgetBuilder = Widget Function(BuildContext context, Object? e);

typedef DataErrorWidgetBuilder<T> = Widget Function(
  BuildContext context,
  T? data,
  Object? e,
);

/// Reactive widget for [EntityStreamedState]
///
/// [streamedState] - external stream that controls the state of the widget
/// widget has three states:
///   [builder] - content;
///   [loadingChild] - loading;
///   [errorChild] - error.
///
/// Error builders priority order:
/// 1. [errorDataBuilder]
/// 3. [errorChild]
///
/// ### example
/// ```dart
/// EntityStateBuilder<Data>(
///      streamedState: wm.dataState,
///      builder: (context, data) => DataWidget(data),
///      loadingChild: LoadingWidget(),
///      errorChild: ErrorPlaceholder(),
///    );
///  ```
class EntityStateBuilder<T> extends StatelessWidget {
  /// StreamedState of entity
  final EntityStreamedState<T> streamedState;

  /// WidgetBuilder for [streamedState]'s data
  final DataWidgetBuilder<T> builder;

  /// WidgetBuilder for empty data
  final DataWidgetBuilder<T>? loadingBuilder;

  /// WidgetBuilder for error with previous data
  final DataErrorWidgetBuilder<T>? errorDataBuilder;

  /// Loading child widget
  final Widget loadingChild;

  /// Error child widget
  final Widget errorChild;

  const EntityStateBuilder({
    required this.streamedState,
    required this.builder,
    this.loadingBuilder,
    this.errorDataBuilder,
    this.loadingChild = const SizedBox.shrink(),
    this.errorChild = const SizedBox.shrink(),
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<EntityState<T>?>(
      stream: streamedState.stream,
      initialData: streamedState.value,
      builder: (context, snapshot) {
        final streamData = snapshot.data;

        if (streamData != null && streamData.isContent) {
          return builder(context, streamData.data);
        }
        if (streamData != null) {
          if (streamData.isLoading) {
            return loadingBuilder == null
                ? loadingChild
                : loadingBuilder!(context, streamData.data);
          } else if (streamData.hasError) {
            if (errorDataBuilder != null) {
              return errorDataBuilder!(
                context,
                streamData.data,
                streamData.error,
              );
            }
          }
        }

        return errorChild;
      },
    );
  }
}
