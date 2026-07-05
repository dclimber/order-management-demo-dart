import 'package:jaspr/server.dart';

import 'session.dart';

Future<Response> handleSignIn(Request request, SessionService sessions) async {
  final redirect = request.url.queryParameters['redirect'] ?? '/';
  final safeRedirect = redirect.startsWith('/') ? redirect : '/';
  final result = await sessions.signInDevUser();
  return Response.found(
    safeRedirect,
    headers: {'set-cookie': sessionCookie(result.sessionId)},
  );
}

Future<Response> handleSignOut(Request request, SessionService sessions) async {
  final sessionId = readCookie(request, sessionCookieName);
  await sessions.signOut(sessionId);
  return Response.found('/', headers: {'set-cookie': clearSessionCookie()});
}
