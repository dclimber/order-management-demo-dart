import 'package:order_management_demo/api.dart';
import 'package:order_management_demo/composition/app_services.dart';
import 'package:order_management_demo/vertical_slices/place_order/command.dart';
import 'package:order_management_demo/platform/server/json_parse.dart';
import 'package:order_management_demo/platform/server/handler_result.dart';
import 'package:order_management_demo/vertical_slices/place_order/dto.dart';
import 'package:order_management_demo/vertical_slices/place_order/handler.dart';
import 'package:test/test.dart';

import '../../platform/support/server_fixtures.dart';

void main() {
  late AppServices services;

  setUp(() {
    services = createTestAppServices();
  });

  test('handlePlaceOrder - success returns 201', () async {
    await seedRestaurant(services);

    final parsed = parsePlaceOrderCommand({
      'restaurantId': 'restaurant-1',
      'orderId': 'order-1',
      'menuItems': [
        {
          'menuItemId': 'item-1',
          'name': 'Pizza',
          'price': '10.00',
        },
      ],
    });

    final result = await handlePlaceOrder(
      command: (parsed as ParseSuccess<PlaceOrderCommand>).value,
      service: services.placeOrderService,
    );

    expect(result, isA<HandlerSuccess<List<Event>>>());
    final success = result as HandlerSuccess<List<Event>>;
    expect(success.statusCode, 201);
    expect(success.value.single, isA<RestaurantOrderPlacedEvent>());
  });

  test('handlePlaceOrder - restaurant not found returns 404', () async {
    final parsed = parsePlaceOrderCommand({
      'restaurantId': 'restaurant-1',
      'orderId': 'order-1',
      'menuItems': [
        {
          'menuItemId': 'item-1',
          'name': 'Pizza',
          'price': '10.00',
        },
      ],
    });

    final result = await handlePlaceOrder(
      command: (parsed as ParseSuccess<PlaceOrderCommand>).value,
      service: services.placeOrderService,
    );

    expect(result, isA<HandlerError>());
    expect((result as HandlerError).statusCode, 404);
  });

  test('handlePlaceOrder - duplicate order returns 409', () async {
    await seedPlacedOrder(services);

    final parsed = parsePlaceOrderCommand({
      'restaurantId': 'restaurant-1',
      'orderId': 'order-1',
      'menuItems': [
        {
          'menuItemId': 'item-1',
          'name': 'Pizza',
          'price': '10.00',
        },
      ],
    });

    final result = await handlePlaceOrder(
      command: (parsed as ParseSuccess<PlaceOrderCommand>).value,
      service: services.placeOrderService,
    );

    expect(result, isA<HandlerError>());
    expect((result as HandlerError).statusCode, 409);
  });

  test('handlePlaceOrder - unavailable items returns 422', () async {
    await seedRestaurant(services);

    final parsed = parsePlaceOrderCommand({
      'restaurantId': 'restaurant-1',
      'orderId': 'order-1',
      'menuItems': [
        {
          'menuItemId': 'item-999',
          'name': 'InvalidItem',
          'price': '99.00',
        },
      ],
    });

    final result = await handlePlaceOrder(
      command: (parsed as ParseSuccess<PlaceOrderCommand>).value,
      service: services.placeOrderService,
    );

    expect(result, isA<HandlerError>());
    expect((result as HandlerError).statusCode, 422);
  });
}
