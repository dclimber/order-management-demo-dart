/// The entrypoint for the **server** environment.
///
/// The [main] method will only be executed on the server during pre-rendering.
/// To run code on the client, check the `main.client.dart` file.
library;

import 'dart:io';

// Server-specific Jaspr import.
import 'package:jaspr/server.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';

import 'composition/api_router.dart';
import 'composition/app_context.dart';
import 'composition/app_services.dart';
import 'composition/serialization_bootstrap.dart';
import 'platform/auth/auth_routes.dart';
import 'platform/auth/session.dart';
import 'platform/auth/session_context.dart';
import 'platform/database/database.dart';
import 'platform/event_store/serialization.dart';
import 'platform/event_store/sqlite_event_store.dart';
import 'shell/app.dart';
import 'shell/constants/theme.dart';

// This file is generated automatically by Jaspr, do not remove or edit.
import 'main.server.options.dart';

/// Keeps track of the currently running http server.
HttpServer? activeServer;

/// Keeps track of the last created reload lock.
Object? activeReloadLock;

Middleware sessionMiddleware() {
  return (Handler inner) {
    return (Request request) async {
      currentSessionUser = await sessionService.resolveUser(request);
      currentSessionId = readCookie(request, sessionCookieName);
      return inner(request);
    };
  };
}

void main() async {
  configureEventSerialization(bootstrapSerializationRegistry());

  final db = openDatabase();
  appServices = AppServices(eventStore: SqliteEventStore(db));
  sessionService = SessionService(db);

  Jaspr.initializeApp(
    options: defaultServerOptions,
  );

  final router = Router();
  router.get('/signin', (request) => handleSignIn(request, sessionService));
  router.get('/signout', (request) => handleSignOut(request, sessionService));
  router.mount('/api/', buildApiHandler(appServices));
  router.mount(
    '/',
    serveApp((request, render) {
      final path = request.url.path;
      if (isProtectedPage(path) && currentSessionUser == null) {
        final redirectPath = path.startsWith('/') ? path : '/$path';
        return Response.found(
          '/signin?redirect=${Uri.encodeComponent(redirectPath)}',
        );
      }
      return render(
        Document(
          title: 'order_management_demo',
          styles: styles,
          head: [
            .element(
              tag: 'script',
              attributes: {'src': '/theme.js'},
            ),
          ],
          body: App(),
        ),
      );
    }),
  );

  final handler = Pipeline().addMiddleware(sessionMiddleware()).addHandler(router.call);

  final reloadLock = activeReloadLock = Object();
  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final server = await shelf_io.serve(handler, InternetAddress.anyIPv4, port, shared: true);

  if (reloadLock != activeReloadLock) {
    await server.close();
    return;
  }

  await activeServer?.close();
  activeServer = server;

  print('Serving at http://${server.address.host}:${server.port}');
}
