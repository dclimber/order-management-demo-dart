import 'package:jaspr/server.dart';
import 'package:sqlite3/sqlite3.dart';

import '../id.dart';

/// Authenticated user returned by `/api/me` and shown on protected pages.
final class SessionUser {
  const SessionUser({
    required this.id,
    required this.login,
    required this.name,
    required this.avatarUrl,
    this.email,
  });

  final String id;
  final String login;
  final String name;
  final String avatarUrl;
  final String? email;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SessionUser &&
          id == other.id &&
          login == other.login &&
          name == other.name &&
          avatarUrl == other.avatarUrl &&
          email == other.email;

  @override
  int get hashCode => Object.hash(id, login, name, avatarUrl, email);
}

Map<String, dynamic> encodeSessionUser(SessionUser user) => {
  'id': user.id,
  'login': user.login,
  'name': user.name,
  'avatarUrl': user.avatarUrl,
  'email': user.email,
};

/// Hardcoded development user used until GitHub OAuth is implemented.
///
/// GitHub OAuth (Phase 15.3) is intentionally out of scope for this port:
/// the TypeScript demo relies on `@deno/kv-oauth`, which has no direct Dart
/// equivalent. Use `/signin` to create a dev session backed by SQLite.
const devSessionUser = SessionUser(
  id: 'dev-user-1',
  login: 'dev-user',
  name: 'Dev User',
  avatarUrl: 'https://avatars.githubusercontent.com/u/0?v=4',
  email: 'dev@example.com',
);

const sessionCookieName = 'session_id';

/// SQLite-backed session store mirroring Deno KV `users` / `users_by_session`.
final class SessionService {
  SessionService(this._db);

  final Database _db;

  Future<SessionUser?> resolveUser(Request request) async {
    final sessionId = readCookie(request, sessionCookieName);
    if (sessionId == null || sessionId.isEmpty) return null;
    return getUserBySession(sessionId);
  }

  Future<({String sessionId, SessionUser user})> signInDevUser() async {
    await upsertUser(devSessionUser);
    final sessionId = generateId();
    final createdAt = DateTime.now().toUtc().toIso8601String();
    _db.execute(
      'INSERT INTO sessions (id, user_id, created_at) VALUES (?, ?, ?)',
      [sessionId, devSessionUser.id, createdAt],
    );
    return (sessionId: sessionId, user: devSessionUser);
  }

  Future<void> signOut(String? sessionId) async {
    if (sessionId == null || sessionId.isEmpty) return;
    _db.execute('DELETE FROM sessions WHERE id = ?', [sessionId]);
  }

  Future<SessionUser?> getUserBySession(String sessionId) async {
    final rows = _db.select(
      '''
      SELECT u.id, u.login, u.name, u.avatar_url, u.email
      FROM sessions s
      JOIN users u ON u.id = s.user_id
      WHERE s.id = ?
      LIMIT 1
      ''',
      [sessionId],
    );
    if (rows.isEmpty) return null;
    return _userFromRow(rows.first);
  }

  Future<void> upsertUser(SessionUser user) async {
    _db.execute(
      '''
      INSERT INTO users (id, login, name, avatar_url, email)
      VALUES (?, ?, ?, ?, ?)
      ON CONFLICT(id) DO UPDATE SET
        login = excluded.login,
        name = excluded.name,
        avatar_url = excluded.avatar_url,
        email = excluded.email
      ''',
      [user.id, user.login, user.name, user.avatarUrl, user.email],
    );
  }

  SessionUser _userFromRow(Map<String, Object?> row) => SessionUser(
    id: row['id']! as String,
    login: row['login']! as String,
    name: row['name']! as String,
    avatarUrl: row['avatar_url']! as String,
    email: row['email'] as String?,
  );
}

String? readCookie(Request request, String name) {
  final header = request.headers['cookie'];
  if (header == null) return null;
  for (final part in header.split(';')) {
    final trimmed = part.trim();
    final separator = trimmed.indexOf('=');
    if (separator <= 0) continue;
    final key = trimmed.substring(0, separator);
    if (key == name) {
      return Uri.decodeComponent(trimmed.substring(separator + 1));
    }
  }
  return null;
}

String sessionCookie(String sessionId) =>
    '$sessionCookieName=${Uri.encodeComponent(sessionId)}; Path=/; HttpOnly; SameSite=Lax';

String clearSessionCookie() => '$sessionCookieName=; Path=/; HttpOnly; SameSite=Lax; Max-Age=0';

const protectedPagePaths = {'/dashboard', '/kitchen'};

bool isProtectedPage(String path) {
  final normalized = path.isEmpty || path == '/' ? '/' : (path.startsWith('/') ? path : '/$path');
  return protectedPagePaths.contains(normalized);
}
