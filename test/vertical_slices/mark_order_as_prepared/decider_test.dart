import 'package:order_management_demo/api.dart';
import 'package:order_management_demo/vertical_slices/mark_order_as_prepared/command.dart';
import 'package:order_management_demo/vertical_slices/mark_order_as_prepared/decider.dart';
import 'package:order_management_demo/vertical_slices/mark_order_as_prepared/errors.dart';
import 'package:test/test.dart';

import '../../platform/support/decider_test_dsl.dart';

void main() {
  final command = MarkOrderAsPreparedCommand(orderId: OrderId('order-1'));

  test('MarkOrderAsPrepared - success', () async {
    await markOrderAsPreparedDecider
        .givenEvents([
          RestaurantOrderPlacedEvent(
            restaurantId: RestaurantId('restaurant-1'),
            orderId: OrderId('order-1'),
            menuItems: _pizzaOrderItems,
          ),
        ])
        .whenCommand(command)
        .thenEvents([
          OrderPreparedEvent(orderId: OrderId('order-1')),
        ]);
  });

  test('MarkOrderAsPrepared - order not found', () async {
    await expectLater(
      () => markOrderAsPreparedDecider.givenEvents([]).whenCommand(command).thenEvents([]),
      throwsA(isA<OrderNotFoundError>()),
    );
  });

  test('MarkOrderAsPrepared - already prepared', () async {
    await expectLater(
      () => markOrderAsPreparedDecider
          .givenEvents([
            RestaurantOrderPlacedEvent(
              restaurantId: RestaurantId('restaurant-1'),
              orderId: OrderId('order-1'),
              menuItems: _pizzaOrderItems,
            ),
            OrderPreparedEvent(orderId: OrderId('order-1')),
          ])
          .whenCommand(command)
          .thenEvents([]),
      throwsA(isA<OrderAlreadyPreparedError>()),
    );
  });
}

final _pizzaOrderItems = [
  MenuItem(
    menuItemId: MenuItemId('item-1'),
    name: MenuItemName('Pizza'),
    price: MenuItemPrice('10.00'),
  ),
];
