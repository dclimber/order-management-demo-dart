import 'package:order_management_demo/api.dart';
import 'package:order_management_demo/composition/app_services.dart';
import 'package:order_management_demo/vertical_slices/mark_order_as_prepared/command.dart';
import 'package:order_management_demo/platform/server/json_parse.dart';
import 'package:order_management_demo/platform/server/handler_result.dart';
import 'package:order_management_demo/vertical_slices/mark_order_as_prepared/dto.dart';
import 'package:order_management_demo/vertical_slices/mark_order_as_prepared/handler.dart';
import 'package:test/test.dart';

import '../../platform/support/server_fixtures.dart';

void main() {
  late AppServices services;

  setUp(() {
    services = createTestAppServices();
  });

  test('handleMarkOrderAsPrepared - success', () async {
    await seedPlacedOrder(services);

    final parsed = parseMarkOrderAsPreparedCommand({'orderId': 'order-1'});
    final result = await handleMarkOrderAsPrepared(
      command: (parsed as ParseSuccess<MarkOrderAsPreparedCommand>).value,
      service: services.markOrderAsPreparedService,
    );

    expect(result, isA<HandlerSuccess<List<OrderEvent>>>());
    expect(
      (result as HandlerSuccess<List<OrderEvent>>).value.single,
      isA<OrderPreparedEvent>(),
    );
  });

  test('handleMarkOrderAsPrepared - not found returns 404', () async {
    final parsed = parseMarkOrderAsPreparedCommand({'orderId': 'order-1'});
    final result = await handleMarkOrderAsPrepared(
      command: (parsed as ParseSuccess<MarkOrderAsPreparedCommand>).value,
      service: services.markOrderAsPreparedService,
    );

    expect(result, isA<HandlerError>());
    expect((result as HandlerError).statusCode, 404);
  });

  test('handleMarkOrderAsPrepared - already prepared returns 409', () async {
    await seedPlacedOrder(services);
    await services.markOrderAsPreparedService.aggregate
        .handle(MarkOrderAsPreparedCommand(orderId: OrderId('order-1')))
        .toList();

    final parsed = parseMarkOrderAsPreparedCommand({'orderId': 'order-1'});
    final result = await handleMarkOrderAsPrepared(
      command: (parsed as ParseSuccess<MarkOrderAsPreparedCommand>).value,
      service: services.markOrderAsPreparedService,
    );

    expect(result, isA<HandlerError>());
    expect((result as HandlerError).statusCode, 409);
  });
}
