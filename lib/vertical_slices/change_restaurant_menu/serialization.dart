import '../../api.dart';
import '../../platform/event_store/event_payload.dart';
import '../../platform/event_store/serialization_registry.dart';

const restaurantMenuChangedEventKind = 'RestaurantMenuChangedEvent';

void registerChangeRestaurantMenuSerialization(SerializationRegistry registry) {
  registry.register(
    eventType: RestaurantMenuChangedEvent,
    kind: restaurantMenuChangedEventKind,
    encode: _encode,
    decode: _decode,
  );
}

Map<String, dynamic> _encode(Event event) {
  final changed = event as RestaurantMenuChangedEvent;
  return {
    'kind': restaurantMenuChangedEventKind,
    'restaurantId': changed.restaurantId.value,
    'menu': encodeMenu(changed.menu),
    'isFinal': changed.isFinal,
  };
}

RestaurantMenuChangedEvent _decode(Map<String, dynamic> json) => RestaurantMenuChangedEvent(
  restaurantId: RestaurantId(json['restaurantId'] as String),
  menu: decodeMenu(json['menu'] as Map<String, dynamic>),
  isFinal: json['isFinal'] as bool? ?? true,
);
