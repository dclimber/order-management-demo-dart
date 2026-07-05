import 'dart:convert';

import 'package:sqlite3/sqlite3.dart';

import '../../api.dart';
import '../id.dart';
import '../database/sqlite_schema.dart';
import 'event_store.dart';
import 'event_tags.dart';
import 'serialization.dart';

final class SqliteEventStore implements EventStore {
  SqliteEventStore(this._db);

  factory SqliteEventStore.memory() {
    final db = sqlite3.openInMemory();
    migrate(db);
    return SqliteEventStore(db);
  }

  final Database _db;

  void close() => _db.close();

  @override
  Stream<Event> append(
    Stream<Event> events, {
    Map<String, int?> expectedVersions = const {},
  }) async* {
    await for (final event in events) {
      final id = generateId();
      final type = eventTypeName(event);
      final tags = extractTags(event);
      final subsets = generateTagSubsets(tags);
      final pointerKeys = [for (final subset in subsets) indexKey(type, subset)];

      for (final pointerKey in pointerKeys) {
        if (!expectedVersions.containsKey(pointerKey)) continue;
        final expected = expectedVersions[pointerKey];
        final actual = _readVersion(pointerKey);
        if (actual != expected) {
          throw OptimisticLockException(
            pointerKey: pointerKey,
            expectedVersion: expected,
            actualVersion: actual,
          );
        }
      }

      final sequence = _nextSequence();
      final createdAt = DateTime.now().toUtc().toIso8601String();
      final payload = jsonEncode(encodeEvent(event));

      _db.execute(
        'INSERT INTO events (id, event_type, payload, created_at, sequence) VALUES (?, ?, ?, ?, ?)',
        [id, type, payload, createdAt, sequence],
      );

      for (final subset in subsets) {
        final tagKey = subset.join('|');
        final pointerKey = indexKey(type, subset);

        _db.execute(
          'INSERT INTO event_tags (event_type, tag_key, event_id, sequence) VALUES (?, ?, ?, ?)',
          [type, tagKey, id, sequence],
        );

        final newVersion = (_readVersion(pointerKey) ?? 0) + 1;
        _db.execute(
          'INSERT INTO last_events (pointer_key, event_id, version) VALUES (?, ?, ?) '
          'ON CONFLICT(pointer_key) DO UPDATE SET event_id = excluded.event_id, version = excluded.version',
          [pointerKey, id, newVersion],
        );
      }

      yield event;
    }
  }

  @override
  Stream<Event> streamForQueries(
    List<({String tag, String value, Type eventType})> queries,
  ) async* {
    if (queries.isEmpty) return;

    final clauses = <String>[];
    final variables = <Object?>[];
    for (final query in queries) {
      clauses.add('(t.tag_key = ? AND t.event_type = ?)');
      variables.addAll(['${query.tag}:${query.value}', typeName(query.eventType)]);
    }

    final rows = _db.select(
      '''
      SELECT DISTINCT e.payload, e.sequence
      FROM event_tags t
      JOIN events e ON e.id = t.event_id
      WHERE ${clauses.join(' OR ')}
      ORDER BY e.sequence
      ''',
      variables,
    );

    for (final row in rows) {
      yield decodeEvent(
        jsonDecode(row['payload']! as String) as Map<String, dynamic>,
      );
    }
  }

  @override
  Stream<Event> streamFor({
    required String tag,
    required String value,
    required List<Type> eventTypes,
  }) async* {
    if (eventTypes.isEmpty) return;

    final tagKey = '$tag:$value';
    final placeholders = List.filled(eventTypes.length, '?').join(', ');
    final typeNames = eventTypes.map(typeName).toList();

    final rows = _db.select(
      '''
      SELECT e.payload
      FROM event_tags t
      JOIN events e ON e.id = t.event_id
      WHERE t.tag_key = ? AND t.event_type IN ($placeholders)
      ORDER BY e.sequence
      ''',
      [tagKey, ...typeNames],
    );

    for (final row in rows) {
      yield decodeEvent(
        jsonDecode(row['payload']! as String) as Map<String, dynamic>,
      );
    }
  }

  @override
  Stream<Event> streamByEventType(String eventType) async* {
    final rows = _db.select(
      'SELECT payload FROM events WHERE event_type = ? ORDER BY sequence',
      [eventType],
    );

    for (final row in rows) {
      yield decodeEvent(
        jsonDecode(row['payload']! as String) as Map<String, dynamic>,
      );
    }
  }

  @override
  Future<String?> lastEventId({
    required String eventType,
    required String tag,
    required String value,
  }) async {
    return _readPointer(indexKey(eventType, ['$tag:$value']))?.eventId;
  }

  @override
  Future<int?> lastEventVersion({
    required String eventType,
    required String tag,
    required String value,
  }) async {
    return _readVersion(indexKey(eventType, ['$tag:$value']));
  }

  @override
  Future<T> withTransaction<T>(Future<T> Function(EventStore store) action) async {
    _db.execute('BEGIN IMMEDIATE');
    try {
      final result = await action(this);
      _db.execute('COMMIT');
      return result;
    } catch (error) {
      _db.execute('ROLLBACK');
      rethrow;
    }
  }

  @override
  Future<void> clear() async {
    _db.execute('DELETE FROM event_tags');
    _db.execute('DELETE FROM last_events');
    _db.execute('DELETE FROM events');
  }

  int _nextSequence() {
    final rows = _db.select('SELECT COALESCE(MAX(sequence), 0) + 1 AS next FROM events');
    return rows.first['next']! as int;
  }

  int? _readVersion(String pointerKey) => _readPointer(pointerKey)?.version;

  ({String eventId, int version})? _readPointer(String pointerKey) {
    final rows = _db.select(
      'SELECT event_id, version FROM last_events WHERE pointer_key = ? LIMIT 1',
      [pointerKey],
    );
    if (rows.isEmpty) return null;
    final row = rows.first;
    return (eventId: row['event_id']! as String, version: row['version']! as int);
  }
}
