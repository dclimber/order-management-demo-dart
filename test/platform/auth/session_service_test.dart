import 'package:jaspr/server.dart';
import 'package:order_management_demo/platform/database/sqlite_schema.dart';
import 'package:order_management_demo/platform/auth/session.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

void main() {
  late Database db;
  late SessionService sessions;

  setUp(() {
    db = sqlite3.openInMemory();
    migrate(db);
    sessions = SessionService(db);
  });

  tearDown(() {
    db.close();
  });

  test('signInDevUser creates resolvable session', () async {
    final result = await sessions.signInDevUser();

    final user = await sessions.getUserBySession(result.sessionId);
    expect(user, devSessionUser);
  });

  test('resolveUser reads session from cookie header', () async {
    final result = await sessions.signInDevUser();
    final request = Request(
      'GET',
      Uri.parse('https://example.com/dashboard'),
      headers: {'cookie': sessionCookie(result.sessionId)},
    );

    final user = await sessions.resolveUser(request);
    expect(user, devSessionUser);
  });

  test('signOut removes session', () async {
    final result = await sessions.signInDevUser();
    await sessions.signOut(result.sessionId);

    final user = await sessions.getUserBySession(result.sessionId);
    expect(user, isNull);
  });
}
