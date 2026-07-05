import 'package:order_management_demo/api.dart';
import 'package:order_management_demo/composition/app_services.dart';
import 'package:order_management_demo/platform/server/handler_result.dart';
import 'package:order_management_demo/vertical_slices/restaurant_view/handler.dart';
import 'package:order_management_demo/vertical_slices/restaurant_view/state.dart';
import 'package:test/test.dart';

import '../../platform/support/server_fixtures.dart';

void main() {
  late AppServices services;

  setUp(() {
    services = createTestAppServices();
  });

  test('handleGetRestaurant - returns view state', () async {
    await seedRestaurant(services);

    final result = await handleGetRestaurant(
      restaurantId: RestaurantId('restaurant-1'),
      service: services.restaurantViewService,
    );

    expect(result, isA<HandlerSuccess<RestaurantViewState>>());
    final state = (result as HandlerSuccess<RestaurantViewState>).value;
    expect(state.restaurantId, RestaurantId('restaurant-1'));
    expect(state.name, RestaurantName('Italian Bistro'));
  });

  test('handleGetRestaurant - not found returns 404', () async {
    final result = await handleGetRestaurant(
      restaurantId: RestaurantId('missing'),
      service: services.restaurantViewService,
    );

    expect(result, isA<HandlerError>());
    expect((result as HandlerError).statusCode, 404);
  });

  test('handleListRestaurants returns all restaurant views', () async {
    await seedRestaurant(services);

    final result = await handleListRestaurants(service: services.restaurantViewService);

    expect(result, isA<HandlerSuccess<List<RestaurantViewState>>>());
    expect((result as HandlerSuccess<List<RestaurantViewState>>).value, hasLength(1));
  });
}
