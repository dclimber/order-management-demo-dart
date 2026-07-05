import 'dart:async';

import 'package:jaspr/server.dart' hide AppContext;

import '../platform/auth/auth_api.dart';
import 'app_context.dart';
import 'slice_registry.dart';
import 'vertical_slice.dart';

typedef ApiRouteHandler = FutureOr<Response> Function(Request request);

/// Collects HTTP API routes from vertical slices.
final class ApiRegistry {
  final _routes = <(String method, String path), ApiRouteHandler>{};

  void register({
    required String method,
    required String path,
    required ApiRouteHandler handler,
  }) {
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    _routes[(method.toUpperCase(), normalizedPath)] = handler;
  }

  /// Match a request to a registered handler, or null if no route matches.
  FutureOr<Response>? match(Request request) {
    final rawPath = request.url.path;
    final path = rawPath.isEmpty ? '/' : (rawPath.startsWith('/') ? rawPath : '/$rawPath');
    return _routes[(request.method.toUpperCase(), path)]?.call(request);
  }

  Iterable<(String method, String path)> get routes => _routes.keys;

  /// Build a registry from all slices plus platform auth routes (R4.1).
  static ApiRegistry build(AppContext ctx, Iterable<VerticalSlice> slices) {
    final registry = ApiRegistry();
    for (final slice in slices) {
      slice.registerApi(registry, ctx);
    }
    registerAuthApi(registry);
    return registry;
  }
}
