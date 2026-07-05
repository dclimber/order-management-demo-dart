import '../../api.dart';
import '../../platform/event_store/event_payload.dart';
import 'state.dart';

Map<String, dynamic> encodeRestaurantView(RestaurantViewState state) => {
  'restaurantId': state.restaurantId.value,
  'name': state.name.value,
  'menu': {
    'menuId': state.menu.menuId.value,
    'cuisine': state.menu.cuisine.name.toUpperCase(),
    'menuItems': state.menu.menuItems.map(encodeMenuItem).toList(),
  },
};

String cuisineLabel(RestaurantMenuCuisine cuisine) => cuisine.name.toUpperCase();

List<Map<String, String>> restaurantSummaries(List<RestaurantViewState> restaurants) => [
  for (final restaurant in restaurants)
    {
      'restaurantId': restaurant.restaurantId.value,
      'name': restaurant.name.value,
    },
];
