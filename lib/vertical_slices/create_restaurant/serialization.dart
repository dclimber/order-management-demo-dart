import '../../api.dart';
import '../../platform/event_store/event_payload.dart';
import '../../platform/event_store/serialization_registry.dart';

const restaurantCreatedEventKind = 'RestaurantCreatedEvent';

void registerCreateRestaurantSerialization(SerializationRegistry registry) {
  registry.register(
    eventType: RestaurantCreatedEvent,
    kind: restaurantCreatedEventKind,
    encode: _encode,
    decode: _decode,
  );
}

Map<String, dynamic> _encode(Event event) {
  final created = event as RestaurantCreatedEvent;
  return {
    'kind': restaurantCreatedEventKind,
    'restaurantId': created.restaurantId.value,
    'name': created.name.value,
    'menu': encodeMenu(created.menu),
    'isFinal': created.isFinal,
  };
}

RestaurantCreatedEvent _decode(Map<String, dynamic> json) => RestaurantCreatedEvent(
  restaurantId: RestaurantId(json['restaurantId'] as String),
  name: RestaurantName(json['name'] as String),
  menu: decodeMenu(json['menu'] as Map<String, dynamic>),
  isFinal: json['isFinal'] as bool? ?? true,
);
