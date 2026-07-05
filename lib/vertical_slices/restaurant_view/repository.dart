import 'package:fmodel/fmodel.dart';

import '../../api.dart';
import '../../platform/event_store/event_store.dart';

typedef RestaurantViewQuery = RestaurantId;

final class RestaurantEphemeralViewRepository implements EphemeralViewRepository<RestaurantEvent, RestaurantViewQuery> {
  RestaurantEphemeralViewRepository(this._store);

  final EventStore _store;

  @override
  Stream<RestaurantEvent> fetchEvents(RestaurantViewQuery query) {
    return _store.streamForQueries([
      (tag: 'restaurantId', value: query.value, eventType: RestaurantCreatedEvent),
      (tag: 'restaurantId', value: query.value, eventType: RestaurantMenuChangedEvent),
    ]).cast<RestaurantEvent>();
  }
}
