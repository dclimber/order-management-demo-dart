import 'package:order_management_demo/api.dart';
import 'package:order_management_demo/composition/app_services.dart';
import 'package:order_management_demo/platform/event_store/in_memory_event_store.dart';
import 'package:order_management_demo/vertical_slices/create_restaurant/command.dart';
import 'package:order_management_demo/vertical_slices/place_order/command.dart';
import 'package:test/test.dart';

import '../platform/support/application_fixtures.dart';

void main() {
  late AppServices services;

  setUp(() {
    services = AppServices(eventStore: InMemoryEventStore());
  });

  test('AppServices delegates read queries to slice services', () async {
    await services.createRestaurantService.aggregate
        .handle(
          CreateRestaurantCommand(
            restaurantId: RestaurantId('restaurant-1'),
            name: RestaurantName('Bistro'),
            menu: applicationTestMenu,
          ),
        )
        .toList();

    await services.placeOrderService.aggregate
        .handle(
          PlaceOrderCommand(
            restaurantId: RestaurantId('restaurant-1'),
            orderId: OrderId('order-1'),
            menuItems: applicationTestMenu.menuItems,
          ),
        )
        .toList();

    final restaurant = await services.queryRestaurant(RestaurantId('restaurant-1'));
    final order = await services.queryOrder(OrderId('order-1'));
    final restaurants = await services.queryAllRestaurants();
    final created = await services.queryOrdersByStatus(OrderStatus.created);

    expect(restaurant?.name.value, 'Bistro');
    expect(order?.orderId.value, 'order-1');
    expect(restaurants, hasLength(1));
    expect(created, hasLength(1));
  });
}
