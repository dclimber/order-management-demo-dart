import 'package:sqlite3/sqlite3.dart';

const schemaVersion = 2;

const createEventsTable = '''
CREATE TABLE IF NOT EXISTS events (
  id TEXT PRIMARY KEY,
  event_type TEXT NOT NULL,
  payload TEXT NOT NULL,
  created_at TEXT NOT NULL,
  sequence INTEGER NOT NULL
);
''';

const createEventTagsTable = '''
CREATE TABLE IF NOT EXISTS event_tags (
  event_type TEXT NOT NULL,
  tag_key TEXT NOT NULL,
  event_id TEXT NOT NULL,
  sequence INTEGER NOT NULL,
  PRIMARY KEY (event_type, tag_key, event_id),
  FOREIGN KEY (event_id) REFERENCES events(id)
);
''';

const createEventTagsIndex = '''
CREATE INDEX IF NOT EXISTS idx_event_tags_lookup
  ON event_tags(event_type, tag_key, sequence);
''';

const createLastEventsTable = '''
CREATE TABLE IF NOT EXISTS last_events (
  pointer_key TEXT PRIMARY KEY,
  event_id TEXT NOT NULL,
  version INTEGER NOT NULL
);
''';

const createSchemaVersionTable = '''
CREATE TABLE IF NOT EXISTS schema_version (
  version INTEGER NOT NULL
);
''';

const createUsersTable = '''
CREATE TABLE IF NOT EXISTS users (
  id TEXT PRIMARY KEY,
  login TEXT NOT NULL,
  name TEXT NOT NULL,
  avatar_url TEXT NOT NULL,
  email TEXT
);
''';

const createSessionsTable = '''
CREATE TABLE IF NOT EXISTS sessions (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  created_at TEXT NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users(id)
);
''';

/// Apply schema migrations to [db].
void migrate(Database db) {
  db.execute(createEventsTable);
  db.execute(createEventTagsTable);
  db.execute(createEventTagsIndex);
  db.execute(createLastEventsTable);
  db.execute(createSchemaVersionTable);
  db.execute(createUsersTable);
  db.execute(createSessionsTable);

  final versionRows = db.select('SELECT version FROM schema_version LIMIT 1');
  final currentVersion = versionRows.isEmpty ? 0 : versionRows.first['version']! as int;

  if (versionRows.isEmpty) {
    db.execute('INSERT INTO schema_version (version) VALUES (?)', [schemaVersion]);
    return;
  }

  if (currentVersion < schemaVersion) {
    db.execute('UPDATE schema_version SET version = ?', [schemaVersion]);
  }
}
