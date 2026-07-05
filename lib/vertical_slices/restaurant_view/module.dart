import 'package:jaspr/server.dart' hide AppContext;

import '../../api.dart';
import '../../composition/api_registry.dart';
import '../../composition/app_context.dart';
import '../../platform/event_store/serialization_registry.dart';
import '../../composition/ui_registry.dart';
import '../../composition/vertical_slice.dart';
import '../../platform/server/api_response.dart';
import 'dto.dart';
import 'handler.dart';

/// Read-model slice: restaurant projection (D4).
final class RestaurantViewSlice implements VerticalSlice {
  const RestaurantViewSlice();

  @override
  String get name => 'restaurant_view';

  @override
  void registerApi(ApiRegistry registry, AppContext ctx) {
    registry.register(
      method: 'GET',
      path: '/restaurant',
      handler: (request) => _handleGetRestaurantRoute(request, ctx),
    );
  }

  @override
  void registerUi(UiRegistry registry) {}

  @override
  void registerSerialization(SerializationRegistry registry) {}

  Future<Response> _handleGetRestaurantRoute(Request request, AppContext ctx) async {
    final service = ctx.services.restaurantViewService;
    final restaurantId = request.url.queryParameters['restaurantId']?.trim();
    if (restaurantId == null || restaurantId.isEmpty) {
      final result = await handleListRestaurants(service: service);
      return toJsonResponse(
        result,
        (list) => list.map(encodeRestaurantView).toList(),
      );
    }

    final result = await handleGetRestaurant(
      restaurantId: RestaurantId(restaurantId),
      service: service,
    );
    return toJsonResponse(result, encodeRestaurantView);
  }
}
