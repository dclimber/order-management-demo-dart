import 'package:fmodel/fmodel.dart';
import 'package:test/test.dart';

// Event Repository
extension ApplicationEventSourcedAggregateTestDsl<C, S, E> on Decider<C, S, E> {
  GivenEventRepositoryWhenStep<C, S, E> givenEventRepository(
    EventRepository<C, E, NoMetadata, NoMetadata> repository,
  ) => GivenEventRepositoryWhenStep(this, repository);

  GivenEventLockingRepositoryWhenStep<C, S, E, V>
  givenEventLockingRepository<V>(
    EventLockingRepository<C, E, V, NoMetadata, NoMetadata> repository,
  ) => GivenEventLockingRepositoryWhenStep(this, repository);

  GivenSagaAndEventRepositoryWhenStep<C, S, E> givenSagaAndEventRepository(
    SagaContract<E, C> saga,
    EventRepository<C, E, NoMetadata, NoMetadata> repository,
  ) => GivenSagaAndEventRepositoryWhenStep(this, saga, repository);

  GivenSagaAndEventLockingRepositoryWhenStep<C, S, E, V>
  givenSagaAndEventLockingRepository<V>(
    SagaContract<E, C> saga,
    EventLockingRepository<C, E, V, NoMetadata, NoMetadata> repository,
  ) => GivenSagaAndEventLockingRepositoryWhenStep(this, saga, repository);
}

final class GivenEventRepositoryWhenStep<C, S, E> {
  const GivenEventRepositoryWhenStep(this._decider, this._repository);

  final Decider<C, S, E> _decider;
  final EventRepository<C, E, NoMetadata, NoMetadata> _repository;

  GivenRepositoryThenStep<C, S, E> whenCommand(C command) =>
      GivenRepositoryThenStep(_decider, _repository, command);
}

final class GivenRepositoryThenStep<C, S, E> {
  const GivenRepositoryThenStep(this._decider, this._repository, this._command);

  final Decider<C, S, E> _decider;
  final EventRepository<C, E, NoMetadata, NoMetadata> _repository;
  final C _command;

  Future<void> thenEvents(Iterable<E> expected) async {
    final resultingEvents = await createEventSourcingAggregate(
      decider: _decider,
      eventRepository: _repository,
    ).handle(_command).toList();
    expect(resultingEvents, expected);
  }
}

// Event Locking Repository

final class GivenEventLockingRepositoryWhenStep<C, S, E, V> {
  const GivenEventLockingRepositoryWhenStep(this._decider, this._repository);

  final Decider<C, S, E> _decider;
  final EventLockingRepository<C, E, V, NoMetadata, NoMetadata> _repository;

  GivenLockingRepositoryThenStep<C, S, E, V> whenCommand(C command) =>
      GivenLockingRepositoryThenStep(_decider, _repository, command);
}

final class GivenLockingRepositoryThenStep<C, S, E, V> {
  const GivenLockingRepositoryThenStep(
    this._decider,
    this._repository,
    this._command,
  );

  final Decider<C, S, E> _decider;
  final EventLockingRepository<C, E, V, NoMetadata, NoMetadata> _repository;
  final C _command;

  Future<void> thenEventPairs(Iterable<(E, V)> expected) async {
    final resultingEventPairs = await createEventSourcingLockingAggregate(
      decider: _decider,
      eventRepository: _repository,
    ).handleOptimistically(_command).toList();

    expect(resultingEventPairs, expected);
  }
}

// Saga + Event Repository

final class GivenSagaAndEventRepositoryWhenStep<C, S, E> {
  const GivenSagaAndEventRepositoryWhenStep(
    this._decider,
    this._saga,
    this._repository,
  );

  final Decider<C, S, E> _decider;
  final SagaContract<E, C> _saga;
  final EventRepository<C, E, NoMetadata, NoMetadata> _repository;

  GivenSagaAndRepositoryThenStep<C, S, E> whenCommand(C command) =>
      GivenSagaAndRepositoryThenStep(_decider, _saga, _repository, command);
}

final class GivenSagaAndRepositoryThenStep<C, S, E> {
  const GivenSagaAndRepositoryThenStep(
    this._decider,
    this._saga,
    this._repository,
    this._command,
  );

  final Decider<C, S, E> _decider;
  final SagaContract<E, C> _saga;
  final EventRepository<C, E, NoMetadata, NoMetadata> _repository;
  final C _command;

  Future<void> thenEvents(Iterable<E> expected) async {
    final resultingEvents = await createEventSourcingOrchestratingAggregate(
      decider: _decider,
      eventRepository: _repository,
      saga: _saga,
    ).handle(_command).toList();

    expect(resultingEvents, expected);
  }
}

final class GivenSagaAndEventLockingRepositoryWhenStep<C, S, E, V> {
  const GivenSagaAndEventLockingRepositoryWhenStep(
    this._decider,
    this._saga,
    this._repository,
  );

  final Decider<C, S, E> _decider;
  final SagaContract<E, C> _saga;
  final EventLockingRepository<C, E, V, NoMetadata, NoMetadata> _repository;

  GivenSagaAndLockingRepositoryThenStep<C, S, E, V> whenCommand(C command) =>
      GivenSagaAndLockingRepositoryThenStep(
        _decider,
        _saga,
        _repository,
        command,
      );
}

final class GivenSagaAndLockingRepositoryThenStep<C, S, E, V> {
  const GivenSagaAndLockingRepositoryThenStep(
    this._decider,
    this._saga,
    this._repository,
    this._command,
  );

  final Decider<C, S, E> _decider;
  final SagaContract<E, C> _saga;
  final EventLockingRepository<C, E, V, NoMetadata, NoMetadata> _repository;
  final C _command;

  Future<void> thenEventPairs(Iterable<(E, V)> expected) async {
    final resultingEventPairs =
        await createEventSourcingLockingOrchestratingAggregate(
          decider: _decider,
          eventRepository: _repository,
          saga: _saga,
        ).handleOptimistically(_command).toList();

    expect(resultingEventPairs, expected);
  }
}
