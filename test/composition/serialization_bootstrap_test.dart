import 'package:order_management_demo/api.dart';
import 'package:order_management_demo/composition/serialization_bootstrap.dart';
import 'package:order_management_demo/platform/event_store/serialization.dart';
import 'package:test/test.dart';

void main() {
  setUpAll(() {
    configureEventSerialization(bootstrapSerializationRegistry());
  });

  test('bootstrap registers all four event types', () {
    final created = RestaurantCreatedEvent(
      restaurantId: RestaurantId('r1'),
      name: RestaurantName('Test'),
      menu: RestaurantMenu(
        menuId: RestaurantMenuId('m1'),
        cuisine: RestaurantMenuCuisine.general,
        menuItems: const [],
      ),
    );

    expect(decodeEvent(encodeEvent(created)), created);
  });
}
