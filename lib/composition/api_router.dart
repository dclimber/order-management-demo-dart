import 'package:jaspr/server.dart' hide AppContext;

import '../platform/server/api_response.dart';
import 'api_registry.dart';
import 'app_context.dart';
import 'app_services.dart';
import 'slice_registry.dart';

/// Shelf handler for routes mounted at `/api/` (R4.1).
Handler buildApiHandler(AppServices services) {
  final ctx = AppContext(services: services);
  final registry = ApiRegistry.build(ctx, allSlices);

  return (Request request) async {
    final matched = registry.match(request);
    if (matched != null) {
      return await matched;
    }
    return jsonError(404, 'Not found');
  };
}
