import 'app_services.dart';

/// Runtime context passed to slices during API/UI registration.
final class AppContext {
  const AppContext({required this.services});

  final AppServices services;
}

/// Server-side composition root, set during bootstrap in [main.server.dart].
late AppServices appServices;
