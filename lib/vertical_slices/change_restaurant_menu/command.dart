import '../../api.dart';

final class ChangeRestaurantMenuCommand {
  const ChangeRestaurantMenuCommand({
    required this.restaurantId,
    required this.menu,
  });

  final RestaurantId restaurantId;
  final RestaurantMenu menu;
}