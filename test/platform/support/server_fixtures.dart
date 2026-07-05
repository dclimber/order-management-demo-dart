import 'package:order_management_demo/composition/app_services.dart';
import 'package:order_management_demo/api.dart';
import 'package:order_management_demo/vertical_slices/create_restaurant/command.dart';
import 'package:order_management_demo/vertical_slices/place_order/command.dart';
import 'package:order_management_demo/platform/event_store/in_memory_event_store.dart';

AppServices createTestAppServices() => AppServices(eventStore: InMemoryEventStore());

Map<String, dynamic> createRestaurantRequestJson({
  String restaurantId = 'restaurant-1',
  String name = 'Italian Bistro',
}) => {
  'restaurantId': restaurantId,
  'name': name,
  'menu': menuRequestJson(),
};

Map<String, dynamic> menuRequestJson() => {
  'menuId': 'menu-1',
  'cuisine': 'ITALIAN',
  'menuItems': [
    {
      'menuItemId': 'item-1',
      'name': 'Pizza',
      'price': '10.00',
    },
    {
      'menuItemId': 'item-2',
      'name': 'Pasta',
      'price': '12.00',
    },
  ],
};

Map<String, dynamic> mexicanMenuRequestJson() => {
  'menuId': 'menu-2',
  'cuisine': 'MEXICAN',
  'menuItems': [
    {
      'menuItemId': 'item-3',
      'name': 'Tacos',
      'price': '8.00',
    },
  ],
};

Future<void> seedRestaurant(AppServices services) async {
  await services.createRestaurantService.aggregate
      .handle(
        CreateRestaurantCommand(
          restaurantId: RestaurantId('restaurant-1'),
          name: RestaurantName('Italian Bistro'),
          menu: RestaurantMenu(
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
          ),
        ),
      )
      .toList();
}

Future<void> seedPlacedOrder(AppServices services) async {
  await seedRestaurant(services);
  await services.placeOrderService.aggregate
      .handle(
        PlaceOrderCommand(
          restaurantId: RestaurantId('restaurant-1'),
          orderId: OrderId('order-1'),
          menuItems: [
            MenuItem(
              menuItemId: MenuItemId('item-1'),
              name: MenuItemName('Pizza'),
              price: MenuItemPrice('10.00'),
            ),
          ],
        ),
      )
      .toList();
}
