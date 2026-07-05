import 'package:jaspr/server.dart' hide AppContext;

import '../../composition/api_registry.dart';
import '../../composition/app_context.dart';
import '../../platform/event_store/serialization_registry.dart';
import '../../platform/server/event_encoding.dart';
import '../../platform/server/json_parse.dart';
import '../../platform/server/request_body.dart';
import '../../composition/ui_registry.dart';
import '../../composition/vertical_slice.dart';
import '../../platform/server/api_response.dart';
import 'dto.dart';
import 'handler.dart';
import 'serialization.dart';

/// Write slice: mark order as prepared (D3).
final class MarkOrderAsPreparedSlice implements VerticalSlice {
  const MarkOrderAsPreparedSlice();

  @override
  String get name => 'mark_order_as_prepared';

  @override
  void registerApi(ApiRegistry registry, AppContext ctx) {
    registry.register(
      method: 'POST',
      path: '/kitchen',
      handler: (request) => _handleMarkOrderAsPreparedRoute(request, ctx),
    );
  }

  @override
  void registerUi(UiRegistry registry) {}

  @override
  void registerSerialization(SerializationRegistry registry) {
    registerMarkOrderAsPreparedSerialization(registry);
  }

  Future<Response> _handleMarkOrderAsPreparedRoute(Request request, AppContext ctx) async {
    final parsed = await parseRequestBody(request, parseMarkOrderAsPreparedCommand);
    if (parsed is ParseError) return jsonError(400, parsed.message);

    final result = await handleMarkOrderAsPrepared(
      command: (parsed as ParseSuccess).value,
      service: ctx.services.markOrderAsPreparedService,
    );
    return toJsonResponse(result, encodeEvents);
  }
}
