import 'package:jaspr/dom.dart';
import 'package:jaspr/server.dart';
import 'package:jaspr_router/jaspr_router.dart';

import '../../api.dart';
import '../../composition/app_context.dart';
import '../../vertical_slices/change_restaurant_menu/ui/ui.dart';
import '../../vertical_slices/create_restaurant/ui/ui.dart';
import '../../vertical_slices/restaurant_view/ui/ui.dart';

class RestaurantPage extends AsyncStatelessComponent {
  const RestaurantPage({super.key});

  @override
  Future<Component> build(BuildContext context) async {
    final query = RouteState.of(context).queryParams;
    final restaurantIdParam = query['restaurantId']?.trim();
    final restaurants = await appServices.queryAllRestaurants();
    final lookupResult = restaurantIdParam != null && restaurantIdParam.isNotEmpty
        ? await _buildRestaurantResult(restaurantIdParam)
        : null;

    return div(classes: 'page-container', [
      h1(classes: 'page-title', [.text('Restaurant Management')]),
      const CreateRestaurantForm(),
      hr(classes: 'section-divider'),
      ChangeMenuForm(initialRestaurants: restaurantSummaries(restaurants)),
      hr(classes: 'section-divider'),
      section(classes: 'page-section', [
        h2(classes: 'section-title', [.text('View Restaurant')]),
        restaurantLookupForm(restaurantId: restaurantIdParam),
        if (lookupResult != null) lookupResult,
      ]),
      restaurantIndexList(restaurants),
    ]);
  }

  Future<Component> _buildRestaurantResult(String restaurantIdParam) async {
    try {
      final state = await appServices.queryRestaurant(RestaurantId(restaurantIdParam));
      if (state == null) {
        return p(classes: 'error-message', [
          .text('Restaurant $restaurantIdParam does not exist'),
        ]);
      }
      return restaurantViewCard(state);
    } on ArgumentError catch (error) {
      return p(classes: 'error-message', [.text(error.message ?? 'Invalid restaurant ID')]);
    }
  }
}
