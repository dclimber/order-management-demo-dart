import 'package:order_management_demo/api.dart';
import 'package:order_management_demo/vertical_slices/create_restaurant/command.dart';
import 'package:order_management_demo/vertical_slices/create_restaurant/decider.dart';
import 'package:order_management_demo/vertical_slices/create_restaurant/errors.dart';
import 'package:test/test.dart';

import '../../platform/support/decider_test_dsl.dart';

void main() {
  final command = CreateRestaurantCommand(
    restaurantId: RestaurantId('restaurant-1'),
    name: RestaurantName('Italian Bistro'),
    menu: _testMenu,
  );

  test('CreateRestaurant - success', () async {
    await createRestaurantDecider.givenEvents([]).whenCommand(command).thenEvents([
      RestaurantCreatedEvent(
        restaurantId: RestaurantId('restaurant-1'),
        name: RestaurantName('Italian Bistro'),
        menu: _testMenu,
      ),
    ]);
  });

  test('CreateRestaurant - already exists', () async {
    await expectLater(
      () => createRestaurantDecider
          .givenEvents([
            RestaurantCreatedEvent(
              restaurantId: RestaurantId('restaurant-1'),
              name: RestaurantName('Italian Bistro'),
              menu: _testMenu,
            ),
          ])
          .whenCommand(command)
          .thenEvents([]),
      throwsA(isA<RestaurantAlreadyExistsError>()),
    );
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
