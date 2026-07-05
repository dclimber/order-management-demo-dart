import '../../api.dart';

/// Tag field names per event type (mirrors TS `tagFields`).
const eventTagFields = <Type, List<String>>{
  RestaurantCreatedEvent: ['restaurantId'],
  RestaurantMenuChangedEvent: ['restaurantId'],
  RestaurantOrderPlacedEvent: ['restaurantId', 'orderId'],
  OrderPreparedEvent: ['orderId'],
};

/// Canonical event type name for indexing and serialization.
String eventTypeName(Event event) => switch (event) {
  RestaurantCreatedEvent() => 'RestaurantCreatedEvent',
  RestaurantMenuChangedEvent() => 'RestaurantMenuChangedEvent',
  RestaurantOrderPlacedEvent() => 'RestaurantOrderPlacedEvent',
  OrderPreparedEvent() => 'OrderPreparedEvent',
};

String typeName(Type type) => type.toString();

/// Extract sorted `fieldName:value` tags from a domain event.
List<String> extractTags(Event event) {
  final fields = eventTagFields[event.runtimeType] ?? [];
  return [
    for (final field in fields)
      if (_tagValue(event, field) case final value? when value.isNotEmpty) '$field:$value',
  ]..sort();
}

/// Generate all non-empty subsets (2^n - 1) from sorted [tags].
List<List<String>> generateTagSubsets(List<String> tags) {
  if (tags.isEmpty) return [];
  final subsets = <List<String>>[];
  final count = 1 << tags.length;
  for (var mask = 1; mask < count; mask++) {
    final subset = <String>[];
    for (var i = 0; i < tags.length; i++) {
      if ((mask & (1 << i)) != 0) {
        subset.add(tags[i]);
      }
    }
    subsets.add(subset);
  }
  return subsets;
}

String indexKey(String eventType, List<String> sortedTags) =>
    sortedTags.isEmpty ? eventType : '$eventType|${sortedTags.join('|')}';

String? _tagValue(Event event, String field) => switch (event) {
  RestaurantCreatedEvent(:final restaurantId) when field == 'restaurantId' => restaurantId.value,
  RestaurantMenuChangedEvent(:final restaurantId) when field == 'restaurantId' => restaurantId.value,
  RestaurantOrderPlacedEvent(:final restaurantId) when field == 'restaurantId' => restaurantId.value,
  RestaurantOrderPlacedEvent(:final orderId) when field == 'orderId' => orderId.value,
  OrderPreparedEvent(:final orderId) when field == 'orderId' => orderId.value,
  _ => null,
};
