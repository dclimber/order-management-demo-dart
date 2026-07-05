import '../../api.dart';

final class CreateRestaurantState {
  const CreateRestaurantState({this.restaurantId});

  final RestaurantId? restaurantId;

  bool get exists => restaurantId != null;
}