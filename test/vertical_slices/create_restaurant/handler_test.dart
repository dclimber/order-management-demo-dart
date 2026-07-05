import 'package:order_management_demo/api.dart';
import 'package:order_management_demo/composition/app_services.dart';
import 'package:order_management_demo/vertical_slices/create_restaurant/command.dart';
import 'package:order_management_demo/platform/server/json_parse.dart';
import 'package:order_management_demo/platform/server/handler_result.dart';
import 'package:order_management_demo/vertical_slices/create_restaurant/dto.dart';
import 'package:order_management_demo/vertical_slices/create_restaurant/handler.dart';
import 'package:test/test.dart';

import '../../platform/support/server_fixtures.dart';

void main() {
  late AppServices services;

  setUp(() {
    services = createTestAppServices();
  });

  test('handleCreateRestaurant - success returns 201', () async {
    final parsed = parseCreateRestaurantCommand(createRestaurantRequestJson());
    expect(parsed, isA<ParseSuccess<CreateRestaurantCommand>>());

    final result = await handleCreateRestaurant(
      command: (parsed as ParseSuccess<CreateRestaurantCommand>).value,
      service: services.createRestaurantService,
    );

    expect(result, isA<HandlerSuccess<List<RestaurantEvent>>>());
    final success = result as HandlerSuccess<List<RestaurantEvent>>;
    expect(success.statusCode, 201);
    expect(success.value, hasLength(1));
    expect(success.value.single, isA<RestaurantCreatedEvent>());
  });

  test('handleCreateRestaurant - duplicate returns 409', () async {
    await seedRestaurant(services);

    final parsed = parseCreateRestaurantCommand(createRestaurantRequestJson());
    final result = await handleCreateRestaurant(
      command: (parsed as ParseSuccess<CreateRestaurantCommand>).value,
      service: services.createRestaurantService,
    );

    expect(result, isA<HandlerError>());
    expect((result as HandlerError).statusCode, 409);
  });

  test('parseCreateRestaurantCommand - rejects missing restaurantId', () {
    final result = parseCreateRestaurantCommand({
      'name': 'Bistro',
      'menu': menuRequestJson(),
    });

    expect(result, isA<ParseError>());
  });
}
