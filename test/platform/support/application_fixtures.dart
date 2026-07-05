import 'package:order_management_demo/api.dart';

final applicationTestMenu = RestaurantMenu(
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

final applicationMexicanMenu = RestaurantMenu(
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

final applicationPizzaOrderItems = [
  MenuItem(
    menuItemId: MenuItemId('item-1'),
    name: MenuItemName('Pizza'),
    price: MenuItemPrice('10.00'),
  ),
];
