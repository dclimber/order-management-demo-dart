import 'package:order_management_demo/api.dart';
import 'package:order_management_demo/composition/app_services.dart';
import 'package:order_management_demo/vertical_slices/create_restaurant/command.dart';
import 'package:order_management_demo/vertical_slices/mark_order_as_prepared/command.dart';
import 'package:order_management_demo/vertical_slices/place_order/command.dart';
import 'package:order_management_demo/platform/event_store/in_memory_event_store.dart';
import 'package:order_management_demo/vertical_slices/create_restaurant/decider.dart';
import 'package:order_management_demo/vertical_slices/mark_order_as_prepared/decider.dart';
import 'package:order_management_demo/vertical_slices/mark_order_as_prepared/errors.dart';
import 'package:order_management_demo/vertical_slices/place_order/decider.dart';
import 'package:test/test.dart';

import '../../platform/support/application_fixtures.dart';
import '../../platform/support/decider_test_event_sourced_dsl.dart';

void main() {
  late AppServices services;

  setUp(() {
    services = AppServices(eventStore: InMemoryEventStore());
  });

  final markPreparedCommand = MarkOrderAsPreparedCommand(
    orderId: OrderId('order-1'),
  );

  Future<void> seedPlacedOrder() async {
    await createRestaurantDecider
        .givenEventRepository(services.createRestaurantService.repository)
        .whenCommand(
          CreateRestaurantCommand(
            restaurantId: RestaurantId('restaurant-1'),
            name: RestaurantName('Italian Bistro'),
            menu: applicationTestMenu,
          ),
        )
        .thenEvents([
          RestaurantCreatedEvent(
            restaurantId: RestaurantId('restaurant-1'),
            name: RestaurantName('Italian Bistro'),
            menu: applicationTestMenu,
          ),
        ]);

    await placeOrderDecider
        .givenEventRepository(services.placeOrderService.repository)
        .whenCommand(
          PlaceOrderCommand(
            restaurantId: RestaurantId('restaurant-1'),
            orderId: OrderId('order-1'),
            menuItems: applicationPizzaOrderItems,
          ),
        )
        .thenEvents([
          RestaurantOrderPlacedEvent(
            restaurantId: RestaurantId('restaurant-1'),
            orderId: OrderId('order-1'),
            menuItems: applicationPizzaOrderItems,
          ),
        ]);
  }

  test('MarkOrderAsPreparedRepository - success', () async {
    await seedPlacedOrder();

    await markOrderAsPreparedDecider
        .givenEventRepository(services.markOrderAsPreparedService.repository)
        .whenCommand(markPreparedCommand)
        .thenEvents([
          OrderPreparedEvent(orderId: OrderId('order-1')),
        ]);
  });

  test('MarkOrderAsPreparedRepository - order not found', () async {
    await expectLater(
      () => markOrderAsPreparedDecider
          .givenEventRepository(services.markOrderAsPreparedService.repository)
          .whenCommand(markPreparedCommand)
          .thenEvents([]),
      throwsA(isA<OrderNotFoundError>()),
    );
  });
}
