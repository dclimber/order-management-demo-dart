import 'package:order_management_demo/api.dart';
import 'package:order_management_demo/composition/app_services.dart';
import 'package:order_management_demo/vertical_slices/change_restaurant_menu/command.dart';
import 'package:order_management_demo/platform/server/json_parse.dart';
import 'package:order_management_demo/platform/server/handler_result.dart';
import 'package:order_management_demo/vertical_slices/change_restaurant_menu/dto.dart';
import 'package:order_management_demo/vertical_slices/change_restaurant_menu/handler.dart';
import 'package:test/test.dart';

import '../../platform/support/server_fixtures.dart';

void main() {
  late AppServices services;

  setUp(() {
    services = createTestAppServices();
  });

  test('handleChangeRestaurantMenu - success', () async {
    await seedRestaurant(services);

    final parsed = parseChangeRestaurantMenuCommand({
      'restaurantId': 'restaurant-1',
      'menu': mexicanMenuRequestJson(),
    });

    final result = await handleChangeRestaurantMenu(
      command: (parsed as ParseSuccess<ChangeRestaurantMenuCommand>).value,
      service: services.changeRestaurantMenuService,
    );

    expect(result, isA<HandlerSuccess<List<RestaurantEvent>>>());
    expect(
      (result as HandlerSuccess<List<RestaurantEvent>>).value.single,
      isA<RestaurantMenuChangedEvent>(),
    );
  });

  test('handleChangeRestaurantMenu - not found returns 404', () async {
    final parsed = parseChangeRestaurantMenuCommand({
      'restaurantId': 'restaurant-1',
      'menu': mexicanMenuRequestJson(),
    });

    final result = await handleChangeRestaurantMenu(
      command: (parsed as ParseSuccess<ChangeRestaurantMenuCommand>).value,
      service: services.changeRestaurantMenuService,
    );

    expect(result, isA<HandlerError>());
    expect((result as HandlerError).statusCode, 404);
  });
}
