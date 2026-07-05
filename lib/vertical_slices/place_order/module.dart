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

/// Write slice: place order (D3).
final class PlaceOrderSlice implements VerticalSlice {
  const PlaceOrderSlice();

  @override
  String get name => 'place_order';

  @override
  void registerApi(ApiRegistry registry, AppContext ctx) {
    registry.register(
      method: 'POST',
      path: '/order',
      handler: (request) => _handlePlaceOrderRoute(request, ctx),
    );
  }

  @override
  void registerUi(UiRegistry registry) {}

  @override
  void registerSerialization(SerializationRegistry registry) {
    registerPlaceOrderSerialization(registry);
  }

  Future<Response> _handlePlaceOrderRoute(Request request, AppContext ctx) async {
    final parsed = await parseRequestBody(request, parsePlaceOrderCommand);
    if (parsed is ParseError) return jsonError(400, parsed.message);

    final result = await handlePlaceOrder(
      command: (parsed as ParseSuccess).value,
      service: ctx.services.placeOrderService,
    );
    return toJsonResponse(result, encodeEvents);
  }
}
