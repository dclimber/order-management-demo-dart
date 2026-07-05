import 'package:order_management_demo/api.dart';
import 'package:order_management_demo/composition/app_services.dart';
import 'package:order_management_demo/vertical_slices/create_restaurant/command.dart';
import 'package:order_management_demo/platform/event_store/in_memory_event_store.dart';
import 'package:order_management_demo/vertical_slices/create_restaurant/decider.dart';
import 'package:order_management_demo/vertical_slices/create_restaurant/errors.dart';
import 'package:test/test.dart';

import '../../platform/support/application_fixtures.dart';
import '../../platform/support/decider_test_event_sourced_dsl.dart';

void main() {
  late AppServices services;

  setUp(() {
    services = AppServices(eventStore: InMemoryEventStore());
  });

  final command = CreateRestaurantCommand(
    restaurantId: RestaurantId('restaurant-1'),
    name: RestaurantName('Italian Bistro'),
    menu: applicationTestMenu,
  );

  test('CreateRestaurantRepository - success', () async {
    await createRestaurantDecider
        .givenEventRepository(services.createRestaurantService.repository)
        .whenCommand(command)
        .thenEvents([
          RestaurantCreatedEvent(
            restaurantId: RestaurantId('restaurant-1'),
            name: RestaurantName('Italian Bistro'),
            menu: applicationTestMenu,
          ),
        ]);
  });

  test('CreateRestaurantRepository - duplicate restaurant', () async {
    await createRestaurantDecider
        .givenEventRepository(services.createRestaurantService.repository)
        .whenCommand(command)
        .thenEvents([
          RestaurantCreatedEvent(
            restaurantId: RestaurantId('restaurant-1'),
            name: RestaurantName('Italian Bistro'),
            menu: applicationTestMenu,
          ),
        ]);

    await expectLater(
      () => createRestaurantDecider
          .givenEventRepository(services.createRestaurantService.repository)
          .whenCommand(command)
          .thenEvents([]),
      throwsA(isA<RestaurantAlreadyExistsError>()),
    );
  });
}
