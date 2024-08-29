import 'package:relation/src/relation/event.dart';
import 'package:rxdart/rxdart.dart';

class StreamedStateNS<T> implements EventNS<T> {
  /// Behavior state for updating events
  final BehaviorSubject<T> stateSubject = BehaviorSubject();

  /// current value in stream
  T get value => stateSubject.value;

  @override
  Stream<T> get stream => stateSubject.stream;

  StreamedStateNS(T initialData) {
    accept(initialData);
  }

  StreamedStateNS.from(Stream<T> stream) {
    stateSubject.addStream(stream);
  }

  @override
  Future<T> accept(T data) {
    stateSubject.add(data);
    return stateSubject.stream.first;
  }

  Future<T?> reAccept() {
    stateSubject.add(value);
    return stateSubject.stream.first;
  }

  void dispose() {
    stateSubject.close();
  }
}
