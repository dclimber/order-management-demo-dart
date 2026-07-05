import '../../api.dart';
import '../../platform/event_store/event_payload.dart';
import '../../platform/event_store/serialization_registry.dart';

const restaurantOrderPlacedEventKind = 'RestaurantOrderPlacedEvent';

void registerPlaceOrderSerialization(SerializationRegistry registry) {
  registry.register(
    eventType: RestaurantOrderPlacedEvent,
    kind: restaurantOrderPlacedEventKind,
    encode: _encode,
    decode: _decode,
  );
}

Map<String, dynamic> _encode(Event event) {
  final placed = event as RestaurantOrderPlacedEvent;
  return {
    'kind': restaurantOrderPlacedEventKind,
    'restaurantId': placed.restaurantId.value,
    'orderId': placed.orderId.value,
    'menuItems': placed.menuItems.map(encodeMenuItem).toList(),
    'isFinal': placed.isFinal,
  };
}

RestaurantOrderPlacedEvent _decode(Map<String, dynamic> json) => RestaurantOrderPlacedEvent(
  restaurantId: RestaurantId(json['restaurantId'] as String),
  orderId: OrderId(json['orderId'] as String),
  menuItems: (json['menuItems'] as List<dynamic>).map((item) => decodeMenuItem(item as Map<String, dynamic>)).toList(),
  isFinal: json['isFinal'] as bool? ?? true,
);
