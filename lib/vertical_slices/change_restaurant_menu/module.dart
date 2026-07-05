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

/// Write slice: change restaurant menu (D3).
final class ChangeRestaurantMenuSlice implements VerticalSlice {
  const ChangeRestaurantMenuSlice();

  @override
  String get name => 'change_restaurant_menu';

  @override
  void registerApi(ApiRegistry registry, AppContext ctx) {
    registry.register(
      method: 'PUT',
      path: '/restaurant/menu',
      handler: (request) => _handleChangeRestaurantMenuRoute(request, ctx),
    );
  }

  @override
  void registerUi(UiRegistry registry) {}

  @override
  void registerSerialization(SerializationRegistry registry) {
    registerChangeRestaurantMenuSerialization(registry);
  }

  Future<Response> _handleChangeRestaurantMenuRoute(Request request, AppContext ctx) async {
    final parsed = await parseRequestBody(request, parseChangeRestaurantMenuCommand);
    if (parsed is ParseError) return jsonError(400, parsed.message);

    final result = await handleChangeRestaurantMenu(
      command: (parsed as ParseSuccess).value,
      service: ctx.services.changeRestaurantMenuService,
    );
    return toJsonResponse(result, encodeEvents);
  }
}
