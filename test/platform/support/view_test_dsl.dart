import 'package:fmodel/fmodel.dart';
import 'package:test/test.dart';

extension ViewTestDsl<S, E> on View<S, E> {
  GivenEventsThenStep<S, E> givenEvents(Iterable<E> events) =>
      GivenEventsThenStep(this, events);
}

final class GivenEventsThenStep<S, E> {
  const GivenEventsThenStep(this._view, this._events);

  final View<S, E> _view;
  final Iterable<E> _events;

  void thenState(S expected) {
    final resultingState = _events.fold<S>(
      _view.initialState,
      (state, event) => _view.evolve(state, event),
    );
    expect(resultingState, expected);
  }
}
