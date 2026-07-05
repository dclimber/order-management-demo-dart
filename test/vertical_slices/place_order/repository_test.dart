import 'package:order_management_demo/api.dart';
import 'package:order_management_demo/composition/app_services.dart';
import 'package:order_management_demo/vertical_slices/create_restaurant/command.dart';
import 'package:order_management_demo/vertical_slices/place_order/command.dart';
import 'package:order_management_demo/platform/event_store/in_memory_event_store.dart';
import 'package:order_management_demo/vertical_slices/create_restaurant/decider.dart';
import 'package:order_management_demo/vertical_slices/place_order/decider.dart';
import 'package:order_management_demo/vertical_slices/place_order/errors.dart';
import 'package:test/test.dart';

import '../../platform/support/application_fixtures.dart';
import '../../platform/support/decider_test_event_sourced_dsl.dart';

void main() {
  late AppServices services;

  setUp(() {
    services = AppServices(eventStore: InMemoryEventStore());
  });

  final createCommand = CreateRestaurantCommand(
    restaurantId: RestaurantId('restaurant-1'),
    name: RestaurantName('Italian Bistro'),
    menu: applicationTestMenu,
  );

  final placeOrderCommand = PlaceOrderCommand(
    restaurantId: RestaurantId('restaurant-1'),
    orderId: OrderId('order-1'),
    menuItems: applicationPizzaOrderItems,
  );

  test('PlaceOrderRepository - success', () async {
    await createRestaurantDecider
        .givenEventRepository(services.createRestaurantService.repository)
        .whenCommand(createCommand)
        .thenEvents([
          RestaurantCreatedEvent(
            restaurantId: RestaurantId('restaurant-1'),
            name: RestaurantName('Italian Bistro'),
            menu: applicationTestMenu,
          ),
        ]);

    await placeOrderDecider
        .givenEventRepository(services.placeOrderService.repository)
        .whenCommand(placeOrderCommand)
        .thenEvents([
          RestaurantOrderPlacedEvent(
            restaurantId: RestaurantId('restaurant-1'),
            orderId: OrderId('order-1'),
            menuItems: applicationPizzaOrderItems,
          ),
        ]);
  });

  test('PlaceOrderRepository - restaurant not found', () async {
    await expectLater(
      () => placeOrderDecider
          .givenEventRepository(services.placeOrderService.repository)
          .whenCommand(placeOrderCommand)
          .thenEvents([]),
      throwsA(isA<RestaurantNotFoundError>()),
    );
  });

  test('PlaceOrderRepository - duplicate order', () async {
    await createRestaurantDecider
        .givenEventRepository(services.createRestaurantService.repository)
        .whenCommand(createCommand)
        .thenEvents([
          RestaurantCreatedEvent(
            restaurantId: RestaurantId('restaurant-1'),
            name: RestaurantName('Italian Bistro'),
            menu: applicationTestMenu,
          ),
        ]);

    await placeOrderDecider
        .givenEventRepository(services.placeOrderService.repository)
        .whenCommand(placeOrderCommand)
        .thenEvents([
          RestaurantOrderPlacedEvent(
            restaurantId: RestaurantId('restaurant-1'),
            orderId: OrderId('order-1'),
            menuItems: applicationPizzaOrderItems,
          ),
        ]);

    await expectLater(
      () => placeOrderDecider
          .givenEventRepository(services.placeOrderService.repository)
          .whenCommand(placeOrderCommand)
          .thenEvents([]),
      throwsA(isA<OrderAlreadyExistsError>()),
    );
  });
}
