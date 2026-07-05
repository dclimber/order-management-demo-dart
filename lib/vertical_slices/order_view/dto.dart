import '../../api.dart';
import '../../platform/event_store/event_payload.dart';
import '../../platform/server/json_parse.dart';
import 'state.dart';

Map<String, dynamic> encodeOrderView(OrderViewState state) => {
  'orderId': state.orderId.value,
  'restaurantId': state.restaurantId.value,
  'menuItems': state.menuItems.map(encodeMenuItem).toList(),
  'status': switch (state.status) {
    OrderStatus.created => 'CREATED',
    OrderStatus.prepared => 'PREPARED',
  },
};

String orderStatusLabel(OrderStatus status) => switch (status) {
  OrderStatus.created => 'CREATED',
  OrderStatus.prepared => 'PREPARED',
};

List<Map<String, dynamic>> encodedOrders(List<OrderViewState> orders) => [
  for (final order in orders) encodeOrderView(order),
];

ParseResult<OrderStatus> parseKitchenStatusQuery(Map<String, String> query) {
  final value = query['status'];
  return switch (value) {
    'CREATED' => const ParseSuccess(OrderStatus.created),
    'PREPARED' => const ParseSuccess(OrderStatus.prepared),
    null || '' => const ParseError('status query parameter must be CREATED or PREPARED'),
    _ => const ParseError('status query parameter must be CREATED or PREPARED'),
  };
}

ParseResult<String> parseOrderIdQuery(Map<String, String> query) {
  final value = query['orderId'];
  if (value == null || value.isEmpty) {
    return const ParseError('orderId query parameter is required');
  }
  return ParseSuccess(value);
}
