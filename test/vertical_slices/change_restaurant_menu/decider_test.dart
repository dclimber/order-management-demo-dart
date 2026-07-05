import 'package:order_management_demo/api.dart';
import 'package:order_management_demo/vertical_slices/change_restaurant_menu/command.dart';
import 'package:order_management_demo/vertical_slices/change_restaurant_menu/decider.dart';
import 'package:order_management_demo/vertical_slices/change_restaurant_menu/errors.dart';
import 'package:test/test.dart';

import '../../platform/support/decider_test_dsl.dart';

void main() {
  final command = ChangeRestaurantMenuCommand(
    restaurantId: RestaurantId('restaurant-1'),
    menu: _newMenu,
  );

  test('ChangeRestaurantMenu - success', () async {
    await changeRestaurantMenuDecider
        .givenEvents([
          RestaurantCreatedEvent(
            restaurantId: RestaurantId('restaurant-1'),
            name: RestaurantName('Italian Bistro'),
            menu: _initialMenu,
          ),
        ])
        .whenCommand(command)
        .thenEvents([
          RestaurantMenuChangedEvent(
            restaurantId: RestaurantId('restaurant-1'),
            menu: _newMenu,
          ),
        ]);
  });

  test('ChangeRestaurantMenu - restaurant not found', () async {
    await expectLater(
      () => changeRestaurantMenuDecider.givenEvents([]).whenCommand(command).thenEvents([]),
      throwsA(isA<RestaurantNotFoundError>()),
    );
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

final _newMenu = RestaurantMenu(
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
