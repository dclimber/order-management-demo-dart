import '../../api.dart';

sealed class DomainError implements Exception {
  const DomainError(this.message);
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

final class RestaurantNotFoundError extends DomainError {
  RestaurantNotFoundError(this.restaurantId) : super('Restaurant $restaurantId does not exist');

  final RestaurantId restaurantId;
}

final class OrderAlreadyExistsError extends DomainError {
  OrderAlreadyExistsError(this.orderId) : super('Order $orderId already exists');

  final OrderId orderId;
}

final class MenuItemsNotAvailableError extends DomainError {
  MenuItemsNotAvailableError(this.menuItemIds) : super('Menu items not available: ${menuItemIds.join(', ')}');

  final List<MenuItemId> menuItemIds;
}