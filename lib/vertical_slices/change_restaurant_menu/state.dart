import '../../api.dart';

final class ChangeRestaurantMenuState {
  const ChangeRestaurantMenuState({this.restaurantId});

  final RestaurantId? restaurantId;

  bool get exists => restaurantId != null;
}