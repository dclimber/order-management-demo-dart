import 'package:fmodel/domain.dart';
import 'package:test/test.dart';

extension DeciderTestDsl<C, S, E> on Decider<C, S, E> {
  GivenStateWhenStep<C, S, E> givenState(S state) =>
      GivenStateWhenStep(this, state);

  GivenEventsWhenStep<C, S, E> givenEvents(Iterable<E> events) =>
      GivenEventsWhenStep(this, events);
}

final class GivenStateWhenStep<C, S, E> {
  const GivenStateWhenStep(this._decider, this._state);

  final Decider<C, S, E> _decider;
  final S _state;

  GivenStateThenStep<C, S, E> whenCommand(C command) =>
      GivenStateThenStep(_decider, _state, command);
}

final class GivenStateThenStep<C, S, E> {
  const GivenStateThenStep(this._decider, this._state, this._command);

  final Decider<C, S, E> _decider;
  final S _state;
  final C _command;

  Future<void> thenState(S expected) async {
    final events = await _decider.decide(_command, _state).toList();
    final resultingState = events.fold<S>(
      _state,
      (state, event) => _decider.evolve(state, event),
    );
    expect(resultingState, expected);
  }
}

final class GivenEventsWhenStep<C, S, E> {
  const GivenEventsWhenStep(this._decider, this._events);

  final Decider<C, S, E> _decider;
  final Iterable<E> _events;

  GivenEventsThenStep<C, S, E> whenCommand(C command) =>
      GivenEventsThenStep(_decider, _events, command);
}

final class GivenEventsThenStep<C, S, E> {
  const GivenEventsThenStep(this._decider, this._events, this._command);

  final Decider<C, S, E> _decider;
  final Iterable<E> _events;
  final C _command;

  Future<void> thenEvents(Iterable<E> expected) async {
    final stateAfterEvents = _events.fold<S>(
      _decider.initialState,
      (state, event) => _decider.evolve(state, event),
    );
    final resultingEvents = await _decider
        .decide(_command, stateAfterEvents)
        .toList();
    expect(resultingEvents, expected);
  }
}
