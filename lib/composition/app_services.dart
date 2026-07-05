import '../api.dart';
import '../platform/event_store/event_store.dart';
import '../vertical_slices/change_restaurant_menu/service.dart';
import '../vertical_slices/create_restaurant/service.dart';
import '../vertical_slices/mark_order_as_prepared/service.dart';
import '../vertical_slices/order_view/service.dart';
import '../vertical_slices/order_view/state.dart';
import '../vertical_slices/place_order/service.dart';
import '../vertical_slices/restaurant_view/service.dart';
import '../vertical_slices/restaurant_view/state.dart';

/// Thin composition facade — delegates to slice services (R4.2).
final class AppServices {
  AppServices({required EventStore eventStore}) : eventStore = eventStore {
    createRestaurantService = CreateRestaurantService(eventStore: eventStore);
    changeRestaurantMenuService = ChangeRestaurantMenuService(eventStore: eventStore);
    placeOrderService = PlaceOrderService(eventStore: eventStore);
    markOrderAsPreparedService = MarkOrderAsPreparedService(eventStore: eventStore);
    restaurantViewService = RestaurantViewService(eventStore: eventStore);
    orderViewService = OrderViewService(eventStore: eventStore);
  }

  final EventStore eventStore;

  late final CreateRestaurantService createRestaurantService;
  late final ChangeRestaurantMenuService changeRestaurantMenuService;
  late final PlaceOrderService placeOrderService;
  late final MarkOrderAsPreparedService markOrderAsPreparedService;
  late final RestaurantViewService restaurantViewService;
  late final OrderViewService orderViewService;

  Future<RestaurantViewState?> queryRestaurant(RestaurantId restaurantId) => restaurantViewService.query(restaurantId);

  Future<OrderViewState?> queryOrder(OrderId orderId) => orderViewService.query(orderId);

  Future<List<RestaurantViewState>> queryAllRestaurants() => restaurantViewService.queryAll();

  Future<List<OrderViewState>> queryOrdersByStatus(OrderStatus status) => orderViewService.listByStatus(status);
}
