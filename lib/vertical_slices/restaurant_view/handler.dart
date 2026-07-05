import '../../api.dart';
import '../../platform/server/handler_result.dart';
import 'service.dart';
import 'state.dart';

Future<HandlerResult<RestaurantViewState>> handleGetRestaurant({
  required RestaurantId restaurantId,
  required RestaurantViewService service,
}) async {
  final state = await service.query(restaurantId);
  if (state == null) {
    return HandlerError(404, 'Restaurant ${restaurantId.value} does not exist');
  }
  return HandlerSuccess(state);
}

Future<HandlerResult<List<RestaurantViewState>>> handleListRestaurants({
  required RestaurantViewService service,
}) async {
  return HandlerSuccess(await service.queryAll());
}
