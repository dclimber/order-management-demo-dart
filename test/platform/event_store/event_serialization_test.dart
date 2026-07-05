import 'package:order_management_demo/api.dart';
import 'package:order_management_demo/platform/event_store/serialization.dart';
import 'package:test/test.dart';

import 'test_setup.dart';

void main() {
  setUpAll(setUpPlatformEventStore);

  test('RestaurantCreatedEvent round-trips through JSON', () {
    final event = RestaurantCreatedEvent(
      restaurantId: RestaurantId('restaurant-1'),
      name: RestaurantName('Italian Bistro'),
      menu: _testMenu,
      isFinal: false,
    );

    expect(decodeEvent(encodeEvent(event)), event);
  });

  test('RestaurantMenuChangedEvent round-trips through JSON', () {
    final event = RestaurantMenuChangedEvent(
      restaurantId: RestaurantId('restaurant-1'),
      menu: _mexicanMenu,
      isFinal: false,
    );

    expect(decodeEvent(encodeEvent(event)), event);
  });

  test('RestaurantOrderPlacedEvent round-trips through JSON', () {
    final event = RestaurantOrderPlacedEvent(
      restaurantId: RestaurantId('restaurant-1'),
      orderId: OrderId('order-1'),
      menuItems: _pizzaItems,
      isFinal: false,
    );

    expect(decodeEvent(encodeEvent(event)), event);
  });

  test('OrderPreparedEvent round-trips through JSON', () {
    final event = OrderPreparedEvent(
      orderId: OrderId('order-1'),
      isFinal: false,
    );

    expect(decodeEvent(encodeEvent(event)), event);
  });
}

final _testMenu = RestaurantMenu(
  menuItems: [
    MenuItem(
      menuItemId: MenuItemId('item-1'),
      name: MenuItemName('Pizza'),
      price: MenuItemPrice('10.00'),
    ),
    MenuItem(
      menuItemId: MenuItemId('item-2'),
      name: MenuItemName('Pasta'),
      price: MenuItemPrice('12.00'),
    ),
  ],
  menuId: RestaurantMenuId('menu-1'),
  cuisine: RestaurantMenuCuisine.italian,
);

final _mexicanMenu = RestaurantMenu(
  menuItems: [
    MenuItem(
      menuItemId: MenuItemId('item-3'),
      name: MenuItemName('Tacos'),
      price: MenuItemPrice('8.00'),
    ),
  ],
  menuId: RestaurantMenuId('menu-2'),
  cuisine: RestaurantMenuCuisine.mexican,
);

final _pizzaItems = [
  MenuItem(
    menuItemId: MenuItemId('item-1'),
    name: MenuItemName('Pizza'),
    price: MenuItemPrice('10.00'),
  ),
];
