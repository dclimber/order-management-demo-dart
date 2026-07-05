import 'package:order_management_demo/api.dart';
import 'package:order_management_demo/vertical_slices/create_restaurant/command.dart';
import 'package:order_management_demo/composition/app_services.dart';
import 'package:order_management_demo/platform/event_store/in_memory_event_store.dart';
import 'package:test/test.dart';

import '../../platform/support/application_fixtures.dart';

void main() {
  late AppServices services;

  setUp(() {
    services = AppServices(eventStore: InMemoryEventStore());
  });

  test('discoverIds returns ids from created restaurants', () async {
    await services.createRestaurantService.aggregate
        .handle(
          CreateRestaurantCommand(
            restaurantId: RestaurantId('restaurant-1'),
            name: RestaurantName('Bistro'),
            menu: applicationTestMenu,
          ),
        )
        .toList();
    await services.createRestaurantService.aggregate
        .handle(
          CreateRestaurantCommand(
            restaurantId: RestaurantId('restaurant-2'),
            name: RestaurantName('Cafe'),
            menu: applicationMexicanMenu,
          ),
        )
        .toList();

    final ids = await services.restaurantViewService.discoverIds();

    expect(ids.map((id) => id.value), ['restaurant-1', 'restaurant-2']);
  });

  test('queryAll projects current restaurant views', () async {
    await services.createRestaurantService.aggregate
        .handle(
          CreateRestaurantCommand(
            restaurantId: RestaurantId('restaurant-1'),
            name: RestaurantName('Bistro'),
            menu: applicationTestMenu,
          ),
        )
        .toList();

    final restaurants = await services.restaurantViewService.queryAll();

    expect(restaurants, hasLength(1));
    expect(restaurants.first.name.value, 'Bistro');
  });
}
