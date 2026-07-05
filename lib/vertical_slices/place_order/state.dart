import '../../api.dart';

final class PlaceOrderState {
  const PlaceOrderState({
    this.restaurantId,
    this.menu,
    this.orderPlaced = false,
  });

  final RestaurantId? restaurantId;
  final RestaurantMenu? menu;
  final bool orderPlaced;

  PlaceOrderState copyWith({
    RestaurantId? restaurantId,
    RestaurantMenu? menu,
    bool? orderPlaced,
  }) => PlaceOrderState(
    restaurantId: restaurantId ?? this.restaurantId,
    menu: menu ?? this.menu,
    orderPlaced: orderPlaced ?? this.orderPlaced,
  );
}