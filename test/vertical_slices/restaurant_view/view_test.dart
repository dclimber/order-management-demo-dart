import 'package:order_management_demo/api.dart';
import 'package:order_management_demo/vertical_slices/restaurant_view/state.dart';
import 'package:order_management_demo/vertical_slices/restaurant_view/view.dart';
import 'package:test/test.dart';

import '../../platform/support/view_test_dsl.dart';

void main() {
  test('RestaurantView - created', () {
    restaurantView
        .givenEvents([
          RestaurantCreatedEvent(
            restaurantId: RestaurantId('restaurant-1'),
            name: RestaurantName('Italian Bistro'),
            menu: _initialMenu,
          ),
        ])
        .thenState(
          RestaurantViewState(
            restaurantId: RestaurantId('restaurant-1'),
            name: RestaurantName('Italian Bistro'),
            menu: _initialMenu,
          ),
        );
  });

  test('RestaurantView - menu changed after creation', () {
    restaurantView
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
        .thenState(
          RestaurantViewState(
            restaurantId: RestaurantId('restaurant-1'),
            name: RestaurantName('Italian Bistro'),
            menu: _mexicanMenu,
          ),
        );
  });

  test('RestaurantView - menu changed on null state returns null', () {
    restaurantView
        .givenEvents([
          RestaurantMenuChangedEvent(
            restaurantId: RestaurantId('restaurant-1'),
            menu: _mexicanMenu,
          ),
        ])
        .thenState(null);
  });

  test('RestaurantView - only restaurant events affect state', () {
    restaurantView
        .givenEvents([
          RestaurantCreatedEvent(
            restaurantId: RestaurantId('restaurant-1'),
            name: RestaurantName('Italian Bistro'),
            menu: _initialMenu,
          ),
        ])
        .thenState(
          RestaurantViewState(
            restaurantId: RestaurantId('restaurant-1'),
            name: RestaurantName('Italian Bistro'),
            menu: _initialMenu,
          ),
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
