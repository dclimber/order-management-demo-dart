import 'package:order_management_demo/api.dart';
import 'package:order_management_demo/vertical_slices/order_view/state.dart';
import 'package:order_management_demo/vertical_slices/order_view/view.dart';
import 'package:test/test.dart';

import '../../platform/support/view_test_dsl.dart';

void main() {
  test('OrderView - order placed', () {
    orderView
        .givenEvents([
          RestaurantOrderPlacedEvent(
            orderId: OrderId('order-1'),
            restaurantId: RestaurantId('restaurant-1'),
            menuItems: _pizzaOrderItems,
          ),
        ])
        .thenState(
          OrderViewState(
            orderId: OrderId('order-1'),
            restaurantId: RestaurantId('restaurant-1'),
            menuItems: _pizzaOrderItems,
            status: OrderStatus.created,
          ),
        );
  });

  test('OrderView - order prepared', () {
    orderView
        .givenEvents([
          RestaurantOrderPlacedEvent(
            orderId: OrderId('order-1'),
            restaurantId: RestaurantId('restaurant-1'),
            menuItems: _pizzaOrderItems,
          ),
          OrderPreparedEvent(orderId: OrderId('order-1')),
        ])
        .thenState(
          OrderViewState(
            orderId: OrderId('order-1'),
            restaurantId: RestaurantId('restaurant-1'),
            menuItems: _pizzaOrderItems,
            status: OrderStatus.prepared,
          ),
        );
  });

  test('OrderView - prepared event on null state returns null', () {
    orderView
        .givenEvents([
          OrderPreparedEvent(orderId: OrderId('order-1')),
        ])
        .thenState(null);
  });
}

final _pizzaOrderItems = [
  MenuItem(
    menuItemId: MenuItemId('item-1'),
    name: MenuItemName('Pizza'),
    price: MenuItemPrice('10.00'),
  ),
];
