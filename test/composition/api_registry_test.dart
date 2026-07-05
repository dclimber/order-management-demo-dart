import 'package:order_management_demo/composition/api_registry.dart';
import 'package:order_management_demo/composition/app_context.dart';
import 'package:order_management_demo/composition/app_services.dart';
import 'package:order_management_demo/composition/slice_registry.dart';
import 'package:order_management_demo/platform/event_store/in_memory_event_store.dart';
import 'package:test/test.dart';

void main() {
  test('ApiRegistry.build registers read, write, and auth routes', () {
    final ctx = AppContext(services: AppServices(eventStore: InMemoryEventStore()));
    final registry = ApiRegistry.build(ctx, allSlices);

    expect(
      registry.routes.map((entry) => '${entry.$1} ${entry.$2}').toSet(),
      containsAll([
        'GET /restaurant',
        'GET /order',
        'GET /kitchen',
        'GET /me',
        'POST /restaurant',
        'PUT /restaurant/menu',
        'POST /order',
        'POST /kitchen',
      ]),
    );
  });
}
