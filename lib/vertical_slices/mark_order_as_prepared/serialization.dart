import '../../api.dart';
import '../../platform/event_store/serialization_registry.dart';

const orderPreparedEventKind = 'OrderPreparedEvent';

void registerMarkOrderAsPreparedSerialization(SerializationRegistry registry) {
  registry.register(
    eventType: OrderPreparedEvent,
    kind: orderPreparedEventKind,
    encode: _encode,
    decode: _decode,
  );
}

Map<String, dynamic> _encode(Event event) {
  final prepared = event as OrderPreparedEvent;
  return {
    'kind': orderPreparedEventKind,
    'orderId': prepared.orderId.value,
    'isFinal': prepared.isFinal,
  };
}

OrderPreparedEvent _decode(Map<String, dynamic> json) => OrderPreparedEvent(
  orderId: OrderId(json['orderId'] as String),
  isFinal: json['isFinal'] as bool? ?? true,
);
