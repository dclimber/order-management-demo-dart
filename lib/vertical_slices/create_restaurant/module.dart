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

/// Write slice: create restaurant (D3).
final class CreateRestaurantSlice implements VerticalSlice {
  const CreateRestaurantSlice();

  @override
  String get name => 'create_restaurant';

  @override
  void registerApi(ApiRegistry registry, AppContext ctx) {
    registry.register(
      method: 'POST',
      path: '/restaurant',
      handler: (request) => _handleCreateRestaurantRoute(request, ctx),
    );
  }

  @override
  void registerUi(UiRegistry registry) {}

  @override
  void registerSerialization(SerializationRegistry registry) {
    registerCreateRestaurantSerialization(registry);
  }

  Future<Response> _handleCreateRestaurantRoute(Request request, AppContext ctx) async {
    final parsed = await parseRequestBody(request, parseCreateRestaurantCommand);
    if (parsed is ParseError) return jsonError(400, parsed.message);

    final result = await handleCreateRestaurant(
      command: (parsed as ParseSuccess).value,
      service: ctx.services.createRestaurantService,
    );
    return toJsonResponse(result, encodeEvents);
  }
}
