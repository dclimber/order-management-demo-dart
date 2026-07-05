import 'dart:io';

import 'package:sqlite3/sqlite3.dart';

import 'sqlite_schema.dart';

const defaultDatabasePath = 'data/events.db';

/// Opens the SQLite event store database at [path], creating parent
/// directories and applying migrations when needed.
Database openDatabase({String path = defaultDatabasePath}) {
  final file = File(path);
  file.parent.createSync(recursive: true);
  final db = sqlite3.open(file.path);
  migrate(db);
  return db;
}
