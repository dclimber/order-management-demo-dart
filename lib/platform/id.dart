import 'package:ulid/ulid.dart';

/// Generate a time-sortable ULID. Drop-in replacement for `crypto.randomUUID()`.
String generateId() => Ulid().toString();
