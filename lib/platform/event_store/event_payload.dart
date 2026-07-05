import '../../api.dart';

Map<String, dynamic> encodeMenu(RestaurantMenu menu) => {
  'menuId': menu.menuId.value,
  'cuisine': menu.cuisine.name,
  'menuItems': menu.menuItems.map(encodeMenuItem).toList(),
};

RestaurantMenu decodeMenu(Map<String, dynamic> json) => RestaurantMenu(
  menuId: RestaurantMenuId(json['menuId'] as String),
  cuisine: RestaurantMenuCuisine.values.byName(json['cuisine'] as String),
  menuItems: (json['menuItems'] as List<dynamic>).map((item) => decodeMenuItem(item as Map<String, dynamic>)).toList(),
);

Map<String, dynamic> encodeMenuItem(MenuItem item) => {
  'menuItemId': item.menuItemId.value,
  'name': item.name.value,
  'price': item.price.value,
};

MenuItem decodeMenuItem(Map<String, dynamic> json) => MenuItem(
  menuItemId: MenuItemId(json['menuItemId'] as String),
  name: MenuItemName(json['name'] as String),
  price: MenuItemPrice(json['price'] as String),
);
