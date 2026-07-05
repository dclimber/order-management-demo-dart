import 'package:order_management_demo/composition/slice_registry.dart';
import 'package:test/test.dart';

void main() {
  test('allSlices registers six canonical slices in read-then-write order', () {
    expect(allSlices, hasLength(6));
    expect(allSlices.map((s) => s.name).toList(), [
      'restaurant_view',
      'order_view',
      'create_restaurant',
      'change_restaurant_menu',
      'place_order',
      'mark_order_as_prepared',
    ]);
  });
}
