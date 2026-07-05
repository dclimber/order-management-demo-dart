import '../../api.dart';
import '../id.dart';

sealed class ParseResult<T> {
  const ParseResult();
}

final class ParseSuccess<T> extends ParseResult<T> {
  const ParseSuccess(this.value);
  final T value;
}

final class ParseError extends ParseResult<Never> {
  const ParseError(this.message);
  final String message;
}

ParseResult<RestaurantMenu> parseMenu(Object? value) {
  if (value is! Map<String, dynamic>) {
    return const ParseError('menu is required');
  }

  final menuIdResult = requiredString(value, 'menuId');
  if (menuIdResult is ParseError) return ParseError(menuIdResult.message);

  final cuisineResult = parseCuisine(value['cuisine']);
  if (cuisineResult is ParseError) return ParseError(cuisineResult.message);

  final menuItemsResult = parseMenuItems(value['menuItems']);
  if (menuItemsResult is ParseError) return ParseError(menuItemsResult.message);

  return ParseSuccess(
    RestaurantMenu(
      menuId: RestaurantMenuId((menuIdResult as ParseSuccess<String>).value),
      cuisine: (cuisineResult as ParseSuccess<RestaurantMenuCuisine>).value,
      menuItems: (menuItemsResult as ParseSuccess<List<MenuItem>>).value,
    ),
  );
}

ParseResult<List<MenuItem>> parseMenuItems(Object? value) {
  if (value is! List || value.isEmpty) {
    return const ParseError('menuItems must be a non-empty array');
  }

  final items = <MenuItem>[];
  for (final entry in value) {
    if (entry is! Map<String, dynamic>) {
      return const ParseError('menuItems must contain objects');
    }

    final nameResult = requiredString(entry, 'name');
    if (nameResult is ParseError) return ParseError(nameResult.message);

    final priceResult = requiredString(entry, 'price');
    if (priceResult is ParseError) return ParseError(priceResult.message);

    final menuItemIdValue = entry['menuItemId'];
    final id = menuItemIdValue is String && menuItemIdValue.isNotEmpty ? menuItemIdValue : generateId();

    items.add(
      MenuItem(
        menuItemId: MenuItemId(id),
        name: MenuItemName((nameResult as ParseSuccess<String>).value),
        price: MenuItemPrice((priceResult as ParseSuccess<String>).value),
      ),
    );
  }

  return ParseSuccess(items);
}

ParseResult<RestaurantMenuCuisine> parseCuisine(Object? value) {
  if (value is! String || value.isEmpty) {
    return const ParseError('cuisine is required');
  }

  return switch (value.toUpperCase()) {
    'GENERAL' => const ParseSuccess(RestaurantMenuCuisine.general),
    'SERBIAN' => const ParseSuccess(RestaurantMenuCuisine.serbian),
    'ITALIAN' => const ParseSuccess(RestaurantMenuCuisine.italian),
    'MEXICAN' => const ParseSuccess(RestaurantMenuCuisine.mexican),
    'CHINESE' => const ParseSuccess(RestaurantMenuCuisine.chinese),
    'INDIAN' => const ParseSuccess(RestaurantMenuCuisine.indian),
    'FRENCH' => const ParseSuccess(RestaurantMenuCuisine.french),
    _ => ParseError('Unknown cuisine: $value'),
  };
}

ParseResult<String> requiredString(Map<String, dynamic> json, String field) {
  final value = json[field];
  if (value is! String || value.isEmpty) {
    return ParseError('$field is required');
  }
  return ParseSuccess(value);
}
