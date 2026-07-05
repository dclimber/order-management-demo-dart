import 'package:order_management_demo/api.dart';
import 'package:order_management_demo/vertical_slices/create_restaurant/command.dart';
import 'package:order_management_demo/vertical_slices/mark_order_as_prepared/command.dart';
import 'package:order_management_demo/vertical_slices/place_order/command.dart';
import 'package:order_management_demo/composition/app_services.dart';
import 'package:order_management_demo/platform/event_store/in_memory_event_store.dart';
import 'package:test/test.dart';

import '../../platform/support/application_fixtures.dart';

void main() {
  late AppServices services;

  setUp(() {
    services = AppServices(eventStore: InMemoryEventStore());
  });

  test('listByStatus filters created and prepared orders', () async {
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
    await services.placeOrderService.aggregate
        .handle(
          PlaceOrderCommand(
            restaurantId: RestaurantId('restaurant-1'),
            orderId: OrderId('order-2'),
            menuItems: applicationTestMenu.menuItems,
          ),
        )
        .toList();

    await services.markOrderAsPreparedService.aggregate
        .handle(MarkOrderAsPreparedCommand(orderId: OrderId('order-2')))
        .toList();

    final created = await services.orderViewService.listByStatus(OrderStatus.created);
    final prepared = await services.orderViewService.listByStatus(OrderStatus.prepared);

    expect(created.map((order) => order.orderId.value), ['order-1']);
    expect(prepared.map((order) => order.orderId.value), ['order-2']);
  });
}
