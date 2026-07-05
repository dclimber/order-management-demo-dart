import '../../api.dart';
import '../id.dart';
import 'event_store.dart';
import 'event_tags.dart';

final class _StoredRecord {
  const _StoredRecord({
    required this.id,
    required this.event,
    required this.sequence,
  });

  final String id;
  final Event event;
  final int sequence;
}

final class InMemoryEventStore implements EventStore {
  final _records = <String, _StoredRecord>{};
  final _index = <String, List<String>>{};
  final _lastPointers = <String, ({String eventId, int version})>{};
  var _sequence = 0;

  @override
  Stream<Event> append(
    Stream<Event> events, {
    Map<String, int?> expectedVersions = const {},
  }) async* {
    await for (final event in events) {
      final type = eventTypeName(event);
      final tags = extractTags(event);
      final subsets = generateTagSubsets(tags);
      final pointerKeys = [for (final subset in subsets) indexKey(type, subset)];

      for (final pointerKey in pointerKeys) {
        if (!expectedVersions.containsKey(pointerKey)) continue;
        final expected = expectedVersions[pointerKey];
        final actual = _lastPointers[pointerKey]?.version;
        if (actual != expected) {
          throw OptimisticLockException(
            pointerKey: pointerKey,
            expectedVersion: expected,
            actualVersion: actual,
          );
        }
      }

      final id = generateId();
      final record = _StoredRecord(
        id: id,
        event: event,
        sequence: _sequence++,
      );
      _records[id] = record;

      for (final subset in subsets) {
        final key = indexKey(type, subset);
        _index.putIfAbsent(key, () => []).add(id);
        final version = (_lastPointers[key]?.version ?? 0) + 1;
        _lastPointers[key] = (eventId: id, version: version);
      }

      yield event;
    }
  }

  @override
  Stream<Event> streamForQueries(
    List<({String tag, String value, Type eventType})> queries,
  ) async* {
    final ids = <String>{};
    for (final query in queries) {
      final key = indexKey(typeName(query.eventType), ['${query.tag}:${query.value}']);
      ids.addAll(_index[key] ?? const []);
    }

    final sortedIds = ids.toList()
      ..sort(
        (a, b) => _records[a]!.sequence.compareTo(_records[b]!.sequence),
      );
    for (final id in sortedIds) {
      final record = _records[id];
      if (record != null) {
        yield record.event;
      }
    }
  }

  @override
  Stream<Event> streamFor({
    required String tag,
    required String value,
    required List<Type> eventTypes,
  }) async* {
    final ids = <String>{};
    for (final type in eventTypes) {
      final key = indexKey(typeName(type), ['$tag:$value']);
      ids.addAll(_index[key] ?? const []);
    }

    final sortedIds = ids.toList()
      ..sort(
        (a, b) => _records[a]!.sequence.compareTo(_records[b]!.sequence),
      );
    for (final id in sortedIds) {
      final record = _records[id];
      if (record != null) {
        yield record.event;
      }
    }
  }

  @override
  Stream<Event> streamByEventType(String eventType) async* {
    final sorted = _records.values.toList()..sort((a, b) => a.sequence.compareTo(b.sequence));
    for (final record in sorted) {
      if (eventTypeName(record.event) == eventType) {
        yield record.event;
      }
    }
  }

  @override
  Future<String?> lastEventId({
    required String eventType,
    required String tag,
    required String value,
  }) async {
    return _lastPointers[indexKey(eventType, ['$tag:$value'])]?.eventId;
  }

  @override
  Future<int?> lastEventVersion({
    required String eventType,
    required String tag,
    required String value,
  }) async {
    return _lastPointers[indexKey(eventType, ['$tag:$value'])]?.version;
  }

  @override
  Future<T> withTransaction<T>(Future<T> Function(EventStore store) action) {
    return action(this);
  }

  @override
  Future<void> clear() async {
    _records.clear();
    _index.clear();
    _lastPointers.clear();
    _sequence = 0;
  }
}
