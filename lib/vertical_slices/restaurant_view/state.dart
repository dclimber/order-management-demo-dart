import '../../api.dart';

final class RestaurantViewState {
  const RestaurantViewState({
    required this.restaurantId,
    required this.name,
    required this.menu,
  });

  final RestaurantId restaurantId;
  final RestaurantName name;
  final RestaurantMenu menu;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RestaurantViewState && restaurantId == other.restaurantId && name == other.name && menu == other.menu;

  @override
  int get hashCode => Object.hash(restaurantId, name, menu);
}
