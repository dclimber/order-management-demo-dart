import '../platform/event_store/serialization_registry.dart';
import 'slice_registry.dart';

/// Populate [SerializationRegistry] from all registered vertical slices (D8).
SerializationRegistry bootstrapSerializationRegistry() {
  final registry = SerializationRegistry();
  for (final slice in allSlices) {
    slice.registerSerialization(registry);
  }
  if (registry.isEmpty) {
    throw StateError('No event serializers registered');
  }
  return registry;
}
