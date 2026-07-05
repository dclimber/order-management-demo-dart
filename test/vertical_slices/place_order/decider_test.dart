import 'package:order_management_demo/api.dart';
import 'package:order_management_demo/vertical_slices/place_order/command.dart';
import 'package:order_management_demo/vertical_slices/place_order/decider.dart';
import 'package:order_management_demo/vertical_slices/place_order/errors.dart';
import 'package:test/test.dart';

import '../../platform/support/decider_test_dsl.dart';

void main() {
  final command = PlaceOrderCommand(
    restaurantId: RestaurantId('restaurant-1'),
    orderId: OrderId('order-1'),
    menuItems: _pizzaOrderItems,
  );

  test('PlaceOrder - success', () async {
    await placeOrderDecider
        .givenEvents([
          RestaurantCreatedEvent(
            restaurantId: RestaurantId('restaurant-1'),
            name: RestaurantName('Italian Bistro'),
            menu: _initialMenu,
          ),
        ])
        .whenCommand(command)
        .thenEvents([
          RestaurantOrderPlacedEvent(
            restaurantId: RestaurantId('restaurant-1'),
            orderId: OrderId('order-1'),
            menuItems: _pizzaOrderItems,
          ),
        ]);
  });

  test('PlaceOrder - restaurant not found', () async {
    await expectLater(
      () => placeOrderDecider.givenEvents([]).whenCommand(command).thenEvents([]),
      throwsA(isA<RestaurantNotFoundError>()),
    );
  });

  test('PlaceOrder - order already exists', () async {
    await expectLater(
      () => placeOrderDecider
          .givenEvents([
            RestaurantCreatedEvent(
              restaurantId: RestaurantId('restaurant-1'),
              name: RestaurantName('Italian Bistro'),
              menu: _initialMenu,
            ),
            RestaurantOrderPlacedEvent(
              restaurantId: RestaurantId('restaurant-1'),
              orderId: OrderId('order-1'),
              menuItems: _pizzaOrderItems,
            ),
          ])
          .whenCommand(command)
          .thenEvents([]),
      throwsA(isA<OrderAlreadyExistsError>()),
    );
  });

  test('PlaceOrder - menu items not available', () async {
    final invalidCommand = PlaceOrderCommand(
      restaurantId: RestaurantId('restaurant-1'),
      orderId: OrderId('order-1'),
      menuItems: _invalidOrderItems,
    );

    await expectLater(
      () => placeOrderDecider
          .givenEvents([
            RestaurantCreatedEvent(
              restaurantId: RestaurantId('restaurant-1'),
              name: RestaurantName('Italian Bistro'),
              menu: _initialMenu,
            ),
          ])
          .whenCommand(invalidCommand)
          .thenEvents([]),
      throwsA(isA<MenuItemsNotAvailableError>()),
    );
  });

  test('PlaceOrder - after menu change', () async {
    final tacosOrderItems = [
      MenuItem(
        menuItemId: MenuItemId('item-3'),
        name: MenuItemName('Tacos'),
        price: MenuItemPrice('8.00'),
      ),
    ];

    final afterMenuChangeCommand = PlaceOrderCommand(
      restaurantId: RestaurantId('restaurant-1'),
      orderId: OrderId('order-1'),
      menuItems: tacosOrderItems,
    );

    await placeOrderDecider
        .givenEvents([
          RestaurantCreatedEvent(
            restaurantId: RestaurantId('restaurant-1'),
            name: RestaurantName('Italian Bistro'),
            menu: _initialMenu,
          ),
          RestaurantMenuChangedEvent(
            restaurantId: RestaurantId('restaurant-1'),
            menu: _mexicanMenu,
          ),
        ])
        .whenCommand(afterMenuChangeCommand)
        .thenEvents([
          RestaurantOrderPlacedEvent(
            restaurantId: RestaurantId('restaurant-1'),
            orderId: OrderId('order-1'),
            menuItems: tacosOrderItems,
          ),
        ]);
  });
}

final _initialMenu = RestaurantMenu(
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

final _pizzaOrderItems = [
  MenuItem(
    menuItemId: MenuItemId('item-1'),
    name: MenuItemName('Pizza'),
    price: MenuItemPrice('10.00'),
  ),
];

final _invalidOrderItems = [
  MenuItem(
    menuItemId: MenuItemId('item-999'),
    name: MenuItemName('InvalidItem'),
    price: MenuItemPrice('99.00'),
  ),
];
