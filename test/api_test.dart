import 'package:order_management_demo/api.dart';
import 'package:order_management_demo/vertical_slices/change_restaurant_menu/command.dart';
import 'package:order_management_demo/vertical_slices/change_restaurant_menu/errors.dart';
import 'package:order_management_demo/vertical_slices/create_restaurant/command.dart';
import 'package:order_management_demo/vertical_slices/create_restaurant/errors.dart';
import 'package:order_management_demo/vertical_slices/mark_order_as_prepared/command.dart';
import 'package:order_management_demo/vertical_slices/mark_order_as_prepared/errors.dart';
import 'package:order_management_demo/vertical_slices/place_order/command.dart';
import 'package:order_management_demo/vertical_slices/place_order/errors.dart' hide RestaurantNotFoundError;
import 'package:test/test.dart';

void main() {
  group('extension type IDs', () {
    test('RestaurantId accepts non-empty value', () {
      expect(RestaurantId('restaurant-1').value, 'restaurant-1');
    });

    test('RestaurantId rejects empty value', () {
      expect(() => RestaurantId(''), throwsArgumentError);
    });

    test('OrderId accepts non-empty value', () {
      expect(OrderId('order-1').value, 'order-1');
    });

    test('OrderId rejects empty value', () {
      expect(() => OrderId(''), throwsArgumentError);
    });

    test('MenuItemId accepts non-empty value', () {
      expect(MenuItemId('item-1').value, 'item-1');
    });

    test('MenuItemId rejects empty value', () {
      expect(() => MenuItemId(''), throwsArgumentError);
    });

    test('RestaurantMenuId accepts non-empty value', () {
      expect(RestaurantMenuId('menu-1').value, 'menu-1');
    });

    test('RestaurantMenuId rejects empty value', () {
      expect(() => RestaurantMenuId(''), throwsArgumentError);
    });
  });

  group('sealed commands', () {
    test('CreateRestaurantCommand constructs correctly', () {
      final command = CreateRestaurantCommand(
        restaurantId: RestaurantId('restaurant-1'),
        name: RestaurantName('Italian Bistro'),
        menu: testMenu,
      );

      expect(command.restaurantId, RestaurantId('restaurant-1'));
      expect(command.name, RestaurantName('Italian Bistro'));
      expect(command.menu, testMenu);
    });

    test('ChangeRestaurantMenuCommand constructs correctly', () {
      final command = ChangeRestaurantMenuCommand(
        restaurantId: RestaurantId('restaurant-1'),
        menu: testMenu,
      );

      expect(command.restaurantId, RestaurantId('restaurant-1'));
      expect(command.menu, testMenu);
    });

    test('PlaceOrderCommand constructs correctly', () {
      final command = PlaceOrderCommand(
        restaurantId: RestaurantId('restaurant-1'),
        orderId: OrderId('order-1'),
        menuItems: testMenu.menuItems,
      );

      expect(command.restaurantId, RestaurantId('restaurant-1'));
      expect(command.orderId, OrderId('order-1'));
      expect(command.menuItems, testMenu.menuItems);
    });

    test('MarkOrderAsPreparedCommand constructs correctly', () {
      final command = MarkOrderAsPreparedCommand(
        orderId: OrderId('order-1'),
      );

      expect(command.orderId, OrderId('order-1'));
    });
  });

  group('sealed events', () {
    test('RestaurantCreatedEvent constructs correctly', () {
      final event = RestaurantCreatedEvent(
        restaurantId: RestaurantId('restaurant-1'),
        name: RestaurantName('Italian Bistro'),
        menu: testMenu,
      );

      expect(event.restaurantId, RestaurantId('restaurant-1'));
      expect(event.name, RestaurantName('Italian Bistro'));
      expect(event.menu, testMenu);
      expect(event.isFinal, isTrue);
    });

    test('RestaurantMenuChangedEvent constructs correctly', () {
      final event = RestaurantMenuChangedEvent(
        restaurantId: RestaurantId('restaurant-1'),
        menu: testMenu,
      );

      expect(event.restaurantId, RestaurantId('restaurant-1'));
      expect(event.menu, testMenu);
      expect(event.isFinal, isTrue);
    });

    test('RestaurantOrderPlacedEvent constructs correctly', () {
      final event = RestaurantOrderPlacedEvent(
        restaurantId: RestaurantId('restaurant-1'),
        orderId: OrderId('order-1'),
        menuItems: testMenu.menuItems,
      );

      expect(event.restaurantId, RestaurantId('restaurant-1'));
      expect(event.orderId, OrderId('order-1'));
      expect(event.menuItems, testMenu.menuItems);
      expect(event.isFinal, isTrue);
    });

    test('OrderPreparedEvent constructs correctly', () {
      final event = OrderPreparedEvent(orderId: OrderId('order-1'));

      expect(event.orderId, OrderId('order-1'));
      expect(event.isFinal, isTrue);
    });
  });

  group('domain errors', () {
    test('RestaurantAlreadyExistsError carries restaurantId', () {
      final error = RestaurantAlreadyExistsError(RestaurantId('restaurant-1'));

      expect(error.restaurantId, RestaurantId('restaurant-1'));
      expect(error.message, contains('restaurant-1'));
    });

    test('RestaurantNotFoundError carries restaurantId', () {
      final error = RestaurantNotFoundError(RestaurantId('restaurant-1'));

      expect(error.restaurantId, RestaurantId('restaurant-1'));
      expect(error.message, contains('restaurant-1'));
    });

    test('OrderAlreadyExistsError carries orderId', () {
      final error = OrderAlreadyExistsError(OrderId('order-1'));

      expect(error.orderId, OrderId('order-1'));
      expect(error.message, contains('order-1'));
    });

    test('OrderNotFoundError carries orderId', () {
      final error = OrderNotFoundError(OrderId('order-1'));

      expect(error.orderId, OrderId('order-1'));
      expect(error.message, contains('order-1'));
    });

    test('OrderAlreadyPreparedError carries orderId', () {
      final error = OrderAlreadyPreparedError(OrderId('order-1'));

      expect(error.orderId, OrderId('order-1'));
      expect(error.message, contains('order-1'));
    });

    test('MenuItemsNotAvailableError carries menuItemIds', () {
      final error = MenuItemsNotAvailableError([
        MenuItemId('item-1'),
        MenuItemId('item-2'),
      ]);

      expect(error.menuItemIds, [
        MenuItemId('item-1'),
        MenuItemId('item-2'),
      ]);
      expect(error.message, contains('item-1'));
      expect(error.message, contains('item-2'));
    });
  });

  group('MenuItem equality', () {
    test('equal when all fields match', () {
      final a = MenuItem(
        menuItemId: MenuItemId('item-1'),
        name: MenuItemName('Pizza'),
        price: MenuItemPrice('10.00'),
      );
      final b = MenuItem(
        menuItemId: MenuItemId('item-1'),
        name: MenuItemName('Pizza'),
        price: MenuItemPrice('10.00'),
      );

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('not equal when fields differ', () {
      final a = MenuItem(
        menuItemId: MenuItemId('item-1'),
        name: MenuItemName('Pizza'),
        price: MenuItemPrice('10.00'),
      );
      final b = MenuItem(
        menuItemId: MenuItemId('item-2'),
        name: MenuItemName('Pasta'),
        price: MenuItemPrice('12.00'),
      );

      expect(a, isNot(equals(b)));
    });
  });

  group('RestaurantMenu equality', () {
    test('equal when all fields match', () {
      final a = testMenu;
      final b = RestaurantMenu(
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

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('not equal when cuisine differs', () {
      final other = RestaurantMenu(
        menuItems: testMenu.menuItems,
        menuId: testMenu.menuId,
        cuisine: RestaurantMenuCuisine.mexican,
      );

      expect(testMenu, isNot(equals(other)));
    });
  });
}

final testMenu = RestaurantMenu(
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
