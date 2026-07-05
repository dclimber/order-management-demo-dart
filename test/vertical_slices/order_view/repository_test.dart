import 'package:order_management_demo/api.dart';
import 'package:order_management_demo/vertical_slices/create_restaurant/command.dart';
import 'package:order_management_demo/vertical_slices/mark_order_as_prepared/command.dart';
import 'package:order_management_demo/vertical_slices/place_order/command.dart';
import 'package:order_management_demo/composition/app_services.dart';
import 'package:order_management_demo/platform/event_store/in_memory_event_store.dart';
import 'package:order_management_demo/vertical_slices/order_view/state.dart';
import 'package:order_management_demo/vertical_slices/order_view/view.dart';
import 'package:test/test.dart';

import '../../platform/support/application_fixtures.dart';
import '../../platform/support/ephemeral_view_test_dsl.dart';

void main() {
  late AppServices services;

  setUp(() {
    services = AppServices(eventStore: InMemoryEventStore());
  });

  Future<void> seedPlacedOrder() async {
    await services.createRestaurantService.aggregate
        .handle(
          CreateRestaurantCommand(
            restaurantId: RestaurantId('restaurant-1'),
            name: RestaurantName('Italian Bistro'),
            menu: applicationTestMenu,
          ),
        )
        .toList();

    await services.placeOrderService.aggregate
        .handle(
          PlaceOrderCommand(
            restaurantId: RestaurantId('restaurant-1'),
            orderId: OrderId('order-1'),
            menuItems: applicationPizzaOrderItems,
          ),
        )
        .toList();
  }

  test('OrderEphemeralView - project placed order', () async {
    await seedPlacedOrder();

    await orderView
        .givenEphemeralRepository(services.orderViewService.repository)
        .whenQuery(OrderId('order-1'))
        .thenState(
          OrderViewState(
            orderId: OrderId('order-1'),
            restaurantId: RestaurantId('restaurant-1'),
            menuItems: applicationPizzaOrderItems,
            status: OrderStatus.created,
          ),
        );
  });

  test('OrderEphemeralView - project prepared order', () async {
    await seedPlacedOrder();

    await services.markOrderAsPreparedService.aggregate
        .handle(MarkOrderAsPreparedCommand(orderId: OrderId('order-1')))
        .toList();

    await orderView
        .givenEphemeralRepository(services.orderViewService.repository)
        .whenQuery(OrderId('order-1'))
        .thenState(
          OrderViewState(
            orderId: OrderId('order-1'),
            restaurantId: RestaurantId('restaurant-1'),
            menuItems: applicationPizzaOrderItems,
            status: OrderStatus.prepared,
          ),
        );
  });

  test('OrderEphemeralView - unknown order returns null', () async {
    await orderView
        .givenEphemeralRepository(services.orderViewService.repository)
        .whenQuery(OrderId('missing'))
        .thenState(null);
  });
}
