import 'package:fmodel/fmodel.dart';
import 'package:test/test.dart';

// Ephemeral view
extension ApplicationEphemeralViewTestDsl<S, E> on View<S, E> {
  GivenEphemeralRepositoryWhenStep<S, E, Q> givenEphemeralRepository<Q>(
    EphemeralViewRepository<E, Q> repository,
  ) => GivenEphemeralRepositoryWhenStep(this, repository);
}

final class GivenEphemeralRepositoryWhenStep<S, E, Q> {
  const GivenEphemeralRepositoryWhenStep(this._view, this._repository);

  final View<S, E> _view;
  final EphemeralViewRepository<E, Q> _repository;

  GivenRepositoryThenStep<S, E, Q> whenQuery(Q query) =>
      GivenRepositoryThenStep(_view, _repository, query);
}

final class GivenRepositoryThenStep<S, E, Q> {
  const GivenRepositoryThenStep(this._view, this._repository, this._query);

  final View<S, E> _view;
  final EphemeralViewRepository<E, Q> _repository;
  final Q _query;

  Future<void> thenState(S expected) async {
    final resultingState = await createEphemeralView(
      view: _view,
      ephemeralViewRepository: _repository,
    ).handle(_query);
    expect(resultingState, expected);
  }
}

// Materilized view
extension ApplicationMaterializedViewTestDsl<S, E> on View<S, E> {
  GivenMaterializedRepositoryWhenStep<S, E> givenStateRepository(
    ViewStateRepository<E, S, NoMetadata> repository,
  ) => GivenMaterializedRepositoryWhenStep(this, repository);
}

final class GivenMaterializedRepositoryWhenStep<S, E> {
  const GivenMaterializedRepositoryWhenStep(this._view, this._repository);

  final View<S, E> _view;
  final ViewStateRepository<E, S, NoMetadata> _repository;

  GivenMaterializedRepositoryThenStep<S, E> whenEvent(E event) =>
      GivenMaterializedRepositoryThenStep(_view, _repository, event);
}

final class GivenMaterializedRepositoryThenStep<S, E> {
  const GivenMaterializedRepositoryThenStep(
    this._view,
    this._repository,
    this._event,
  );

  final View<S, E> _view;
  final ViewStateRepository<E, S, NoMetadata> _repository;
  final E _event;

  Future<void> thenState(S expected) async {
    final resultingState = await createMaterializedView(
      view: _view,
      viewStateRepository: _repository,
    ).handle(_event);
    expect(resultingState, expected);
  }
}

// Materialized Locking View
extension ApplicationMaterializedLockingViewTestDsl<S, E, V> on View<S, E> {
  GivenViewStateLockingRepositoryWhenStep<S, E, V> givenStateLockingRepository(
    ViewStateLockingRepository<E, S, V, NoMetadata> repository,
  ) => GivenViewStateLockingRepositoryWhenStep(this, repository);
}

final class GivenViewStateLockingRepositoryWhenStep<S, E, V> {
  const GivenViewStateLockingRepositoryWhenStep(this._view, this._repository);

  final View<S, E> _view;
  final ViewStateLockingRepository<E, S, V, NoMetadata> _repository;

  GivenMaterializedLockingRepositoryThenStep<S, E, V> whenEvent(E event) =>
      GivenMaterializedLockingRepositoryThenStep(_view, _repository, event);
}

final class GivenMaterializedLockingRepositoryThenStep<S, E, V> {
  const GivenMaterializedLockingRepositoryThenStep(
    this._view,
    this._repository,
    this._event,
  );

  final View<S, E> _view;
  final ViewStateLockingRepository<E, S, V, NoMetadata> _repository;
  final E _event;

  Future<void> thenStateAndVersion((S, V) expected) async {
    final resultingState = await createMaterializedLockingView(
      view: _view,
      viewStateLockingRepository: _repository,
    ).handleOptimistically(_event);
    expect(resultingState, expected);
  }
}

// Materialized Locking Deduplication View
extension ApplicationMaterializedLockingDeduplicationViewTestDsl<S, E, EV, SV>
    on View<S, E> {
  GivenViewStateLockingDeduplicationRepositoryWhenStep<S, E, EV, SV>
  givenStateLockingDeduplicationRepository(
    ViewStateLockingDeduplicationRepository<E, S, EV, SV, NoMetadata>
    repository,
  ) => GivenViewStateLockingDeduplicationRepositoryWhenStep(this, repository);
}

final class GivenViewStateLockingDeduplicationRepositoryWhenStep<S, E, EV, SV> {
  const GivenViewStateLockingDeduplicationRepositoryWhenStep(
    this._view,
    this._repository,
  );

  final View<S, E> _view;
  final ViewStateLockingDeduplicationRepository<E, S, EV, SV, NoMetadata>
  _repository;

  GivenMaterializedLockingDeduplicationRepositoryThenStep<S, E, EV, SV>
  whenEventAndVersion(E event, EV version) =>
      GivenMaterializedLockingDeduplicationRepositoryThenStep(
        _view,
        _repository,
        (event, version),
      );
}

final class GivenMaterializedLockingDeduplicationRepositoryThenStep<
  S,
  E,
  EV,
  SV
> {
  const GivenMaterializedLockingDeduplicationRepositoryThenStep(
    this._view,
    this._repository,
    this._eventAndVersion,
  );

  final View<S, E> _view;
  final ViewStateLockingDeduplicationRepository<E, S, EV, SV, NoMetadata>
  _repository;
  final (E, EV) _eventAndVersion;

  Future<void> thenStateAndVersion((S, SV) expected) async {
    final resultingState = await createMaterializedLockingDeduplicationView(
      view: _view,
      viewStateLockingDeduplicationRepository: _repository,
    ).handleOptimisticallyWithDeduplication(_eventAndVersion);
    expect(resultingState, expected);
  }
}
