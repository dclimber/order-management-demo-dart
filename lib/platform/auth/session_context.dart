import 'session.dart';

/// Server-side session service, initialized during bootstrap.
late SessionService sessionService;

/// Per-request session state, set before rendering or handling APIs.
SessionUser? currentSessionUser;
String? currentSessionId;
