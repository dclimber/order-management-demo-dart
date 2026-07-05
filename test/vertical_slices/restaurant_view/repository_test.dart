import 'package:order_management_demo/api.dart';
import 'package:order_management_demo/vertical_slices/change_restaurant_menu/command.dart';
import 'package:order_management_demo/vertical_slices/create_restaurant/command.dart';
import 'package:order_management_demo/composition/app_services.dart';
import 'package:order_management_demo/platform/event_store/in_memory_event_store.dart';
import 'package:order_management_demo/vertical_slices/restaurant_view/state.dart';
import 'package:order_management_demo/vertical_slices/restaurant_view/view.dart';
import 'package:test/test.dart';

import '../../platform/support/application_fixtures.dart';
import '../../platform/support/ephemeral_view_test_dsl.dart';

void main() {
  late AppServices services;

  setUp(() {
    services = AppServices(eventStore: InMemoryEventStore());
  });

  test('RestaurantEphemeralView - project created restaurant', () async {
    await services.createRestaurantService.aggregate
        .handle(
          CreateRestaurantCommand(
            restaurantId: RestaurantId('restaurant-1'),
            name: RestaurantName('Italian Bistro'),
            menu: applicationTestMenu,
          ),
        )
        .toList();

    await restaurantView
        .givenEphemeralRepository(services.restaurantViewService.repository)
        .whenQuery(RestaurantId('restaurant-1'))
        .thenState(
          RestaurantViewState(
            restaurantId: RestaurantId('restaurant-1'),
            name: RestaurantName('Italian Bistro'),
            menu: applicationTestMenu,
          ),
        );
  });

  test('RestaurantEphemeralView - project state after menu change', () async {
    await services.createRestaurantService.aggregate
        .handle(
          CreateRestaurantCommand(
            restaurantId: RestaurantId('restaurant-1'),
            name: RestaurantName('Italian Bistro'),
            menu: applicationTestMenu,
          ),
        )
        .toList();

    await services.changeRestaurantMenuService.aggregate
        .handle(
          ChangeRestaurantMenuCommand(
            restaurantId: RestaurantId('restaurant-1'),
            menu: applicationMexicanMenu,
          ),
        )
        .toList();

    await restaurantView
        .givenEphemeralRepository(services.restaurantViewService.repository)
        .whenQuery(RestaurantId('restaurant-1'))
        .thenState(
          RestaurantViewState(
            restaurantId: RestaurantId('restaurant-1'),
            name: RestaurantName('Italian Bistro'),
            menu: applicationMexicanMenu,
          ),
        );
  });

  test('RestaurantEphemeralView - unknown restaurant returns null', () async {
    await restaurantView
        .givenEphemeralRepository(services.restaurantViewService.repository)
        .whenQuery(RestaurantId('missing'))
        .thenState(null);
  });
}
