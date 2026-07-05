import '../../api.dart';

/// Thrown when an append observes a different [last_events.version] than expected.
final class OptimisticLockException implements Exception {
  const OptimisticLockException({
    required this.pointerKey,
    required this.expectedVersion,
    required this.actualVersion,
  });

  final String pointerKey;
  final int? expectedVersion;
  final int? actualVersion;

  @override
  String toString() => 'OptimisticLockException($pointerKey: expected $expectedVersion, actual $actualVersion)';
}

/// Persistence adapter for domain events with tag-based indexing.
abstract interface class EventStore {
  /// Persist events, index tags, and yield the stored domain events.
  ///
  /// [expectedVersions] maps pointer keys (`eventType|tag:value`) to the version
  /// observed before append. A mismatch throws [OptimisticLockException].
  Stream<Event> append(
    Stream<Event> events, {
    Map<String, int?> expectedVersions,
  });

  /// Load events matching a single tag field, filtered by [eventTypes], in
  /// chronological order.
  Stream<Event> streamFor({
    required String tag,
    required String value,
    required List<Type> eventTypes,
  });

  /// Load events matching any [queries], deduplicated, in chronological order.
  Stream<Event> streamForQueries(
    List<({String tag, String value, Type eventType})> queries,
  );

  /// Load all events of [eventType] in chronological order.
  Stream<Event> streamByEventType(String eventType);

  /// Latest event id for the given event type and tag, or null if none.
  Future<String?> lastEventId({
    required String eventType,
    required String tag,
    required String value,
  });

  /// Latest optimistic-lock version for the given event type and tag.
  Future<int?> lastEventVersion({
    required String eventType,
    required String tag,
    required String value,
  });

  /// Run [action] atomically against this store.
  Future<T> withTransaction<T>(Future<T> Function(EventStore store) action);

  /// Reset all stored events. For tests only.
  Future<void> clear();
}
