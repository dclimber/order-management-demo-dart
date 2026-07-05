import '../../api.dart';

final class OrderViewState {
  const OrderViewState({
    required this.orderId,
    required this.restaurantId,
    required this.menuItems,
    required this.status,
  });

  final OrderId orderId;
  final RestaurantId restaurantId;
  final List<MenuItem> menuItems;
  final OrderStatus status;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrderViewState &&
          orderId == other.orderId &&
          restaurantId == other.restaurantId &&
          status == other.status &&
          _listEquals(menuItems, other.menuItems);

  @override
  int get hashCode => Object.hash(orderId, restaurantId, status, Object.hashAll(menuItems));
}

bool _listEquals<T>(List<T> a, List<T> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
