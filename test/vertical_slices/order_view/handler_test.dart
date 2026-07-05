import 'package:order_management_demo/api.dart';
import 'package:order_management_demo/composition/app_services.dart';
import 'package:order_management_demo/composition/json_dto.dart';
import 'package:order_management_demo/platform/server/handler_result.dart';
import 'package:order_management_demo/vertical_slices/mark_order_as_prepared/command.dart';
import 'package:order_management_demo/vertical_slices/place_order/command.dart';
import 'package:order_management_demo/vertical_slices/order_view/dto.dart';
import 'package:order_management_demo/vertical_slices/order_view/handler.dart';
import 'package:order_management_demo/vertical_slices/order_view/state.dart';
import 'package:test/test.dart';

import '../../platform/support/server_fixtures.dart';

void main() {
  late AppServices services;

  setUp(() {
    services = createTestAppServices();
  });

  test('handleGetOrder - returns view state', () async {
    await seedPlacedOrder(services);

    final result = await handleGetOrder(
      orderId: OrderId('order-1'),
      service: services.orderViewService,
    );

    expect(result, isA<HandlerSuccess<OrderViewState>>());
    final state = (result as HandlerSuccess<OrderViewState>).value;
    expect(state.orderId, OrderId('order-1'));
    expect(state.status, OrderStatus.created);
  });

  test('handleGetOrder - not found returns 404', () async {
    final result = await handleGetOrder(
      orderId: OrderId('missing'),
      service: services.orderViewService,
    );

    expect(result, isA<HandlerError>());
    expect((result as HandlerError).statusCode, 404);
  });

  test('handleListKitchenOrders filters by status', () async {
    await seedPlacedOrder(services);
    await services.placeOrderService.aggregate
        .handle(
          PlaceOrderCommand(
            restaurantId: RestaurantId('restaurant-1'),
            orderId: OrderId('order-2'),
            menuItems: [
              MenuItem(
                menuItemId: MenuItemId('item-1'),
                name: MenuItemName('Pizza'),
                price: MenuItemPrice('10.00'),
              ),
            ],
          ),
        )
        .toList();
    await services.markOrderAsPreparedService.aggregate
        .handle(MarkOrderAsPreparedCommand(orderId: OrderId('order-2')))
        .toList();

    final created = await handleListKitchenOrders(
      status: OrderStatus.created,
      service: services.orderViewService,
    );
    final prepared = await handleListKitchenOrders(
      status: OrderStatus.prepared,
      service: services.orderViewService,
    );

    expect((created as HandlerSuccess).value, hasLength(1));
    expect((prepared as HandlerSuccess).value, hasLength(1));
  });

  test('parseKitchenStatusQuery accepts CREATED and PREPARED', () {
    expect(parseKitchenStatusQuery({'status': 'CREATED'}), isA<ParseSuccess<OrderStatus>>());
    expect(parseKitchenStatusQuery({'status': 'PREPARED'}), isA<ParseSuccess<OrderStatus>>());
    expect(parseKitchenStatusQuery({}), isA<ParseError>());
  });
}
