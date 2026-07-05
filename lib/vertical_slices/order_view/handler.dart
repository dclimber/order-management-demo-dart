import '../../api.dart';
import '../../platform/server/handler_result.dart';
import 'service.dart';
import 'state.dart';

Future<HandlerResult<OrderViewState>> handleGetOrder({
  required OrderId orderId,
  required OrderViewService service,
}) async {
  final state = await service.query(orderId);
  if (state == null) {
    return HandlerError(404, 'Order ${orderId.value} does not exist');
  }
  return HandlerSuccess(state);
}

Future<HandlerResult<List<OrderViewState>>> handleListKitchenOrders({
  required OrderStatus status,
  required OrderViewService service,
}) async {
  return HandlerSuccess(await service.listByStatus(status));
}
