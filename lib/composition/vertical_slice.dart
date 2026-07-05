import 'api_registry.dart';
import 'app_context.dart';
import '../platform/event_store/serialization_registry.dart';
import 'ui_registry.dart';

/// Contract for a deletable vertical slice (D2, D3).
abstract interface class VerticalSlice {
  String get name;

  /// Register Shelf `/api/*` routes for this slice.
  void registerApi(ApiRegistry registry, AppContext ctx);

  /// Register Jaspr UI contributions (pages, sections, @client components).
  void registerUi(UiRegistry registry);

  /// Register encode/decode for event types this slice emits (write slices only; D8).
  void registerSerialization(SerializationRegistry registry);
}
