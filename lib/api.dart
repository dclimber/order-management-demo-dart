// Shared contract: value objects and events only (D1).
// Commands, errors, and slice state live in vertical_slices/<slice>/.

// ---------------------------------------------------------------------------
// Extension types — IDs and primitives
// ---------------------------------------------------------------------------

extension type const RestaurantId._(String value) {
  factory RestaurantId(String raw) {
    if (raw.isEmpty) throw ArgumentError('RestaurantId cannot be empty');
    return RestaurantId._(raw);
  }
}

extension type const OrderId._(String value) {
  factory OrderId(String raw) {
    if (raw.isEmpty) throw ArgumentError('OrderId cannot be empty');
    return OrderId._(raw);
  }
}

extension type const MenuItemId._(String value) {
  factory MenuItemId(String raw) {
    if (raw.isEmpty) throw ArgumentError('MenuItemId cannot be empty');
    return MenuItemId._(raw);
  }
}

extension type const RestaurantMenuId._(String value) {
  factory RestaurantMenuId(String raw) {
    if (raw.isEmpty) throw ArgumentError('RestaurantMenuId cannot be empty');
    return RestaurantMenuId._(raw);
  }
}

extension type const RestaurantName._(String value) {
  factory RestaurantName(String raw) => RestaurantName._(raw);
}

extension type const MenuItemName._(String value) {
  factory MenuItemName(String raw) => MenuItemName._(raw);
}

extension type const MenuItemPrice._(String value) {
  factory MenuItemPrice(String raw) => MenuItemPrice._(raw);
}

// ---------------------------------------------------------------------------
// Value objects
// ---------------------------------------------------------------------------

enum RestaurantMenuCuisine {
  general,
  serbian,
  italian,
  mexican,
  chinese,
  indian,
  french,
}

enum OrderStatus {
  created,
  prepared,
}

final class MenuItem {
  const MenuItem({
    required this.menuItemId,
    required this.name,
    required this.price,
  });

  final MenuItemId menuItemId;
  final MenuItemName name;
  final MenuItemPrice price;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MenuItem && menuItemId == other.menuItemId && name == other.name && price == other.price;

  @override
  int get hashCode => Object.hash(menuItemId, name, price);
}

final class RestaurantMenu {
  const RestaurantMenu({
    required this.menuItems,
    required this.menuId,
    required this.cuisine,
  });

  final List<MenuItem> menuItems;
  final RestaurantMenuId menuId;
  final RestaurantMenuCuisine cuisine;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RestaurantMenu &&
          menuId == other.menuId &&
          cuisine == other.cuisine &&
          _listEquals(menuItems, other.menuItems);

  @override
  int get hashCode => Object.hash(menuId, cuisine, Object.hashAll(menuItems));
}

bool _listEquals<T>(List<T> a, List<T> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

// ---------------------------------------------------------------------------
// Events
// ---------------------------------------------------------------------------

sealed class Event {
  const Event();
}

sealed class RestaurantEvent extends Event {
  const RestaurantEvent();
}

final class RestaurantCreatedEvent extends RestaurantEvent {
  const RestaurantCreatedEvent({
    required this.restaurantId,
    required this.name,
    required this.menu,
    this.isFinal = true,
  });

  final RestaurantId restaurantId;
  final RestaurantName name;
  final RestaurantMenu menu;
  final bool isFinal;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RestaurantCreatedEvent &&
          restaurantId == other.restaurantId &&
          name == other.name &&
          menu == other.menu &&
          isFinal == other.isFinal;

  @override
  int get hashCode => Object.hash(restaurantId, name, menu, isFinal);
}

final class RestaurantMenuChangedEvent extends RestaurantEvent {
  const RestaurantMenuChangedEvent({
    required this.restaurantId,
    required this.menu,
    this.isFinal = true,
  });

  final RestaurantId restaurantId;
  final RestaurantMenu menu;
  final bool isFinal;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RestaurantMenuChangedEvent &&
          restaurantId == other.restaurantId &&
          menu == other.menu &&
          isFinal == other.isFinal;

  @override
  int get hashCode => Object.hash(restaurantId, menu, isFinal);
}

sealed class OrderEvent extends Event {
  const OrderEvent();
}

final class RestaurantOrderPlacedEvent extends OrderEvent {
  const RestaurantOrderPlacedEvent({
    required this.restaurantId,
    required this.orderId,
    required this.menuItems,
    this.isFinal = true,
  });

  final RestaurantId restaurantId;
  final OrderId orderId;
  final List<MenuItem> menuItems;
  final bool isFinal;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RestaurantOrderPlacedEvent &&
          restaurantId == other.restaurantId &&
          orderId == other.orderId &&
          isFinal == other.isFinal &&
          _listEquals(menuItems, other.menuItems);

  @override
  int get hashCode => Object.hash(restaurantId, orderId, isFinal, Object.hashAll(menuItems));
}

final class OrderPreparedEvent extends OrderEvent {
  const OrderPreparedEvent({
    required this.orderId,
    this.isFinal = true,
  });

  final OrderId orderId;
  final bool isFinal;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is OrderPreparedEvent && orderId == other.orderId && isFinal == other.isFinal;

  @override
  int get hashCode => Object.hash(orderId, isFinal);
}
