import '../../api.dart';

final class CreateRestaurantCommand {
  const CreateRestaurantCommand({
    required this.restaurantId,
    required this.name,
    required this.menu,
  });

  final RestaurantId restaurantId;
  final RestaurantName name;
  final RestaurantMenu menu;
}