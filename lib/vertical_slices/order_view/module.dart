import 'package:jaspr/server.dart' hide AppContext;

import '../../api.dart';
import '../../composition/api_registry.dart';
import '../../composition/app_context.dart';
import '../../platform/event_store/serialization_registry.dart';
import '../../composition/ui_registry.dart';
import '../../composition/vertical_slice.dart';
import '../../platform/server/api_response.dart';
import '../../platform/server/json_parse.dart';
import 'dto.dart';
import 'handler.dart';

/// Read-model slice: order projection (D4).
final class OrderViewSlice implements VerticalSlice {
  const OrderViewSlice();

  @override
  String get name => 'order_view';

  @override
  void registerApi(ApiRegistry registry, AppContext ctx) {
    registry.register(
      method: 'GET',
      path: '/order',
      handler: (request) => _handleGetOrderRoute(request, ctx),
    );
    registry.register(
      method: 'GET',
      path: '/kitchen',
      handler: (request) => _handleListKitchenOrdersRoute(request, ctx),
    );
  }

  @override
  void registerUi(UiRegistry registry) {}

  @override
  void registerSerialization(SerializationRegistry registry) {}

  Future<Response> _handleGetOrderRoute(Request request, AppContext ctx) async {
    final parsed = parseOrderIdQuery(request.url.queryParameters);
    if (parsed is ParseError) return jsonError(400, parsed.message);

    final result = await handleGetOrder(
      orderId: OrderId((parsed as ParseSuccess<String>).value),
      service: ctx.services.orderViewService,
    );
    return toJsonResponse(result, encodeOrderView);
  }

  Future<Response> _handleListKitchenOrdersRoute(Request request, AppContext ctx) async {
    final parsed = parseKitchenStatusQuery(request.url.queryParameters);
    if (parsed is ParseError) return jsonError(400, parsed.message);

    final result = await handleListKitchenOrders(
      status: (parsed as ParseSuccess<OrderStatus>).value,
      service: ctx.services.orderViewService,
    );
    return toJsonResponse(
      result,
      (list) => list.map(encodeOrderView).toList(),
    );
  }
}
