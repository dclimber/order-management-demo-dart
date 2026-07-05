import '../../api.dart';

final class PlaceOrderCommand {
  const PlaceOrderCommand({
    required this.restaurantId,
    required this.orderId,
    required this.menuItems,
  });

  final RestaurantId restaurantId;
  final OrderId orderId;
  final List<MenuItem> menuItems;
}