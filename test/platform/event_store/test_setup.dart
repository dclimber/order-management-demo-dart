import 'package:order_management_demo/composition/serialization_bootstrap.dart';
import 'package:order_management_demo/platform/event_store/serialization.dart';

/// Configure per-slice event serialization for tests that persist events.
void setUpPlatformEventStore() {
  configureEventSerialization(bootstrapSerializationRegistry());
}
