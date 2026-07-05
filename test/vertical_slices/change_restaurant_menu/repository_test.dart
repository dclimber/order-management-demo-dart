import 'package:order_management_demo/api.dart';
import 'package:order_management_demo/composition/app_services.dart';
import 'package:order_management_demo/vertical_slices/change_restaurant_menu/command.dart';
import 'package:order_management_demo/vertical_slices/create_restaurant/command.dart';
import 'package:order_management_demo/platform/event_store/in_memory_event_store.dart';
import 'package:order_management_demo/vertical_slices/change_restaurant_menu/decider.dart';
import 'package:order_management_demo/vertical_slices/change_restaurant_menu/errors.dart';
import 'package:order_management_demo/vertical_slices/create_restaurant/decider.dart';
import 'package:test/test.dart';

import '../../platform/support/application_fixtures.dart';
import '../../platform/support/decider_test_event_sourced_dsl.dart';

void main() {
  late AppServices services;

  setUp(() {
    services = AppServices(eventStore: InMemoryEventStore());
  });

  final createCommand = CreateRestaurantCommand(
    restaurantId: RestaurantId('restaurant-1'),
    name: RestaurantName('Italian Bistro'),
    menu: applicationTestMenu,
  );

  final changeCommand = ChangeRestaurantMenuCommand(
    restaurantId: RestaurantId('restaurant-1'),
    menu: applicationMexicanMenu,
  );

  test('ChangeRestaurantMenuRepository - success', () async {
    await createRestaurantDecider
        .givenEventRepository(services.createRestaurantService.repository)
        .whenCommand(createCommand)
        .thenEvents([
          RestaurantCreatedEvent(
            restaurantId: RestaurantId('restaurant-1'),
            name: RestaurantName('Italian Bistro'),
            menu: applicationTestMenu,
          ),
        ]);

    await changeRestaurantMenuDecider
        .givenEventRepository(services.changeRestaurantMenuService.repository)
        .whenCommand(changeCommand)
        .thenEvents([
          RestaurantMenuChangedEvent(
            restaurantId: RestaurantId('restaurant-1'),
            menu: applicationMexicanMenu,
          ),
        ]);
  });

  test('ChangeRestaurantMenuRepository - restaurant not found', () async {
    await expectLater(
      () => changeRestaurantMenuDecider
          .givenEventRepository(services.changeRestaurantMenuService.repository)
          .whenCommand(changeCommand)
          .thenEvents([]),
      throwsA(isA<RestaurantNotFoundError>()),
    );
  });
}
