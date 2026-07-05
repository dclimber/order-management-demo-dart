import '../../api.dart';
import 'serialization_registry.dart';

SerializationRegistry? _registry;

/// Wire slice-registered codecs before persisting or reading events.
void configureEventSerialization(SerializationRegistry registry) {
  _registry = registry;
}

SerializationRegistry get _configuredRegistry {
  final registry = _registry;
  if (registry == null) {
    throw StateError('Event serialization not configured. Call configureEventSerialization().');
  }
  return registry;
}

Map<String, dynamic> encodeEvent(Event event) => _configuredRegistry.encode(event);

Event decodeEvent(Map<String, dynamic> json) => _configuredRegistry.decode(json);
